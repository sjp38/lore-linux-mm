Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C6AF76B0062
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:28:21 -0400 (EDT)
Date: Fri, 26 Jul 2013 17:28:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 6/6] mm: memcg: do not trap chargers with full callstack
 on OOM
Message-ID: <20130726212808.GD17975@cmpxchg.org>
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
 <1374791138-15665-7-git-send-email-hannes@cmpxchg.org>
 <20130726144310.GH17761@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130726144310.GH17761@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jul 26, 2013 at 04:43:10PM +0200, Michal Hocko wrote:
> On Thu 25-07-13 18:25:38, Johannes Weiner wrote:
> > @@ -2189,31 +2191,20 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
> >  }
> >  
> >  /*
> > - * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> > + * try to call OOM killer
> >   */
> > -static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
> > -				  int order)
> > +static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> >  {
> > -	struct oom_wait_info owait;
> > -	bool locked, need_to_kill;
> > +	bool locked, need_to_kill = true;
> >  
> > -	owait.memcg = memcg;
> > -	owait.wait.flags = 0;
> > -	owait.wait.func = memcg_oom_wake_function;
> > -	owait.wait.private = current;
> > -	INIT_LIST_HEAD(&owait.wait.task_list);
> > -	need_to_kill = true;
> > -	mem_cgroup_mark_under_oom(memcg);
> 
> You are marking memcg under_oom only for the sleepers. So if we have
> no sleepers then the memcg will never report it is under oom which
> is a behavior change. On the other hand who-ever relies on under_oom
> under such conditions (it would basically mean a busy loop reading
> memory.oom_control) would be racy anyway so it is questionable it
> matters at all. At least now when we do not have any active notification
> that under_oom has changed.
> 
> Anyway, this shouldn't be a part of this patch so if you want it because
> it saves a pointless hierarchy traversal then make it a separate patch
> with explanation why the new behavior is still OK.

This made me think again about how the locking and waking in there
works and I found a bug in this patch.

Basically, we have an open-coded sleeping lock in there and it's all
obfuscated by having way too much stuffed into the memcg_oom_lock
section.

Removing all the clutter, it becomes clear that I can't remove that
(undocumented) final wakeup at the end of the function.  As with any
lock, a contender has to be woken up after unlock.  We can't rely on
the lock holder's OOM kill to trigger uncharges and wakeups, because a
contender for the OOM lock could show up after the OOM kill but before
the lock is released.  If there weren't any more wakeups, the
contender would sleep indefinitely.

It also becomes clear that I can't remove the
mem_cgroup_mark_under_oom() like that because it is key in receiving
wakeups.  And as with any sleeping lock, we need to listen to wakeups
before attempting the trylock, or we might miss the wakeup from the
unlock.

It definitely became a separate patch, which cleans up this unholy
mess first before putting new things on top:

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcg: rework and document OOM serialization

1. Remove the return value of mem_cgroup_oom_unlock().

2. Rename mem_cgroup_oom_lock() to mem_cgroup_oom_trylock().

3. Pull the prepare_to_wait() out of the memcg_oom_lock scope.  This
   makes it more obvious that the task has to be on the waitqueue
   before attempting to OOM-trylock the hierarchy, to not miss any
   wakeups before going to sleep.  It just didn't matter until now
   because it was all lumped together into the global memcg_oom_lock
   spinlock section.

4. Pull the mem_cgroup_oom_notify() out of the memcg_oom_lock scope.
   It is proctected by the hierarchical OOM-lock.

5. The memcg_oom_lock spinlock is only required to propagate the OOM
   lock in any given hierarchy atomically.  Restrict its scope to
   mem_cgroup_oom_(trylock|unlock).

6. Do not wake up the waitqueue unconditionally at the end of the
   function.  Only the lockholder has to wake up the next in line
   after releasing the lock.

   Note that the lockholder kicks off the OOM-killer, which in turn
   leads to wakeups from the uncharges of the exiting task.  But any
   contender is not guaranteed to see them if it enters the OOM path
   after the OOM kills but before the lockholder releases the lock.
   Thus the wakeup has to be explicitely after releasing the lock.

7. Put the OOM task on the waitqueue before marking the hierarchy as
   under OOM as that is the point where we start to receive wakeups.
   No point in listening before being on the waitqueue.

8. Likewise, unmark the hierarchy before finishing the sleep, for
   symmetry.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 85 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 47 insertions(+), 38 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 30ae46a..0d923df 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2076,15 +2076,18 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 	return total;
 }
 
+static DEFINE_SPINLOCK(memcg_oom_lock);
+
 /*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
- * Has to be called with memcg_oom_lock
  */
