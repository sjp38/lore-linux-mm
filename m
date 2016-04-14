Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B312C6B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 06:57:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so122524303pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 03:57:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n6si8809854pfa.10.2016.04.14.03.57.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 03:57:42 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom_reaper: Use try_oom_reaper() for reapability test.
Date: Thu, 14 Apr 2016 19:56:30 +0900
Message-Id: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Assuming that try_oom_reaper() is correctly implemented, we should use
try_oom_reaper() for testing "whether the OOM reaper is allowed to reap
the OOM victim's memory" rather than "whether the OOM killer is allowed
to send SIGKILL to thread groups sharing the OOM victim's memory",
for the OOM reaper is allowed to reap the OOM victim's memory even if
that memory is shared by OOM_SCORE_ADJ_MIN but already-killed-or-exiting
thread groups.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7098104..e78818d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -648,10 +648,6 @@ subsys_initcall(oom_init)
 static void try_oom_reaper(struct task_struct *tsk)
 {
 }
-
-static void wake_oom_reaper(struct task_struct *tsk)
-{
-}
 #endif
 
 /**
@@ -741,7 +737,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -833,22 +828,18 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		if (same_thread_group(p, victim))
 			continue;
-		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-			/*
-			 * We cannot use oom_reaper for the mm shared by this
-			 * process because it wouldn't get killed and so the
-			 * memory might be still used.
-			 */
-			can_oom_reap = false;
+		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
-		}
+		if (is_global_init(p))
+			continue;
+		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+			continue;
+
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
-		wake_oom_reaper(victim);
+	try_oom_reaper(victim);
 
 	mmdrop(mm);
 	put_task_struct(victim);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
