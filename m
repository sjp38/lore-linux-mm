Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AD7D96B0087
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 02:50:23 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o816oKUL022323
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Sep 2010 15:50:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 77DA845DE52
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:50:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5662C45DE51
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:50:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DFCC1DB804F
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:50:20 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BA2B01DB8045
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:50:19 +0900 (JST)
Date: Wed, 1 Sep 2010 15:45:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/5] memcg: light weight file mapped update lock system
Message-Id: <20100901154518.8faacc44.kamezawa.hiroyu@jp.fujitsu.com>
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

At accounting file events per memory cgroup, we need to find memory cgroup
via page_cgroup->mem_cgroup. Now, we use lock_page_cgroup().

But, considering the context which page-cgroup for files are accessed,
we can use alternative light-weight mutual execusion in the most case.

At handling file-caches, the only race we have to take care of is "moving"
account, IOW, overwriting page_cgroup->mem_cgroup. 
(See comment in the patch)

Unlike charge/uncharge, "move" happens not so frequently. It happens only when
rmdir() and task-moving (with a special settings.)
This patch adds a race-checker for file-cache-status accounting v.s. account
moving. The new per-cpu-per-memcg counter MEM_CGROUP_ON_MOVE is added.
The routine for account move 
  1. Increment it before start moving
  2. Call synchronize_rcu()
  3. Decrement it after the end of moving.
By this, file-status-counting routine can check it needs to call
lock_page_cgroup(). In most case, I doesn't need to call it.

Changelog: 20100901
 - changes id_to_memcg(pc, true) to be id_to_memcg(pc, false)
   in update_file_mapped()
 - updated comments on lock rule of update_file_mapped()
Changelog: 20100825
 - added a comment about mc.lock
 - fixed bad lock.
Changelog: 20100804
 - added a comment for possible optimization hint.
Changelog: 20100730
 - some cleanup.
Changelog: 20100729
 - replaced __this_cpu_xxx() with this_cpu_xxx
   (because we don't call spinlock)
 - added VM_BUG_ON().

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   98 ++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 85 insertions(+), 13 deletions(-)

Index: mmotm-0827/mm/memcontrol.c
===================================================================
--- mmotm-0827.orig/mm/memcontrol.c
+++ mmotm-0827/mm/memcontrol.c
@@ -90,6 +90,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
 	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
+	MEM_CGROUP_ON_MOVE,   /* A check for locking move account/status */
 
 	MEM_CGROUP_STAT_NSTATS,
 };
@@ -1092,7 +1093,52 @@ static unsigned int get_swappiness(struc
 	return swappiness;
 }
 
