Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E564C6B0261
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:04:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so13228863wme.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:04:38 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id wt3si30107208wjb.215.2016.04.26.07.04.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 07:04:37 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id w143so4729572wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:04:37 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm, oom_reaper: hide oom reaped tasks from OOM killer more carefully
Date: Tue, 26 Apr 2016 16:04:29 +0200
Message-Id: <1461679470-8364-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461679470-8364-1-git-send-email-mhocko@kernel.org>
References: <1461679470-8364-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

36324a990cf5 ("oom: clear TIF_MEMDIE after oom_reaper managed to unmap
the address space") not only clears TIF_MEMDIE for oom reaped task
but also set OOM_SCORE_ADJ_MIN for the target task to hide it from
the oom killer. This works in simple cases but it is not sufficient
for (unlikely) cases where the mm is shared between independent
processes (as they do not share signal struct). If the mm had only
small amount of memory which could be reaped then another task
sharing the mm could be selected and that wouldn't help to move out from
the oom situation.

Introduce MMF_OOM_REAPED mm flag which is checked in oom_badness (same
as OOM_SCORE_ADJ_MIN) and task is skipped if the flag is set.  Set the
flag after __oom_reap_task is done with a task. This will force the
select_bad_process() to ignore all already oom reaped tasks as well as
no such task is sacrificed for its parent.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h | 1 +
 mm/oom_kill.c         | 9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index acfc32b30704..7bd0fa9db199 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -512,6 +512,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
+#define MMF_OOM_REAPED		21	/* mm has been already reaped */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 415f7eb913fa..c0376efa79ec 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -174,8 +174,13 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	if (!p)
 		return 0;
 
+	/*
+	 * Do not even consider tasks which are explicitly marked oom
+	 * unkillable or have been already oom reaped.
+	 */
 	adj = (long)p->signal->oom_score_adj;
-	if (adj == OOM_SCORE_ADJ_MIN) {
+	if (adj == OOM_SCORE_ADJ_MIN ||
+			test_bit(MMF_OOM_REAPED, &p->mm->flags)) {
 		task_unlock(p);
 		return 0;
 	}
@@ -513,7 +518,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * This task can be safely ignored because we cannot do much more
 	 * to release its memory.
 	 */
-	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
+	set_bit(MMF_OOM_REAPED, &mm->flags);
 out:
 	mmput(mm);
 	return ret;
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
