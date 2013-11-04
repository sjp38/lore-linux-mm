Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 648116B0037
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 11:16:41 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id fb1so7116569pad.37
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 08:16:41 -0800 (PST)
Received: from psmtp.com ([74.125.245.131])
        by mx.google.com with SMTP id z1si155784pbn.151.2013.11.04.08.16.38
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 08:16:39 -0800 (PST)
Message-ID: <5277C862.4080605@suse.cz>
Date: Mon, 04 Nov 2013 17:16:34 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/2] vmsplice: unmap gifted pages for recipient
References: <1382715984-10558-1-git-send-email-rcj@linux.vnet.ibm.com> <1382715984-10558-2-git-send-email-rcj@linux.vnet.ibm.com>
In-Reply-To: <1382715984-10558-2-git-send-email-rcj@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Jennings <rcj@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Simon Jin <simonjin@linux.vnet.ibm.com>

On 10/25/2013 05:46 PM, Robert Jennings wrote:
> From: Robert C Jennings <rcj@linux.vnet.ibm.com>
> 
> Introduce use of the unused SPLICE_F_MOVE flag for vmsplice to zap
> pages.
> 
> When vmsplice is called with flags (SPLICE_F_GIFT | SPLICE_F_MOVE) the
> writer's gift'ed pages would be zapped.  This patch supports further work
> to move vmsplice'd pages rather than copying them.  That patch has the
> restriction that the page must not be mapped by the source for the move,
> otherwise it will fall back to copying the page.
> 
> Signed-off-by: Matt Helsley <matt.helsley@gmail.com>
> Signed-off-by: Robert C Jennings <rcj@linux.vnet.ibm.com>
> ---
> Changes since v1:
>  - Cleanup zap coalescing in splice_to_pipe for readability
>  - Field added to struct partial_page in v1 was unnecessary, using 
>    private field instead.
> ---
>  fs/splice.c | 38 ++++++++++++++++++++++++++++++++++++++
>  1 file changed, 38 insertions(+)
> 
> diff --git a/fs/splice.c b/fs/splice.c
> index 3b7ee65..c14be6f 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -188,12 +188,18 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
>  {
>  	unsigned int spd_pages = spd->nr_pages;
>  	int ret, do_wakeup, page_nr;
> +	struct vm_area_struct *vma;
> +	unsigned long user_start, user_end, addr;
>  
>  	ret = 0;
>  	do_wakeup = 0;
>  	page_nr = 0;
> +	vma = NULL;
> +	user_start = user_end = 0;
>  
>  	pipe_lock(pipe);
> +	/* mmap_sem taken for zap_page_range with SPLICE_F_MOVE */
> +	down_read(&current->mm->mmap_sem);

I have suggested taking the semaphore here only when the gift and move
flags are set. You said that taking it outside the loop and acquiring it
once already improved performance. This is OK, but my point was to not
take the semaphore at all for vmsplice calls without these flags, to
avoid unnecessary contention.

>  
>  	for (;;) {
>  		if (!pipe->readers) {
> @@ -215,6 +221,33 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
>  			if (spd->flags & SPLICE_F_GIFT)
>  				buf->flags |= PIPE_BUF_FLAG_GIFT;
>  
> +			/* Prepare to move page sized/aligned bufs.
> +			 * Gather pages for a single zap_page_range()
> +			 * call per VMA.
> +			 */
> +			if (spd->flags & (SPLICE_F_GIFT | SPLICE_F_MOVE) &&
> +					!buf->offset &&
> +					(buf->len == PAGE_SIZE)) {
> +				addr = buf->private;

Here you assume that buf->private (initialized from
spd->partial[page_nr].private) will contain a valid address whenever the
GIFT and MOVE flags are set. I think that's quite dangerous and could be
easily exploited. Briefly looking it seems to me that at least one
caller of splice_to_pipe(), __generic_file_splice_read() doesn't
initialize the on-stack-allocated private fields, and it can take flags
directly from the splice syscall.

> +
> +				if (vma && (addr == user_end) &&
> +					   (addr + PAGE_SIZE <= vma->vm_end)) {
> +					/* Same vma, no holes */
> +					user_end += PAGE_SIZE;
> +				} else {
> +					if (vma)
> +						zap_page_range(vma, user_start,
> +							(user_end - user_start),
> +							NULL);
> +					vma = find_vma(current->mm, addr);

Seems like there is a good chance that when crossing over previous vma's
vm_end, taking the next vma would suffice instead of find_vma().

> +					if (!IS_ERR_OR_NULL(vma)) {
> +						user_start = addr;
> +						user_end = (addr + PAGE_SIZE);
> +					} else
> +						vma = NULL;
> +				}
> +			}
> +
>  			pipe->nrbufs++;
>  			page_nr++;
>  			ret += buf->len;
> @@ -255,6 +288,10 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
>  		pipe->waiting_writers--;
>  	}
>  
> +	if (vma)
> +		zap_page_range(vma, user_start, (user_end - user_start), NULL);
> +
> +	up_read(&current->mm->mmap_sem);
>  	pipe_unlock(pipe);
>  
>  	if (do_wakeup)
> @@ -1475,6 +1512,7 @@ static int get_iovec_page_array(const struct iovec __user *iov,
>  
>  			partial[buffers].offset = off;
>  			partial[buffers].len = plen;
> +			partial[buffers].private = (unsigned long)base;
>  
>  			off = 0;
>  			len -= plen;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
