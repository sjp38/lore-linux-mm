Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7C74A6B0255
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 18:20:30 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l66so1750042wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 15:20:30 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id vt3si24893982wjc.145.2016.01.29.15.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 15:20:29 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/3] mm: simplify lock_page_memcg()
Date: Fri, 29 Jan 2016 18:19:32 -0500
Message-Id: <1454109573-29235-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org>
References: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Now that migration doesn't clear page->mem_cgroup of live pages
anymore, it's safe to make lock_page_memcg() and the memcg stat
functions take pages, and spare the callers from memcg objects.

Suggested-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/buffer.c                | 18 ++++++++---------
 fs/xfs/xfs_aops.c          |  7 +++----
 include/linux/memcontrol.h | 34 ++++++++++++++++----------------
 include/linux/mm.h         |  5 ++---
 include/linux/pagemap.h    |  3 +--
 mm/filemap.c               | 20 ++++++++-----------
 mm/memcontrol.c            | 23 +++++++++-------------
 mm/page-writeback.c        | 49 ++++++++++++++++++++--------------------------
 mm/rmap.c                  | 16 ++++++---------
 mm/truncate.c              |  9 ++++-----
 mm/vmscan.c                | 11 +++++------
 mm/workingset.c            |  9 ++++-----
 12 files changed, 88 insertions(+), 116 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index dc991510bb06..33be29675358 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -624,14 +624,14 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  * The caller must hold lock_page_memcg().
  */
 static void __set_page_dirty(struct page *page, struct address_space *mapping,
-			     struct mem_cgroup *memcg, int warn)
+			     int warn)
 {
 	unsigned long flags;
 
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
-		account_page_dirtied(page, mapping, memcg);
+		account_page_dirtied(page, mapping);
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
@@ -666,7 +666,6 @@ static void __set_page_dirty(struct page *page, struct address_space *mapping,
 int __set_page_dirty_buffers(struct page *page)
 {
 	int newly_dirty;
-	struct mem_cgroup *memcg;
 	struct address_space *mapping = page_mapping(page);
 
 	if (unlikely(!mapping))
@@ -686,14 +685,14 @@ int __set_page_dirty_buffers(struct page *page)
 	 * Lock out page->mem_cgroup migration to keep PageDirty
 	 * synchronized with per-memcg dirty page counters.
 	 */
-	memcg = lock_page_memcg(page);
+	lock_page_memcg(page);
 	newly_dirty = !TestSetPageDirty(page);
 	spin_unlock(&mapping->private_lock);
 
 	if (newly_dirty)
-		__set_page_dirty(page, mapping, memcg, 1);
+		__set_page_dirty(page, mapping, 1);
 
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 
 	if (newly_dirty)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
@@ -1167,15 +1166,14 @@ void mark_buffer_dirty(struct buffer_head *bh)
 	if (!test_set_buffer_dirty(bh)) {
 		struct page *page = bh->b_page;
 		struct address_space *mapping = NULL;
-		struct mem_cgroup *memcg;
 
-		memcg = lock_page_memcg(page);
+		lock_page_memcg(page);
 		if (!TestSetPageDirty(page)) {
 			mapping = page_mapping(page);
 			if (mapping)
-				__set_page_dirty(page, mapping, memcg, 0);
+				__set_page_dirty(page, mapping, 0);
 		}
-		unlock_page_memcg(memcg);
+		unlock_page_memcg(page);
 		if (mapping)
 			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	}
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 28eb6f535ca9..f73d009143e2 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1953,7 +1953,6 @@ xfs_vm_set_page_dirty(
 	loff_t			end_offset;
 	loff_t			offset;
 	int			newly_dirty;
-	struct mem_cgroup	*memcg;
 
 	if (unlikely(!mapping))
 		return !TestSetPageDirty(page);
@@ -1977,7 +1976,7 @@ xfs_vm_set_page_dirty(
 	 * Lock out page->mem_cgroup migration to keep PageDirty
 	 * synchronized with per-memcg dirty page counters.
 	 */
-	memcg = lock_page_memcg(page);
+	lock_page_memcg(page);
 	newly_dirty = !TestSetPageDirty(page);
 	spin_unlock(&mapping->private_lock);
 
@@ -1988,13 +1987,13 @@ xfs_vm_set_page_dirty(
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		if (page->mapping) {	/* Race with truncate? */
 			WARN_ON_ONCE(!PageUptodate(page));
-			account_page_dirtied(page, mapping, memcg);
+			account_page_dirtied(page, mapping);
 			radix_tree_tag_set(&mapping->page_tree,
 					page_index(page), PAGECACHE_TAG_DIRTY);
 		}
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	}
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 	if (newly_dirty)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	return newly_dirty;
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b246e1b1fd4b..c355efff8148 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -455,42 +455,42 @@ bool mem_cgroup_oom_synchronize(bool wait);
 extern int do_swap_account;
 #endif
 
-struct mem_cgroup *lock_page_memcg(struct page *page);
-void unlock_page_memcg(struct mem_cgroup *memcg);
+void lock_page_memcg(struct page *page);
+void unlock_page_memcg(struct page *page);
 
 /**
  * mem_cgroup_update_page_stat - update page state statistics
- * @memcg: memcg to account against
+ * @page: the page
  * @idx: page state item to account
  * @val: number of pages (positive or negative)
  *
  * Callers must use lock_page_memcg() to prevent double accounting
  * when the page is concurrently being moved to another memcg:
  *
- *   memcg = lock_page_memcg(page);
+ *   lock_page_memcg(page);
  *   if (TestClearPageState(page))
- *     mem_cgroup_update_page_stat(memcg, state, -1);
- *   unlock_page_memcg(memcg);
+ *     mem_cgroup_update_page_stat(page, state, -1);
+ *   unlock_page_memcg(page);
  */
-static inline void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
+static inline void mem_cgroup_update_page_stat(struct page *page,
 				 enum mem_cgroup_stat_index idx, int val)
 {
 	VM_BUG_ON(!rcu_read_lock_held());
 
-	if (memcg)
-		this_cpu_add(memcg->stat->count[idx], val);
+	if (page->mem_cgroup)
+		this_cpu_add(page->mem_cgroup->stat->count[idx], val);
 }
 
-static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
+static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_stat_index idx)
 {
-	mem_cgroup_update_page_stat(memcg, idx, 1);
+	mem_cgroup_update_page_stat(page, idx, 1);
 }
 
-static inline void mem_cgroup_dec_page_stat(struct mem_cgroup *memcg,
+static inline void mem_cgroup_dec_page_stat(struct page *page,
 					    enum mem_cgroup_stat_index idx)
 {
-	mem_cgroup_update_page_stat(memcg, idx, -1);
+	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
@@ -661,12 +661,12 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
-static inline struct mem_cgroup *lock_page_memcg(struct page *page)
+static inline void lock_page_memcg(struct page *page)
 {
 	return NULL;
 }
 
-static inline void unlock_page_memcg(struct mem_cgroup *memcg)
+static inline void unlock_page_memcg(struct page *page)
 {
 }
 
@@ -692,12 +692,12 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
 	return false;
 }
 
-static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
+static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_stat_index idx)
 {
 }
 
-static inline void mem_cgroup_dec_page_stat(struct mem_cgroup *memcg,
+static inline void mem_cgroup_dec_page_stat(struct page *page,
 					    enum mem_cgroup_stat_index idx)
 {
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d11955f2d69c..05a51c0fe872 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1290,10 +1290,9 @@ int __set_page_dirty_nobuffers(struct page *page);
 int __set_page_dirty_no_writeback(struct page *page);
 int redirty_page_for_writepage(struct writeback_control *wbc,
 				struct page *page);
-void account_page_dirtied(struct page *page, struct address_space *mapping,
-			  struct mem_cgroup *memcg);
+void account_page_dirtied(struct page *page, struct address_space *mapping);
 void account_page_cleaned(struct page *page, struct address_space *mapping,
-			  struct mem_cgroup *memcg, struct bdi_writeback *wb);
+			  struct bdi_writeback *wb);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 void cancel_dirty_page(struct page *page);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 92395a0a7dc5..183b15ea052b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -663,8 +663,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 extern void delete_from_page_cache(struct page *page);
-extern void __delete_from_page_cache(struct page *page, void *shadow,
-				     struct mem_cgroup *memcg);
+extern void __delete_from_page_cache(struct page *page, void *shadow);
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index 37d0ecb94061..b9b1cb2ce40b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -179,8 +179,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
  * is safe.  The caller must hold the mapping's tree_lock and
  * lock_page_memcg().
  */
-void __delete_from_page_cache(struct page *page, void *shadow,
-			      struct mem_cgroup *memcg)
+void __delete_from_page_cache(struct page *page, void *shadow)
 {
 	struct address_space *mapping = page->mapping;
 
@@ -216,8 +215,7 @@ void __delete_from_page_cache(struct page *page, void *shadow,
 	 * anyway will be cleared before returning page into buddy allocator.
 	 */
 	if (WARN_ON_ONCE(PageDirty(page)))
-		account_page_cleaned(page, mapping, memcg,
-				     inode_to_wb(mapping->host));
+		account_page_cleaned(page, mapping, inode_to_wb(mapping->host));
 }
 
 /**
@@ -231,7 +229,6 @@ void __delete_from_page_cache(struct page *page, void *shadow,
 void delete_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
-	struct mem_cgroup *memcg;
 	unsigned long flags;
 
 	void (*freepage)(struct page *);
@@ -240,11 +237,11 @@ void delete_from_page_cache(struct page *page)
 
 	freepage = mapping->a_ops->freepage;
 
-	memcg = lock_page_memcg(page);
+	lock_page_memcg(page);
 	spin_lock_irqsave(&mapping->tree_lock, flags);
-	__delete_from_page_cache(page, NULL, memcg);
+	__delete_from_page_cache(page, NULL);
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 
 	if (freepage)
 		freepage(page);
@@ -532,7 +529,6 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 	if (!error) {
 		struct address_space *mapping = old->mapping;
 		void (*freepage)(struct page *);
-		struct mem_cgroup *memcg;
 		unsigned long flags;
 
 		pgoff_t offset = old->index;
@@ -542,9 +538,9 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		new->mapping = mapping;
 		new->index = offset;
 
-		memcg = lock_page_memcg(old);
+		lock_page_memcg(old);
 		spin_lock_irqsave(&mapping->tree_lock, flags);
-		__delete_from_page_cache(old, NULL, memcg);
+		__delete_from_page_cache(old, NULL);
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
 		BUG_ON(error);
 		mapping->nrpages++;
@@ -557,7 +553,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		if (PageSwapBacked(new))
 			__inc_zone_page_state(new, NR_SHMEM);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		unlock_page_memcg(memcg);
+		unlock_page_memcg(old);
 		mem_cgroup_migrate(old, new);
 		radix_tree_preload_end();
 		if (freepage)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 64506b2eef34..3e4199830456 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1690,7 +1690,7 @@ cleanup:
  * This function protects unlocked LRU pages from being moved to
  * another cgroup and stabilizes their page->mem_cgroup binding.
  */
-struct mem_cgroup *lock_page_memcg(struct page *page)
+void lock_page_memcg(struct page *page)
 {
 	struct mem_cgroup *memcg;
 	unsigned long flags;
@@ -1699,25 +1699,18 @@ struct mem_cgroup *lock_page_memcg(struct page *page)
 	 * The RCU lock is held throughout the transaction.  The fast
 	 * path can get away without acquiring the memcg->move_lock
 	 * because page moving starts with an RCU grace period.
-	 *
-	 * The RCU lock also protects the memcg from being freed when
-	 * the page state that is going to change is the only thing
-	 * preventing the page from being uncharged.
-	 * E.g. end-writeback clearing PageWriteback(), which allows
-	 * migration to go ahead and uncharge the page before the
-	 * account transaction might be complete.
 	 */
 	rcu_read_lock();
 
 	if (mem_cgroup_disabled())
-		return NULL;
+		return;
 again:
 	memcg = page->mem_cgroup;
 	if (unlikely(!memcg))
-		return NULL;
+		return;
 
 	if (atomic_read(&memcg->moving_account) <= 0)
-		return memcg;
+		return;
 
 	spin_lock_irqsave(&memcg->move_lock, flags);
 	if (memcg != page->mem_cgroup) {
@@ -1733,16 +1726,18 @@ again:
 	memcg->move_lock_task = current;
 	memcg->move_lock_flags = flags;
 
-	return memcg;
+	return;
 }
 EXPORT_SYMBOL(lock_page_memcg);
 
 /**
  * unlock_page_memcg - unlock a page->mem_cgroup binding
- * @memcg: the memcg returned by lock_page_memcg()
+ * @page: the page
  */
-void unlock_page_memcg(struct mem_cgroup *memcg)
+void unlock_page_memcg(struct page *page)
 {
+	struct mem_cgroup *memcg = page->mem_cgroup;
+
 	if (memcg && memcg->move_lock_task == current) {
 		unsigned long flags = memcg->move_lock_flags;
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2b5ea1271e32..d7cf2c53d125 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2414,8 +2414,7 @@ int __set_page_dirty_no_writeback(struct page *page)
  *
  * NOTE: This relies on being atomic wrt interrupts.
  */
-void account_page_dirtied(struct page *page, struct address_space *mapping,
-			  struct mem_cgroup *memcg)
+void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	struct inode *inode = mapping->host;
 
@@ -2427,7 +2426,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping,
 		inode_attach_wb(inode, page);
 		wb = inode_to_wb(inode);
 
-		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
+		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
@@ -2445,10 +2444,10 @@ EXPORT_SYMBOL(account_page_dirtied);
  * Caller must hold lock_page_memcg().
  */
 void account_page_cleaned(struct page *page, struct address_space *mapping,
-			  struct mem_cgroup *memcg, struct bdi_writeback *wb)
+			  struct bdi_writeback *wb)
 {
 	if (mapping_cap_account_dirty(mapping)) {
-		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
+		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_wb_stat(wb, WB_RECLAIMABLE);
 		task_io_account_cancelled_write(PAGE_CACHE_SIZE);
@@ -2469,26 +2468,24 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
-	struct mem_cgroup *memcg;
-
-	memcg = lock_page_memcg(page);
+	lock_page_memcg(page);
 	if (!TestSetPageDirty(page)) {
 		struct address_space *mapping = page_mapping(page);
 		unsigned long flags;
 
 		if (!mapping) {
-			unlock_page_memcg(memcg);
+			unlock_page_memcg(page);
 			return 1;
 		}
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		BUG_ON(page_mapping(page) != mapping);
 		WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
-		account_page_dirtied(page, mapping, memcg);
+		account_page_dirtied(page, mapping);
 		radix_tree_tag_set(&mapping->page_tree, page_index(page),
 				   PAGECACHE_TAG_DIRTY);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		unlock_page_memcg(memcg);
+		unlock_page_memcg(page);
 
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
@@ -2496,7 +2493,7 @@ int __set_page_dirty_nobuffers(struct page *page)
 		}
 		return 1;
 	}
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 	return 0;
 }
 EXPORT_SYMBOL(__set_page_dirty_nobuffers);
@@ -2626,17 +2623,16 @@ void cancel_dirty_page(struct page *page)
 	if (mapping_cap_account_dirty(mapping)) {
 		struct inode *inode = mapping->host;
 		struct bdi_writeback *wb;
-		struct mem_cgroup *memcg;
 		bool locked;
 
-		memcg = lock_page_memcg(page);
+		lock_page_memcg(page);
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 
 		if (TestClearPageDirty(page))
-			account_page_cleaned(page, mapping, memcg, wb);
+			account_page_cleaned(page, mapping, wb);
 
 		unlocked_inode_to_wb_end(inode, locked);
-		unlock_page_memcg(memcg);
+		unlock_page_memcg(page);
 	} else {
 		ClearPageDirty(page);
 	}
@@ -2667,7 +2663,6 @@ int clear_page_dirty_for_io(struct page *page)
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		struct inode *inode = mapping->host;
 		struct bdi_writeback *wb;
-		struct mem_cgroup *memcg;
 		bool locked;
 
 		/*
@@ -2705,16 +2700,16 @@ int clear_page_dirty_for_io(struct page *page)
 		 * always locked coming in here, so we get the desired
 		 * exclusion.
 		 */
-		memcg = lock_page_memcg(page);
+		lock_page_memcg(page);
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		if (TestClearPageDirty(page)) {
-			mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
+			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_wb_stat(wb, WB_RECLAIMABLE);
 			ret = 1;
 		}
 		unlocked_inode_to_wb_end(inode, locked);
-		unlock_page_memcg(memcg);
+		unlock_page_memcg(page);
 		return ret;
 	}
 	return TestClearPageDirty(page);
@@ -2724,10 +2719,9 @@ EXPORT_SYMBOL(clear_page_dirty_for_io);
 int test_clear_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
-	struct mem_cgroup *memcg;
 	int ret;
 
-	memcg = lock_page_memcg(page);
+	lock_page_memcg(page);
 	if (mapping) {
 		struct inode *inode = mapping->host;
 		struct backing_dev_info *bdi = inode_to_bdi(inode);
@@ -2751,21 +2745,20 @@ int test_clear_page_writeback(struct page *page)
 		ret = TestClearPageWriteback(page);
 	}
 	if (ret) {
-		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
+		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
 		dec_zone_page_state(page, NR_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITTEN);
 	}
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 	return ret;
 }
 
 int __test_set_page_writeback(struct page *page, bool keep_write)
 {
 	struct address_space *mapping = page_mapping(page);
-	struct mem_cgroup *memcg;
 	int ret;
 
-	memcg = lock_page_memcg(page);
+	lock_page_memcg(page);
 	if (mapping) {
 		struct inode *inode = mapping->host;
 		struct backing_dev_info *bdi = inode_to_bdi(inode);
@@ -2793,10 +2786,10 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 		ret = TestSetPageWriteback(page);
 	}
 	if (!ret) {
-		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
+		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITEBACK);
 	}
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 	return ret;
 
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 2871e7d3cced..02f0bfc3c80a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1287,21 +1287,17 @@ void page_add_new_anon_rmap(struct page *page,
  */
 void page_add_file_rmap(struct page *page)
 {
-	struct mem_cgroup *memcg;
-
-	memcg = lock_page_memcg(page);
+	lock_page_memcg(page);
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
+		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 }
 
 static void page_remove_file_rmap(struct page *page)
 {
-	struct mem_cgroup *memcg;
-
-	memcg = lock_page_memcg(page);
+	lock_page_memcg(page);
 
 	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
 	if (unlikely(PageHuge(page))) {
@@ -1320,12 +1316,12 @@ static void page_remove_file_rmap(struct page *page)
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
 	__dec_zone_page_state(page, NR_FILE_MAPPED);
-	mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
+	mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 out:
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 }
 
 static void page_remove_anon_compound_rmap(struct page *page)
diff --git a/mm/truncate.c b/mm/truncate.c
index 51a24f6a555d..87311af936f2 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -519,7 +519,6 @@ EXPORT_SYMBOL(invalidate_mapping_pages);
 static int
 invalidate_complete_page2(struct address_space *mapping, struct page *page)
 {
-	struct mem_cgroup *memcg;
 	unsigned long flags;
 
 	if (page->mapping != mapping)
@@ -528,15 +527,15 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	if (page_has_private(page) && !try_to_release_page(page, GFP_KERNEL))
 		return 0;
 
-	memcg = lock_page_memcg(page);
+	lock_page_memcg(page);
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	if (PageDirty(page))
 		goto failed;
 
 	BUG_ON(page_has_private(page));
-	__delete_from_page_cache(page, NULL, memcg);
+	__delete_from_page_cache(page, NULL);
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 
 	if (mapping->a_ops->freepage)
 		mapping->a_ops->freepage(page);
@@ -545,7 +544,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	return 1;
 failed:
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 	return 0;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9342a0fe8836..28e518d3c700 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -611,12 +611,11 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 			    bool reclaimed)
 {
 	unsigned long flags;
-	struct mem_cgroup *memcg;
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
-	memcg = lock_page_memcg(page);
+	lock_page_memcg(page);
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	/*
 	 * The non racy check for a busy page.
@@ -656,7 +655,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		mem_cgroup_swapout(page, swap);
 		__delete_from_swap_cache(page);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		unlock_page_memcg(memcg);
+		unlock_page_memcg(page);
 		swapcache_free(swap);
 	} else {
 		void (*freepage)(struct page *);
@@ -682,9 +681,9 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		if (reclaimed && page_is_file_cache(page) &&
 		    !mapping_exiting(mapping) && !dax_mapping(mapping))
 			shadow = workingset_eviction(mapping, page);
-		__delete_from_page_cache(page, shadow, memcg);
+		__delete_from_page_cache(page, shadow);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		unlock_page_memcg(memcg);
+		unlock_page_memcg(page);
 
 		if (freepage != NULL)
 			freepage(page);
@@ -694,7 +693,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 
 cannot_free:
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 	return 0;
 }
 
diff --git a/mm/workingset.c b/mm/workingset.c
index 3ced3a2f8383..14522ed04869 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -305,10 +305,9 @@ bool workingset_refault(void *shadow)
  */
 void workingset_activation(struct page *page)
 {
-	struct mem_cgroup *memcg;
 	struct lruvec *lruvec;
 
-	memcg = lock_page_memcg(page);
+	lock_page_memcg(page);
 	/*
 	 * Filter non-memcg pages here, e.g. unmap can call
 	 * mark_page_accessed() on VDSO pages.
@@ -316,11 +315,11 @@ void workingset_activation(struct page *page)
 	 * XXX: See workingset_refault() - this should return
 	 * root_mem_cgroup even for !CONFIG_MEMCG.
 	 */
-	if (!mem_cgroup_disabled() && !memcg)
+	if (!mem_cgroup_disabled() && !page_memcg(page))
 		return;
-	lruvec = mem_cgroup_zone_lruvec(page_zone(page), memcg);
+	lruvec = mem_cgroup_zone_lruvec(page_zone(page), page_memcg(page));
 	atomic_long_inc(&lruvec->inactive_age);
-	unlock_page_memcg(memcg);
+	unlock_page_memcg(page);
 }
 
 /*
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
