Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7EF828E2
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:33:24 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id fy10so9261920pac.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 02:33:24 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y70si1182053pfa.0.2016.02.17.02.33.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 02:33:23 -0800 (PST)
Subject: [PATCH 4/6] mm,oom: exclude oom_task_origin processes if they are OOM-unkillable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
In-Reply-To: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
Message-Id: <201602171933.HFD51078.LOSFVMFQFOJHOt@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 19:33:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>From 4924ca3031444bfb831b2d4f004e5a613ad48d68 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 16:35:12 +0900
Subject: [PATCH 4/6] mm,oom: exclude oom_task_origin processes if they are OOM-unkillable.

oom_scan_process_thread() returns OOM_SCAN_SELECT when there is a
thread which returns oom_task_origin() == true. But it is possible
that that thread is marked as OOM-unkillable.

This patch changes oom_scan_process_thread() not to select it
if it is marked as OOM-unkillable.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b0c327d..ebc6764 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -308,7 +308,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * If task is allocating a lot of memory and has been marked to be
 	 * killed first if it triggers an oom, then select it.
 	 */
-	if (oom_task_origin(task) && !test_tsk_thread_flag(task, TIF_MEMDIE))
+	if (oom_task_origin(task) && !test_tsk_thread_flag(task, TIF_MEMDIE) &&
+	    task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN)
 		return OOM_SCAN_SELECT;
 
 	return OOM_SCAN_OK;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
