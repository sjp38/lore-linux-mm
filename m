Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 053E36B0070
	for <linux-mm@kvack.org>; Sat, 22 Nov 2014 23:50:11 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id z10so7817049pdj.40
        for <linux-mm@kvack.org>; Sat, 22 Nov 2014 20:50:10 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j4si15507155pdm.235.2014.11.22.20.50.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 22 Nov 2014 20:50:09 -0800 (PST)
Received: from fsav204.sakura.ne.jp (fsav204.sakura.ne.jp [210.224.168.166])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4o6EJ080830
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:50:06 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4o64K080827
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:50:06 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [PATCH 1/5] mm: Introduce OOM kill timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
In-Reply-To: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
Message-Id: <201411231350.DDH78622.LOtOQOFMFSHFJV@I-love.SAKURA.ne.jp>
Date: Sun, 23 Nov 2014 13:50:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

>From ca8b3ee4bea5bcc6f8ec5e8496a97fd4cab5a440 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 23 Nov 2014 13:38:53 +0900
Subject: [PATCH 1/5] mm: Introduce OOM kill timeout.

Regarding many of Linux kernel versions (from unknown till now), any
local user can give a certain type of memory pressure which causes
__alloc_pages_nodemask() to keep trying to reclaim memory for presumably
forever. As a consequence, such user can disturb any users' activities
by keeping the system stalled with 0% or 100% CPU usage.

On systems where XFS is used, SysRq-f (forced OOM killer) may become
unresponsive because kernel worker thread which is supposed to process
SysRq-f request is blocked by previous request's GFP_WAIT allocation.

The problem described above is one of phenomena which is triggered by
a vulnerability which exists since (if I didn't miss something)
Linux 2.0 (18 years ago). However, it is too difficult to backport
patches which fix the vulnerability.

Setting TIF_MEMDIE to SIGKILL'ed and/or PF_EXITING thread disables
the OOM killer. But the TIF_MEMDIE thread may not be able to terminate
within reasonable duration for some reason. Therefore, in order to avoid
keeping the OOM killer disabled forever, this patch introduces 5 seconds
timeout for TIF_MEMDIE threads which are supposed to terminate shortly.

Android platform's low memory killer is already using 1 second timeout
for TIF_MEMDIE threads. This patch is for generic platforms.

Note that this patch does not help unless out_of_memory() is called.
For example, if all threads were looping at

  while (unlikely(too_many_isolated(zone, file, sc))) {
          congestion_wait(BLK_RW_ASYNC, HZ/10);

          /* We are about to die and free our memory. Return now. */
          if (fatal_signal_pending(current))
                  return SWAP_CLUSTER_MAX;
  }

in shrink_inactive_list() when kswapd is sleeping inside shrinker
functions, the system will stall forever with 0% CPU usage.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/staging/android/lowmemorykiller.c |  2 +-
 include/linux/mm.h                        |  2 ++
 include/linux/sched.h                     |  2 ++
 mm/memcontrol.c                           |  2 +-
 mm/oom_kill.c                             | 35 ++++++++++++++++++++++++++++---
 5 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index b545d3d..819bc36 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -160,7 +160,7 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 			     selected->pid, selected->comm,
 			     selected_oom_score_adj, selected_tasksize);
 		lowmem_deathpending_timeout = jiffies + HZ;
-		set_tsk_thread_flag(selected, TIF_MEMDIE);
+		set_memdie_flag(selected);
 		send_sig(SIGKILL, selected, 0);
 		rem += selected_tasksize;
 	}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b464611..8b187fe 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2161,5 +2161,7 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+void set_memdie_flag(struct task_struct *task);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5e344bb..f1626c3 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1661,6 +1661,8 @@ struct task_struct {
 	unsigned int	sequential_io;
 	unsigned int	sequential_io_avg;
 #endif
+	/* Set when TIF_MEMDIE flag is set to this thread. */
+	unsigned long memdie_start;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d6ac0e3..bf51518 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1735,7 +1735,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
-		set_thread_flag(TIF_MEMDIE);
+		set_memdie_flag(current);
 		return;
 	}
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5340f6b..678c431 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -134,6 +134,19 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
 
+	/* p may not be terminated within reasonale duration */
+	if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+		smp_rmb(); /* set_memdie_flag() uses smp_wmb(). */
+		if (time_after(jiffies, p->memdie_start + 5 * HZ)) {
+			static unsigned char warn = 255;
+			char comm[sizeof(p->comm)];
+
+			if (warn && warn--)
+				pr_err("Process %d (%s) was not killed within 5 seconds.\n",
+				       task_pid_nr(p), get_task_comm(comm, p));
+			return true;
+		}
+	}
 	return false;
 }
 
@@ -444,7 +457,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (p->flags & PF_EXITING) {
-		set_tsk_thread_flag(p, TIF_MEMDIE);
+		set_memdie_flag(p);
 		put_task_struct(p);
 		return;
 	}
@@ -527,7 +540,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		}
 	rcu_read_unlock();
 
-	set_tsk_thread_flag(victim, TIF_MEMDIE);
+	set_memdie_flag(victim);
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	put_task_struct(victim);
 }
@@ -650,7 +663,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
-		set_thread_flag(TIF_MEMDIE);
+		set_memdie_flag(current);
 		return;
 	}
 
@@ -711,3 +724,19 @@ void pagefault_out_of_memory(void)
 		oom_zonelist_unlock(zonelist, GFP_KERNEL);
 	}
 }
+
+void set_memdie_flag(struct task_struct *task)
+{
+	if (test_tsk_thread_flag(task, TIF_MEMDIE))
+		return;
+	/*
+	 * Allow oom_unkillable_task() to take into account whether
+	 * the thread cannot be terminated immediately for some reason
+	 * (e.g. waiting on unkillable lock, waiting for completion by
+	 * other thread).
+	 */
+	task->memdie_start = jiffies;
+	smp_wmb(); /* oom_unkillable_task() uses smp_rmb(). */
+	set_tsk_thread_flag(task, TIF_MEMDIE);
+}
+EXPORT_SYMBOL(set_memdie_flag);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
