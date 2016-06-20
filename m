Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id B50576B0268
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 08:44:18 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id na2so26978473lbb.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 05:44:18 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id o10si29077939wje.245.2016.06.20.05.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 05:44:01 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r201so13799457wme.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 05:44:01 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 09/10] mm, oom_reaper: do not attempt to reap a task more than twice
Date: Mon, 20 Jun 2016 14:43:47 +0200
Message-Id: <1466426628-15074-10-git-send-email-mhocko@kernel.org>
In-Reply-To: <1466426628-15074-1-git-send-email-mhocko@kernel.org>
References: <1466426628-15074-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom_reaper relies on the mmap_sem for read to do its job. Many places
which might block readers have been converted to use down_write_killable
and that has reduced chances of the contention a lot. Some paths where
the mmap_sem is held for write can take other locks and they might
either be not prepared to fail due to fatal signal pending or too
impractical to be changed.

This patch introduces MMF_OOM_NOT_REAPABLE flag which gets set after the
first attempt to reap a task's mm fails. If the flag is present after
the failure then we set MMF_OOM_REAPED to hide this mm from the oom
killer completely so it can go and chose another victim.

As a result a risk of OOM deadlock when the oom victim would be blocked
indefinetly and so the oom killer cannot make any progress should be
mitigated considerably while we still try really hard to perform all
reclaim attempts and stay predictable in the behavior.

Acked-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h |  1 +
 mm/oom_kill.c         | 19 +++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7442f74b6d44..6d81a1eb974a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -512,6 +512,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 #define MMF_OOM_REAPED		21	/* mm has been already reaped */
+#define MMF_OOM_NOT_REAPABLE	22	/* mm couldn't be reaped */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 36d5dd88d990..bfddc93ccd34 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -556,8 +556,27 @@ static void oom_reap_task(struct task_struct *tsk)
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
