Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 86D986B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 19:04:05 -0500 (EST)
Date: Tue, 28 Feb 2012 16:04:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
Message-Id: <20120228160403.9c9fa4dc.akpm@linux-foundation.org>
In-Reply-To: <20120228144747.198713792@intel.com>
References: <20120228140022.614718843@intel.com>
	<20120228144747.198713792@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 28 Feb 2012 22:00:27 +0800
Fengguang Wu <fengguang.wu@intel.com> wrote:

> This relays file pageout IOs to the flusher threads.
> 
> It's much more important now that page reclaim generally does not
> writeout filesystem-backed pages.

It doesn't?  We still do writeback in direct reclaim.  This claim
should be fleshed out rather a lot, please.

> The ultimate target is to gracefully handle the LRU lists pressured by
> dirty/writeback pages. In particular, problems (1-2) are addressed here.
> 
> 1) I/O efficiency
> 
> The flusher will piggy back the nearby ~10ms worth of dirty pages for I/O.
> 
> This takes advantage of the time/spacial locality in most workloads: the
> nearby pages of one file are typically populated into the LRU at the same
> time, hence will likely be close to each other in the LRU list. Writing
> them in one shot helps clean more pages effectively for page reclaim.

Yes, this is often true.  But when adjacent pages from the same file
are clustered together on the LRU, direct reclaim's LRU-based walk will
also provide good I/O patterns.

> For the common dd style sequential writes that have excellent locality,
> up to ~80ms data will be wrote around by the pageout work, which helps
> make I/O performance very close to that of the background writeback.
> 
> 2) writeback work coordinations
> 
> To avoid memory allocations at page reclaim, a mempool for struct
> wb_writeback_work is created.
> 
> wakeup_flusher_threads() is removed because it can easily delay the
> more oriented pageout works and even exhaust the mempool reservations.
> It's also found to not I/O efficient by frequently submitting writeback
> works with small ->nr_pages.

The last sentence here needs help.

> Background/periodic works will quit automatically, so as to clean the
> pages under reclaim ASAP.

I don't know what this means.  How does a work "quit automatically" and
why does that initiate I/O?

> However for now the sync work can still block
> us for long time.

Please define the term "sync work".

