Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FACC6B0263
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:30:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so31597597pfx.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:30:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v76si4207603pfa.20.2016.07.12.06.30.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 06:30:19 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 7/8] mm,oom: Stop clearing TIF_MEMDIE on remote thread.
Date: Tue, 12 Jul 2016 22:29:22 +0900
Message-Id: <1468330163-4405-8-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Since no kernel code path needs to clear TIF_MEMDIE flag on a remote
thread we can drop the task parameter and enforce that actually.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h | 2 +-
 kernel/exit.c       | 2 +-
 mm/oom_kill.c       | 5 ++---
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 27be4ba..90e98ea 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -90,7 +90,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 
 extern bool out_of_memory(struct oom_control *oc);
 
-extern void exit_oom_victim(struct task_struct *tsk);
+extern void exit_oom_victim(void);
 
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/kernel/exit.c b/kernel/exit.c
index 84ae830..1b1dada 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -511,7 +511,7 @@ static void exit_mm(struct task_struct *tsk)
 	mm_update_next_owner(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim(tsk);
+		exit_oom_victim();
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7ee6b70..fab0bec 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -692,10 +692,9 @@ void mark_oom_victim(struct task_struct *tsk)
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
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
