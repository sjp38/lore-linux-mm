Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA286B0029
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:23:43 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 41so3780623qtp.8
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:23:43 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f72si5861683qkf.203.2018.03.21.11.23.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 11:23:42 -0700 (PDT)
Date: Wed, 21 Mar 2018 14:23:40 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <20180321174937.GF4780@bombadil.infradead.org>
Message-ID: <alpine.LRH.2.02.1803211406180.26409@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake> <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake> <alpine.DEB.2.20.1803211233290.3384@nuc-kabylake> <20180321174937.GF4780@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>



On Wed, 21 Mar 2018, Matthew Wilcox wrote:

> On Wed, Mar 21, 2018 at 12:39:33PM -0500, Christopher Lameter wrote:
> > One other thought: If you want to improve the behavior for large scale
> > objects allocated through kmalloc/kmemcache then we would certainly be
> > glad to entertain those ideas.
> > 
> > F.e. you could optimize the allcations > 2x PAGE_SIZE so that they do not
> > allocate powers of two pages. It would be relatively easy to make
> > kmalloc_large round the allocation to the next page size and then allocate
> > N consecutive pages via alloc_pages_exact() and free the remainder unused
> > pages or some such thing.

alloc_pages_exact() has O(n*log n) complexity with respect to the number 
of requested pages. It would have to be reworked and optimized if it were 
to be used for the dm-bufio cache. (it could be optimized down to O(log n) 
if it didn't split the compound page to a lot of separate pages, but split 
it to a power-of-two clusters instead).

> I don't know if that's a good idea.  That will contribute to fragmentation
> if the allocation is held onto for a short-to-medium length of time.
> If the allocation is for a very long period of time then those pages
> would have been unavailable anyway, but if the user of the tail pages
> holds them beyond the lifetime of the large allocation, then this is
> probably a bad tradeoff to make.

The problem with alloc_pages_exact() is that it exhausts all the 
high-order pages and leaves many free low-order pages around. So you'll 
end up in a system with a lot of free memory, but with all high-order 
pages missing. As there would be a lot of free memory, the kswapd thread 
would not be woken up to free some high-order pages.

I think that using slab with high order is better, because it at least 
doesn't leave many low-order pages behind.

> I do see Mikulas' use case as interesting, I just don't know whether it's
> worth changing slab/slub to support it.  At first blush, other than the
> sheer size of the allocations, it's a good fit.

All I need is to increase the order of a specific slab cache - I think 
it's better to implement an interface that allows doing it than to 
duplicate the slab cache code.

BTW. it could be possible to open the file 
"/sys/kernel/slab/<cache>/order" from the dm-bufio kernel driver and write 
the requested value there, but it seems very dirty. It would be better to 
have a kernel interface for that.

Mikulas
