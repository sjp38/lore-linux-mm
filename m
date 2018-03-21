Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0872E6B0012
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:40:35 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 204-v6so5312564itu.6
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:40:35 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id r142-v6si513835itc.75.2018.03.21.11.40.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 11:40:33 -0700 (PDT)
Date: Wed, 21 Mar 2018 13:40:31 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1803211406180.26409@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1803211335240.13978@nuc-kabylake>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.DEB.2.20.1803211233290.3384@nuc-kabylake> <20180321174937.GF4780@bombadil.infradead.org> <alpine.LRH.2.02.1803211406180.26409@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Wed, 21 Mar 2018, Mikulas Patocka wrote:

> > > F.e. you could optimize the allcations > 2x PAGE_SIZE so that they do not
> > > allocate powers of two pages. It would be relatively easy to make
> > > kmalloc_large round the allocation to the next page size and then allocate
> > > N consecutive pages via alloc_pages_exact() and free the remainder unused
> > > pages or some such thing.
>
> alloc_pages_exact() has O(n*log n) complexity with respect to the number
> of requested pages. It would have to be reworked and optimized if it were
> to be used for the dm-bufio cache. (it could be optimized down to O(log n)
> if it didn't split the compound page to a lot of separate pages, but split
> it to a power-of-two clusters instead).

Well then a memory pool of page allocator requests may address that issue?

Have a look at include/linux/mempool.h.

> > I don't know if that's a good idea.  That will contribute to fragmentation
> > if the allocation is held onto for a short-to-medium length of time.
> > If the allocation is for a very long period of time then those pages
> > would have been unavailable anyway, but if the user of the tail pages
> > holds them beyond the lifetime of the large allocation, then this is
> > probably a bad tradeoff to make.

Fragmentation is sadly a big issue. You could create a mempool on bootup
or early after boot to ensure that you have a sufficient number of
contiguous pages available.

> The problem with alloc_pages_exact() is that it exhausts all the
> high-order pages and leaves many free low-order pages around. So you'll
> end up in a system with a lot of free memory, but with all high-order
> pages missing. As there would be a lot of free memory, the kswapd thread
> would not be woken up to free some high-order pages.

I think that logic is properly balanced and will take into account pages
that have been removed from the LRU expiration logic.

> I think that using slab with high order is better, because it at least
> doesn't leave many low-order pages behind.

Any request to the slab via kmalloc with a size > 2x page size will simply
lead to a page allocator request. You have the same issue. If you want to
rely on the slab allocator buffering large segments for you then a mempool
will also solve the issue for you and you have more control over the pool.

> BTW. it could be possible to open the file
> "/sys/kernel/slab/<cache>/order" from the dm-bufio kernel driver and write
> the requested value there, but it seems very dirty. It would be better to
> have a kernel interface for that.

Hehehe you could directly write to the kmem_cache structure and increase
the order. AFAICT this would be dirty but work.

But still the increased page order will get you into trouble with
fragmentation when the system runs for a long time. That is the reason we
try to limit the allocation sizes coming from the slab allocator.
