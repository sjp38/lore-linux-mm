Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ECBC3600044
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 04:01:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6R81EKr008110
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Jul 2010 17:01:14 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A5E7745DE6E
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:01:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AFB245DE6F
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:01:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4441DE38002
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:01:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C5E1E38006
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:01:13 +0900 (JST)
Date: Tue, 27 Jul 2010 16:56:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/7][memcg] memcg use ID in page_cgroup
Message-Id: <20100727165629.6f98145c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, addresses of memory cgroup can be calculated by their ID without complex.
This patch relplaces pc->mem_cgroup from a pointer to a unsigned short.
On 64bit architecture, this offers us more 6bytes room per page_cgroup.
Use 2bytes for blkio-cgroup's page tracking. More 4bytes will be used for
some light-weight concurrent access.

We may able to move this id onto flags field but ...go step by step.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |    3 ++-
 mm/memcontrol.c             |   40 +++++++++++++++++++++++++---------------
 mm/page_cgroup.c            |    2 +-
 3 files changed, 28 insertions(+), 17 deletions(-)

Index: mmotm-0719/include/linux/page_cgroup.h
===================================================================
--- mmotm-0719.orig/include/linux/page_cgroup.h
+++ mmotm-0719/include/linux/page_cgroup.h
@@ -12,7 +12,8 @@
  */
 struct page_cgroup {
 	unsigned long flags;
-	struct mem_cgroup *mem_cgroup;
+	unsigned short mem_cgroup;	/* ID of assigned memory cgroup */
+	unsigned short blk_cgroup;	/* Not Used..but will be. */
 	struct page *page;
 	struct list_head lru;		/* per cgroup LRU list */
 };
Index: mmotm-0719/mm/page_cgroup.c
===================================================================
--- mmotm-0719.orig/mm/page_cgroup.c
+++ mmotm-0719/mm/page_cgroup.c
@@ -14,7 +14,7 @@ static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
 {
 	pc->flags = 0;
-	pc->mem_cgroup = NULL;
+	pc->mem_cgroup = 0;
 	pc->page = pfn_to_page(pfn);
 	INIT_LIST_HEAD(&pc->lru);
 }
