Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 999BB6B0267
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 08:20:15 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id di3so46644840pab.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 05:20:15 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 21si340665pfy.28.2016.06.02.05.20.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 05:20:13 -0700 (PDT)
Subject: Re: [PATCH] mm,oom_reaper: don't call mmput_async() without atomic_inc_not_zero()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464423365-5555-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160601155313.dc3aa18eb6ad0e163d44b355@linux-foundation.org>
	<20160602064804.GF1995@dhcp22.suse.cz>
In-Reply-To: <20160602064804.GF1995@dhcp22.suse.cz>
Message-Id: <201606022120.FAG39003.OFFtHOVMFSJQLO@I-love.SAKURA.ne.jp>
Date: Thu, 2 Jun 2016 21:20:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, arnd@arndb.de

Michal Hocko wrote:
> On Wed 01-06-16 15:53:13, Andrew Morton wrote:
> > On Sat, 28 May 2016 17:16:05 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > 
> > > Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
> > > reduced frequency of needlessly selecting next OOM victim, but was
> > > calling mmput_async() when atomic_inc_not_zero() failed.
> > 
> > Changelog fail.
> > 
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -478,6 +478,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
> > >  	mm = p->mm;
> > >  	if (!atomic_inc_not_zero(&mm->mm_users)) {
> > >  		task_unlock(p);
> > > +		mm = NULL;
> > >  		goto unlock_oom;
> > >  	}
> > 
> > This looks like a pretty fatal bug.  I assume the result of hitting
> > that race will be a kernel crash, yes?
> 
> Yes it is a nasty bug. It was (re)introduced by the final touch to the
> goto paths. And yes it can cause a crash.

Not always a kernel crash.

