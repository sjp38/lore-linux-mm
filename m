Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAEAMVCP017311
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 14 Nov 2008 19:22:32 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 66A9445DD7E
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:22:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 142CC45DD7A
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:22:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A943DE08004
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:22:30 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4622C1DB803C
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:22:30 +0900 (JST)
Date: Fri, 14 Nov 2008 19:21:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 9/9] memcg : add mem_cgroup_disabled()
Message-Id: <20081114192151.9185a2b4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, pbadari@us.ibm.com, jblunck@suse.de, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

We check mem_cgroup is disabled or not by checking mem_cgroup_subsys.disabled.
I think it has more references than expected, now.

replacing 
   if (mem_cgroup_subsys.disabled)
with
   if (mem_cgroup_disabled())

give us good look, I think.

From: Hirokazu Takahashi <taka@valinux.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/memcontrol.h |   13 +++++++++++++
 mm/memcontrol.c            |   28 ++++++++++++++--------------
 mm/page_cgroup.c           |    4 ++--
 3 files changed, 29 insertions(+), 16 deletions(-)

Index: mmotm-2.6.28-Nov13/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-Nov13.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-Nov13/include/linux/memcontrol.h
@@ -87,6 +87,14 @@ extern long mem_cgroup_calc_reclaim(stru
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
+
+static inline bool mem_cgroup_disabled(void)
+{
+	if (mem_cgroup_subsys.disabled)
+		return true;
+	return false;
+}
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -214,6 +222,11 @@ static inline long mem_cgroup_calc_recla
 {
 	return 0;
 }
+
+static inline bool mem_cgroup_disabled(void)
+{
+	return true;
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
Index: mmotm-2.6.28-Nov13/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Nov13.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Nov13/mm/memcontrol.c
@@ -278,7 +278,7 @@ void mem_cgroup_del_lru_list(struct page
 	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
 
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return;
 	pc = lookup_page_cgroup(page);
 	/* can happen while we handle swapcache. */
@@ -301,7 +301,7 @@ void mem_cgroup_rotate_lru_list(struct p
 	struct mem_cgroup_per_zone *mz;
 	struct page_cgroup *pc;
 
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_diabled())
 		return;
 
 	pc = lookup_page_cgroup(page);
@@ -318,7 +318,7 @@ void mem_cgroup_add_lru_list(struct page
 	struct page_cgroup *pc;
 	struct mem_cgroup_per_zone *mz;
 
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return;
 	pc = lookup_page_cgroup(page);
 	/* barrier to sync with "charge" */
@@ -343,7 +343,7 @@ static void mem_cgroup_lru_fixup(struct 
 void mem_cgroup_move_lists(struct page *page,
 			   enum lru_list from, enum lru_list to)
 {
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return;
 	mem_cgroup_del_lru_list(page, from);
 	mem_cgroup_add_lru_list(page, to);
@@ -730,7 +730,7 @@ static int mem_cgroup_charge_common(stru
 int mem_cgroup_newpage_charge(struct page *page,
 			      struct mm_struct *mm, gfp_t gfp_mask)
 {
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return 0;
 	if (PageCompound(page))
 		return 0;
@@ -752,7 +752,7 @@ int mem_cgroup_newpage_charge(struct pag
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return 0;
 	if (PageCompound(page))
 		return 0;
@@ -798,7 +798,7 @@ int mem_cgroup_try_charge_swapin(struct 
 	struct mem_cgroup *mem;
 	swp_entry_t     ent;
 
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return 0;
 
 	if (!do_swap_account)
@@ -824,7 +824,7 @@ int mem_cgroup_cache_charge_swapin(struc
 {
 	int ret = 0;
 
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return 0;
 	if (unlikely(!mm))
 		mm = &init_mm;
@@ -871,7 +871,7 @@ void mem_cgroup_commit_charge_swapin(str
 {
 	struct page_cgroup *pc;
 
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return;
 	if (!ptr)
 		return;
@@ -900,7 +900,7 @@ void mem_cgroup_commit_charge_swapin(str
 
 void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
 {
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return;
 	if (!mem)
 		return;
@@ -921,7 +921,7 @@ __mem_cgroup_uncharge_common(struct page
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
 
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return NULL;
 
 	if (PageSwapCache(page))
@@ -1040,7 +1040,7 @@ int mem_cgroup_prepare_migration(struct 
 	struct mem_cgroup *mem = NULL;
 	int ret = 0;
 
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return 0;
 
 	pc = lookup_page_cgroup(page);
@@ -1122,7 +1122,7 @@ int mem_cgroup_shrink_usage(struct mm_st
 	int progress = 0;
 	int retry = MEM_CGROUP_RECLAIM_RETRIES;
 
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return 0;
 	if (!mm)
 		return 0;
@@ -1675,7 +1675,7 @@ static void mem_cgroup_put(struct mem_cg
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 static void __init enable_swap_cgroup(void)
 {
-	if (!mem_cgroup_subsys.disabled && really_do_swap_account)
+	if (!mem_cgroup_disabled() && really_do_swap_account)
 		do_swap_account = 1;
 }
 #else
Index: mmotm-2.6.28-Nov13/mm/page_cgroup.c
===================================================================
--- mmotm-2.6.28-Nov13.orig/mm/page_cgroup.c
+++ mmotm-2.6.28-Nov13/mm/page_cgroup.c
@@ -72,7 +72,7 @@ void __init page_cgroup_init(void)
 
 	int nid, fail;
 
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return;
 
 	for_each_online_node(nid)  {
@@ -244,7 +244,7 @@ void __init page_cgroup_init(void)
 	unsigned long pfn;
 	int fail = 0;
 
-	if (mem_cgroup_subsys.disabled)
+	if (mem_cgroup_disabled())
 		return;
 
 	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
