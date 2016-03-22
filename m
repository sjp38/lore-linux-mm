Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id D0DFE6B0260
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:01:07 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id p65so186749108wmp.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:07 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id d19si19484956wjs.146.2016.03.22.04.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 04:01:05 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id u125so2596807wmg.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:05 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/9] mm, oom_reaper: report success/failure
Date: Tue, 22 Mar 2016 12:00:21 +0100
Message-Id: <1458644426-22973-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Inform about the successful/failed oom_reaper attempts and dump all the
held locks to tell us more who is blocking the progress.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2830b1c6483e..e627ce235e38 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -419,6 +419,7 @@ static struct task_struct *oom_reaper_th;
 static struct task_struct *task_to_reap;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 
+#define K(x) ((x) << (PAGE_SHIFT-10))
 static bool __oom_reap_task(struct task_struct *tsk)
 {
 	struct mmu_gather tlb;
@@ -479,6 +480,11 @@ static bool __oom_reap_task(struct task_struct *tsk)
 					 &details);
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
+	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+			task_pid_nr(tsk), tsk->comm,
+			K(get_mm_counter(mm, MM_ANONPAGES)),
+			K(get_mm_counter(mm, MM_FILEPAGES)),
+			K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	up_read(&mm->mmap_sem);
 
 	/*
@@ -495,14 +501,21 @@ static bool __oom_reap_task(struct task_struct *tsk)
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
@@ -649,7 +662,6 @@ static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
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
