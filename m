Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E16006B01F1
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 04:14:02 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7P8E3CO006661
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Aug 2010 17:14:03 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C61545DE51
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:14:03 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D95C845DE50
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:14:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B07431DB8015
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:14:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E1751DB8017
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:13:59 +0900 (JST)
Date: Wed, 25 Aug 2010 17:09:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/5] memcg: use ID instead of pointer in page_cgroup
Message-Id: <20100825170900.3feababc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
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

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |    6 ++++
 mm/memcontrol.c             |   53 ++++++++++++++++++++++++++++----------------
 mm/page_cgroup.c            |    2 -
 3 files changed, 40 insertions(+), 21 deletions(-)

Index: mmotm-0811/include/linux/page_cgroup.h
===================================================================
--- mmotm-0811.orig/include/linux/page_cgroup.h
+++ mmotm-0811/include/linux/page_cgroup.h
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
Index: mmotm-0811/mm/page_cgroup.c
===================================================================
--- mmotm-0811.orig/mm/page_cgroup.c
+++ mmotm-0811/mm/page_cgroup.c
@@ -15,7 +15,7 @@ static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
 {
 	pc->flags = 0;
-	pc->mem_cgroup = NULL;
+	pc->mem_cgroup = 0;
 	pc->page = pfn_to_page(pfn);
 	INIT_LIST_HEAD(&pc->lru);
 }
Index: mmotm-0811/mm/memcontrol.c
===================================================================
--- mmotm-0811.orig/mm/memcontrol.c
+++ mmotm-0811/mm/memcontrol.c
@@ -300,12 +300,16 @@ static atomic_t mem_cgroup_num;
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
 	/* see mem_cgroup_free() */
-	mem = rcu_dereference_check(mem_cgroups[id], rcu_read_lock_held());
+	mem = rcu_dereference_check(mem_cgroups[id],
+				rcu_read_lock_held() || safe);
 	if (likely(mem && mem->valid))
 		return mem;
 	return NULL;
@@ -381,7 +385,12 @@ struct cgroup_subsys_state *mem_cgroup_c
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
 
@@ -723,6 +732,11 @@ static inline bool mem_cgroup_is_root(st
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
@@ -755,7 +769,7 @@ void mem_cgroup_del_lru_list(struct page
 	 */
 	mz = page_cgroup_zoneinfo(pc);
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
-	if (mem_cgroup_is_root(pc->mem_cgroup))
+	if (mem_cgroup_is_rootid(pc->mem_cgroup))
 		return;
 	VM_BUG_ON(list_empty(&pc->lru));
 	list_del_init(&pc->lru);
@@ -782,7 +796,7 @@ void mem_cgroup_rotate_lru_list(struct p
 	 */
 	smp_rmb();
 	/* unused or root page is not rotated. */
-	if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
+	if (!PageCgroupUsed(pc) || mem_cgroup_is_rootid(pc->mem_cgroup))
 		return;
 	mz = page_cgroup_zoneinfo(pc);
 	list_move(&pc->lru, &mz->lists[lru]);
@@ -808,7 +822,7 @@ void mem_cgroup_add_lru_list(struct page
 	mz = page_cgroup_zoneinfo(pc);
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
 	SetPageCgroupAcctLRU(pc);
-	if (mem_cgroup_is_root(pc->mem_cgroup))
+	if (mem_cgroup_is_rootid(pc->mem_cgroup))
 		return;
 	list_add(&pc->lru, &mz->lists[lru]);
 }
@@ -1497,7 +1511,7 @@ void mem_cgroup_update_file_mapped(struc
 		return;
 
 	lock_page_cgroup(pc);
-	mem = pc->mem_cgroup;
+	mem = id_to_memcg(pc->mem_cgroup, true);
 	if (!mem || !PageCgroupUsed(pc))
 		goto done;
 
@@ -1885,14 +1899,14 @@ struct mem_cgroup *try_get_mem_cgroup_fr
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
@@ -1921,7 +1935,7 @@ static void __mem_cgroup_commit_charge(s
 		return;
 	}
 
-	pc->mem_cgroup = mem;
+	pc->mem_cgroup = css_id(&mem->css);
 	/*
 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
 	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
@@ -1979,7 +1993,7 @@ static void __mem_cgroup_move_account(st
 	VM_BUG_ON(PageLRU(pc->page));
 	VM_BUG_ON(!PageCgroupLocked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
-	VM_BUG_ON(pc->mem_cgroup != from);
+	VM_BUG_ON(id_to_memcg(pc->mem_cgroup, true) != from);
 
 	if (PageCgroupFileMapped(pc)) {
 		/* Update mapped_file data for mem_cgroup */
@@ -1994,7 +2008,7 @@ static void __mem_cgroup_move_account(st
 		mem_cgroup_cancel_charge(from);
 
 	/* caller should have done css_get */
-	pc->mem_cgroup = to;
+	pc->mem_cgroup = css_id(&to->css);
 	mem_cgroup_charge_statistics(to, pc, true);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
@@ -2014,7 +2028,7 @@ static int mem_cgroup_move_account(struc
 {
 	int ret = -EINVAL;
 	lock_page_cgroup(pc);
-	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
+	if (PageCgroupUsed(pc) && id_to_memcg(pc->mem_cgroup, true) == from) {
 		__mem_cgroup_move_account(pc, from, to, uncharge);
 		ret = 0;
 	}
@@ -2244,7 +2258,7 @@ __mem_cgroup_commit_charge_swapin(struct
 
 		id = swap_cgroup_record(ent, 0);
 		rcu_read_lock();
-		memcg = id_to_memcg(id);
+		memcg = id_to_memcg(id, false);
 		if (memcg) {
 			/*
 			 * This recorded memcg can be obsolete one. So, avoid
@@ -2354,7 +2368,7 @@ __mem_cgroup_uncharge_common(struct page
 
 	lock_page_cgroup(pc);
 
-	mem = pc->mem_cgroup;
+	mem = id_to_memcg(pc->mem_cgroup, true);
 
 	if (!PageCgroupUsed(pc))
 		goto unlock_out;
@@ -2509,7 +2523,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
 
 	id = swap_cgroup_record(ent, 0);
 	rcu_read_lock();
-	memcg = id_to_memcg(id);
+	memcg = id_to_memcg(id, false);
 	if (memcg) {
 		/*
 		 * We uncharge this because swap is freed.
@@ -2600,7 +2614,7 @@ int mem_cgroup_prepare_migration(struct 
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
-		mem = pc->mem_cgroup;
+		mem = id_to_memcg(pc->mem_cgroup, true);
 		css_get(&mem->css);
 		/*
 		 * At migrating an anonymous page, its mapcount goes down
@@ -4440,7 +4454,8 @@ static int is_target_pte_for_mc(struct v
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
