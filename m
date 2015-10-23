Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id EF5AB6B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 10:50:48 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so17895632igb.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 07:50:48 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id j135si16042191ioj.178.2015.10.23.07.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 07:50:48 -0700 (PDT)
Received: by pagq8 with SMTP id q8so11821972pag.2
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 07:50:48 -0700 (PDT)
Date: Fri, 23 Oct 2015 23:49:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: Make vmstat deferrable again (was Re: [PATCH] mm,vmscan: Use
 accurate values for zone_reclaimable() checks)
Message-ID: <20151023144928.GA455@swordfish>
References: <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022150623.GE26854@dhcp22.suse.cz>
 <20151022151528.GG30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510221031090.24250@east.gentwo.org>
 <20151023083719.GD2410@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510230642210.5612@east.gentwo.org>
 <20151023120728.GA462@swordfish>
 <alpine.DEB.2.20.1510230910370.12801@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1510230910370.12801@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On (10/23/15 09:12), Christoph Lameter wrote:
[..]
> > > +		if (!cpumask_test_and_set_cpu(smp_processor_id(), cpu_stat_off))
> > > +			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
> >
> > shouldn't preemption be disable for smp_processor_id() here?
> 
> Preemption is disabled when quiet_vmstat() is called.
> 

cond_resched()

[   29.607725] BUG: sleeping function called from invalid context at mm/vmstat.c:487
[   29.607729] in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/7
[   29.607731] no locks held by swapper/7/0.
[   29.607732] irq event stamp: 48932
[   29.607733] hardirqs last  enabled at (48931): [<ffffffff813b246a>] _raw_spin_unlock_irq+0x2c/0x37
[   29.607739] hardirqs last disabled at (48932): [<ffffffff810a3fec>] tick_nohz_idle_enter+0x3c/0x5f
[   29.607743] softirqs last  enabled at (48924): [<ffffffff81041fd8>] __do_softirq+0x2bb/0x3a9
[   29.607747] softirqs last disabled at (48893): [<ffffffff810422a7>] irq_exit+0x41/0x95
[   29.607752] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 4.3.0-rc6-next-20151022-dbg-00003-g01184ff-dirty #261
[   29.607754]  0000000000000000 ffff88041dae7da0 ffffffff811dd4f3 ffff88041dacd100
[   29.607756]  ffff88041dae7dc8 ffffffff8105f144 ffffffff8169f800 0000000000000000
[   29.607759]  0000000000000007 ffff88041dae7e70 ffffffff811040b1 0000000000000002
[   29.607761] Call Trace:
[   29.607767]  [<ffffffff811dd4f3>] dump_stack+0x4b/0x63
[   29.607770]  [<ffffffff8105f144>] ___might_sleep+0x1e7/0x1ee
[   29.607773]  [<ffffffff811040b1>] refresh_cpu_vm_stats+0x8b/0xb5
[   29.607776]  [<ffffffff81104f4c>] quiet_vmstat+0x3a/0x41
[   29.607778]  [<ffffffff810a3ccf>] __tick_nohz_idle_enter+0x292/0x410
[   29.607781]  [<ffffffff810a4007>] tick_nohz_idle_enter+0x57/0x5f
[   29.607784]  [<ffffffff81076d8b>] cpu_startup_entry+0x36/0x330
[   29.607788]  [<ffffffff81028821>] start_secondary+0xf3/0xf6



by the way, tick_nohz_stop_sched_tick() receives cpu from __tick_nohz_idle_enter().
do you want to pass it to quiet_vmstat()?

	if (!ts->tick_stopped) {
		nohz_balance_enter_idle(cpu);
-		quiet_vmstat();
+		quiet_vmstat(cpu);
		calc_load_enter_idle();

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