Calling mmput_async() when atomic_inc_not_zero(&mm->mm_users) failed
(i.e. mm->mm_users == 0) will make mm->mm_users == -1 by

  if (atomic_dec_and_test(&mm->mm_users)) {

in mmput_async(). Unless mm is released before this atomic_dec_and_test()
is executed, it will be merely a counter underflow. If mm is released
and reallocated for new instance before this atomic_dec_and_test() is
executed, it might cause a kernel crash. But

> 
> > Is it even possible to hit that race? 
> 
> It is, we can have a concurrent mmput followed by mmdrop.
> 
> > find_lock_task_mm() takes some
> > care to prevent a NULL ->mm.  But I guess a concurrent mmput() doesn't
> > require task_lock().  Kinda makes me wonder what's the point in even
> > having find_lock_task_mm() if its guarantee on ->mm is useless...
> 
> find_lock_task_mm makes sure that the mm stays non-NULL while we hold
> the lock. We have to do all the necessary pinning while holding it.
> atomic_inc_not_zero will guarantee we are not racing with the finall
> mmput.
> 
> Does that make more sense now?

what Andrew wanted to confirm is "how can it be possible that
mm->mm_users < 1 when there is a tsk with tsk->mm != NULL", isn't it?

Indeed, find_lock_task_mm() returns a tsk where tsk->mm != NULL with
tsk->alloc_lock held. Therefore, tsk->mm != NULL implies mm->mm_users > 0
until we release tsk->alloc_lock , and we can do

 	p = find_lock_task_mm(tsk);
 	if (!p)
 		goto unlock_oom;
 
 	mm = p->mm;
-	if (!atomic_inc_not_zero(&mm->mm_users)) {
-		task_unlock(p);
-		goto unlock_oom;
-	}
+	atomic_inc(&mm->mm_users);
 
 	task_unlock(p);

in __oom_reap_task() (unless I'm missing something).

Also, dmesg.xz in the crash report http://lkml.kernel.org/r/20160601080209.GA7190@yexl-desktop
includes an interesting race.

----------------------------------------
[    0.000000] Initializing CPU#0
(...snipped...)
[   82.643609] seq invoked oom-killer: gfp_mask=0x24200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
[   82.644682] CPU: 0 PID: 3946 Comm: seq Not tainted 4.6.0-10870-gdf1e2f5 #1
(...snipped...)
[   82.679858] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[   82.680805] [  429]     0   429      171      125       3       0        0             0 ubusd
[   82.681742] [  430]     0   430      156      117       3       0        0             0 askfirst
[   82.682903] [  884]     0   884      194      143       3       0        0             0 logd
[   82.683866] [  916]     0   916      248      202       3       0        0             0 netifd
[   82.684820] [ 1029]     0  1029      277      213       3       0        0             0 S95done
[   82.685977] [ 1030]     0  1030      269      185       3       0        0             0 sh
[   82.686903] [ 1035]     0  1035      268      195       3       0        0             0 01-cpu-hotplug
[   82.687926] [ 1040]     0  1040    13637      509       4       0        0             0 trinity
[   82.689100] [ 1041]     0  1041      266      169       3       0        0             0 sleep
[   82.690055] [ 3533]     0  3533    13637      285       3       0        0             0 trinity-watchdo
[   82.691082] [ 3534]     1  3534    13986      633       3       0        0             0 trinity-main
[   82.692316] [ 3914]     1  3914    13966     7054      14       0        0             0 trinity-c0
[   82.693322] [ 3946]     0  3946      145       30       3       0        0             0 seq
[   82.694232] Out of memory: Kill process 3914 (trinity-c0) score 167 or sacrifice child
[   82.695110] Killed process 3914 (trinity-c0) total-vm:55864kB, anon-rss:1512kB, file-rss:1088kB, shmem-rss:25616kB
[   82.706724] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26488kB
[   82.715540] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
[   82.717662] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
[   82.725804] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:27296kB
[   82.739091] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:28148kB
[   82.741088] 01-cpu-hotplug invoked oom-killer: gfp_mask=0x24200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
[   82.743238] CPU: 0 PID: 3947 Comm: 01-cpu-hotplug Not tainted 4.6.0-10870-gdf1e2f5 #1
(...snipped...)
[   82.788986] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[   82.790484] [  429]     0   429      171      125       3       0        0             0 ubusd
[   82.792271] [  430]     0   430      156      117       3       0        0             0 askfirst
[   82.793809] [  884]     0   884      194      143       3       0        0             0 logd
[   82.795588] [  916]     0   916      248      202       3       0        0             0 netifd
[   82.797099] [ 1029]     0  1029      277      213       3       0        0             0 S95done
[   82.798894] [ 1030]     0  1030      269      185       3       0        0             0 sh
[   82.800286] [ 1035]     0  1035      268      195       3       0        0             0 01-cpu-hotplug
[   82.801852] [ 1040]     0  1040    13637      509       4       0        0             0 trinity
[   82.803458] [ 1041]     0  1041      266      169       3       0        0             0 sleep
[   82.804943] [ 3533]     0  3533    13637      285       3       0        0             0 trinity-watchdo
[   82.806800] [ 3534]     1  3534    13986      633       3       0        0             0 trinity-main
[   82.808388] [ 3914]     1  3914    13966     7038      14       0        0             0 trinity-c0
[   82.809970] [ 3947]     0  3947      268       36       3       0        0             0 01-cpu-hotplug
[   82.811002] Out of memory: Kill process 3534 (trinity-main) score 15 or sacrifice child
[   82.811891] Killed process 3534 (trinity-main) total-vm:55944kB, anon-rss:1440kB, file-rss:1024kB, shmem-rss:68kB
[   82.815896] BUG: unable to handle kernel NULL pointer dereference at 00000025
[   82.816733] IP: [<81e30134>] mmput_async+0x9/0x6b
[   82.817281] *pde = 00000000
[   82.817628] Oops: 0002 [#1] PREEMPT DEBUG_PAGEALLOC
[   82.818169] CPU: 0 PID: 13 Comm: oom_reaper Not tainted 4.6.0-10870-gdf1e2f5 #1
[   82.818973] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[   82.819867] task: 819a2340 ti: 819a4000 task.ti: 819a4000
[   82.820419] EIP: 0060:[<81e30134>] EFLAGS: 00010246 CPU: 0
[   82.820988] EIP is at mmput_async+0x9/0x6b
[   82.821413] EAX: 00000001 EBX: 00000001 ECX: 00000000 EDX: 00000000
[   82.822040] ESI: 00000000 EDI: 819a5e9c EBP: 819a5e7c ESP: 819a5e78
[   82.822683]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[   82.823226] CR0: 80050033 CR2: 00000025 CR3: 00740000 CR4: 00000690
[   82.823864] DR0: 6cd78000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[   82.824511] DR6: ffff0ff0 DR7: 00000600
----------------------------------------

The crash itself seems to be caused by use of uninitialized mm.
(Wow! The compiler failed to warn it.)

----------------------------------------
static bool __oom_reap_task(struct task_struct *tsk)
{
        struct mmu_gather tlb;
        struct vm_area_struct *vma;
        struct mm_struct *mm; /***** Not initialized as of df1e2f5 *****/
        struct task_struct *p;
        struct zap_details details = {.check_swap_entries = true,
                                      .ignore_dirty = true};
        bool ret = true;

        /*
         * We have to make sure to not race with the victim exit path
         * and cause premature new oom victim selection:
         * __oom_reap_task              exit_mm
         *   atomic_inc_not_zero
         *                                mmput
         *                                  atomic_dec_and_test
         *                                exit_oom_victim
         *                              [...]
         *                              out_of_memory
         *                                select_bad_process
         *                                  # no TIF_MEMDIE task select new victim
         *  unmap_page_range # frees some memory
         */
        mutex_lock(&oom_lock);

        /*
         * Make sure we find the associated mm_struct even when the particular
         * thread has already terminated and cleared its mm.
         * We might have race with exit path so consider our work done if there
         * is no mm.
         */
        p = find_lock_task_mm(tsk);  /***** Seems that p == NULL here. *****/
        if (!p)
                goto unlock_oom;

        mm = p->mm;
        if (!atomic_inc_not_zero(&mm->mm_users)) {
                task_unlock(p);
                goto unlock_oom;
        }
(...snipped...)
unlock_oom:
        mutex_unlock(&oom_lock);
        /*
         * Drop our reference but make sure the mmput slow path is called from a
         * different context because we shouldn't risk we get stuck there and
         * put the oom_reaper out of the way.
         */
        mmput_async(mm); /***** Passed uninitialized mm which had a value 0x00000001 by chance. *****/
        return ret;
}
----------------------------------------

The consecutive oom_reaper message on the same thread

----------
[   82.706724] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26488kB
[   82.715540] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
[   82.717662] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:26900kB
[   82.725804] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:27296kB
[   82.739091] oom_reaper: reaped process 3914 (trinity-c0), now anon-rss:0kB, file-rss:0kB, shmem-rss:28148kB
----------

suggests that it repeated race that trinity-c0 called out_of_memory()
and hit the shortcut

	if (current->mm &&
	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
		mark_oom_victim(current);
		try_oom_reaper(current);
		return true;
	}

and got TIF_MEMDIE and woke up the OOM reaper. But the OOM reaper started
oom_reap_task() and cleared TIF_MEMDIE from trinity-c0 BEFORE trinity-c0
tries to allocate using ALLOC_NO_WATERMARKS via TIF_MEMDIE.

As a result, trinity-c0 was unable to use ALLOC_NO_WATERMARKS and had to call
out_of_memory() again. And again hit the shortcut and got TIF_MEMDIE and woke
up the OOM reaper, the OOM reaper cleared TIF_MEMDIE. So, this set TIF_MEMDIE
followed by clear TIF_MEMDIE repetition lasted for several times. Maybe we
should not try to clear TIF_MEMDIE from the OOM reaper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
