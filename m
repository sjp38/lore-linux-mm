Date: Wed, 28 Feb 2007 14:00:22 -0800 (PST)
Message-Id: <20070228.140022.74750199.davem@davemloft.net>
Subject: Re: [PATCH] SLUB The unqueued slab allocator V3
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0702281120110.27828@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702281120110.27828@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 28 Feb 2007 11:20:44 -0800 (PST)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@engr.sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> V2->V3
> - Debugging and diagnostic support. This is runtime enabled and not compile
>   time enabled. Runtime debugging can be controlled via kernel boot options
>   on an individual slab cache basis or globally.
> - Slab Trace support (For individual slab caches).
> - Resiliency support: If basic sanity checks are enabled (via F f.e.)
>   (boot option) then SLUB will do the best to perform diagnostics and
>   then continue (i.e. mark corrupted objects as used).
> - Fix up numerous issues including clash of SLUBs use of page
>   flags with i386 arch use for pmd and pgds (which are managed
>   as slab caches, sigh).
> - Dynamic per CPU array sizing.
> - Explain SLUB slabcache flags

V3 doesn't boot successfully on sparc64, sorry I don't have the
ability to track this down at the moment since it resets the
machine right as the video device is initialized and after diffing
V2 to V3 there is way too much stuff changing for me to try and
"bisect" between V2 to V3 to find the guilty sub-change.

Maybe if you managed your individual changes in GIT or similar
this could be debugged very quickly. :-)

Meanwhile I noticed that your alignment algorithm is different
than SLAB's.  And I think this is important for the page table
SLABs that some platforms use.

No matter what flags are specified, SLAB gives at least the
passed in alignment specified in kmem_cache_create().  That
logic in slab is here:

	/* 3) caller mandated alignment */
	if (ralign < align) {
		ralign = align;
	}

Whereas SLUB uses the CPU cacheline size when the MUSTALIGN
flag is set.  Architectures do things like:

	pgtable_cache = kmem_cache_create("pgtable_cache",
					  PAGE_SIZE, PAGE_SIZE,
					  SLAB_HWCACHE_ALIGN |
					  SLAB_MUST_HWCACHE_ALIGN,
					  zero_ctor,
					  NULL);

to get a PAGE_SIZE aligned slab, SLUB doesn't give the same
behavior SLAB does in this case.

Arguably SLAB_HWCACHE_ALIGN and SLAB_MUST_HWCACHE_ALIGN should
not be set here, but SLUBs change in semantics in this area
could cause similar grief in other areas, an audit is probably
in order.

The above example was from sparc64, but x86 does the same thing
as probably do other platforms which use SLAB for pagetables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
