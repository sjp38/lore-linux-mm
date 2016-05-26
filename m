Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 96DA46B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 11:29:59 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id w16so33530594lfd.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 08:29:59 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id zb6si19068905wjc.198.2016.05.26.08.29.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 08:29:58 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a136so6476266wme.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 08:29:58 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm, oom_reaper: do not attempt to reap a task more than twice
Date: Thu, 26 May 2016 17:27:56 +0200
Message-Id: <1464276476-25136-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom_reaper relies on the mmap_sem for read to do its job. Many places
which might block readers have been converted to use down_write_killable
and that has reduced chances of the contention a lot. Some paths where
the mmap_sem is held for write can take other locks and they might
either be not prepared to fail due to fatal signal pending or too
impractical to be changed.

This patch introduces MMF_OOM_NOT_REAPABLE flag which gets set after the
first attempt to reap a task's mm fails. If the flag is present already
after the failure then we set MMF_OOM_REAPED to hide this mm from the
oom killer completely so it can go and chose another victim.

As a result a risk of OOM deadlock when the oom victim would be blocked
indefinetly and so the oom killer cannot make any progress should be
mitigated considerably while we still try really hard to do perform all
reclaim attempts and stay predictable in the behavior.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
I believe that after [1] and this patch we can reasonably expect that
the risk of the oom lockups is so low that we do not need to employ
timeout based solutions. I am sending this as an RFC because there still
might be better ways to accomplish the similar effect. I just like this
one because it is nicely grafted into the oom reaper which will now be
invoked for basically all oom victims.

[1] http://lkml.kernel.org/r/1464266415-15558-1-git-send-email-mhocko@kernel.org

 include/linux/sched.h |  1 +
 mm/oom_kill.c         | 19 +++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index ec636400669f..12a4c8e04e6a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -512,6 +512,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 #define MMF_OOM_REAPED		21	/* mm has been already reaped */
+#define MMF_OOM_NOT_REAPABLE	22	/* mm couldn't be reaped */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5bb2f7698ad7..2f82f2a558e4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -531,8 +531,27 @@ static void oom_reap_task(struct task_struct *tsk)
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts > MAX_OOM_REAP_RETRIES) {
+		struct task_struct *p;
+
 		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 				task_pid_nr(tsk), tsk->comm);
+
+		/*
+		 * If we've already tried to reap this task in the past and
+		 * failed it probably doesn't make much sense to try yet again
+		 * so hide the mm from the oom killer so that it can move on
+		 * to another task with a different mm struct.
+		 */
+		p = find_lock_task_mm(tsk);
+		if (p) {
+			if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &p->mm->flags)) {
+				pr_info("oom_reaper: giving up pid:%d (%s)\n",
+						task_pid_nr(tsk), tsk->comm);
+				set_bit(MMF_OOM_REAPED, &p->mm->flags);
+			}
+			task_unlock(p);
+		}
+
 		debug_show_all_locks();
 	}
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
