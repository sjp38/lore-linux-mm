Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE2C76B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 20:49:41 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id d132so271011oig.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 17:49:41 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k16si7854787itk.0.2016.06.21.17.49.40
        for <linux-mm@kvack.org>;
        Tue, 21 Jun 2016 17:49:40 -0700 (PDT)
Date: Wed, 22 Jun 2016 09:52:08 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Message-ID: <20160622005208.GB25106@js1304-P5Q-DELUXE>
References: <20160614062456.GB13753@js1304-P5Q-DELUXE>
 <CAMuHMdWipquaVFKYLd=2KhTx6djwH7NXpzL-RjtikCE=G8KTbA@mail.gmail.com>
 <20160614081125.GA17700@js1304-P5Q-DELUXE>
 <CAMuHMdXc=XN4z96vr_FNcUzFb0203ovHgcfD95Q5LPebr1z0ZQ@mail.gmail.com>
 <20160615022325.GA19863@js1304-P5Q-DELUXE>
 <CAMuHMdVi-F0n-GjnUqEEd58UcWxw67g8ZJO838fvo31Ttr5E1g@mail.gmail.com>
 <20160620063942.GA13747@js1304-P5Q-DELUXE>
 <20160620131254.GO3923@linux.vnet.ibm.com>
 <20160621064302.GA20635@js1304-P5Q-DELUXE>
 <20160621125406.GF3923@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160621125406.GF3923@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-renesas-soc@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Jun 21, 2016 at 05:54:06AM -0700, Paul E. McKenney wrote:
