Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 20A0A8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 05:26:33 -0500 (EST)
Date: Mon, 15 Nov 2010 10:26:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] set_pgdat_percpu_threshold() don't use
	for_each_online_cpu
Message-ID: <20101115102617.GK27362@csn.ul.ie>
References: <1288169256-7174-2-git-send-email-mel@csn.ul.ie> <20101028100920.5d4ce413.kamezawa.hiroyu@jp.fujitsu.com> <20101114163727.BEE0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101114163727.BEE0.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 14, 2010 at 05:53:03PM +0900, KOSAKI Motohiro wrote:
> > > @@ -159,6 +165,44 @@ static void refresh_zone_stat_thresholds(void)
> > >  	}
> > >  }
> > >  
> > > +void reduce_pgdat_percpu_threshold(pg_data_t *pgdat)
> > > +{
> > > +	struct zone *zone;
> > > +	int cpu;
> > > +	int threshold;
> > > +	int i;
> > > +
> > 
> > get_online_cpus();
> 
> 
> This caused following runtime warnings. but I don't think here is
> real lock inversion. 
> 
> =================================
> [ INFO: inconsistent lock state ]
> 2.6.37-rc1-mm1+ #150
> ---------------------------------
> inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
> kswapd0/419 [HC0[0]:SC0[0]:HE1:SE1] takes:
>  (cpu_hotplug.lock){+.+.?.}, at: [<ffffffff810520d1>] get_online_cpus+0x41/0x60
> {RECLAIM_FS-ON-W} state was registered at:
>   [<ffffffff8108a1a3>] mark_held_locks+0x73/0xa0
>   [<ffffffff8108a296>] lockdep_trace_alloc+0xc6/0x100
>   [<ffffffff8113fba9>] kmem_cache_alloc+0x39/0x2b0
>   [<ffffffff812eea10>] idr_pre_get+0x60/0x90
>   [<ffffffff812ef5b7>] ida_pre_get+0x27/0xf0
>   [<ffffffff8106ebf5>] create_worker+0x55/0x190
>   [<ffffffff814fb4f4>] workqueue_cpu_callback+0xbc/0x235
>   [<ffffffff8151934c>] notifier_call_chain+0x8c/0xe0
>   [<ffffffff8107a34e>] __raw_notifier_call_chain+0xe/0x10
>   [<ffffffff81051f30>] __cpu_notify+0x20/0x40
>   [<ffffffff8150bff7>] _cpu_up+0x73/0x113
>   [<ffffffff8150c175>] cpu_up+0xde/0xf1
>   [<ffffffff81dcc81d>] kernel_init+0x21b/0x342
>   [<ffffffff81003724>] kernel_thread_helper+0x4/0x10
> irq event stamp: 27
> hardirqs last  enabled at (27): [<ffffffff815152c0>] _raw_spin_unlock_irqrestore+0x40/0x80
> hardirqs last disabled at (26): [<ffffffff81514982>] _raw_spin_lock_irqsave+0x32/0xa0
> softirqs last  enabled at (20): [<ffffffff810614c4>] del_timer_sync+0x54/0xa0
> softirqs last disabled at (18): [<ffffffff8106148c>] del_timer_sync+0x1c/0xa0
> 
> other info that might help us debug this:
> no locks held by kswapd0/419.
> 
> stack backtrace:
> Pid: 419, comm: kswapd0 Not tainted 2.6.37-rc1-mm1+ #150
> Call Trace:
>  [<ffffffff810890b1>] print_usage_bug+0x171/0x180
>  [<ffffffff8108a057>] mark_lock+0x377/0x450
>  [<ffffffff8108ab67>] __lock_acquire+0x267/0x15e0
>  [<ffffffff8107af0f>] ? local_clock+0x6f/0x80
>  [<ffffffff81086789>] ? trace_hardirqs_off_caller+0x29/0x150
>  [<ffffffff8108bf94>] lock_acquire+0xb4/0x150
>  [<ffffffff810520d1>] ? get_online_cpus+0x41/0x60
>  [<ffffffff81512cf4>] __mutex_lock_common+0x44/0x3f0
>  [<ffffffff810520d1>] ? get_online_cpus+0x41/0x60
>  [<ffffffff810744f0>] ? prepare_to_wait+0x60/0x90
>  [<ffffffff81086789>] ? trace_hardirqs_off_caller+0x29/0x150
>  [<ffffffff810520d1>] ? get_online_cpus+0x41/0x60
>  [<ffffffff810868bd>] ? trace_hardirqs_off+0xd/0x10
>  [<ffffffff8107af0f>] ? local_clock+0x6f/0x80
>  [<ffffffff815131a8>] mutex_lock_nested+0x48/0x60
>  [<ffffffff810520d1>] get_online_cpus+0x41/0x60
>  [<ffffffff811138b2>] set_pgdat_percpu_threshold+0x22/0xe0
>  [<ffffffff81113970>] ? calculate_normal_threshold+0x0/0x60
>  [<ffffffff8110b552>] kswapd+0x1f2/0x360
>  [<ffffffff81074180>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff8110b360>] ? kswapd+0x0/0x360
>  [<ffffffff81073ae6>] kthread+0xa6/0xb0
>  [<ffffffff81003724>] kernel_thread_helper+0x4/0x10
>  [<ffffffff81515710>] ? restore_args+0x0/0x30
>  [<ffffffff81073a40>] ? kthread+0x0/0xb0
>  [<ffffffff81003720>] ? kernel_thread_helper+0x0/0x10
> 
> 
> I think we have two option 1) call lockdep_clear_current_reclaim_state()
> every time 2) use for_each_possible_cpu instead for_each_online_cpu.
> 
> Following patch use (2) beucase removing get_online_cpus() makes good
> side effect. It reduce potentially cpu-hotplug vs memory-shortage deadlock
> risk. 
> 

With recent per-cpu allocator changes, are we guaranteed that the per-cpu
structures exist and are valid?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
