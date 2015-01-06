Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 24FE06B00B8
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 05:34:41 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so5024797wid.11
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 02:34:40 -0800 (PST)
Received: from rhlx01.hs-esslingen.de (rhlx01.hs-esslingen.de. [129.143.116.10])
        by mx.google.com with ESMTPS id e6si92332079wja.82.2015.01.06.02.34.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jan 2015 02:34:40 -0800 (PST)
Date: Tue, 6 Jan 2015 11:34:39 +0100
From: Andreas Mohr <andi@lisas.de>
Subject: Re: [PATCH 6/6] mm/slab: allocation fastpath without disabling irq
Message-ID: <20150106103439.GA8669@rhlx01.hs-esslingen.de>
References: <1420421851-3281-7-git-send-email-iamjoonsoo.kim@lge.com>
 <20150105172139.GA11201@rhlx01.hs-esslingen.de>
 <20150106013122.GB17222@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150106013122.GB17222@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andreas Mohr <andi@lisas.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Tue, Jan 06, 2015 at 10:31:22AM +0900, Joonsoo Kim wrote:
> Hello,
> 
> On Mon, Jan 05, 2015 at 06:21:39PM +0100, Andreas Mohr wrote:
> > Hi,
> > 
> > Joonsoo Kim wrote:
> > > +	ac->tid = next_tid(ac->tid);
> > (and all others)
> > 
> > object oriented:
> > array_cache_next_tid(ac);
> > (or perhaps rather: array_cache_start_transaction(ac);?).
> 
> Okay. Christoph request common transaction id management code. If
> above object oriented design fit that, I will do it.

Yeah, that may easily have been the same thing.
This function would then obviously and simply do a
    ac->tid = next_tid(ac->tid);
dance internally
(thereby likely introducing some nice instruction cache savings, too).


> > General thoughts (maybe just rambling, but that's just my feelings vs.
> > this mechanism, so maybe it's food for thought):
> > To me, the existing implementation seems too fond of IRQ fumbling
> > (i.e., affecting of oh so nicely *unrelated*
> > outer global environment context stuff).
> > A proper implementation wouldn't need *any* knowledge of this
> > (i.e., modifying such "IRQ disable" side effects,
> > to avoid having a scheduler hit and possibly ending up on another node).
> > 
> > Thus to me, the whole handling seems somewhat wrong and split
> > (since there remains the need to deal with scheduler distortion/disruption).
> > The bare-metal "inner" algorithm should not need to depend on such shenanigans
> > but simply be able to carry out its task unaffected,
> > where IRQs are simply always left enabled
> > (or at least potentially disabled by other kernel components only)
> > and the code then elegantly/inherently deals with IRQ complications.
> 
> I'm not sure I understand your opinion correctly. If my response is
> wrong, please let me know your thought more correctly.

I have to admit that I was talking general implementation guidelines
rather than having a very close look at what can be done *here*.
Put differently, my goal at this point was just to state weird questions,
for people to then reason about the bigger picture
and come to possibly brilliant conclusions ;)


> IRQ manipulation is done for synchronization of array cache, not for
> freezing allocation context. That is just side-effect. As Christoph
> said, slab operation could be executed in interrupt context so we
> should protect array cache even if we are in process context.

Ah, that clarifies collision areas, thanks!

In general the goal likely should be
to attempt to do as many things "in parallel" (guaranteed-collision-free,
via cleanly instance-separate data) as possible,
and then once the result has been calculated,
do quick/short updating (insertion/deletion)
of the shared/contended resource (here: array cache)
with the necessary protection (IRQs disabled, in this case).
Via some layering tricks, one could manage to do all the calculation handling
without even drawing in any "IRQ management" dependency
to that inner code part ("code file"?),
but the array cache management would then remain IRQ-affected
(in those outer layers which know that they are unfortunately still drawn down
by an annoying dependency on IRQ shenanigans).
Or, in other words: achieve a clean separation of layers
so that it's obvious which ones get hampered by annoying dependencies
and which ones are able to carry out their job unaffected.


And for the "disruption via interrupt context" part:
we currently seem to have "synchronous" handling,
where one needs to forcefully block access to a shared/contended resource
(which would be done
either via annoying mutex contention,
or even via wholesale blocking of IRQ execution).
To remove/reduce friction,
one should either remove any additional foreign-context access to that resource,
thereby making this implementation cleanly (if woefully)
single-context only (as Christoph seems to be intending,
by removing SLAB access from IRQ handlers?),
or ideally implement fully parallel instance-separate data management
(but I guess that's not what one would want
for a global multi-sized-area and thus fragmentation-avoiding SL*B allocator,
since that would mean splitting global memory resources
into per-instance areas?).

Alternatively, one could go for "asynchronous" handling,
where SL*B updates of any foreign-context (but not main-context)
are *delayed*,
by merely queuing them into a simple submission queue
which then will be delay-applied by main-context
either once main-context enters a certain "quiet" state (e.g. context switch?),
or once main-context needs to actively take into account
these effects of foreign-context registrations.
But for an allocator (memory manager),
such "asynchronous" handling might be completely impossible anyway,
since it might need to have a consistent global view,
of all resources at all times
(--> we're back to having a synchronous handling requirement,
via lock contention).


> > These thoughts also mean that I'm unsure (difficult to determine)
> > of whether this change is good (i.e. a clean step in the right direction),
> > or whether instead the implementation could easily directly be made
> > fully independent from IRQ constraints.
> 
> Is there any issue that this change prevent further improvment?
> I think that we can go right direction easily as soon as we find
> a better solution even if this change is merged.

Ah, I see you're skillfully asking the right forward progress question ;)

To which I'm currently limited to saying
that from my side there are no objections to be added to the list
(other than the minor mechanical parts directly stated in my review).

Thanks,

Andreas Mohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
