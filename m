Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C33F46B025F
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 05:26:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so13369061wma.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 02:26:56 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id lp5si2763579wjb.121.2016.07.01.02.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 02:26:54 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id r201so3870743wme.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 02:26:53 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 3/6] exit, oom: postpone exit_oom_victim to later
Date: Fri,  1 Jul 2016 11:26:27 +0200
Message-Id: <1467365190-24640-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

exit_oom_victim was called after mmput because it is expected that
address space of the victim would get released by that time and there is
no reason to hold off the oom killer from selecting another task should
that be insufficient to handle the oom situation. In order to catch
post exit_mm() allocations we used to check for PF_EXITING but this
got removed by 6a618957ad17 ("mm: oom_kill: don't ignore oom score on
exiting tasks") because this check was lockup prone.

It seems that we have all needed pieces ready now and can finally
fix this properly (at least for CONFIG_MMU cases where we have the
oom_reaper).  Since "oom: keep mm of the killed task available" we have
a reliable way to ignore oom victims which are no longer interesting
because they either were reaped and do not sit on a lot of memory or
they are not reapable for some reason and it is safer to ignore them
and move on to another victim. That means that we can safely postpone
exit_oom_victim to closer to the final schedule.

There is possible advantages of this because we are reducing chances
of further interference of the oom victim with the rest of the system
after oom_killer_disable(). Strictly speaking this is possible right
now because there are indeed allocations possible past exit_mm() and
who knows whether some of them can trigger IO. I haven't seen this in
practice though.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/exit.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 9e6e1356e6bb..a7260c05f18c 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -434,8 +434,6 @@ static void exit_mm(struct task_struct *tsk)
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
-	if (test_thread_flag(TIF_MEMDIE))
-		exit_oom_victim(tsk);
 }
 
 static struct task_struct *find_alive_thread(struct task_struct *p)
@@ -822,6 +820,9 @@ void do_exit(long code)
 	smp_mb();
 	raw_spin_unlock_wait(&tsk->pi_lock);
 
+	if (test_thread_flag(TIF_MEMDIE))
+		exit_oom_victim(tsk);
+
 	/* causes final put_task_struct in finish_task_switch(). */
 	tsk->state = TASK_DEAD;
 	tsk->flags |= PF_NOFREEZE;	/* tell freezer to ignore us */
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
