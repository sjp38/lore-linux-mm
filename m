Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 335C06B0074
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:22:25 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id b6so4079171lbj.31
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 08:22:24 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ba16si14809515lab.35.2014.10.20.08.22.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 08:22:23 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/4] mm: memcontrol: remove unnecessary PCG_USED pc->mem_cgroup valid flag
Date: Mon, 20 Oct 2014 11:22:12 -0400
Message-Id: <1413818532-11042-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
References: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

pc->mem_cgroup had to be left intact after uncharge for the final LRU
removal, and !PCG_USED indicated whether the page was uncharged.  But
since 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API") pages are
uncharged after the final LRU removal.  Uncharge can simply clear the
pointer and the PCG_USED/PageCgroupUsed sites can test that instead.

Because this is the last page_cgroup flag, this patch reduces the
memcg per-page overhead to a single pointer.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/page_cgroup.h |  10 -----
 mm/memcontrol.c             | 107 +++++++++++++++++---------------------------
 2 files changed, 42 insertions(+), 75 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 97536e685843..1289be6b436c 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -1,11 +1,6 @@
 #ifndef __LINUX_PAGE_CGROUP_H
 #define __LINUX_PAGE_CGROUP_H
 
-enum {
-	/* flags for mem_cgroup */
-	PCG_USED = 0x01,	/* This page is charged to a memcg */
-};
-
 struct pglist_data;
 
 #ifdef CONFIG_MEMCG
@@ -19,7 +14,6 @@ struct mem_cgroup;
  * then the page cgroup for pfn always exists.
  */
 struct page_cgroup {
-	unsigned long flags;
 	struct mem_cgroup *mem_cgroup;
 };
 
@@ -39,10 +33,6 @@ static inline void page_cgroup_init(void)
 
 struct page_cgroup *lookup_page_cgroup(struct page *page);
 
-static inline int PageCgroupUsed(struct page_cgroup *pc)
-{
-	return !!(pc->flags & PCG_USED);
-}
 #else /* !CONFIG_MEMCG */
 struct page_cgroup;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1d66ac49e702..48d49c6b08d1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1284,14 +1284,12 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
 
 	pc = lookup_page_cgroup(page);
 	memcg = pc->mem_cgroup;
-
 	/*
 	 * Swapcache readahead pages are added to the LRU - and
-	 * possibly migrated - before they are charged.  Ensure
-	 * pc->mem_cgroup is sane.
+	 * possibly migrated - before they are charged.
 	 */
-	if (!PageLRU(page) && !PageCgroupUsed(pc) && memcg != root_mem_cgroup)
-		pc->mem_cgroup = memcg = root_mem_cgroup;
+	if (!memcg)
+		memcg = root_mem_cgroup;
 
 	mz = mem_cgroup_page_zoneinfo(memcg, page);
 	lruvec = &mz->lruvec;
@@ -2141,7 +2139,7 @@ void __mem_cgroup_begin_update_page_stat(struct page *page,
 	pc = lookup_page_cgroup(page);
 again:
 	memcg = pc->mem_cgroup;
-	if (unlikely(!memcg || !PageCgroupUsed(pc)))
+	if (unlikely(!memcg))
 		return;
 	/*
 	 * If this memory cgroup is not under account moving, we don't
@@ -2154,7 +2152,7 @@ again:
 		return;
 
 	move_lock_mem_cgroup(memcg, flags);
-	if (memcg != pc->mem_cgroup || !PageCgroupUsed(pc)) {
+	if (memcg != pc->mem_cgroup) {
 		move_unlock_mem_cgroup(memcg, flags);
 		goto again;
 	}
@@ -2186,7 +2184,7 @@ void mem_cgroup_update_page_stat(struct page *page,
 
 	pc = lookup_page_cgroup(page);
 	memcg = pc->mem_cgroup;
-	if (unlikely(!memcg || !PageCgroupUsed(pc)))
+	if (unlikely(!memcg))
 		return;
 
 	this_cpu_add(memcg->stat->count[idx], val);
@@ -2525,9 +2523,10 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
 	pc = lookup_page_cgroup(page);
-	if (PageCgroupUsed(pc)) {
-		memcg = pc->mem_cgroup;
-		if (memcg && !css_tryget_online(&memcg->css))
+	memcg = pc->mem_cgroup;
+
+	if (memcg) {
+		if (!css_tryget_online(&memcg->css))
 			memcg = NULL;
 	} else if (PageSwapCache(page)) {
 		ent.val = page_private(page);
@@ -2578,7 +2577,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 	int isolated;
 
-	VM_BUG_ON_PAGE(PageCgroupUsed(pc), page);
+	VM_BUG_ON_PAGE(pc->mem_cgroup, page);
 	/*
 	 * we don't need page_cgroup_lock about tail pages, becase they are not
 	 * accessed by any other context at this point.
@@ -2593,7 +2592,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 
 	/*
 	 * Nobody should be changing or seriously looking at
-	 * pc->mem_cgroup and pc->flags at this point:
+	 * pc->mem_cgroup at this point:
 	 *
 	 * - the page is uncharged
 	 *
@@ -2606,7 +2605,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 	 *   have the page locked
 	 */
 	pc->mem_cgroup = memcg;
-	pc->flags = PCG_USED;
 
 	if (lrucare)
 		unlock_page_lru(page, isolated);
@@ -3120,37 +3118,22 @@ void __memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg,
 		memcg_uncharge_kmem(memcg, 1 << order);
 		return;
 	}
