Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8174C6B0262
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:30:18 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id d2so30218156obp.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:30:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i71si2885518ita.35.2016.07.12.06.30.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 06:30:16 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 8/8] oom_reaper: Revert "oom_reaper: close race with exiting task".
Date: Tue, 12 Jul 2016 22:29:23 +0900
Message-Id: <1468330163-4405-9-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

We can revert commit e2fe14564d3316d1 ("oom_reaper: close race with
exiting task") because oom_has_pending_mm() which will return true until
exit_oom_mm() is called after OOM victim's mm is reclaimed by __mmput()
or oom_reap_task() can close that race.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 29 ++++-------------------------
 1 file changed, 4 insertions(+), 25 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index fab0bec..232c1ce 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -476,28 +476,9 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
-	bool ret = true;
 
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * __oom_reap_task		exit_mm
-	 *   mmget_not_zero
-	 *				  mmput
-	 *				    atomic_dec_and_test
-	 *				  exit_oom_victim
-	 *				[...]
-	 *				out_of_memory
-	 *				  select_bad_process
-	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
-	 */
-	mutex_lock(&oom_lock);
-
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
-		goto unlock_oom;
-	}
+	if (!down_read_trylock(&mm->mmap_sem))
+		return false;
 
 	/*
 	 * increase mm_users only after we know we will reap something so
@@ -506,7 +487,7 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	if (!mmget_not_zero(mm)) {
 		up_read(&mm->mmap_sem);
-		goto unlock_oom;
+		return true;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -554,9 +535,7 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 	 * put the oom_reaper out of the way.
 	 */
 	mmput_async(mm);
-unlock_oom:
-	mutex_unlock(&oom_lock);
-	return ret;
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
