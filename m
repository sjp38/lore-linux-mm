Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05D776B0007
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 11:48:10 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id s68-v6so4346410oih.23
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 08:48:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k206-v6si2735284oia.214.2018.07.27.08.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 08:48:08 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
References: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
 <20180726113958.GE28386@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <55c9da7f-e448-964a-5b50-47f89a24235b@i-love.sakura.ne.jp>
Date: Sat, 28 Jul 2018 00:47:40 +0900
MIME-Version: 1.0
In-Reply-To: <20180726113958.GE28386@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/07/26 20:39, Michal Hocko wrote:
> On Thu 26-07-18 20:06:24, Tetsuo Handa wrote:
>> Before applying "an OOM lockup mitigation patch", I want to apply this
>> "another OOM lockup avoidance" patch.
> 
> I do not really see why. All these are borderline interesting as the
> system is basically dead by the time you reach this state.

I don't like your "borderline interesting". We still don't have a watchdog
which tells something went wrong. Thus, "borderline interesting" has to be
examined and fixed.

> 
>> Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20180726.txt.xz
>> (which was captured with
>>
>>   --- a/mm/oom_kill.c
>>   +++ b/mm/oom_kill.c
>>   @@ -1071,6 +1071,12 @@ bool out_of_memory(struct oom_control *oc)
>>    {
>>    	unsigned long freed = 0;
>>    	bool delay = false; /* if set, delay next allocation attempt */
>>   +	static unsigned long last_warned;
>>   +	if (!last_warned || time_after(jiffies, last_warned + 10 * HZ)) {
>>   +		pr_warn("%s(%d) gfp_mask=%#x(%pGg), order=%d\n", current->comm,
>>   +			current->pid, oc->gfp_mask, &oc->gfp_mask, oc->order);
>>   +		last_warned = jiffies;
>>   +	}
>>    
>>    	oc->constraint = CONSTRAINT_NONE;
>>    	if (oom_killer_disabled)
>>
>> in order to demonstrate that the GFP_NOIO allocation from disk_events_workfn() is
>> calling out_of_memory() rather than by error failing to give up direct reclaim).
>>
>> [  258.619119] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
>> [  268.622732] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
>> [  278.635344] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
>> [  288.639360] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
>> [  298.642715] kworker/0:0(5) gfp_mask=0x600000(GFP_NOIO), order=0
> 
> Hmm, so there is no other memory allocation to trigger the oom or they
> all just back off on the oom_lock trylock? In other words what is
> preventing from the oom killer invocation?

All __GFP_FS allocations got stuck at direct reclaim or workqueue.

[  310.265293] systemd         D12240     1      0 0x00000000
[  310.268118] Call Trace:
[  310.269894]  ? __schedule+0x245/0x7f0
[  310.271901]  ? xfs_reclaim_inodes_ag+0x3b8/0x470 [xfs]
[  310.274187]  schedule+0x23/0x80
[  310.275965]  schedule_preempt_disabled+0x5/0x10
[  310.278107]  __mutex_lock+0x3f5/0x9b0
[  310.280070]  ? xfs_reclaim_inodes_ag+0x3b8/0x470 [xfs]
[  310.282451]  xfs_reclaim_inodes_ag+0x3b8/0x470 [xfs]
[  310.284730]  ? lock_acquire+0x51/0x70
[  310.286678]  ? xfs_ail_push_all+0x13/0x60 [xfs]
[  310.288844]  xfs_reclaim_inodes_nr+0x2c/0x40 [xfs]
[  310.291092]  super_cache_scan+0x14b/0x1a0
[  310.293131]  do_shrink_slab+0xfc/0x190
[  310.295082]  shrink_slab+0x240/0x2c0
[  310.297028]  shrink_node+0xe3/0x460
[  310.298899]  do_try_to_free_pages+0xcb/0x380
[  310.300945]  try_to_free_pages+0xbb/0xf0
[  310.302874]  __alloc_pages_slowpath+0x3c1/0xc50
[  310.304931]  ? lock_acquire+0x51/0x70
[  310.306753]  ? set_page_refcounted+0x40/0x40
[  310.308686]  __alloc_pages_nodemask+0x2a6/0x2c0
[  310.310663]  filemap_fault+0x437/0x8e0
[  310.312446]  ? lock_acquire+0x51/0x70
[  310.314150]  ? xfs_ilock+0x86/0x190 [xfs]
[  310.315915]  __xfs_filemap_fault.constprop.21+0x37/0xc0 [xfs]
[  310.318089]  __do_fault+0x13/0x126
[  310.319696]  __handle_mm_fault+0xc8d/0x11c0
[  310.321493]  handle_mm_fault+0x17a/0x390
[  310.323156]  __do_page_fault+0x24c/0x4d0
[  310.324782]  do_page_fault+0x2a/0x70
[  310.326289]  ? page_fault+0x8/0x30
[  310.327745]  page_fault+0x1e/0x30

[  313.714537] systemd-journal D12600   498      1 0x00000000
[  313.716538] Call Trace:
[  313.717683]  ? __schedule+0x245/0x7f0
[  313.719221]  schedule+0x23/0x80
[  313.720586]  schedule_timeout+0x21f/0x400
[  313.722163]  wait_for_completion+0xb2/0x130
[  313.723750]  ? wake_up_q+0x70/0x70
[  313.725134]  flush_work+0x1db/0x2b0
[  313.726535]  ? flush_workqueue_prep_pwqs+0x1b0/0x1b0
[  313.728336]  ? page_alloc_cpu_dead+0x30/0x30
[  313.729936]  drain_all_pages+0x174/0x1e0
[  313.731446]  __alloc_pages_slowpath+0x428/0xc50
[  313.733120]  __alloc_pages_nodemask+0x2a6/0x2c0
[  313.734826]  filemap_fault+0x437/0x8e0
[  313.736296]  ? lock_acquire+0x51/0x70
[  313.737769]  ? xfs_ilock+0x86/0x190 [xfs]
[  313.739309]  __xfs_filemap_fault.constprop.21+0x37/0xc0 [xfs]
[  313.741291]  __do_fault+0x13/0x126
[  313.742667]  __handle_mm_fault+0xc8d/0x11c0
[  313.744245]  handle_mm_fault+0x17a/0x390
[  313.745755]  __do_page_fault+0x24c/0x4d0
[  313.747290]  do_page_fault+0x2a/0x70
[  313.748728]  ? page_fault+0x8/0x30
[  313.750148]  page_fault+0x1e/0x30

[  324.987240] workqueue events_freezable_power_: flags=0x84
[  324.989292]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  324.991482]     in-flight: 5:disk_events_workfn
[  324.993371] workqueue mm_percpu_wq: flags=0x8
[  324.995167]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  324.997363]     pending: vmstat_update, drain_local_pages_wq BAR(498)