-	/*
-	 * The page is freshly allocated and not visible to any
-	 * outside callers yet.  Set up pc non-atomically.
-	 */
 	pc = lookup_page_cgroup(page);
 	pc->mem_cgroup = memcg;
-	pc->flags = PCG_USED;
 }
 
 void __memcg_kmem_uncharge_pages(struct page *page, int order)
 {
-	struct mem_cgroup *memcg = NULL;
-	struct page_cgroup *pc;
-
-
-	pc = lookup_page_cgroup(page);
-	if (!PageCgroupUsed(pc))
-		return;
-
-	memcg = pc->mem_cgroup;
-	pc->flags = 0;
+	struct page_cgroup *pc = lookup_page_cgroup(page);
+	struct mem_cgroup *memcg = pc->mem_cgroup;
 
-	/*
-	 * We trust that only if there is a memcg associated with the page, it
-	 * is a valid allocation
-	 */
 	if (!memcg)
 		return;
 
 	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
+
 	memcg_uncharge_kmem(memcg, 1 << order);
+	pc->mem_cgroup = NULL;
 }
 #else
 static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
@@ -3168,21 +3151,16 @@ static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
  */
 void mem_cgroup_split_huge_fixup(struct page *head)
 {
-	struct page_cgroup *head_pc = lookup_page_cgroup(head);
-	struct page_cgroup *pc;
-	struct mem_cgroup *memcg;
+	struct page_cgroup *pc = lookup_page_cgroup(head);
 	int i;
 
 	if (mem_cgroup_disabled())
 		return;
 
-	memcg = head_pc->mem_cgroup;
-	for (i = 1; i < HPAGE_PMD_NR; i++) {
-		pc = head_pc + i;
-		pc->mem_cgroup = memcg;
-		pc->flags = head_pc->flags;
-	}
-	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
+	for (i = 1; i < HPAGE_PMD_NR; i++)
+		pc[i].mem_cgroup = pc[0].mem_cgroup;
+
+	__this_cpu_sub(pc[0].mem_cgroup->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
 		       HPAGE_PMD_NR);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
@@ -3232,7 +3210,7 @@ static int mem_cgroup_move_account(struct page *page,
 		goto out;
 
 	ret = -EINVAL;
-	if (!PageCgroupUsed(pc) || pc->mem_cgroup != from)
+	if (pc->mem_cgroup != from)
 		goto out_unlock;
 
 	move_lock_mem_cgroup(from, &flags);
@@ -3342,7 +3320,7 @@ static struct page_cgroup *lookup_page_cgroup_used(struct page *page)
 	 * the first time, i.e. during boot or memory hotplug;
 	 * or when mem_cgroup_disabled().
 	 */
-	if (likely(pc) && PageCgroupUsed(pc))
+	if (likely(pc) && pc->mem_cgroup)
 		return pc;
 	return NULL;
 }
@@ -3360,10 +3338,8 @@ void mem_cgroup_print_bad_page(struct page *page)
 	struct page_cgroup *pc;
 
 	pc = lookup_page_cgroup_used(page);
-	if (pc) {
-		pr_alert("pc:%p pc->flags:%lx pc->mem_cgroup:%p\n",
-			 pc, pc->flags, pc->mem_cgroup);
-	}
+	if (pc)
+		pr_alert("pc:%p pc->mem_cgroup:%p\n", pc, pc->mem_cgroup);
 }
 #endif
 
