Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 38BFF6B0009
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 09:31:55 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id xk3so16266543obc.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 06:31:55 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id ko1si1806437obb.46.2016.02.17.06.31.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 06:31:54 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2] mm,oom: don't abort on exiting processes when selecting a victim.
Date: Wed, 17 Feb 2016 23:31:25 +0900
Message-Id: <1455719485-7730-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>

Currently, oom_scan_process_thread() returns OOM_SCAN_ABORT when there is
a thread which is exiting. But it is possible that that thread is blocked
at down_read(&mm->mmap_sem) in exit_mm() called from do_exit() whereas
one of threads sharing that memory is doing a GFP_KERNEL allocation
between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
(e.g. mmap()).

----------
T1                  T2
                    Calls mmap()
Calls _exit(0)
                    Arrives at vm_mmap_pgoff()
Arrives at do_exit()
Gets PF_EXITING via exit_signals()
                    Calls down_write(&mm->mmap_sem)
                    Calls do_mmap_pgoff()
Calls down_read(&mm->mmap_sem) from exit_mm()
                    Calls out of memory via a GFP_KERNEL allocation but
                    oom_scan_process_thread(T1) returns OOM_SCAN_ABORT
----------

down_read(&mm->mmap_sem) by T1 is waiting for up_write(&mm->mmap_sem) by
T2 while oom_scan_process_thread() by T2 is waiting for T1 to set
T1->mm = NULL. Under such situation, the OOM killer does not choose
a victim, which results in silent OOM livelock problem.

This patch changes oom_scan_process_thread() not to return OOM_SCAN_ABORT
when there is a thread which is exiting.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/oom_kill.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index cf87153..6e6abaf 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -292,9 +292,6 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
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
