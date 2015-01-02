Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 48BF46B0032
	for <linux-mm@kvack.org>; Fri,  2 Jan 2015 15:58:56 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id k14so6848703wgh.16
        for <linux-mm@kvack.org>; Fri, 02 Jan 2015 12:58:55 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cl6si97450710wjb.49.2015.01.02.12.58.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jan 2015 12:58:55 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: track move_lock state internally
Date: Fri,  2 Jan 2015 15:58:47 -0500
Message-Id: <1420232327-13316-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The complexity of memcg page stat synchronization is currently leaking
into the callsites, forcing them to keep track of the move_lock state
and the IRQ flags.  Simplify the API by tracking it in the memcg.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  6 ++--
 mm/memcontrol.c            | 68 ++++++++++++++++++++++++++--------------------
 mm/page-writeback.c        | 12 +++-----
 mm/rmap.c                  | 12 +++-----
 4 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index fb212e1d700d..04d3c2028782 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -138,12 +138,10 @@ static inline bool mem_cgroup_disabled(void)
 	return false;
 }
 
-struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page, bool *locked,
-					      unsigned long *flags);
-void mem_cgroup_end_page_stat(struct mem_cgroup *memcg, bool *locked,
-			      unsigned long *flags);
+struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page);
 void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
 				 enum mem_cgroup_stat_index idx, int val);
+void mem_cgroup_end_page_stat(struct mem_cgroup *memcg);
 
 static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
 					    enum mem_cgroup_stat_index idx)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a855848627a5..eccc0ed3b6f3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -325,9 +325,11 @@ struct mem_cgroup {
 	/*
 	 * set > 0 if pages under this cgroup are moving to other cgroup.
 	 */
-	atomic_t	moving_account;
+	atomic_t		moving_account;
 	/* taken only while moving_account > 0 */
-	spinlock_t	move_lock;
+	spinlock_t		move_lock;
+	struct task_struct	*move_lock_task;
+	unsigned long		move_lock_flags;
 	/*
 	 * percpu counter.
 	 */
@@ -1977,34 +1979,33 @@ cleanup:
 /**
  * mem_cgroup_begin_page_stat - begin a page state statistics transaction
  * @page: page that is going to change accounted state
- * @locked: &memcg->move_lock slowpath was taken
- * @flags: IRQ-state flags for &memcg->move_lock
  *
  * This function must mark the beginning of an accounted page state
  * change to prevent double accounting when the page is concurrently
  * being moved to another memcg:
  *
- *   memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
+ *   memcg = mem_cgroup_begin_page_stat(page);
  *   if (TestClearPageState(page))
  *     mem_cgroup_update_page_stat(memcg, state, -1);
- *   mem_cgroup_end_page_stat(memcg, locked, flags);
- *
- * The RCU lock is held throughout the transaction.  The fast path can
- * get away without acquiring the memcg->move_lock (@locked is false)
- * because page moving starts with an RCU grace period.
- *
- * The RCU lock also protects the memcg from being freed when the page
- * state that is going to change is the only thing preventing the page
- * from being uncharged.  E.g. end-writeback clearing PageWriteback(),
- * which allows migration to go ahead and uncharge the page before the
- * account transaction might be complete.
+ *   mem_cgroup_end_page_stat(memcg);
  */
-struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page,
-					      bool *locked,
-					      unsigned long *flags)
+struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page)
 {
 	struct mem_cgroup *memcg;
+	unsigned long flags;
 
+	/*
+	 * The RCU lock is held throughout the transaction.  The fast
+	 * path can get away without acquiring the memcg->move_lock
+	 * because page moving starts with an RCU grace period.
+	 *
+	 * The RCU lock also protects the memcg from being freed when
+	 * the page state that is going to change is the only thing
+	 * preventing the page from being uncharged.
+	 * E.g. end-writeback clearing PageWriteback(), which allows
+	 * migration to go ahead and uncharge the page before the
+	 * account transaction might be complete.
+	 */
 	rcu_read_lock();
 
 	if (mem_cgroup_disabled())
@@ -2014,16 +2015,22 @@ again:
 	if (unlikely(!memcg))
 		return NULL;
 
-	*locked = false;
 	if (atomic_read(&memcg->moving_account) <= 0)
 		return memcg;
 
-	spin_lock_irqsave(&memcg->move_lock, *flags);
+	spin_lock_irqsave(&memcg->move_lock, flags);
 	if (memcg != page->mem_cgroup) {
-		spin_unlock_irqrestore(&memcg->move_lock, *flags);
+		spin_unlock_irqrestore(&memcg->move_lock, flags);
 		goto again;
 	}
-	*locked = true;
+
+	/*
+	 * When charge migration first begins, we can have locked and
+	 * unlocked page stat updates happening concurrently.  Track
+	 * the task who has the lock for mem_cgroup_end_page_stat().
+	 */
+	memcg->move_lock_task = current;
+	memcg->move_lock_flags = flags;
 
 	return memcg;
 }
