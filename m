Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 495216B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 14:14:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so5397031pfz.19
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 11:14:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t141si557012pgb.38.2018.04.09.11.14.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 11:14:04 -0700 (PDT)
Date: Mon, 9 Apr 2018 20:14:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: __GFP_LOW
Message-ID: <20180409181400.GO21835@dhcp22.suse.cz>
References: <20180405142749.GL6312@dhcp22.suse.cz>
 <20180405151359.GB28128@bombadil.infradead.org>
 <20180405153240.GO6312@dhcp22.suse.cz>
 <20180405161501.GD28128@bombadil.infradead.org>
 <20180405185444.GQ6312@dhcp22.suse.cz>
 <20180405201557.GA3666@bombadil.infradead.org>
 <20180406060953.GA8286@dhcp22.suse.cz>
 <20180408042709.GC32632@bombadil.infradead.org>
 <20180409073407.GD21835@dhcp22.suse.cz>
 <20180409155157.GC11756@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409155157.GC11756@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Mon 09-04-18 08:51:57, Matthew Wilcox wrote:
> On Mon, Apr 09, 2018 at 09:34:07AM +0200, Michal Hocko wrote:
> > On Sat 07-04-18 21:27:09, Matthew Wilcox wrote:
> > > > >    - Steal time from other processes to free memory (KSWAPD_RECLAIM)
> > > > 
> > > > What does that mean? If I drop the flag, do not steal? Well I do because
> > > > they will hit direct reclaim sooner...
> > > 
> > > If they allocate memory, sure.  A process which stays in its working
> > > set won't, unless it's preempted by kswapd.
> > 
> > Well, I was probably not clear here. KSWAPD_RECLAIM is not something you
> > want to drop because this is a cooperative flag. If you do not use it
> > then you are effectivelly pushing others to the direct reclaim because
> > the kswapd won't be woken up and won't do the background work. Your
> > working make it sound as a good thing to drop.
> 
> If memory is low, *somebody* has to reclaim.  As I understand it, kswapd
> was originally introduced because networking might do many allocations
> from interrupt context, and so was unable to do its own reclaiming.  On a
> machine which was used only for routing, there was no userspace process to
> do the reclaiming, so it ran out of memory.  But if you're an HPC person
> who's expecting their long-running tasks to be synchronised and not be
> unnecessarily disturbed, having kswapd preempting your task is awful.
> 
> I'm not arguing in favour of removing kswapd or anything like that,
> but if you're not willing/able to reclaim memory yourself, then you're
> necessarily stealing time from other tasks in order to have reclaim
> happen.

Sure, you are right, except if you do not wake kswapd then other
allocators will pay when they hit the wmark and that will happen sooner
or later with our caching semantic. The more users who drop
KSWAPD_RECLAIM we have the more this will be visible. That is all I want
to say.
 
> > > > What does that mean and how it is different from NOWAIT? Is this about
> > > > the low watermark and if yes do we want to teach users about this and
> > > > make the whole thing even more complicated?  Does it wake
> > > > kswapd? What is the eagerness ordering? LOW, NOWAIT, NORETRY,
> > > > RETRY_MAYFAIL, NOFAIL?
> > > 
> > > LOW doesn't quite fit into the eagerness scale with the other flags;
> > > instead it's composable with them.  So you can specify NOWAIT | LOW,
> > > NORETRY | LOW, NOFAIL | LOW, etc.  All I have in mind is something
> > > like this:
> > > 
> > >         if (alloc_flags & ALLOC_HIGH)
> > >                 min -= min / 2;
> > > +	if (alloc_flags & ALLOC_LOW)
> > > +		min += min / 2;
> > > 
> > > The idea is that a GFP_KERNEL | __GFP_LOW allocation cannot force a
> > > GFP_KERNEL allocation into an OOM situation because it cannot take
> > > the last pages of memory before the watermark.
> > 
> > So what are we going to do if the LOW watermark cannot succeed?
> 
> Depends on the other flags.  GFP_NOWAIT | GFP_LOW will just return NULL
> (somewhat more readily than a plain GFP_NOWAIT would).  GFP_NORETRY |
> GFP_LOW will do one pass through reclaim.  If it gets enough pages
> to drag the zone above the watermark, then it'll succeed, otherwise
> return NULL.  NOFAIL | LOW will keep retrying forever.  GFP_KERNEL |
> GFP_LOW ... hmm, that'll OOM-kill another process more eagerly that

s@more eagerly@less eagerly@? And what does that mean actually?

> a regular GFP_KERNEL allocation would.  We'll need a little tweak so
> GFP_LOW implies __GFP_RETRY_MAYFAIL.

I am not really convinced we really need to make the current code, which
is already dreadfully complicated, even more complicated. So color me
unconvinced but I do not really think we absolutely need yet another
flag with a nontrivial semantic. E.g. GFP_KERNEL | __GFP_LOW sounds
quite subtle to me.