> On Tue, Jun 21, 2016 at 03:43:02PM +0900, Joonsoo Kim wrote:
> > On Mon, Jun 20, 2016 at 06:12:54AM -0700, Paul E. McKenney wrote:
> > > On Mon, Jun 20, 2016 at 03:39:43PM +0900, Joonsoo Kim wrote:
> > > > CCing Paul to ask some question.
> > > > 
> > > > On Wed, Jun 15, 2016 at 10:39:47AM +0200, Geert Uytterhoeven wrote:
> > > > > Hi Joonsoo,
> > > > > 
> > > > > On Wed, Jun 15, 2016 at 4:23 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > > > > On Tue, Jun 14, 2016 at 12:45:14PM +0200, Geert Uytterhoeven wrote:
> > > > > >> On Tue, Jun 14, 2016 at 10:11 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > > > >> > On Tue, Jun 14, 2016 at 09:31:23AM +0200, Geert Uytterhoeven wrote:
> > > > > >> >> On Tue, Jun 14, 2016 at 8:24 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > > > >> >> > On Mon, Jun 13, 2016 at 09:43:13PM +0200, Geert Uytterhoeven wrote:
> > > > > >> >> >> On Tue, Apr 12, 2016 at 6:51 AM,  <js1304@gmail.com> wrote:
> > > > > >> >> >> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > > > >> >> >> > To check whther free objects exist or not precisely, we need to grab a
> > > > > >> >> >> > lock.  But, accuracy isn't that important because race window would be
> > > > > >> >> >> > even small and if there is too much free object, cache reaper would reap
> > > > > >> >> >> > it.  So, this patch makes the check for free object exisistence not to
> > > > > >> >> >> > hold a lock.  This will reduce lock contention in heavily allocation case.
> > > > > 
> > > > > >> >> >> I've bisected a boot failure (no output at all) in v4.7-rc2 on emev2/kzm9d
> > > > > >> >> >> (Renesas dual Cortex A9) to this patch, which is upstream commit
> > > > > >> >> >> 801faf0db8947e01877920e848a4d338dd7a99e7.
> > > > > 
> > > > > > It's curious that synchronize_sched() has some effect in this early
> > > > > > phase. In synchronize_sched(), rcu_blocking_is_gp() is called and
> > > > > > it checks num_online_cpus <= 1. If so, synchronize_sched() does nothing.
> > > > > >
> > > > > > It would be related to might_sleep() in rcu_blocking_is_gp() but I'm not sure now.
> > > > > >
> > > > > > First, I'd like to confirm that num_online_cpus() is correct.
> > > > > > Could you try following patch and give me a dmesg?
> > > > > >
> > > > > > Thanks.
> > > > > >
> > > > > > ------->8----------
> > > > > > diff --git a/mm/slab.c b/mm/slab.c
> > > > > > index 763096a..5b7300a 100644
> > > > > > --- a/mm/slab.c
> > > > > > +++ b/mm/slab.c
> > > > > > @@ -964,8 +964,10 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
> > > > > >          * guaranteed to be valid until irq is re-enabled, because it will be
> > > > > >          * freed after synchronize_sched().
> > > > > >          */
> > > > > > -       if (force_change)
> > > > > > -               synchronize_sched();
> > > > > > +       if (force_change) {
> > > > > > +               WARN_ON_ONCE(num_online_cpus() <= 1);
> > > > > > +               WARN_ON_ONCE(num_online_cpus() > 1);
> > > > > > +       }
> > > > > 
> > > > > Full dmesg output below.
> > > > > 
> > > > > I also tested whether it's the call to synchronize_sched() before or after
> > > > > secondary CPU bringup that hangs.
> > > > > 
> > > > >         if (force_change && num_online_cpus() <= 1)
> > > > >                 synchronize_sched();
> > > > > 
> > > > > boots.
> > > > > 
> > > > >         if (force_change && num_online_cpus() > 1)
> > > > >                 synchronize_sched();
> > > > > 
> > > > > hangs.
> > > > 
> > > > Hello, Paul.
> > > > 
> > > > I changed slab.c to use synchronize_sched() for full memory barrier. First
> > > > call happens on kmem_cache_init_late() and it would not be a problem
> > > > because, at this time, num_online_cpus() <= 1 and synchronize_sched()
> > > > would return immediately. Second call site would be shmem_init()
> > > > and it seems that system hangs on it. Since smp is already initialized
> > > > at that time, there would be some effect of synchronize_sched() but I
> > > > can't imagine what's wrong here. Is it invalid moment to call
> > > > synchronize_sched()?
> > > > 
> > > > Note that my x86 virtual machine works fine even if
> > > > synchronize_sched() is called in shmem_init() but Geert's some ARM
> > > > machines (not all ARM machine) don't work well with it.
> > > 
> > > Color me confused.
> > > 
> > > Is Geert's ARM system somehow adding the second CPU before
> > > rcu_spawn_gp_kthread() is called, that is, before or during
> > > early_initcall() time?
> > 
> > Hang would happen on shmem_init() which is called in do_basic_setup().
> > do_basic_setup() is called after early_initcall().
> 
> Thank you for the info!
> 
> That should be lat enough that the RCU kthreads are alive and well.
> 
> Can you get sysalt-t output?
> 
> > Hmm... Is it okay to call synchronize_sched() by kernel thread?
> 
> Yes, it can, in fact, rcutorture does this all the time.  As do any
> number of other kthreads.

Paul, thanks for confirmation.

Geert, we need to try more debugging.

Could you try below patch to check who causes the hang?

And, if sysalt-t works when hang, could you get sysalt-t output? I haven't
used it before but Paul could find some culprit on it. :)

Thanks.


----->8-----
diff --git a/mm/slab.c b/mm/slab.c
index 763096a..9652d38 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -964,8 +964,13 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
         * guaranteed to be valid until irq is re-enabled, because it will be
         * freed after synchronize_sched().
         */
-       if (force_change)
+       if (force_change) {
+               if (num_online_cpus() > 1)
+                       dump_stack();
                synchronize_sched();
+               if (num_online_cpus() > 1)
+                       dump_stack();
+       }
 
 fail:
        kfree(old_shared);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
