Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE3216B0271
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 09:58:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v105so1298246wrc.11
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 06:58:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z72si707208wmz.132.2017.11.01.06.58.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 06:58:57 -0700 (PDT)
Date: Wed, 1 Nov 2017 14:58:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm,oom: Use ALLOC_OOM for OOM victim's last second
 allocation.
Message-ID: <20171101135855.bqg2kuj6ao2cicqi@dhcp22.suse.cz>
References: <1509537268-4726-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1509537268-4726-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509537268-4726-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Manish Jaggi <mjaggi@caviumnetworks.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@virtuozzo.com>

On Wed 01-11-17 20:54:28, Tetsuo Handa wrote:
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
> victims.

So what you are essentially saying is that there is a race window
Proc1					Proc2				oom_reaper
__alloc_pages_slowpath			out_of_memory
  __gfp_pfmemalloc_flags		  select_bad_process # Proc1
[1]  oom_reserves_allowed # false	  oom_kill_process
    									  oom_reap_task
  __alloc_pages_may_oom							    __oom_reap_task_mm
  									      # doesn't unmap anything
      									    set_bit(MMF_OOM_SKIP)
    out_of_memory
      task_will_free_mem
[2]     MMF_OOM_SKIP check # true
      select_bad_process # Another victim

mostly because the above is an artificial workload which triggers the
pathological path where nothing is really unmapped due to mlocked
memory, which makes the race window (1-2) smaller than it usually is. So
this is pretty much a corner case which we want to address by making
mlocked pages really reapable. Trying to use memory reserves for the
oom victims reduces changes of the race.

This would be really useful to have in the changelog IMHO.

> There is no need that the OOM victim is such malicious that consumes all
> memory. It is possible that a multithreaded but non memory hog process is
> selected by the OOM killer, and the OOM reaper fails to reclaim memory due
> to e.g. khugepaged [2], and the process fails to try allocation from memory
> reserves.

I am not sure about this part though. If the oom_reaper cannot take the
mmap_sem then it retries for 1s. Have you ever seen the race to be that
large?

> Therefore, this patch allows OOM victims to use ALLOC_OOM watermark
> for last second allocation attempt.
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
>  mm/page_alloc.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6654f52..382ed57 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4112,9 +4112,14 @@ struct page *alloc_pages_before_oomkill(const struct oom_control *oc)
>  	 * we're still under heavy pressure. But make sure that this reclaim
>  	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
>  	 * allocation which will never fail due to oom_lock already held.
> +	 * Also, make sure that OOM victims can try ALLOC_OOM watermark in case
> +	 * they haven't tried ALLOC_OOM watermark.
>  	 */
>  	return get_page_from_freelist((oc->gfp_mask | __GFP_HARDWALL) &
>  				      ~__GFP_DIRECT_RECLAIM, oc->order,
> +				      oom_reserves_allowed(current) &&
> +				      !(oc->gfp_mask & __GFP_NOMEMALLOC) ?
> +				      ALLOC_OOM :
>  				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, oc->ac);

This just makes my eyes bleed. Really, why don't you simply make this
more readable.

	int alloc_flags = ALLOC_CPUSET | ALLOC_WMARK_HIGH;
	gfp_t gfp_mask = oc->gfp_mask | __GFP_HARDWALL;
	int reserves

	gfp_mask &= ~__GFP_DIRECT_RECLAIM;
	reserves = __gfp_pfmemalloc_flags(gfp_mask);
	if (reserves)
		alloc_flags = reserves;

>  }
>  
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
