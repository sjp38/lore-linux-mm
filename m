Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 711DE6B0072
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 11:41:55 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so1981778wiw.7
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 08:41:55 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hs8si3107326wib.102.2014.12.05.08.41.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 08:41:54 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2 1/5] oom: add helpers for setting and clearing TIF_MEMDIE
Date: Fri,  5 Dec 2014 17:41:43 +0100
Message-Id: <1417797707-31699-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1417797707-31699-1-git-send-email-mhocko@suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

This patch is just a preparatory and it doesn't introduce any functional
change.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/oom.h |  4 ++++
 kernel/exit.c       |  2 +-
 mm/memcontrol.c     |  2 +-
 mm/oom_kill.c       | 23 ++++++++++++++++++++---
 4 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 4971874f54db..1315fcbb9527 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -47,6 +47,10 @@ static inline bool oom_task_origin(const struct task_struct *p)
 	return !!(p->signal->oom_flags & OOM_FLAG_ORIGIN);
 }
 
+extern void mark_tsk_oom_victim(struct task_struct *tsk);
+
+extern void unmark_tsk_oom_victim(void);
+
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
diff --git a/kernel/exit.c b/kernel/exit.c
index 5d30019ff953..ee5176e2a1ba 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -459,7 +459,7 @@ static void exit_mm(struct task_struct *tsk)
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
-	clear_thread_flag(TIF_MEMDIE);
+	unmark_tsk_oom_victim();
 }
 
 /*
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d6ac0e33e150..302e0fc6d121 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1735,7 +1735,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
-		set_thread_flag(TIF_MEMDIE);
+		mark_tsk_oom_victim(current);
 		return;
 	}
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5340f6b91312..c75b37d59a32 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -421,6 +421,23 @@ void note_oom_kill(void)
 	atomic_inc(&oom_kills);
 }
 
+/**
+ * Marks the given taks as OOM victim.
+ * @tsk: task to mark
+ */
+void mark_tsk_oom_victim(struct task_struct *tsk)
+{
+	set_tsk_thread_flag(tsk, TIF_MEMDIE);
+}
+
+/**
+ * Unmarks the current task as OOM victim.
+ */
+void unmark_tsk_oom_victim(void)
+{
+	clear_thread_flag(TIF_MEMDIE);
+}
+
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /*
  * Must be called while holding a reference to p, which will be released upon
@@ -444,7 +461,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (p->flags & PF_EXITING) {
-		set_tsk_thread_flag(p, TIF_MEMDIE);
+		mark_tsk_oom_victim(p);
 		put_task_struct(p);
 		return;
 	}
@@ -527,7 +544,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		}
 	rcu_read_unlock();
 
-	set_tsk_thread_flag(victim, TIF_MEMDIE);
+	mark_tsk_oom_victim(victim);
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	put_task_struct(victim);
 }
@@ -650,7 +667,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * quickly exit and free its memory.
 	 */
 	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
-		set_thread_flag(TIF_MEMDIE);
+		mark_tsk_oom_victim(current);
 		return;
 	}
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
