Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9418A6B0254
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 12:58:05 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p63so79143660wmp.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:58:05 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c2si23449671wjb.214.2016.01.29.09.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 09:58:04 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH v2 1/5] mm: memcontrol: generalize locking for the page->mem_cgroup binding
Date: Fri, 29 Jan 2016 12:54:03 -0500
Message-Id: <1454090047-1790-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1454090047-1790-1-git-send-email-hannes@cmpxchg.org>
References: <1454090047-1790-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

So far the only sites that needed to exclude charge migration to
stabilize page->mem_cgroup have been per-cgroup page statistics, hence
the name mem_cgroup_begin_page_stat(). But per-cgroup thrash detection
will add another site that needs to ensure page->mem_cgroup lifetime.

Rename these locking functions to the more generic lock_page_memcg()
and unlock_page_memcg(). Since charge migration is a cgroup1 feature
only, we might be able to delete it at some point, and these now easy
to identify locking sites along with it.

Suggested-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/buffer.c                | 14 +++++++-------
 fs/xfs/xfs_aops.c          |  8 ++++----
 include/linux/memcontrol.h | 16 +++++++++++-----
 mm/filemap.c               | 12 ++++++------
 mm/memcontrol.c            | 34 ++++++++++++++--------------------
 mm/page-writeback.c        | 28 ++++++++++++++--------------
 mm/rmap.c                  |  8 ++++----
 mm/truncate.c              |  6 +++---
 mm/vmscan.c                |  8 ++++----
 9 files changed, 67 insertions(+), 67 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index e1632ab..dc99151 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -621,7 +621,7 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  * If warn is true, then emit a warning if the page is not uptodate and has
  * not been truncated.
  *
- * The caller must hold mem_cgroup_begin_page_stat() lock.
+ * The caller must hold lock_page_memcg().
  */
 static void __set_page_dirty(struct page *page, struct address_space *mapping,
 			     struct mem_cgroup *memcg, int warn)
@@ -683,17 +683,17 @@ int __set_page_dirty_buffers(struct page *page)
 		} while (bh != head);
 	}
 	/*
-	 * Use mem_group_begin_page_stat() to keep PageDirty synchronized with
-	 * per-memcg dirty page counters.
+	 * Lock out page->mem_cgroup migration to keep PageDirty
+	 * synchronized with per-memcg dirty page counters.
 	 */
-	memcg = mem_cgroup_begin_page_stat(page);
+	memcg = lock_page_memcg(page);
 	newly_dirty = !TestSetPageDirty(page);
 	spin_unlock(&mapping->private_lock);
 
 	if (newly_dirty)
 		__set_page_dirty(page, mapping, memcg, 1);
 
-	mem_cgroup_end_page_stat(memcg);
+	unlock_page_memcg(memcg);
 
 	if (newly_dirty)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
@@ -1169,13 +1169,13 @@ void mark_buffer_dirty(struct buffer_head *bh)
 		struct address_space *mapping = NULL;
 		struct mem_cgroup *memcg;
 
-		memcg = mem_cgroup_begin_page_stat(page);
+		memcg = lock_page_memcg(page);
 		if (!TestSetPageDirty(page)) {
 			mapping = page_mapping(page);
 			if (mapping)
 				__set_page_dirty(page, mapping, memcg, 0);
 		}
-		mem_cgroup_end_page_stat(memcg);
+		unlock_page_memcg(memcg);
 		if (mapping)
 			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	}
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 379c089..28eb6f5 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1974,10 +1974,10 @@ xfs_vm_set_page_dirty(
 		} while (bh != head);
 	}
 	/*
-	 * Use mem_group_begin_page_stat() to keep PageDirty synchronized with
-	 * per-memcg dirty page counters.
+	 * Lock out page->mem_cgroup migration to keep PageDirty
+	 * synchronized with per-memcg dirty page counters.
 	 */
-	memcg = mem_cgroup_begin_page_stat(page);
+	memcg = lock_page_memcg(page);
 	newly_dirty = !TestSetPageDirty(page);
 	spin_unlock(&mapping->private_lock);
 
@@ -1994,7 +1994,7 @@ xfs_vm_set_page_dirty(
 		}
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	}
-	mem_cgroup_end_page_stat(memcg);
+	unlock_page_memcg(memcg);
 	if (newly_dirty)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	return newly_dirty;
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9ae48d4..c4347a0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -429,8 +429,8 @@ bool mem_cgroup_oom_synchronize(bool wait);
 extern int do_swap_account;
 #endif
 
-struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page);
-void mem_cgroup_end_page_stat(struct mem_cgroup *memcg);
+struct mem_cgroup *lock_page_memcg(struct page *page);
+void unlock_page_memcg(struct mem_cgroup *memcg);
 
 /**
  * mem_cgroup_update_page_stat - update page state statistics
@@ -438,7 +438,13 @@ void mem_cgroup_end_page_stat(struct mem_cgroup *memcg);
  * @idx: page state item to account
  * @val: number of pages (positive or negative)
  *
- * See mem_cgroup_begin_page_stat() for locking requirements.
+ * Callers must use lock_page_memcg() to prevent double accounting
+ * when the page is concurrently being moved to another memcg:
+ *
+ *   memcg = lock_page_memcg(page);
+ *   if (TestClearPageState(page))
+ *     mem_cgroup_update_page_stat(memcg, state, -1);
+ *   unlock_page_memcg(memcg);
  */
 static inline void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
 				 enum mem_cgroup_stat_index idx, int val)
@@ -613,12 +619,12 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
-static inline struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page)
+static inline struct mem_cgroup *lock_page_memcg(struct page *page)
 {
 	return NULL;
 }
 
-static inline void mem_cgroup_end_page_stat(struct mem_cgroup *memcg)
+static inline void unlock_page_memcg(struct mem_cgroup *memcg)
 {
 }
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 0720c9d..f812976 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -101,7 +101,7 @@
  *    ->tree_lock		(page_remove_rmap->set_page_dirty)
  *    bdi.wb->list_lock		(page_remove_rmap->set_page_dirty)
  *    ->inode->i_lock		(page_remove_rmap->set_page_dirty)
- *    ->memcg->move_lock	(page_remove_rmap->mem_cgroup_begin_page_stat)
+ *    ->memcg->move_lock	(page_remove_rmap->lock_page_memcg)
  *    bdi.wb->list_lock		(zap_pte_range->set_page_dirty)
  *    ->inode->i_lock		(zap_pte_range->set_page_dirty)
  *    ->private_lock		(zap_pte_range->__set_page_dirty_buffers)
@@ -177,7 +177,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
  * Delete a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.  The caller must hold the mapping's tree_lock and
- * mem_cgroup_begin_page_stat().
+ * lock_page_memcg().
  */
 void __delete_from_page_cache(struct page *page, void *shadow,
 			      struct mem_cgroup *memcg)
@@ -240,11 +240,11 @@ void delete_from_page_cache(struct page *page)
 
 	freepage = mapping->a_ops->freepage;
 
-	memcg = mem_cgroup_begin_page_stat(page);
+	memcg = lock_page_memcg(page);
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	__delete_from_page_cache(page, NULL, memcg);
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	mem_cgroup_end_page_stat(memcg);
+	unlock_page_memcg(memcg);
 
 	if (freepage)
 		freepage(page);
@@ -542,7 +542,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		new->mapping = mapping;
 		new->index = offset;
 
-		memcg = mem_cgroup_begin_page_stat(old);
+		memcg = lock_page_memcg(old);
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		__delete_from_page_cache(old, NULL, memcg);
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
@@ -557,7 +557,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		if (PageSwapBacked(new))
 			__inc_zone_page_state(new, NR_SHMEM);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		mem_cgroup_end_page_stat(memcg);
+		unlock_page_memcg(memcg);
 		mem_cgroup_replace_page(old, new);
 		radix_tree_preload_end();
 		if (freepage)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d06cae2..953f0f9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1709,19 +1709,13 @@ cleanup:
 }
 
 /**
- * mem_cgroup_begin_page_stat - begin a page state statistics transaction
- * @page: page that is going to change accounted state
- *
- * This function must mark the beginning of an accounted page state
- * change to prevent double accounting when the page is concurrently
- * being moved to another memcg:
+ * lock_page_memcg - lock a page->mem_cgroup binding
+ * @page: the page
  *
- *   memcg = mem_cgroup_begin_page_stat(page);
- *   if (TestClearPageState(page))
- *     mem_cgroup_update_page_stat(memcg, state, -1);
- *   mem_cgroup_end_page_stat(memcg);
+ * This function protects unlocked LRU pages from being moved to
+ * another cgroup and stabilizes their page->mem_cgroup binding.
  */
-struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page)
+struct mem_cgroup *lock_page_memcg(struct page *page)
 {
 	struct mem_cgroup *memcg;
 	unsigned long flags;
@@ -1759,20 +1753,20 @@ again:
 	/*
 	 * When charge migration first begins, we can have locked and
 	 * unlocked page stat updates happening concurrently.  Track
-	 * the task who has the lock for mem_cgroup_end_page_stat().
+	 * the task who has the lock for unlock_page_memcg().
 	 */
 	memcg->move_lock_task = current;
 	memcg->move_lock_flags = flags;
 
 	return memcg;
 }
