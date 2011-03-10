Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 38BE28D0047
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 02:37:55 -0500 (EST)
Date: Thu, 10 Mar 2011 02:37:51 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] xfs: flush vmap aliases when mapping fails
Message-ID: <20110310073751.GB25374@infradead.org>
References: <1299713876-7747-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299713876-7747-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, npiggin@kernel.dk, linux-mm@kvack.org

On Thu, Mar 10, 2011 at 10:37:56AM +1100, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> On 32 bit systems, vmalloc space is limited and XFS can chew through
> it quickly as the vmalloc space is lazily freed. This can result in
> failure to map buffers, even when there is apparently large amounts
> of vmalloc space available. Hence, if we fail to map a buffer, purge
> the aliases that have not yet been freed to hopefuly free up enough
> vmalloc space to allow a retry to succeed.

IMHO this should be done by vm_map_ram internally.  If we can't get the
core code fixes we can put this in as a last resort.

> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/linux-2.6/xfs_buf.c |   14 +++++++++++---
>  1 files changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
> index 3cc671c..a5a260f 100644
> --- a/fs/xfs/linux-2.6/xfs_buf.c
> +++ b/fs/xfs/linux-2.6/xfs_buf.c
> @@ -455,9 +455,17 @@ _xfs_buf_map_pages(
>  		bp->b_addr = page_address(bp->b_pages[0]) + bp->b_offset;
>  		bp->b_flags |= XBF_MAPPED;
>  	} else if (flags & XBF_MAPPED) {
> -		bp->b_addr = vm_map_ram(bp->b_pages, bp->b_page_count,
> -					-1, PAGE_KERNEL);
> -		if (unlikely(bp->b_addr == NULL))
> +		int retried = 0;
> +
> +		do {
> +			bp->b_addr = vm_map_ram(bp->b_pages, bp->b_page_count,
> +						-1, PAGE_KERNEL);
> +			if (bp->b_addr)
> +				break;
> +			vm_unmap_aliases();
> +		} while (retried++ <= 1);
> +
> +		if (!bp->b_addr)
>  			return -ENOMEM;
>  		bp->b_addr += bp->b_offset;
>  		bp->b_flags |= XBF_MAPPED;
> -- 
> 1.7.2.3
> 
> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
