Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47D756B007E
	for <linux-mm@kvack.org>; Sat, 28 May 2016 07:25:05 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 85so226195308ioq.3
        for <linux-mm@kvack.org>; Sat, 28 May 2016 04:25:05 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i6si13941128oih.238.2016.05.28.04.25.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 28 May 2016 04:25:04 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Allow SysRq-f to always select !TIF_MEMDIE thread group.
Date: Sat, 28 May 2016 19:53:04 +0900
Message-Id: <1464432784-6058-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>

There has been two problems about SysRq-f (manual invocation of the OOM
killer). One is that moom_callback() is not called by moom_work under OOM
livelock situation because it does not have a dedicated WQ like vmstat_wq.
The other is that select_bad_process() selects a thread group which
already has a TIF_MEMDIE thread because oom_scan_process_thread() was
scanning all threads of all thread groups and find_lock_task_mm() can
return a TIF_MEMDIE thread.

Since commit f44666b04605d1c7 ("mm,oom: speed up select_bad_process()
loop") changed oom_scan_process_group() to use task->signal->oom_victims,
the OOM killer will no longer select a thread group which already has a
TIF_MEMDIE thread. But SysRq-f will select such thread group due to
returning OOM_SCAN_OK.

Although we will change oom_badness() to return 0 after the OOM reaper
gave up reaping the OOM victim's mm, currently there is possibility that
the OOM reaper is not called (due to "the OOM victim's mm is shared by
unkillable threads" or "the OOM reaper thread is not available due to
kthread_run() failure or CONFIG_MMU=n"). Therefore, we need to make sure
that SysRq-f will skip oom_badness() if such thread group has a TIF_MEMDIE
thread.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1685890..c16331c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -283,8 +283,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves.
 	 */
-	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
-		return OOM_SCAN_ABORT;
+	if (atomic_read(&task->signal->oom_victims))
+		return !is_sysrq_oom(oc) ? OOM_SCAN_ABORT : OOM_SCAN_CONTINUE;
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
