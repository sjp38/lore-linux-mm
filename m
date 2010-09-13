Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4C5FA6B00EA
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 04:07:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8D86xCn023769
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 13 Sep 2010 17:06:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD1B045DE4D
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 17:06:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ADF8145DE4F
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 17:06:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DCDC1DB803B
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 17:06:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41E271DB803E
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 17:06:58 +0900 (JST)
Date: Mon, 13 Sep 2010 17:01:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: avoid lock in updating file_mapped (Was fix race in
 file_mapped accouting flag management
Message-Id: <20100913170151.aef94e26.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100913161309.9d733e6b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100913160822.0c2cd732.kamezawa.hiroyu@jp.fujitsu.com>
	<20100913161309.9d733e6b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Very sorry, subject was wrong..(reposting).

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

At accounting file events per memory cgroup, we need to find memory cgroup
via page_cgroup->mem_cgroup. Now, we use lock_page_cgroup() for guarantee
pc->mem_cgroup is not overwritten while we make use of it.

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

Following is a perf data of a process which mmap()/munmap 32MB of file cache
in a minute.

Before patch:
    28.25%     mmap  mmap               [.] main
    22.64%     mmap  [kernel.kallsyms]  [k] page_fault
     9.96%     mmap  [kernel.kallsyms]  [k] mem_cgroup_update_file_mapped
     3.67%     mmap  [kernel.kallsyms]  [k] filemap_fault
     3.50%     mmap  [kernel.kallsyms]  [k] unmap_vmas
     2.99%     mmap  [kernel.kallsyms]  [k] __do_fault
     2.76%     mmap  [kernel.kallsyms]  [k] find_get_page

After patch:
    30.00%     mmap  mmap               [.] main
    23.78%     mmap  [kernel.kallsyms]  [k] page_fault
     5.52%     mmap  [kernel.kallsyms]  [k] mem_cgroup_update_file_mapped
     3.81%     mmap  [kernel.kallsyms]  [k] unmap_vmas
     3.26%     mmap  [kernel.kallsyms]  [k] find_get_page
     3.18%     mmap  [kernel.kallsyms]  [k] __do_fault
     3.03%     mmap  [kernel.kallsyms]  [k] filemap_fault
     2.40%     mmap  [kernel.kallsyms]  [k] handle_mm_fault
     2.40%     mmap  [kernel.kallsyms]  [k] do_page_fault

This patch reduces memcg's cost to some extent.
(mem_cgroup_update_file_mapped is called by both of map/unmap)

Note: It seems some more improvements are required..but no idea.
      maybe removing set/unset flag is required.

Changelog: 20100913
 - decoupled with ID patches.
 - updated comments.

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
 mm/memcontrol.c |   99 ++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 85 insertions(+), 14 deletions(-)

Index: lockless-update/mm/memcontrol.c
===================================================================
--- lockless-update.orig/mm/memcontrol.c
+++ lockless-update/mm/memcontrol.c
@@ -90,6 +90,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
 	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
+	MEM_CGROUP_ON_MOVE,	/* someone is moving account between groups */
 
 	MEM_CGROUP_STAT_NSTATS,
 };
@@ -1051,7 +1052,46 @@ static unsigned int get_swappiness(struc
 	return swappiness;
 }
 
