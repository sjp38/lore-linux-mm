Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 646CE6B0028
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 13:49:51 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s6so2747307pgn.3
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 10:49:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q24-v6si4230621pls.600.2018.03.21.10.49.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Mar 2018 10:49:50 -0700 (PDT)
Date: Wed, 21 Mar 2018 10:49:37 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
Message-ID: <20180321174937.GF4780@bombadil.infradead.org>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180320173512.GA19669@bombadil.infradead.org>
 <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake>
 <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake>
 <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
 <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.DEB.2.20.1803211233290.3384@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803211233290.3384@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Wed, Mar 21, 2018 at 12:39:33PM -0500, Christopher Lameter wrote:
> One other thought: If you want to improve the behavior for large scale
> objects allocated through kmalloc/kmemcache then we would certainly be
> glad to entertain those ideas.
> 
> F.e. you could optimize the allcations > 2x PAGE_SIZE so that they do not
> allocate powers of two pages. It would be relatively easy to make
> kmalloc_large round the allocation to the next page size and then allocate
> N consecutive pages via alloc_pages_exact() and free the remainder unused
> pages or some such thing.

I don't know if that's a good idea.  That will contribute to fragmentation
if the allocation is held onto for a short-to-medium length of time.
If the allocation is for a very long period of time then those pages
would have been unavailable anyway, but if the user of the tail pages
holds them beyond the lifetime of the large allocation, then this is
probably a bad tradeoff to make.

I do see Mikulas' use case as interesting, I just don't know whether it's
worth changing slab/slub to support it.  At first blush, other than the
sheer size of the allocations, it's a good fit.
