Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9D85C6B0082
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 07:14:01 -0400 (EDT)
Message-Id: <b24894c23d0bb06f849822cb30726b532ea3a4c5.1310732789.git.mhocko@suse.cz>
In-Reply-To: <cover.1310732789.git.mhocko@suse.cz>
References: <cover.1310732789.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Thu, 14 Jul 2011 17:29:51 +0200
Subject: [PATCH 2/2] memcg: change memcg_oom_mutex to spinlock
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

memcg_oom_mutex is used to protect memcg OOM path and eventfd interface
for oom_control. None of the critical sections which it protects sleep
(eventfd_signal works from atomic context and the rest are simple linked
list resp. oom_lock atomic operations).
Mutex is also too heavy weight for those code paths because it triggers
a lot of scheduling. It also makes makes convoying effects more visible
when we have a big number of oom killing because we take the lock
mutliple times during mem_cgroup_handle_oom so we have multiple places
where many processes can sleep.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index de1702c..f11f198 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1806,7 +1806,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 /*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
- * Has to be called with memcg_oom_mutex
+ * Has to be called with memcg_oom_lock
  */
 static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
 {
@@ -1851,7 +1851,7 @@ done:
 }
 
 /*
- * Has to be called with memcg_oom_mutex
+ * Has to be called with memcg_oom_lock
  */
 static int mem_cgroup_oom_unlock(struct mem_cgroup *mem)
 {
@@ -1883,7 +1883,7 @@ static void mem_cgroup_unmark_under_oom(struct mem_cgroup *mem)
 		atomic_add_unless(&iter->under_oom, -1, 0);
 }
 
-static DEFINE_MUTEX(memcg_oom_mutex);
+static DEFINE_SPINLOCK(memcg_oom_lock);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
 
 struct oom_wait_info {
@@ -1945,7 +1945,7 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 	mem_cgroup_mark_under_oom(mem);
 
 	/* At first, try to OOM lock hierarchy under mem.*/
-	mutex_lock(&memcg_oom_mutex);
+	spin_lock(&memcg_oom_lock);
 	locked = mem_cgroup_oom_lock(mem);
 	/*
 	 * Even if signal_pending(), we can't quit charge() loop without
@@ -1957,7 +1957,7 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
 		need_to_kill = false;
 	if (locked)
 		mem_cgroup_oom_notify(mem);
-	mutex_unlock(&memcg_oom_mutex);
+	spin_unlock(&memcg_oom_lock);
 
 	if (need_to_kill) {
 		finish_wait(&memcg_oom_waitq, &owait.wait);
@@ -1966,11 +1966,11 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
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
 
 	mem_cgroup_unmark_under_oom(mem);
 
@@ -4632,7 +4632,7 @@ static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
 	if (!event)
 		return -ENOMEM;
 
-	mutex_lock(&memcg_oom_mutex);
+	spin_lock(&memcg_oom_lock);
 
 	event->eventfd = eventfd;
 	list_add(&event->list, &memcg->oom_notify);
@@ -4640,7 +4640,7 @@ static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
 	/* already in OOM ? */
 	if (atomic_read(&memcg->under_oom))
 		eventfd_signal(eventfd, 1);
-	mutex_unlock(&memcg_oom_mutex);
+	spin_unlock(&memcg_oom_lock);
 
 	return 0;
 }
@@ -4654,7 +4654,7 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 
 	BUG_ON(type != _OOM_TYPE);
 
-	mutex_lock(&memcg_oom_mutex);
+	spin_lock(&memcg_oom_lock);
 
 	list_for_each_entry_safe(ev, tmp, &mem->oom_notify, list) {
 		if (ev->eventfd == eventfd) {
@@ -4663,7 +4663,7 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
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
