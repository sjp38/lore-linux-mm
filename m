Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 37F73800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 08:46:53 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id e186so9808397iof.9
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 05:46:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f67si5958019itb.164.2018.01.22.05.46.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 Jan 2018 05:46:51 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
Date: Mon, 22 Jan 2018 22:46:22 +0900
Message-Id: <1516628782-3524-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

When I was examining a bug which occurs under CPU + memory pressure, I
observed that a thread which called out_of_memory() can sleep for minutes
at schedule_timeout_killable(1) with oom_lock held when many threads are
doing direct reclaim.

--------------------
[  163.357628] b.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[  163.360946] CPU: 0 PID: 554 Comm: b.out Not tainted 4.15.0-rc8+ #216
(...snipped...)
[  163.470193] Out of memory: Kill process 548 (b.out) score 6 or sacrifice child
[  163.471813] Killed process 1191 (b.out) total-vm:2108kB, anon-rss:60kB, file-rss:4kB, shmem-rss:0kB
(...snipped...)
[  248.016033] sysrq: SysRq : Show State
(...snipped...)
[  249.625720] b.out           R  running task        0   554    538 0x00000004
[  249.627778] Call Trace:
[  249.628513]  __schedule+0x142/0x4b2
[  249.629394]  schedule+0x27/0x70
[  249.630114]  schedule_timeout+0xd1/0x160
[  249.631029]  ? oom_kill_process+0x396/0x400
[  249.632039]  ? __next_timer_interrupt+0xc0/0xc0
[  249.633087]  schedule_timeout_killable+0x15/0x20
[  249.634097]  out_of_memory+0xea/0x270
[  249.634901]  __alloc_pages_nodemask+0x715/0x880
[  249.635920]  handle_mm_fault+0x538/0xe40
[  249.636888]  ? __enqueue_entity+0x63/0x70
[  249.637787]  ? set_next_entity+0x4b/0x80
[  249.638687]  __do_page_fault+0x199/0x430
[  249.639535]  ? vmalloc_sync_all+0x180/0x180
[  249.640452]  do_page_fault+0x1a/0x1e
[  249.641283]  common_exception+0x82/0x8a
(...snipped...)
[  462.676366] oom_reaper: reaped process 1191 (b.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
--------------------

--------------------
[  269.985819] b.out invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  269.988570] CPU: 0 PID: 9079 Comm: b.out Not tainted 4.15.0-rc8+ #217
(...snipped...)
[  270.073050] Out of memory: Kill process 914 (b.out) score 9 or sacrifice child
[  270.074660] Killed process 2208 (b.out) total-vm:2108kB, anon-rss:64kB, file-rss:4kB, shmem-rss:0kB
[  297.562824] sysrq: SysRq : Show State
(...snipped...)
[  471.716610] b.out           R  running task        0  9079   7400 0x00000000
[  471.718203] Call Trace:
[  471.718784]  __schedule+0x142/0x4b2
[  471.719577]  schedule+0x27/0x70
[  471.720294]  schedule_timeout+0xd1/0x160
[  471.721207]  ? oom_kill_process+0x396/0x400
[  471.722151]  ? __next_timer_interrupt+0xc0/0xc0
[  471.723215]  schedule_timeout_killable+0x15/0x20
[  471.724350]  out_of_memory+0xea/0x270
[  471.725201]  __alloc_pages_nodemask+0x715/0x880
[  471.726238]  ? radix_tree_lookup_slot+0x1f/0x50
[  471.727253]  filemap_fault+0x346/0x510
[  471.728120]  ? filemap_map_pages+0x245/0x2d0
[  471.729105]  ? unlock_page+0x30/0x30
[  471.729987]  __xfs_filemap_fault.isra.18+0x2d/0xb0
[  471.731488]  ? unlock_page+0x30/0x30
[  471.732364]  xfs_filemap_fault+0xa/0x10
[  471.733260]  __do_fault+0x11/0x30
[  471.734033]  handle_mm_fault+0x8e8/0xe40
[  471.735200]  __do_page_fault+0x199/0x430
[  471.736163]  ? common_exception+0x82/0x8a
[  471.737102]  ? vmalloc_sync_all+0x180/0x180
[  471.738061]  do_page_fault+0x1a/0x1e
[  471.738881]  common_exception+0x82/0x8a
(...snipped...)
[  566.969400] oom_reaper: reaped process 2208 (b.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
--------------------

Allowing the OOM reaper to start reclaiming memory without waiting for
the oom_lock is not sufficient if the OOM reaper did not reclaim enough
memory. We need to make sure that the thread which called out_of_memory()
will release oom_lock shortly. Thus, this patch brings the short sleep
to outside of the OOM killer.

For __alloc_pages_may_oom() case, this patch uses uninterruptible sleep
than killable sleep because fatal_signal_pending() threads won't be able
to use memory reserves unless tsk_is_oom_victim() becomes true.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/oom_kill.c   | 18 +++---------------
 mm/page_alloc.c |  3 ++-
 2 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8219001..47212442 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1078,7 +1078,6 @@ bool out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
-	bool delay = false; /* if set, delay next allocation attempt */
 
 	if (oom_killer_disabled)
 		return false;
@@ -1128,10 +1127,8 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
-	if (mem_cgroup_select_oom_victim(oc) && oom_kill_memcg_victim(oc)) {
-		delay = true;
+	if (mem_cgroup_select_oom_victim(oc) && oom_kill_memcg_victim(oc))
 		goto out;
-	}
 
 	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
@@ -1139,20 +1136,10 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (oc->chosen_task && oc->chosen_task != INFLIGHT_VICTIM) {
+	if (oc->chosen_task && oc->chosen_task != INFLIGHT_VICTIM)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
 				 "Memory cgroup out of memory");
-		delay = true;
-	}
-
 out:
-	/*
-	 * Give the killed process a good chance to exit before trying
-	 * to allocate memory again.
-	 */
-	if (delay)
-		schedule_timeout_killable(1);
-
 	return !!oc->chosen_task;
 }
 
@@ -1178,4 +1165,5 @@ void pagefault_out_of_memory(void)
 		return;
 	out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
+	schedule_timeout_killable(1);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4093728..e93bff1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3355,7 +3355,6 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	 */
 	if (!mutex_trylock(&oom_lock)) {
 		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
 
@@ -4116,6 +4115,8 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;
+		if (!tsk_is_oom_victim(current))
+			schedule_timeout_uninterruptible(1);
 		goto retry;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
