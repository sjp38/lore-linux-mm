Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id CF25F6B006C
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 06:06:08 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id l15so1548875wiw.4
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 03:06:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wq5si18378253wjc.172.2015.01.09.03.06.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 03:06:08 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v3 1/5] oom: add helpers for setting and clearing TIF_MEMDIE
Date: Fri,  9 Jan 2015 12:05:51 +0100
Message-Id: <1420801555-22659-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1420801555-22659-1-git-send-email-mhocko@suse.cz>
References: <1420801555-22659-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

This patch is just a preparatory and it doesn't introduce any functional
change.

Note:
I am utterly unhappy about lowmemory killer abusing TIF_MEMDIE just to
wait for the oom victim and to prevent from new killing. This is
just a side effect of the flag. The primary meaning is to give the oom
victim access to the memory reserves and that shouldn't be necessary
here.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 drivers/staging/android/lowmemorykiller.c |  7 ++++++-
 include/linux/oom.h                       |  4 ++++
 kernel/exit.c                             |  2 +-
 mm/memcontrol.c                           |  2 +-
 mm/oom_kill.c                             | 23 ++++++++++++++++++++---
 5 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index b545d3d1da3e..feafa172b155 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -160,7 +160,12 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 			     selected->pid, selected->comm,
 			     selected_oom_score_adj, selected_tasksize);
 		lowmem_deathpending_timeout = jiffies + HZ;
-		set_tsk_thread_flag(selected, TIF_MEMDIE);
+		/*
+		 * FIXME: lowmemorykiller shouldn't abuse global OOM killer
+		 * infrastructure. There is no real reason why the selected
+		 * task should have access to the memory reserves.
+		 */
+		mark_tsk_oom_victim(selected);
 		send_sig(SIGKILL, selected, 0);
 		rem += selected_tasksize;
 	}
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 76200984d1e2..b42b80f88c3a 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -47,6 +47,10 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return !!(p->signal->oom_flags & OOM_FLAG_ORIGIN);
 }
 
+extern void mark_tsk_oom_victim(struct task_struct *tsk);
+
+extern void unmark_oom_victim(void);
+
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
diff --git a/kernel/exit.c b/kernel/exit.c
index 287884b05b89..5db52e52c493 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -456,7 +456,7 @@ static void exit_mm(struct task_struct *tsk)
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
-	clear_thread_flag(TIF_MEMDIE);
+	unmark_oom_victim();
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0021313d1210..18ecef729597 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1559,7 +1559,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
-		set_thread_flag(TIF_MEMDIE);
+		mark_tsk_oom_victim(current);
 		return;
 	}
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 294493a7ae4b..80b34e285f96 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -416,6 +416,23 @@ void note_oom_kill(void)
 	atomic_inc(&oom_kills);
 }
 
+/**
+ * mark_tsk_oom_victim - marks the given taks as OOM victim.
+ * @tsk: task to mark
+ */
+void mark_tsk_oom_victim(struct task_struct *tsk)
+{
+	set_tsk_thread_flag(tsk, TIF_MEMDIE);
+}
+
+/**
+ * unmark_oom_victim - unmarks the current task as OOM victim.
+ */
+void unmark_oom_victim(void)
+{
+	clear_thread_flag(TIF_MEMDIE);
+}
+
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /*
  * Must be called while holding a reference to p, which will be released upon
@@ -440,7 +457,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 */
 	task_lock(p);
 	if (p->mm && task_will_free_mem(p)) {
-		set_tsk_thread_flag(p, TIF_MEMDIE);
+		mark_tsk_oom_victim(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -495,7 +512,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
-	set_tsk_thread_flag(victim, TIF_MEMDIE);
+	mark_tsk_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -652,7 +669,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 */
 	if (current->mm &&
 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
-		set_thread_flag(TIF_MEMDIE);
+		mark_tsk_oom_victim(current);
 		return;
 	}
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