> Jan Kara: limit the search scope; remove works and unpin inodes on umount.
> 
> TODO: the pageout works may be starved by the sync work and maybe others.
> Need a proper way to guarantee fairness.
> 
> CC: Jan Kara <jack@suse.cz>
> CC: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>
> CC: Greg Thelen <gthelen@google.com>
> CC: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c                |  230 +++++++++++++++++++++++++++--
>  fs/super.c                       |    1 
>  include/linux/backing-dev.h      |    2 
>  include/linux/writeback.h        |   16 +-
>  include/trace/events/writeback.h |   12 +
>  mm/vmscan.c                      |   36 ++--
>  6 files changed, 268 insertions(+), 29 deletions(-)
> 
> --- linux.orig/fs/fs-writeback.c	2012-02-28 19:07:06.109064465 +0800
> +++ linux/fs/fs-writeback.c	2012-02-28 19:07:07.277064493 +0800
> @@ -41,6 +41,8 @@ struct wb_writeback_work {
>  	long nr_pages;
>  	struct super_block *sb;
>  	unsigned long *older_than_this;
> +	struct inode *inode;
> +	pgoff_t offset;

Please document `offset' here.  What is it used for?

>  	enum writeback_sync_modes sync_mode;
>  	unsigned int tagged_writepages:1;
>  	unsigned int for_kupdate:1;
> @@ -57,6 +59,27 @@ struct wb_writeback_work {
>   */
>  int nr_pdflush_threads;
>  
> +static mempool_t *wb_work_mempool;
> +
> +static void *wb_work_alloc(gfp_t gfp_mask, void *pool_data)

The gfp_mask is traditionally the last function argument.

> +{
> +	/*
> +	 * alloc_queue_pageout_work() will be called on page reclaim
> +	 */
> +	if (current->flags & PF_MEMALLOC)
> +		return NULL;

Do we need to test current->flags here?  Could we have checked
!(gfp_mask & __GFP_IO) and/or __GFP_FILE?

I'm not really suggsting such a change - just trying to get my head
around how this stuff works..


> +	return kmalloc(sizeof(struct wb_writeback_work), gfp_mask);
> +}
> +
> +static __init int wb_work_init(void)
> +{
> +	wb_work_mempool = mempool_create(WB_WORK_MEMPOOL_SIZE,
> +					 wb_work_alloc, mempool_kfree, NULL);
> +	return wb_work_mempool ? 0 : -ENOMEM;
> +}
> +fs_initcall(wb_work_init);

Please provide a description of the wb_writeback_work lifecycle: when
they are allocated, when they are freed, how we ensure that a finite
number are in flight.

Also, when a mempool_alloc() caller is waiting for wb_writeback_works
to be freed, how are we dead certain that some *will* be freed?  It
means that the mempool_alloc() caller cannot be holding any explicit or
implicit locks which would prevent wb_writeback_works would be freed. 
Where "implicit lock" means things like being inside ext3/4
journal_start.

This stuff is tricky and is hard to get right.  Reviewing its
correctness by staring at a patch is difficult.

>  /**
>   * writeback_in_progress - determine whether there is writeback in progress
>   * @bdi: the device's backing_dev_info structure.
> @@ -129,7 +152,7 @@ __bdi_start_writeback(struct backing_dev
>  	 * This is WB_SYNC_NONE writeback, so if allocation fails just
>  	 * wakeup the thread for old dirty data writeback
>  	 */
> -	work = kzalloc(sizeof(*work), GFP_ATOMIC);
> +	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);

Sneaky change from GFP_ATOMIC to GFP_NOWAIT is significant, but
undescribed?

>  	if (!work) {
>  		if (bdi->wb.task) {
>  			trace_writeback_nowork(bdi);
> @@ -138,6 +161,7 @@ __bdi_start_writeback(struct backing_dev
>  		return;
>  	}
>  
> +	memset(work, 0, sizeof(*work));
>  	work->sync_mode	= WB_SYNC_NONE;
>  	work->nr_pages	= nr_pages;
>  	work->range_cyclic = range_cyclic;
> @@ -187,6 +211,181 @@ void bdi_start_background_writeback(stru
>  }
>  
>  /*
> + * Check if @work already covers @offset, or try to extend it to cover @offset.
> + * Returns true if the wb_writeback_work now encompasses the requested offset.
> + */
> +static bool extend_writeback_range(struct wb_writeback_work *work,
> +				   pgoff_t offset,
> +				   unsigned long unit)
> +{
> +	pgoff_t end = work->offset + work->nr_pages;
> +
> +	if (offset >= work->offset && offset < end)
> +		return true;
> +
> +	/*
> +	 * for sequential workloads with good locality, include up to 8 times
> +	 * more data in one chunk
> +	 */
> +	if (work->nr_pages >= 8 * unit)
> +		return false;

argh, gack, puke.  I thought I revoked your magic number license months ago!

Please, it's a HUGE red flag that bad things are happening.  Would the
kernel be better or worse if we were to use 9.5 instead?  How do we
know that "8" is optimum for all memory sizes, device bandwidths, etc?

It's a hack - it's *always* a hack.  Find a better way.

> +	/* the unsigned comparison helps eliminate one compare */
> +	if (work->offset - offset < unit) {
> +		work->nr_pages += unit;
> +		work->offset -= unit;
> +		return true;
> +	}
> +
> +	if (offset - end < unit) {
> +		work->nr_pages += unit;
> +		return true;
> +	}
> +
> +	return false;
> +}
> +
> +/*
> + * schedule writeback on a range of inode pages.
> + */
> +static struct wb_writeback_work *
> +alloc_queue_pageout_work(struct backing_dev_info *bdi,
> +			 struct inode *inode,
> +			 pgoff_t offset,
> +			 pgoff_t len)
> +{
> +	struct wb_writeback_work *work;
> +
> +	/*
> +	 * Grab the inode until the work is executed. We are calling this from
> +	 * page reclaim context and the only thing pinning the address_space
> +	 * for the moment is the page lock.
> +	 */
> +	if (!igrab(inode))
> +		return ERR_PTR(-ENOENT);

uh-oh.  igrab() means iput().

ENOENT means "no such file or directory" and makes no sense in this
context.

> +	work = mempool_alloc(wb_work_mempool, GFP_NOWAIT);
> +	if (!work) {
> +		trace_printk("wb_work_mempool alloc fail\n");
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
> +	memset(work, 0, sizeof(*work));
> +	work->sync_mode		= WB_SYNC_NONE;
> +	work->inode		= inode;
> +	work->offset		= offset;
> +	work->nr_pages		= len;
> +	work->reason		= WB_REASON_PAGEOUT;
> +
> +	bdi_queue_work(bdi, work);
> +
> +	return work;
> +}
> +
> +/*
> + * Called by page reclaim code to flush the dirty page ASAP. Do write-around to
> + * improve IO throughput. The nearby pages will have good chance to reside in
> + * the same LRU list that vmscan is working on, and even close to each other
> + * inside the LRU list in the common case of sequential read/write.
> + *
> + * ret > 0: success, allocated/queued a new pageout work;
> + *	    there are at least @ret writeback works queued now
> + * ret = 0: success, reused/extended a previous pageout work
> + * ret < 0: failed
> + */
> +int queue_pageout_work(struct address_space *mapping, struct page *page)
> +{
> +	struct backing_dev_info *bdi = mapping->backing_dev_info;
> +	struct inode *inode = mapping->host;
> +	struct wb_writeback_work *work;
> +	unsigned long write_around_pages;
> +	pgoff_t offset = page->index;
> +	int i = 0;
> +	int ret = -ENOENT;

ENOENT means "no such file or directory" and makes no sense in this
context.

> +	if (unlikely(!inode))
> +		return ret;

How does this happen?

> +	/*
> +	 * piggy back 8-15ms worth of data
> +	 */
> +	write_around_pages = bdi->avg_write_bandwidth + MIN_WRITEBACK_PAGES;
> +	write_around_pages = rounddown_pow_of_two(write_around_pages) >> 6;

Where did "6" come from?

> +	i = 1;
> +	spin_lock_bh(&bdi->wb_lock);
> +	list_for_each_entry_reverse(work, &bdi->work_list, list) {
> +		if (work->inode != inode)
> +			continue;
> +		if (extend_writeback_range(work, offset, write_around_pages)) {
> +			ret = 0;
> +			break;
> +		}
> +		/*
> +		 * vmscan will slow down page reclaim when there are more than
> +		 * LOTS_OF_WRITEBACK_WORKS queued. Limit search depth to two
> +		 * times larger.
> +		 */
> +		if (i++ > 2 * LOTS_OF_WRITEBACK_WORKS)
> +			break;

I'm now totally lost.  What are the units of "i"?  (And why the heck was
it called "i" anyway?) Afaict, "i" counts the number of times we
successfully extended the writeback range by write_around_pages?  What
relationship does this have to yet-another-magic-number-times-two?

Please have a think about how to make the code comprehensible to (and
hence maintainable by) others?

> +	}
> +	spin_unlock_bh(&bdi->wb_lock);
> +
> +	if (ret) {
> +		ret = i;
> +		offset = round_down(offset, write_around_pages);
> +		work = alloc_queue_pageout_work(bdi, inode,
> +						offset, write_around_pages);
> +		if (IS_ERR(work))
> +			ret = PTR_ERR(work);
> +	}

Need a comment over this code section.  afacit it would be something
like "if we failed to add pages to an existing wb_writeback_work then
allocate and queue a new one".

> +	return ret;
> +}
> +
> +static void wb_free_work(struct wb_writeback_work *work)
> +{
> +	if (work->inode)
> +		iput(work->inode);

And here is where at least two previous attempts to perform
address_space-based writearound within direct reclaim have come
unstuck.

Occasionally, iput() does a huge amount of stuff: when it is the final
iput() on the inode.  iirc this can include taking tons of VFS locks,
truncating files, starting (and perhaps waiting upon) journal commits,
etc.  I forget, but it's a *lot*.

And quite possibly you haven't tested this at all, because it's pretty
rare for an iput() like this to be the final one.

Let me give you an example to worry about: suppose code which holds fs
locks calls into direct reclaim and then calls
mempool_alloc(wb_work_mempool) and that mempool_alloc() has to wait for
an item to be returned.  But no items will ever be returned, because
all the threads which own wb_writeback_works are stuck in
wb_free_work->iput, trying to take an fs lock which is still held by
the now-blocked direct-reclaim caller.

And a billion similar scenarios :( The really nasty thing about this is
that it is very rare for this iput() to be a final iput(), so it's hard
to get code coverage.

Please have a think about all of this and see if you can demonstrate
how the iput() here is guaranteed safe.

> +	/*
> +	 * Notify the caller of completion if this is a synchronous
> +	 * work item, otherwise just free it.
> +	 */
> +	if (work->done)
> +		complete(work->done);
> +	else
> +		mempool_free(work, wb_work_mempool);
> +}
> +
> +/*
> + * Remove works for @sb; or if (@sb == NULL), remove all works on @bdi.
> + */
> +void bdi_remove_writeback_works(struct backing_dev_info *bdi,
> +				struct super_block *sb)
> +{
> +	struct wb_writeback_work *work, *tmp;
> +	LIST_HEAD(dispose);
> +
> +	spin_lock_bh(&bdi->wb_lock);
> +	list_for_each_entry_safe(work, tmp, &bdi->work_list, list) {
> +		if (sb) {
> +			if (work->sb && work->sb != sb)
> +				continue;

What does it mean when wb_writeback_work.sb==NULL?  This reader doesn't
know, hence he can't understand (or review) this code.  Perhaps
describe it here, unless it is well described elsewhere?

> +			if (work->inode && work->inode->i_sb != sb)

And what is the meaning of wb_writeback_work.inode==NULL?

Seems odd that wb_writeback_work.sb exists, when it is accessible via
wb_writeback_work.inode->i_sb.

As a person who reviews a huge amount of code, I can tell you this: the
key to understanding code is to understand the data structures and the
relationship between their fields and between different data
structures.  Including lifetime rules, locking rules and hidden
information such as "what does it mean when wb_writeback_work.sb is
NULL".  Once one understands all this about the data structures, the
code becomes pretty obvious and bugs can be spotted and fixed.  But
alas, wb_writeback_work is basically undocumented.

> +				continue;
> +		}
> +		list_move(&work->list, &dispose);

So here we have queued for disposal a) works which refer to an inode on
sb and b) works which have ->sb==NULL and ->inode==NULL.  I don't know
whether the b) type exist.

> +	}
> +	spin_unlock_bh(&bdi->wb_lock);
> +
> +	while (!list_empty(&dispose)) {
> +		work = list_entry(dispose.next,
> +				  struct wb_writeback_work, list);
> +		list_del_init(&work->list);
> +		wb_free_work(work);
> +	}

You should be able to do this operation without writing to all the
list_heads: no list_del(), no list_del_init().

> +}
> +
> +/*
>   * Remove the inode from the writeback list it is on.
>   */
>  void inode_wb_list_del(struct inode *inode)
> @@ -833,6 +1032,21 @@ static unsigned long get_nr_dirty_pages(
>  		get_nr_dirty_inodes();
>  }
>  
> +static long wb_pageout(struct bdi_writeback *wb, struct wb_writeback_work *work)
> +{
> +	struct writeback_control wbc = {
> +		.sync_mode = WB_SYNC_NONE,
> +		.nr_to_write = LONG_MAX,
> +		.range_start = work->offset << PAGE_CACHE_SHIFT,

I think this will give you a 32->64 bit overflow on 32-bit machines.

> +		.range_end = (work->offset + work->nr_pages - 1)
> +						<< PAGE_CACHE_SHIFT,

Ditto.

Please include this in a patchset sometime ;)

--- a/include/linux/writeback.h~a
+++ a/include/linux/writeback.h
@@ -64,7 +64,7 @@ struct writeback_control {
 	long pages_skipped;		/* Pages which were not written */
 
 	/*
-	 * For a_ops->writepages(): is start or end are non-zero then this is
+	 * For a_ops->writepages(): if start or end are non-zero then this is
 	 * a hint that the filesystem need only write out the pages inside that
 	 * byterange.  The byte at `end' is included in the writeout request.
 	 */


> +	};
> +
> +	do_writepages(work->inode->i_mapping, &wbc);
> +
> +	return LONG_MAX - wbc.nr_to_write;
> +}

