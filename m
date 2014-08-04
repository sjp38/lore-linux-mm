Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id AB8086B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 16:34:36 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so149735wib.17
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 13:34:36 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id dt8si309910wib.7.2014.08.04.13.34.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 13:34:34 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: avoid charge statistics churn during page migration
Date: Mon,  4 Aug 2014 16:34:29 -0400
Message-Id: <1407184469-20741-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Charge migration currently disables IRQs twice to update the charge
statistics for the old page and then again for the new page.

But migration is a seemless transition of a charge from one physical
page to another one of the same size, so this should be a non-event
from an accounting point of view.  Leave the statistics alone.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 35 ++++++++++-------------------------
 1 file changed, 10 insertions(+), 25 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 475ecadd9646..8d65dadeec1b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2728,7 +2728,7 @@ static void unlock_page_lru(struct page *page, int isolated)
 }
 
 static void commit_charge(struct page *page, struct mem_cgroup *memcg,
-			  unsigned int nr_pages, bool lrucare)
+			  bool lrucare)
 {
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 	int isolated;
@@ -2765,16 +2765,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 
 	if (lrucare)
 		unlock_page_lru(page, isolated);
-
-	local_irq_disable();
-	mem_cgroup_charge_statistics(memcg, page, nr_pages);
-	/*
-	 * "charge_statistics" updated event counter. Then, check it.
-	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
-	 * if they exceeds softlimit.
-	 */
-	memcg_check_events(memcg, page);
-	local_irq_enable();
 }
 
 static DEFINE_MUTEX(set_limit_mutex);
@@ -6460,12 +6450,17 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 	if (!memcg)
 		return;
 
+	commit_charge(page, memcg, lrucare);
+
 	if (PageTransHuge(page)) {
 		nr_pages <<= compound_order(page);
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 	}
 
-	commit_charge(page, memcg, nr_pages, lrucare);
+	local_irq_disable();
+	mem_cgroup_charge_statistics(memcg, page, nr_pages);
+	memcg_check_events(memcg, page);
+	local_irq_enable();
 
 	if (do_swap_account && PageSwapCache(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
@@ -6651,7 +6646,6 @@ void mem_cgroup_uncharge_list(struct list_head *page_list)
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 			bool lrucare)
 {
-	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
 	int isolated;
 
@@ -6660,6 +6654,8 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage), oldpage);
 	VM_BUG_ON_PAGE(!lrucare && PageLRU(newpage), newpage);
 	VM_BUG_ON_PAGE(PageAnon(oldpage) != PageAnon(newpage), newpage);
+	VM_BUG_ON_PAGE(PageTransHuge(oldpage) != PageTransHuge(newpage),
+		       newpage);
 
 	if (mem_cgroup_disabled())
 		return;
@@ -6677,12 +6673,6 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
 	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
 
-	if (PageTransHuge(oldpage)) {
-		nr_pages <<= compound_order(oldpage);
-		VM_BUG_ON_PAGE(!PageTransHuge(oldpage), oldpage);
-		VM_BUG_ON_PAGE(!PageTransHuge(newpage), newpage);
-	}
-
 	if (lrucare)
 		lock_page_lru(oldpage, &isolated);
 
@@ -6691,12 +6681,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	if (lrucare)
 		unlock_page_lru(oldpage, isolated);
 
-	local_irq_disable();
-	mem_cgroup_charge_statistics(pc->mem_cgroup, oldpage, -nr_pages);
-	memcg_check_events(pc->mem_cgroup, oldpage);
-	local_irq_enable();
-
-	commit_charge(newpage, pc->mem_cgroup, nr_pages, lrucare);
+	commit_charge(newpage, pc->mem_cgroup, lrucare);
 }
 
 /*
-- 
2.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
