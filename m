From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 2/4] memcg: rename and export try_get_mem_cgroup_from_page()
Date: Mon, 31 Aug 2009 18:26:42 +0800
Message-ID: <20090831104216.759762658@intel.com>
References: <20090831102640.092092954@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CE38B6B005C
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 06:43:31 -0400 (EDT)
Content-Disposition: inline; filename=memcg-try_get_mem_cgroup_from_page.patch
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, lizf@cn.fujitsu.com, nishimura@mxp.nes.nec.co.jp, menage@google.com, linux-mm <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

The hwpoison injection code need to get the mem_cgroup from
arbitrary page in order to check its css_id.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/memcontrol.h |    6 ++++++
 mm/memcontrol.c            |   12 +++++-------
 2 files changed, 11 insertions(+), 7 deletions(-)

--- linux-mm.orig/mm/memcontrol.c	2009-08-31 15:41:50.000000000 +0800
+++ linux-mm/mm/memcontrol.c	2009-08-31 15:41:53.000000000 +0800
@@ -1385,25 +1385,22 @@ static struct mem_cgroup *mem_cgroup_loo
 	return container_of(css, struct mem_cgroup, css);
 }
 
-static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
+struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem = NULL;
 	struct page_cgroup *pc;
 	unsigned short id;
 	swp_entry_t ent;
 
 	VM_BUG_ON(!PageLocked(page));
 
-	if (!PageSwapCache(page))
-		return NULL;
-
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		if (mem && !css_tryget(&mem->css))
 			mem = NULL;
-	} else {
+	} else if (PageSwapCache(page)) {
 		ent.val = page_private(page);
 		id = lookup_swap_cgroup(ent);
 		rcu_read_lock();
@@ -1415,6 +1412,7 @@ static struct mem_cgroup *try_get_mem_cg
 	unlock_page_cgroup(pc);
 	return mem;
 }
+EXPORT_SYMBOL(try_get_mem_cgroup_from_page);
 
 /*
  * commit a charge got by __mem_cgroup_try_charge() and makes page_cgroup to be
@@ -1749,7 +1747,7 @@ int mem_cgroup_try_charge_swapin(struct 
 	 */
 	if (!PageSwapCache(page))
 		return 0;
-	mem = try_get_mem_cgroup_from_swapcache(page);
+	mem = try_get_mem_cgroup_from_page(page);
 	if (!mem)
 		goto charge_cur_mm;
 	*ptr = mem;
--- linux-mm.orig/include/linux/memcontrol.h	2009-08-31 15:41:50.000000000 +0800
+++ linux-mm/include/linux/memcontrol.h	2009-08-31 15:41:53.000000000 +0800
@@ -68,6 +68,7 @@ extern unsigned long mem_cgroup_isolate_
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
+extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
 static inline
@@ -189,6 +190,11 @@ mem_cgroup_move_lists(struct page *page,
 {
 }
 
+static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
+{
+	return NULL;
+}
+
 static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
 {
 	return 1;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
