Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9ECA56B02A8
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 06:06:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o75A6mYx013755
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Aug 2010 19:06:48 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D0CFD45DE55
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 19:06:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A832145DE4E
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 19:06:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 90E4A1DB803C
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 19:06:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 235A61DB803E
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 19:06:44 +0900 (JST)
Date: Thu, 5 Aug 2010 19:01:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/4 -mm][memcg] scalable file status update logic without
 race
Message-Id: <20100805190152.0fbb5db4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100805184434.3a29c0f9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100805184434.3a29c0f9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

At accounting file events per memory cgroup, we need to find memory cgroup
via page_cgroup->mem_cgroup. Now, we use lock_page_cgroup().

But, considering the context which page-cgroup for files are accessed,
we can use alternative light-weight mutual execusion in the most case.
At handling file-caches, the only race we have to take care of is "moving"
account, IOW, overwriting page_cgroup->mem_cgroup. Because file status
update is done while the page-cache is in stable state, we don't have to
take care of race with charge/uncharge.

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


Changelog: 20100804
 - added a comment for possible optimization hint. (for_each_possible...)
   (but this is not needed to be quick..now)
Changelog: 20100730
 - some cleanup.
Changelog: 20100729
 - replaced __this_cpu_xxx() with this_cpu_xxx
   (because we don't call spinlock)
 - added VM_BUG_ON().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   79 +++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 67 insertions(+), 12 deletions(-)

Index: mmotm-0727/mm/memcontrol.c
===================================================================
--- mmotm-0727.orig/mm/memcontrol.c
+++ mmotm-0727/mm/memcontrol.c
@@ -88,6 +88,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
 	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
+	MEM_CGROUP_ON_MOVE,   /* A check for locking move account/status */
 
 	MEM_CGROUP_STAT_NSTATS,
 };
@@ -1074,7 +1075,50 @@ static unsigned int get_swappiness(struc
 	return swappiness;
 }
 
-/* A routine for testing mem is not under move_account */
+static void mem_cgroup_start_move(struct mem_cgroup *mem)
+{
+	int cpu;
+	/* for fast checking in mem_cgroup_update_file_stat() etc..*/
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
@@ -1473,29 +1517,36 @@ void mem_cgroup_update_file_mapped(struc
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
+	bool need_lock = false;
 
 	pc = lookup_page_cgroup(page);
 	if (unlikely(!pc))
 		return;
-
-	lock_page_cgroup(pc);
+	rcu_read_lock();
 	mem = id_to_memcg(pc->mem_cgroup);
-	if (!mem || !PageCgroupUsed(pc))
+	if (likely(mem)) {
+		if (mem_cgroup_is_moved(mem)) {
+			/* need to serialize with move_account */
+			lock_page_cgroup(pc);
+			need_lock = true;
+			mem = id_to_memcg(pc->mem_cgroup);
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
@@ -3034,6 +3085,7 @@ move_account:
 		lru_add_drain_all();
 		drain_all_stock_sync();
 		ret = 0;
+		mem_cgroup_start_move(mem);
 		for_each_node_state(node, N_HIGH_MEMORY) {
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
 				enum lru_list l;
@@ -3047,6 +3099,7 @@ move_account:
 			if (ret)
 				break;
 		}
+		mem_cgroup_end_move(mem);
 		memcg_oom_recover(mem);
 		/* it seems parent cgroup doesn't have enough mem */
 		if (ret == -ENOMEM)
@@ -4513,6 +4566,7 @@ static void mem_cgroup_clear_mc(void)
 	mc.to = NULL;
 	mc.moving_task = NULL;
 	spin_unlock(&mc.lock);
+	mem_cgroup_end_move(from);
 	memcg_oom_recover(from);
 	memcg_oom_recover(to);
 	wake_up_all(&mc.waitq);
@@ -4543,6 +4597,7 @@ static int mem_cgroup_can_attach(struct 
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