-/* A routine for testing mem is not under move_account */
+static void mem_cgroup_start_move(struct mem_cgroup *mem)
+{
+	int cpu;
+	/* Because this is for moving account, reuse mc.lock */
+	spin_lock(&mc.lock);
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
+	spin_lock(&mc.lock);
+	for_each_possible_cpu(cpu)
+		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) -= 1;
+	spin_unlock(&mc.lock);
+}
+/*
+ * 2 routines for checking "mem" is under move_account() or not.
+ *
+ * mem_cgroup_stealed() - checking a cgroup is mc.from or not. This is used
+ *			  for avoiding race in accounting. If true,
+ *			  pc->mem_cgroup may be overwritten.
+ *
+ * mem_cgroup_under_move() - checking a cgroup is mc.from or mc.to or
+ *			  under hierarchy of moving cgroups. This is for
+ *			  waiting at hith-memory prressure caused by "move".
+ */
+
+static bool mem_cgroup_stealed(struct mem_cgroup *mem)
+{
+	VM_BUG_ON(!rcu_read_lock_held());
+	return this_cpu_read(mem->stat->count[MEM_CGROUP_ON_MOVE]) > 0;
+}
 
 static bool mem_cgroup_under_move(struct mem_cgroup *mem)
 {
@@ -1462,35 +1502,62 @@ bool mem_cgroup_handle_oom(struct mem_cg
 /*
  * Currently used to update mapped file statistics, but the routine can be
  * generalized to update other statistics as well.
+ *
+ * Notes: Race condition
+ *
+ * We usually use page_cgroup_lock() for accessing page_cgroup member but
+ * it tends to be costly. But considering some conditions, we doesn't need
+ * to do so _always_.
+ *
+ * Considering "charge", lock_page_cgroup() is not required because all
+ * file-stat operations happen after a page is attached to radix-tree. There
+ * are no race with "charge".
+ *
+ * Considering "uncharge", we know that memcg doesn't clear pc->mem_cgroup
+ * at "uncharge" intentionally. So, we always see valid pc->mem_cgroup even
+ * if there are race with "uncharge". Statistics itself is properly handled
+ * by flags.
+ *
+ * Considering "move", this is an only case we see a race. To make the race
+ * small, we check MEM_CGROUP_ON_MOVE percpu value and detect there are
+ * possibility of race condition. If there is, we take a lock.
  */
 void mem_cgroup_update_file_mapped(struct page *page, int val)
 {
 	struct mem_cgroup *mem;
-	struct page_cgroup *pc;
+	struct page_cgroup *pc = lookup_page_cgroup(page);
+	bool need_unlock = false;
 
-	pc = lookup_page_cgroup(page);
 	if (unlikely(!pc))
 		return;
 
-	lock_page_cgroup(pc);
+	rcu_read_lock();
 	mem = pc->mem_cgroup;
-	if (!mem || !PageCgroupUsed(pc))
-		goto done;
-
-	/*
-	 * Preemption is already disabled. We can use __this_cpu_xxx
-	 */
+	if (unlikely(!mem || !PageCgroupUsed(pc)))
+		goto out;
+	/* pc->mem_cgroup is unstable ? */
+	if (unlikely(mem_cgroup_stealed(mem))) {
+		/* take a lock against to access pc->mem_cgroup */
+		lock_page_cgroup(pc);
+		need_unlock = true;
+		mem = pc->mem_cgroup;
+		if (!mem || !PageCgroupUsed(pc))
+			goto out;
+	}
 	if (val > 0) {
-		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		SetPageCgroupFileMapped(pc);
 	} else {
-		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
+		this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
 		if (!page_mapped(page)) /* for race between dec->inc counter */
 			ClearPageCgroupFileMapped(pc);
 	}
 
-done:
-	unlock_page_cgroup(pc);
+out:
+	if (unlikely(need_unlock))
+		unlock_page_cgroup(pc);
+	rcu_read_unlock();
+	return;
 }
 
 /*
@@ -3039,6 +3106,7 @@ move_account:
 		lru_add_drain_all();
 		drain_all_stock_sync();
 		ret = 0;
+		mem_cgroup_start_move(mem);
 		for_each_node_state(node, N_HIGH_MEMORY) {
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
 				enum lru_list l;
@@ -3052,6 +3120,7 @@ move_account:
 			if (ret)
 				break;
 		}
+		mem_cgroup_end_move(mem);
 		memcg_oom_recover(mem);
 		/* it seems parent cgroup doesn't have enough mem */
 		if (ret == -ENOMEM)
@@ -4510,6 +4579,7 @@ static void mem_cgroup_clear_mc(void)
 	mc.to = NULL;
 	mc.moving_task = NULL;
 	spin_unlock(&mc.lock);
+	mem_cgroup_end_move(from);
 	memcg_oom_recover(from);
 	memcg_oom_recover(to);
 	wake_up_all(&mc.waitq);
@@ -4540,6 +4610,7 @@ static int mem_cgroup_can_attach(struct 
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
