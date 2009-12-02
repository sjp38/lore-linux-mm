From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 19/24] memcg: rename and export try_get_mem_cgroup_from_page()
Date: Wed, 02 Dec 2009 11:12:50 +0800
Message-ID: <20091202043046.127781753@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0B1416007BF
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:38 -0500 (EST)
Content-Disposition: inline; filename=memcg-try_get_mem_cgroup_from_page.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

So that the hwpoison injector can get mem_cgroup for arbitrary page
and thus know whether it is owned by some mem_cgroup task(s).

CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/memcontrol.h |    6 ++++++
 mm/memcontrol.c            |   11 ++++-------
 2 files changed, 10 insertions(+), 7 deletions(-)

--- linux-mm.orig/mm/memcontrol.c	2009-11-02 10:18:42.000000000 +0800
+++ linux-mm/mm/memcontrol.c	2009-11-02 10:26:21.000000000 +0800
@@ -1379,25 +1379,22 @@ static struct mem_cgroup *mem_cgroup_loo
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
@@ -1742,7 +1739,7 @@ int mem_cgroup_try_charge_swapin(struct 
 	 */
 	if (!PageSwapCache(page))
 		return 0;
-	mem = try_get_mem_cgroup_from_swapcache(page);
+	mem = try_get_mem_cgroup_from_page(page);
 	if (!mem)
 		goto charge_cur_mm;
 	*ptr = mem;
--- linux-mm.orig/include/linux/memcontrol.h	2009-11-02 10:18:42.000000000 +0800
+++ linux-mm/include/linux/memcontrol.h	2009-11-02 10:26:21.000000000 +0800
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
