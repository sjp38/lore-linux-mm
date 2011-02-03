Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BE7258D003D
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:27:17 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/5] memcg: condense page_cgroup-to-page lookup points
Date: Thu,  3 Feb 2011 15:26:05 +0100
Message-Id: <1296743166-9412-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The per-cgroup LRU lists string up 'struct page_cgroup's.  To get from
those structures to the page they represent, a lookup is required.
Currently, the lookup is done through a direct pointer in struct
page_cgroup, so a lot of functions down the callchain do this lookup
by themselves instead of receiving the page pointer from their
callers.

The next patch removes this pointer, however, and the lookup is no
longer that straight-forward.  In preparation for that, this patch
only leaves the non-optional lookups when coming directly from the LRU
list and passes the page down the stack.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |   38 +++++++++++++++++++++++---------------
 1 files changed, 23 insertions(+), 15 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5eb0dc2..998da06 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1051,9 +1051,11 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 		if (scan >= nr_to_scan)
 			break;
 
-		page = pc->page;
 		if (unlikely(!PageCgroupUsed(pc)))
 			continue;
+
+		page = pc->page;
+
 		if (unlikely(!PageLRU(page)))
 			continue;
 
@@ -2082,6 +2084,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 }
 
 static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
+				       struct page *page,
 				       struct page_cgroup *pc,
 				       enum charge_type ctype,
 				       int page_size)
@@ -2128,7 +2131,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
 	 * if they exceeds softlimit.
 	 */
-	memcg_check_events(mem, pc->page);
+	memcg_check_events(mem, page);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -2175,6 +2178,7 @@ void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
 
 /**
  * mem_cgroup_move_account - move account of the page
+ * @page: the page
  * @pc:	page_cgroup of the page.
  * @from: mem_cgroup which the page is moved from.
  * @to:	mem_cgroup which the page is moved to. @from != @to.
@@ -2190,7 +2194,7 @@ void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
  * true, this function does "uncharge" from old cgroup, but it doesn't if
  * @uncharge is false, so a caller should do "uncharge".
  */
-static int mem_cgroup_move_account(struct page_cgroup *pc,
+static int mem_cgroup_move_account(struct page *page, struct page_cgroup *pc,
 				   struct mem_cgroup *from, struct mem_cgroup *to,
 				   bool uncharge, int charge_size)
 {
@@ -2199,7 +2203,7 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 	int ret;
 
 	VM_BUG_ON(from == to);
-	VM_BUG_ON(PageLRU(pc->page));
+	VM_BUG_ON(PageLRU(page));
 	/*
 	 * The page is isolated from LRU. So, collapse function
 	 * will not handle this page. But page splitting can happen.
@@ -2207,7 +2211,7 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 	 * hold it.
 	 */
 	ret = -EBUSY;
-	if (charge_size > PAGE_SIZE && !PageTransHuge(pc->page))
+	if (charge_size > PAGE_SIZE && !PageTransHuge(page))
 		goto out;
 
 	lock_page_cgroup(pc);
@@ -2247,8 +2251,8 @@ unlock:
 	/*
 	 * check events
 	 */
-	memcg_check_events(to, pc->page);
-	memcg_check_events(from, pc->page);
+	memcg_check_events(to, page);
+	memcg_check_events(from, page);
 out:
 	return ret;
 }
@@ -2257,11 +2261,11 @@ out:
  * move charges to its parent.
  */
 
-static int mem_cgroup_move_parent(struct page_cgroup *pc,
+static int mem_cgroup_move_parent(struct page *page,
+				  struct page_cgroup *pc,
 				  struct mem_cgroup *child,
 				  gfp_t gfp_mask)
 {
-	struct page *page = pc->page;
 	struct cgroup *cg = child->css.cgroup;
 	struct cgroup *pcg = cg->parent;
 	struct mem_cgroup *parent;
@@ -2291,7 +2295,7 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
 	if (page_size > PAGE_SIZE)
 		flags = compound_lock_irqsave(page);
 
-	ret = mem_cgroup_move_account(pc, child, parent, true, page_size);
+	ret = mem_cgroup_move_account(page, pc, child, parent, true, page_size);
 	if (ret)
 		mem_cgroup_cancel_charge(parent, page_size);
 
@@ -2337,7 +2341,7 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 	if (ret || !mem)
 		return ret;
 
-	__mem_cgroup_commit_charge(mem, pc, ctype, page_size);
+	__mem_cgroup_commit_charge(mem, page, pc, ctype, page_size);
 	return 0;
 }
 
@@ -2473,7 +2477,7 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
 	cgroup_exclude_rmdir(&ptr->css);
 	pc = lookup_page_cgroup(page);
 	mem_cgroup_lru_del_before_commit_swapcache(page);
-	__mem_cgroup_commit_charge(ptr, pc, ctype, PAGE_SIZE);
+	__mem_cgroup_commit_charge(ptr, page, pc, ctype, PAGE_SIZE);
 	mem_cgroup_lru_add_after_commit_swapcache(page);
 	/*
 	 * Now swap is on-memory. This means this page may be
@@ -2926,7 +2930,7 @@ int mem_cgroup_prepare_migration(struct page *page,
 		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	else
 		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
-	__mem_cgroup_commit_charge(mem, pc, ctype, PAGE_SIZE);
+	__mem_cgroup_commit_charge(mem, page, pc, ctype, PAGE_SIZE);
 	return ret;
 }
 
@@ -3275,6 +3279,8 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 	loop += 256;
 	busy = NULL;
 	while (loop--) {
+		struct page *page;
+
 		ret = 0;
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		if (list_empty(list)) {
@@ -3290,7 +3296,9 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 		}
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-		ret = mem_cgroup_move_parent(pc, mem, GFP_KERNEL);
+		page = pc->page;
+
+		ret = mem_cgroup_move_parent(page, pc, mem, GFP_KERNEL);
 		if (ret == -ENOMEM)
 			break;
 
@@ -4907,7 +4915,7 @@ retry:
 			if (isolate_lru_page(page))
 				goto put;
 			pc = lookup_page_cgroup(page);
-			if (!mem_cgroup_move_account(pc,
+			if (!mem_cgroup_move_account(page, pc,
 					mc.from, mc.to, false, PAGE_SIZE)) {
 				mc.precharge--;
 				/* we uncharge from mc.from later. */
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