-EXPORT_SYMBOL(mem_cgroup_begin_page_stat);
+EXPORT_SYMBOL(lock_page_memcg);
 
 /**
- * mem_cgroup_end_page_stat - finish a page state statistics transaction
- * @memcg: the memcg that was accounted against
+ * unlock_page_memcg - unlock a page->mem_cgroup binding
+ * @memcg: the memcg returned by lock_page_memcg()
  */
-void mem_cgroup_end_page_stat(struct mem_cgroup *memcg)
+void unlock_page_memcg(struct mem_cgroup *memcg)
 {
 	if (memcg && memcg->move_lock_task == current) {
 		unsigned long flags = memcg->move_lock_flags;
@@ -1785,7 +1779,7 @@ void mem_cgroup_end_page_stat(struct mem_cgroup *memcg)
 
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL(mem_cgroup_end_page_stat);
+EXPORT_SYMBOL(unlock_page_memcg);
 
 /*
  * size of first charge trial. "32" comes from vmscan.c's magic value.
@@ -4923,9 +4917,9 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
 
 	lru_add_drain_all();
 	/*
-	 * Signal mem_cgroup_begin_page_stat() to take the memcg's
-	 * move_lock while we're moving its pages to another memcg.
-	 * Then wait for already started RCU-only updates to finish.
+	 * Signal lock_page_memcg() to take the memcg's move_lock
+	 * while we're moving its pages to another memcg. Then wait
+	 * for already started RCU-only updates to finish.
 	 */
 	atomic_inc(&mc.from->moving_account);
 	synchronize_rcu();
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d782cba..2b5ea12 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2410,7 +2410,7 @@ int __set_page_dirty_no_writeback(struct page *page)
 /*
  * Helper function for set_page_dirty family.
  *
- * Caller must hold mem_cgroup_begin_page_stat().
+ * Caller must hold lock_page_memcg().
  *
  * NOTE: This relies on being atomic wrt interrupts.
  */
@@ -2442,7 +2442,7 @@ EXPORT_SYMBOL(account_page_dirtied);
 /*
  * Helper function for deaccounting dirty page without writeback.
  *
- * Caller must hold mem_cgroup_begin_page_stat().
+ * Caller must hold lock_page_memcg().
  */
 void account_page_cleaned(struct page *page, struct address_space *mapping,
 			  struct mem_cgroup *memcg, struct bdi_writeback *wb)
@@ -2471,13 +2471,13 @@ int __set_page_dirty_nobuffers(struct page *page)
 {
 	struct mem_cgroup *memcg;
 
-	memcg = mem_cgroup_begin_page_stat(page);
+	memcg = lock_page_memcg(page);
 	if (!TestSetPageDirty(page)) {
 		struct address_space *mapping = page_mapping(page);
 		unsigned long flags;
 
 		if (!mapping) {
-			mem_cgroup_end_page_stat(memcg);
+			unlock_page_memcg(memcg);
 			return 1;
 		}
 
@@ -2488,7 +2488,7 @@ int __set_page_dirty_nobuffers(struct page *page)
 		radix_tree_tag_set(&mapping->page_tree, page_index(page),
 				   PAGECACHE_TAG_DIRTY);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		mem_cgroup_end_page_stat(memcg);
+		unlock_page_memcg(memcg);
 
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
@@ -2496,7 +2496,7 @@ int __set_page_dirty_nobuffers(struct page *page)
 		}
 		return 1;
 	}
-	mem_cgroup_end_page_stat(memcg);
+	unlock_page_memcg(memcg);
 	return 0;
 }
 EXPORT_SYMBOL(__set_page_dirty_nobuffers);
@@ -2629,14 +2629,14 @@ void cancel_dirty_page(struct page *page)
 		struct mem_cgroup *memcg;
 		bool locked;
 
-		memcg = mem_cgroup_begin_page_stat(page);
+		memcg = lock_page_memcg(page);
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 
 		if (TestClearPageDirty(page))
 			account_page_cleaned(page, mapping, memcg, wb);
 
 		unlocked_inode_to_wb_end(inode, locked);
-		mem_cgroup_end_page_stat(memcg);
+		unlock_page_memcg(memcg);
 	} else {
 		ClearPageDirty(page);
 	}
@@ -2705,7 +2705,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 * always locked coming in here, so we get the desired
 		 * exclusion.
 		 */
