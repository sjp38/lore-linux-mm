Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 57FF96B0070
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 16:21:52 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id s18so1780688lam.37
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 13:21:51 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u2si20639190lal.70.2014.10.21.13.21.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 13:21:50 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/4] mm: memcontrol: simplify per-memcg page statistics accounting
Date: Tue, 21 Oct 2014 16:21:36 -0400
Message-Id: <1413922896-29042-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1413922896-29042-1-git-send-email-hannes@cmpxchg.org>
References: <1413922896-29042-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The per-page statistics interface is heavily optimized to avoid a
function call and a lookup_page_cgroup() in the file unmap fast path,
but this results in fairly convoluted and repetitive code.

Rework it so that it looks up the page's memcg once at the beginning
of the transaction and then uses it throughout, which makes things a
lot more readable.

The following test results are from a microbenchmark that maps,
faults, and unmaps a 4GB sparse file three times in a nested fashion,
so that there are two negative passes that don't account but still go
through the new transaction overhead.  There is no actual difference:

old:     33.195102545 seconds time elapsed       ( +-  0.01% )
new:     33.199231369 seconds time elapsed       ( +-  0.03% )

The time spent in page_remove_rmap()'s callees still adds up to the
same, but the time spent in the function itself seems reduced:

    # Children      Self  Command        Shared Object       Symbol
old:     0.12%     0.11%  filemapstress  [kernel.kallsyms]   [k] page_remove_rmap
new:     0.12%     0.08%  filemapstress  [kernel.kallsyms]   [k] page_remove_rmap

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 57 +++++++++++++---------------------------------
 mm/memcontrol.c            | 52 +++++++++++++++++-------------------------
 mm/page-writeback.c        | 22 ++++++++++--------
 mm/rmap.c                  | 20 ++++++++--------
 4 files changed, 59 insertions(+), 92 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0daf383f8f1c..4dc4a2aec440 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -139,48 +139,23 @@ static inline bool mem_cgroup_disabled(void)
 	return false;
 }
 
-void __mem_cgroup_begin_update_page_stat(struct page *page, bool *locked,
-					 unsigned long *flags);
-
-extern atomic_t memcg_moving;
-
-static inline void mem_cgroup_begin_update_page_stat(struct page *page,
-					bool *locked, unsigned long *flags)
-{
-	if (mem_cgroup_disabled())
-		return;
-	rcu_read_lock();
-	*locked = false;
-	if (atomic_read(&memcg_moving))
-		__mem_cgroup_begin_update_page_stat(page, locked, flags);
-}
-
-void __mem_cgroup_end_update_page_stat(struct page *page,
-				unsigned long *flags);
-static inline void mem_cgroup_end_update_page_stat(struct page *page,
-					bool *locked, unsigned long *flags)
-{
-	if (mem_cgroup_disabled())
-		return;
-	if (*locked)
-		__mem_cgroup_end_update_page_stat(page, flags);
-	rcu_read_unlock();
-}
-
-void mem_cgroup_update_page_stat(struct page *page,
-				 enum mem_cgroup_stat_index idx,
-				 int val);
-
-static inline void mem_cgroup_inc_page_stat(struct page *page,
+struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page, bool *locked,
+					      unsigned long *flags);
+void mem_cgroup_end_page_stat(struct mem_cgroup *memcg, bool locked,
+			      unsigned long flags);
+void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
+				 enum mem_cgroup_stat_index idx, int val);
+
+static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
 					    enum mem_cgroup_stat_index idx)
 {
-	mem_cgroup_update_page_stat(page, idx, 1);
+	mem_cgroup_update_page_stat(memcg, idx, 1);
 }
 
