Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BFC128D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 06:15:43 -0400 (EDT)
Date: Thu, 21 Apr 2011 18:15:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/6] writeback: moving expire targets for
 background/kupdate works
Message-ID: <20110421101538.GB991@localhost>
References: <20110419030003.108796967@intel.com>
 <20110421043449.GA22423@infradead.org>
 <20110421055031.GA23711@localhost>
 <20110421055634.GA26187@infradead.org>
 <20110421060738.GB24232@localhost>
 <20110421071757.GA30781@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421071757.GA30781@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Apr 21, 2011 at 03:17:57PM +0800, Christoph Hellwig wrote:
> Here's the inode_wb_list_lock splitup against current mainline:

So quick! I'll carry it and collect some numbers in my tests btw.

Thanks,
Fengguang

> ---
> From: Christoph Hellwig <hch@lst.de>
> Subject: [PATCH] writeback: split inode_wb_list_lock
> 
> Split the global inode_wb_list_lock into a per-bdi_writeback list_lock,
> as it's currently the most contended lock in the system for metadata
> heavy workloads.  I won't help for single-filesystem workloads for
> which we'll need the I/O-less balance_dirty_pages, but at least we
> can dedicate a cpu to spinning on each bdi now for larger systems.
> 
> Based on earlier patches from Nick Piggin and Dave Chinner.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Index: linux-2.6/fs/fs-writeback.c
> ===================================================================
> --- linux-2.6.orig/fs/fs-writeback.c    2011-04-21 08:31:44.512334499 +0200
> +++ linux-2.6/fs/fs-writeback.c 2011-04-21 09:07:05.327511722 +0200
> @@ -180,12 +180,13 @@ void bdi_start_background_writeback(stru
>   */
>  void inode_wb_list_del(struct inode *inode)
>  {
> -       spin_lock(&inode_wb_list_lock);
> +       struct backing_dev_info *bdi = inode_to_bdi(inode);
> +
> +       spin_lock(&bdi->wb.list_lock);
>         list_del_init(&inode->i_wb_list);
> -       spin_unlock(&inode_wb_list_lock);
> +       spin_unlock(&bdi->wb.list_lock);
>  }
> 
> -
>  /*
>   * Redirty an inode: set its when-it-was dirtied timestamp and move it to the
>   * furthest end of its superblock's dirty-inode list.
> @@ -195,11 +196,9 @@ void inode_wb_list_del(struct inode *ino
>   * the case then the inode must have been redirtied while it was being written
>   * out and we don't reset its dirtied_when.
>   */
> -static void redirty_tail(struct inode *inode)
> +static void redirty_tail(struct inode *inode, struct bdi_writeback *wb)
>  {
> -       struct bdi_writeback *wb = &inode_to_bdi(inode)->wb;
> -
> -       assert_spin_locked(&inode_wb_list_lock);
> +       assert_spin_locked(&wb->list_lock);
>         if (!list_empty(&wb->b_dirty)) {
>                 struct inode *tail;
> 
> @@ -213,11 +212,9 @@ static void redirty_tail(struct inode *i
>  /*
>   * requeue inode for re-scanning after bdi->b_io list is exhausted.
>   */
> -static void requeue_io(struct inode *inode)
> +static void requeue_io(struct inode *inode, struct bdi_writeback *wb)
>  {
> -       struct bdi_writeback *wb = &inode_to_bdi(inode)->wb;
> -
> -       assert_spin_locked(&inode_wb_list_lock);
> +       assert_spin_locked(&wb->list_lock);
>         list_move(&inode->i_wb_list, &wb->b_more_io);
>  }
> 
> @@ -225,7 +222,7 @@ static void inode_sync_complete(struct i
>  {
>         /*
>          * Prevent speculative execution through
> -        * spin_unlock(&inode_wb_list_lock);
> +        * spin_unlock(&wb->list_lock);
>          */
> 
>         smp_mb();
> @@ -301,7 +298,7 @@ static void move_expired_inodes(struct l
>   */
>  static void queue_io(struct bdi_writeback *wb, unsigned long *older_than_this)
>  {
> -       assert_spin_locked(&inode_wb_list_lock);
> +       assert_spin_locked(&wb->list_lock);
>         list_splice_init(&wb->b_more_io, &wb->b_io);
>         move_expired_inodes(&wb->b_dirty, &wb->b_io, older_than_this);
>  }
> @@ -316,7 +313,8 @@ static int write_inode(struct inode *ino
>  /*
>   * Wait for writeback on an inode to complete.
>   */
> -static void inode_wait_for_writeback(struct inode *inode)
> +static void inode_wait_for_writeback(struct inode *inode,
> +               struct bdi_writeback *wb)
>  {
>         DEFINE_WAIT_BIT(wq, &inode->i_state, __I_SYNC);
>         wait_queue_head_t *wqh;
> @@ -324,15 +322,15 @@ static void inode_wait_for_writeback(str
>         wqh = bit_waitqueue(&inode->i_state, __I_SYNC);
>         while (inode->i_state & I_SYNC) {
>                 spin_unlock(&inode->i_lock);
> -               spin_unlock(&inode_wb_list_lock);
> +               spin_unlock(&wb->list_lock);
>                 __wait_on_bit(wqh, &wq, inode_wait, TASK_UNINTERRUPTIBLE);
> -               spin_lock(&inode_wb_list_lock);
> +               spin_lock(&wb->list_lock);
>                 spin_lock(&inode->i_lock);
>         }
>  }
> 
>  /*
> - * Write out an inode's dirty pages.  Called under inode_wb_list_lock and
> + * Write out an inode's dirty pages.  Called under wb->list_lock and
>   * inode->i_lock.  Either the caller has an active reference on the inode or
>   * the inode has I_WILL_FREE set.
>   *
> @@ -343,13 +341,14 @@ static void inode_wait_for_writeback(str
>   * livelocks, etc.
>   */
>  static int
> -writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
> +writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
> +               struct writeback_control *wbc)
>  {
>         struct address_space *mapping = inode->i_mapping;
>         unsigned dirty;
>         int ret;
> 
> -       assert_spin_locked(&inode_wb_list_lock);
> +       assert_spin_locked(&wb->list_lock);
>         assert_spin_locked(&inode->i_lock);
> 
>         if (!atomic_read(&inode->i_count))
> @@ -367,14 +366,14 @@ writeback_single_inode(struct inode *ino
>                  * completed a full scan of b_io.
>                  */
>                 if (wbc->sync_mode != WB_SYNC_ALL) {
> -                       requeue_io(inode);
> +                       requeue_io(inode, wb);
>                         return 0;
>                 }
> 
>                 /*
>                  * It's a data-integrity sync.  We must wait.
>                  */
> -               inode_wait_for_writeback(inode);
> +               inode_wait_for_writeback(inode, wb);
>         }
> 
>         BUG_ON(inode->i_state & I_SYNC);
> @@ -383,7 +382,7 @@ writeback_single_inode(struct inode *ino
>         inode->i_state |= I_SYNC;
>         inode->i_state &= ~I_DIRTY_PAGES;
>         spin_unlock(&inode->i_lock);
> -       spin_unlock(&inode_wb_list_lock);
> +       spin_unlock(&wb->list_lock);
> 
>         ret = do_writepages(mapping, wbc);
> 
> @@ -414,7 +413,7 @@ writeback_single_inode(struct inode *ino
>                         ret = err;
>         }
> 
> -       spin_lock(&inode_wb_list_lock);
> +       spin_lock(&wb->list_lock);
>         spin_lock(&inode->i_lock);
>         inode->i_state &= ~I_SYNC;
>         if (!(inode->i_state & I_FREEING)) {
> @@ -428,7 +427,7 @@ writeback_single_inode(struct inode *ino
>                                 /*
>                                  * slice used up: queue for next turn
>                                  */
> -                               requeue_io(inode);
> +                               requeue_io(inode, wb);
>                         } else {
>                                 /*
>                                  * Writeback blocked by something other than
> @@ -437,7 +436,7 @@ writeback_single_inode(struct inode *ino
>                                  * retrying writeback of the dirty page/inode
>                                  * that cannot be performed immediately.
>                                  */
> -                               redirty_tail(inode);
> +                               redirty_tail(inode, wb);
>                         }
>                 } else if (inode->i_state & I_DIRTY) {
>                         /*
> @@ -446,7 +445,7 @@ writeback_single_inode(struct inode *ino
>                          * submission or metadata updates after data IO
>                          * completion.
>                          */
> -                       redirty_tail(inode);
> +                       redirty_tail(inode, wb);
>                 } else {
>                         /*
>                          * The inode is clean.  At this point we either have
> @@ -510,7 +509,7 @@ static int writeback_sb_inodes(struct su
>                                  * superblock, move all inodes not belonging
>                                  * to it back onto the dirty list.
>                                  */
> -                               redirty_tail(inode);
> +                               redirty_tail(inode, wb);
>                                 continue;
>                         }
> 
> @@ -530,7 +529,7 @@ static int writeback_sb_inodes(struct su
>                 spin_lock(&inode->i_lock);
>                 if (inode->i_state & (I_NEW | I_FREEING | I_WILL_FREE)) {
>                         spin_unlock(&inode->i_lock);
> -                       requeue_io(inode);
> +                       requeue_io(inode, wb);
>                         continue;
>                 }
> 
> @@ -546,19 +545,19 @@ static int writeback_sb_inodes(struct su
>                 __iget(inode);
> 
>                 pages_skipped = wbc->pages_skipped;
> -               writeback_single_inode(inode, wbc);
> +               writeback_single_inode(inode, wb, wbc);
>                 if (wbc->pages_skipped != pages_skipped) {
>                         /*
>                          * writeback is not making progress due to locked
>                          * buffers.  Skip this inode for now.
>                          */
> -                       redirty_tail(inode);
> +                       redirty_tail(inode, wb);
>                 }
>                 spin_unlock(&inode->i_lock);
> -               spin_unlock(&inode_wb_list_lock);
> +               spin_unlock(&wb->list_lock);
>                 iput(inode);
>                 cond_resched();
> -               spin_lock(&inode_wb_list_lock);
> +               spin_lock(&wb->list_lock);
>                 if (wbc->nr_to_write <= 0) {
>                         wbc->more_io = 1;
>                         return 1;
> @@ -577,7 +576,7 @@ void writeback_inodes_wb(struct bdi_writ
> 
>         if (!wbc->wb_start)
>                 wbc->wb_start = jiffies; /* livelock avoidance */
> -       spin_lock(&inode_wb_list_lock);
> +       spin_lock(&wb->list_lock);
>         if (!wbc->for_kupdate || list_empty(&wb->b_io))
>                 queue_io(wb, wbc->older_than_this);
> 
> @@ -586,7 +585,7 @@ void writeback_inodes_wb(struct bdi_writ
>                 struct super_block *sb = inode->i_sb;
> 
>                 if (!pin_sb_for_writeback(sb)) {
> -                       requeue_io(inode);
> +                       requeue_io(inode, wb);
>                         continue;
>                 }
>                 ret = writeback_sb_inodes(sb, wb, wbc, false);
> @@ -595,7 +594,7 @@ void writeback_inodes_wb(struct bdi_writ
>                 if (ret)
>                         break;
>         }
> -       spin_unlock(&inode_wb_list_lock);
> +       spin_unlock(&wb->list_lock);
>         /* Leave any unwritten inodes on b_io */
>  }
> 
> @@ -604,11 +603,11 @@ static void __writeback_inodes_sb(struct
>  {
>         WARN_ON(!rwsem_is_locked(&sb->s_umount));
> 
> -       spin_lock(&inode_wb_list_lock);
> +       spin_lock(&wb->list_lock);
>         if (!wbc->for_kupdate || list_empty(&wb->b_io))
>                 queue_io(wb, wbc->older_than_this);
>         writeback_sb_inodes(sb, wb, wbc, true);
> -       spin_unlock(&inode_wb_list_lock);
> +       spin_unlock(&wb->list_lock);
>  }
> 
>  /*
> @@ -747,15 +746,15 @@ static long wb_writeback(struct bdi_writ
>                  * become available for writeback. Otherwise
>                  * we'll just busyloop.
>                  */
> -               spin_lock(&inode_wb_list_lock);
> +               spin_lock(&wb->list_lock);
>                 if (!list_empty(&wb->b_more_io))  {
>                         inode = wb_inode(wb->b_more_io.prev);
>                         trace_wbc_writeback_wait(&wbc, wb->bdi);
>                         spin_lock(&inode->i_lock);
> -                       inode_wait_for_writeback(inode);
> +                       inode_wait_for_writeback(inode, wb);
>                         spin_unlock(&inode->i_lock);
>                 }
> -               spin_unlock(&inode_wb_list_lock);
> +               spin_unlock(&wb->list_lock);
>         }
> 
>         return wrote;
> @@ -1092,10 +1091,10 @@ void __mark_inode_dirty(struct inode *in
>                         }
> 
>                         spin_unlock(&inode->i_lock);
> -                       spin_lock(&inode_wb_list_lock);
> +                       spin_lock(&bdi->wb.list_lock);
>                         inode->dirtied_when = jiffies;
>                         list_move(&inode->i_wb_list, &bdi->wb.b_dirty);
> -                       spin_unlock(&inode_wb_list_lock);
> +                       spin_unlock(&bdi->wb.list_lock);
> 
>                         if (wakeup_bdi)
>                                 bdi_wakeup_thread_delayed(bdi);
> @@ -1296,6 +1295,7 @@ EXPORT_SYMBOL(sync_inodes_sb);
>   */
>  int write_inode_now(struct inode *inode, int sync)
>  {
> +       struct bdi_writeback *wb = &inode_to_bdi(inode)->wb;
>         int ret;
>         struct writeback_control wbc = {
>                 .nr_to_write = LONG_MAX,
> @@ -1308,11 +1308,11 @@ int write_inode_now(struct inode *inode,
>                 wbc.nr_to_write = 0;
> 
>         might_sleep();
> -       spin_lock(&inode_wb_list_lock);
> +       spin_lock(&wb->list_lock);
>         spin_lock(&inode->i_lock);
> -       ret = writeback_single_inode(inode, &wbc);
> +       ret = writeback_single_inode(inode, wb, &wbc);
>         spin_unlock(&inode->i_lock);
> -       spin_unlock(&inode_wb_list_lock);
> +       spin_unlock(&wb->list_lock);
>         if (sync)
>                 inode_sync_wait(inode);
>         return ret;
> @@ -1332,13 +1332,14 @@ EXPORT_SYMBOL(write_inode_now);
>   */
>  int sync_inode(struct inode *inode, struct writeback_control *wbc)
>  {
> +       struct bdi_writeback *wb = &inode_to_bdi(inode)->wb;
>         int ret;
> 
> -       spin_lock(&inode_wb_list_lock);
> +       spin_lock(&wb->list_lock);
>         spin_lock(&inode->i_lock);
> -       ret = writeback_single_inode(inode, wbc);
> +       ret = writeback_single_inode(inode, wb, wbc);
>         spin_unlock(&inode->i_lock);
> -       spin_unlock(&inode_wb_list_lock);
> +       spin_unlock(&wb->list_lock);
>         return ret;
>  }
>  EXPORT_SYMBOL(sync_inode);
> Index: linux-2.6/fs/inode.c
> ===================================================================
> --- linux-2.6.orig/fs/inode.c   2011-04-21 08:31:40.172358011 +0200
> +++ linux-2.6/fs/inode.c        2011-04-21 09:07:05.327511722 +0200
> @@ -37,7 +37,7 @@
>   *   inode_lru, inode->i_lru
>   * inode_sb_list_lock protects:
>   *   sb->s_inodes, inode->i_sb_list
> - * inode_wb_list_lock protects:
> + * bdi->wb.list_lock protects:
>   *   bdi->wb.b_{dirty,io,more_io}, inode->i_wb_list
>   * inode_hash_lock protects:
>   *   inode_hashtable, inode->i_hash
> @@ -48,7 +48,7 @@
>   *   inode->i_lock
>   *     inode_lru_lock
>   *
> - * inode_wb_list_lock
> + * bdi->wb.list_lock
>   *   inode->i_lock
>   *
>   * inode_hash_lock
> @@ -111,7 +111,6 @@ static LIST_HEAD(inode_lru);
>  static DEFINE_SPINLOCK(inode_lru_lock);
> 
>  __cacheline_aligned_in_smp DEFINE_SPINLOCK(inode_sb_list_lock);
> -__cacheline_aligned_in_smp DEFINE_SPINLOCK(inode_wb_list_lock);
> 
>  /*
>   * iprune_sem provides exclusion between the icache shrinking and the
> Index: linux-2.6/include/linux/writeback.h
> ===================================================================
> --- linux-2.6.orig/include/linux/writeback.h    2011-04-21 08:31:42.185680435 +0200
> +++ linux-2.6/include/linux/writeback.h 2011-04-21 09:07:05.327511722 +0200
> @@ -9,8 +9,6 @@
> 
>  struct backing_dev_info;
> 
> -extern spinlock_t inode_wb_list_lock;
> -
>  /*
>   * fs/fs-writeback.c
>   */
> Index: linux-2.6/mm/backing-dev.c
> ===================================================================
> --- linux-2.6.orig/mm/backing-dev.c     2011-04-21 08:31:44.532334389 +0200
> +++ linux-2.6/mm/backing-dev.c  2011-04-21 09:07:05.327511722 +0200
> @@ -45,6 +45,17 @@ static struct timer_list sync_supers_tim
>  static int bdi_sync_supers(void *);
>  static void sync_supers_timer_fn(unsigned long);
> 
> +void bdi_lock_two(struct bdi_writeback *wb1, struct bdi_writeback *wb2)
> +{
> +       if (wb1 < wb2) {
> +               spin_lock(&wb1->list_lock);
> +               spin_lock_nested(&wb2->list_lock, 1);
> +       } else {
> +               spin_lock(&wb2->list_lock);
> +               spin_lock_nested(&wb1->list_lock, 1);
> +       }
> +}
> +
>  #ifdef CONFIG_DEBUG_FS
>  #include <linux/debugfs.h>
>  #include <linux/seq_file.h>
> @@ -67,14 +78,14 @@ static int bdi_debug_stats_show(struct s
>         struct inode *inode;
> 
>         nr_wb = nr_dirty = nr_io = nr_more_io = 0;
> -       spin_lock(&inode_wb_list_lock);
> +       spin_lock(&wb->list_lock);
>         list_for_each_entry(inode, &wb->b_dirty, i_wb_list)
>                 nr_dirty++;
>         list_for_each_entry(inode, &wb->b_io, i_wb_list)
>                 nr_io++;
>         list_for_each_entry(inode, &wb->b_more_io, i_wb_list)
>                 nr_more_io++;
> -       spin_unlock(&inode_wb_list_lock);
> +       spin_unlock(&wb->list_lock);
> 
>         global_dirty_limits(&background_thresh, &dirty_thresh);
>         bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
> @@ -628,6 +639,7 @@ static void bdi_wb_init(struct bdi_write
>         INIT_LIST_HEAD(&wb->b_dirty);
>         INIT_LIST_HEAD(&wb->b_io);
>         INIT_LIST_HEAD(&wb->b_more_io);
> +       spin_lock_init(&wb->list_lock);
>         setup_timer(&wb->wakeup_timer, wakeup_timer_fn, (unsigned long)bdi);
>  }
> 
> @@ -676,11 +688,12 @@ void bdi_destroy(struct backing_dev_info
>         if (bdi_has_dirty_io(bdi)) {
>                 struct bdi_writeback *dst = &default_backing_dev_info.wb;
> 
> -               spin_lock(&inode_wb_list_lock);
> +               bdi_lock_two(&bdi->wb, dst);
>                 list_splice(&bdi->wb.b_dirty, &dst->b_dirty);
>                 list_splice(&bdi->wb.b_io, &dst->b_io);
>                 list_splice(&bdi->wb.b_more_io, &dst->b_more_io);
> -               spin_unlock(&inode_wb_list_lock);
> +               spin_unlock(&bdi->wb.list_lock);
> +               spin_unlock(&dst->list_lock);
>         }
> 
>         bdi_unregister(bdi);
> Index: linux-2.6/mm/filemap.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap.c 2011-04-21 08:31:42.159013915 +0200
> +++ linux-2.6/mm/filemap.c      2011-04-21 09:07:05.330845037 +0200
> @@ -80,7 +80,7 @@
>   *  ->i_mutex
>   *    ->i_alloc_sem             (various)
>   *
> - *  inode_wb_list_lock
> + *  bdi->wb.list_lock
>   *    sb_lock                  (fs/fs-writeback.c)
>   *    ->mapping->tree_lock     (__sync_single_inode)
>   *
> @@ -98,9 +98,9 @@
>   *    ->zone.lru_lock          (check_pte_range->isolate_lru_page)
>   *    ->private_lock           (page_remove_rmap->set_page_dirty)
>   *    ->tree_lock              (page_remove_rmap->set_page_dirty)
> - *    inode_wb_list_lock       (page_remove_rmap->set_page_dirty)
> + *    bdi.wb->list_lock                (page_remove_rmap->set_page_dirty)
>   *    ->inode->i_lock          (page_remove_rmap->set_page_dirty)
> - *    inode_wb_list_lock       (zap_pte_range->set_page_dirty)
> + *    bdi.wb->list_lock        (zap_pte_range->set_page_dirty)
>   *    ->inode->i_lock          (zap_pte_range->set_page_dirty)
>   *    ->private_lock           (zap_pte_range->__set_page_dirty_buffers)
>   *
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c    2011-04-21 08:31:41.519017382 +0200
> +++ linux-2.6/mm/rmap.c 2011-04-21 09:07:05.330845037 +0200
> @@ -32,11 +32,11 @@
>   *               mmlist_lock (in mmput, drain_mmlist and others)
>   *               mapping->private_lock (in __set_page_dirty_buffers)
>   *               inode->i_lock (in set_page_dirty's __mark_inode_dirty)
> - *               inode_wb_list_lock (in set_page_dirty's __mark_inode_dirty)
> + *               bdi.wb->list_lock (in set_page_dirty's __mark_inode_dirty)
>   *                 sb_lock (within inode_lock in fs/fs-writeback.c)
>   *                 mapping->tree_lock (widely used, in set_page_dirty,
>   *                           in arch-dependent flush_dcache_mmap_lock,
> - *                           within inode_wb_list_lock in __sync_single_inode)
> + *                           within bdi.wb->list_lock in __sync_single_inode)
>   *
>   * (code doesn't rely on that order so it could be switched around)
>   * ->tasklist_lock
> Index: linux-2.6/fs/block_dev.c
> ===================================================================
> --- linux-2.6.orig/fs/block_dev.c       2011-04-21 08:31:44.522334444 +0200
> +++ linux-2.6/fs/block_dev.c    2011-04-21 09:07:05.330845037 +0200
> @@ -55,13 +55,16 @@ EXPORT_SYMBOL(I_BDEV);
>  static void bdev_inode_switch_bdi(struct inode *inode,
>                         struct backing_dev_info *dst)
>  {
> -       spin_lock(&inode_wb_list_lock);
> +       struct backing_dev_info *old = inode->i_data.backing_dev_info;
> +
> +       bdi_lock_two(&old->wb, &dst->wb);
>         spin_lock(&inode->i_lock);
>         inode->i_data.backing_dev_info = dst;
>         if (inode->i_state & I_DIRTY)
>                 list_move(&inode->i_wb_list, &dst->wb.b_dirty);
>         spin_unlock(&inode->i_lock);
> -       spin_unlock(&inode_wb_list_lock);
> +       spin_unlock(&old->wb.list_lock);
> +       spin_unlock(&dst->wb.list_lock);
>  }
> 
>  static sector_t max_block(struct block_device *bdev)
> Index: linux-2.6/include/linux/backing-dev.h
> ===================================================================
> --- linux-2.6.orig/include/linux/backing-dev.h  2011-04-21 08:31:42.202347013 +0200
> +++ linux-2.6/include/linux/backing-dev.h       2011-04-21 09:07:05.330845037 +0200
> @@ -57,6 +57,7 @@ struct bdi_writeback {
>         struct list_head b_dirty;       /* dirty inodes */
>         struct list_head b_io;          /* parked for writeback */
>         struct list_head b_more_io;     /* parked for more writeback */
> +       spinlock_t list_lock;           /* protects the b_* lists. */
>  };
> 
>  struct backing_dev_info {
> @@ -106,6 +107,7 @@ int bdi_writeback_thread(void *data);
>  int bdi_has_dirty_io(struct backing_dev_info *bdi);
>  void bdi_arm_supers_timer(void);
>  void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi);
> +void bdi_lock_two(struct bdi_writeback *wb1, struct bdi_writeback *wb2);
> 
>  extern spinlock_t bdi_lock;
>  extern struct list_head bdi_list;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
