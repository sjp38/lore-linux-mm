Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 733D96B006E
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:06:34 -0400 (EDT)
Received: by wizk4 with SMTP id k4so111777621wiz.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:06:34 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id em10si34657565wjd.79.2015.04.27.12.06.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 12:06:30 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/9] mm: oom_kill: clean up victim marking and exiting interfaces
Date: Mon, 27 Apr 2015 15:05:48 -0400
Message-Id: <1430161555-6058-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Rename unmark_oom_victim() to exit_oom_victim().  Marking and
unmarking are related in functionality, but the interface is not
symmetrical at all: one is an internal OOM killer function used during
the killing, the other is for an OOM victim to signal its own death on
exit later on.  This has locking implications, see follow-up changes.

While at it, rename mark_tsk_oom_victim() to mark_oom_victim(), which
is easier on the eye.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 drivers/staging/android/lowmemorykiller.c |  2 +-
 include/linux/oom.h                       |  7 ++++---
 kernel/exit.c                             |  2 +-
 mm/memcontrol.c                           |  2 +-
 mm/oom_kill.c                             | 16 +++++++---------
 5 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index feafa17..2345ee7 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -165,7 +165,7 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 		 * infrastructure. There is no real reason why the selected
 		 * task should have access to the memory reserves.
 		 */
-		mark_tsk_oom_victim(selected);
+		mark_oom_victim(selected);
 		send_sig(SIGKILL, selected, 0);
 		rem += selected_tasksize;
 	}
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 44b2f6f..a8e6a49 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -47,9 +47,7 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return !!(p->signal->oom_flags & OOM_FLAG_ORIGIN);
 }
 
-extern void mark_tsk_oom_victim(struct task_struct *tsk);
-
-extern void unmark_oom_victim(void);
+extern void mark_oom_victim(struct task_struct *tsk);
 
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
@@ -75,6 +73,9 @@ extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 
 extern bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *mask, bool force_kill);
+
+extern void exit_oom_victim(void);
+
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
 
diff --git a/kernel/exit.c b/kernel/exit.c
index 22fcc05..185752a 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -436,7 +436,7 @@ static void exit_mm(struct task_struct *tsk)
 	mm_update_next_owner(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
-		unmark_oom_victim();
+		exit_oom_victim();
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14c2f20..54f8457 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1536,7 +1536,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
-		mark_tsk_oom_victim(current);
+		mark_oom_victim(current);
 		return;
 	}
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 73763e4..b2f081f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -408,13 +408,13 @@ bool oom_killer_disabled __read_mostly;
 static DECLARE_RWSEM(oom_sem);
 
 /**
- * mark_tsk_oom_victim - marks the given task as OOM victim.
+ * mark_oom_victim - mark the given task as OOM victim
  * @tsk: task to mark
  *
  * Has to be called with oom_sem taken for read and never after
  * oom has been disabled already.
  */
-void mark_tsk_oom_victim(struct task_struct *tsk)
+void mark_oom_victim(struct task_struct *tsk)
 {
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
@@ -431,11 +431,9 @@ void mark_tsk_oom_victim(struct task_struct *tsk)
 }
 
 /**
- * unmark_oom_victim - unmarks the current task as OOM victim.
- *
- * Wakes up all waiters in oom_killer_disable()
+ * exit_oom_victim - note the exit of an OOM victim
  */
-void unmark_oom_victim(void)
+void exit_oom_victim(void)
 {
 	if (!test_and_clear_thread_flag(TIF_MEMDIE))
 		return;
@@ -515,7 +513,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 */
 	task_lock(p);
 	if (p->mm && task_will_free_mem(p)) {
-		mark_tsk_oom_victim(p);
+		mark_oom_victim(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -570,7 +568,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
-	mark_tsk_oom_victim(victim);
+	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -728,7 +726,7 @@ static void __out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 */
 	if (current->mm &&
 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
-		mark_tsk_oom_victim(current);
+		mark_oom_victim(current);
 		return;
 	}
 
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
