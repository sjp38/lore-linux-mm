Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 19DC9828E6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:14:16 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l66so69745102wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:14:16 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id hq2si9840425wjb.240.2016.02.03.05.14.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 05:14:10 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id 128so7363772wmz.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:14:10 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/5] mm, oom_reaper: report success/failure
Date: Wed,  3 Feb 2016 14:13:59 +0100
Message-Id: <1454505240-23446-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Inform about the successful/failed oom_reaper attempts and dump all the
held locks to tell us more who is blocking the progress.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8e345126d73e..b87acdca2a41 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -420,6 +420,7 @@ static struct task_struct *oom_reaper_th;
 static struct task_struct *task_to_reap;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 
+#define K(x) ((x) << (PAGE_SHIFT-10))
 static bool __oom_reap_task(struct task_struct *tsk)
 {
 	struct mmu_gather tlb;
@@ -476,6 +477,11 @@ static bool __oom_reap_task(struct task_struct *tsk)
 		}
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
+	pr_info("oom_reaper: reaped process :%d (%s) anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lulB\n",
+			task_pid_nr(tsk), tsk->comm,
+			K(get_mm_counter(mm, MM_ANONPAGES)),
+			K(get_mm_counter(mm, MM_FILEPAGES)),
+			K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	up_read(&mm->mmap_sem);
 
 	/*
@@ -492,14 +498,21 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	return ret;
 }
 
+#define MAX_OOM_REAP_RETRIES 10
 static void oom_reap_task(struct task_struct *tsk)
 {
 	int attempts = 0;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < 10 && !__oom_reap_task(tsk))
+	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk))
 		schedule_timeout_idle(HZ/10);
 
+	if (attempts > MAX_OOM_REAP_RETRIES) {
+		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
+				task_pid_nr(tsk), tsk->comm);
+		debug_show_all_locks();
+	}
+
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
 }
@@ -646,7 +659,6 @@ static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 	return false;
 }
 
-#define K(x) ((x) << (PAGE_SHIFT-10))
 /*
  * Must be called while holding a reference to p, which will be released upon
  * returning.
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
