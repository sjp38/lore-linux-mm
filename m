Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 530396B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 09:24:19 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so3477448wib.13
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 06:24:18 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id r1si11276868wjr.24.2014.06.05.06.24.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 06:24:17 -0700 (PDT)
Date: Thu, 5 Jun 2014 09:24:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [stable-3.10.y] possible unsafe locking warning
Message-ID: <20140605132400.GW2878@cmpxchg.org>
References: <5385B52A.7050106@cn.fujitsu.com>
 <20140528154856.GD1419@htj.dyndns.org>
 <539003C6.9060308@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <539003C6.9060308@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>, stable@vger.kernel.org, Cgroups <cgroups@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, tangchen <tangchen@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Hi,

[cc'ing Andrew and linux-mm for patch review and inclusion]

On Thu, Jun 05, 2014 at 01:44:38PM +0800, Gu Zheng wrote:
> Hi Tejun,
> Sorry for late replay.
> On 05/28/2014 11:48 PM, Tejun Heo wrote:
> 
> > (cc'ing Johannes for mm-foo)
> > 
> > Hello,
> > 
> > On Wed, May 28, 2014 at 06:06:34PM +0800, Gu Zheng wrote:
> >> [ 2457.683370] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-R} usage.
> >> [ 2457.761540] kswapd2/1151 [HC0[0]:SC0[0]:HE1:SE1] takes:
> >> [ 2457.824102]  (&sig->group_rwsem){+++++?}, at: [<ffffffff81071864>] exit_signals+0x24/0x130
> >> [ 2457.923538] {RECLAIM_FS-ON-W} state was registered at:
> >> [ 2457.985055]   [<ffffffff810bfc99>] mark_held_locks+0xb9/0x140
> >> [ 2458.053976]   [<ffffffff810c1e3a>] lockdep_trace_alloc+0x7a/0xe0
> >> [ 2458.126015]   [<ffffffff81194f47>] kmem_cache_alloc_trace+0x37/0x240
> >> [ 2458.202214]   [<ffffffff812c6e89>] flex_array_alloc+0x99/0x1a0
> >> [ 2458.272175]   [<ffffffff810da563>] cgroup_attach_task+0x63/0x430
> >> [ 2458.344214]   [<ffffffff810dcca0>] attach_task_by_pid+0x210/0x280
> >> [ 2458.417294]   [<ffffffff810dcd26>] cgroup_procs_write+0x16/0x20
> >> [ 2458.488287]   [<ffffffff810d8410>] cgroup_file_write+0x120/0x2c0
> >> [ 2458.560320]   [<ffffffff811b21a0>] vfs_write+0xc0/0x1f0
> >> [ 2458.622994]   [<ffffffff811b2bac>] SyS_write+0x4c/0xa0
> >> [ 2458.684618]   [<ffffffff815ec3c0>] tracesys+0xdd/0xe2
> >> [ 2458.745214] irq event stamp: 49
> >> [ 2458.782794] hardirqs last  enabled at (49): [<ffffffff815e2b56>] _raw_spin_unlock_irqrestore+0x36/0x70
> >> [ 2458.894388] hardirqs last disabled at (48): [<ffffffff815e337b>] _raw_spin_lock_irqsave+0x2b/0xa0
> >> [ 2459.000771] softirqs last  enabled at (0): [<ffffffff81059247>] copy_process.part.24+0x627/0x15f0
> >> [ 2459.107161] softirqs last disabled at (0): [<          (null)>]           (null)
> >> [ 2459.195852] 
> >> [ 2459.195852] other info that might help us debug this:
> >> [ 2459.274024]  Possible unsafe locking scenario:
> >> [ 2459.274024] 
> >> [ 2459.344911]        CPU0
> >> [ 2459.374161]        ----
> >> [ 2459.403408]   lock(&sig->group_rwsem);
> >> [ 2459.448490]   <Interrupt>
> >> [ 2459.479825]     lock(&sig->group_rwsem);
> >> [ 2459.526979] 
> >> [ 2459.526979]  *** DEADLOCK ***
> >> [ 2459.526979] 
> >> [ 2459.597866] no locks held by kswapd2/1151.
> >> [ 2459.646896] 
> >> [ 2459.646896] stack backtrace:
> >> [ 2459.699049] CPU: 30 PID: 1151 Comm: kswapd2 Not tainted 3.10.39+ #4
> >> [ 2459.774098] Hardware name: FUJITSU PRIMEQUEST2800E/SB, BIOS PRIMEQUEST 2000 Series BIOS Version 01.48 05/07/2014
> >> [ 2459.895983]  ffffffff82284bf0 ffff88085856bbf8 ffffffff815dbcf6 ffff88085856bc48
> >> [ 2459.985003]  ffffffff815d67c6 0000000000000000 ffff880800000001 ffff880800000001
> >> [ 2460.074024]  000000000000000a ffff88085edc9600 ffffffff810be0e0 0000000000000009
> >> [ 2460.163087] Call Trace:
> >> [ 2460.192345]  [<ffffffff815dbcf6>] dump_stack+0x19/0x1b
> >> [ 2460.253874]  [<ffffffff815d67c6>] print_usage_bug+0x1f7/0x208
> >> [ 2460.399807]  [<ffffffff810bfb5d>] mark_lock+0x21d/0x2a0
> >> [ 2460.462369]  [<ffffffff810c076a>] __lock_acquire+0x52a/0xb60
> >> [ 2460.735516]  [<ffffffff810c1592>] lock_acquire+0xa2/0x140
> >> [ 2460.935691]  [<ffffffff815e01e1>] down_read+0x51/0xa0
> >> [ 2461.062888]  [<ffffffff81071864>] exit_signals+0x24/0x130
> >> [ 2461.127536]  [<ffffffff81060d55>] do_exit+0xb5/0xa50
> >> [ 2461.320433]  [<ffffffff8108303b>] kthread+0xdb/0x100
> >> [ 2461.532049]  [<ffffffff815ec0ec>] ret_from_fork+0x7c/0xb0
> > 
> > The lockdep warning is about threadgroup_lock being grabbed by kswapd
> > which is depended upon during memory reclaim when the lock may be held
> > by tasks which may wait on memory reclaim.  From the backtrace, it
> > looks like the right thing to do is marking the kswapd that it's no
> > longer a memory reclaimer once before it starts exiting.

Yeah, that makes sense.  In fact, we can reset *all* the
reclaim-specific per-task states the second it stops performing
reclaim work.

> >> And when reference to the related code(kernel-3.10.y), it seems that cgroup_attach_task(thread-2,
> >> attach kswapd) trigger kswapd(reclaim memory?) when trying to alloc memory(flex_array_alloc) under
> >> the protection of sig->group_rwsem, but meanwhile the kswapd(thread-1) is in the exit routine
> >> (because it was marked SHOULD STOP when offline pages completed), which needs to acquire
> >> sig->group_rwsem in exit_signals(), so the deadlock occurs.
> >>
> >>        thread-1                           			 |            thread-2
> >>                                                                  |
> >> __offline_pages():                                               | system_call_fastpath()
> >> |-> kswapd_stop(node);                                           | |-> ......
> >>     |-> kthread_stop(kswapd)                                     | |-> cgroup_file_write()
> >>         |-> set_bit(KTHREAD_SHOULD_STOP, &kthread->flags);       | |-> ......
> >>         |-> wake_up_process(k)                                   | |-> attach_task_by_pid()
> >>             |                                                    |     |-> threadgroup_lock(tsk)
> >> |<----------|                                                    |        // Here, got the lock.
> >> |-> kswapd()                                                     |    |-> ...
> >>     |-> if (kthread_should_stop())                               |     |-> cgroup_attach_task()
> >>             return;                                              |         |-> flex_array_alloc()
> >>             |                                                    |             |-> kzalloc()
> >> |<----------|                                                    |                |-> wait for kswapd to reclaim memory
> >> |-> kthread()                                                    |
> >>     |-> do_exit(ret)                                             |
> >>         |-> exit_signals()                                       |
> >>             |-> threadgroup_change_begin(tsk)                    |
> >>                 |-> down_read(&tsk->signal->group_rwsem)         |
> >>                     // Here, acquire the lock. 
> >>
> >> If my analysis is correct, the latest kernel may have the same issue, though the flex_array was replaced
> >> by list, but we still need to alloc memory(e.g. in find_css_set()), so the race may still occur.
> >> Any comments about this? If I missed something, please correct me.:)
> > 
> > Not sure whether this can actually happen but if so the right fix
> > would be making thread-2 not wait for kswapd which is exiting and can
> > no longer serve as memory reclaimer.

There is never a direct wait for a specific kswapd thread in the
waitqueue sense.  The allocator wakes up the kswapds for all nodes
allowed in the allocation, then retries the allocation a few times in
the hope that kswapd does something before entering reclaim itself.

How far back do we need this in stable?

---
