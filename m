Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id AD45D828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 05:10:14 -0500 (EST)
Received: by mail-io0-f172.google.com with SMTP id q21so281412407iod.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 02:10:14 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 69si6368799iob.145.2016.01.08.02.10.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jan 2016 02:10:13 -0800 (PST)
Subject: Re: [PATCH v2] mm,oom: Exclude TIF_MEMDIE processes from candidates.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp>
	<20160107091512.GB27868@dhcp22.suse.cz>
	<201601072231.DGG78695.OOFVLHJFFQOStM@I-love.SAKURA.ne.jp>
	<20160107145841.GN27868@dhcp22.suse.cz>
	<20160107154436.GO27868@dhcp22.suse.cz>
In-Reply-To: <20160107154436.GO27868@dhcp22.suse.cz>
Message-Id: <201601081909.CDJ52685.HLFOFJFOQMVOtS@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jan 2016 19:09:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 07-01-16 15:58:41, Michal Hocko wrote:
> > On Thu 07-01-16 22:31:32, Tetsuo Handa wrote:
> > [...]
> > > I think we need to filter at select_bad_process() and oom_kill_process().
> > >
> > > When P has no children, P is chosen and TIF_MEMDIE is set on P. But P can
> > > be chosen forever due to P->signal->oom_score_adj == OOM_SCORE_ADJ_MAX
> > > even if the OOM reaper reclaimed P's mm. We need to ensure that
> > > oom_kill_process() is not called with P if P already has TIF_MEMDIE.
> >
> > Hmm. Any task is allowed to set its oom_score_adj that way and I
> > guess we should really make sure that at least sysrq+f will make some
> > progress. This is what I would do. Again I think this is worth a
> > separate patch. Unless there are any objections I will roll out what I
> > have and post 3 separate patches.
> > ---
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 45e51ad2f7cf..ee34a51bd65a 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -333,6 +333,14 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
> >  		if (points == chosen_points && thread_group_leader(chosen))
> >  			continue;
> >
> > +		/*
> > +		 * If the current major task is already ooom killed and this
> > +		 * is sysrq+f request then we rather choose somebody else
> > +		 * because the current oom victim might be stuck.
> > +		 */
> > +		if (is_sysrq_oom(sc) && test_tsk_thread_flag(p, TIF_MEMDIE))
> > +			continue;
> > +
> >  		chosen = p;
> >  		chosen_points = points;
> >  	}
>
> I guess we can move this up to oom_scan_process_thread already. It would
> be simpler and I it should be also more appropriate because we already
> do sysrq specific handling there:
> ---
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 45e51ad2f7cf..a27a43212075 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -277,10 +277,16 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  	/*
>  	 * This task already has access to memory reserves and is being killed.
>  	 * Don't allow any other task to have access to the reserves.
> +	 * If we are doing sysrq+f then it doesn't make any sense to check such
> +	 * a task because it might be stuck and unable to terminate while the
> +	 * forced OOM might be the only option left to get the system back to
> +	 * work.
>  	 */

"the forced OOM might be the only option left to get the system back to work"
makes an admission that "it doesn't make sense to wait for such a task forever
but we do not offer other options to get the system back to work". The forced
OOM is not always available on non-desktop systems; we can't ask administrators
to stand by in front of the console twenty-four seven.

We spent more than one year and found several bugs, but we still cannot find
bulletproof OOM handling. We are making the code more and more complicated and
difficult to test all cases. Unspotted corner cases annoy administrators and
troubleshooting staffs at support center (e.g. me). For some systems, papering
over OOM related problems is more important than trying to debug to the last
second. Firstly, we should offer another option to get the system back to work
( http://lkml.kernel.org/r/201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp )
for such systems. After that, we can try to avoid using such options.

>  	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
>  		if (!is_sysrq_oom(oc))
>  			return OOM_SCAN_ABORT;
> +		else
> +			return OOM_SCAN_CONTINUE;

This preserves possibility of choosing a !TIF_MEMDIE thread which belongs
to a process which at least one of threads is a TIF_MEMDIE thread.
We can't guarantee that find_lock_task_mm() from oom_kill_process() chooses
a !TIF_MEMDIE thread unless we check TIF_MEMDIE at find_lock_task_mm().

If we don't want to require SysRq-f for each thread in a process, updated
patch shown below will guarantee (for both SysRq-f option and another option
in the patch above). We can change like

static struct task_struct *find_lock_non_victim_task_mm(struct task_struct *p)
{
	struct task_struct *t;

	rcu_read_lock();

	for_each_thread(p, t) {
		if (unlikely(test_tsk_thread_flag(t, TIF_MEMDIE)))
			continue;
		task_lock(t);
		if (likely(t->mm))
			goto found;
		task_unlock(t);
	}
	t = NULL;
 found:
	rcu_read_unlock();

	return t;
}

if we want to require SysRq-f for each thread in a process.

>  	}
>  	if (!task->mm)
>  		return OOM_SCAN_CONTINUE;
>
----------------------------------------
>From 1b199467eaf9e3a8cdac5eacde704fbd13969f68 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 8 Jan 2016 12:40:02 +0900
Subject: [PATCH v2] mm,oom: exclude TIF_MEMDIE processes from candidates.

