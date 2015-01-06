Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 08A3A6B0171
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:42 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id n4so215579qaq.6
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:41 -0800 (PST)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id l4si5814212qcm.37.2015.01.06.13.27.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:40 -0800 (PST)
Received: by mail-qg0-f45.google.com with SMTP id z107so69922qgd.18
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:40 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 39/45] writeback: make DIRTY_PAGES tracking cgroup writeback aware
Date: Tue,  6 Jan 2015 16:26:16 -0500
Message-Id: <1420579582-8516-40-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

I_DIRTY_PAGES on inode->i_state tracks whether its address_space
contains dirty pages.  When cgroup writeback is used, an address_space
can be dirtied against multiple wb's (bdi_writeback's) and we want to
be able to track dirty state per iwbl (inode_wb_link).

This patch adds IWBL_DIRTY_PAGES which tracks whether an iwbl has
dirty pages.  It's set along with I_DIRTY_PAGES when an inode gets
dirtied but because the radix tree tags can't carry which iwbl's pages
are dirtied against, whether an iwbl became clean can't be decided by
testing PAGECACHE_TAG_DIRTY.  Instead, it's opportunistically cleared
after a whole address_space writeback and when I_DIRTY_PAGES is
cleared.  This isn't ideal but the cost of inaccuracies should be
reasonable.  See the comment on top of I_DIRTY_PAGES definition for
more info.

Note that non-root iwbl's are only attributed with dirty pages, the
metadata dirtiness - I_DIRTY_SYNC and I_DIRTY_DATASYNC - are always
attributed to the root iwbl.  This means that when an inode gets
dirtied for both metadata and dirty pages from non-root cgroup, it
will dirty both the root iwbl for the metadata and the matching cgroup
iwbl for the dirty pages.

This encapsulates I_DIRTY_* manipulations and testing through new
functions - iwbl_has_enough_dirty(), iwbl_set_dirty() and
iwbl_still_has_dirty_pages() - and introduces another mb which is
paired with the one in __mark_inode_dirty_dctx() to interlock
IWBL_DIRTY_PAGES testing and clearing.  Comments for the mb's are
updated to reflect it.

write_cache_pages() is updated to use
mapping_writeback_{maybe|confirm}_whole() to clear IWBL_DIRTY_PAGES
opportunistically.  Filesystems which implement custom writepages
should be updated similarly to support cgroup writeback.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                | 186 +++++++++++++++++++++++++++++++--------
 include/linux/backing-dev-defs.h |  17 ++++
 include/linux/backing-dev.h      |  72 +++++++++++++++
 mm/page-writeback.c              |  21 ++++-
 4 files changed, 255 insertions(+), 41 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 562b75f..dbfd0b0 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -619,6 +619,71 @@ static inline void wbc_set_iwbl(struct writeback_control *wbc,
 	wbc->iwbl = iwbl;
 }
 
