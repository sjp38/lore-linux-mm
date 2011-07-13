Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0976B6B0082
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 08:59:53 -0400 (EDT)
Message-Id: <50d526ee242916bbfb44b9df4474df728c4892c6.1310561078.git.mhocko@suse.cz>
In-Reply-To: <cover.1310561078.git.mhocko@suse.cz>
References: <cover.1310561078.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Wed, 13 Jul 2011 13:05:49 +0200
Subject: [PATCH 1/2] memcg: make oom_lock 0 and 1 based rather than coutner
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

867578cb "memcg: fix oom kill behavior" introduced oom_lock counter
which is incremented by mem_cgroup_oom_lock when we are about to handle
memcg OOM situation. mem_cgroup_handle_oom falls back to a sleep if
oom_lock > 1 to prevent from multiple oom kills at the same time.
The counter is then decremented by mem_cgroup_oom_unlock called from the
same function.

This works correctly but it can lead to serious starvations when we
have many processes triggering OOM.

Consider a process (call it A) which gets the oom_lock (the first one
that got to mem_cgroup_handle_oom and grabbed memcg_oom_mutex). All
other processes are blocked on the mutex.
While A releases the mutex and calls mem_cgroup_out_of_memory others
will wake up (one after another) and increase the counter and fall into
sleep (memcg_oom_waitq). Once A finishes mem_cgroup_out_of_memory it
takes the mutex again and decreases oom_lock and wakes other tasks (if
releasing memory of the killed task hasn't done it yet).
The main problem here is that everybody still race for the mutex and
there is no guarantee that we will get counter back to 0 for those
that got back to mem_cgroup_handle_oom. In the end the whole convoy
in/decreases the counter but we do not get to 1 that would enable
killing so nothing useful is going on.
The time is basically unbounded because it highly depends on scheduling
and ordering on mutex.

This patch replaces the counter by a simple {un}lock semantic. We are
using only 0 and 1 to distinguish those two states.
As mem_cgroup_oom_{un}lock works on the hierarchy we have to make sure
that we cannot race with somebody else which is already guaranteed
because we call both functions with the mutex held. All other consumers
just read the value atomically for a single group which is sufficient
because we set the value atomically.
The other thing is that only that process which locked the oom will
unlock it once the OOM is handled.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e013b8e..f6c9ead 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1803,22 +1803,31 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 /*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
+ * Has to be called with memcg_oom_mutex
  */
 static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
 {
-	int x, lock_count = 0;
+	int x, lock_count = -1;
 	struct mem_cgroup *iter;
 
 	for_each_mem_cgroup_tree(iter, mem) {
-		x = atomic_inc_return(&iter->oom_lock);
-		lock_count = max(x, lock_count);
+		x = !!atomic_add_unless(&iter->oom_lock, 1, 1);
+		if (lock_count == -1)
+			lock_count = x;
+
+		/* New child can be created but we shouldn't race with
+		 * somebody else trying to oom because we are under
+		 * memcg_oom_mutex
+		 */
+		BUG_ON(lock_count != x);
 	}
 
-	if (lock_count == 1)
-		return true;
-	return false;
+	return lock_count;
 }
 
+/*
+ * Has to be called with memcg_oom_mutex
+ */
 static int mem_cgroup_oom_unlock(struct mem_cgroup *mem)
 {
 	struct mem_cgroup *iter;
@@ -1916,7 +1925,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 	}
 	mutex_lock(&memcg_oom_mutex);
-	mem_cgroup_oom_unlock(mem);
+	if (locked)
+		mem_cgroup_oom_unlock(mem);
 	memcg_wakeup_oom(mem);
 	mutex_unlock(&memcg_oom_mutex);
 
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
