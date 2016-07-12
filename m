Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94E6E6B0268
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:31:23 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r71so34997492ioi.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:31:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i201si11688548iti.12.2016.07.12.06.31.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 06:31:20 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2/8] mm,oom_reaper: Do not attempt to reap a task twice.
Date: Tue, 12 Jul 2016 22:29:17 +0900
Message-Id: <1468330163-4405-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

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
---
 include/linux/sched.h |  1 -
 mm/oom_kill.c         | 15 +++------------
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 553af29..c0efd80 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -523,7 +523,6 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 #define MMF_OOM_REAPED		21	/* mm has been already reaped */
-#define MMF_OOM_NOT_REAPABLE	22	/* mm couldn't be reaped */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 951eb1b..9f0022e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -567,20 +567,11 @@ static void oom_reap_task(struct task_struct *tsk)
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
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
