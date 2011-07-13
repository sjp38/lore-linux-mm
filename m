Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 199986B0083
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 08:59:53 -0400 (EDT)
Message-Id: <c56ab7b9417bb5e5b898afe7c21df8ae40fdadcf.1310561078.git.mhocko@suse.cz>
In-Reply-To: <cover.1310561078.git.mhocko@suse.cz>
References: <cover.1310561078.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Wed, 13 Jul 2011 14:32:27 +0200
Subject: [PATCH 2/2] memcg: change memcg_oom_mutex to spinlock
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

memcg_oom_mutex is used to protect memcg OOM path and eventfd interface
for oom_control. None of the critical sections that it protects sleep
(eventfd_signal works from atomic context and the rest are simple linked
list resp. oom_lock atomic oprations).
Mutex is too heavy weight for those code paths because it triggers a lot
of scheduling.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f6c9ead..38f988e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1803,7 +1803,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 /*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
- * Has to be called with memcg_oom_mutex
+ * Has to be called with memcg_oom_lock
  */
 static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
 {
@@ -1817,7 +1817,7 @@ static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
 
 		/* New child can be created but we shouldn't race with
 		 * somebody else trying to oom because we are under
-		 * memcg_oom_mutex
+		 * memcg_oom_lock
 		 */
 		BUG_ON(lock_count != x);
 	}
@@ -1826,7 +1826,7 @@ static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
 }
 
 /*
- * Has to be called with memcg_oom_mutex
+ * Has to be called with memcg_oom_lock
  */
 static int mem_cgroup_oom_unlock(struct mem_cgroup *mem)
 {
@@ -1843,7 +1843,7 @@ static int mem_cgroup_oom_unlock(struct mem_cgroup *mem)
 }
 
 
-static DEFINE_MUTEX(memcg_oom_mutex);
+static DEFINE_SPINLOCK(memcg_oom_lock);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
 
 struct oom_wait_info {
@@ -1903,7 +1903,7 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 	INIT_LIST_HEAD(&owait.wait.task_list);
 	need_to_kill = true;
 	/* At first, try to OOM lock hierarchy under mem.*/
-	mutex_lock(&memcg_oom_mutex);
+	spin_lock(&memcg_oom_lock);
 	locked = mem_cgroup_oom_lock(mem);
 	/*
 	 * Even if signal_pending(), we can't quit charge() loop without
@@ -1915,7 +1915,7 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 		need_to_kill = false;
 	if (locked)
 		mem_cgroup_oom_notify(mem);
-	mutex_unlock(&memcg_oom_mutex);
+	spin_unlock(&memcg_oom_lock);
 
 	if (need_to_kill) {
 		finish_wait(&memcg_oom_waitq, &owait.wait);
@@ -1924,11 +1924,11 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 		schedule();
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 	}
-	mutex_lock(&memcg_oom_mutex);
+	spin_lock(&memcg_oom_lock);
 	if (locked)
 		mem_cgroup_oom_unlock(mem);
 	memcg_wakeup_oom(mem);
-	mutex_unlock(&memcg_oom_mutex);
+	spin_unlock(&memcg_oom_lock);
 
 	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
 		return false;
@@ -4588,7 +4588,7 @@ static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
 	if (!event)
 		return -ENOMEM;
 
-	mutex_lock(&memcg_oom_mutex);
+	spin_lock(&memcg_oom_lock);
 
 	event->eventfd = eventfd;
 	list_add(&event->list, &memcg->oom_notify);
@@ -4596,7 +4596,7 @@ static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
 	/* already in OOM ? */
 	if (atomic_read(&memcg->oom_lock))
 		eventfd_signal(eventfd, 1);
-	mutex_unlock(&memcg_oom_mutex);
+	spin_unlock(&memcg_oom_lock);
 
 	return 0;
 }
@@ -4610,7 +4610,7 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 
 	BUG_ON(type != _OOM_TYPE);
 
-	mutex_lock(&memcg_oom_mutex);
+	spin_lock(&memcg_oom_lock);
 
 	list_for_each_entry_safe(ev, tmp, &mem->oom_notify, list) {
 		if (ev->eventfd == eventfd) {
@@ -4619,7 +4619,7 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 		}
 	}
 
-	mutex_unlock(&memcg_oom_mutex);
+	spin_unlock(&memcg_oom_lock);
 }
 
 static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
