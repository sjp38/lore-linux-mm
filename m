Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 966706B009A
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 20:31:23 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id v10so29229803pde.15
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 17:31:23 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id dr6si58971512pdb.16.2015.01.05.17.31.20
        for <linux-mm@kvack.org>;
        Mon, 05 Jan 2015 17:31:22 -0800 (PST)
Date: Tue, 6 Jan 2015 10:31:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 6/6] mm/slab: allocation fastpath without disabling irq
Message-ID: <20150106013122.GB17222@js1304-P5Q-DELUXE>
References: <1420421851-3281-7-git-send-email-iamjoonsoo.kim@lge.com>
 <20150105172139.GA11201@rhlx01.hs-esslingen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150105172139.GA11201@rhlx01.hs-esslingen.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Mohr <andi@lisas.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

Hello,

On Mon, Jan 05, 2015 at 06:21:39PM +0100, Andreas Mohr wrote:
> Hi,
> 
> Joonsoo Kim wrote:
> > + * Calculate the next globally unique transaction for disambiguiation
> 
> "disambiguation"

Okay.

> 
> > +	ac->tid = next_tid(ac->tid);
> (and all others)
> 
> object oriented:
> array_cache_next_tid(ac);
> (or perhaps rather: array_cache_start_transaction(ac);?).

Okay. Christoph request common transaction id management code. If
above object oriented design fit that, I will do it.
> 
> > +	/*
> > +	 * Because we disable irq just now, cpu can be changed
> > +	 * and we are on different node with object node. In this rare
> > +	 * case, just return pfmemalloc object for simplicity.
> > +	 */
> 
> "are on a node which is different from object's node"
> 

Thanks. :)

> 
> 
> General thoughts (maybe just rambling, but that's just my feelings vs.
> this mechanism, so maybe it's food for thought):
> To me, the existing implementation seems too fond of IRQ fumbling
> (i.e., affecting of oh so nicely *unrelated*
> outer global environment context stuff).
> A proper implementation wouldn't need *any* knowledge of this
> (i.e., modifying such "IRQ disable" side effects,
> to avoid having a scheduler hit and possibly ending up on another node).
> 
> Thus to me, the whole handling seems somewhat wrong and split
> (since there remains the need to deal with scheduler distortion/disruption).
> The bare-metal "inner" algorithm should not need to depend on such shenanigans
> but simply be able to carry out its task unaffected,
> where IRQs are simply always left enabled
> (or at least potentially disabled by other kernel components only)
> and the code then elegantly/inherently deals with IRQ complications.

I'm not sure I understand your opinion correctly. If my response is
wrong, please let me know your thought more correctly.

IRQ manipulation is done for synchronization of array cache, not for
freezing allocation context. That is just side-effect. As Christoph
said, slab operation could be executed in interrupt context so we
should protect array cache even if we are in process context.

> Since the node change is scheduler-driven (I assume),
> any (changes of) context attributes
> which are relevant to (affect) SLAB-internal operations
> ought to be implicitly/automatically re-assigned by the scheduler,
> and then the most that should be needed is a *final* check in SLAB
> (possibly in an outer user-facing layer of it)
> whether the current final calculation result still matches expectations,
> i.e. whether there was no disruption
> (in which case we'd also do a goto redo: operation or some such :).

If we can do whole procedure without IRQ manipulation, final check
would be more elegant solution. But, current implementation necessarily
needs IRQ manipulation for synchronization at pretty early phase. In this
situation, doing context check and adjusting context at first step may
be better than final check and redo.

> These thoughts also mean that I'm unsure (difficult to determine)
> of whether this change is good (i.e. a clean step in the right direction),
> or whether instead the implementation could easily directly be made
> fully independent from IRQ constraints.

Is there any issue that this change prevent further improvment?
I think that we can go right direction easily as soon as we find
a better solution even if this change is merged.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
