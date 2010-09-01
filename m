Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A18616B0083
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 02:48:51 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o816mnPv021476
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Sep 2010 15:48:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 366FF45DE51
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:48:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 129C745DE4E
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:48:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E43111DB8045
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:48:48 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93B311DB804A
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:48:48 +0900 (JST)
Date: Wed, 1 Sep 2010 15:43:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/5] memcg: use ID in page cgroup
Message-Id: <20100901154349.70f8f207.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100901153951.bc82c021.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100901153951.bc82c021.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, gthelen@google.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, menage@google.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, addresses of memory cgroup can be calculated by their ID without complex.
This patch relplaces pc->mem_cgroup from a pointer to a unsigned short.
On 64bit architecture, this offers us more 6bytes room per page_cgroup.
Use 2bytes for blkio-cgroup's page tracking. More 4bytes will be used for
some light-weight concurrent access.

We may able to move this id onto flags field but ...go step by step.

Changelog: 20100824
 - fixed comments, and typo.
Changelog: 20100811
 - using new rcu APIs, as rcu_dereference_check() etc.
Changelog: 20100804
 - added comments to page_cgroup.h
Changelog: 20100730
 - fixed some garbage added by debug code in early stage

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |    6 ++++
 mm/memcontrol.c             |   53 ++++++++++++++++++++++++++++----------------
 mm/page_cgroup.c            |    2 -
 3 files changed, 40 insertions(+), 21 deletions(-)

Index: mmotm-0827/include/linux/page_cgroup.h
===================================================================
--- mmotm-0827.orig/include/linux/page_cgroup.h
+++ mmotm-0827/include/linux/page_cgroup.h
@@ -9,10 +9,14 @@
  * page_cgroup helps us identify information about the cgroup
  * All page cgroups are allocated at boot or memory hotplug event,
  * then the page cgroup for pfn always exists.
+ *
+ * TODO: It seems ID for cgroup can be packed into "flags". But there will
+ * be race between assigning ID <-> set/clear flags. Please be careful.
  */
 struct page_cgroup {
 	unsigned long flags;
-	struct mem_cgroup *mem_cgroup;
+	unsigned short mem_cgroup;	/* ID of assigned memory cgroup */
+	unsigned short blk_cgroup;	/* Not Used..but will be. */
 	struct page *page;
 	struct list_head lru;		/* per cgroup LRU list */
 };
Index: mmotm-0827/mm/page_cgroup.c
===================================================================
--- mmotm-0827.orig/mm/page_cgroup.c
+++ mmotm-0827/mm/page_cgroup.c
@@ -15,7 +15,7 @@ static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
 {
 	pc->flags = 0;
-	pc->mem_cgroup = NULL;
+	pc->mem_cgroup = 0;
 	pc->page = pfn_to_page(pfn);
 	INIT_LIST_HEAD(&pc->lru);
 }
Index: mmotm-0827/mm/memcontrol.c
===================================================================
--- mmotm-0827.orig/mm/memcontrol.c
+++ mmotm-0827/mm/memcontrol.c
@@ -299,11 +299,15 @@ static atomic_t mem_cgroup_num;
 #define NR_MEMCG_GROUPS (CONFIG_MEM_CGROUP_MAX_GROUPS + 1)
 static struct mem_cgroup *mem_cgroups[NR_MEMCG_GROUPS] __read_mostly;
 
-/* Must be called under rcu_read_lock */
-static struct mem_cgroup *id_to_memcg(unsigned short id)
+/*
+ * Must be called under rcu_read_lock, Set safe==true if you're sure
+ * you're in safe condition...under lock_page_cgroup() etc.
+ */
+static struct mem_cgroup *id_to_memcg(unsigned short id, bool safe)
 {
 	struct mem_cgroup *mem;
-	mem = rcu_dereference_check(mem_cgroups[id], rcu_read_lock_held());
+	mem = rcu_dereference_check(mem_cgroups[id],
+				rcu_read_lock_held() || safe);
 	return mem;
 }
 
