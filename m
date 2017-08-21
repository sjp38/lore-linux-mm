Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDB5280310
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 04:43:11 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p14so19308684wrg.8
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 01:43:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s26si8981295wrs.289.2017.08.21.01.43.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Aug 2017 01:43:09 -0700 (PDT)
Date: Mon, 21 Aug 2017 10:43:07 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, oom: task_will_free_mem(current) should ignore
 MMF_OOM_SKIP for once.
Message-ID: <20170821084307.GB25956@dhcp22.suse.cz>
References: <1501718104-8099-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201708191523.BJH90621.MHOOFFQSOLJFtV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708191523.BJH90621.MHOOFFQSOLJFtV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov@virtuozzo.com

On Sat 19-08-17 15:23:19, Tetsuo Handa wrote:
> Tetsuo Handa wrote at http://lkml.kernel.org/r/201708102328.ACD34352.OHFOLJMQVSFOFt@I-love.SAKURA.ne.jp :
> > Michal Hocko wrote:
> > > On Thu 10-08-17 21:10:30, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Tue 08-08-17 11:14:50, Tetsuo Handa wrote:
> > > > > > Michal Hocko wrote:
> > > > > > > On Sat 05-08-17 10:02:55, Tetsuo Handa wrote:
> > > > > > > > Michal Hocko wrote:
> > > > > > > > > On Wed 26-07-17 20:33:21, Tetsuo Handa wrote:
> > > > > > > > > > My question is, how can users know it if somebody was OOM-killed needlessly
> > > > > > > > > > by allowing MMF_OOM_SKIP to race.
> > > > > > > > > 
> > > > > > > > > Is it really important to know that the race is due to MMF_OOM_SKIP?
> > > > > > > > 
> > > > > > > > Yes, it is really important. Needlessly selecting even one OOM victim is
> > > > > > > > a pain which is difficult to explain to and persuade some of customers.
> > > > > > > 
> > > > > > > How is this any different from a race with a task exiting an releasing
> > > > > > > some memory after we have crossed the point of no return and will kill
> > > > > > > something?
> > > > > > 
> > > > > > I'm not complaining about an exiting task releasing some memory after we have
> > > > > > crossed the point of no return.
> > > > > > 
> > > > > > What I'm saying is that we can postpone "the point of no return" if we ignore
> > > > > > MMF_OOM_SKIP for once (both this "oom_reaper: close race without using oom_lock"
> > > > > > thread and "mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for
> > > > > > once." thread). These are race conditions we can avoid without crystal ball.
> > > > > 
> > > > > If those races are really that common than we can handle them even
> > > > > without "try once more" tricks. Really this is just an ugly hack. If you
> > > > > really care then make sure that we always try to allocate from memory
> > > > > reserves before going down the oom path. In other words, try to find a
> > > > > robust solution rather than tweaks around a problem.
> > > > 
> > > > Since your "mm, oom: allow oom reaper to race with exit_mmap" patch removes
> > > > oom_lock serialization from the OOM reaper, possibility of calling out_of_memory()
> > > > due to successful mutex_trylock(&oom_lock) would increase when the OOM reaper set
> > > > MMF_OOM_SKIP quickly.
> > > > 
> > > > What if task_is_oom_victim(current) became true and MMF_OOM_SKIP was set
> > > > on current->mm between after __gfp_pfmemalloc_flags() returned 0 and before
> > > > out_of_memory() is called (due to successful mutex_trylock(&oom_lock)) ?
> > > > 
> > > > Excuse me? Are you suggesting to try memory reserves before
> > > > task_is_oom_victim(current) becomes true?
> > > 
> > > No what I've tried to say is that if this really is a real problem,
> > > which I am not sure about, then the proper way to handle that is to
> > > attempt to allocate from memory reserves for an oom victim. I would be
> > > even willing to take the oom_lock back into the oom reaper path if the
> > > former turnes out to be awkward to implement. But all this assumes this
> > > is a _real_ problem.
> > 
> > Aren't we back to square one? My question is, how can users know it if
> > somebody was OOM-killed needlessly by allowing MMF_OOM_SKIP to race.
> > 
> > You don't want to call get_page_from_freelist() from out_of_memory(), do you?
> > But without passing a flag "whether get_page_from_freelist() with memory reserves
> > was already attempted if current thread is an OOM victim" to task_will_free_mem()
> > in out_of_memory() and a flag "whether get_page_from_freelist() without memory
> > reserves was already attempted if current thread is not an OOM victim" to
> > test_bit(MMF_OOM_SKIP) in oom_evaluate_task(), we won't be able to know
> > if somebody was OOM-killed needlessly by allowing MMF_OOM_SKIP to race.
> 
> Michal, I did not get your answer, and your "mm, oom: do not rely on
> TIF_MEMDIE for memory reserves access" did not help solving this problem.
> (I confirmed it by reverting your "mm, oom: allow oom reaper to race with
> exit_mmap" and applying Andrea's "mm: oom: let oom_reap_task and exit_mmap
> run concurrently" and this patch on top of linux-next-20170817.)

By "this patch" you probably mean a BUG_ON(tsk_is_oom_victim) somewhere
in task_will_free_mem right? I do not see anything like that in you
email.

> [  204.413605] Out of memory: Kill process 9286 (a.out) score 930 or sacrifice child
> [  204.416241] Killed process 9286 (a.out) total-vm:4198476kB, anon-rss:72kB, file-rss:0kB, shmem-rss:3465520kB
> [  204.419783] oom_reaper: reaped process 9286 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3465720kB
> [  204.455864] ------------[ cut here ]------------
> [  204.457921] kernel BUG at mm/oom_kill.c:786!
> 
> Therefore, I propose this patch for inclusion.

i've already told you that this is a wrong approach to handle a possible
race and offered you an alternative. I realy fail to see why you keep
reposting it. So to make myself absolutely clear

Nacked-by: Michal Hocko <mhocko@suse.com> to the patch below.
 
> >From cf6ef5a7b110d12e98bb2928e839abee16418188 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Thu, 17 Aug 2017 14:45:31 +0900
> Subject: [PATCH v2] mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for once.
> 
> Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
> count causes random kernel panics when an OOM victim which consumed memory
> in a way the OOM reaper does not help was selected by the OOM killer [1].
> 
> ----------
> oom02       0  TINFO  :  start OOM testing for mlocked pages.
> oom02       0  TINFO  :  expected victim is 4578.
> oom02       0  TINFO  :  thread (ffff8b0e71f0), allocating 3221225472 bytes.
> oom02       0  TINFO  :  thread (ffff8b8e71f0), allocating 3221225472 bytes.
> (...snipped...)
> oom02       0  TINFO  :  thread (ffff8a0e71f0), allocating 3221225472 bytes.
> [  364.737486] oom02:4583 invoked oom-killer: gfp_mask=0x16080c0(GFP_KERNEL|__GFP_ZERO|__GFP_NOTRACK), nodemask=1,  order=0, oom_score_adj=0
> (...snipped...)
> [  365.036127] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
> [  365.044691] [ 1905]     0  1905     3236     1714      10       4        0             0 systemd-journal
> [  365.054172] [ 1908]     0  1908    20247      590       8       4        0             0 lvmetad
> [  365.062959] [ 2421]     0  2421     3241      878       9       3        0         -1000 systemd-udevd
> [  365.072266] [ 3125]     0  3125     3834      719       9       4        0         -1000 auditd
> [  365.080963] [ 3145]     0  3145     1086      630       6       4        0             0 systemd-logind
> [  365.090353] [ 3146]     0  3146     1208      596       7       3        0             0 irqbalance
> [  365.099413] [ 3147]    81  3147     1118      625       5       4        0          -900 dbus-daemon
> [  365.108548] [ 3149]   998  3149   116294     4180      26       5        0             0 polkitd
> [  365.117333] [ 3164]   997  3164    19992      785       9       3        0             0 chronyd
> [  365.126118] [ 3180]     0  3180    55605     7880      29       3        0             0 firewalld
> [  365.135075] [ 3187]     0  3187    87842     3033      26       3        0             0 NetworkManager
> [  365.144465] [ 3290]     0  3290    43037     1224      16       5        0             0 rsyslogd
> [  365.153335] [ 3295]     0  3295   108279     6617      30       3        0             0 tuned
> [  365.161944] [ 3308]     0  3308    27846      676      11       3        0             0 crond
> [  365.170554] [ 3309]     0  3309     3332      616      10       3        0         -1000 sshd
> [  365.179076] [ 3371]     0  3371    27307      364       6       3        0             0 agetty
> [  365.187790] [ 3375]     0  3375    29397     1125      11       3        0             0 login
> [  365.196402] [ 4178]     0  4178     4797     1119      14       4        0             0 master
> [  365.205101] [ 4209]    89  4209     4823     1396      12       4        0             0 pickup
> [  365.213798] [ 4211]    89  4211     4842     1485      12       3        0             0 qmgr
> [  365.222325] [ 4491]     0  4491    27965     1022       8       3        0             0 bash
> [  365.230849] [ 4513]     0  4513      670      365       5       3        0             0 oom02
> [  365.239459] [ 4578]     0  4578 37776030 32890957   64257     138        0             0 oom02
> [  365.248067] Out of memory: Kill process 4578 (oom02) score 952 or sacrifice child
> [  365.255581] Killed process 4578 (oom02) total-vm:151104120kB, anon-rss:131562528kB, file-rss:1300kB, shmem-rss:0kB
> [  365.266829] out_of_memory: Current (4583) has a pending SIGKILL
> [  365.267347] oom_reaper: reaped process 4578 (oom02), now anon-rss:131559616kB, file-rss:0kB, shmem-rss:0kB
> [  365.282658] oom_reaper: reaped process 4583 (oom02), now anon-rss:131561664kB, file-rss:0kB, shmem-rss:0kB
> [  365.283361] oom02:4586 invoked oom-killer: gfp_mask=0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=1,  order=0, oom_score_adj=0
> (...snipped...)
> [  365.576164] oom02:4585 invoked oom-killer: gfp_mask=0x16080c0(GFP_KERNEL|__GFP_ZERO|__GFP_NOTRACK), nodemask=1,  order=0, oom_score_adj=0
> (...snipped...)
> [  365.576298] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
> [  365.576338] [ 2421]     0  2421     3241      878       9       3        0         -1000 systemd-udevd
> [  365.576342] [ 3125]     0  3125     3834      719       9       4        0         -1000 auditd
> [  365.576347] [ 3309]     0  3309     3332      616      10       3        0         -1000 sshd
> [  365.576356] [ 4580]     0  4578 37776030 32890417   64258     138        0             0 oom02
> [  365.576361] Kernel panic - not syncing: Out of memory and no killable processes...
> ----------
> 
> Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
> to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
> victim's mm were not able to try allocation from memory reserves after the
> OOM reaper gave up reclaiming memory.
> 
> Until Linux 4.7, we were using
> 
>   if (current->mm &&
>       (fatal_signal_pending(current) || task_will_free_mem(current)))
> 
> as a condition to try allocation from memory reserves with the risk of OOM
> lockup, but reports like [1] were impossible. Linux 4.8+ are regressed
> compared to Linux 4.7 due to the risk of needlessly selecting more OOM
> victims. We don't need to give up task_will_free_mem(current) before trying
> allocation from memory reserves. We will need to select next OOM victim
> only when allocation from memory reserves did not help.
> 
> There is no need that the OOM victim is such malicious that consumes all
> memory. It is possible that a multithreaded but non memory hog process is
> selected by the OOM killer, and the OOM reaper fails to reclaim memory due
> to e.g. khugepaged [2], and the process fails to try allocation from memory
> reserves.
> 
> Although "mm, oom: do not rely on TIF_MEMDIE for memory reserves access"
> tried to reduce this race window by replacing TIF_MEMDIE with oom_mm, and
> "mm: oom: let oom_reap_task and exit_mmap run concurrently" did not remove
> oom_lock serialization, this race window is still easy to trigger. You can
> confirm it by adding "BUG_ON(1);" at "task->oom_kill_free_check_raced = 1;"
> of this patch.
> 
> Thus, this patch allows task_will_free_mem(current) to ignore MMF_OOM_SKIP
> for once so that task_will_free_mem(current) will not start selecting next
> OOM victim without trying allocation from memory reserves.
> 
> [1] http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com
> [2] http://lkml.kernel.org/r/201708090835.ICI69305.VFFOLMHOStJOQF@I-love.SAKURA.ne.jp
> 
> Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
> Reported-by: Manish Jaggi <mjaggi@caviumnetworks.com>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  include/linux/sched.h |  1 +
>  mm/oom_kill.c         | 14 +++++++++++---
>  2 files changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 6110471..11f8d54 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -652,6 +652,7 @@ struct task_struct {
>  	/* disallow userland-initiated cgroup migration */
>  	unsigned			no_cgroup_migration:1;
>  #endif
> +	unsigned			oom_kill_free_check_raced:1;
>  
>  	unsigned long			atomic_flags; /* Flags requiring atomic access. */
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ab8348d..c5fb8a3 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -749,11 +749,19 @@ static bool task_will_free_mem(struct task_struct *task)
>  		return false;
>  
>  	/*
> -	 * This task has already been drained by the oom reaper so there are
> -	 * only small chances it will free some more
> +	 * The current thread might fail to try OOM_ALLOC allocation if the OOM
> +	 * reaper set MMF_OOM_SKIP on this mm when the current thread was
> +	 * between after __gfp_pfmemalloc_flags() and before out_of_memory().
> +	 * Make sure that the current thread has tried OOM_ALLOC allocation
> +	 * before starting to select the next OOM victims.
>  	 */
> -	if (test_bit(MMF_OOM_SKIP, &mm->flags))
> +	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
> +		if (task == current && !task->oom_kill_free_check_raced) {
> +			task->oom_kill_free_check_raced = 1;
> +			return true;
> +		}
>  		return false;
> +	}
>  
>  	if (atomic_read(&mm->mm_users) <= 1)
>  		return true;
> -- 
> 2.9.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
