Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0326B0068
	for <linux-mm@kvack.org>; Sun,  8 Apr 2018 00:27:13 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f4-v6so4142303plm.12
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 21:27:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c16si9223613pgv.220.2018.04.07.21.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 07 Apr 2018 21:27:12 -0700 (PDT)
Date: Sat, 7 Apr 2018 21:27:09 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: __GFP_LOW
Message-ID: <20180408042709.GC32632@bombadil.infradead.org>
References: <20180405025841.GA9301@bombadil.infradead.org>
 <CAJWu+oqP64QzvPM6iHtzowek6s4p+3rb7WDXs1z51mwW-9mLbA@mail.gmail.com>
 <20180405142258.GA28128@bombadil.infradead.org>
 <20180405142749.GL6312@dhcp22.suse.cz>
 <20180405151359.GB28128@bombadil.infradead.org>
 <20180405153240.GO6312@dhcp22.suse.cz>
 <20180405161501.GD28128@bombadil.infradead.org>
 <20180405185444.GQ6312@dhcp22.suse.cz>
 <20180405201557.GA3666@bombadil.infradead.org>
 <20180406060953.GA8286@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180406060953.GA8286@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Fri, Apr 06, 2018 at 08:09:53AM +0200, Michal Hocko wrote:
> OK, we already split the documentation into these categories. So we got
> at least the structure right ;)

Yes, this part of the documentation makes sense to me :-)

> >  - What kind of memory to allocate (DMA, NORMAL, HIGHMEM)
> >  - Where to get the pages from
> >    - Local node only (THISNODE)
> >    - Only in compliance with cpuset policy (HARDWALL)
> >    - Spread the pages between zones (WRITE)
> >    - The movable zone (MOVABLE)
> >    - The reclaimable zone (RECLAIMABLE)
> >  - What you are willing to do if no free memory is available:
> >    - Nothing at all (NOWAIT)
> >    - Use my own time to free memory (DIRECT_RECLAIM)
> >      - But only try once (NORETRY)
> >      - Can call into filesystems (FS)
> >      - Can start I/O (IO)
> >      - Can sleep (!ATOMIC)
> >    - Steal time from other processes to free memory (KSWAPD_RECLAIM)
> 
> What does that mean? If I drop the flag, do not steal? Well I do because
> they will hit direct reclaim sooner...

If they allocate memory, sure.  A process which stays in its working
set won't, unless it's preempted by kswapd.

> >    - Kill other processes to get their memory (!RETRY_MAYFAIL)
> 
> Not really for costly orders.

Yes, need to be more precise there.

> >    - All of the above, and wait forever (NOFAIL)
> >    - Take from emergency reserves (HIGH)
> >    - ... but not the last parts of the regular reserves (LOW)
> 
> What does that mean and how it is different from NOWAIT? Is this about
> the low watermark and if yes do we want to teach users about this and
> make the whole thing even more complicated?  Does it wake
> kswapd? What is the eagerness ordering? LOW, NOWAIT, NORETRY,
> RETRY_MAYFAIL, NOFAIL?

LOW doesn't quite fit into the eagerness scale with the other flags;
instead it's composable with them.  So you can specify NOWAIT | LOW,
NORETRY | LOW, NOFAIL | LOW, etc.  All I have in mind is something
like this:

        if (alloc_flags & ALLOC_HIGH)
                min -= min / 2;
+	if (alloc_flags & ALLOC_LOW)
+		min += min / 2;

The idea is that a GFP_KERNEL | __GFP_LOW allocation cannot force a
GFP_KERNEL allocation into an OOM situation because it cannot take
the last pages of memory before the watermark.  It can still make a
GFP_KERNEL allocation *more likely* to hit OOM (just like any other kind
of allocation can), but it can't do it by itself.

---

I've been wondering about combining the DIRECT_RECLAIM, NORETRY,
RETRY_MAYFAIL and NOFAIL flags together into a single field:
0 => RECLAIM_NEVER,	/* !DIRECT_RECLAIM */
1 => RECLAIM_ONCE,	/* NORETRY */
2 => RECLAIM_PROGRESS,	/* RETRY_MAYFAIL */
3 => RECLAIM_FOREVER,	/* NOFAIL */

The existance of __GFP_RECLAIM makes this a bit tricky.  I honestly don't
know what this code is asking for:

kernel/power/swap.c:                       __get_free_page(__GFP_RECLAIM | __GFP_HIGH);
but I suspect I'll have to find out.  There's about 60 places to look at.

I also want to add __GFP_KILL (to be part of the GFP_KERNEL definition).
That way, each bit that you set in the GFP mask increases the things the
page allocator can do to get memory for you.  At the moment, RETRY_MAYFAIL
subtracts the ability to kill other tasks, which is unusual.  For example,
this test in kvmalloc_node:

        WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);

doesn't catch RETRY_MAYFAIL being set.
