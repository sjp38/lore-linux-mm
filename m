Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD506B007E
	for <linux-mm@kvack.org>; Sat, 28 May 2016 13:25:06 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w143so215728666oiw.3
        for <linux-mm@kvack.org>; Sat, 28 May 2016 10:25:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c70si18876365itc.34.2016.05.28.10.25.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 28 May 2016 10:25:05 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2] mm,oom: Allow SysRq-f to always select !TIF_MEMDIE thread group.
Date: Sun, 29 May 2016 01:25:14 +0900
Message-Id: <1464452714-5126-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1464432784-6058-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464432784-6058-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>

There has been three problems about SysRq-f (manual invocation of the OOM
killer) case. To make description simple, this patch assumes situation
where the OOM reaper is not called (because the OOM victim's mm is shared
by unkillable threads) or not available (due to kthread_run() failure or
CONFIG_MMU=n).

First is that moom_callback() is not called by moom_work under OOM
livelock situation because it does not have a dedicated WQ like vmstat_wq.
This problem is not fixed yet.

Second is that select_bad_process() chooses a thread group which already
has a TIF_MEMDIE thread. Since commit f44666b04605d1c7 ("mm,oom: speed up
select_bad_process() loop") changed oom_scan_process_group() to use
task->signal->oom_victims, non SysRq-f case will no longer select a
thread group which already has a TIF_MEMDIE thread. But SysRq-f case will
select such thread group due to returning OOM_SCAN_OK. This patch makes
sure that oom_badness() is skipped by making oom_scan_process_group() to
return OOM_SCAN_CONTINUE for SysRq-f case.

Third is that oom_kill_process() chooses a thread group which already
has a TIF_MEMDIE thread when the candidate select_bad_process() chose
has children because oom_badness() does not take TIF_MEMDIE into account.
This patch checks child->signal->oom_victims before calling oom_badness()
if oom_kill_process() was called by SysRq-f case. This resembles making
sure that oom_badness() is skipped by returning OOM_SCAN_CONTINUE.

If we don't limit child->signal->oom_victims check to SysRq-f case, we
will break sysctl_oom_kill_allocating_task case by immediately killing
all children of the candidate when killing some child did not immediately
solve the OOM situation because oom_scan_process_thread() is not called.
This will be something we need to mark such child as unkillable after
some reasonable period or make sysctl_oom_kill_allocating_task literally
kill allocating task. Anyway, this patch addresses only SysRq-f case.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1685890..159063e 100644
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
@@ -793,6 +793,14 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			if (process_shares_mm(child, p->mm))
 				continue;
 			/*
+			 * Don't select TIF_MEMDIE child by SysRq-f case, or
+			 * we will get stuck by selecting the same TIF_MEMDIE
+			 * child forever.
+			 */
+			if (is_sysrq_oom(oc) &&
+			    atomic_read(&child->signal->oom_victims))
+				continue;
+			/*
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */
 			child_points = oom_badness(child, memcg, oc->nodemask,
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