<infers the return semantics from the code> It took a while.  Peeking
at the caller helped.

>  static long wb_check_background_flush(struct bdi_writeback *wb)
>  {
>  	if (over_bground_thresh(wb->bdi)) {
> @@ -905,16 +1119,12 @@ long wb_do_writeback(struct bdi_writebac
>  
>  		trace_writeback_exec(bdi, work);
>  
> -		wrote += wb_writeback(wb, work);
> -
> -		/*
> -		 * Notify the caller of completion if this is a synchronous
> -		 * work item, otherwise just free it.
> -		 */
> -		if (work->done)
> -			complete(work->done);
> +		if (!work->inode)
> +			wrote += wb_writeback(wb, work);
>  		else
> -			kfree(work);
> +			wrote += wb_pageout(wb, work);
> +
> +		wb_free_work(work);
>  	}
>  
>  	/*
>
> ...
>
> --- linux.orig/include/linux/backing-dev.h	2012-02-28 19:07:06.081064464 +0800
> +++ linux/include/linux/backing-dev.h	2012-02-28 19:07:07.281064493 +0800
> @@ -126,6 +126,8 @@ int bdi_has_dirty_io(struct backing_dev_
>  void bdi_arm_supers_timer(void);
>  void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi);
>  void bdi_lock_two(struct bdi_writeback *wb1, struct bdi_writeback *wb2);
> +void bdi_remove_writeback_works(struct backing_dev_info *bdi,
> +				struct super_block *sb);
>  
>  extern spinlock_t bdi_lock;
>  extern struct list_head bdi_list;
> --- linux.orig/mm/vmscan.c	2012-02-28 19:07:06.065064464 +0800
> +++ linux/mm/vmscan.c	2012-02-28 20:26:15.559731455 +0800
> @@ -874,12 +874,22 @@ static unsigned long shrink_page_list(st
>  			nr_dirty++;
>  
>  			/*
> -			 * Only kswapd can writeback filesystem pages to
> -			 * avoid risk of stack overflow but do not writeback
> -			 * unless under significant pressure.
> +			 * Pages may be dirtied anywhere inside the LRU. This
> +			 * ensures they undergo a full period of LRU iteration
> +			 * before considering pageout. The intention is to
> +			 * delay writeout to the flusher thread, unless when
> +			 * run into a long segment of dirty pages.
> +			 */
> +			if (references == PAGEREF_RECLAIM_CLEAN &&
> +			    priority == DEF_PRIORITY)
> +				goto keep_locked;
> +
> +			/*
> +			 * Try relaying the pageout I/O to the flusher threads
> +			 * for better I/O efficiency and avoid stack overflow.
>  			 */
> -			if (page_is_file_cache(page) &&
> -					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
> +			if (page_is_file_cache(page) && mapping &&
> +			    queue_pageout_work(mapping, page) >= 0) {
>  				/*
>  				 * Immediately reclaim when written back.
>  				 * Similar in principal to deactivate_page()
> @@ -892,8 +902,13 @@ static unsigned long shrink_page_list(st
>  				goto keep_locked;
>  			}
>  
> -			if (references == PAGEREF_RECLAIM_CLEAN)
> +			/*
> +			 * Only kswapd can writeback filesystem pages to
> +			 * avoid risk of stack overflow.
> +			 */
> +			if (page_is_file_cache(page) && !current_is_kswapd())

And here we run into big problems.

When a page-allocator enters direct reclaim, that process is trying to
allocate a page from a particular zone (or set of zones).  For example,
he wants a ZONE_NORMAL or ZONE_DMA page.  Asking flusher threads to go
off and write back three gigabytes of ZONE_HIGHMEM is pointless,
inefficient and doesn't fix the caller's problem at all.

This has always been the biggest problem with the
avoid-writeback-from-direct-reclaim patches.  And your patchset (as far
as I've read) doesn't address the problem at all and appears to be
blissfully unaware of its existence.


I've attempted versions of this I think twice, and thrown the patches
away in disgust.  One approach I tried was, within direct reclaim, to
grab the page I wanted (ie: one which is in one of the caller's desired
zones) and to pass that page over to the kernel threads.  The kernel
threads would ensure that this particular page was included in the
writearound preparation.  So that we at least make *some* progress
toward what the caller is asking us to do.

iirc, the way I "grabbed" the page was to actually lock it, with
[try_]_lock_page().  And unlock it again way over within the writeback
thread.  I forget why I did it this way, rather than get_page() or
whatever.  Locking the page is a good way of preventing anyone else
from futzing with it.  It also pins the inode, which perhaps meant that
with careful management, I could avoid the igrab()/iput() horrors
discussed above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
