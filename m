Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 25CC6828E2
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:30:54 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id q63so9369216pfb.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 02:30:54 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id lq6si1065659pab.140.2016.02.17.02.30.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 02:30:52 -0800 (PST)
Subject: [PATCH 2/6] mm,oom: don't abort on exiting processes when selecting a victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
In-Reply-To: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
Message-Id: <201602171930.AII18204.FMOSVFQFOJtLOH@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 19:30:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>From 22bd036766e70f0df38c38f3ecc226e857d20faf Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 16:30:59 +0900
Subject: [PATCH 2/6] mm,oom: don't abort on exiting processes when selecting a victim.

Currently, oom_scan_process_thread() returns OOM_SCAN_ABORT when there
is a thread which is exiting. But it is possible that that thread is
blocked at down_read(&mm->mmap_sem) in exit_mm() called from do_exit()
whereas one of threads sharing that memory is doing a GFP_KERNEL
allocation between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
(e.g. mmap()). Under such situation, the OOM killer does not choose a
victim, which results in silent OOM livelock problem.

This patch changes oom_scan_process_thread() not to return OOM_SCAN_ABORT
when there is a thread which is exiting.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 27949ef..a3868fd 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -311,9 +311,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	if (oom_task_origin(task))
 		return OOM_SCAN_SELECT;
 
-	if (task_will_free_mem(task) && !is_sysrq_oom(oc))
-		return OOM_SCAN_ABORT;
-
 	return OOM_SCAN_OK;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
