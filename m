Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E28366B004A
	for <linux-mm@kvack.org>; Sun, 24 Jul 2011 07:32:03 -0400 (EDT)
Date: Sun, 24 Jul 2011 07:32:00 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/8] xfs: Warn if direct reclaim tries to writeback pages
Message-ID: <20110724113200.GA26332@infradead.org>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311265730-5324-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <jweiner@redhat.com>

On Thu, Jul 21, 2011 at 05:28:44PM +0100, Mel Gorman wrote:
> --- a/fs/xfs/linux-2.6/xfs_aops.c
> +++ b/fs/xfs/linux-2.6/xfs_aops.c
> @@ -930,12 +930,13 @@ xfs_vm_writepage(
>  	 * random callers for direct reclaim or memcg reclaim.  We explicitly
>  	 * allow reclaim from kswapd as the stack usage there is relatively low.
>  	 *
> -	 * This should really be done by the core VM, but until that happens
> -	 * filesystems like XFS, btrfs and ext4 have to take care of this
> -	 * by themselves.
> +	 * This should never happen except in the case of a VM regression so
> +	 * warn about it.
>  	 */
> -	if ((current->flags & (PF_MEMALLOC|PF_KSWAPD)) == PF_MEMALLOC)
> +	if ((current->flags & (PF_MEMALLOC|PF_KSWAPD)) == PF_MEMALLOC) {
> +		WARN_ON_ONCE(1);
>  		goto redirty;

The nicer way to write this is

	if (WARN_ON(current->flags & (PF_MEMALLOC|PF_KSWAPD)) == PF_MEMALLOC)
		goto redirty;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
