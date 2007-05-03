Date: Thu, 3 May 2007 14:15:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22 -mm merge plans: slub on PowerPC
In-Reply-To: <Pine.LNX.4.64.0705032143420.7589@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0705031408360.13387@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705021017270.32635@schroedinger.engr.sgi.com>
 <20070503011515.0d89082b.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705030936120.5165@blonde.wat.veritas.com>
 <20070503015729.7496edff.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705031011020.9826@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705032143420.7589@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 May 2007, Hugh Dickins wrote:

> On Thu, 3 May 2007, Hugh Dickins wrote:
> > 
> > Seems we're all wrong in thinking Christoph's Kconfiggery worked
> > as intended: maybe it just works some of the time.  I'm not going
> > to hazard a guess as to how to fix it up, will resume looking at
> > the powerpc's quicklist potential later.
> 
> Here's the patch I've been testing on G5, with 4k and with 64k pages,
> with SLAB and with SLUB.  But, though it doesn't crash, the pgd
> kmem_cache in the 4k-page SLUB case is revealing SLUB's propensity
> for using highorder allocations where SLAB would stick to order 0:
> under load, exec's mm_init gets page allocation failure on order 4
> - SLUB's calculate_order may need some retuning.  (I'd expect it to
> be going for order 3 actually, I'm not sure how order 4 comes about.)

There are SLUB patches pending (not in rc7-mm2 as far as I can recall) 
that reduce the default page order sizes to head off this issue. The 
defaults were initially too large (and they still default to large
for testing if Mel's Antifrag work is detected to be active).

> -	return kmem_cache_alloc(pgtable_cache[PTE_CACHE_NUM],
> -				GFP_KERNEL|__GFP_REPEAT);
> +	return quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);

__GFP_REPEAT is unusual here but this was carried over from the 
kmem_cache_alloc it seems. Hmm... There is some variance on how we do this 
between arches. Should we uniformly set or not set this flag?

clameter@schroedinger:~/software/linux-2.6.21-rc7-mm2$ grep quicklist_alloc include/asm-ia64/*
include/asm-ia64/pgalloc.h:     return quicklist_alloc(0, GFP_KERNEL, NULL);
include/asm-ia64/pgalloc.h:     return quicklist_alloc(0, GFP_KERNEL, NULL);
include/asm-ia64/pgalloc.h:     return quicklist_alloc(0, GFP_KERNEL, NULL);
include/asm-ia64/pgalloc.h:     void *pg = quicklist_alloc(0, GFP_KERNEL, NULL);
include/asm-ia64/pgalloc.h:     return quicklist_alloc(0, GFP_KERNEL, NULL);
clameter@schroedinger:~/software/linux-2.6.21-rc7-mm2$ grep quicklist_alloc arch/i386/mm/*    
arch/i386/mm/pgtable.c: pgd_t *pgd = quicklist_alloc(0, GFP_KERNEL, pgd_ctor);
clameter@schroedinger:~/software/linux-2.6.21-rc7-mm2$ grep quicklist_alloc include/asm-sparc64/*
include/asm-sparc64/pgalloc.h:  return quicklist_alloc(0, GFP_KERNEL, NULL);
include/asm-sparc64/pgalloc.h:  return quicklist_alloc(0, GFP_KERNEL, NULL);
include/asm-sparc64/pgalloc.h:  return quicklist_alloc(0, GFP_KERNEL, NULL);
include/asm-sparc64/pgalloc.h:  void *pg = quicklist_alloc(0, GFP_KERNEL, NULL);
clameter@schroedinger:~/software/linux-2.6.21-rc7-mm2$ grep quicklist_alloc include/asm-x86_64/* 
include/asm-x86_64/pgalloc.h:   return (pmd_t *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
include/asm-x86_64/pgalloc.h:   return (pud_t *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
include/asm-x86_64/pgalloc.h:   pgd_t *pgd = (pgd_t *)quicklist_alloc(QUICK_PGD,
include/asm-x86_64/pgalloc.h:   return (pte_t *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
include/asm-x86_64/pgalloc.h:   void *p = (void *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
