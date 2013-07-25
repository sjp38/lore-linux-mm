Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 29F406B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 13:30:26 -0400 (EDT)
Message-ID: <51F160A5.2040004@sr71.net>
Date: Thu, 25 Jul 2013 10:30:13 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/2] vmsplice unmap gifted pages for recipient
References: <1374772906-21511-1-git-send-email-rcj@linux.vnet.ibm.com> <1374772906-21511-2-git-send-email-rcj@linux.vnet.ibm.com>
In-Reply-To: <1374772906-21511-2-git-send-email-rcj@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Jennings <rcj@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <aliguori@us.ibm.com>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>

On 07/25/2013 10:21 AM, Robert Jennings wrote:
> +static void zap_buf_page(unsigned long useraddr)
> +{
> +	struct vm_area_struct *vma;
> +
> +	down_read(&current->mm->mmap_sem);
> +	vma = find_vma_intersection(current->mm, useraddr,
> +			useraddr + PAGE_SIZE);
> +	if (!IS_ERR_OR_NULL(vma))
> +		zap_page_range(vma, useraddr, PAGE_SIZE, NULL);
> +	up_read(&current->mm->mmap_sem);
> +}
> +
>  /**
>   * splice_to_pipe - fill passed data into a pipe
>   * @pipe:	pipe to fill
> @@ -212,8 +224,16 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
>  			buf->len = spd->partial[page_nr].len;
>  			buf->private = spd->partial[page_nr].private;
>  			buf->ops = spd->ops;
> -			if (spd->flags & SPLICE_F_GIFT)
> +			if (spd->flags & SPLICE_F_GIFT) {
> +				unsigned long useraddr =
> +						spd->partial[page_nr].useraddr;
> +
> +				if ((spd->flags & SPLICE_F_MOVE) &&
> +				    !buf->offset && (buf->len == PAGE_SIZE))
> +					/* Can move page aligned buf */
> +					zap_buf_page(useraddr);
>  				buf->flags |= PIPE_BUF_FLAG_GIFT;
> +			}

There isn't quite enough context here, but is it going to do this
zap_buf_page() very often?  Seems a bit wasteful to do the up/down and
find_vma() every trip through the loop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