-static bool mem_cgroup_oom_lock(struct mem_cgroup *memcg)
+static bool mem_cgroup_oom_trylock(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *iter, *failed = NULL;
 
+	spin_lock(&memcg_oom_lock);
+
 	for_each_mem_cgroup_tree(iter, memcg) {
 		if (iter->oom_lock) {
 			/*
@@ -2098,33 +2101,33 @@ static bool mem_cgroup_oom_lock(struct mem_cgroup *memcg)
 			iter->oom_lock = true;
 	}
 
-	if (!failed)
-		return true;
-
-	/*
-	 * OK, we failed to lock the whole subtree so we have to clean up
-	 * what we set up to the failing subtree
-	 */
-	for_each_mem_cgroup_tree(iter, memcg) {
-		if (iter == failed) {
-			mem_cgroup_iter_break(memcg, iter);
-			break;
+	if (failed) {
+		/*
+		 * OK, we failed to lock the whole subtree so we have
+		 * to clean up what we set up to the failing subtree
+		 */
+		for_each_mem_cgroup_tree(iter, memcg) {
+			if (iter == failed) {
+				mem_cgroup_iter_break(memcg, iter);
+				break;
+			}
+			iter->oom_lock = false;
 		}
-		iter->oom_lock = false;
-	}
-	return false;
+	}	
+
+	spin_unlock(&memcg_oom_lock);
+
+	return !failed;
 }
 
-/*
- * Has to be called with memcg_oom_lock
- */
-static int mem_cgroup_oom_unlock(struct mem_cgroup *memcg)
+static void mem_cgroup_oom_unlock(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *iter;
 
+	spin_lock(&memcg_oom_lock);
 	for_each_mem_cgroup_tree(iter, memcg)
 		iter->oom_lock = false;
-	return 0;
+	spin_unlock(&memcg_oom_lock);
 }
 
 static void mem_cgroup_mark_under_oom(struct mem_cgroup *memcg)
@@ -2148,7 +2151,6 @@ static void mem_cgroup_unmark_under_oom(struct mem_cgroup *memcg)
 		atomic_add_unless(&iter->under_oom, -1, 0);
 }
 
-static DEFINE_SPINLOCK(memcg_oom_lock);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
 
 struct oom_wait_info {
@@ -2195,45 +2197,52 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
 				  int order)
 {
 	struct oom_wait_info owait;
-	bool locked, need_to_kill;
+	bool locked;
 
 	owait.memcg = memcg;
 	owait.wait.flags = 0;
 	owait.wait.func = memcg_oom_wake_function;
 	owait.wait.private = current;
 	INIT_LIST_HEAD(&owait.wait.task_list);
-	need_to_kill = true;
-	mem_cgroup_mark_under_oom(memcg);
 
-	/* At first, try to OOM lock hierarchy under memcg.*/
-	spin_lock(&memcg_oom_lock);
-	locked = mem_cgroup_oom_lock(memcg);
 	/*
+	 * As with any blocking lock, a contender needs to start
+	 * listening for wakeups before attempting the trylock,
+	 * otherwise it can miss the wakeup from the unlock and sleep
+	 * indefinitely.  This is just open-coded because our locking
+	 * is so particular to memcg hierarchies.
+	 *
 	 * Even if signal_pending(), we can't quit charge() loop without
 	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
 	 * under OOM is always welcomed, use TASK_KILLABLE here.
 	 */
 	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
-	if (!locked || memcg->oom_kill_disable)
-		need_to_kill = false;
+	mem_cgroup_mark_under_oom(memcg);
+
+	locked = mem_cgroup_oom_trylock(memcg);
+
 	if (locked)
 		mem_cgroup_oom_notify(memcg);
-	spin_unlock(&memcg_oom_lock);
 
-	if (need_to_kill) {
+	if (locked && !memcg->oom_kill_disable) {
+		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 		mem_cgroup_out_of_memory(memcg, mask, order);
 	} else {
 		schedule();
+		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 	}
-	spin_lock(&memcg_oom_lock);
-	if (locked)
-		mem_cgroup_oom_unlock(memcg);
-	memcg_wakeup_oom(memcg);
-	spin_unlock(&memcg_oom_lock);
 
-	mem_cgroup_unmark_under_oom(memcg);
+	if (locked) {
+		mem_cgroup_oom_unlock(memcg);
+		/*
+		 * There is no guarantee that a OOM-lock contender
+		 * sees the wakeups triggered by the OOM kill
+		 * uncharges.  Wake any sleepers explicitely.
+		 */
+		memcg_oom_recover(memcg);
+	}
 
 	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
 		return false;
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