Index: mmotm-0719/mm/memcontrol.c
===================================================================
--- mmotm-0719.orig/mm/memcontrol.c
+++ mmotm-0719/mm/memcontrol.c
@@ -372,7 +372,7 @@ struct cgroup_subsys_state *mem_cgroup_c
 static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {
-	struct mem_cgroup *mem = pc->mem_cgroup;
+	struct mem_cgroup *mem = id_to_mem(pc->mem_cgroup);
 	int nid = page_cgroup_nid(pc);
 	int zid = page_cgroup_zid(pc);
 
@@ -577,7 +577,11 @@ static void mem_cgroup_charge_statistics
 					 bool charge)
 {
 	int val = (charge) ? 1 : -1;
-
+	if (pc->mem_cgroup == 0) {
+		show_stack(NULL, NULL);
+		printk("charge to 0\n");
+		while(1);
+	}
 	preempt_disable();
 
 	if (PageCgroupCache(pc))
@@ -714,6 +718,11 @@ static inline bool mem_cgroup_is_root(st
 	return (mem == root_mem_cgroup);
 }
 
+static inline bool mem_cgroup_is_rootid(unsigned short id)
+{
+	return (id == 1);
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -746,7 +755,7 @@ void mem_cgroup_del_lru_list(struct page
 	 */
 	mz = page_cgroup_zoneinfo(pc);
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
-	if (mem_cgroup_is_root(pc->mem_cgroup))
+	if (mem_cgroup_is_rootid(pc->mem_cgroup))
 		return;
 	VM_BUG_ON(list_empty(&pc->lru));
 	list_del_init(&pc->lru);
@@ -773,7 +782,7 @@ void mem_cgroup_rotate_lru_list(struct p
 	 */
 	smp_rmb();
 	/* unused or root page is not rotated. */
-	if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
+	if (!PageCgroupUsed(pc) || mem_cgroup_is_rootid(pc->mem_cgroup))
 		return;
 	mz = page_cgroup_zoneinfo(pc);
 	list_move(&pc->lru, &mz->lists[lru]);
@@ -799,7 +808,7 @@ void mem_cgroup_add_lru_list(struct page
 	mz = page_cgroup_zoneinfo(pc);
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
 	SetPageCgroupAcctLRU(pc);
-	if (mem_cgroup_is_root(pc->mem_cgroup))
+	if (mem_cgroup_is_rootid(pc->mem_cgroup))
 		return;
 	list_add(&pc->lru, &mz->lists[lru]);
 }
@@ -1467,7 +1476,7 @@ void mem_cgroup_update_file_mapped(struc
 		return;
 
 	lock_page_cgroup(pc);
-	mem = pc->mem_cgroup;
+	mem = id_to_mem(pc->mem_cgroup);
 	if (!mem || !PageCgroupUsed(pc))
 		goto done;
 
@@ -1848,7 +1857,7 @@ struct mem_cgroup *try_get_mem_cgroup_fr
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		mem = pc->mem_cgroup;
+		mem = id_to_mem(pc->mem_cgroup);
 		if (mem && !css_tryget(&mem->css))
 			mem = NULL;
 	} else if (PageSwapCache(page)) {
@@ -1884,7 +1893,7 @@ static void __mem_cgroup_commit_charge(s
 		return;
 	}
 
-	pc->mem_cgroup = mem;
+	pc->mem_cgroup = css_id(&mem->css);
 	/*
 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
 	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
@@ -1942,7 +1951,7 @@ static void __mem_cgroup_move_account(st
 	VM_BUG_ON(PageLRU(pc->page));
 	VM_BUG_ON(!PageCgroupLocked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
-	VM_BUG_ON(pc->mem_cgroup != from);
+	VM_BUG_ON(id_to_mem(pc->mem_cgroup) != from);
 
 	if (PageCgroupFileMapped(pc)) {
 		/* Update mapped_file data for mem_cgroup */
@@ -1957,7 +1966,7 @@ static void __mem_cgroup_move_account(st
 		mem_cgroup_cancel_charge(from);
 
 	/* caller should have done css_get */
-	pc->mem_cgroup = to;
+	pc->mem_cgroup = css_id(&to->css);
 	mem_cgroup_charge_statistics(to, pc, true);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
@@ -1977,7 +1986,7 @@ static int mem_cgroup_move_account(struc
 {
 	int ret = -EINVAL;
 	lock_page_cgroup(pc);
-	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
+	if (PageCgroupUsed(pc) && id_to_mem(pc->mem_cgroup) == from) {
 		__mem_cgroup_move_account(pc, from, to, uncharge);
 		ret = 0;
 	}
@@ -2316,9 +2325,9 @@ __mem_cgroup_uncharge_common(struct page
 
 	lock_page_cgroup(pc);
 
-	mem = pc->mem_cgroup;
+	mem = id_to_mem(pc->mem_cgroup);
 
-	if (!PageCgroupUsed(pc))
+	if (!mem || !PageCgroupUsed(pc))
 		goto unlock_out;
 
 	switch (ctype) {
@@ -2561,7 +2570,7 @@ int mem_cgroup_prepare_migration(struct 
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		mem = pc->mem_cgroup;
+		mem = id_to_mem(pc->mem_cgroup);
 		css_get(&mem->css);
 		/*
 		 * At migrating an anonymous page, its mapcount goes down
@@ -4384,7 +4393,8 @@ static int is_target_pte_for_mc(struct v
 		 * mem_cgroup_move_account() checks the pc is valid or not under
 		 * the lock.
 		 */
-		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+		if (PageCgroupUsed(pc) &&
+			id_to_mem(pc->mem_cgroup) == mc.from) {
 			ret = MC_TARGET_PAGE;
 			if (target)
 				target->page = page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