+/**
+ * iwbl_has_enough_dirty - does an iwbl and its inode have dirty bits already?
+ * @iwbl: inode_wb_link of interest
+ * @inode: inode @iwbl belongs to
+ * @dirty: I_DIRTY_* bits to be set
+ *
+ * @inode is being dirtied with @dirty by @iwbl's cgroup, test whether
+ * @iwbl and @inode already have all the dirty bits set.  Each iwbl has
+ * separate %IWBL_DIRTY_PAGES bit which should be also set if @dirty has
+ * %I_DIRTY_PAGES.
+ */
+static inline bool iwbl_has_enough_dirty(struct inode_wb_link *iwbl,
+					 struct inode *inode, int dirty)
+{
+	return (inode->i_state & dirty) == dirty &&
+		(!(dirty & I_DIRTY_PAGES) ||
+		 test_bit(IWBL_DIRTY_PAGES, &iwbl->data));
+}
+
+/**
+ * iwbl_set_dirty - set dirty bits on an iwbl and its inode
+ * @iwbl: ionde_wb_link of interest
+ * @inode: inode @iwbl belongs to
+ * @dirty: I_DIRTY_* bits to be set
+ *
+ * Set @dirty on @iwbl and @inode and return whether @iwbl was already
+ * dirty.  @iwbl only carries the data dirty bit through %IWBL_DIRTY_PAGES.
+ */
+static inline bool iwbl_set_dirty(struct inode_wb_link *iwbl,
+				  struct inode *inode, int dirty)
+{
+	bool was_dirty = test_bit(IWBL_DIRTY_PAGES, &iwbl->data);
+
+	/* metadata dirty bit is always attributed to the root */
+	if (iwbl_is_root(iwbl))
+		was_dirty |= inode->i_state & (I_DIRTY_SYNC | I_DIRTY_DATASYNC);
+
+	inode->i_state |= dirty;
+	if (dirty & I_DIRTY_PAGES)
+		set_bit(IWBL_DIRTY_PAGES, &iwbl->data);
+	return was_dirty;
+}
+
+/**
+ * iwbl_still_has_dirty_pages - does an iwbl have dirty pages after writeback?
+ * @iwbl: inode_wb_link of interest
+ * @inode: inode @iwbl belongs to
+ *
+ * Called from requeue_inode() after writing back @inode for @iwbl to
+ * determine whether @iwbl still has dirty pages and should thus be
+ * requeued.  This function can update IWBL_DIRTY_PAGES and may also
+ * spuriously return true.
+ *
+ * See IWBL_DIRTY_PAGES definition for more info.
+ */
+static inline bool iwbl_still_has_dirty_pages(struct inode_wb_link *iwbl,
+					      struct inode *inode)
+{
+	if (!mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
+		clear_bit(IWBL_DIRTY_PAGES, &iwbl->data);
+		return false;
+	}
+	return test_bit(IWBL_DIRTY_PAGES, &iwbl->data);
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
@@ -705,6 +770,27 @@ static inline void wbc_set_iwbl(struct writeback_control *wbc,
 {
 }
 
+static inline bool iwbl_has_enough_dirty(struct inode_wb_link *iwbl,
+					 struct inode *inode, int dirty)
+{
+	return (inode->i_state & dirty) == dirty;
+}
+
+static inline bool iwbl_set_dirty(struct inode_wb_link *iwbl,
+				  struct inode *inode, int dirty)
+{
+	bool was_dirty = inode->i_state & I_DIRTY;
+
+	inode->i_state |= dirty;
+	return was_dirty;
+}
+
+static inline bool iwbl_still_has_dirty_pages(struct inode_wb_link *iwbl,
+					      struct inode *inode)
+{
+	return mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY);
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /**
@@ -999,7 +1085,7 @@ static void requeue_inode(struct inode_wb_link *iwbl, struct bdi_writeback *wb,
 		return;
 	}
 
-	if (mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
+	if (iwbl_still_has_dirty_pages(iwbl, inode)) {
 		/*
 		 * We didn't write back all the pages.  nfs_writepages()
 		 * sometimes bales out without doing anything.
@@ -1017,7 +1103,8 @@ static void requeue_inode(struct inode_wb_link *iwbl, struct bdi_writeback *wb,
 			 */
 			redirty_tail(iwbl, wb);
 		}
-	} else if (inode->i_state & I_DIRTY) {
+	} else if (iwbl_is_root(iwbl) &&
+		   (inode->i_state & (I_DIRTY_SYNC | I_DIRTY_DATASYNC))) {
 		/*
 		 * Filesystems can dirty the inode during writeback operations,
 		 * such as delayed allocation during submission or metadata
@@ -1074,14 +1161,14 @@ __writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 	inode->i_state &= ~I_DIRTY;
 
 	/*
-	 * Paired with smp_mb() in __mark_inode_dirty().  This allows
-	 * __mark_inode_dirty() to test i_state without grabbing i_lock -
-	 * either they see the I_DIRTY bits cleared or we see the dirtied
-	 * inode.
+	 * Paired with smp_mb() in __mark_inode_dirty_dctx().  This allows
+	 * the function to perform iwbl_has_enough_dirty() test without
+	 * grabbing i_lock - either they see the dirty bits cleared or we
+	 * see the dirtied inode.
 	 *
 	 * I_DIRTY_PAGES is always cleared together above even if @mapping
 	 * still has dirty pages.  The flag is reinstated after smp_mb() if
-	 * necessary.  This guarantees that either __mark_inode_dirty()
+	 * necessary to guarantee that either __mark_inode_dirty_dctx()
 	 * sees clear I_DIRTY_PAGES or we see PAGECACHE_TAG_DIRTY.
 	 */
 	smp_mb();
@@ -1729,31 +1816,7 @@ static noinline void block_dump___mark_inode_dirty(struct inode *inode)
 	}
 }
 
