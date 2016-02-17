Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4BBA7828E2
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:32:13 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id y8so120595822igp.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 02:32:13 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y1si41629212iga.101.2016.02.17.02.32.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 02:32:12 -0800 (PST)
Subject: [PATCH 3/6] mm,oom: exclude oom_task_origin processes if they are OOM victims.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
In-Reply-To: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
Message-Id: <201602171932.IDB09391.FSOOtHJLQVFMFO@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 19:32:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>From f5531e726caad7431020c027b6900a8e2c678345 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 16:32:37 +0900
Subject: [PATCH 3/6] mm,oom: exclude oom_task_origin processes if they are OOM victims.

Currently, oom_scan_process_thread() returns OOM_SCAN_SELECT when there
is a thread which returns oom_task_origin() == true. But it is possible
that that thread is sharing memory with OOM-unkillable processes or the
OOM reaper fails to reclaim enough memory. In that case, we must not
continue selecting such threads forever.

This patch changes oom_scan_process_thread() not to select a thread
which returns oom_task_origin() = true if TIF_MEMDIE is already set
because SysRq-f case can reach here. Since "mm,oom: exclude TIF_MEMDIE
processes from candidates." made sure that we will choose a !TIF_MEMDIE
thread when only some of threads are marked TIF_MEMDIE, we don't need to
check all threads which returns oom_task_origin() == true.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index a3868fd..b0c327d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -308,7 +308,7 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * If task is allocating a lot of memory and has been marked to be
 	 * killed first if it triggers an oom, then select it.
 	 */
-	if (oom_task_origin(task))
+	if (oom_task_origin(task) && !test_tsk_thread_flag(task, TIF_MEMDIE))
 		return OOM_SCAN_SELECT;
 
 	return OOM_SCAN_OK;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
