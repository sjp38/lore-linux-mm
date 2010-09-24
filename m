Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8166D6B004A
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 05:21:50 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8O9LnXP023445
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 24 Sep 2010 18:21:49 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D283C45DE51
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:21:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B1D0B45DE4F
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:21:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 97D371DB803B
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:21:48 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 46AD21DB8038
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:21:48 +0900 (JST)
Date: Fri, 24 Sep 2010 18:16:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/2] memcg: use ID instead of pointer
Message-Id: <20100924181637.a763c4e5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100924181302.7d764e0d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100924181302.7d764e0d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

replaces page_cgroup->mem_cgroup to be an unsigned short.
And add an ID for blkio cgroup.

More work will be required for reducing sturct page_cgroup size,
but maybe good as 1st step.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |    3 ++-
 mm/memcontrol.c             |   34 ++++++++++++++++++++--------------
 mm/page_cgroup.c            |    2 +-
 3 files changed, 23 insertions(+), 16 deletions(-)

Index: mmotm-0922/include/linux/page_cgroup.h
===================================================================
--- mmotm-0922.orig/include/linux/page_cgroup.h
+++ mmotm-0922/include/linux/page_cgroup.h
@@ -12,7 +12,8 @@
  */
 struct page_cgroup {
 	unsigned long flags;
-	struct mem_cgroup *mem_cgroup;
+	unsigned short mem_cgroup;
+	unsigned short blkio_cgroup;
 	struct page *page;
 	struct list_head lru;		/* per cgroup LRU list */
 };
