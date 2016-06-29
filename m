Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA27E828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 10:54:46 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id o10so26194939obp.3
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 07:54:46 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id 133si1522723itg.114.2016.06.29.07.54.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 07:54:46 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id 100so5521411ioh.1
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 07:54:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160623025329.GA13095@linux.vnet.ibm.com>
References: <20160620063942.GA13747@js1304-P5Q-DELUXE> <20160620131254.GO3923@linux.vnet.ibm.com>
 <20160621064302.GA20635@js1304-P5Q-DELUXE> <20160621125406.GF3923@linux.vnet.ibm.com>
 <20160622005208.GB25106@js1304-P5Q-DELUXE> <CAMuHMdW-wSxASozhmPh0b+9UJFFVbYHqTqH5e9P1oO7T59YE7g@mail.gmail.com>
 <20160622190859.GA1473@linux.vnet.ibm.com> <20160623004935.GA20752@linux.vnet.ibm.com>
 <20160623023756.GA30438@js1304-P5Q-DELUXE> <20160623024742.GD1473@linux.vnet.ibm.com>
 <20160623025329.GA13095@linux.vnet.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 29 Jun 2016 16:54:44 +0200
Message-ID: <CAMuHMdVqNV5ZbR3_NV5ZsLxoNQUXXGpfAcaoMJffaJbRPUb6-A@mail.gmail.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi Paul,