-/**
- *	mark_inode_dirty_dctx -	internal function
- *	@dctx: dirty_context containing the target inode
- *	@flags: what kind of dirty (i.e. I_DIRTY_SYNC)
- *	Mark an inode as dirty. Callers should use mark_inode_dirty or
- *  	mark_inode_dirty_sync.
- *
- * Put the inode on the super block's dirty list.
- *
- * CAREFUL! We mark it dirty unconditionally, but move it onto the
- * dirty list only if it is hashed or if it refers to a blockdev.
- * If it was not hashed, it will never be added to the dirty list
- * even if it is later hashed, as it will have been marked dirty already.
- *
- * In short, make sure you hash any inodes _before_ you start marking
- * them dirty.
- *
- * Note that for blockdevs, iwbl->dirtied_when represents the dirtying time of
- * the block-special inode (/dev/hda1) itself.  And the ->dirtied_when field of
- * the kernel-internal blockdev inode represents the dirtying time of the
- * blockdev's pages.  This is why for I_DIRTY_PAGES we always use
- * page->mapping->host, so the page-dirtying time is recorded in the internal
- * blockdev inode.
- */
-void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
+static void __mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 {
 	struct inode *inode = dctx->inode;
 	struct inode_wb_link *iwbl = dctx->iwbl;
@@ -1774,22 +1837,23 @@ void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 	}
 
 	/*
-	 * Paired with smp_mb() in __writeback_single_inode() for the
-	 * following lockless i_state test.  See there for details.
+	 * Paired with smp_mb()'s in __writeback_single_inode() and
+	 * mapping_writeback_maybe_whole() for the following lockless
+	 * iwbl_has_enough_dirty() test.  See there for details.
 	 */
 	smp_mb();
 
-	if ((inode->i_state & flags) == flags)
+	if (iwbl_has_enough_dirty(iwbl, inode, flags))
 		return;
 
 	if (unlikely(block_dump))
 		block_dump___mark_inode_dirty(inode);
 
 	spin_lock(&inode->i_lock);