The OOM reaper kernel thread can reclaim OOM victim's memory before the
victim terminates.  But since oom_kill_process() tries to kill children of
the memory hog process first, the OOM reaper can not reclaim enough memory
for terminating the victim if the victim is consuming little memory.  The
result is OOM livelock as usual, for timeout based next OOM victim
selection is not implemented.

While SysRq-f (manual invocation of the OOM killer) can wake up the OOM
killer, the OOM killer chooses the same OOM victim which already has
TIF_MEMDIE.  This is effectively disabling SysRq-f.

This patch excludes TIF_MEMDIE processes from candidates so that the
memory hog process itself will be killed when all children of the memory
hog process got stuck with TIF_MEMDIE pending.

[  120.078776] oom-write invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO)
[  120.088610] oom-write cpuset=/ mems_allowed=0
[  120.095558] CPU: 0 PID: 9546 Comm: oom-write Not tainted 4.4.0-rc6-next-20151223 #260
(...snipped...)
[  120.194148] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
(...snipped...)
[  120.260191] [ 9546]  1000  9546   541716   453473     896       6        0             0 oom-write
[  120.262166] [ 9547]  1000  9547       40        1       3       2        0             0 write
[  120.264071] [ 9548]  1000  9548       40        1       3       2        0             0 write
[  120.265939] [ 9549]  1000  9549       40        1       4       2        0             0 write
[  120.267794] [ 9550]  1000  9550       40        1       3       2        0             0 write
[  120.269654] [ 9551]  1000  9551       40        1       3       2        0             0 write
[  120.271447] [ 9552]  1000  9552       40        1       3       2        0             0 write
[  120.273220] [ 9553]  1000  9553       40        1       3       2        0             0 write
[  120.274975] [ 9554]  1000  9554       40        1       3       2        0             0 write
[  120.276745] [ 9555]  1000  9555       40        1       3       2        0             0 write
[  120.278516] [ 9556]  1000  9556       40        1       3       2        0             0 write
[  120.280227] Out of memory: Kill process 9546 (oom-write) score 892 or sacrifice child
[  120.282010] Killed process 9549 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  122.506001] systemd-journal invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|GFP_COLD)
[  122.515041] systemd-journal cpuset=/ mems_allowed=0
(...snipped...)
[  122.697515] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
[  122.699492] [ 9551]  1000  9551       40        1       3       2        0             0 write
[  122.701399] [ 9552]  1000  9552       40        1       3       2        0             0 write
[  122.703282] [ 9553]  1000  9553       40        1       3       2        0             0 write
[  122.705188] [ 9554]  1000  9554       40        1       3       2        0             0 write
[  122.707017] [ 9555]  1000  9555       40        1       3       2        0             0 write
[  122.708842] [ 9556]  1000  9556       40        1       3       2        0             0 write
[  122.710675] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
[  122.712475] Killed process 9551 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
[  139.606508] sysrq: SysRq : Manual OOM execution
[  139.612371] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
[  139.620210] kworker/0:2 cpuset=/ mems_allowed=0
(...snipped...)
[  139.795759] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
[  139.797649] [ 9551]  1000  9551       40        0       3       2        0             0 write
[  139.799526] [ 9552]  1000  9552       40        1       3       2        0             0 write
[  139.801368] [ 9553]  1000  9553       40        1       3       2        0             0 write
[  139.803249] [ 9554]  1000  9554       40        1       3       2        0             0 write
[  139.805020] [ 9555]  1000  9555       40        1       3       2        0             0 write
[  139.806799] [ 9556]  1000  9556       40        1       3       2        0             0 write
[  139.808524] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
[  139.810216] Killed process 9552 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
(...snipped...)
[  142.571815] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
[  142.573840] [ 9551]  1000  9551       40        0       3       2        0             0 write
[  142.575754] [ 9552]  1000  9552       40        0       3       2        0             0 write
[  142.577633] [ 9553]  1000  9553       40        1       3       2        0             0 write
[  142.579433] [ 9554]  1000  9554       40        1       3       2        0             0 write
[  142.581250] [ 9555]  1000  9555       40        1       3       2        0             0 write
[  142.583003] [ 9556]  1000  9556       40        1       3       2        0             0 write
[  142.585055] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
[  142.586796] Killed process 9553 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
[  143.599058] sysrq: SysRq : Manual OOM execution
[  143.604300] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
(...snipped...)
[  143.783739] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
[  143.785691] [ 9551]  1000  9551       40        0       3       2        0             0 write
[  143.787532] [ 9552]  1000  9552       40        0       3       2        0             0 write
[  143.789377] [ 9553]  1000  9553       40        0       3       2        0             0 write
[  143.791172] [ 9554]  1000  9554       40        1       3       2        0             0 write
[  143.792985] [ 9555]  1000  9555       40        1       3       2        0             0 write
[  143.794730] [ 9556]  1000  9556       40        1       3       2        0             0 write
[  143.796723] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
[  143.798338] Killed process 9554 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
[  144.374525] sysrq: SysRq : Manual OOM execution
[  144.379779] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
(...snipped...)
[  144.560718] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
[  144.562657] [ 9551]  1000  9551       40        0       3       2        0             0 write
[  144.564560] [ 9552]  1000  9552       40        0       3       2        0             0 write
[  144.566369] [ 9553]  1000  9553       40        0       3       2        0             0 write
[  144.568246] [ 9554]  1000  9554       40        0       3       2        0             0 write
[  144.570001] [ 9555]  1000  9555       40        1       3       2        0             0 write
[  144.571794] [ 9556]  1000  9556       40        1       3       2        0             0 write
[  144.573502] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
[  144.575119] Killed process 9555 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
[  145.158485] sysrq: SysRq : Manual OOM execution
[  145.163600] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
(...snipped...)
[  145.346059] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
[  145.348012] [ 9551]  1000  9551       40        0       3       2        0             0 write
[  145.349954] [ 9552]  1000  9552       40        0       3       2        0             0 write
[  145.351817] [ 9553]  1000  9553       40        0       3       2        0             0 write
[  145.353701] [ 9554]  1000  9554       40        0       3       2        0             0 write
[  145.355568] [ 9555]  1000  9555       40        0       3       2        0             0 write
[  145.357319] [ 9556]  1000  9556       40        1       3       2        0             0 write
[  145.359114] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
[  145.360733] Killed process 9556 (write) total-vm:160kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
[  169.158408] sysrq: SysRq : Manual OOM execution
[  169.163612] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
(...snipped...)
[  169.343115] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
[  169.345053] [ 9551]  1000  9551       40        0       3       2        0             0 write
[  169.346884] [ 9552]  1000  9552       40        0       3       2        0             0 write
[  169.348965] [ 9553]  1000  9553       40        0       3       2        0             0 write
[  169.350893] [ 9554]  1000  9554       40        0       3       2        0             0 write
[  169.352713] [ 9555]  1000  9555       40        0       3       2        0             0 write
[  169.354551] [ 9556]  1000  9556       40        0       3       2        0             0 write
[  169.356450] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
[  169.358105] Killed process 9551 (write) total-vm:160kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  178.950315] sysrq: SysRq : Manual OOM execution
[  178.955560] kworker/0:2 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
(...snipped...)
[  179.140752] [ 9546]  1000  9546   541716   458687     906       6        0             0 oom-write
[  179.142653] [ 9551]  1000  9551       40        0       3       2        0             0 write
[  179.144997] [ 9552]  1000  9552       40        0       3       2        0             0 write
[  179.146849] [ 9553]  1000  9553       40        0       3       2        0             0 write
[  179.148654] [ 9554]  1000  9554       40        0       3       2        0             0 write
[  179.150411] [ 9555]  1000  9555       40        0       3       2        0             0 write
[  179.152291] [ 9556]  1000  9556       40        0       3       2        0             0 write
[  179.154002] Out of memory: Kill process 9546 (oom-write) score 902 or sacrifice child
[  179.155666] Killed process 9551 (write) total-vm:160kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/oom_kill.c | 30 +++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ef89fda..edce443 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -125,6 +125,30 @@ found:
 }

 /*
+ * Treat the whole process p as unkillable when one of threads has
+ * TIF_MEMDIE pending. Otherwise, we may end up setting TIF_MEMDIE
+ * on the same victim forever (e.g. making SysRq-f unusable).
+ */
+static struct task_struct *find_lock_non_victim_task_mm(struct task_struct *p)
+{
+	struct task_struct *t;
+
+	rcu_read_lock();
+
+	for_each_thread(p, t) {
+		if (likely(!test_tsk_thread_flag(t, TIF_MEMDIE)))
+			continue;
+		t = NULL;
+		goto found;
+	}
+	t = find_lock_task_mm(p);
+ found:
+	rcu_read_unlock();
+
+	return t;
+}
+
+/*
  * order == -1 means the oom kill is required by sysrq, otherwise only
  * for display purposes.
  */
@@ -171,7 +195,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	if (oom_unkillable_task(p, memcg, nodemask))
 		return 0;

-	p = find_lock_task_mm(p);
+	p = find_lock_non_victim_task_mm(p);
 	if (!p)
 		return 0;

@@ -367,7 +391,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 		if (oom_unkillable_task(p, memcg, nodemask))
 			continue;

-		task = find_lock_task_mm(p);
+		task = find_lock_non_victim_task_mm(p);
 		if (!task) {
 			/*
 			 * This is a kthread or all of p's threads have already
@@ -708,7 +732,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	read_unlock(&tasklist_lock);

-	p = find_lock_task_mm(victim);
+	p = find_lock_non_victim_task_mm(victim);
 	if (!p) {
 		put_task_struct(victim);
 		return;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
