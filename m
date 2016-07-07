Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2388A6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:08:01 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t74so50242515ioi.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 09:08:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p82si216135oih.291.2016.07.07.09.08.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 09:08:00 -0700 (PDT)
Subject: [PATCH 6/6] mm,oom: Stop clearing TIF_MEMDIE on remote thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
In-Reply-To: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
Message-Id: <201607080107.ADG65168.QJLFFOFOHMOSVt@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jul 2016 01:07:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

>From fefcbf2412e38b006281cf1d20f9e3a2bb76714f Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jul 2016 00:42:48 +0900
Subject: [PATCH 6/6] mm,oom: Stop clearing TIF_MEMDIE on remote thread.

Since oom_has_pending_mm() controls whether to select next OOM victim,
we are no longer clearing TIF_MEMDIE on remote thread.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
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
index b6b79ae..d120cb1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -632,10 +632,9 @@ void mark_oom_victim(struct task_struct *tsk)
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