-	if ((inode->i_state & flags) != flags) {
-		const int was_dirty = inode->i_state & I_DIRTY;
+	if (!iwbl_has_enough_dirty(iwbl, inode, flags)) {
+		bool was_dirty;
 
-		inode->i_state |= flags;
+		was_dirty = iwbl_set_dirty(iwbl, inode, flags);
 
 		/*
 		 * If the inode is being synced, just update its dirty state.
@@ -1845,6 +1909,52 @@ out_unlock_inode:
 }
 EXPORT_SYMBOL(mark_inode_dirty_dctx);
 
+/**
+ *	mark_inode_dirty_dctx -	internal function
+ *	@dctx: dirty_context containing the target inode
+ *	@flags: what kind of dirty (i.e. I_DIRTY_SYNC)
+ *	Mark an inode as dirty. Callers should use mark_inode_dirty or
+ *  	mark_inode_dirty_sync.
+ *
+ * Put the inode on the super block's dirty list.
+ *
+ * CAREFUL! We mark it dirty unconditionally, but move it onto the
+ * dirty list only if it is hashed or if it refers to a blockdev.
+ * If it was not hashed, it will never be added to the dirty list
+ * even if it is later hashed, as it will have been marked dirty already.
+ *
+ * In short, make sure you hash any inodes _before_ you start marking
+ * them dirty.
+ *
+ * Note that for blockdevs, iwbl->dirtied_when represents the dirtying time of
+ * the block-special inode (/dev/hda1) itself.  And the ->dirtied_when field of
+ * the kernel-internal blockdev inode represents the dirtying time of the
+ * blockdev's pages.  This is why for I_DIRTY_PAGES we always use
+ * page->mapping->host, so the page-dirtying time is recorded in the internal
+ * blockdev inode.
+ */
+void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
+{
+	/*
+	 * I_DIRTY_PAGES should dirty @dctx->iwbl but I_DIRTY_[DATA]SYNC
+	 * should always dirty the root iwbl.  If @dctx->iwbl is root, we
+	 * can do both at the same time; otherwise, handle the two dirtying
+	 * separately.
+	 */
+	if (iwbl_is_root(dctx->iwbl) ||
+	    !(flags & (I_DIRTY_SYNC | I_DIRTY_DATASYNC))) {
+		__mark_inode_dirty_dctx(dctx, flags);
+		return;
+	}
+
+	if (flags & I_DIRTY_PAGES)
+		__mark_inode_dirty_dctx(dctx, I_DIRTY_PAGES);
+
+	flags &= ~I_DIRTY_PAGES;
+	if (flags)
+		__mark_inode_dirty(dctx->inode, flags);
+}
+
 void __mark_inode_dirty(struct inode *inode, int flags)
 {
 	struct dirty_context dctx;
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 6d64a0e..5e0381c 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -52,9 +52,26 @@ enum wb_stat_item {
  *
  *  Tracks whether writeback is in progress for an iwbl.  If this bit is
  *  set for any iwbl on an inode, the inode's I_SYNC is set too.
+ *
+ * IWBL_DIRTY_PAGES
+ *
+ *  Tracks whether an iwbl has dirty pages.  This bit is asserted when a
+ *  page is dirtied against it; unfortunately, unlike I_DIRTY_PAGES which
+ *  can be cleared reliably by testing PAGECACHE_TAG_DIRTY after a
+ *  writeback, there's no way to reliably determine whether an iwbl is
+ *  clean and the bit may remain set spuriously w/o dirty pages.
+ *
+ *  mapping_writeback_{maybe|confirm}_whole() are used to opportunistically
+ *  clear the bit if a writeback attempt successfully sweeps all the dirty
+ *  pages.  It also gets cleared when PAGECACHE_TAG_DIRTY test indicates
+ *  that the whole address_space is clean.  While the bit may remain set
+ *  spuriously for a while, the duration of such inaccuracy should be
+ *  reasonably limited as a periodic cyclic writeback triggered on a clean
+ *  iwbl will notice the clean state.
  */
 enum {
 	IWBL_SYNC		= 0,
+	IWBL_DIRTY_PAGES,
 
 	IWBL_FLAGS_BITS,
 	IWBL_FLAGS_MASK		= (1UL << IWBL_FLAGS_BITS) - 1,
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 57dd200..5d919bc 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -575,6 +575,66 @@ static inline pgoff_t *mapping_writeback_index(struct address_space *mapping,
 }
 
 /**
+ * mapping_writeback_maybe_whole - prepare for possible whole writeback
+ * @mapping: address_space under writeback
+ * @wbc: writeback_control in effect
+ *
+ * @mapping is being written back according to @wbc and it may write back
+ * all dirty pages.  This function must be called before such writeback is
+ * started and matched with mapping_writeback_confirm_whole() which is
+ * called after the writeback.  Combined, these two functions can detect
+ * clean condition on the associated inode_wb_link and clear
+ * %IWBL_DIRTY_PAGES on it so that its writeback work can be selectively
+ * turned off even while the inode is dirty on other cgroups.
+ *
+ * See IWBL_DIRTY_PAGES definition for more info.
+ */
+static inline void
+mapping_writeback_maybe_whole(struct address_space *mapping,
+			      struct writeback_control *wbc)
+{
+	struct inode *inode = mapping->host;
+
+	if (!inode)
+		return;
+
+	clear_bit(IWBL_DIRTY_PAGES, &inode_writeback_iwbl(inode, wbc)->data);
+
+	/*
+	 * Paired with smp_mb() in __mark_inode_dirty_dctx().  Clearing
+	 * IWBL_DIRTY_PAGES before the following mb and reinstating it
+	 * later if writeback skips over some pages guarantees that either
+	 * __mark_inode_dirty_dctx() sees clear IWBL_DIRTY_PAGES or we see
+	 * all the dirtied pages.
+	 */
+	smp_mb__after_atomic();
+}
+
+/**
+ * mapping_writeback_confirm_whole - confirm whether whole writeback took place
+ * @mapping: address_space under writeback
+ * @wbc: writeback_control in effect
+ * @wrote_whole: were all pages written out?
+ *
+ * @mapping is being written back according to @wbc and
+ * mapping_writeback_maybe_whole() was called because it could write back
+ * all dirty pages.  The writeback function must call this function to
+ * indicate whether all pages were actually written out or not.  See
+ * mapping_writeback_maybe_whole() for more info.
+ */
+static inline void
+mapping_writeback_confirm_whole(struct address_space *mapping,
+				struct writeback_control *wbc, bool wrote_whole)
+{
+	struct inode *inode = mapping->host;
+
+	if (!inode || wrote_whole)
+		return;
+
+	set_bit(IWBL_DIRTY_PAGES, &inode_writeback_iwbl(inode, wbc)->data);
+}
+
+/**
  * wbc_blkcg_css - return the blkcg_css associated with a wbc
  * @wbc: writeback_control of interest
  *
@@ -682,6 +742,18 @@ static inline pgoff_t *mapping_writeback_index(struct address_space *mapping,
 	return &mapping->writeback_index;
 }
 
+static inline void
+mapping_writeback_maybe_whole(struct address_space *mapping,
+			      struct writeback_control *wbc)
+{
+}
+
+static inline void
+mapping_writeback_confirm_whole(struct address_space *mapping,
+				struct writeback_control *wbc, bool wrote_whole)
+{
+}
+
 static inline struct cgroup_subsys_state *
 wbc_blkcg_css(struct writeback_control *wbc)
 {
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 753d76f..dd15bb3 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1904,6 +1904,7 @@ int write_cache_pages(struct address_space *mapping,
 {
 	int ret = 0;
 	int done = 0;
+	int skipped_dirty = 0;
 	struct pagevec pvec;
 	int nr_pages;
 	pgoff_t *writeback_index_ptr = mapping_writeback_index(mapping, wbc);
@@ -1913,6 +1914,7 @@ int write_cache_pages(struct address_space *mapping,
 	pgoff_t done_index;
 	int cycled;
 	int range_whole = 0;
+	int maybe_whole = 0;
 	int tag;
 
 	pagevec_init(&pvec, 0);
@@ -1924,13 +1926,20 @@ int write_cache_pages(struct address_space *mapping,
 		else
 			cycled = 0;
 		end = -1;
+		maybe_whole = 1;
 	} else {
 		index = wbc->range_start >> PAGE_CACHE_SHIFT;
 		end = wbc->range_end >> PAGE_CACHE_SHIFT;
-		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
+		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX) {
 			range_whole = 1;
+			maybe_whole = 1;
+		}
 		cycled = 1; /* ignore range_cyclic tests */
 	}
+
+	if (maybe_whole)
+		mapping_writeback_maybe_whole(mapping, wbc);
+
 	if (wbc->sync_mode == WB_SYNC_ALL || wbc->tagged_writepages)
 		tag = PAGECACHE_TAG_TOWRITE;
 	else
@@ -1990,10 +1999,12 @@ continue_unlock:
 			}
 
 			if (PageWriteback(page)) {
-				if (wbc->sync_mode != WB_SYNC_NONE)
+				if (wbc->sync_mode != WB_SYNC_NONE) {
 					wait_on_page_writeback(page);
-				else
+				} else {
+					skipped_dirty = 1;
 					goto continue_unlock;
+				}
 			}
 
 			BUG_ON(PageWriteback(page));
@@ -2004,6 +2015,7 @@ continue_unlock:
 			ret = (*writepage)(page, wbc, data);
 			if (unlikely(ret)) {
 				if (ret == AOP_WRITEPAGE_ACTIVATE) {
+					skipped_dirty = 1;
 					unlock_page(page);
 					ret = 0;
 				} else {
@@ -2051,6 +2063,9 @@ continue_unlock:
 	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))
 		*writeback_index_ptr = done_index;
 
+	if (maybe_whole)
+		mapping_writeback_confirm_whole(mapping, wbc,
+						!done && !skipped_dirty);
 	return ret;
 }
 EXPORT_SYMBOL(write_cache_pages);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
