Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id EB02B828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 19:32:53 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id yy13so255469316pab.3
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:32:53 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id bf9si11566192pac.163.2016.01.12.16.32.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 16:32:52 -0800 (PST)
Received: by mail-pa0-x233.google.com with SMTP id ho8so87310933pac.2
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:32:52 -0800 (PST)
Date: Tue, 12 Jan 2016 16:32:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm,oom: Exclude TIF_MEMDIE processes from
 candidates.
In-Reply-To: <201601081909.CDJ52685.HLFOFJFOQMVOtS@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1601121626310.28831@chino.kir.corp.google.com>
References: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp> <20160107091512.GB27868@dhcp22.suse.cz> <201601072231.DGG78695.OOFVLHJFFQOStM@I-love.SAKURA.ne.jp> <20160107145841.GN27868@dhcp22.suse.cz> <20160107154436.GO27868@dhcp22.suse.cz>
 <201601081909.CDJ52685.HLFOFJFOQMVOtS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, hannes@cmpxchg.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 8 Jan 2016, Tetsuo Handa wrote:

> The OOM reaper kernel thread can reclaim OOM victim's memory before the
> victim terminates.  But since oom_kill_process() tries to kill children of
> the memory hog process first, the OOM reaper can not reclaim enough memory
> for terminating the victim if the victim is consuming little memory.  The
> result is OOM livelock as usual, for timeout based next OOM victim
> selection is not implemented.
> 
> While SysRq-f (manual invocation of the OOM killer) can wake up the OOM
> killer, the OOM killer chooses the same OOM victim which already has
> TIF_MEMDIE.  This is effectively disabling SysRq-f.
> 
> This patch excludes TIF_MEMDIE processes from candidates so that the
> memory hog process itself will be killed when all children of the memory
> hog process got stuck with TIF_MEMDIE pending.
> 
> [  120.078776] oom-write invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO)
> [  120.088610] oom-write cpuset=/ mems_allowed=0
> [  120.095558] CPU: 0 PID: 9546 Comm: oom-write Not tainted 4.4.0-rc6-next-20151223 #260
> (...snipped...)
> [  120.194148] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
> (...snipped...)
> [  120.260191] [ 9546]  1000  9546   541716   453473     896       6        0             0 oom-write
> [  120.262166] [ 9547]  1000  9547       40        1       3       2        0             0 write
> [  120.264071] [ 9548]  1000  9548       40        1       3       2        0             0 write
> [  120.265939] [ 9549]  1000  9549       40        1       4       2        0             0 write
> [  120.267794] [ 9550]  1000  9550       40        1       3       2        0             0 write
> [  120.269654] [ 9551]  1000  9551       40        1       3       2        0             0 write
> [  120.271447] [ 9552]  1000  9552       40        1       3       2        0             0 write
> [  120.273220] [ 9553]  1000  9553       40        1       3       2        0             0 write
> [  120.274975] [ 9554]  1000  9554       40        1       3       2        0             0 write
> [  120.276745] [ 9555]  1000  9555       40        1       3       2        0             0 write
> [  120.278516] [ 9556]  1000  9556       40        1       3       2        0             0 write
> [  120.280227] Out of memory: Kill process 9546 (oom-write) score 892 or sacrifice child
> [  120.282010] Killed process 9549 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
> (...snipped...)
> [  122.506001] systemd-journal invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|GFP_COLD)
> [  122.515041] systemd-journal cpuset=/ mems_allowed=0
> (...snipped...)
> [  122.697515] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
> [  122.699492] [ 9551]  1000  9551       40        1       3       2        0             0 write
> [  122.701399] [ 9552]  1000  9552       40        1       3       2        0             0 write
> [  122.703282] [ 9553]  1000  9553       40        1       3       2        0             0 write
> [  122.705188] [ 9554]  1000  9554       40        1       3       2        0             0 write
> [  122.707017] [ 9555]  1000  9555       40        1       3       2        0             0 write
> [  122.708842] [ 9556]  1000  9556       40        1       3       2        0             0 write
> [  122.710675] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
> [  122.712475] Killed process 9551 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
> [  139.606508] sysrq: SysRq : Manual OOM execution
> [  139.612371] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
> [  139.620210] kworker/0:2 cpuset=/ mems_allowed=0
> (...snipped...)
> [  139.795759] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
> [  139.797649] [ 9551]  1000  9551       40        0       3       2        0             0 write
> [  139.799526] [ 9552]  1000  9552       40        1       3       2        0             0 write
> [  139.801368] [ 9553]  1000  9553       40        1       3       2        0             0 write
> [  139.803249] [ 9554]  1000  9554       40        1       3       2        0             0 write
> [  139.805020] [ 9555]  1000  9555       40        1       3       2        0             0 write
> [  139.806799] [ 9556]  1000  9556       40        1       3       2        0             0 write
> [  139.808524] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
> [  139.810216] Killed process 9552 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
> (...snipped...)
> [  142.571815] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
> [  142.573840] [ 9551]  1000  9551       40        0       3       2        0             0 write
> [  142.575754] [ 9552]  1000  9552       40        0       3       2        0             0 write
> [  142.577633] [ 9553]  1000  9553       40        1       3       2        0             0 write
> [  142.579433] [ 9554]  1000  9554       40        1       3       2        0             0 write
> [  142.581250] [ 9555]  1000  9555       40        1       3       2        0             0 write
> [  142.583003] [ 9556]  1000  9556       40        1       3       2        0             0 write
> [  142.585055] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
> [  142.586796] Killed process 9553 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
> [  143.599058] sysrq: SysRq : Manual OOM execution
> [  143.604300] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
> (...snipped...)
> [  143.783739] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
> [  143.785691] [ 9551]  1000  9551       40        0       3       2        0             0 write
> [  143.787532] [ 9552]  1000  9552       40        0       3       2        0             0 write
> [  143.789377] [ 9553]  1000  9553       40        0       3       2        0             0 write
> [  143.791172] [ 9554]  1000  9554       40        1       3       2        0             0 write
> [  143.792985] [ 9555]  1000  9555       40        1       3       2        0             0 write
> [  143.794730] [ 9556]  1000  9556       40        1       3       2        0             0 write
> [  143.796723] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
> [  143.798338] Killed process 9554 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
> [  144.374525] sysrq: SysRq : Manual OOM execution
> [  144.379779] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
> (...snipped...)
> [  144.560718] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
> [  144.562657] [ 9551]  1000  9551       40        0       3       2        0             0 write
> [  144.564560] [ 9552]  1000  9552       40        0       3       2        0             0 write
> [  144.566369] [ 9553]  1000  9553       40        0       3       2        0             0 write
> [  144.568246] [ 9554]  1000  9554       40        0       3       2        0             0 write
> [  144.570001] [ 9555]  1000  9555       40        1       3       2        0             0 write
> [  144.571794] [ 9556]  1000  9556       40        1       3       2        0             0 write
> [  144.573502] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
> [  144.575119] Killed process 9555 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
> [  145.158485] sysrq: SysRq : Manual OOM execution
> [  145.163600] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
> (...snipped...)
> [  145.346059] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
> [  145.348012] [ 9551]  1000  9551       40        0       3       2        0             0 write
> [  145.349954] [ 9552]  1000  9552       40        0       3       2        0             0 write
> [  145.351817] [ 9553]  1000  9553       40        0       3       2        0             0 write
> [  145.353701] [ 9554]  1000  9554       40        0       3       2        0             0 write
> [  145.355568] [ 9555]  1000  9555       40        0       3       2        0             0 write
> [  145.357319] [ 9556]  1000  9556       40        1       3       2        0             0 write
> [  145.359114] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
> [  145.360733] Killed process 9556 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
> [  169.158408] sysrq: SysRq : Manual OOM execution
> [  169.163612] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
> (...snipped...)
> [  169.343115] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
> [  169.345053] [ 9551]  1000  9551       40        0       3       2        0             0 write
> [  169.346884] [ 9552]  1000  9552       40        0       3       2        0             0 write
> [  169.348965] [ 9553]  1000  9553       40        0       3       2        0             0 write
> [  169.350893] [ 9554]  1000  9554       40        0       3       2        0             0 write
> [  169.352713] [ 9555]  1000  9555       40        0       3       2        0             0 write
> [  169.354551] [ 9556]  1000  9556       40        0       3       2        0             0 write
> [  169.356450] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
> [  169.358105] Killed process 9551 (write) total-vm:160kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  178.950315] sysrq: SysRq : Manual OOM execution
> [  178.955560] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
> (...snipped...)
> [  179.140752] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
> [  179.142653] [ 9551]  1000  9551       40        0       3       2        0             0 write
> [  179.144997] [ 9552]  1000  9552       40        0       3       2        0             0 write
> [  179.146849] [ 9553]  1000  9553       40        0       3       2        0             0 write
> [  179.148654] [ 9554]  1000  9554       40        0       3       2        0             0 write
> [  179.150411] [ 9555]  1000  9555       40        0       3       2        0             0 write
> [  179.152291] [ 9556]  1000  9556       40        0       3       2        0             0 write
> [  179.154002] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
> [  179.155666] Killed process 9551 (write) total-vm:160kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/oom_kill.c | 30 +++++++++++++++++++++++++++---
>  1 file changed, 27 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ef89fda..edce443 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -125,6 +125,30 @@ found:
>  }
> 
>  /*
> + * Treat the whole process p as unkillable when one of threads has
> + * TIF_MEMDIE pending. Otherwise, we may end up setting TIF_MEMDIE
> + * on the same victim forever (e.g. making SysRq-f unusable).
> + */
> +static struct task_struct *find_lock_non_victim_task_mm(struct task_struct *p)
> +{
> +	struct task_struct *t;
> +
> +	rcu_read_lock();
> +
> +	for_each_thread(p, t) {
> +		if (likely(!test_tsk_thread_flag(t, TIF_MEMDIE)))
> +			continue;
> +		t = NULL;
> +		goto found;
> +	}
> +	t = find_lock_task_mm(p);
> + found:
> +	rcu_read_unlock();
> +
> +	return t;
> +}
> +
> +/*
>   * order == -1 means the oom kill is required by sysrq, otherwise only
>   * for display purposes.
>   */
> @@ -171,7 +195,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  	if (oom_unkillable_task(p, memcg, nodemask))
>  		return 0;
> 
> -	p = find_lock_task_mm(p);
> +	p = find_lock_non_victim_task_mm(p);
>  	if (!p)
>  		return 0;
> 

I understand how this may make your test case pass, but I simply don't 
understand how this could possibly be the correct thing to do.  This would 
cause oom_badness() to return 0 for any process where a thread has 
TIF_MEMDIE set.  If the oom killer is called from the page allocator, 
kills a thread, and it is recalled before that thread may exit, then this 
will panic the system if there are no other eligible processes to kill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