Index: mmotm-0922/mm/memcontrol.c
===================================================================
--- mmotm-0922.orig/mm/memcontrol.c
+++ mmotm-0922/mm/memcontrol.c
@@ -427,7 +427,7 @@ struct cgroup_subsys_state *mem_cgroup_c
 static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {
-	struct mem_cgroup *mem = pc->mem_cgroup;
+	struct mem_cgroup *mem = memcg_lookup(pc->mem_cgroup);
 	int nid = page_cgroup_nid(pc);
 	int zid = page_cgroup_zid(pc);
 
@@ -838,6 +838,11 @@ static inline bool mem_cgroup_is_root(st
 	return (mem == root_mem_cgroup);
 }
 
+static inline bool mem_cgroup_id_is_root(unsigned short id)
+{
+	return (id == 1);
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -870,7 +875,7 @@ void mem_cgroup_del_lru_list(struct page
 	 */
 	mz = page_cgroup_zoneinfo(pc);
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
-	if (mem_cgroup_is_root(pc->mem_cgroup))
+	if (mem_cgroup_id_is_root(pc->mem_cgroup))
 		return;
 	VM_BUG_ON(list_empty(&pc->lru));
 	list_del_init(&pc->lru);
@@ -897,7 +902,7 @@ void mem_cgroup_rotate_lru_list(struct p
 	 */
 	smp_rmb();
 	/* unused or root page is not rotated. */
-	if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
+	if (!PageCgroupUsed(pc) || mem_cgroup_id_is_root(pc->mem_cgroup))
 		return;
 	mz = page_cgroup_zoneinfo(pc);
 	list_move(&pc->lru, &mz->lists[lru]);
@@ -923,7 +928,7 @@ void mem_cgroup_add_lru_list(struct page
 	mz = page_cgroup_zoneinfo(pc);
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
 	SetPageCgroupAcctLRU(pc);
-	if (mem_cgroup_is_root(pc->mem_cgroup))
+	if (mem_cgroup_id_is_root(pc->mem_cgroup))
 		return;
 	list_add(&pc->lru, &mz->lists[lru]);
 }
@@ -1663,7 +1668,7 @@ static void mem_cgroup_update_file_stat(
 		return;
 
 	rcu_read_lock();
-	mem = pc->mem_cgroup;
+	mem = memcg_lookup(pc->mem_cgroup);
 	if (unlikely(!mem || !PageCgroupUsed(pc)))
 		goto out;
 	/* pc->mem_cgroup is unstable ? */
@@ -1671,7 +1676,7 @@ static void mem_cgroup_update_file_stat(
 		/* take a lock against to access pc->mem_cgroup */
 		lock_page_cgroup(pc);
 		need_unlock = true;
-		mem = pc->mem_cgroup;
+		mem = memcg_lookup(pc->mem_cgroup);
 		if (!mem || !PageCgroupUsed(pc))
 			goto out;
 	}
@@ -2121,7 +2126,7 @@ struct mem_cgroup *try_get_mem_cgroup_fr
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		mem = pc->mem_cgroup;
+		mem = memcg_lookup(pc->mem_cgroup);
 		if (mem && !css_tryget(&mem->css))
 			mem = NULL;
 	} else if (PageSwapCache(page)) {
@@ -2158,7 +2163,7 @@ static void __mem_cgroup_commit_charge(s
 	}
 	memcg_lookup_set(mem);
 
-	pc->mem_cgroup = mem;
+	pc->mem_cgroup = css_id(&mem->css);
 	/*
 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
 	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
@@ -2216,7 +2221,7 @@ static void __mem_cgroup_move_account(st
 	VM_BUG_ON(PageLRU(pc->page));
 	VM_BUG_ON(!PageCgroupLocked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
-	VM_BUG_ON(pc->mem_cgroup != from);
+	VM_BUG_ON(pc->mem_cgroup != css_id(&from->css));
 
 	if (PageCgroupFileMapped(pc)) {
 		/* Update mapped_file data for mem_cgroup */
@@ -2231,7 +2236,7 @@ static void __mem_cgroup_move_account(st
 		mem_cgroup_cancel_charge(from);
 
 	/* caller should have done css_get */
-	pc->mem_cgroup = to;
+	pc->mem_cgroup = css_id(&to->css);
 	mem_cgroup_charge_statistics(to, pc, true);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
@@ -2251,7 +2256,7 @@ static int mem_cgroup_move_account(struc
 {
 	int ret = -EINVAL;
 	lock_page_cgroup(pc);
-	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
+	if (PageCgroupUsed(pc) && pc->mem_cgroup == css_id(&from->css)) {
 		__mem_cgroup_move_account(pc, from, to, uncharge);
 		ret = 0;
 	}
@@ -2590,7 +2595,7 @@ __mem_cgroup_uncharge_common(struct page
 
 	lock_page_cgroup(pc);
 
-	mem = pc->mem_cgroup;
+	mem = memcg_lookup(pc->mem_cgroup);
 
 	if (!PageCgroupUsed(pc))
 		goto unlock_out;
@@ -2835,7 +2840,7 @@ int mem_cgroup_prepare_migration(struct 
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		mem = pc->mem_cgroup;
+		mem = memcg_lookup(pc->mem_cgroup);
 		css_get(&mem->css);
 		/*
 		 * At migrating an anonymous page, its mapcount goes down
@@ -4652,7 +4657,8 @@ static int is_target_pte_for_mc(struct v
 		 * mem_cgroup_move_account() checks the pc is valid or not under
 		 * the lock.
 		 */
-		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+		if (PageCgroupUsed(pc) &&
+			pc->mem_cgroup == css_id(&mc.from->css)) {
 			ret = MC_TARGET_PAGE;
 			if (target)
 				target->page = page;
Index: mmotm-0922/mm/page_cgroup.c
===================================================================
--- mmotm-0922.orig/mm/page_cgroup.c
+++ mmotm-0922/mm/page_cgroup.c
@@ -15,7 +15,7 @@ static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
 {
 	pc->flags = 0;
-	pc->mem_cgroup = NULL;
+	pc->mem_cgroup = 0;
 	pc->page = pfn_to_page(pfn);
 	INIT_LIST_HEAD(&pc->lru);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
