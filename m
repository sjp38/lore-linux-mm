Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 734436B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 16:42:35 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id m3-v6so10630691iti.1
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:42:35 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id w7-v6si1656217itd.101.2018.03.20.13.42.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 13:42:34 -0700 (PDT)
Date: Tue, 20 Mar 2018 15:42:32 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake>
 <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Tue, 20 Mar 2018, Mikulas Patocka wrote:

> > Maybe do the same thing for SLAB?
>
> Yes, but I need to change it for a specific cache, not for all caches.

Why only some caches?

> When the order is greater than 3 (PAGE_ALLOC_COSTLY_ORDER), the allocation
> becomes unreliable, thus it is a bad idea to increase slub_max_order
> system-wide.

Well the allocations is more likely to fail that is true but SLUB will
fall back to a smaller order should the page allocator refuse to give us
that larger sized page.

> Another problem with slub_max_order is that it would pad all caches to
> slub_max_order, even those that already have a power-of-two size (in that
> case, the padding is counterproductive).

No it does not. Slub will calculate the configuration with the least byte
wastage. It is not the standard order but the maximum order to be used.
Power of two caches below PAGE_SIZE will have order 0.

There are some corner cases where extra metadata is needed per object or
per page that will result in either object sizes that are no longer a
power of two or in page sizes smaller than the whole page. Maybe you have
a case like that? Can you show me a cache that has this issue?

> BTW. the function "order_store" in mm/slub.c modifies the structure
> kmem_cache without taking any locks - is it a bug?

The kmem_cache structure was just allocated. Only one thread can access it
thus no locking is necessary.
