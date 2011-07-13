Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DD8696B0083
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 07:14:01 -0400 (EDT)
Message-Id: <44ec61829ed8a83b55dc90a7aebffdd82fe0e102.1310732789.git.mhocko@suse.cz>
In-Reply-To: <cover.1310732789.git.mhocko@suse.cz>
References: <cover.1310732789.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Wed, 13 Jul 2011 13:05:49 +0200
Subject: [PATCH 1/2 v2] memcg: make oom_lock 0 and 1 based rather than coutner
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

867578cb "memcg: fix oom kill behavior" introduced oom_lock counter
which is incremented by mem_cgroup_oom_lock when we are about to handle
memcg OOM situation. mem_cgroup_handle_oom falls back to a sleep if
oom_lock > 1 to prevent from multiple oom kills at the same time.  The
counter is then decremented by mem_cgroup_oom_unlock called from the
same function.

This works correctly but it can lead to serious starvations when we
have many processes triggering OOM and many CPUs available for them
(I have tested with 16 CPUs).

Consider a process (call it A) which gets the oom_lock (the first one
that got to mem_cgroup_handle_oom and grabbed memcg_oom_mutex) and
other processes that are blocked on the mutex.
While A releases the mutex and calls mem_cgroup_out_of_memory others
will wake up (one after another) and increase the counter and fall into
sleep (memcg_oom_waitq).
Once A finishes mem_cgroup_out_of_memory it takes the mutex again
and decreases oom_lock and wakes other tasks (if releasing memory by
somebody else - e.g. killed process - hasn't done it yet).

Testcase would look like:
 Assume malloc XXX is a program allocating XXX Megabytes of memory
 which touches all allocated pages in a tight loop
 # swapoff SWAP_DEVICE
 # cgcreate -g memory:A
 # cgset -r memory.oom_control=0   A
 # cgset -r memory.limit_in_bytes= 200M
 # for i in `seq 100`
 # do
 #     cgexec -g memory:A   malloc 10 &
 # done

The main problem here is that all processes still race for the mutex
and there is no guarantee that we will get counter back to 0 for those
that got back to mem_cgroup_handle_oom. In the end the whole convoy
in/decreases the counter but we do not get to 1 that would enable
killing so nothing useful can be done.
The time is basically unbounded because it highly depends on scheduling
and ordering on mutex (I have seen this taking hours...).

This patch replaces the counter by a simple {un}lock semantic.
As mem_cgroup_oom_{un}lock works on the a subtree of a hierarchy we have
to make sure that nobody else races with us which is guaranteed by the
memcg_oom_mutex.
We have to be careful while locking subtrees because we can encounter a
subtree which is already locked:
hierarchy:
          A
        /   \
       B     \
      /\      \
     C  D     E

B - C - D tree might be already locked. While we want to enable locking
E subtree because OOM situations cannot influence each other we
definitely do not want to allow locking A.
Therefore we have to refuse lock if any subtree is already locked and
clear up the lock for all nodes that have been set up to the failure
point.

On the other hand we have to make sure that the rest of the world
will recognize that a group is under OOM even though it doesn't have
a lock. Therefore we have to introduce under_oom variable which is
incremented and decremented for the whole subtree when we enter resp.
leave mem_cgroup_handle_oom.
under_oom, unlike oom_lock, doesn't need be updated under
memcg_oom_mutex because its users only check a single group and they use
atomic operations for that.

This can be checked easily by the following test case:

 # cgcreate -g memory:A
 # cgset -r memory.use_hierarchy=1 A
 # cgset -r memory.oom_control=1   A
 # cgset -r memory.limit_in_bytes= 100M
 # cgset -r memory.memsw.limit_in_bytes= 100M
 # cgcreate -g memory:A/B
 # cgset -r memory.oom_control=1 A/B
 # cgset -r memory.limit_in_bytes=20M
 # cgset -r memory.memsw.limit_in_bytes=20M
 # cgexec -g memory:A/B malloc 30  &    #->this will be blocked by OOM of group B
 # cgexec -g memory:A   malloc 80  &    #->this will be blocked by OOM of group A

While B gets oom_lock A will not get it. Both of them go into sleep and
wait for an external action. We can make the limit higher for A to
enforce waking it up

 # cgset -r memory.memsw.limit_in_bytes=300M A
 # cgset -r memory.limit_in_bytes=300M A

malloc in A has to wake up even though it doesn't have oom_lock.

Finally, the unlock path is very easy because we always unlock only the
subtree we have locked previously while we always decrement under_oom.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Changes since v1:
- under_oom added to mark that a subtree is under OOM condition even if
  it doesn't keep the lock. memcg_oom_recover,
  mem_cgroup_oom_register_event and mem_cgroup_oom_control_read are
  using this flag to find out whether a group is under oom.
- under_oom is handles separately from oom_lock because it doesn't need
  memcg_oom_mutex
- updated changelog with test cases

---
 mm/memcontrol.c |   86 ++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 70 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e013b8e..de1702c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -246,7 +246,10 @@ struct mem_cgroup {
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
 	bool use_hierarchy;
-	atomic_t	oom_lock;
+
+	bool		oom_lock;
+	atomic_t	under_oom;
+
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
@@ -1803,37 +1806,83 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 /*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
+ * Has to be called with memcg_oom_mutex
  */
 static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
 {
-	int x, lock_count = 0;
-	struct mem_cgroup *iter;
+	int lock_count = -1;
+	struct mem_cgroup *iter, *failed = NULL;
+	bool cond = true;
 
-	for_each_mem_cgroup_tree(iter, mem) {
-		x = atomic_inc_return(&iter->oom_lock);
-		lock_count = max(x, lock_count);
+	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
+		bool locked = iter->oom_lock;
+
+		iter->oom_lock = true;
+		if (lock_count == -1)
+			lock_count = iter->oom_lock;
+		else if (lock_count != locked) {
+			/*
+			 * this subtree of our hierarchy is already locked
+			 * so we cannot give a lock.
+			 */
+			lock_count = 0;
+			failed = iter;
+			cond = false;
+		}
 	}
 
-	if (lock_count == 1)
-		return true;
-	return false;
+	if (!failed)
+		goto done;
+
+	/*
+	 * OK, we failed to lock the whole subtree so we have to clean up
+	 * what we set up to the failing subtree
+	 */
+	cond = true;
+	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
+		if (iter == failed) {
+			cond = false;
+			continue;
+		}
+		iter->oom_lock = false;
+	}
+done:
+	return lock_count;
 }
 
+/*
+ * Has to be called with memcg_oom_mutex
+ */
 static int mem_cgroup_oom_unlock(struct mem_cgroup *mem)
 {
 	struct mem_cgroup *iter;
 
+	for_each_mem_cgroup_tree(iter, mem)
+		iter->oom_lock = false;
+	return 0;
+}
+
+static void mem_cgroup_mark_under_oom(struct mem_cgroup *mem)
+{
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup_tree(iter, mem)
+		atomic_inc(&iter->under_oom);
+}
+
+static void mem_cgroup_unmark_under_oom(struct mem_cgroup *mem)
+{
+	struct mem_cgroup *iter;
+
 	/*
 	 * When a new child is created while the hierarchy is under oom,
 	 * mem_cgroup_oom_lock() may not be called. We have to use
 	 * atomic_add_unless() here.
 	 */
 	for_each_mem_cgroup_tree(iter, mem)
-		atomic_add_unless(&iter->oom_lock, -1, 0);
-	return 0;
+		atomic_add_unless(&iter->under_oom, -1, 0);
 }
 
-
 static DEFINE_MUTEX(memcg_oom_mutex);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
 
@@ -1875,7 +1924,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *mem)
 
 static void memcg_oom_recover(struct mem_cgroup *mem)
 {
-	if (mem && atomic_read(&mem->oom_lock))
+	if (mem && atomic_read(&mem->under_oom))
 		memcg_wakeup_oom(mem);
 }
 