@@ -2031,14 +2038,17 @@ again:
 /**
  * mem_cgroup_end_page_stat - finish a page state statistics transaction
  * @memcg: the memcg that was accounted against
- * @locked: value received from mem_cgroup_begin_page_stat()
- * @flags: value received from mem_cgroup_begin_page_stat()
  */
-void mem_cgroup_end_page_stat(struct mem_cgroup *memcg, bool *locked,
-			      unsigned long *flags)
+void mem_cgroup_end_page_stat(struct mem_cgroup *memcg)
 {
-	if (memcg && *locked)
-		spin_unlock_irqrestore(&memcg->move_lock, *flags);
+	if (memcg && memcg->move_lock_task == current) {
+		unsigned long flags = memcg->move_lock_flags;
+
+		memcg->move_lock_task = NULL;
+		memcg->move_lock_flags = 0;
+
+		spin_unlock_irqrestore(&memcg->move_lock, flags);
+	}
 
 	rcu_read_unlock();
 }
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 6f4335238e33..fb71e9deca85 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2308,12 +2308,10 @@ EXPORT_SYMBOL(clear_page_dirty_for_io);
 int test_clear_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
-	unsigned long memcg_flags;
 	struct mem_cgroup *memcg;
-	bool locked;
 	int ret;
 
-	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
+	memcg = mem_cgroup_begin_page_stat(page);
 	if (mapping) {
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
@@ -2338,19 +2336,17 @@ int test_clear_page_writeback(struct page *page)
 		dec_zone_page_state(page, NR_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITTEN);
 	}
-	mem_cgroup_end_page_stat(memcg, &locked, &memcg_flags);
+	mem_cgroup_end_page_stat(memcg);
 	return ret;
 }
 
 int __test_set_page_writeback(struct page *page, bool keep_write)
 {
 	struct address_space *mapping = page_mapping(page);
-	unsigned long memcg_flags;
 	struct mem_cgroup *memcg;
-	bool locked;
 	int ret;
 
-	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
+	memcg = mem_cgroup_begin_page_stat(page);
 	if (mapping) {
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
@@ -2380,7 +2376,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITEBACK);
 	}
-	mem_cgroup_end_page_stat(memcg, &locked, &memcg_flags);
+	mem_cgroup_end_page_stat(memcg);
 	return ret;
 
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index c325f8bd2cc4..5e995a9da902 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1112,24 +1112,20 @@ void page_add_new_anon_rmap(struct page *page,
 void page_add_file_rmap(struct page *page)
 {
 	struct mem_cgroup *memcg;
-	unsigned long flags;
-	bool locked;
 
-	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
+	memcg = mem_cgroup_begin_page_stat(page);
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
-	mem_cgroup_end_page_stat(memcg, &locked, &flags);
+	mem_cgroup_end_page_stat(memcg);
 }
 
 static void page_remove_file_rmap(struct page *page)
 {
 	struct mem_cgroup *memcg;
-	unsigned long flags;
-	bool locked;
 
-	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
+	memcg = mem_cgroup_begin_page_stat(page);
 
 	/* page still mapped by someone else? */
 	if (!atomic_add_negative(-1, &page->_mapcount))
@@ -1150,7 +1146,7 @@ static void page_remove_file_rmap(struct page *page)
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 out:
-	mem_cgroup_end_page_stat(memcg, &locked, &flags);
+	mem_cgroup_end_page_stat(memcg);
 }
 
 /**
-- 
2.2.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
