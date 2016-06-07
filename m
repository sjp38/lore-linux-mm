Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 286486B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 09:43:21 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id jf8so43241258lbc.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 06:43:21 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id g126si25266415wmd.89.2016.06.07.06.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 06:43:19 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n184so24365973wmn.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 06:43:19 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom_reaper: make sure that mmput_async is called only when memory was reaped
Date: Tue,  7 Jun 2016 15:43:07 +0200
Message-Id: <1465306987-30297-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1465305264-28715-1-git-send-email-mhocko@kernel.org>
References: <1465305264-28715-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo is worried that mmput_async might still lead to a premature
new oom victim selection due to the following race:

__oom_reap_task				exit_mm
  find_lock_task_mm
  atomic_inc(mm->mm_users) # = 2
  task_unlock
  					  task_lock
					  task->mm = NULL
					  up_read(&mm->mmap_sem)
		< somebody write locks mmap_sem >
					  task_unlock
					  mmput
  					    atomic_dec_and_test # = 1
					  exit_oom_victim
  down_read_trylock # failed - no reclaim
  mmput_async # Takes unpredictable amount of time
  		< new OOM situation >

the final __mmput will be executed in the delayed context which might
happen far in the future. Such a race is highly unlikely because the
write holder of mmap_sem would have to be an external task (all direct
holders are already killed or exiting) and it usually have to pin
mm_users in order to do anything reasonable.

We can, however, make sure that the mmput_async is only called when we
do not back off and reap some memory. That would reduce the impact of
the delayed __mmput because the real content would be already freed.
Pin mm_count to keep it alive after we drop task_lock and before we try
to get mmap_sem. If the mmap_sem succeeds we can try to grab mm_users
reference and then go on with unmapping the address space.

It is not clear whether this race is possible at all but it is better
to be more robust and do not pin mm_users unless we are sure we are
actually doing some real work during __oom_reap_task.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c11f8bdd0c12..d4a929d79470 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -452,7 +452,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * We have to make sure to not race with the victim exit path
 	 * and cause premature new oom victim selection:
 	 * __oom_reap_task		exit_mm
-	 *   atomic_inc_not_zero
+	 *   mmget_not_zero
 	 *				  mmput
 	 *				    atomic_dec_and_test
 	 *				  exit_oom_victim
@@ -474,12 +474,22 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	if (!p)
 		goto unlock_oom;
 	mm = p->mm;
-	atomic_inc(&mm->mm_users);
+	atomic_inc(&mm->mm_count);
 	task_unlock(p);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
-		goto unlock_oom;
+		goto mm_drop;
+	}
+
+	/*
+	 * increase mm_users only after we know we will reap something so
+	 * that the mmput_async is called only when we have reaped something
+	 * and delayed __mmput doesn't matter that much
+	 */
+	if (!mmget_not_zero(mm)) {
+		up_read(&mm->mmap_sem);
+		goto mm_drop;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -521,15 +531,16 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * to release its memory.
 	 */
 	set_bit(MMF_OOM_REAPED, &mm->flags);
-unlock_oom:
-	mutex_unlock(&oom_lock);
 	/*
 	 * Drop our reference but make sure the mmput slow path is called from a
 	 * different context because we shouldn't risk we get stuck there and
 	 * put the oom_reaper out of the way.
 	 */
-	if (mm)
-		mmput_async(mm);
+	mmput_async(mm);
+mm_drop:
+	mmdrop(mm);
+unlock_oom:
+	mutex_unlock(&oom_lock);
 	return ret;
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
