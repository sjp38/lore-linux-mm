Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9EAE683093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 06:03:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so30718296wme.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:31 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id i11si13510875wmh.67.2016.08.25.03.03.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 03:03:30 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q128so6651566wma.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:30 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2 2/9] mm,oom_reaper: Do not attempt to reap a task twice.
Date: Thu, 25 Aug 2016 12:03:07 +0200
Message-Id: <1472119394-11342-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
References: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

"mm, oom_reaper: do not attempt to reap a task twice" tried to give the
OOM reaper one more chance to retry using MMF_OOM_NOT_REAPABLE flag. But
the usefulness of the flag is rather limited and actually never shown
in practice. If the flag is set, it means that the holder of mm->mmap_sem
cannot call up_write() due to presumably being blocked at unkillable wait
waiting for other thread's memory allocation. But since one of threads
sharing that mm will queue that mm immediately via task_will_free_mem()
shortcut (otherwise, oom_badness() will select the same mm again due to
oom_score_adj value unchanged), retrying MMF_OOM_NOT_REAPABLE mm is
unlikely helpful.

Let's always set MMF_OOM_REAPED.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h |  1 -
 mm/oom_kill.c         | 15 +++------------
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index d7e1e783cf01..f9b0b2dd4f18 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -522,7 +522,6 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 #define MMF_OOM_REAPED		21	/* mm has been already reaped */
-#define MMF_OOM_NOT_REAPABLE	22	/* mm couldn't be reaped */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 87fad956c96b..45097f5a8f30 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -578,20 +578,11 @@ static void oom_reap_task(struct task_struct *tsk)
 	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;
 
+	/* Ignore this mm because somebody can't call up_write(mmap_sem). */
+	set_bit(MMF_OOM_REAPED, &mm->flags);
+
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 		task_pid_nr(tsk), tsk->comm);
-
-	/*
-	 * If we've already tried to reap this task in the past and
-	 * failed it probably doesn't make much sense to try yet again
-	 * so hide the mm from the oom killer so that it can move on
-	 * to another task with a different mm struct.
-	 */
-	if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &mm->flags)) {
-		pr_info("oom_reaper: giving up pid:%d (%s)\n",
-			task_pid_nr(tsk), tsk->comm);
-		set_bit(MMF_OOM_REAPED, &mm->flags);
-	}
 	debug_show_all_locks();
 
 done:
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
