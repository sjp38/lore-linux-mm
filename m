Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D7A856B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 09:37:43 -0400 (EDT)
Date: Tue, 14 Sep 2010 15:36:52 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/4] writeback: introduce bdi_start_inode_writeback()
Message-ID: <20100914133652.GC4874@quack.suse.cz>
References: <20100913123110.372291929@intel.com>
 <20100913130150.138758012@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100913130150.138758012@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon 13-09-10 20:31:13, Wu Fengguang wrote:
> This is to transfer dirty pages encountered in page reclaim to the
> flusher threads for writeback.
> 
> The flusher will piggy back more dirty pages for IO
> - it's more IO efficient
> - it helps clean more pages, a good number of them may sit in the same
>   LRU list that is being scanned.
> 
> To avoid memory allocations at page reclaim, a mempool is created.
> 
> Background/periodic works will quit automatically, so as to clean the
> pages under reclaim ASAP. However the sync work can still block us for
> long time.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c           |  103 +++++++++++++++++++++++++++++++++-
>  include/linux/backing-dev.h |    2 
>  2 files changed, 102 insertions(+), 3 deletions(-)
> 
...
> +int bdi_start_inode_writeback(struct backing_dev_info *bdi,
> +			      struct inode *inode, pgoff_t offset)
> +{
> +	struct wb_writeback_work *work;
> +
> +	spin_lock_bh(&bdi->wb_lock);
> +	list_for_each_entry_reverse(work, &bdi->work_list, list) {
> +		unsigned long end;
> +		if (work->inode != inode)
> +			continue;
  Hmm, this looks rather inefficient. I can imagine the list of work items
can grow rather large on memory stressed machine and the linear scan does
not play well with that (and contention on wb_lock would make it even
worse). I'm not sure how to best handle your set of intervals... RB tree
attached to an inode is an obvious choice but it seems too expensive
(memory spent for every inode) for such a rare use. Maybe you could have
a per-bdi mapping (hash table) from ino to it's tree of intervals for
reclaim... But before going for this, probably measuring how many intervals
are we going to have under memory pressure would be good.

> +		end = work->offset + work->nr_pages;
> +		if (work->offset - offset < WRITE_AROUND_PAGES) {
       It's slightly unclear what's intended here when offset >
work->offset. Could you make that explicit?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
