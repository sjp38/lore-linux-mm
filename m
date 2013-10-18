Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id DE33A6B012A
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 04:10:20 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so3487552pbb.41
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 01:10:20 -0700 (PDT)
Received: from psmtp.com ([74.125.245.192])
        by mx.google.com with SMTP id gw3si788807pac.317.2013.10.18.01.10.18
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 01:10:19 -0700 (PDT)
Message-ID: <5260ECE2.6010106@suse.cz>
Date: Fri, 18 Oct 2013 10:10:10 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmsplice: unmap gifted pages for recipient
References: <1381177293-27125-1-git-send-email-rcj@linux.vnet.ibm.com> <1381177293-27125-2-git-send-email-rcj@linux.vnet.ibm.com> <525FB9EE.3070609@suse.cz> <20131017134827.GB19741@linux.vnet.ibm.com>
In-Reply-To: <20131017134827.GB19741@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>

On 10/17/2013 03:48 PM, Robert Jennings wrote:
> * Vlastimil Babka (vbabka@suse.cz) wrote:
>> On 10/07/2013 10:21 PM, Robert C Jennings wrote:
>>> Introduce use of the unused SPLICE_F_MOVE flag for vmsplice to zap
>>> pages.
>>>
>>> When vmsplice is called with flags (SPLICE_F_GIFT | SPLICE_F_MOVE) the
>>> writer's gift'ed pages would be zapped.  This patch supports further work
>>> to move vmsplice'd pages rather than copying them.  That patch has the
>>> restriction that the page must not be mapped by the source for the move,
>>> otherwise it will fall back to copying the page.
>>>
>>> Signed-off-by: Matt Helsley <matt.helsley@gmail.com>
>>> Signed-off-by: Robert C Jennings <rcj@linux.vnet.ibm.com>
>>> ---
>>> Since the RFC went out I have coalesced the zap_page_range() call to
>>> operate on VMAs rather than calling this for each page.  For a 256MB
>>> vmsplice this reduced the write side 50% from the RFC.
>>> ---
>>>  fs/splice.c            | 51 +++++++++++++++++++++++++++++++++++++++++++++++++-
>>>  include/linux/splice.h |  1 +
>>>  2 files changed, 51 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/fs/splice.c b/fs/splice.c
>>> index 3b7ee65..a62d61e 100644
>>> --- a/fs/splice.c
>>> +++ b/fs/splice.c
>>> @@ -188,12 +188,17 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
>>>  {
>>>  	unsigned int spd_pages = spd->nr_pages;
>>>  	int ret, do_wakeup, page_nr;
>>> +	struct vm_area_struct *vma;
>>> +	unsigned long user_start, user_end;
>>>  
>>>  	ret = 0;
>>>  	do_wakeup = 0;
>>>  	page_nr = 0;
>>> +	vma = NULL;
>>> +	user_start = user_end = 0;
>>>  
>>>  	pipe_lock(pipe);
>>> +	down_read(&current->mm->mmap_sem);
>>
>> Seems like you could take the mmap_sem only when GIFT and MOVE is set.
>> Maybe it won't help that much for performance but at least serve as
>> documenting the reason it's needed?
>>
>> Vlastimil
>>
> 
> I had been doing that previously but moving this outside the loop and
> acquiring it once did improve performance.  I'll add a comment on
> down_read() as to the reason for taking this though.
> 
> -Rob

Hm perhaps in light of recent patches to reduce mmap_sem usage only to
really critical regions, maybe it really shouldn't be taken at all if
not needed.

Vlastimil

>>>  	for (;;) {
>>>  		if (!pipe->readers) {
>>> @@ -212,8 +217,44 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
>>>  			buf->len = spd->partial[page_nr].len;
>>>  			buf->private = spd->partial[page_nr].private;
>>>  			buf->ops = spd->ops;
>>> -			if (spd->flags & SPLICE_F_GIFT)
>>> +			if (spd->flags & SPLICE_F_GIFT) {
>>> +				unsigned long useraddr =
>>> +						spd->partial[page_nr].useraddr;
>>> +
>>> +				if ((spd->flags & SPLICE_F_MOVE) &&
>>> +						!buf->offset &&
>>> +						(buf->len == PAGE_SIZE)) {
>>> +					/* Can move page aligned buf, gather
>>> +					 * requests to make a single
>>> +					 * zap_page_range() call per VMA
>>> +					 */
>>> +					if (vma && (useraddr == user_end) &&
>>> +						   ((useraddr + PAGE_SIZE) <=
>>> +						    vma->vm_end)) {
>>> +						/* same vma, no holes */
>>> +						user_end += PAGE_SIZE;
>>> +					} else {
>>> +						if (vma)
>>> +							zap_page_range(vma,
>>> +								user_start,
>>> +								(user_end -
>>> +								 user_start),
>>> +								NULL);
>>> +						vma = find_vma_intersection(
>>> +								current->mm,
>>> +								useraddr,
>>> +								(useraddr +
>>> +								 PAGE_SIZE));
>>> +						if (!IS_ERR_OR_NULL(vma)) {
>>> +							user_start = useraddr;
>>> +							user_end = (useraddr +
>>> +								    PAGE_SIZE);
>>> +						} else
>>> +							vma = NULL;
>>> +					}
>>> +				}
>>>  				buf->flags |= PIPE_BUF_FLAG_GIFT;
>>> +			}
>>>  
>>>  			pipe->nrbufs++;
>>>  			page_nr++;
>>> @@ -255,6 +296,10 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
>>>  		pipe->waiting_writers--;
>>>  	}
>>>  
>>> +	if (vma)
>>> +		zap_page_range(vma, user_start, (user_end - user_start), NULL);
>>> +
>>> +	up_read(&current->mm->mmap_sem);
>>>  	pipe_unlock(pipe);
>>>  
>>>  	if (do_wakeup)
>>> @@ -485,6 +530,7 @@ fill_it:
>>>  
>>>  		spd.partial[page_nr].offset = loff;
>>>  		spd.partial[page_nr].len = this_len;
>>> +		spd.partial[page_nr].useraddr = index << PAGE_CACHE_SHIFT;
>>>  		len -= this_len;
>>>  		loff = 0;
>>>  		spd.nr_pages++;
>>> @@ -656,6 +702,7 @@ ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
>>>  		this_len = min_t(size_t, vec[i].iov_len, res);
>>>  		spd.partial[i].offset = 0;
>>>  		spd.partial[i].len = this_len;
>>> +		spd.partial[i].useraddr = (unsigned long)vec[i].iov_base;
>>>  		if (!this_len) {
>>>  			__free_page(spd.pages[i]);
>>>  			spd.pages[i] = NULL;
>>> @@ -1475,6 +1522,8 @@ static int get_iovec_page_array(const struct iovec __user *iov,
>>>  
>>>  			partial[buffers].offset = off;
>>>  			partial[buffers].len = plen;
>>> +			partial[buffers].useraddr = (unsigned long)base;
>>> +			base = (void*)((unsigned long)base + PAGE_SIZE);
>>>  
>>>  			off = 0;
>>>  			len -= plen;
>>> diff --git a/include/linux/splice.h b/include/linux/splice.h
>>> index 74575cb..56661e3 100644
>>> --- a/include/linux/splice.h
>>> +++ b/include/linux/splice.h
>>> @@ -44,6 +44,7 @@ struct partial_page {
>>>  	unsigned int offset;
>>>  	unsigned int len;
>>>  	unsigned long private;
>>> +	unsigned long useraddr;
>>>  };
>>>  
>>>  /*
>>>
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