On Thu, Jun 23, 2016 at 4:53 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Wed, Jun 22, 2016 at 07:47:42PM -0700, Paul E. McKenney wrote:
>> On Thu, Jun 23, 2016 at 11:37:56AM +0900, Joonsoo Kim wrote:
>> > On Wed, Jun 22, 2016 at 05:49:35PM -0700, Paul E. McKenney wrote:
>> > > On Wed, Jun 22, 2016 at 12:08:59PM -0700, Paul E. McKenney wrote:
>> > > > On Wed, Jun 22, 2016 at 05:01:35PM +0200, Geert Uytterhoeven wrote:
>> > > > > On Wed, Jun 22, 2016 at 2:52 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>> > > > > > Could you try below patch to check who causes the hang?
>> > > > > >
>> > > > > > And, if sysalt-t works when hang, could you get sysalt-t output? I haven't
>> > > > > > used it before but Paul could find some culprit on it. :)
>> > > > > >
>> > > > > > Thanks.
>> > > > > >
>> > > > > >
>> > > > > > ----->8-----
>> > > > > > diff --git a/mm/slab.c b/mm/slab.c
>> > > > > > index 763096a..9652d38 100644
>> > > > > > --- a/mm/slab.c
>> > > > > > +++ b/mm/slab.c
>> > > > > > @@ -964,8 +964,13 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
>> > > > > >          * guaranteed to be valid until irq is re-enabled, because it will be
>> > > > > >          * freed after synchronize_sched().
>> > > > > >          */
>> > > > > > -       if (force_change)
>> > > > > > +       if (force_change) {
>> > > > > > +               if (num_online_cpus() > 1)
>> > > > > > +                       dump_stack();
>> > > > > >                 synchronize_sched();
>> > > > > > +               if (num_online_cpus() > 1)
>> > > > > > +                       dump_stack();
>> > > > > > +       }
>> > > > >
>> > > > > I've only added the first one, as I would never see the second one. All of
>> > > > > this happens before the serial console is activated, earlycon is not supported,
>> > > > > and I only have remote access.
>> > > > >
>> > > > > Brought up 2 CPUs
>> > > > > SMP: Total of 2 processors activated (2132.00 BogoMIPS).
>> > > > > CPU: All CPU(s) started in SVC mode.
>> > > > > CPU: 0 PID: 1 Comm: swapper/0 Not tainted
>> > > > > 4.7.0-rc4-kzm9d-00404-g4a235e6dde4404dd-dirty #89
>> > > > > Hardware name: Generic Emma Mobile EV2 (Flattened Device Tree)
>> > > > > [<c010de68>] (unwind_backtrace) from [<c010a658>] (show_stack+0x10/0x14)
>> > > > > [<c010a658>] (show_stack) from [<c02b5cf8>] (dump_stack+0x7c/0x9c)
>> > > > > [<c02b5cf8>] (dump_stack) from [<c01cfa4c>] (setup_kmem_cache_node+0x140/0x170)
>> > > > > [<c01cfa4c>] (setup_kmem_cache_node) from [<c01cfe3c>]
>> > > > > (__do_tune_cpucache+0xf4/0x114)
>> > > > > [<c01cfe3c>] (__do_tune_cpucache) from [<c01cff54>] (enable_cpucache+0xf8/0x148)
>> > > > > [<c01cff54>] (enable_cpucache) from [<c01d0190>]
>> > > > > (__kmem_cache_create+0x1a8/0x1d0)
>> > > > > [<c01d0190>] (__kmem_cache_create) from [<c01b32d0>]
>> > > > > (kmem_cache_create+0xbc/0x190)
>> > > > > [<c01b32d0>] (kmem_cache_create) from [<c070d968>] (shmem_init+0x34/0xb0)
>> > > > > [<c070d968>] (shmem_init) from [<c0700cc8>] (kernel_init_freeable+0x98/0x1ec)
>> > > > > [<c0700cc8>] (kernel_init_freeable) from [<c049fdbc>] (kernel_init+0x8/0x110)
>> > > > > [<c049fdbc>] (kernel_init) from [<c0106cb8>] (ret_from_fork+0x14/0x3c)
>> > > > > devtmpfs: initialized
>> > > >
>> > > > I don't see anything here that would prevent grace periods from completing.
>> > > >
>> > > > The CPUs are using the normal hotplug sequence to come online, correct?
>> > >
>> > > And either way, could you please apply the patch below and then
>> > > invoke rcu_dump_rcu_sched_tree() just before the offending call to
>> > > synchronize_sched()?  That will tell me what CPUs RCU believes exist,
>> > > and perhaps also which CPU is holding it up.
>> >
>> > I can't find rcu_dump_rcu_sched_tree(). Do you mean
>> > rcu_dump_rcu_node_tree()? Anyway, there is no patch below so I attach
>> > one which does what Paul want, maybe.
>>
>> One of those days, I guess!  :-/
>>
>> Your patch is exactly what I intended to send, thank you!
>
> Ah, but your telepathy was not sufficient to intuit the additional
> information I need.  Please see the patch at the end.  Your hunk
> in mm/slab.c is needed on top of my patch.

> @@ -4720,11 +4720,18 @@ static void __init rcu_dump_rcu_node_tree(struct rcu_state *rsp)
>                         pr_info(" ");
>                         level = rnp->level;
>                 }
> -               pr_cont("%d:%d ^%d  ", rnp->grplo, rnp->grphi, rnp->grpnum);
> +               pr_cont("%d:%d/%#lx/%#lx ^%d  ", rnp->grplo, rnp->grphi,
> +                       rnp->qsmask,
> +                       rnp->qsmaskinit | rnp->qsmaskinitnext, rnp->grpnum);
>         }
>         pr_cont("\n");
>  }

For me it always crashes during the 37th call of synchronize_sched() in
setup_kmem_cache_node(), which is the first call after secondary CPU bring up.
With your and my debug code, I get:

  CPU: Testing write buffer coherency: ok
  CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
  Setting up static identity map for 0x40100000 - 0x40100058
  cnt = 36, sync
  CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
  Brought up 2 CPUs
  SMP: Total of 2 processors activated (2132.00 BogoMIPS).
  CPU: All CPU(s) started in SVC mode.
  rcu_node tree layout dump
   0:1/0x0/0x3 ^0
  devtmpfs: initialized
  VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev 1
  clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff,
max_idle_ns: 19112604462750000 ns

I hope it helps. Thanks!

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