[  378.984241] INFO: task systemd-journal:498 blocked for more than 120 seconds.
[  378.986657]       Not tainted 4.18.0-rc6-next-20180724+ #248
[  378.988741] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  378.991343] systemd-journal D12600   498      1 0x00000000
[  378.993434] Call Trace:
[  378.994643]  ? __schedule+0x245/0x7f0
[  378.996158]  schedule+0x23/0x80
[  378.997528]  schedule_timeout+0x21f/0x400
[  378.999112]  wait_for_completion+0xb2/0x130
[  379.000728]  ? wake_up_q+0x70/0x70
[  379.002170]  flush_work+0x1db/0x2b0
[  379.003667]  ? flush_workqueue_prep_pwqs+0x1b0/0x1b0
[  379.005507]  ? page_alloc_cpu_dead+0x30/0x30
[  379.007176]  drain_all_pages+0x174/0x1e0
[  379.008836]  __alloc_pages_slowpath+0x428/0xc50
[  379.010625]  __alloc_pages_nodemask+0x2a6/0x2c0
[  379.012364]  filemap_fault+0x437/0x8e0
[  379.013881]  ? lock_acquire+0x51/0x70
[  379.015373]  ? xfs_ilock+0x86/0x190 [xfs]
[  379.016950]  __xfs_filemap_fault.constprop.21+0x37/0xc0 [xfs]
[  379.019019]  __do_fault+0x13/0x126
[  379.020439]  __handle_mm_fault+0xc8d/0x11c0
[  379.022055]  handle_mm_fault+0x17a/0x390
[  379.023623]  __do_page_fault+0x24c/0x4d0
[  379.025167]  do_page_fault+0x2a/0x70
[  379.026621]  ? page_fault+0x8/0x30
[  379.028022]  page_fault+0x1e/0x30

[  432.759743] systemd-journal D12600   498      1 0x00000000
[  432.761748] Call Trace:
[  432.762892]  ? __schedule+0x245/0x7f0
[  432.764352]  schedule+0x23/0x80
[  432.765673]  schedule_timeout+0x21f/0x400
[  432.767428]  wait_for_completion+0xb2/0x130
[  432.769207]  ? wake_up_q+0x70/0x70
[  432.770764]  flush_work+0x1db/0x2b0
[  432.772223]  ? flush_workqueue_prep_pwqs+0x1b0/0x1b0
[  432.774125]  ? page_alloc_cpu_dead+0x30/0x30
[  432.775873]  drain_all_pages+0x174/0x1e0
[  432.777528]  __alloc_pages_slowpath+0x428/0xc50
[  432.779306]  __alloc_pages_nodemask+0x2a6/0x2c0
[  432.780977]  filemap_fault+0x437/0x8e0
[  432.782503]  ? lock_acquire+0x51/0x70
[  432.784012]  ? xfs_ilock+0x86/0x190 [xfs]
[  432.785556]  __xfs_filemap_fault.constprop.21+0x37/0xc0 [xfs]
[  432.787537]  __do_fault+0x13/0x126
[  432.788930]  __handle_mm_fault+0xc8d/0x11c0
[  432.790570]  handle_mm_fault+0x17a/0x390
[  432.792162]  __do_page_fault+0x24c/0x4d0
[  432.793773]  do_page_fault+0x2a/0x70
[  432.795196]  ? page_fault+0x8/0x30
[  432.796572]  page_fault+0x1e/0x30

