Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDB96B0253
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 22:21:20 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g13so7949896ioj.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 19:21:20 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id i123si8847102ita.9.2016.06.14.19.21.18
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 19:21:19 -0700 (PDT)
Date: Wed, 15 Jun 2016 11:23:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Message-ID: <20160615022325.GA19863@js1304-P5Q-DELUXE>
References: <CAMuHMdXC=zEjbZADE5wELjOq_kBiFNewpdUrMCe8d3Utu98h8A@mail.gmail.com>
 <20160614062456.GB13753@js1304-P5Q-DELUXE>
 <CAMuHMdWipquaVFKYLd=2KhTx6djwH7NXpzL-RjtikCE=G8KTbA@mail.gmail.com>
 <20160614081125.GA17700@js1304-P5Q-DELUXE>
 <CAMuHMdXc=XN4z96vr_FNcUzFb0203ovHgcfD95Q5LPebr1z0ZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdXc=XN4z96vr_FNcUzFb0203ovHgcfD95Q5LPebr1z0ZQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-renesas-soc@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Jun 14, 2016 at 12:45:14PM +0200, Geert Uytterhoeven wrote:
> Hi Joonsoo,
> 
> On Tue, Jun 14, 2016 at 10:11 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > On Tue, Jun 14, 2016 at 09:31:23AM +0200, Geert Uytterhoeven wrote:
> >> On Tue, Jun 14, 2016 at 8:24 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> >> > On Mon, Jun 13, 2016 at 09:43:13PM +0200, Geert Uytterhoeven wrote:
> >> >> On Tue, Apr 12, 2016 at 6:51 AM,  <js1304@gmail.com> wrote:
> >> >> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >> >> > To check whther free objects exist or not precisely, we need to grab a
> >> >> > lock.  But, accuracy isn't that important because race window would be
> >> >> > even small and if there is too much free object, cache reaper would reap
> >> >> > it.  So, this patch makes the check for free object exisistence not to
> >> >> > hold a lock.  This will reduce lock contention in heavily allocation case.
> >> >> >
> >> >> > Note that until now, n->shared can be freed during the processing by
> >> >> > writing slabinfo, but, with some trick in this patch, we can access it
> >> >> > freely within interrupt disabled period.
> >> >> >
> >> >> > Below is the result of concurrent allocation/free in slab allocation
> >> >> > benchmark made by Christoph a long time ago.  I make the output simpler.
> >> >> > The number shows cycle count during alloc/free respectively so less is
> >> >> > better.
> >> >> >
> >> >> > * Before
> >> >> > Kmalloc N*alloc N*free(32): Average=248/966
> >> >> > Kmalloc N*alloc N*free(64): Average=261/949
> >> >> > Kmalloc N*alloc N*free(128): Average=314/1016
> >> >> > Kmalloc N*alloc N*free(256): Average=741/1061
> >> >> > Kmalloc N*alloc N*free(512): Average=1246/1152
> >> >> > Kmalloc N*alloc N*free(1024): Average=2437/1259
> >> >> > Kmalloc N*alloc N*free(2048): Average=4980/1800
> >> >> > Kmalloc N*alloc N*free(4096): Average=9000/2078
> >> >> >
> >> >> > * After
> >> >> > Kmalloc N*alloc N*free(32): Average=344/792
> >> >> > Kmalloc N*alloc N*free(64): Average=347/882
> >> >> > Kmalloc N*alloc N*free(128): Average=390/959
> >> >> > Kmalloc N*alloc N*free(256): Average=393/1067
> >> >> > Kmalloc N*alloc N*free(512): Average=683/1229
> >> >> > Kmalloc N*alloc N*free(1024): Average=1295/1325
> >> >> > Kmalloc N*alloc N*free(2048): Average=2513/1664
> >> >> > Kmalloc N*alloc N*free(4096): Average=4742/2172
> >> >> >
> >> >> > It shows that allocation performance decreases for the object size up to
> >> >> > 128 and it may be due to extra checks in cache_alloc_refill().  But, with
> >> >> > considering improvement of free performance, net result looks the same.
> >> >> > Result for other size class looks very promising, roughly, 50% performance
> >> >> > improvement.
> >> >> >
> >> >> > v2: replace kick_all_cpus_sync() with synchronize_sched().
> >> >> >
> >> >> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >> >>
> >> >> I've bisected a boot failure (no output at all) in v4.7-rc2 on emev2/kzm9d
> >> >> (Renesas dual Cortex A9) to this patch, which is upstream commit
> >> >> 801faf0db8947e01877920e848a4d338dd7a99e7.
> >> >>
> >> >> I've attached my .config. I don't know if it also happens with
> >> >> shmobile_defconfig, as something went wrong with my remote access to the board,
> >> >> preventing further testing. I also couldn't verify if the issue persists in
> >> >> v4.7-rc3.
> >>
> >> In the mean time, I've verified it also happens with shmobile_defconfig.
> >>
> >> >> Do you have a clue?
> >> >
> >> > I don't have yet. Could you help me to narrow down the problem?
> >> > Following diff is half-revert change to check that synchronize_sched()
> >> > has no problem.
> >>
> >> Thanks!
> >>
> >> Unfortunately the half revert is not sufficient. The full revert is.
> >
> > Thanks for quick testing!
> >
> > Could I ask one more time to check that synchronize_sched() is root
> > cause of the problem? Testing following two diffs will be helpful to me.
> >
> > Thanks.
> >
> > ------->8--------
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 763096a..d892364 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -965,7 +965,7 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
> >          * freed after synchronize_sched().
> >          */
> >         if (force_change)
> > -               synchronize_sched();
> > +               kick_all_cpus_sync();
> >
> >  fail:
> >         kfree(old_shared);
> 
> Works.
> 
> > ------->8------
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 763096a..38d99c2 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -964,8 +964,6 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
> >          * guaranteed to be valid until irq is re-enabled, because it will be
> >          * freed after synchronize_sched().
> >          */
> > -       if (force_change)
> > -               synchronize_sched();
> >
> >  fail:
> >         kfree(old_shared);
> >
> 
> Also works.
> 
> Note that I do not see this problem on any of the other boards I use, one
> of which is also a dual Cortex A9.

Thanks for your help!

It's curious that synchronize_sched() has some effect in this early
phase. In synchronize_sched(), rcu_blocking_is_gp() is called and
it checks num_online_cpus <= 1. If so, synchronize_sched() does nothing.

It would be related to might_sleep() in rcu_blocking_is_gp() but I'm not sure now.

First, I'd like to confirm that num_online_cpus() is correct.
Could you try following patch and give me a dmesg?

Thanks.

------->8----------
diff --git a/mm/slab.c b/mm/slab.c
index 763096a..5b7300a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -964,8 +964,10 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
         * guaranteed to be valid until irq is re-enabled, because it will be
         * freed after synchronize_sched().
         */
-       if (force_change)
-               synchronize_sched();
+       if (force_change) {
+               WARN_ON_ONCE(num_online_cpus() <= 1);
+               WARN_ON_ONCE(num_online_cpus() > 1);
+       }
 
 fail:
        kfree(old_shared);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
