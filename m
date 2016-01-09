Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 89244828DE
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 06:05:03 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id cy9so296033770pac.0
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 03:05:03 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id xp4si23694731pab.1.2016.01.09.03.05.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 09 Jan 2016 03:05:02 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: make oom_killer_disable() killable.
Date: Sat,  9 Jan 2016 20:04:45 +0900
Message-Id: <1452337485-8273-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org, rientjes@google.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

While oom_killer_disable() is called by freeze_processes() after all user
threads except the current thread are frozen, it is possible that kernel
threads invoke the OOM killer and sends SIGKILL to the current thread due
to sharing the thawed victim's memory. Therefore, checking for SIGKILL is
preferable than TIF_MEMDIE.

Also, it is possible that the thawed victim fails to terminate due to
invisible dependency. Therefore, waiting with timeout is preferable.
The timeout is copied from __usermodehelper_disable() called by
freeze_processes().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b8a4210..bafa6b2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -612,21 +612,19 @@ void exit_oom_victim(void)
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
 
-	wait_event(oom_victims_wait, !atomic_read(&oom_victims));
-
-	return true;
+	/* Do not wait forever in case existing victims got stuck. */
+	if (!wait_event_timeout(oom_victims_wait, !atomic_read(&oom_victims),
+				5 * HZ))
+		oom_killer_disabled = false;
+	return oom_killer_disabled;
 }
 
 /**
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
