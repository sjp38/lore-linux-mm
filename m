Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E95106B0025
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 13:11:03 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x8-v6so3451451pln.9
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 10:11:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z13si2979157pgp.602.2018.03.21.10.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Mar 2018 10:11:02 -0700 (PDT)
Date: Wed, 21 Mar 2018 10:10:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
Message-ID: <20180321171057.GD4780@bombadil.infradead.org>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180320173512.GA19669@bombadil.infradead.org>
 <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake>
 <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake>
 <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
 <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Christopher Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Wed, Mar 21, 2018 at 12:25:39PM -0400, Mikulas Patocka wrote:
> Now - we don't want higher-order allocations for power-of-two caches 
> (because higher-order allocations just cause memory fragmentation without 
> any benefit)

Higher-order allocations don't cause memory fragmentation.  Indeed,
they avoid it.  They do fail as a result of fragmentation, which is
probably what you meant.

> , but we want higher-order allocations for non-power-of-two 
> caches (because higher-order allocations minimize wasted space).
> 
> For example:
> for 192K block size, the ideal order is 4MB (it takes 21 blocks)

I wonder if that's true.  You can get five blocks into 1MB, wasting 64kB.
So going up by two orders of magnitude lets you get an extra block in
at the cost of failing more frequently.

> > You should not be using the slab allocators for these. Allocate higher
> > order pages or numbers of consecutive smaller pagess from the page
> > allocator. The slab allocators are written for objects smaller than page
> > size.
> 
> So, do you argue that I need to write my own slab cache functionality 
> instead of using the existing slab code?
> 
> I can do it - but duplicating code is bad thing.

It is -- but writing a special-purpose allocator can be better than making
a general purpose allocator also solve a special purpose.  I don't know
whether that's true here or not.

Your allocator seems like it could be remarkably simple; you know
you're always doing high-order allocations, and you know that you're
never allocating more than a handful of blocks from a page allocation.
So you can probably store all of your metadata in the struct page
(because your metadata is basically a bitmap) and significantly save on
memory usage.  The one downside I see is that you don't get the reporting
through /proc/slabinfo.

So, is this an area where slub should be improved, or is this a case where
writing a special-purpose allocator makes more sense?  It seems like you
already have a special-purpose allocator, in that you know how to fall
back to vmalloc if slab-alloc fails.  So maybe have your own allocator
that interfaces to the page allocator for now; keep its interface nice
and clean, and maybe it'll get pulled out of your driver and put into mm/
some day if it becomes a useful API for everybody to share?
