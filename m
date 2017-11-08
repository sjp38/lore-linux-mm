Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92D704403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 05:44:06 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id l5so1817476oib.0
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 02:44:06 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s203si1798144oig.470.2017.11.08.02.44.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 02:44:04 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom_reaper: Remove pointless kthread_run() error check.
Date: Wed,  8 Nov 2017 19:43:20 +0900
Message-Id: <1510137800-4602-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Since oom_init() is called before userspace processes start, memory
allocation failure for creating the OOM reaper kernel thread will let
the OOM killer call panic() rather than wake up the OOM reaper.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8dd0e08..85eced9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -641,9 +641,6 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	if (!oom_reaper_th)
-		return;
-
 	/* tsk is already queued? */
 	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
 		return;
@@ -661,11 +658,6 @@ static void wake_oom_reaper(struct task_struct *tsk)
 static int __init oom_init(void)
 {
 	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
-	if (IS_ERR(oom_reaper_th)) {
-		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
-				PTR_ERR(oom_reaper_th));
-		oom_reaper_th = NULL;
-	}
 	return 0;
 }
 subsys_initcall(oom_init)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
