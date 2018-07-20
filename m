Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 23DEA6B0269
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 04:41:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e19-v6so5488886pgv.11
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 01:41:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g2-v6sor368684pgv.100.2018.07.20.01.41.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 01:41:45 -0700 (PDT)
Date: Fri, 20 Jul 2018 01:41:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1807200133310.119737@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com> <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com>
 <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Jul 2018, Tetsuo Handa wrote:

> Sigh...
> 
> Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> because David is not aware what is wrong.
> 

Hmm, didn't you incorporate this exact patch into your own patch series 
that you proposed? :)

I'm coming to this stark realization that all of these theater is only for 
effect.  Perhaps other observers have come to that understanding earlier 
and I was late to the party.

You're nacking a patch because it does a double set_bit() and jiffies can 
wraparound and we can add a process to the oom reaper list twice if the 
oom happens at the exact same moment.  Ok.  These are extremely trivial to 
fix.

> Let's call "A" as a thread doing exit_mmap(), and "B" as the OOM reaper kernel thread.
> 
> (1) "A" finds that unlikely(mm_is_oom_victim(mm)) == true.
> (2) "B" finds that test_bit(MMF_OOM_SKIP, &mm->flags) in oom_reap_task() is false.
> (3) "B" finds that !test_bit(MMF_UNSTABLE, &mm->flags) in oom_reap_task() is true.
> (4) "B" enters into oom_reap_task_mm(tsk, mm).
> (5) "B" finds that !down_read_trylock(&mm->mmap_sem) is false.
> (6) "B" finds that mm_has_blockable_invalidate_notifiers(mm) is false.
> (7) "B" finds that test_bit(MMF_UNSTABLE, &mm->flags) is false.
> (8) "B" enters into __oom_reap_task_mm(mm).
> (9) "A" finds that test_and_set_bit(MMF_UNSTABLE, &mm->flags) is false.
> (10) "A" is preempted by somebody else.
> (11) "B" finds that test_and_set_bit(MMF_UNSTABLE, &mm->flags) is true.
> (12) "B" leaves __oom_reap_task_mm(mm).
> (13) "B" leaves oom_reap_task_mm().
> (14) "B" finds that time_after_eq(jiffies, mm->oom_free_expire) became true.
> (15) "B" finds that !test_bit(MMF_OOM_SKIP, &mm->flags) is true.
> (16) "B" calls set_bit(MMF_OOM_SKIP, &mm->flags).
> (17) "B" finds that test_bit(MMF_OOM_SKIP, &mm->flags) is true.
> (18) select_bad_process() finds that MMF_OOM_SKIP is already set.
> (19) out_of_memory() kills a new OOM victim.
> (20) "A" resumes execution and start reclaiming memory.
> 
> because oom_lock serialization was already removed.
> 

Absent oom_lock serialization, this is exactly working as intended.  You 
could argue that once the thread has reached exit_mmap() and begins oom 
reaping that it should be allowed to finish before the oom reaper declares 
MMF_OOM_SKIP.  That could certainly be helpful, I simply haven't 
encountered a usecase where it were needed.  Or, we could restart the oom 
expiration when MMF_UNSTABLE is set and deem that progress is being made 
so it give it some extra time.  In practice, again, we haven't seen this 
needed.  But either of those are very easy to add in as well.  Which would 
you prefer?


mm, oom: fix unnecessary killing of additional processes fix

Fix double set_bit() per Tetsuo.

Fix jiffies wraparound per Tetsuo.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mmap.c     | 13 ++++++-------
 mm/oom_kill.c |  7 +++++--
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3069,23 +3069,22 @@ void exit_mmap(struct mm_struct *mm)
 		 * Nothing can be holding mm->mmap_sem here and the above call
 		 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
 		 * __oom_reap_task_mm() will not block.
-		 */
-		__oom_reap_task_mm(mm);
-
-		/*
-		 * Now, set MMF_UNSTABLE to avoid racing with the oom reaper.
+		 *
+		 * This sets MMF_UNSTABLE to avoid racing with the oom reaper.
 		 * This needs to be done before calling munlock_vma_pages_all(),
 		 * which clears VM_LOCKED, otherwise the oom reaper cannot
 		 * reliably test for it.  If the oom reaper races with
 		 * munlock_vma_pages_all(), this can result in a kernel oops if
 		 * a pmd is zapped, for example, after follow_page_mask() has
 		 * checked pmd_none().
-		 *
+		 */
+		__oom_reap_task_mm(mm);
+
+		/*
 		 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
 		 * guarantee that the oom reaper will not run on this mm again
 		 * after mmap_sem is dropped.
 		 */
-		set_bit(MMF_UNSTABLE, &mm->flags);
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
 	}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -666,12 +666,15 @@ static int oom_reaper(void *unused)
 static u64 oom_free_timeout_ms = 1000;
 static void wake_oom_reaper(struct task_struct *tsk)
 {
+	unsigned long expire = jiffies + msecs_to_jiffies(oom_free_timeout_ms);
+
+	if (!expire)
+		expire++;
 	/*
 	 * Set the reap timeout; if it's already set, the mm is enqueued and
 	 * this tsk can be ignored.
 	 */
-	if (cmpxchg(&tsk->signal->oom_mm->oom_free_expire, 0UL,
-			jiffies + msecs_to_jiffies(oom_free_timeout_ms)))
+	if (cmpxchg(&tsk->signal->oom_mm->oom_free_expire, 0UL, expire))
 		return;
 
 	get_task_struct(tsk);
