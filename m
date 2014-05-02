Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id AE3976B004D
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:53:05 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id c9so4751062qcz.2
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:05 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id j6si14042780qan.262.2014.05.02.06.53.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:53:05 -0700 (PDT)
Received: by mail-qg0-f51.google.com with SMTP id q107so298616qgd.10
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:05 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 05/11] mm/memcg: support accounting null page and transfering null charge to new page.
Date: Fri,  2 May 2014 09:52:04 -0400
Message-Id: <1399038730-25641-6-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

When migrating memory to some device specific memory we still want to properly
account memcg memory usage. To do so we need to be able to account for page not
allocated in system memory. We also need to be able to transfer previous charge
from device memory to a page in an atomic way from memcg point of view.

Also introduce helper function to clear page memcg.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/memcontrol.h |  17 +++++
 mm/memcontrol.c            | 161 +++++++++++++++++++++++++++++++++++++++------
 2 files changed, 159 insertions(+), 19 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1fa2324..1737323 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -67,6 +67,8 @@ struct mem_cgroup_reclaim_cookie {
 
 extern int mem_cgroup_charge_anon(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
+extern void mem_cgroup_transfer_charge_anon(struct page *page,
+					    struct mm_struct *mm);
 /* for swap handling */
 extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 		struct page *page, gfp_t mask, struct mem_cgroup **memcgp);
@@ -85,6 +87,8 @@ extern void mem_cgroup_uncharge_start(void);
 extern void mem_cgroup_uncharge_end(void);
 
 extern void mem_cgroup_uncharge_page(struct page *page);
+extern void mem_cgroup_uncharge_mm(struct mm_struct *mm);
+extern void mem_cgroup_clear_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);
 
 bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
@@ -245,6 +249,11 @@ static inline int mem_cgroup_charge_file(struct page *page,
 	return 0;
 }
 
+static inline void mem_cgroup_transfer_charge_anon(struct page *page,
+						   struct mm_struct *mm)
+{
+}
+
 static inline int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 		struct page *page, gfp_t gfp_mask, struct mem_cgroup **memcgp)
 {
@@ -272,6 +281,14 @@ static inline void mem_cgroup_uncharge_page(struct page *page)
 {
 }
 
+static inline void mem_cgroup_uncharge_mm(struct mm_struct *mm)
+{
+}
+
+static inline void mem_cgroup_clear_page(struct page *page)
+{
+}
+
 static inline void mem_cgroup_uncharge_cache_page(struct page *page)
 {
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 19d620b..ceaf4d7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -940,7 +940,7 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
 				nr_pages);
 
-	if (PageTransHuge(page))
+	if (page && PageTransHuge(page))
 		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
 				nr_pages);
 
@@ -2842,12 +2842,17 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 				       enum charge_type ctype,
 				       bool lrucare)
 {
-	struct page_cgroup *pc = lookup_page_cgroup(page);
+	struct page_cgroup *pc;
 	struct zone *uninitialized_var(zone);
 	struct lruvec *lruvec;
 	bool was_on_lru = false;
 	bool anon;
 
+	if (page == NULL) {
+		goto charge;
+	}
+
+	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	VM_BUG_ON_PAGE(PageCgroupUsed(pc), page);
 	/*
@@ -2891,20 +2896,24 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 		spin_unlock_irq(&zone->lru_lock);
 	}
 
+charge:
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_ANON)
 		anon = true;
 	else
 		anon = false;
 
 	mem_cgroup_charge_statistics(memcg, page, anon, nr_pages);
-	unlock_page_cgroup(pc);
 
-	/*
-	 * "charge_statistics" updated event counter. Then, check it.
-	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
-	 * if they exceeds softlimit.
-	 */
-	memcg_check_events(memcg, page);
+	if (page) {
+		unlock_page_cgroup(pc);
+
+		/*
+		 * "charge_statistics" updated event counter. Then, check it.
+		 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
+		 * if they exceeds softlimit.
+		 */
+		memcg_check_events(memcg, page);
+	}
 }
 
 static DEFINE_MUTEX(set_limit_mutex);
