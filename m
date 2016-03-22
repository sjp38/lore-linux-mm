Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5A96B0265
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:01:20 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id l68so186705589wml.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:20 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id a27si19781593wmi.46.2016.03.22.04.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 04:01:12 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id u125so2597686wmg.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:12 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 9/9] oom, oom_reaper: protect oom_reaper_list using simpler way
Date: Tue, 22 Mar 2016 12:00:26 +0100
Message-Id: <1458644426-22973-10-git-send-email-mhocko@kernel.org>
In-Reply-To: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

"oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task" tried
to protect oom_reaper_list using MMF_OOM_KILLED flag. But we can do it
by simply checking tsk->oom_reaper_list != NULL.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h | 2 --
 mm/oom_kill.c         | 8 ++------
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index d118445a332e..78434d4f85f2 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -511,8 +511,6 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 
-#define MMF_OOM_KILLED		21	/* OOM killer has chosen this mm */
-
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
 struct sighand_struct {
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bed2885d10b0..cfafb91ebcd9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -546,7 +546,7 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	if (!oom_reaper_th)
+	if (!oom_reaper_th || tsk->oom_reaper_list)
 		return;
 
 	get_task_struct(tsk);
@@ -680,7 +680,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap;
+	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -742,10 +742,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
 	atomic_inc(&mm->mm_count);
-
-	/* Make sure we do not try to oom reap the mm multiple times */
-	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);
-
 	/*
 	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
 	 * the OOM victim from depleting the memory reserves from the user
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
