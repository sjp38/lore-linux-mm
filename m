Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A80A16B0320
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 21:38:08 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 33so111968pll.9
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 18:38:08 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id x25si1145387pfe.264.2017.12.05.18.38.06
        for <linux-mm@kvack.org>;
        Tue, 05 Dec 2017 18:38:07 -0800 (PST)
Date: Wed, 6 Dec 2017 13:38:03 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 00/73] XArray version 4
Message-ID: <20171206023803.GD4094@dastard>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206014536.GA4094@dastard>
 <20171206020515.GL26021@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206020515.GL26021@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 05, 2017 at 06:05:15PM -0800, Matthew Wilcox wrote:
> On Wed, Dec 06, 2017 at 12:45:49PM +1100, Dave Chinner wrote:
> > On Tue, Dec 05, 2017 at 04:40:46PM -0800, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > I looked through some notes and decided this was version 4 of the XArray.
> > > Last posted two weeks ago, this version includes a *lot* of changes.
> > > I'd like to thank Dave Chinner for his feedback, encouragement and
> > > distracting ideas for improvement, which I'll get to once this is merged.
> > 
> > BTW, you need to fix the "To:" line on your patchbombs:
> > 
> > > To: unlisted-recipients: ;, no To-header on input <@gmail-pop.l.google.com> 
> > 
> > This bad email address getting quoted to the cc line makes some MTAs
> > very unhappy.
> 
> I know :-(  I was unhappy when I realised what I'd done.
> 
> https://marc.info/?l=git&m=151252237912266&w=2
> 
> > I'll give this a quick burn this afternoon and see what catches fire...
> 
> All of the things ... 0day gave me a 90% chance of hanging in one
> configuration.  Need to drill down on it more and find out what stupid
> thing I've done wrong this time.

Yup, Bad Stuff happened on boot:

[   24.548039] INFO: rcu_preempt detected stalls on CPUs/tasks:
[   24.548978]  1-...!: (0 ticks this GP) idle=688/0/0 softirq=143/143 fqs=0
[   24.549926]  5-...!: (0 ticks this GP) idle=db8/0/0 softirq=120/120 fqs=0
[   24.550864]  6-...!: (0 ticks this GP) idle=d58/0/0 softirq=111/111 fqs=0
[   24.551802]  8-...!: (5 GPs behind) idle=514/0/0 softirq=189/189 fqs=0
[   24.552722]  10-...!: (84 GPs behind) idle=ac0/0/0 softirq=80/80 fqs=0
[   24.553617]  11-...!: (8 GPs behind) idle=cfc/0/0 softirq=95/95 fqs=0
[   24.554496]  13-...!: (8 GPs behind) idle=b0c/0/0 softirq=82/82 fqs=0
[   24.555382]  14-...!: (38 GPs behind) idle=a7c/0/0 softirq=93/93 fqs=0
[   24.556305]  15-...!: (4 GPs behind) idle=b18/0/0 softirq=88/88 fqs=0
[   24.557190]  (detected by 9, t=5252 jiffies, g=-178, c=-179, q=994)
[   24.558051] Sending NMI from CPU 9 to CPUs 1:
[   24.558703] NMI backtrace for cpu 1 skipped: idling at native_safe_halt+0x2/0x10
[   24.559654] Sending NMI from CPU 9 to CPUs 5:
[   24.559675] NMI backtrace for cpu 5 skipped: idling at native_safe_halt+0x2/0x10
[   24.560654] Sending NMI from CPU 9 to CPUs 6:
[   24.560689] NMI backtrace for cpu 6 skipped: idling at native_safe_halt+0x2/0x10
[   24.561655] Sending NMI from CPU 9 to CPUs 8:
[   24.561701] NMI backtrace for cpu 8 skipped: idling at native_safe_halt+0x2/0x10
[   24.562654] Sending NMI from CPU 9 to CPUs 10:
[   24.562675] NMI backtrace for cpu 10 skipped: idling at native_safe_halt+0x2/0x10
[   24.563653] Sending NMI from CPU 9 to CPUs 11:
[   24.563669] NMI backtrace for cpu 11 skipped: idling at native_safe_halt+0x2/0x10
[   24.564653] Sending NMI from CPU 9 to CPUs 13:
[   24.564670] NMI backtrace for cpu 13 skipped: idling at native_safe_halt+0x2/0x10
[   24.565652] Sending NMI from CPU 9 to CPUs 14:
[   24.565674] NMI backtrace for cpu 14 skipped: idling at native_safe_halt+0x2/0x10
[   24.566652] Sending NMI from CPU 9 to CPUs 15:
[   24.566669] NMI backtrace for cpu 15 skipped: idling at native_safe_halt+0x2/0x10
[   24.567653] rcu_preempt kthread starved for 5256 jiffies! g18446744073709551438 c18446744073709551437 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x402 ->7
[   24.567654] rcu_preempt     I15128     9      2 0x80000000
[   24.567660] Call Trace:
[   24.567679]  ? __schedule+0x289/0x880
[   24.567681]  schedule+0x2f/0x90
[   24.567682]  schedule_timeout+0x152/0x370
[   24.567686]  ? __next_timer_interrupt+0xc0/0xc0
[   24.567689]  rcu_gp_kthread+0x561/0x880
[   24.567691]  ? force_qs_rnp+0x1a0/0x1a0
[   24.567693]  kthread+0x111/0x130
[   24.567695]  ? __kthread_create_worker+0x120/0x120
[   24.567697]  ret_from_fork+0x24/0x30
[   44.064092] watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [kswapd0:854]
[   44.065920] CPU: 0 PID: 854 Comm: kswapd0 Not tainted 4.15.0-rc2-dgc #228
[   44.067769] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[   44.070030] RIP: 0010:smp_call_function_single+0xce/0x100
[   44.071521] RSP: 0000:ffffc90001d2fb20 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff11
[   44.073592] RAX: 0000000000000000 RBX: ffff88013ab515c8 RCX: ffffc9000350bb20
[   44.075560] RDX: 0000000000000001 RSI: ffffc90001d2fb20 RDI: ffffc90001d2fb20
[   44.077531] RBP: ffffc90001d2fb50 R08: 0000000000000007 R09: 0000000000000080
[   44.079483] R10: ffffc90001d2fb78 R11: ffffc90001d2fb30 R12: ffffc90001d2fc10
[   44.081465] R13: ffffea000449fc78 R14: ffffea000449fc58 R15: ffff88013ba36c40
[   44.083434] FS:  0000000000000000(0000) GS:ffff88013fc00000(0000) knlGS:0000000000000000
[   44.085683] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   44.087276] CR2: 00007f1ad65f2260 CR3: 0000000002009001 CR4: 00000000000606f0
[   44.089228] Call Trace:
[   44.089942]  ? flush_tlb_func_common.constprop.9+0x240/0x240
[   44.091509]  ? arch_tlbbatch_flush+0x66/0xd0
[   44.092727]  arch_tlbbatch_flush+0x66/0xd0
[   44.093882]  try_to_unmap_flush+0x26/0x40
[   44.095013]  shrink_page_list+0x3f0/0xe20
[   44.096155]  shrink_inactive_list+0x209/0x430
[   44.097392]  ? lruvec_lru_size+0x1d/0xa0
[   44.098495]  shrink_node_memcg.constprop.80+0x3f6/0x650
[   44.099952]  ? _raw_spin_unlock+0xc/0x20
[   44.101060]  ? list_lru_count_one+0x25/0x30
[   44.102225]  ? shrink_node+0x44/0x180
[   44.103252]  shrink_node+0x44/0x180
[   44.104238]  kswapd+0x270/0x6b0
[   44.105142]  ? node_reclaim+0x220/0x220
[   44.106222]  kthread+0x111/0x130
[   44.107109]  ? __kthread_create_worker+0x120/0x120
[   44.108416]  ? call_usermodehelper_exec_async+0x11c/0x150
[   44.109882]  ret_from_fork+0x24/0x30
[   44.110866] Code: 89 3a ee 7e 74 3d 48 83 c4 28 41 5a 5d 49 8d 62 f8 c3 48 89 d1 48 89 f2 48 8d 75 d0 e8 cc fc ff ff 8b 55 e8 83 e2 01 74 0a f 
[   45.596015] INFO: rcu_preempt detected stalls on CPUs/tasks:
[   45.596911]  7-...0: (1 GPs behind) idle=e56/140000000000000/0 softirq=138/139 fqs=2567 
[   45.598054]  (detected by 9, t=5252 jiffies, g=-177, c=-178, q=1001)
[   45.598925] Sending NMI from CPU 9 to CPUs 7:

-Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
