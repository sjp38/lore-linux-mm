Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D68716B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 19:43:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a82so12487179pfc.8
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 16:43:05 -0700 (PDT)
Received: from mail-pg0-x236.google.com (mail-pg0-x236.google.com. [2607:f8b0:400e:c05::236])
        by mx.google.com with ESMTPS id a20si956692pfc.137.2017.06.14.16.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 16:43:05 -0700 (PDT)
Received: by mail-pg0-x236.google.com with SMTP id k71so6740699pgd.2
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 16:43:05 -0700 (PDT)
Date: Wed, 14 Jun 2017 16:43:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: prevent additional oom kills before memory is
 freed
Message-ID: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If mm->mm_users is not incremented because it is already zero by the oom
reaper, meaning the final refcount has been dropped, do not set
MMF_OOM_SKIP prematurely.

__mmput() may not have had a chance to do exit_mmap() yet, so memory from
a previous oom victim is still mapped.  __mput() naturally requires no
references on mm->mm_users to do exit_mmap().

Without this, several processes can be oom killed unnecessarily and the
oom log can show an abundance of memory available if exit_mmap() is in
progress at the time the process is skipped.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -531,6 +531,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 					 NULL);
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
@@ -562,7 +563,11 @@ static void oom_reap_task(struct task_struct *tsk)
 	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;
 
-
+	/*
+	 * Hide this mm from OOM killer because it cannot be reaped since
+	 * mm->mmap_sem cannot be acquired.
+	 */
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 		task_pid_nr(tsk), tsk->comm);
 	debug_show_all_locks();
@@ -570,12 +575,6 @@ static void oom_reap_task(struct task_struct *tsk)
 done:
 	tsk->oom_reaper_list = NULL;
 
-	/*
-	 * Hide this mm from OOM killer because it has been either reaped or
-	 * somebody can't call up_write(mmap_sem).
-	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
-
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
