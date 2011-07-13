Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B7AAB6B004A
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 19:56:11 -0400 (EDT)
Date: Thu, 14 Jul 2011 09:56:06 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 5/5] mm: writeback: Prioritise dirty inodes encountered
 by direct reclaim for background flushing
Message-ID: <20110713235606.GX23038@dastard>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <1310567487-15367-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1310567487-15367-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Wed, Jul 13, 2011 at 03:31:27PM +0100, Mel Gorman wrote:
> It is preferable that no dirty pages are dispatched from the page
> reclaim path. If reclaim is encountering dirty pages, it implies that
> either reclaim is getting ahead of writeback or use-once logic has
> prioritise pages for reclaiming that are young relative to when the
> inode was dirtied.
> 
> When dirty pages are encounted on the LRU, this patch marks the inodes
> I_DIRTY_RECLAIM and wakes the background flusher. When the background
> flusher runs, it moves such inodes immediately to the dispatch queue
> regardless of inode age. There is no guarantee that pages reclaim
> cares about will be cleaned first but the expectation is that the
> flusher threads will clean the page quicker than if reclaim tried to
> clean a single page.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  fs/fs-writeback.c         |   56 ++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/fs.h        |    5 ++-
>  include/linux/writeback.h |    1 +
>  mm/vmscan.c               |   16 ++++++++++++-
>  4 files changed, 74 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 0f015a0..1201052 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -257,9 +257,23 @@ static void move_expired_inodes(struct list_head *delaying_queue,
>  	LIST_HEAD(tmp);
>  	struct list_head *pos, *node;
>  	struct super_block *sb = NULL;
> -	struct inode *inode;
> +	struct inode *inode, *tinode;
>  	int do_sb_sort = 0;
>  
> +	/* Move inodes reclaim found at end of LRU to dispatch queue */
> +	list_for_each_entry_safe(inode, tinode, delaying_queue, i_wb_list) {
> +		/* Move any inode found at end of LRU to dispatch queue */
> +		if (inode->i_state & I_DIRTY_RECLAIM) {
> +			inode->i_state &= ~I_DIRTY_RECLAIM;
> +			list_move(&inode->i_wb_list, &tmp);
> +
> +			if (sb && sb != inode->i_sb)
> +				do_sb_sort = 1;
> +			sb = inode->i_sb;
> +		}
> +	}

This is not a good idea. move_expired_inodes() already sucks a large
amount of CPU when there are lots of dirty inodes on the list (think
hundreds of thousands), and that is when the traversal terminates at
*older_than_this. It's not uncommon in my testing to see this
one function consume 30-35% of the bdi-flusher thread CPU usage
in such conditions.

By adding an entire list traversal in addition to the aging
traversal, this is going significantly increase the CPU overhead of
the function and hence could significantly increase
bdi->wb_list_lock contention and decrease writeback throughput.

> +
> +	sb = NULL;
>  	while (!list_empty(delaying_queue)) {
>  		inode = wb_inode(delaying_queue->prev);
>  		if (older_than_this &&
> @@ -968,6 +982,46 @@ void wakeup_flusher_threads(long nr_pages)
>  	rcu_read_unlock();
>  }
>  
> +/*
> + * Similar to wakeup_flusher_threads except prioritise inodes contained
> + * in the page_list regardless of age
> + */
> +void wakeup_flusher_threads_pages(long nr_pages, struct list_head *page_list)
> +{
> +	struct page *page;
> +	struct address_space *mapping;
> +	struct inode *inode;
> +
> +	list_for_each_entry(page, page_list, lru) {
> +		if (!PageDirty(page))
> +			continue;
> +
> +		if (PageSwapBacked(page))
> +			continue;
> +
> +		lock_page(page);
> +		mapping = page_mapping(page);
> +		if (!mapping)
> +			goto unlock;
> +
> +		/*
> +		 * Test outside the lock to see as if it is already set. Inode
> +		 * should be pinned by the lock_page
> +		 */
> +		inode = page->mapping->host;
> +		if (inode->i_state & I_DIRTY_RECLAIM)
> +			goto unlock;
> +
> +		spin_lock(&inode->i_lock);
> +		inode->i_state |= I_DIRTY_RECLAIM;
> +		spin_unlock(&inode->i_lock);

Micro optimisations like this are unnecessary - the inode->i_lock is
not contended.

As it is, this code won't really work as you think it might.
There's no guarantee a dirty inode is on the dirty - it might have
already been expired, and it might even currently be under
writeback.  In that case, if it is still dirty it goes to the
b_more_io list and writeback bandwidth is shared between all the
other dirty inodes and completely ignores this flag...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
