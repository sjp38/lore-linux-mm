Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 007246B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 03:59:30 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i26-v6so2941501edr.4
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 00:59:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p7-v6sor3212263edh.51.2018.07.19.00.59.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 00:59:28 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom: remove oom_lock from oom_reaper
Date: Thu, 19 Jul 2018 09:59:22 +0200
Message-Id: <20180719075922.13784-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom_reaper used to rely on the oom_lock since e2fe14564d33 ("oom_reaper:
close race with exiting task"). We do not really need the lock anymore
though. 212925802454 ("mm: oom: let oom_reap_task and exit_mmap run
concurrently") has removed serialization with the exit path based on the
mm reference count and so we do not really rely on the oom_lock anymore.

Tetsuo was arguing that at least MMF_OOM_SKIP should be set under the
lock to prevent from races when the page allocator didn't manage to get
the freed (reaped) memory in __alloc_pages_may_oom but it sees the flag
later on and move on to another victim. Although this is possible in
principle let's wait for it to actually happen in real life before we
make the locking more complex again.

Therefore remove the oom_lock for oom_reaper paths (both exit_mmap and
oom_reap_task_mm). The reaper serializes with exit_mmap by mmap_sem +
MMF_OOM_SKIP flag. There is no synchronization with out_of_memory path
now.

Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/mmap.c     |  2 --
 mm/oom_kill.c | 29 ++++-------------------------
 2 files changed, 4 insertions(+), 27 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index fc41c0543d7f..4642964f7741 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3073,9 +3073,7 @@ void exit_mmap(struct mm_struct *mm)
 		 * which clears VM_LOCKED, otherwise the oom reaper cannot
 		 * reliably test it.
 		 */
-		mutex_lock(&oom_lock);
 		__oom_reap_task_mm(mm);
-		mutex_unlock(&oom_lock);
 
 		set_bit(MMF_OOM_SKIP, &mm->flags);
 		down_write(&mm->mmap_sem);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 32e6f7becb40..c74bf0bd8010 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -529,28 +529,9 @@ void __oom_reap_task_mm(struct mm_struct *mm)
 
 static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
-	bool ret = true;
-
-	/*
-	 * We have to make sure to not race with the victim exit path
-	 * and cause premature new oom victim selection:
-	 * oom_reap_task_mm		exit_mm
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
 	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
 		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
+		return false;
 	}
 
 	/*
@@ -562,7 +543,7 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	if (mm_has_blockable_invalidate_notifiers(mm)) {
 		up_read(&mm->mmap_sem);
 		schedule_timeout_idle(HZ);
-		goto unlock_oom;
+		return true;
 	}
 
 	/*
@@ -574,7 +555,7 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
 		up_read(&mm->mmap_sem);
 		trace_skip_task_reaping(tsk->pid);
-		goto unlock_oom;
+		return true;
 	}
 
 	trace_start_task_reaping(tsk->pid);
@@ -589,9 +570,7 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	up_read(&mm->mmap_sem);
 
 	trace_finish_task_reaping(tsk->pid);
-unlock_oom:
-	mutex_unlock(&oom_lock);
-	return ret;
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-- 
2.18.0