> > > It can still make a
> > > GFP_KERNEL allocation *more likely* to hit OOM (just like any other kind
> > > of allocation can), but it can't do it by itself.
> > 
> > So who would be a user of __GFP_LOW?
> 
> vmalloc and Steven's ringbuffer.  If I write a kernel module that tries
> to vmalloc 1TB of space, it'll OOM-kill everything on the machine trying
> to get enough memory to fill the page array.

Yes, we assume certain etiquette and sanity from the code running in
ring 0. I am not really sure we want to make life of any code that
thinks "let's allocated a bunch of memory just in case" very much. Sure
there are places which want to allocate optimistically with some
reasonable fallback but we _do_ have flags for those.

> Probably everyone using
> __GFP_RETRY_MAYFAIL today, to be honest.  It's more likely to accomplish
> what they want -- trying slightly less hard to get memory than GFP_KERNEL
> allocations would.

The main point of __GFP_RETRY_MAYFAIL was to have a consistent failure
semantic regardless of the request size. __GFP_REPEAT was unusable for
that purpose because it was costly order only.

> > > I've been wondering about combining the DIRECT_RECLAIM, NORETRY,
> > > RETRY_MAYFAIL and NOFAIL flags together into a single field:
> > > 0 => RECLAIM_NEVER,	/* !DIRECT_RECLAIM */
> > > 1 => RECLAIM_ONCE,	/* NORETRY */
> > > 2 => RECLAIM_PROGRESS,	/* RETRY_MAYFAIL */
> > > 3 => RECLAIM_FOREVER,	/* NOFAIL */
> > > 
> > > The existance of __GFP_RECLAIM makes this a bit tricky.  I honestly don't
> > > know what this code is asking for:
> > 
> > I am not sure I follow here. Is the RECLAIM_ an internal thing to the
> > allocator?
> 
> No, I'm talking about changing the __GFP flags like this:

OK. I was just confused because we have ALLOC_* for internal use so I
though you want to introduce another concept of RECLAIM_*

Anyway...
> 
> @@ -24,10 +24,8 @@ struct vm_area_struct;
>  #define ___GFP_HIGH            0x20u
>  #define ___GFP_IO              0x40u
>  #define ___GFP_FS              0x80u
> +#define ___GFP_ACCOUNT         0x100u
>  #define ___GFP_NOWARN          0x200u
> -#define ___GFP_RETRY_MAYFAIL   0x400u
> -#define ___GFP_NOFAIL          0x800u
> -#define ___GFP_NORETRY         0x1000u
>  #define ___GFP_MEMALLOC                0x2000u
>  #define ___GFP_COMP            0x4000u
>  #define ___GFP_ZERO            0x8000u
> @@ -35,8 +33,10 @@ struct vm_area_struct;
>  #define ___GFP_HARDWALL                0x20000u
>  #define ___GFP_THISNODE                0x40000u
>  #define ___GFP_ATOMIC          0x80000u
> -#define ___GFP_ACCOUNT         0x100000u
> -#define ___GFP_DIRECT_RECLAIM  0x400000u
> +#define ___GFP_RECLAIM_NEVER   0x00000u
> +#define ___GFP_RECLAIM_ONCE    0x10000u
> +#define ___GFP_RECLAIM_PROGRESS        0x20000u
> +#define ___GFP_RECLAIM_FOREVER 0x30000u
>  #define ___GFP_WRITE           0x800000u
>  #define ___GFP_KSWAPD_RECLAIM  0x1000000u
>  #ifdef CONFIG_LOCKDEP

... I really do not care about names much. It would be a bit pain to do
the flag day and all the renaming but maybe we do not have hundreds of
those. I haven't checked. But I do not see a good reason to do that TBH.
I am pretty sure that you will gate 10 different opinions when you close
3-5 people in the room and let them discuss for more than 10 minutes.

> > > kernel/power/swap.c:                       __get_free_page(__GFP_RECLAIM | __GFP_HIGH);
> > > but I suspect I'll have to find out.  There's about 60 places to look at.
> > 
> > Well, it would be more understandable if this was written as
> > (GFP_KERNEL | __GFP_HIGH) & ~(__GFP_FS|__GFP_IO)
> 
> Yeah, I think it's really (GFP_NOIO | __GFP_HIGH)
> 
> > > I also want to add __GFP_KILL (to be part of the GFP_KERNEL definition).
> > 
> > What does __GFP_KILL means?
> 
> Allows OOM killing.  So it's the inverse of the GFP_RETRY_MAYFAIL bit.

We have GFP_NORETRY for that. Because we absolutely do not want to give
users any control over the OOM killer behavior. This is and should be an
implementation detail of the MM implementation. GFP_NORETRY on the other
hand is not about the OOM killer. It is about to give up early.
-- 
Michal Hocko
SUSE Labs
