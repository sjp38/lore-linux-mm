Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 78F316B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 09:37:00 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 2 Apr 2012 07:36:59 -0600
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 22B57C9006C
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 09:36:55 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q32Dat7k115062
	for <linux-mm@kvack.org>; Mon, 2 Apr 2012 09:36:55 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q32DaWHQ015279
	for <linux-mm@kvack.org>; Mon, 2 Apr 2012 07:36:33 -0600
Date: Mon, 2 Apr 2012 06:09:36 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: kmemleak: illegal RCU use assertion error
Message-ID: <20120402130936.GF2450@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20120402070911.GB3464@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120402070911.GB3464@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 02, 2012 at 10:09:11AM +0300, Sergey Senozhatsky wrote:
> Hello,
> 
> commit e5601400081651060a59bd1f45f2821bb8e97f95
> Author: Paul E. McKenney <paul.mckenney@linaro.org>
> Date:   Sat Jan 7 11:03:57 2012 -0800
> 
>     rcu: Simplify offline processing
>     
>     Move ->qsmaskinit and blkd_tasks[] manipulation to the CPU_DYING
>     notifier.  This simplifies the code by eliminating a potential
>     deadlock and by reducing the responsibilities of force_quiescent_state().
>     Also rename functions to make their connection to the CPU-hotplug
>     stages explicit.
>     
>     Signed-off-by: Paul E. McKenney <paul.mckenney@linaro.org>
>     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> 
> introduced WARN_ON_ONCE(cpu_is_offline(smp_processor_id())); to __call_rcu()
> function, Paul also added cpu_offline checks to other routines (e.g. callbacks)
> in later commits. It happens that kmemleak() triggers one of them.
> 
> During cpu core offline, kfree()->kmemleak_free()->put_object()-->__call_rcu() chain
> for struct intel_shared_regs * is executed when no struct users left on this core -- 
> all CPUs are dead or dying.
> 
> 
> [ 4703.342462] CPU 3 is now offline
> [ 4705.588116] ------------[ cut here ]------------
> [ 4705.588129] WARNING: at kernel/rcutree.c:1823 __call_rcu+0x9d/0x1d2()
> [..]
> [ 4705.588196] Call Trace:
> [ 4705.588207]  [<ffffffff81059a00>] ? synchronize_srcu+0x6/0x17
> [ 4705.588215]  [<ffffffff8103364e>] warn_slowpath_common+0x83/0x9c
> [ 4705.588223]  [<ffffffff8111e627>] ? get_object+0x31/0x31
> [ 4705.588229]  [<ffffffff81033681>] warn_slowpath_null+0x1a/0x1c
> [ 4705.588235]  [<ffffffff810af770>] __call_rcu+0x9d/0x1d2
> [ 4705.588243]  [<ffffffff81013f52>] ? intel_pmu_cpu_dying+0x3b/0x5d
> [ 4705.588249]  [<ffffffff810af8f1>] call_rcu_sched+0x17/0x19
> [ 4705.588255]  [<ffffffff8111eb7e>] put_object+0x47/0x4b
> [ 4705.588261]  [<ffffffff8111ed8b>] delete_object_full+0x2a/0x2e
> [ 4705.588269]  [<ffffffff81491dc8>] kmemleak_free+0x26/0x45
> [ 4705.588274]  [<ffffffff8111691f>] kfree+0x130/0x221
> [ 4705.588280]  [<ffffffff81013f52>] intel_pmu_cpu_dying+0x3b/0x5d
> [ 4705.588287]  [<ffffffff8149cb83>] x86_pmu_notifier+0xaf/0xb9
> [ 4705.588296]  [<ffffffff814b0e9d>] notifier_call_chain+0xac/0xd9
> [ 4705.588303]  [<ffffffff81059c9e>] __raw_notifier_call_chain+0xe/0x10
> [ 4705.588309]  [<ffffffff810354ec>] __cpu_notify+0x20/0x37
> [ 4705.588314]  [<ffffffff81035516>] cpu_notify+0x13/0x15
> [ 4705.588320]  [<ffffffff81490fab>] take_cpu_down+0x28/0x2e
> [ 4705.588326]  [<ffffffff8109ef7f>] stop_machine_cpu_stop+0x96/0xf1
> [ 4705.588332]  [<ffffffff8109ece3>] cpu_stopper_thread+0xe3/0x183
> [ 4705.588338]  [<ffffffff8109eee9>] ? queue_stop_cpus_work+0xd0/0xd0
> [ 4705.588344]  [<ffffffff814ad382>] ? _raw_spin_unlock_irqrestore+0x47/0x65
> [ 4705.588353]  [<ffffffff81087d0d>] ? trace_hardirqs_on_caller+0x119/0x175
> [ 4705.588358]  [<ffffffff81087d76>] ? trace_hardirqs_on+0xd/0xf
> [ 4705.588364]  [<ffffffff8109ec00>] ? cpu_stop_signal_done+0x2c/0x2c
> [ 4705.588370]  [<ffffffff810544a9>] kthread+0x8b/0x93
> [ 4705.588378]  [<ffffffff814b5f34>] kernel_thread_helper+0x4/0x10
> [ 4705.588385]  [<ffffffff814ad7f0>] ? retint_restore_args+0x13/0x13
> [ 4705.588391]  [<ffffffff8105441e>] ? __init_kthread_worker+0x5a/0x5a
> [ 4705.588397]  [<ffffffff814b5f30>] ? gs_change+0x13/0x13
> [ 4705.588400] ---[ end trace 720328982e35a713 ]---
> [ 4705.588507] CPU 2 is now offline
> 
> 
> My first solution was to return from delete_object() if object deallocation
> performed on cpu_is_offline(smp_processor_id()), marking object with special
> flag, say OBJECT_ORPHAN. And issue real object_delete() during scan (for example)
> when we see OBJECT_ORPHAN object.  
> That, however, requires to handle special case when cpu core offlined
> for small period of time, leading to object insertion error in
> create_object(), which either may be handled in 2 possible ways (assuming
> that lookup_object() returned OBJECT_ORPHAN):
> #1 delete orphaned object and retry with insertion (*)
> #2 re-set existing orphan object
> 
> 
> (*) performing delete_object() from within create_object() requires releasing
> of held kmemleak and object locks, which is racy with other create_object() and
> any possible scan() activities.
> 
> Yet I'm not exactly sure that option #2 is the correct one.
> (I've kind of a patch [not properly tested, etc.] for #2 option).

Alternatively, I can make RCU tolerate __call_rcu() from late in the
CPU_DYING notifiers without too much trouble.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
