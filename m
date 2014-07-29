Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 015616B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 19:39:22 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so1881817igd.2
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 16:39:22 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id j9si27942013igm.47.2014.07.29.16.39.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 16:39:22 -0700 (PDT)
Received: by mail-ie0-f179.google.com with SMTP id rl12so432232iec.38
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 16:39:22 -0700 (PDT)
Date: Tue, 29 Jul 2014 16:39:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: remove unnecessary exit_state check
Message-ID: <alpine.DEB.2.02.1407291638310.858@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The oom killer scans each process and determines whether it is eligible for oom 
kill or whether the oom killer should abort because of concurrent memory 
freeing.  It will abort when an eligible process is found to have TIF_MEMDIE 
set, meaning it has already been oom killed and we're waiting for it to exit.

Processes with task->mm == NULL should not be considered because they are either 
kthreads or have already detached their memory and killing them would not lead 
to memory freeing.  That memory is only freed after exit_mm() has returned, 
however, and not when task->mm is first set to NULL.

Clear TIF_MEMDIE after exit_mm()'s mmput() so that an oom killed process is no 
longer considered for oom kill, but only until exit_mm() has returned.  This was 
fragile in the past because it relied on exit_notify() to be reached before no 
longer considering TIF_MEMDIE processes.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 kernel/exit.c | 1 +
 mm/oom_kill.c | 2 --
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -455,6 +455,7 @@ static void exit_mm(struct task_struct * tsk)
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
+	clear_thread_flag(TIF_MEMDIE);
 }
 
 /*
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -258,8 +258,6 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 		unsigned long totalpages, const nodemask_t *nodemask,
 		bool force_kill)
 {
-	if (task->exit_state)
-		return OOM_SCAN_CONTINUE;
 	if (oom_unkillable_task(task, NULL, nodemask))
 		return OOM_SCAN_CONTINUE;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