@@ -1893,6 +1942,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 	owait.wait.private = current;
 	INIT_LIST_HEAD(&owait.wait.task_list);
 	need_to_kill = true;
+	mem_cgroup_mark_under_oom(mem);
+
 	/* At first, try to OOM lock hierarchy under mem.*/
 	mutex_lock(&memcg_oom_mutex);
 	locked = mem_cgroup_oom_lock(mem);
@@ -1916,10 +1967,13 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 	}
 	mutex_lock(&memcg_oom_mutex);
-	mem_cgroup_oom_unlock(mem);
+	if (locked)
+		mem_cgroup_oom_unlock(mem);
 	memcg_wakeup_oom(mem);
 	mutex_unlock(&memcg_oom_mutex);
 
+	mem_cgroup_unmark_under_oom(mem);
+
 	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
 		return false;
 	/* Give chance to dying process */
@@ -4584,7 +4638,7 @@ static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
 	list_add(&event->list, &memcg->oom_notify);
 
 	/* already in OOM ? */
-	if (atomic_read(&memcg->oom_lock))
+	if (atomic_read(&memcg->under_oom))
 		eventfd_signal(eventfd, 1);
 	mutex_unlock(&memcg_oom_mutex);
 
@@ -4619,7 +4673,7 @@ static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
 
 	cb->fill(cb, "oom_kill_disable", mem->oom_kill_disable);
 
-	if (atomic_read(&mem->oom_lock))
+	if (atomic_read(&mem->under_oom))
 		cb->fill(cb, "under_oom", 1);
 	else
 		cb->fill(cb, "under_oom", 0);
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
