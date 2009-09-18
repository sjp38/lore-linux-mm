Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 41D836B00C4
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 05:06:25 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8I96Pws011713
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Sep 2009 18:06:25 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 31D2545DE55
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:06:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D232C45DE4F
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:06:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 716368F8009
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:06:22 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 00B7F8F8006
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:06:22 +0900 (JST)
Date: Fri, 18 Sep 2009 18:04:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 10/11][mmotm] memcg: clean up percpu and more
 commentary for soft limit
Message-Id: <20090918180419.fc511373.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
	<20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

yes, should be separeted to 2 patches...

==
This patch does
  - adds some commentary on softlimit codes.
  - moves per-cpu statitics code right after percpu stat functions.

Signed-off-by: KAMEZAWA Hiroyuki  <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  161 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 97 insertions(+), 64 deletions(-)

Index: mmotm-2.6.31-Sep17/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep17.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep17/mm/memcontrol.c
@@ -56,7 +56,7 @@ static int really_do_swap_account __init
 #endif
 
 static DEFINE_MUTEX(memcg_tasklist);	/* can be hold under cgroup_mutex */
-#define SOFTLIMIT_EVENTS_THRESH (1000)
+
 
 /*
  * Statistics for memory cgroup. accounted per cpu.
@@ -118,8 +118,9 @@ struct mem_cgroup_lru_info {
 };
 
 /*
- * Cgroups above their limits are maintained in a RB-Tree, independent of
- * their hierarchy representation
+ * Cgroups above their soft-limits are maintained in a RB-Tree, independent of
+ * their hierarchy representation. This RB-tree is system-wide but maintained
+ * per zone.
  */
 
 struct mem_cgroup_tree_per_zone {
@@ -415,6 +416,70 @@ static s64 mem_cgroup_local_usage(struct
 }
 
 
+static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
+					 bool charge)
+{
+	int val = (charge) ? 1 : -1;
+	mem_cgroup_stat_add_local(mem, MEM_CGROUP_STAT_SWAPOUT, val);
+}
+
+static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
+					 struct page_cgroup *pc,
+					 bool charge)
+{
+	int val = (charge) ? 1 : -1;
+	struct mem_cgroup_stat *stat = &mem->stat;
+	struct mem_cgroup_stat_cpu *cstat;
+	int cpu = get_cpu();
+	/* for fast access, we use open-coded manner */
+	cstat = &stat->cpustat[cpu];
+	if (PageCgroupCache(pc))
+		__mem_cgroup_stat_add_local(cstat, MEM_CGROUP_STAT_CACHE, val);
+	else
+		__mem_cgroup_stat_add_local(cstat, MEM_CGROUP_STAT_RSS, val);
+
+	if (charge)
+		__mem_cgroup_stat_add_local(cstat,
+				MEM_CGROUP_STAT_PGPGIN_COUNT, 1);
+	else
+		__mem_cgroup_stat_add_local(cstat,
+				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
+	__mem_cgroup_stat_add_local(cstat, MEM_CGROUP_STAT_EVENTS, 1);
+	put_cpu();
+}
+
+/*
+ * Currently used to update mapped file statistics, but the routine can be
+ * generalized to update other statistics as well.
+ */
+void mem_cgroup_update_mapped_file_stat(struct page *page, int val)
+{
+	struct mem_cgroup *mem;
+	struct page_cgroup *pc;
+
+	if (!page_is_file_cache(page))
+		return;
+
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
+		return;
+
+	lock_page_cgroup(pc);
+	mem = pc->mem_cgroup;
+	if (!mem)
+		goto done;
+
+	if (!PageCgroupUsed(pc))
+		goto done;
+
+	mem_cgroup_stat_add_local(mem, MEM_CGROUP_STAT_MAPPED_FILE, val);
+done:
+	unlock_page_cgroup(pc);
+}
+
+/*
+ * For per-zone statistics.
+ */
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 {
@@ -460,6 +525,17 @@ static unsigned long mem_cgroup_get_zone
 	return total;
 }
 
+/*
+ * Followings are functions for per-zone memcg softlimit RB-tree management.
+ * Tree is system-wide but maintained per zone.
+ */
+
+/*
+ * Soft limit uses percpu event counter for status check instead of checking
+ * status at every charge/uncharge.
+ */
+#define SOFTLIMIT_EVENTS_THRESH (1000)
+
 static struct mem_cgroup_tree_per_zone *
 soft_limit_tree_node_zone(int nid, int zid)
 {
@@ -472,9 +548,14 @@ soft_limit_tree_from_page(struct page *p
 	int nid = page_to_nid(page);
 	int zid = page_zonenum(page);
 
-	return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_zone[zid];
+	return soft_limit_tree_node_zone(nid, zid);
 }
 
+/*
+ * Insert memcg's per-zone struct onto softlimit RB-tree. For inserting,
+ * mz should be not on tree. Tree-lock is held before calling this.
+ * tree lock (mctz->lock) should be held.
+ */
 static void
 __mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
 				struct mem_cgroup_per_zone *mz,
@@ -530,6 +611,10 @@ mem_cgroup_remove_exceeded(struct mem_cg
 	spin_unlock(&mctz->lock);
 }
 
+/*
+ * Check per-cpu EVENT COUNTER. If it's over threshold, we check
+ * how memory uasge exceeds softlimit and update tree.
+ */
 static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
 {
 	bool ret = false;
@@ -543,6 +628,11 @@ static bool mem_cgroup_soft_limit_check(
 	return ret;
 }
 
+/*
+ * This function updates soft-limit RB-tree by checking "excess" of
+ * memcgs. When hierarchy is used, all ancestors have to be updated, too.
+ */
+
 static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
 {
 	unsigned long long excess;
@@ -598,6 +688,9 @@ static inline unsigned long mem_cgroup_g
 	return res_counter_soft_limit_excess(&mem->res) >> PAGE_SHIFT;
 }
 
+/*
+ * Check RB-tree of a zone and find a memcg which has the largest "excess"
+ */
 static struct mem_cgroup_per_zone *
 __mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
 {
@@ -634,38 +727,6 @@ mem_cgroup_largest_soft_limit_node(struc
 	return mz;
 }
 
-static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
-					 bool charge)
-{
-	int val = (charge) ? 1 : -1;
-	mem_cgroup_stat_add_local(mem, MEM_CGROUP_STAT_SWAPOUT, val);
-}
-
-static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
-					 struct page_cgroup *pc,
-					 bool charge)
-{
-	int val = (charge) ? 1 : -1;
-	struct mem_cgroup_stat *stat = &mem->stat;
-	struct mem_cgroup_stat_cpu *cstat;
-	int cpu = get_cpu();
-	/* for fast access, we use open-coded manner */
-	cstat = &stat->cpustat[cpu];
-	if (PageCgroupCache(pc))
-		__mem_cgroup_stat_add_local(cstat, MEM_CGROUP_STAT_CACHE, val);
-	else
-		__mem_cgroup_stat_add_local(cstat, MEM_CGROUP_STAT_RSS, val);
-
-	if (charge)
-		__mem_cgroup_stat_add_local(cstat,
-				MEM_CGROUP_STAT_PGPGIN_COUNT, 1);
-	else
-		__mem_cgroup_stat_add_local(cstat,
-				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
-	__mem_cgroup_stat_add_local(cstat, MEM_CGROUP_STAT_EVENTS, 1);
-	put_cpu();
-}
-
 
 /*
  * Call callback function against all cgroup under hierarchy tree.
@@ -1305,34 +1366,6 @@ static void record_last_oom(struct mem_c
 	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
 }
 
-/*
- * Currently used to update mapped file statistics, but the routine can be
- * generalized to update other statistics as well.
- */
-void mem_cgroup_update_mapped_file_stat(struct page *page, int val)
-{
-	struct mem_cgroup *mem;
-	struct page_cgroup *pc;
-
-	if (!page_is_file_cache(page))
-		return;
-
-	pc = lookup_page_cgroup(page);
-	if (unlikely(!pc))
-		return;
-
-	lock_page_cgroup(pc);
-	mem = pc->mem_cgroup;
-	if (!mem)
-		goto done;
-
-	if (!PageCgroupUsed(pc))
-		goto done;
-
-	mem_cgroup_stat_add_local(mem, MEM_CGROUP_STAT_MAPPED_FILE, val);
-done:
-	unlock_page_cgroup(pc);
-}
 
 #define CHARGE_SIZE	(64 * PAGE_SIZE)
 struct memcg_stock_pcp {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
