Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D0C746B0266
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 15:42:56 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so22491667lfe.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 12:42:56 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id jv2si14694037wjc.268.2016.07.28.12.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 12:42:47 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so12632233wme.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 12:42:47 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 07/10] mm, oom: enforce exit_oom_victim on current task
Date: Thu, 28 Jul 2016 21:42:31 +0200
Message-Id: <1469734954-31247-8-git-send-email-mhocko@kernel.org>
In-Reply-To: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
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
index 14a0f15c0c59..22e18c4adc98 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -102,7 +102,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 
 extern bool out_of_memory(struct oom_control *oc);
 
-extern void exit_oom_victim(struct task_struct *tsk);
+extern void exit_oom_victim(void);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/kernel/exit.c b/kernel/exit.c
index 9e6e1356e6bb..c742c37c3a92 100644
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
index 300957e59246..ca1cc24ba720 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -651,10 +651,9 @@ void mark_oom_victim(struct task_struct *tsk)
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
