Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id C33BE6B0294
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 19:11:17 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id w26-v6so12333496ioa.4
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 16:11:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l185-v6sor460249itb.21.2018.11.05.16.11.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 16:11:16 -0800 (PST)
MIME-Version: 1.0
References: <20181105204000.129023-1-bvanassche@acm.org> <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
 <1541454489.196084.157.camel@acm.org> <ce6faf63-1661-abe5-16a6-8c19cc9f6689@rasmusvillemoes.dk>
 <1541457654.196084.159.camel@acm.org> <CAKgT0Udci4Ai4OD20NSRuDckE_G4RHma3Bg6H1Um6N9Se_zPew@mail.gmail.com>
 <1541462466.196084.163.camel@acm.org>
In-Reply-To: <1541462466.196084.163.camel@acm.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 5 Nov 2018 16:11:04 -0800
Message-ID: <CAKgT0Ue59US_f-cZtoA=yVbFJ03ca5OMce2opUdQcsvgd8LWMw@mail.gmail.com>
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bvanassche@acm.org
Cc: linux@rasmusvillemoes.dk, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, guro@fb.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>

On Mon, Nov 5, 2018 at 4:01 PM Bart Van Assche <bvanassche@acm.org> wrote:
>
> On Mon, 2018-11-05 at 14:48 -0800, Alexander Duyck wrote:
> > On Mon, Nov 5, 2018 at 2:41 PM Bart Van Assche <bvanassche@acm.org> wrote:
> > > How about this version, still untested? My compiler is able to evaluate
> > > the switch expression if the argument is constant.
> > >
> > >  static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
> > >  {
> > > -       int is_dma = 0;
> > > -       int type_dma = 0;
> > > -       int is_reclaimable;
> > > +       unsigned int dr = !!(flags & __GFP_RECLAIMABLE);
> > >
> > >  #ifdef CONFIG_ZONE_DMA
> > > -       is_dma = !!(flags & __GFP_DMA);
> > > -       type_dma = is_dma * KMALLOC_DMA;
> > > +       dr |= !!(flags & __GFP_DMA) << 1;
> > >  #endif
> > >
> > > -       is_reclaimable = !!(flags & __GFP_RECLAIMABLE);
> > > -
> > >         /*
> > >          * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
> > >          * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
> > >          */
> > > -       return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
> > > +       switch (dr) {
> > > +       default:
> > > +       case 0:
> > > +               return 0;
> > > +       case 1:
> > > +               return KMALLOC_RECLAIM;
> > > +       case 2:
> > > +       case 3:
> > > +               return KMALLOC_DMA;
> > > +       }
> > >  }
> >
> > Doesn't this defeat the whole point of the code which I thought was to
> > avoid conditional jumps and branches? Also why would you bother with
> > the "dr" value when you could just mask the flags value and switch on
> > that directly?
>
> Storing the relevant bits of 'flags' in the 'dr' variable avoids that the
> bit selection expressions have to be repeated and allows to use a switch
> statement instead of multiple if / else statements.

Really they shouldn't have to be repeated. You essentially have just 3
cases. 0, __GFP_RECLAIMABLE, and the default case.

> Most kmalloc() calls pass a constant to the gfp argument. That allows the
> compiler to evaluate kmalloc_type() at compile time. So the conditional jumps
> and branches only appear when the gfp argument is not a constant. What makes
> you think it is important to optimize for that case?
>
> Bart.

I didn't really think it was all that important to optimize, but I
thought that was what you were trying to maintain with the earlier
patch since it was converting things to a table lookup.

If we really don't care then why even bother with the switch statement
anyway? It seems like you could just do one ternary operator and be
done with it. Basically all you need is:
return (defined(CONFIG_ZONE_DMA) && (flags & __GFP_DMA)) ? KMALLOC_DMA :
        (flags & __GFP_RECLAIMABLE) ? KMALLOC_RECLAIM : 0;

Why bother with all the extra complexity of the switch statement?

Thanks.

- Alex
