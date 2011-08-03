Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E85126B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 07:10:43 -0400 (EDT)
Date: Wed, 3 Aug 2011 13:10:31 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 4/8] btrfs: Warn if direct reclaim tries to writeback
 pages
Message-ID: <20110803111031.GC27199@redhat.com>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311265730-5324-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 21, 2011 at 05:28:46PM +0100, Mel Gorman wrote:
> Direct reclaim should never writeback pages. Warn if an attempt is
> made. By rights, btrfs should be allowing writepage from kswapd if
> it is failing to reclaim pages by any other means but it's outside
> the scope of this patch.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  fs/btrfs/disk-io.c |    2 ++
>  fs/btrfs/inode.c   |    2 ++
>  2 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
> index 1ac8db5d..cc9c9cf 100644
> --- a/fs/btrfs/disk-io.c
> +++ b/fs/btrfs/disk-io.c
> @@ -829,6 +829,8 @@ static int btree_writepage(struct page *page, struct writeback_control *wbc)
>  
>  	tree = &BTRFS_I(page->mapping->host)->io_tree;
>  	if (!(current->flags & PF_MEMALLOC)) {
> +		WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
> +								PF_MEMALLOC);

Since it is branch for PF_MEMALLOC being set, why not just
WARN_ON_ONCE(!(current->flags & PF_KSWAPD)) instead?

Minor nitpick, though, and I can understand if you just want to have
the conditionals be the same in every fs.

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