-		memcg = mem_cgroup_begin_page_stat(page);
+		memcg = lock_page_memcg(page);
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		if (TestClearPageDirty(page)) {
 			mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
@@ -2714,7 +2714,7 @@ int clear_page_dirty_for_io(struct page *page)
 			ret = 1;
 		}
 		unlocked_inode_to_wb_end(inode, locked);
-		mem_cgroup_end_page_stat(memcg);
+		unlock_page_memcg(memcg);
 		return ret;
 	}
 	return TestClearPageDirty(page);
@@ -2727,7 +2727,7 @@ int test_clear_page_writeback(struct page *page)
 	struct mem_cgroup *memcg;
 	int ret;
 
-	memcg = mem_cgroup_begin_page_stat(page);
+	memcg = lock_page_memcg(page);
 	if (mapping) {
 		struct inode *inode = mapping->host;
 		struct backing_dev_info *bdi = inode_to_bdi(inode);
@@ -2755,7 +2755,7 @@ int test_clear_page_writeback(struct page *page)
 		dec_zone_page_state(page, NR_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITTEN);
 	}
-	mem_cgroup_end_page_stat(memcg);
+	unlock_page_memcg(memcg);
 	return ret;
 }
 
@@ -2765,7 +2765,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 	struct mem_cgroup *memcg;
 	int ret;
 
-	memcg = mem_cgroup_begin_page_stat(page);
+	memcg = lock_page_memcg(page);
 	if (mapping) {
 		struct inode *inode = mapping->host;
 		struct backing_dev_info *bdi = inode_to_bdi(inode);
@@ -2796,7 +2796,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITEBACK);
 	}
-	mem_cgroup_end_page_stat(memcg);
+	unlock_page_memcg(memcg);
 	return ret;
 
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 79f3bf0..2871e7d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1289,19 +1289,19 @@ void page_add_file_rmap(struct page *page)
 {
 	struct mem_cgroup *memcg;
 
-	memcg = mem_cgroup_begin_page_stat(page);
+	memcg = lock_page_memcg(page);
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
-	mem_cgroup_end_page_stat(memcg);
+	unlock_page_memcg(memcg);
 }
 
 static void page_remove_file_rmap(struct page *page)
 {
 	struct mem_cgroup *memcg;
 
-	memcg = mem_cgroup_begin_page_stat(page);
+	memcg = lock_page_memcg(page);
 
 	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
 	if (unlikely(PageHuge(page))) {
@@ -1325,7 +1325,7 @@ static void page_remove_file_rmap(struct page *page)
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 out:
-	mem_cgroup_end_page_stat(memcg);
+	unlock_page_memcg(memcg);
 }
 
 static void page_remove_anon_compound_rmap(struct page *page)
diff --git a/mm/truncate.c b/mm/truncate.c
index e3ee0e2..51a24f6 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -528,7 +528,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	if (page_has_private(page) && !try_to_release_page(page, GFP_KERNEL))
 		return 0;
 
-	memcg = mem_cgroup_begin_page_stat(page);
+	memcg = lock_page_memcg(page);
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	if (PageDirty(page))
 		goto failed;
@@ -536,7 +536,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	BUG_ON(page_has_private(page));
 	__delete_from_page_cache(page, NULL, memcg);
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	mem_cgroup_end_page_stat(memcg);
+	unlock_page_memcg(memcg);
 
 	if (mapping->a_ops->freepage)
 		mapping->a_ops->freepage(page);
@@ -545,7 +545,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	return 1;
 failed:
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	mem_cgroup_end_page_stat(memcg);
+	unlock_page_memcg(memcg);
 	return 0;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 30e0cd7..4577132 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -616,7 +616,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
-	memcg = mem_cgroup_begin_page_stat(page);
+	memcg = lock_page_memcg(page);
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	/*
 	 * The non racy check for a busy page.
@@ -656,7 +656,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		mem_cgroup_swapout(page, swap);
 		__delete_from_swap_cache(page);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		mem_cgroup_end_page_stat(memcg);
+		unlock_page_memcg(memcg);
 		swapcache_free(swap);
 	} else {
 		void (*freepage)(struct page *);
@@ -684,7 +684,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 			shadow = workingset_eviction(mapping, page);
 		__delete_from_page_cache(page, shadow, memcg);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		mem_cgroup_end_page_stat(memcg);
+		unlock_page_memcg(memcg);
 
 		if (freepage != NULL)
 			freepage(page);
@@ -694,7 +694,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 
 cannot_free:
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	mem_cgroup_end_page_stat(memcg);
+	unlock_page_memcg(memcg);
 	return 0;
 }
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
