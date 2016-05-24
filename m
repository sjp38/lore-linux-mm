Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0E496B007E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 08:24:08 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 85so29668228ioq.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 05:24:08 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0142.outbound.protection.outlook.com. [157.56.112.142])
        by mx.google.com with ESMTPS id m91si1751325otm.243.2016.05.24.05.24.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 05:24:08 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: oom_kill_process: do not abort if the victim is exiting
Date: Tue, 24 May 2016 15:24:02 +0300
Message-ID: <1464092642-10363-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

After selecting an oom victim, we first check if it's already exiting
and if it is, we don't bother killing tasks sharing its mm. We do try to
reap its mm though, but we abort if any of the processes sharing it is
still alive. This might result in oom deadlock if an exiting task got
stuck trying to acquire a lock held by another task sharing the same mm
which needs memory to continue: if oom killer happens to keep selecting
the stuck task, we won't even try to kill other processes or reap the
mm.

The check in question was first introduced by commit 50ec3bbffbe8 ("oom:
handle current exiting"). Initially it worked in conjunction with
another check in select_bad_process() which forced selecting exiting
task. The goal of that patch was selecting the current task on oom if it
was exiting. Now, we select the current task if it's exiting or was
killed anyway. And the check in select_bad_process() was removed by
commit 6a618957ad17 ("mm: oom_kill: don't ignore oom score on exiting
tasks"), because it prevented oom reaper. This just makes the remaining
hunk in oom_kill_process pointless.

The only possible use of this check is avoiding a warning if oom killer
happens to select a dying process. This seems to be very unlikely,
because we should have spent a fair amount of time in reclaimer trying
to free some memory by the time we get to oom, so if the victim turns
out to be exiting, it is likely because of it is stuck on some lock. And
even if it is not, the check is racy anyway, because the warning is
still printed if the victim had managed to release its mm by the time we
entered oom_kill_process. So let's zap it to clean up the code.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/oom_kill.c | 14 --------------
 1 file changed, 14 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 03bf7a472296..66044153209e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -747,20 +747,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap = true;
 
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
-	 */
-	task_lock(p);
-	if (p->mm && task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		try_oom_reaper(p);
-		task_unlock(p);
-		put_task_struct(p);
-		return;
-	}
-	task_unlock(p);
-
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p, memcg);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
