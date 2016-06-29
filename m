Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 719BB828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 13:52:09 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id fq2so118206351obb.2
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 10:52:09 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id l72si4656194ith.23.2016.06.29.10.52.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 10:52:07 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id y93so6126564ita.0
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 10:52:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160629164415.GG4650@linux.vnet.ibm.com>
References: <20160621064302.GA20635@js1304-P5Q-DELUXE> <20160621125406.GF3923@linux.vnet.ibm.com>
 <20160622005208.GB25106@js1304-P5Q-DELUXE> <CAMuHMdW-wSxASozhmPh0b+9UJFFVbYHqTqH5e9P1oO7T59YE7g@mail.gmail.com>
 <20160622190859.GA1473@linux.vnet.ibm.com> <20160623004935.GA20752@linux.vnet.ibm.com>
 <20160623023756.GA30438@js1304-P5Q-DELUXE> <20160623024742.GD1473@linux.vnet.ibm.com>
 <20160623025329.GA13095@linux.vnet.ibm.com> <CAMuHMdVqNV5ZbR3_NV5ZsLxoNQUXXGpfAcaoMJffaJbRPUb6-A@mail.gmail.com>
 <20160629164415.GG4650@linux.vnet.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 29 Jun 2016 19:52:06 +0200
Message-ID: <CAMuHMdUfQ-gBqjZGvawf5zxgb-0UnWb+fzD-kcWU+kavwvadgQ@mail.gmail.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Linux MM <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi Paul,

On Wed, Jun 29, 2016 at 6:44 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Wed, Jun 29, 2016 at 04:54:44PM +0200, Geert Uytterhoeven wrote:
>> On Thu, Jun 23, 2016 at 4:53 AM, Paul E. McKenney
>> <paulmck@linux.vnet.ibm.com> wrote:
>> > On Wed, Jun 22, 2016 at 07:47:42PM -0700, Paul E. McKenney wrote:
>
> [ . . . ]
>
>> > @@ -4720,11 +4720,18 @@ static void __init rcu_dump_rcu_node_tree(struct rcu_state *rsp)
>> >                         pr_info(" ");
>> >                         level = rnp->level;
>> >                 }
>> > -               pr_cont("%d:%d ^%d  ", rnp->grplo, rnp->grphi, rnp->grpnum);
>> > +               pr_cont("%d:%d/%#lx/%#lx ^%d  ", rnp->grplo, rnp->grphi,
>> > +                       rnp->qsmask,
>> > +                       rnp->qsmaskinit | rnp->qsmaskinitnext, rnp->grpnum);
>> >         }
>> >         pr_cont("\n");
>> >  }
>>
>> For me it always crashes during the 37th call of synchronize_sched() in
>> setup_kmem_cache_node(), which is the first call after secondary CPU bring up.
>> With your and my debug code, I get:
>>
>>   CPU: Testing write buffer coherency: ok
>>   CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
>>   Setting up static identity map for 0x40100000 - 0x40100058
>>   cnt = 36, sync
>>   CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
>>   Brought up 2 CPUs
>>   SMP: Total of 2 processors activated (2132.00 BogoMIPS).
>>   CPU: All CPU(s) started in SVC mode.
>>   rcu_node tree layout dump
>>    0:1/0x0/0x3 ^0
>
> Thank you for running this!
>
> OK, so RCU knows about both CPUs (the "0x3"), and the previous
> grace period has seen quiescent states from both of them (the "0x0").
> That would indicate that your synchronize_sched() showed up when RCU was
> idle, so it had to start a new grace period.  It also rules out failure
> modes where RCU thinks that there are more CPUs than really exist.
> (Don't laugh, such things have really happened.)
>
>>   devtmpfs: initialized
>>   VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev 1
>>   clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff,
>> max_idle_ns: 19112604462750000 ns
>>
>> I hope it helps. Thanks!
>
> I am going to guess that this was the first grace period since the second
> CPU came online.  When there only on CPU online, synchronize_sched()
> is a no-op.
>
> OK, this showed some things that aren't a problem.  What might the
> problem be?
>
> o       The grace-period kthread has not yet started.  It -should- start
>         at early_initcall() time, but who knows?  Adding code to print
>         out that kthread's task_struct address.
>
> o       The grace-period kthread might not be responding to wakeups.
>         Checking this requires that a grace period be in progress,
>         so please put a call_rcu_sched() just before the call to
>         rcu_dump_rcu_node_tree().  (Sample code below.)  Adding code
>         to my patch to print out more GP-kthread state as well.
>
> o       One of the CPUs might not be responding to RCU.  That -should-
>         result in an RCU CPU stall warning, so I will ignore this
>         possibility for the moment.
>
>         That said, do you have some way to determine whether scheduling
>         clock interrupts are really happening?  Without these interrupts,
>         no RCU CPU stall warnings.

I believe there are no clocksources yet. The jiffies clocksource is the first
clocksource found, and that happens after the first call to
synchronize_sched(), cfr. my dmesg snippet above.

In a working boot:
# cat /sys/bus/clocksource/devices/clocksource0/available_clocksource
e0180000.timer jiffies
# cat /sys/bus/clocksource/devices/clocksource0/current_clocksource
e0180000.timer

> OK, that should be enough for the next phase, please see the end for the
> patch.  This patch applies on top of my previous one.
>
> Could you please set this up as follows?
>
>         struct rcu_head rh;
>
>         rcu_dump_rcu_node_tree(&rcu_sched_state);  /* Initial state. */
>         call_rcu(&rh, do_nothing_cb);

I added an empty do_nothing_cb() for this:

    static void do_nothing_cb(struct rcu_head *rcu_head)
    {
    }

According to the debugging technique "comment everything out until it boots",
it now hangs in call_rcu().

>         schedule_timeout_uninterruptible(5 * HZ);  /* Or whatever delay. */
>         rcu_dump_rcu_node_tree(&rcu_sched_state);  /* GP state. */
>         synchronize_sched();  /* Probably hangs. */
>         rcu_barrier();  /* Drop RCU's references to rh before return. */

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
