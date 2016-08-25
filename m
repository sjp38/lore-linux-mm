Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A7DC483093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 06:03:41 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so28685258lfe.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:41 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 3si12963342wjs.264.2016.08.25.03.03.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 03:03:35 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i5so6652736wmg.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:35 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2 7/9] mm, oom: enforce exit_oom_victim on current task
Date: Thu, 25 Aug 2016 12:03:12 +0200
Message-Id: <1472119394-11342-8-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
References: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

There are no users of exit_oom_victim on !current task anymore so
enforce the API to always work on the current.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h | 2 +-
 kernel/exit.c       | 2 +-
 mm/oom_kill.c       | 5 ++---
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 0f1b9da108e4..b4e36e92bc87 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -69,7 +69,7 @@ extern unsigned long oom_badness(struct task_struct *p,
 
 extern bool out_of_memory(struct oom_control *oc);
 
-extern void exit_oom_victim(struct task_struct *tsk);
+extern void exit_oom_victim(void);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/kernel/exit.c b/kernel/exit.c
index bbdef62d6e3b..c36f8e0ab66d 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -435,7 +435,7 @@ static void exit_mm(struct task_struct *tsk)
 	mm_update_next_owner(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim(tsk);
+		exit_oom_victim();
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 895a51fe8e18..3b990544db6d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -662,10 +662,9 @@ static void mark_oom_victim(struct task_struct *tsk)
 /**
  * exit_oom_victim - note the exit of an OOM victim
  */
-void exit_oom_victim(struct task_struct *tsk)
+void exit_oom_victim(void)
 {
-	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
-		return;
+	clear_thread_flag(TIF_MEMDIE);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