@@ -5330,7 +5306,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		 * mem_cgroup_move_account() checks the pc is valid or
 		 * not under LRU exclusion.
 		 */
-		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+		if (pc->mem_cgroup == mc.from) {
 			ret = MC_TARGET_PAGE;
 			if (target)
 				target->page = page;
@@ -5366,7 +5342,7 @@ static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
 	if (!move_anon())
 		return ret;
 	pc = lookup_page_cgroup(page);
-	if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+	if (pc->mem_cgroup == mc.from) {
 		ret = MC_TARGET_PAGE;
 		if (target) {
 			get_page(page);
@@ -5810,18 +5786,17 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 		return;
 
 	pc = lookup_page_cgroup(page);
+	memcg = pc->mem_cgroup;
 
 	/* Readahead page, never charged */
-	if (!PageCgroupUsed(pc))
+	if (!memcg)
 		return;
 
-	memcg = pc->mem_cgroup;
-
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
 	VM_BUG_ON_PAGE(oldid, page);
 	mem_cgroup_swap_statistics(memcg, true);
 
-	pc->flags = 0;
+	pc->mem_cgroup = NULL;
 
 	if (!mem_cgroup_is_root(memcg))
 		page_counter_uncharge(&memcg->memory, 1);
@@ -5895,7 +5870,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 		 * the page lock, which serializes swap cache removal, which
 		 * in turn serializes uncharging.
 		 */
-		if (PageCgroupUsed(pc))
+		if (pc->mem_cgroup)
 			goto out;
 	}
 
@@ -6057,13 +6032,13 @@ static void uncharge_list(struct list_head *page_list)
 		VM_BUG_ON_PAGE(page_count(page), page);
 
 		pc = lookup_page_cgroup(page);
-		if (!PageCgroupUsed(pc))
+		if (!pc->mem_cgroup)
 			continue;
 
 		/*
 		 * Nobody should be changing or seriously looking at
-		 * pc->mem_cgroup and pc->flags at this point, we have
-		 * fully exclusive access to the page.
+		 * pc->mem_cgroup at this point, we have fully
+		 * exclusive access to the page.
 		 */
 
 		if (memcg != pc->mem_cgroup) {
@@ -6086,7 +6061,7 @@ static void uncharge_list(struct list_head *page_list)
 		else
 			nr_file += nr_pages;
 
-		pc->flags = 0;
+		pc->mem_cgroup = NULL;
 
 		pgpgout++;
 	} while (next != page_list);
@@ -6112,7 +6087,7 @@ void mem_cgroup_uncharge(struct page *page)
 
 	/* Don't touch page->lru of any random page, pre-check: */
 	pc = lookup_page_cgroup(page);
-	if (!PageCgroupUsed(pc))
+	if (!pc->mem_cgroup)
 		return;
 
 	INIT_LIST_HEAD(&page->lru);
@@ -6148,6 +6123,7 @@ void mem_cgroup_uncharge_list(struct list_head *page_list)
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 			bool lrucare)
 {
+	struct mem_cgroup *memcg;
 	struct page_cgroup *pc;
 	int isolated;
 
@@ -6164,7 +6140,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 
 	/* Page cache replacement: new page already charged? */
 	pc = lookup_page_cgroup(newpage);
-	if (PageCgroupUsed(pc))
+	if (pc->mem_cgroup)
 		return;
 
 	/*
@@ -6174,18 +6150,19 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	 * reclaim just put back on the LRU but has not released yet.
 	 */
 	pc = lookup_page_cgroup(oldpage);
-	if (!PageCgroupUsed(pc))
+	memcg = pc->mem_cgroup;
+	if (!memcg)
 		return;
 
 	if (lrucare)
 		lock_page_lru(oldpage, &isolated);
 
-	pc->flags = 0;
+	pc->mem_cgroup = NULL;
 
 	if (lrucare)
 		unlock_page_lru(oldpage, isolated);
 
-	commit_charge(newpage, pc->mem_cgroup, lrucare);
+	commit_charge(newpage, memcg, lrucare);
 }
 
 /*
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