@@ -384,7 +388,12 @@ struct cgroup_subsys_state *mem_cgroup_c
 static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {
-	struct mem_cgroup *mem = pc->mem_cgroup;
+	/*
+	 * The caller should guarantee this "pc" is under lock. In typical
+	 * case, this function is called by lru function with zone->lru_lock.
+	 * It is a safe access.
+	 */
+	struct mem_cgroup *mem = id_to_memcg(pc->mem_cgroup, true);
 	int nid = page_cgroup_nid(pc);
 	int zid = page_cgroup_zid(pc);
 
@@ -726,6 +735,11 @@ static inline bool mem_cgroup_is_root(st
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
@@ -758,7 +772,7 @@ void mem_cgroup_del_lru_list(struct page
 	 */
 	mz = page_cgroup_zoneinfo(pc);
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
-	if (mem_cgroup_is_root(pc->mem_cgroup))
+	if (mem_cgroup_is_rootid(pc->mem_cgroup))
 		return;
 	VM_BUG_ON(list_empty(&pc->lru));
 	list_del_init(&pc->lru);
@@ -785,7 +799,7 @@ void mem_cgroup_rotate_lru_list(struct p
 	 */
 	smp_rmb();
 	/* unused or root page is not rotated. */
-	if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
+	if (!PageCgroupUsed(pc) || mem_cgroup_is_rootid(pc->mem_cgroup))
 		return;
 	mz = page_cgroup_zoneinfo(pc);
 	list_move(&pc->lru, &mz->lists[lru]);
@@ -811,7 +825,7 @@ void mem_cgroup_add_lru_list(struct page
 	mz = page_cgroup_zoneinfo(pc);
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
 	SetPageCgroupAcctLRU(pc);
-	if (mem_cgroup_is_root(pc->mem_cgroup))
+	if (mem_cgroup_is_rootid(pc->mem_cgroup))
 		return;
 	list_add(&pc->lru, &mz->lists[lru]);
 }
@@ -1500,7 +1514,7 @@ void mem_cgroup_update_file_mapped(struc
 		return;
 
 	lock_page_cgroup(pc);
-	mem = pc->mem_cgroup;
+	mem = id_to_memcg(pc->mem_cgroup, true);
 	if (!mem || !PageCgroupUsed(pc))
 		goto done;
 
@@ -1888,14 +1902,14 @@ struct mem_cgroup *try_get_mem_cgroup_fr
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		mem = pc->mem_cgroup;
+		mem = id_to_memcg(pc->mem_cgroup, true);
 		if (mem && !css_tryget(&mem->css))
 			mem = NULL;
 	} else if (PageSwapCache(page)) {
 		ent.val = page_private(page);
 		id = lookup_swap_cgroup(ent);
 		rcu_read_lock();
-		mem = id_to_memcg(id);
+		mem = id_to_memcg(id, false);
 		if (mem && !css_tryget(&mem->css))
 			mem = NULL;
 		rcu_read_unlock();
@@ -1924,7 +1938,7 @@ static void __mem_cgroup_commit_charge(s
 		return;
 	}
 
-	pc->mem_cgroup = mem;
+	pc->mem_cgroup = css_id(&mem->css);
 	/*
 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
 	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
@@ -1982,7 +1996,7 @@ static void __mem_cgroup_move_account(st
 	VM_BUG_ON(PageLRU(pc->page));
 	VM_BUG_ON(!PageCgroupLocked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
-	VM_BUG_ON(pc->mem_cgroup != from);
+	VM_BUG_ON(id_to_memcg(pc->mem_cgroup, true) != from);
 
 	if (PageCgroupFileMapped(pc)) {
 		/* Update mapped_file data for mem_cgroup */
@@ -1997,7 +2011,7 @@ static void __mem_cgroup_move_account(st
 		mem_cgroup_cancel_charge(from);
 
 	/* caller should have done css_get */
-	pc->mem_cgroup = to;
+	pc->mem_cgroup = css_id(&to->css);
 	mem_cgroup_charge_statistics(to, pc, true);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
@@ -2017,7 +2031,7 @@ static int mem_cgroup_move_account(struc
 {
 	int ret = -EINVAL;
 	lock_page_cgroup(pc);
-	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
+	if (PageCgroupUsed(pc) && id_to_memcg(pc->mem_cgroup, true) == from) {
 		__mem_cgroup_move_account(pc, from, to, uncharge);
 		ret = 0;
 	}
@@ -2247,7 +2261,7 @@ __mem_cgroup_commit_charge_swapin(struct
 
 		id = swap_cgroup_record(ent, 0);
 		rcu_read_lock();
-		memcg = id_to_memcg(id);
+		memcg = id_to_memcg(id, false);
 		if (memcg) {
 			/*
 			 * This recorded memcg can be obsolete one. So, avoid
@@ -2357,7 +2371,7 @@ __mem_cgroup_uncharge_common(struct page
 
 	lock_page_cgroup(pc);
 
-	mem = pc->mem_cgroup;
+	mem = id_to_memcg(pc->mem_cgroup, true);
 
 	if (!PageCgroupUsed(pc))
 		goto unlock_out;
@@ -2512,7 +2526,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
 
 	id = swap_cgroup_record(ent, 0);
 	rcu_read_lock();
-	memcg = id_to_memcg(id);
+	memcg = id_to_memcg(id, false);
 	if (memcg) {
 		/*
 		 * We uncharge this because swap is freed.
@@ -2603,7 +2617,7 @@ int mem_cgroup_prepare_migration(struct 
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		mem = pc->mem_cgroup;
+		mem = id_to_memcg(pc->mem_cgroup, true);
 		css_get(&mem->css);
 		/*
 		 * At migrating an anonymous page, its mapcount goes down
@@ -4436,7 +4450,8 @@ static int is_target_pte_for_mc(struct v
 		 * mem_cgroup_move_account() checks the pc is valid or not under
 		 * the lock.
 		 */
-		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+		if (PageCgroupUsed(pc) &&
+			id_to_memcg(pc->mem_cgroup, true) == mc.from) {
 			ret = MC_TARGET_PAGE;
 			if (target)
 				target->page = page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
