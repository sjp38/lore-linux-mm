Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A61C6B028B
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 17:48:36 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id l200-v6so2072512ita.3
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 14:48:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e38-v6sor12457568jak.7.2018.11.05.14.48.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 14:48:35 -0800 (PST)
MIME-Version: 1.0
References: <20181105204000.129023-1-bvanassche@acm.org> <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
 <1541454489.196084.157.camel@acm.org> <ce6faf63-1661-abe5-16a6-8c19cc9f6689@rasmusvillemoes.dk>
 <1541457654.196084.159.camel@acm.org>
In-Reply-To: <1541457654.196084.159.camel@acm.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 5 Nov 2018 14:48:23 -0800
Message-ID: <CAKgT0Udci4Ai4OD20NSRuDckE_G4RHma3Bg6H1Um6N9Se_zPew@mail.gmail.com>
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bvanassche@acm.org
Cc: linux@rasmusvillemoes.dk, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, guro@fb.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>

On Mon, Nov 5, 2018 at 2:41 PM Bart Van Assche <bvanassche@acm.org> wrote:
>
> On Mon, 2018-11-05 at 23:14 +0100, Rasmus Villemoes wrote:
> > Won't that pessimize the cases where gfp is a constant to actually do
> > the table lookup, and add 16 bytes to every translation unit?
> >
> > Another option is to add a fake KMALLOC_DMA_RECLAIM so the
> > kmalloc_caches[] array has size 4, then assign the same dma
> > kmalloc_cache pointer to [2][i] and [3][i] (so that costs perhaps a
> > dozen pointers in .data), and then just compute kmalloc_type() as
> >
> > ((flags & __GFP_RECLAIMABLE) >> someshift) | ((flags & __GFP_DMA) >>
> > someothershift).
> >
> > Perhaps one could even shuffle the GFP flags so the two shifts are the same.
>
> How about this version, still untested? My compiler is able to evaluate
> the switch expression if the argument is constant.
>
>  static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
>  {
> -       int is_dma = 0;
> -       int type_dma = 0;
> -       int is_reclaimable;
> +       unsigned int dr = !!(flags & __GFP_RECLAIMABLE);
>
>  #ifdef CONFIG_ZONE_DMA
> -       is_dma = !!(flags & __GFP_DMA);
> -       type_dma = is_dma * KMALLOC_DMA;
> +       dr |= !!(flags & __GFP_DMA) << 1;
>  #endif
>
> -       is_reclaimable = !!(flags & __GFP_RECLAIMABLE);
> -
>         /*
>          * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
>          * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
>          */
> -       return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
> +       switch (dr) {
> +       default:
> +       case 0:
> +               return 0;
> +       case 1:
> +               return KMALLOC_RECLAIM;
> +       case 2:
> +       case 3:
> +               return KMALLOC_DMA;
> +       }
>  }
>
> Bart.

Doesn't this defeat the whole point of the code which I thought was to
avoid conditional jumps and branches? Also why would you bother with
the "dr" value when you could just mask the flags value and switch on
that directly?
