Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 854A36B0009
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 10:47:58 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id ik10so9881242igb.1
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 07:47:58 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p67si19965618iop.77.2016.01.23.07.47.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Jan 2016 07:47:57 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: make oom_killer_disable() killable.
Date: Sun, 24 Jan 2016 00:47:20 +0900
Message-Id: <1453564040-7492-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

While oom_killer_disable() is called by freeze_processes() after all user
threads except the current thread are frozen, it is possible that kernel
threads invoke the OOM killer and sends SIGKILL to the current thread due
to sharing the thawed victim's memory. Therefore, checking for SIGKILL is
preferable than TIF_MEMDIE.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6ebc0351..914451a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -613,15 +613,11 @@ void exit_oom_victim(struct task_struct *tsk)
 bool oom_killer_disable(void)
 {
 	/*
-	 * Make sure to not race with an ongoing OOM killer
-	 * and that the current is not the victim.
+	 * Make sure to not race with an ongoing OOM killer. Check that the
+	 * current is not killed (possibly due to sharing the victim's memory).
 	 */
-	mutex_lock(&oom_lock);
-	if (test_thread_flag(TIF_MEMDIE)) {
-		mutex_unlock(&oom_lock);
+	if (mutex_lock_killable(&oom_lock))
 		return false;
-	}
-
 	oom_killer_disabled = true;
 	mutex_unlock(&oom_lock);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
