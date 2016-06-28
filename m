Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C200D6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 04:46:04 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 13so25844637itl.0
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 01:46:04 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f124si509401ite.2.2016.06.28.01.46.03
        for <linux-mm@kvack.org>;
        Tue, 28 Jun 2016 01:46:04 -0700 (PDT)
Date: Tue, 28 Jun 2016 17:33:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Message-ID: <20160628083357.GE19731@js1304-P5Q-DELUXE>
References: <20160621064302.GA20635@js1304-P5Q-DELUXE>
 <20160621125406.GF3923@linux.vnet.ibm.com>
 <20160622005208.GB25106@js1304-P5Q-DELUXE>
 <CAMuHMdW-wSxASozhmPh0b+9UJFFVbYHqTqH5e9P1oO7T59YE7g@mail.gmail.com>
 <20160622190859.GA1473@linux.vnet.ibm.com>
 <20160623004935.GA20752@linux.vnet.ibm.com>
 <20160623023756.GA30438@js1304-P5Q-DELUXE>
 <20160623024742.GD1473@linux.vnet.ibm.com>
 <20160623025329.GA13095@linux.vnet.ibm.com>
 <20160628001243.GA20638@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160628001243.GA20638@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-renesas-soc@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Mon, Jun 27, 2016 at 05:12:43PM -0700, Paul E. McKenney wrote:
> On Wed, Jun 22, 2016 at 07:53:29PM -0700, Paul E. McKenney wrote:
> > On Wed, Jun 22, 2016 at 07:47:42PM -0700, Paul E. McKenney wrote:
> > > On Thu, Jun 23, 2016 at 11:37:56AM +0900, Joonsoo Kim wrote:
> > > > On Wed, Jun 22, 2016 at 05:49:35PM -0700, Paul E. McKenney wrote:
> > > > > On Wed, Jun 22, 2016 at 12:08:59PM -0700, Paul E. McKenney wrote:
> > > > > > On Wed, Jun 22, 2016 at 05:01:35PM +0200, Geert Uytterhoeven wrote:
> > > > > > > On Wed, Jun 22, 2016 at 2:52 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > > > > > > Could you try below patch to check who causes the hang?
> > > > > > > >
> > > > > > > > And, if sysalt-t works when hang, could you get sysalt-t output? I haven't
> > > > > > > > used it before but Paul could find some culprit on it. :)
> > > > > > > >
> > > > > > > > Thanks.
> > > > > > > >
> > > > > > > >
> > > > > > > > ----->8-----
> > > > > > > > diff --git a/mm/slab.c b/mm/slab.c
> > > > > > > > index 763096a..9652d38 100644
> > > > > > > > --- a/mm/slab.c
> > > > > > > > +++ b/mm/slab.c
> > > > > > > > @@ -964,8 +964,13 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
> > > > > > > >          * guaranteed to be valid until irq is re-enabled, because it will be
> > > > > > > >          * freed after synchronize_sched().
> > > > > > > >          */
> > > > > > > > -       if (force_change)
> > > > > > > > +       if (force_change) {
> > > > > > > > +               if (num_online_cpus() > 1)
> > > > > > > > +                       dump_stack();
> > > > > > > >                 synchronize_sched();
> > > > > > > > +               if (num_online_cpus() > 1)
> > > > > > > > +                       dump_stack();
> > > > > > > > +       }
> > > > > > > 
> > > > > > > I've only added the first one, as I would never see the second one. All of
> > > > > > > this happens before the serial console is activated, earlycon is not supported,
> > > > > > > and I only have remote access.
> > > > > > > 
> > > > > > > Brought up 2 CPUs
> > > > > > > SMP: Total of 2 processors activated (2132.00 BogoMIPS).
> > > > > > > CPU: All CPU(s) started in SVC mode.
> > > > > > > CPU: 0 PID: 1 Comm: swapper/0 Not tainted
> > > > > > > 4.7.0-rc4-kzm9d-00404-g4a235e6dde4404dd-dirty #89
> > > > > > > Hardware name: Generic Emma Mobile EV2 (Flattened Device Tree)
> > > > > > > [<c010de68>] (unwind_backtrace) from [<c010a658>] (show_stack+0x10/0x14)
> > > > > > > [<c010a658>] (show_stack) from [<c02b5cf8>] (dump_stack+0x7c/0x9c)
> > > > > > > [<c02b5cf8>] (dump_stack) from [<c01cfa4c>] (setup_kmem_cache_node+0x140/0x170)
> > > > > > > [<c01cfa4c>] (setup_kmem_cache_node) from [<c01cfe3c>]
> > > > > > > (__do_tune_cpucache+0xf4/0x114)
> > > > > > > [<c01cfe3c>] (__do_tune_cpucache) from [<c01cff54>] (enable_cpucache+0xf8/0x148)
> > > > > > > [<c01cff54>] (enable_cpucache) from [<c01d0190>]
> > > > > > > (__kmem_cache_create+0x1a8/0x1d0)
> > > > > > > [<c01d0190>] (__kmem_cache_create) from [<c01b32d0>]
> > > > > > > (kmem_cache_create+0xbc/0x190)
> > > > > > > [<c01b32d0>] (kmem_cache_create) from [<c070d968>] (shmem_init+0x34/0xb0)
> > > > > > > [<c070d968>] (shmem_init) from [<c0700cc8>] (kernel_init_freeable+0x98/0x1ec)
> > > > > > > [<c0700cc8>] (kernel_init_freeable) from [<c049fdbc>] (kernel_init+0x8/0x110)
> > > > > > > [<c049fdbc>] (kernel_init) from [<c0106cb8>] (ret_from_fork+0x14/0x3c)
> > > > > > > devtmpfs: initialized
> > > > > > 
> > > > > > I don't see anything here that would prevent grace periods from completing.
> > > > > > 
> > > > > > The CPUs are using the normal hotplug sequence to come online, correct?
> > > > > 
> > > > > And either way, could you please apply the patch below and then
> > > > > invoke rcu_dump_rcu_sched_tree() just before the offending call to
> > > > > synchronize_sched()?  That will tell me what CPUs RCU believes exist,
> > > > > and perhaps also which CPU is holding it up.
> > > > 
> > > > I can't find rcu_dump_rcu_sched_tree(). Do you mean
> > > > rcu_dump_rcu_node_tree()? Anyway, there is no patch below so I attach
> > > > one which does what Paul want, maybe.
> > > 
> > > One of those days, I guess!  :-/
> > > 
> > > Your patch is exactly what I intended to send, thank you!
> > 
> > Ah, but your telepathy was not sufficient to intuit the additional
> > information I need.  Please see the patch at the end.  Your hunk
> > in mm/slab.c is needed on top of my patch.
> > 
> > So I am clearly having difficulties reading as well as including patches
> > today...
> 
> Just following up, any news using my diagnostic patch?

Hello, Paul.

Unfortunately, I have no hardware to re-generate it, so we need to wait Geert's
feedback.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