@@ -3745,20 +3754,23 @@ int mem_cgroup_charge_anon(struct page *page,
 	if (mem_cgroup_disabled())
 		return 0;
 
-	VM_BUG_ON_PAGE(page_mapped(page), page);
-	VM_BUG_ON_PAGE(page->mapping && !PageAnon(page), page);
 	VM_BUG_ON(!mm);
+	if (page) {
+		VM_BUG_ON_PAGE(page_mapped(page), page);
+		VM_BUG_ON_PAGE(page->mapping && !PageAnon(page), page);
 
-	if (PageTransHuge(page)) {
-		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-		/*
-		 * Never OOM-kill a process for a huge page.  The
-		 * fault handler will fall back to regular pages.
-		 */
-		oom = false;
+		if (PageTransHuge(page)) {
+			nr_pages <<= compound_order(page);
+			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+			/*
+			 * Never OOM-kill a process for a huge page.  The
+			 * fault handler will fall back to regular pages.
+			 */
+			oom = false;
+		}
 	}
 
+
 	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, nr_pages, oom);
 	if (!memcg)
 		return -ENOMEM;
@@ -3767,6 +3779,60 @@ int mem_cgroup_charge_anon(struct page *page,
 	return 0;
 }
 
+void mem_cgroup_transfer_charge_anon(struct page *page, struct mm_struct *mm)
+{
+	struct page_cgroup *pc;
+	struct task_struct *task;
+	struct mem_cgroup *memcg;
+	struct zone *uninitialized_var(zone);
+
+	if (mem_cgroup_disabled())
+		return;
+
+	VM_BUG_ON(page->mapping && !PageAnon(page));
+	VM_BUG_ON(!mm);
+
+	rcu_read_lock();
+	task = rcu_dereference(mm->owner);
+	/*
+	 * Because we don't have task_lock(), "p" can exit.
+	 * In that case, "memcg" can point to root or p can be NULL with
+	 * race with swapoff. Then, we have small risk of mis-accouning.
+	 * But such kind of mis-account by race always happens because
+	 * we don't have cgroup_mutex(). It's overkill and we allo that
+	 * small race, here.
+	 * (*) swapoff at el will charge against mm-struct not against
+	 * task-struct. So, mm->owner can be NULL.
+	 */
+	memcg = mem_cgroup_from_task(task);
+	if (!memcg) {
+		memcg = root_mem_cgroup;
+	}
+	rcu_read_unlock();
+
+	pc = lookup_page_cgroup(page);
+	lock_page_cgroup(pc);
+	VM_BUG_ON(PageCgroupUsed(pc));
+	/*
+	 * we don't need page_cgroup_lock about tail pages, becase they are not
+	 * accessed by any other context at this point.
+	 */
+
+	pc->mem_cgroup = memcg;
+	/*
+	 * We access a page_cgroup asynchronously without lock_page_cgroup().
+	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
+	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
+	 * before USED bit, we need memory barrier here.
+	 * See mem_cgroup_add_lru_list(), etc.
+	 */
+	smp_wmb();
+	SetPageCgroupUsed(pc);
+
+	unlock_page_cgroup(pc);
+	memcg_check_events(memcg, page);
+}
+
 /*
  * While swap-in, try_charge -> commit or cancel, the page is locked.
  * And when try_charge() successfully returns, one refcnt to memcg without
@@ -4087,6 +4153,63 @@ void mem_cgroup_uncharge_page(struct page *page)
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_ANON, false);
 }
 
+void mem_cgroup_uncharge_mm(struct mm_struct *mm)
+{
+	struct mem_cgroup *memcg;
+	struct task_struct *task;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	VM_BUG_ON(!mm);
+
+	rcu_read_lock();
+	task = rcu_dereference(mm->owner);
+	/*
+	 * Because we don't have task_lock(), "p" can exit.
+	 * In that case, "memcg" can point to root or p can be NULL with
+	 * race with swapoff. Then, we have small risk of mis-accouning.
+	 * But such kind of mis-account by race always happens because
+	 * we don't have cgroup_mutex(). It's overkill and we allo that
+	 * small race, here.
+	 * (*) swapoff at el will charge against mm-struct not against
+	 * task-struct. So, mm->owner can be NULL.
+	 */
+	memcg = mem_cgroup_from_task(task);
+	if (!memcg) {
+		memcg = root_mem_cgroup;
+	}
+	rcu_read_unlock();
+
+	mem_cgroup_charge_statistics(memcg, NULL, true, -1);
+	if (!mem_cgroup_is_root(memcg))
+		mem_cgroup_do_uncharge(memcg, 1, MEM_CGROUP_CHARGE_TYPE_ANON);
+}
+
+void mem_cgroup_clear_page(struct page *page)
+{
+	struct page_cgroup *pc;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	/*
+	 * Check if our page_cgroup is valid
+	 */
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!PageCgroupUsed(pc)))
+		return;
+	lock_page_cgroup(pc);
+	ClearPageCgroupUsed(pc);
+	/*
+	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
+	 * freed from LRU. This is safe because uncharged page is expected not
+	 * to be reused (freed soon). Exception is SwapCache, it's handled by
+	 * special functions.
+	 */
+	unlock_page_cgroup(pc);
+}
+
 void mem_cgroup_uncharge_cache_page(struct page *page)
 {
 	VM_BUG_ON_PAGE(page_mapped(page), page);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
