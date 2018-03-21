Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 405396B0029
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 13:30:40 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id w125-v6so5016749itf.0
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 10:30:40 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id n31si3617313ioi.146.2018.03.21.10.30.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 10:30:38 -0700 (PDT)
Date: Wed, 21 Mar 2018 12:30:36 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
 <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Wed, 21 Mar 2018, Mikulas Patocka wrote:

> > You should not be using the slab allocators for these. Allocate higher
> > order pages or numbers of consecutive smaller pagess from the page
> > allocator. The slab allocators are written for objects smaller than page
> > size.
>
> So, do you argue that I need to write my own slab cache functionality
> instead of using the existing slab code?

Just use the existing page allocator calls to allocate and free the
memory you need.

> I can do it - but duplicating code is bad thing.

There is no need to duplicate anything. There is lots of infrastructure
already in the kernel. You just need to use the right allocation / freeing
calls.

> > What kind of problem could be caused here?
>
> Unlocked accesses are generally considered bad. For example, see this
> piece of code in calculate_sizes:
>         s->allocflags = 0;
>         if (order)
>                 s->allocflags |= __GFP_COMP;
>
>         if (s->flags & SLAB_CACHE_DMA)
>                 s->allocflags |= GFP_DMA;
>
>         if (s->flags & SLAB_RECLAIM_ACCOUNT)
>                 s->allocflags |= __GFP_RECLAIMABLE;
>
> If you are running this while the cache is in use (i.e. when the user
> writes /sys/kernel/slab/<cache>/order), then other processes will see
> invalid s->allocflags for a short time.

Calculating sizes is done when the slab has only a single accessor. Thus
no locking is neeed.

Changing the size of objects in a slab cache when there is already a set
of object allocated and under management by the slab cache would
cause the allocator to fail and lead to garbled data.
