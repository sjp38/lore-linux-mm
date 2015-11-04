Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 206FE6B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 07:36:47 -0500 (EST)
Received: by igbdj2 with SMTP id dj2so33988946igb.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 04:36:46 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c19si2063899iod.106.2015.11.04.04.36.46
        for <linux-mm@kvack.org>;
        Wed, 04 Nov 2015 04:36:46 -0800 (PST)
Date: Wed, 4 Nov 2015 12:36:41 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] arm64: Increase the max granular size
Message-ID: <20151104123640.GK7637@e104818-lin.cambridge.arm.com>
References: <1442944788-17254-1-git-send-email-rric@kernel.org>
 <20151028190948.GJ8899@e104818-lin.cambridge.arm.com>
 <CAMuHMdWQygbxMXoOsbwek6DzZcr7J-C23VCK4ubbgUr+zj=giw@mail.gmail.com>
 <20151103120504.GF7637@e104818-lin.cambridge.arm.com>
 <20151103143858.GI7637@e104818-lin.cambridge.arm.com>
 <CAMuHMdWk0fPzTSKhoCuS4wsOU1iddhKJb2SOpjo=a_9vCm_KXQ@mail.gmail.com>
 <20151103185050.GJ7637@e104818-lin.cambridge.arm.com>
 <alpine.DEB.2.20.1511031724010.8178@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1511031724010.8178@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Robert Richter <rric@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Linux-sh list <linux-sh@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Robert Richter <rrichter@cavium.com>, Tirumalesh Chalamarla <tchalamarla@cavium.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org

(+ linux-mm)

On Tue, Nov 03, 2015 at 05:33:25PM -0600, Christoph Lameter wrote:
> On Tue, 3 Nov 2015, Catalin Marinas wrote:
> > (cc'ing Jonsoo and Christoph; summary: slab failure with L1_CACHE_BYTES
> > of 128 and sizeof(kmem_cache_node) of 152)
> 
> Hmmm... Yes that would mean use the 196 sized kmalloc array which is not a
> power of two slab. But the code looks fine to me.

I'm not entirely sure that gets used (or even created).
kmalloc_index(152) returns 8 (INDEX_NODE==8) since KMALLOC_MIN_SIZE==128
and the "kmalloc-node" cache size is 256.

> > If I revert commit 8fc9cf420b36 ("slab: make more slab management
> > structure off the slab") it works but I still need to figure out how
> > slab indices are calculated. The size_index[] array is overridden so
> > that 0..15 are 7 and 16..23 are 8. But the kmalloc_caches[7] has never
> > been populated, hence the BUG_ON. Another option may be to change
> > kmalloc_size and kmalloc_index to cope with KMALLOC_MIN_SIZE of 128.
> >
> > I'll do some more investigation tomorrow.
> 
> The commit allows off slab management for PAGE_SIZE >> 5 that is 128.

This means that the first kmalloc cache to be created, "kmalloc-128", is
off slab.

> After that commit kmem_cache_create would try to allocate an off slab
> management structure which is not available during early boot.
> But the slab_early_init is set which should prevent the use of an off slab
> management infrastructure in kmem_cache_create().
> 
> However, the failure in line 2283 shows that the OFF SLAB flag was
> mistakenly set anyways!!!! Something must havee cleared slab_early_init?

slab_early_init is cleared after "kmem_cache" and "kmalloc-node" caches
are successfully created. Following this, the minimum kmalloc allocation
goes off-slab when KMALLOC_MIN_SIZE == 128.

When trying to create "kmalloc-128" (via create_kmalloc_caches(),
slab_early_init is already 0), __kmem_cache_create() requires an
allocation of 32 bytes (freelist_size) which has index 7, hence exactly
the kmalloc_caches[7] we are trying to create.

The simplest option would be to make sure that off slab isn't allowed
for caches of KMALLOC_MIN_SIZE or smaller, with the drawback that not
only "kmalloc-128" but any other such caches will be on slab.

I think a better option would be to first check that there is a
kmalloc_caches[] entry for freelist_size before deciding to go off-slab.
See below:

-----8<------------------------------
