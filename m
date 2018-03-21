Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B21366B0012
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:57:06 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o187-v6so5373402ito.2
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:57:06 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id m8-v6si3686237itm.110.2018.03.21.11.57.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 11:57:05 -0700 (PDT)
Date: Wed, 21 Mar 2018 13:57:02 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1803211354170.13978@nuc-kabylake>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Wed, 21 Mar 2018, Mikulas Patocka wrote:

> So, what would you recommend for allocating 640KB objects while minimizing
> wasted space?
> * alloc_pages - rounds up to the next power of two
> * kmalloc - rounds up to the next power of two
> * alloc_pages_exact - O(n*log n) complexity; and causes memory
>   fragmentation if used excesivelly
> * vmalloc - horrible performance (modifies page tables and that causes
>   synchronization across all CPUs)
>
> anything else?

Need to find it but there is a way to allocate N pages in sequence
somewhere. Otherwise mempools are something that would work.

> > > > What kind of problem could be caused here?
> > >
> > > Unlocked accesses are generally considered bad. For example, see this
> > > piece of code in calculate_sizes:
> > >         s->allocflags = 0;
> > >         if (order)
> > >                 s->allocflags |= __GFP_COMP;
> > >
> > >         if (s->flags & SLAB_CACHE_DMA)
> > >                 s->allocflags |= GFP_DMA;
> > >
> > >         if (s->flags & SLAB_RECLAIM_ACCOUNT)
> > >                 s->allocflags |= __GFP_RECLAIMABLE;
> > >
> > > If you are running this while the cache is in use (i.e. when the user
> > > writes /sys/kernel/slab/<cache>/order), then other processes will see
> > > invalid s->allocflags for a short time.
> >
> > Calculating sizes is done when the slab has only a single accessor. Thus
> > no locking is neeed.
>
> The calculation is done whenever someone writes to
> "/sys/kernel/slab/*/order"

But the flags you are mentioning do not change and the size of the object
does not change. What changes is the number of objects in the slab page.

> And you can obviously write to that file why the slab cache is in use. Try
> it.

You cannot change flags that would impact the size of the objects. I only
allowed changing characteristics that does not impact object size.

> I am not talking about changing the size of objects in a slab cache. I am
> talking about changing the allocation order of a slab cache while the
> cache is in use. This can be done with the sysfs interface.

But then that is something that is allowed but does not affect the object
size used by the slab allocators.