-static inline void mem_cgroup_dec_page_stat(struct page *page,
+static inline void mem_cgroup_dec_page_stat(struct mem_cgroup *memcg,
 					    enum mem_cgroup_stat_index idx)
 {
-	mem_cgroup_update_page_stat(page, idx, -1);
+	mem_cgroup_update_page_stat(memcg, idx, -1);
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
@@ -315,13 +290,13 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
-static inline void mem_cgroup_begin_update_page_stat(struct page *page,
+static inline void mem_cgroup_begin_page_stat(struct page *page,
 					bool *locked, unsigned long *flags)
 {
 }
 
-static inline void mem_cgroup_end_update_page_stat(struct page *page,
-					bool *locked, unsigned long *flags)
+static inline void mem_cgroup_end_page_stat(struct mem_cgroup *memcg,
+					bool locked, unsigned long flags)
 {
 }
 
@@ -343,12 +318,12 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
 	return false;
 }
 
-static inline void mem_cgroup_inc_page_stat(struct page *page,
+static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
 					    enum mem_cgroup_stat_index idx)
 {
 }
 
-static inline void mem_cgroup_dec_page_stat(struct page *page,
+static inline void mem_cgroup_dec_page_stat(struct mem_cgroup *memcg,
 					    enum mem_cgroup_stat_index idx)
 {
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c1fe774d712a..36ab98d6659e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1440,19 +1440,14 @@ int mem_cgroup_swappiness(struct mem_cgroup *memcg)
  *         start move here.
  */
 
-/* for quick checking without looking up memcg */
-atomic_t memcg_moving __read_mostly;
-
 static void mem_cgroup_start_move(struct mem_cgroup *memcg)
 {
-	atomic_inc(&memcg_moving);
 	atomic_inc(&memcg->moving_account);
 	synchronize_rcu();
 }
 
 static void mem_cgroup_end_move(struct mem_cgroup *memcg)
 {
-	atomic_dec(&memcg_moving);
 	atomic_dec(&memcg->moving_account);
 }
 
@@ -1977,26 +1972,32 @@ cleanup:
  * account and taking the move_lock in the slowpath.
  */
 
-void __mem_cgroup_begin_update_page_stat(struct page *page,
-				bool *locked, unsigned long *flags)
+struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page,
+					      bool *locked,
+					      unsigned long *flags)
 {
 	struct mem_cgroup *memcg;
 	struct page_cgroup *pc;
 
+	rcu_read_lock();
+
+	if (mem_cgroup_disabled())
+		return NULL;
+
 	pc = lookup_page_cgroup(page);
 again:
 	memcg = pc->mem_cgroup;
 	if (unlikely(!memcg))
-		return;
+		return NULL;
 	/*
 	 * If this memory cgroup is not under account moving, we don't
 	 * need to take &memcg->move_lock. Because we already hold
 	 * rcu_read_lock(), any calls to move_account will be delayed until
 	 * rcu_read_unlock().
 	 */
-	VM_BUG_ON(!rcu_read_lock_held());
+	*locked = false;
 	if (atomic_read(&memcg->moving_account) <= 0)
-		return;
+		return memcg;
 
 	spin_lock_irqsave(&memcg->move_lock, *flags);
 	if (memcg != pc->mem_cgroup) {
@@ -2004,37 +2005,26 @@ again:
 		goto again;
 	}
 	*locked = true;
+
+	return memcg;
 }
 
-void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
+void mem_cgroup_end_page_stat(struct mem_cgroup *memcg, bool locked,
+			      unsigned long flags)
 {
-	struct page_cgroup *pc = lookup_page_cgroup(page);
+	if (memcg && locked)
+		spin_unlock_irqrestore(&memcg->move_lock, flags);
 
-	/*
-	 * It's guaranteed that pc->mem_cgroup never changes while
-	 * lock is held because a routine modifies pc->mem_cgroup
-	 * should take move_lock_mem_cgroup().
-	 */
-	spin_unlock_irqrestore(&pc->mem_cgroup->move_lock, *flags);
+	rcu_read_unlock();
 }
 
-void mem_cgroup_update_page_stat(struct page *page,
+void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
 				 enum mem_cgroup_stat_index idx, int val)
 {
-	struct mem_cgroup *memcg;
-	struct page_cgroup *pc;
-
 	VM_BUG_ON(!rcu_read_lock_held());
 
-	if (mem_cgroup_disabled())
-		return;
-
-	pc = lookup_page_cgroup(page);
-	memcg = pc->mem_cgroup;
-	if (unlikely(!memcg))
-		return;
-
-	this_cpu_add(memcg->stat->count[idx], val);
+	if (memcg)
+		this_cpu_add(memcg->stat->count[idx], val);
 }
 
 /*
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index ff6a5b07211e..19ceae87522d 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2327,11 +2327,12 @@ EXPORT_SYMBOL(clear_page_dirty_for_io);
 int test_clear_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
-	int ret;
-	bool locked;
 	unsigned long memcg_flags;
+	struct mem_cgroup *memcg;
+	bool locked;
+	int ret;
 
-	mem_cgroup_begin_update_page_stat(page, &locked, &memcg_flags);
+	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
 	if (mapping) {
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
@@ -2352,22 +2353,23 @@ int test_clear_page_writeback(struct page *page)
 		ret = TestClearPageWriteback(page);
 	}
 	if (ret) {
-		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
+		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
 		dec_zone_page_state(page, NR_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITTEN);
 	}
-	mem_cgroup_end_update_page_stat(page, &locked, &memcg_flags);
+	mem_cgroup_end_page_stat(memcg, locked, memcg_flags);
 	return ret;
 }
 
 int __test_set_page_writeback(struct page *page, bool keep_write)
 {
 	struct address_space *mapping = page_mapping(page);
-	int ret;
-	bool locked;
 	unsigned long memcg_flags;
+	struct mem_cgroup *memcg;
+	bool locked;
+	int ret;
 
-	mem_cgroup_begin_update_page_stat(page, &locked, &memcg_flags);
+	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
 	if (mapping) {
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
@@ -2394,10 +2396,10 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 		ret = TestSetPageWriteback(page);
 	}
 	if (!ret) {
-		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
+		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITEBACK);
 	}
-	mem_cgroup_end_update_page_stat(page, &locked, &memcg_flags);
+	mem_cgroup_end_page_stat(memcg, locked, memcg_flags);
 	return ret;
 
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 116a5053415b..f574046f77d4 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1042,15 +1042,16 @@ void page_add_new_anon_rmap(struct page *page,
  */
 void page_add_file_rmap(struct page *page)
 {
-	bool locked;
+	struct mem_cgroup *memcg;
 	unsigned long flags;
+	bool locked;
 
-	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
+	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
+		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
-	mem_cgroup_end_update_page_stat(page, &locked, &flags);
+	mem_cgroup_end_page_stat(memcg, locked, flags);
 }
 
 /**
@@ -1061,9 +1062,10 @@ void page_add_file_rmap(struct page *page)
  */
 void page_remove_rmap(struct page *page)
 {
+	struct mem_cgroup *uninitialized_var(memcg);
 	bool anon = PageAnon(page);
-	bool locked;
 	unsigned long flags;
+	bool locked;
 
 	/*
 	 * The anon case has no mem_cgroup page_stat to update; but may
@@ -1071,7 +1073,7 @@ void page_remove_rmap(struct page *page)
 	 * we hold the lock against page_stat move: so avoid it on anon.
 	 */
 	if (!anon)
-		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
+		memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
 
 	/* page still mapped by someone else? */
 	if (!atomic_add_negative(-1, &page->_mapcount))
@@ -1096,8 +1098,7 @@ void page_remove_rmap(struct page *page)
 				-hpage_nr_pages(page));
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
-		mem_cgroup_end_update_page_stat(page, &locked, &flags);
+		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
@@ -1110,10 +1111,9 @@ void page_remove_rmap(struct page *page)
 	 * Leaving it set also helps swapoff to reinstate ptes
 	 * faster for those pages still in swapcache.
 	 */
-	return;
 out:
 	if (!anon)
-		mem_cgroup_end_update_page_stat(page, &locked, &flags);
+		mem_cgroup_end_page_stat(memcg, locked, flags);
 }
 
 /*
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