-/* A routine for testing mem is not under move_account */
+static void mem_cgroup_start_move(struct mem_cgroup *mem)
+{
+	int cpu;
+	/*
+	 * reuse mc.lock.
+	 */
+	spin_lock(&mc.lock);
+	/* TODO: Can we optimize this by for_each_online_cpu() ? */
+	for_each_possible_cpu(cpu)
+		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
+	spin_unlock(&mc.lock);
+
+	synchronize_rcu();
+}
+
+static void mem_cgroup_end_move(struct mem_cgroup *mem)
+{
+	int cpu;
+
+	if (!mem)
+		return;
+	/* for fast checking in mem_cgroup_update_file_stat() etc..*/
+	spin_lock(&mc.lock);
+	for_each_possible_cpu(cpu)
+		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) -= 1;
+	spin_unlock(&mc.lock);
+}
+
+/*
+ * mem_cgroup_is_moved -- checking a cgroup is mc.from target or not.
+ *                          used for avoiding race.
+ * mem_cgroup_under_move -- checking a cgroup is mc.from or mc.to or
+ *			    under hierarchy of them. used for waiting at
+ *			    memory pressure.
+ * Result of is_moved can be trusted until the end of rcu_read_unlock().
+ * The caller must do
+ *	rcu_read_lock();
+ *	result = mem_cgroup_is_moved();
+ *	.....make use of result here....
+ *	rcu_read_unlock();
+ */
+static bool mem_cgroup_is_moved(struct mem_cgroup *mem)
+{
+	VM_BUG_ON(!rcu_read_lock_held());
+	return this_cpu_read(mem->stat->count[MEM_CGROUP_ON_MOVE]) > 0;
+}
 
 static bool mem_cgroup_under_move(struct mem_cgroup *mem)
 {
@@ -1503,34 +1549,56 @@ bool mem_cgroup_handle_oom(struct mem_cg
 /*
  * Currently used to update mapped file statistics, but the routine can be
  * generalized to update other statistics as well.
+ *
+ * Notes: How to consider race conditions.
+ *
+ * Lock against "charge" is not required. All operations happens after the
+ * page is attached to address_space->mapping, charge must be finished.
+ *
+ * Rquired lock against "move" is held if necessary and account move code
+ * does proper move of statistics data.
+ *
+ * Lock against "uncharge" is not required. Because uncharge() doesn't clear
+ * pc->mem_cgroup, we can catch proper memcg even under race with truncation.
+ * Another thinking, while we call this, we grab a page_count of the page. So,
+ * the page will be never reused for other purpose and page_cgroup->mem_cgroup
+ * will contain the last data it had.
  */
+
 void mem_cgroup_update_file_mapped(struct page *page, int val)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
+	bool need_lock = false;
 
 	pc = lookup_page_cgroup(page);
 	if (unlikely(!pc))
 		return;
-
-	lock_page_cgroup(pc);
-	mem = id_to_memcg(pc->mem_cgroup, true);
-	if (!mem || !PageCgroupUsed(pc))
+	rcu_read_lock();
+	mem = id_to_memcg(pc->mem_cgroup, false);
+	if (likely(mem)) {
+		if (mem_cgroup_is_moved(mem)) {
+			/* need to serialize with move_account */
+			lock_page_cgroup(pc);
+			need_lock = true;
+			mem = id_to_memcg(pc->mem_cgroup, true);
+			if (unlikely(!mem))
+				goto done;
+		}
+	}
+	if (unlikely(!PageCgroupUsed(pc)))
 		goto done;
-
-	/*
-	 * Preemption is already disabled. We can use __this_cpu_xxx
-	 */
 	if (val > 0) {
-		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		SetPageCgroupFileMapped(pc);
 	} else {
-		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		ClearPageCgroupFileMapped(pc);
 	}
-
 done:
-	unlock_page_cgroup(pc);
+	if (need_lock)
+		unlock_page_cgroup(pc);
+	rcu_read_unlock();
 }
 
 /*
@@ -3070,6 +3138,7 @@ move_account:
 		lru_add_drain_all();
 		drain_all_stock_sync();
 		ret = 0;
+		mem_cgroup_start_move(mem);
 		for_each_node_state(node, N_HIGH_MEMORY) {
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
 				enum lru_list l;
@@ -3083,6 +3152,7 @@ move_account:
 			if (ret)
 				break;
 		}
+		mem_cgroup_end_move(mem);
 		memcg_oom_recover(mem);
 		/* it seems parent cgroup doesn't have enough mem */
 		if (ret == -ENOMEM)
@@ -4560,6 +4630,7 @@ static void mem_cgroup_clear_mc(void)
 	mc.to = NULL;
 	mc.moving_task = NULL;
 	spin_unlock(&mc.lock);
+	mem_cgroup_end_move(from);
 	memcg_oom_recover(from);
 	memcg_oom_recover(to);
 	wake_up_all(&mc.waitq);
@@ -4590,6 +4661,7 @@ static int mem_cgroup_can_attach(struct 
 			VM_BUG_ON(mc.moved_charge);
 			VM_BUG_ON(mc.moved_swap);
 			VM_BUG_ON(mc.moving_task);
+			mem_cgroup_start_move(from);
 			spin_lock(&mc.lock);
 			mc.from = from;
 			mc.to = mem;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
