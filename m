Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B94AA6B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 10:05:01 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h68so2479400lfh.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 07:05:01 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 71si4916078wmr.122.2016.05.26.07.05.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 07:05:00 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n129so5330646wmn.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 07:05:00 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] oom_reaper: close race with exiting task
Date: Thu, 26 May 2016 16:04:53 +0200
Message-Id: <1464271493-20008-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo has reported:
[   74.453958] Out of memory: Kill process 443 (oleg's-test) score 855 or sacrifice child
[   74.456234] Killed process 443 (oleg's-test) total-vm:493248kB, anon-rss:423880kB, file-rss:4kB, shmem-rss:0kB
[   74.459219] sh invoked oom-killer: gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), order=0, oom_score_adj=0
[   74.462813] sh cpuset=/ mems_allowed=0
[   74.465221] CPU: 2 PID: 1 Comm: sh Not tainted 4.6.0-rc7+ #51
[   74.467037] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   74.470207]  0000000000000286 00000000a17a86b0 ffff88001e673a18 ffffffff812c7cbd
[   74.473422]  0000000000000000 ffff88001e673bd0 ffff88001e673ab8 ffffffff811b9e94
[   74.475704]  ffff88001e66cbe0 ffff88001e673ab8 0000000000000246 0000000000000000
[   74.477990] Call Trace:
[   74.479170]  [<ffffffff812c7cbd>] dump_stack+0x85/0xc8
[   74.480872]  [<ffffffff811b9e94>] dump_header+0x5b/0x394
[   74.481837] oom_reaper: reaped process 443 (oleg's-test), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

In other words:
__oom_reap_task			exit_mm
  atomic_inc_not_zero
				  tsk->mm = NULL
				  mmput
				    atomic_dec_and_test # > 0
				  exit_oom_victim # New victim will be
						  # selected
				<OOM killer invoked>
				  # no TIF_MEMDIE task so we can select a new one
  unmap_page_range # to release the memory

The race exists even without the oom_reaper because anybody who pins the
address space and gets preempted might race with exit_mm but oom_reaper
made this race more probable.

We can address the oom_reaper part by using oom_lock for __oom_reap_task
because this would guarantee that a new oom victim will not be selected
if the oom reaper might race with the exit path. This doesn't solve the
original issue, though, because somebody else still might be pinning
mm_users and so __mmput won't be called to release the memory but that
is not really realiably solvable because the task will get away from the
oom sight as soon as it is unhashed from the task_list and so we cannot
guarantee a new victim won't be selected.

Fixes: aac453635549 ("mm, oom: introduce oom reaper")
Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
I haven't marked this for stable because the race is quite unlikely I
believe. I have noted the original commit, though, for those who might
want to backport it and consider this follow up fix as well.

I guess this would be good to go in the current merge window, unless I
have missed something subtle. It would be great if Tetsuo could try to
reproduce and confirm this really solves his issue.

Thanks!

 mm/oom_kill.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5bb2f7698ad7..d0f42cc88f6a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -450,6 +450,22 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	bool ret = true;
 
 	/*
+	 * We have to make sure to not race with the victim exit path
+	 * and cause premature new oom victim selection:
+	 * __oom_reap_task		exit_mm
+	 *   atomic_inc_not_zero
+	 *   				  mmput
+	 *   				    atomic_dec_and_test
+	 *				  exit_oom_victim
+	 *				[...]
+	 *				out_of_memory
+	 *				  select_bad_process
+	 *				    # no TIF_MEMDIE task select new victim
+	 *  unmap_page_range # frees some memory
+	 */
+	mutex_lock(&oom_lock);
+
+	/*
 	 * Make sure we find the associated mm_struct even when the particular
 	 * thread has already terminated and cleared its mm.
 	 * We might have race with exit path so consider our work done if there
@@ -457,19 +473,19 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 */
 	p = find_lock_task_mm(tsk);
 	if (!p)
-		return true;
+		goto unlock_oom;
 
 	mm = p->mm;
 	if (!atomic_inc_not_zero(&mm->mm_users)) {
 		task_unlock(p);
-		return true;
+		goto unlock_oom;
 	}
 
 	task_unlock(p);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
-		goto out;
+		goto unlock_oom;
 	}
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
@@ -511,7 +527,8 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * to release its memory.
 	 */
 	set_bit(MMF_OOM_REAPED, &mm->flags);
-out:
+unlock_oom:
+	mutex_unlock(&oom_lock);
 	/*
 	 * Drop our reference but make sure the mmput slow path is called from a
 	 * different context because we shouldn't risk we get stuck there and
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
