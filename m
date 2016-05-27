Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4928A6B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 08:08:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f75so60129334wmf.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 05:08:19 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id w81si11842253wmd.93.2016.05.27.05.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 05:08:17 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n129so13819760wmn.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 05:08:17 -0700 (PDT)
Date: Fri, 27 May 2016 14:08:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom_reaper: close race with exiting task
Message-ID: <20160527120816.GH27686@dhcp22.suse.cz>
References: <1464271493-20008-1-git-send-email-mhocko@kernel.org>
 <201605271924.JHJ51087.JFOLSVOFtHFQMO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201605271924.JHJ51087.JFOLSVOFtHFQMO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org

On Fri 27-05-16 19:24:16, Tetsuo Handa wrote:
> Continued from http://lkml.kernel.org/r/20160526115759.GB23675@dhcp22.suse.cz :
> > The problem with signal_struct is that we will not help if the task gets
> > unhashed from the task list which usually happens quite early after
> > exit_mm. The oom_lock will keep other OOM killer activity away until we
> > reap the address space and free up the memory so it would cover that
> > case. So I think the oom_lock is a more robust solution. I plan to post
> > the patch with the full changelog soon I just wanted to finish the other
> > pile before.
> 
> Excuse me, I didn't understand it.
> A task is unhashed at __unhash_process() from __exit_signal() from
> release_task() from exit_notify() which is called from do_exit() after
> exit_task_work(), isn't it? It seems to me that it happens quite late
> after exit_mm(), and signal_struct will help.

The point I've tried to make is that after __unhash_process we even do
not see the task when doing for_each_process.

> Michal Hocko wrote:
> > Hi,
> > I haven't marked this for stable because the race is quite unlikely I
> > believe. I have noted the original commit, though, for those who might
> > want to backport it and consider this follow up fix as well.
> > 
> > I guess this would be good to go in the current merge window, unless I
> > have missed something subtle. It would be great if Tetsuo could try to
> > reproduce and confirm this really solves his issue.
> 
> I haven't tried this patch. But you need below fix if you use oom_lock.
> 
>   mm/oom_kill.c: In function a??__oom_reap_taska??:
>   mm/oom_kill.c:537:13: warning: a??mma?? may be used uninitialized in this function [-Wmaybe-uninitialized]
>     mmput_async(mm);

Arnd has already posted a fix
http://lkml.kernel.org/r/1464336081-994232-1-git-send-email-arnd@arndb.de
 
> While it is true that commit ec8d7c14ea14922f ("mm, oom_reaper: do not mmput
> synchronously from the oom reaper context") avoids locking up the OOM reaper,
> the OOM reaper can prematurely clear TIF_MEMDIE due to deferring synchronous
> exit_aio() etc. in __mmput() by TIF_MEMDIE thread's mmput() till asynchronous
> exit_aio() etc. in __mmput() by some workqueue (which is not guaranteed to
> run shortly) via the OOM reaper's mmput_async(). 

I am not sure I get your point. So are you worried about
__oom_reap_task				exit_mm
					  up_read(&mm->mmap_sem)
		< somebody write locks mmap_sem >
					  task_unlock
					  mmput
  find_lock_task_mm
  atomic_inc_not_zero # = 2
  					    atomic_dec_and_test # = 1
  task_unlock
  down_read_trylock # failed - no reclaim
  mmput_async # Takes unpredictable amount of time

We can handle that situation by pinning mm_struct only after we know we
won't back off. Something like (untested just for illustration):
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 268b76b88220..bc69dc54ed05 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -475,8 +475,12 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	if (!p)
 		goto unlock_oom;
 
+	/*
+	 * pin mm because we have to increment mm_users only after
+	 * task_unlock so make sure it won't get freed
+	 */
 	mm = p->mm;
-	if (!atomic_inc_not_zero(&mm->mm_users)) {
+	if (!atomic_inc_not_zero(&mm->mm_count)) {
 		task_unlock(p);
 		goto unlock_oom;
 	}
@@ -485,8 +489,15 @@ static bool __oom_reap_task(struct task_struct *tsk)
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
+		mm_drop(mm);
+		goto unlock_oom;
+	}
+
+	if (!atomic_inc_not_zero(&mm->mm_users)) {
+		mm_drop(mm);
 		goto unlock_oom;
 	}
+	mm_drop(mm);
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {

This way we can be sure that the async_mmput will be executed only if we
have in fact reaped some memory which should put a relief to the over
OOM situation and so the delayed nature of the operation shouldn't
really matter much.

[...]

> Do we really want to let the OOM reaper try __oom_reap_task() as soon
> as calling mark_oom_victim()?

Well, after this patch they would get naturally synchronized over the
oom_lock. So it won't be immediately because we are already doing
schedule_timeout_killable while holding oom_lock.

> Since majority of OOM-killer events can
> solve the OOM situation without waking up the OOM reaper, from the point
> of view of avoid selecting next OOM victim needlessly, it might be
> desirable to defer calling __oom_reap_task() for a while to wait for
> synchronous mmput().

We already have this timeout in oom_kill_process...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
