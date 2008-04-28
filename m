Date: Mon, 28 Apr 2008 20:32:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 8/8] memcg: inlining mem_cgroup_chage_statistics()
Message-Id: <20080428203245.97bb66c6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

I added mem_cgroup_charge_statistics() but this seems to add more
function calls. (compiler doesn't inline this ;) And maybe 
removing mem_cgroup_charge_statistics() is more straightforward and
easier to read.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   32 ++++++++++++++------------------
 1 file changed, 14 insertions(+), 18 deletions(-)

Index: mm-2.6.25-mm1/mm/memcontrol.c
===================================================================
--- mm-2.6.25-mm1.orig/mm/memcontrol.c
+++ mm-2.6.25-mm1/mm/memcontrol.c
@@ -185,22 +185,6 @@ enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
 };
 
-/*
- * Always modified under lru lock. Then, not necessary to preempt_disable()
- */
-static void mem_cgroup_charge_statistics(struct mem_cgroup *mem, int flags,
-					bool charge)
-{
-	int val = (charge)? 1 : -1;
-	struct mem_cgroup_stat *stat = &mem->stat;
-
-	VM_BUG_ON(!irqs_disabled());
-	if (flags & PAGE_CGROUP_FLAG_CACHE)
-		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, val);
-	else
-		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
-}
-
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 {
@@ -279,14 +263,20 @@ static void unlock_page_cgroup(struct pa
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
 			struct page_cgroup *pc)
 {
+	struct mem_cgroup_stat *stat = &pc->mem_cgroup->stat;
 	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
+	int cache = pc->flags & PAGE_CGROUP_FLAG_CACHE;
 
 	if (from)
 		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) -= 1;
 	else
 		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) -= 1;
 
-	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, false);
+	if (cache)
+		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, -1);
+	else
+		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, -1);
+
 	list_del(&pc->lru);
 }
 
@@ -294,6 +284,8 @@ static void __mem_cgroup_add_list(struct
 				struct page_cgroup *pc)
 {
 	int to = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
+	int cache =  pc->flags & PAGE_CGROUP_FLAG_CACHE;
+	struct mem_cgroup_stat *stat = &pc->mem_cgroup->stat;
 
 	if (!to) {
 		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE) += 1;
@@ -302,7 +294,11 @@ static void __mem_cgroup_add_list(struct
 		MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE) += 1;
 		list_add(&pc->lru, &mz->active_list);
 	}
-	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, true);
+
+	if (cache)
+		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, 1);
+	else
+		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, 1);
 }
 
 static void __mem_cgroup_move_lists(struct page_cgroup *pc, bool active)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
