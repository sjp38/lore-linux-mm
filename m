Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 94699280251
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 01:22:52 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 92so85922012iom.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 22:22:52 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e90si7971513ioi.226.2016.09.27.22.22.51
        for <linux-mm@kvack.org>;
        Tue, 27 Sep 2016 22:22:51 -0700 (PDT)
Date: Wed, 28 Sep 2016 14:31:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Soft lockup in __slab_free (SLUB)
Message-ID: <20160928053114.GC22706@js1304-P5Q-DELUXE>
References: <57E8D270.8040802@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E8D270.8040802@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Christoph Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, brouer@redhat.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Hello,

Ccing Paul, because it looks like RCU problem.

On Mon, Sep 26, 2016 at 10:46:56AM +0300, Nikolay Borisov wrote:
> Hello, 
> 
> On 4.4.14 stable kernel I observed the following soft-lockup, however I
> also checked that the code is the same in 4.8-rc so the problem is 
> present there as well: 
> 
> [434575.862377] NMI watchdog: BUG: soft lockup - CPU#13 stuck for 23s! [swapper/13:0]
> [434575.866352] CPU: 13 PID: 0 Comm: swapper/13 Tainted: P           O    4.4.14-clouder5 #2
> [434575.866643] Hardware name: Supermicro X9DRD-iF/LF/X9DRD-iF, BIOS 3.0b 12/05/2013
> [434575.866932] task: ffff8803714aadc0 ti: ffff8803714c4000 task.ti: ffff8803714c4000
> [434575.867221] RIP: 0010:[<ffffffff81613f4c>]  [<ffffffff81613f4c>] _raw_spin_unlock_irqrestore+0x1c/0x30
> [434575.867566] RSP: 0018:ffff880373ce3dc0  EFLAGS: 00000203
> [434575.867736] RAX: ffff88066e0c9a40 RBX: 0000000000000203 RCX: 0000000000000000
> [434575.868023] RDX: 0000000000000008 RSI: 0000000000000203 RDI: ffff88066e0c9a40
> [434575.868311] RBP: ffff880373ce3dc8 R08: ffff8803e5c1d118 R09: ffff8803e5c1d538
> [434575.868609] R10: 0000000000000000 R11: ffffea000f970600 R12: ffff88066e0c9a40
> [434575.868895] R13: ffffea000f970600 R14: 000000000046cf3b R15: ffff88036f8e3200
> [434575.869183] FS:  0000000000000000(0000) GS:ffff880373ce0000(0000) knlGS:0000000000000000
> [434575.869472] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [434575.869643] CR2: ffffffffff600400 CR3: 0000000367201000 CR4: 00000000001406e0
> [434575.869931] Stack:
> [434575.870095]  ffff88066e0c9a40 ffff880373ce3e78 ffffffff8117ea8a ffff880373ce3e08
> [434575.870567]  000000000046bd03 0000000100170017 ffff8803e5c1d118 ffff8803e5c1d118
> [434575.871037]  00ff000100000000 0000000000000203 0000000000000000 ffffffff8123d9ac
> [434575.874253] Call Trace:
> [434575.874418]  <IRQ> 
> [434575.874473]  [<ffffffff8117ea8a>] __slab_free+0xca/0x290
> [434575.874806]  [<ffffffff8123d9ac>] ? ext4_i_callback+0x1c/0x20
> [434575.874978]  [<ffffffff8117ee3a>] kmem_cache_free+0x1ea/0x200
> [434575.875149]  [<ffffffff8123d9ac>] ext4_i_callback+0x1c/0x20
> [434575.875325]  [<ffffffff810ad09b>] rcu_process_callbacks+0x21b/0x620
> [434575.875506]  [<ffffffff81057337>] __do_softirq+0x147/0x310
> [434575.875680]  [<ffffffff8105764f>] irq_exit+0x5f/0x70
> [434575.875851]  [<ffffffff81616a82>] smp_apic_timer_interrupt+0x42/0x50
> [434575.876025]  [<ffffffff816151e9>] apic_timer_interrupt+0x89/0x90
> [434575.876197]  <EOI> 
> [434575.876250]  [<ffffffff81510601>] ? cpuidle_enter_state+0x141/0x2c0
> [434575.876583]  [<ffffffff815105f6>] ? cpuidle_enter_state+0x136/0x2c0
> [434575.876755]  [<ffffffff815107b7>] cpuidle_enter+0x17/0x20
> [434575.876929]  [<ffffffff810949fc>] cpu_startup_entry+0x2fc/0x360
> [434575.877105]  [<ffffffff810330e3>] start_secondary+0xf3/0x100
> 
> The ip in __slab_free points to this piece of code (in mm/slub.c): 
> 
> if (unlikely(n)) {
> 	spin_unlock_irqrestore(&n->list_lock, flags);
>         n = NULL;
> }
> 
> I think it's a pure chance that the spin_unlock_restore is being shown in this trace, 
> do you think that a cond_resched is needed in this unlikely if clause? Apparently there 
> are cases where this loop can take a considerable amount of time.

I think that __slab_free() doesn't take too long time even if there is
lock contention. And, cond_resched() is valid on softirq context?

I think that problem would be caused by too many rcu callback is
executed without scheduling. Paul?

Thanks.

> 
> How about this patch: 
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 65d5f92d51d2..daa20f38770a 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2654,6 +2654,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>                 if (unlikely(n)) {
>                         spin_unlock_irqrestore(&n->list_lock, flags);
>                         n = NULL;
> +                       cond_resched();
>                 }
>                 prior = page->freelist;
>                 counters = page->counters;
> 
> Regards,
> Nikolay 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