[  444.234824] workqueue events_freezable_power_: flags=0x84
[  444.236937]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  444.239138]     in-flight: 5:disk_events_workfn
[  444.241022] workqueue mm_percpu_wq: flags=0x8
[  444.242829]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  444.245057]     pending: vmstat_update, drain_local_pages_wq BAR(498)

>  
> [...]
> 
>> Since the patch shown below was suggested by Michal Hocko at
>> https://marc.info/?l=linux-mm&m=152723708623015 , it is from Michal Hocko.
>>
>> >From cd8095242de13ace61eefca0c3d6f2a5a7b40032 Mon Sep 17 00:00:00 2001
>> From: Michal Hocko <mhocko@suse.com>
>> Date: Thu, 26 Jul 2018 14:40:03 +0900
>> Subject: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at should_reclaim_retry().
>>
>> Tetsuo Handa has reported that it is possible to bypass the short sleep
>> for PF_WQ_WORKER threads which was introduced by commit 373ccbe5927034b5
>> ("mm, vmstat: allow WQ concurrency to discover memory reclaim doesn't make
>> any progress") and moved by commit ede37713737834d9 ("mm: throttle on IO
>> only when there are too many dirty and writeback pages") and lock up the
>> system if OOM.
>>
>> This is because we are implicitly counting on falling back to
>> schedule_timeout_uninterruptible() in __alloc_pages_may_oom() when
>> schedule_timeout_uninterruptible() in should_reclaim_retry() was not
>> called due to __zone_watermark_ok() == false.
> 
> How do we rely on that?

Unless disk_events_workfn() (PID=5) sleeps at schedule_timeout_uninterruptible()
in __alloc_pages_may_oom(), drain_local_pages_wq() which a thread doing __GFP_FS
allocation (PID=498) is waiting for cannot be started.

> 
>> However, schedule_timeout_uninterruptible() in __alloc_pages_may_oom() is
>> not called if all allocating threads but a PF_WQ_WORKER thread got stuck at
>> __GFP_FS direct reclaim, for mutex_trylock(&oom_lock) by that PF_WQ_WORKER
>> thread succeeds and out_of_memory() remains no-op unless that PF_WQ_WORKER
>> thread is doing __GFP_FS allocation.
> 
> I have really hard time to parse and understand this.

You can write as you like.

> 
>> Tetsuo is observing that GFP_NOIO
>> allocation request from disk_events_workfn() is preventing other pending
>> works from starting.
> 
> What about any other allocation from !PF_WQ_WORKER context? Why those do
> not jump in?

All __GFP_FS allocations got stuck at direct reclaim or workqueue.

> 
>> Since should_reclaim_retry() should be a natural reschedule point,
>> let's do the short sleep for PF_WQ_WORKER threads unconditionally
>> in order to guarantee that other pending works are started.
> 
> OK, this is finally makes some sense. But it doesn't explain why it
> handles the live lock.

As explained above, if disk_events_workfn() (PID=5) explicitly sleeps,
vmstat_update and drain_local_pages_wq from WQ_MEM_RECLAIM workqueue will
start, and unblock PID=498 which is waiting for drain_local_pages_wq and
allow PID=498 to invoke the OOM killer.

> 
>> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Your s-o-b is missing again. I have already told you that previously
> when you were posting the patch.

I'm waiting for you to post this change with your wording.

> 
> I do not mind this change per se but I am not happy about _your_ changelog.
> It doesn't explain the underlying problem IMHO. Having a natural and
> unconditional scheduling point in should_reclaim_retry is a reasonable
> thing. But how the hack it relates to the livelock you are seeing. So
> namely the changelog should explain
> 1) why nobody is able to make forward progress during direct reclaim

Because GFP_NOIO allocation from one workqueue prevented WQ_MEM_RECLAIM
workqueues from starting, for it did not call schedule_timeout_*() because
mutex_trylock(&oom_lock) did not fail because nobody else could call
__alloc_pages_may_oom().

> 2) why nobody is able to trigger oom killer as the last resort

Because only one !__GFP_FS allocating thread which did not get stuck at
direct reclaim was able to call __alloc_pages_may_oom().
