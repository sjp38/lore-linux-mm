Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8F46B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 17:45:10 -0400 (EDT)
Received: by wgso17 with SMTP id o17so61288517wgs.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:45:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r6si10474114wjx.75.2015.04.15.14.45.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 14:45:08 -0700 (PDT)
Date: Wed, 15 Apr 2015 22:44:47 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: migrate: Batch TLB flushing when unmapping pages
 for migration
Message-ID: <20150415214447.GJ14842@suse.de>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de>
 <1429094576-5877-5-git-send-email-mgorman@suse.de>
 <alpine.LSU.2.11.1504151302490.13387@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1504151302490.13387@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 15, 2015 at 02:06:19PM -0700, Hugh Dickins wrote:
> On Wed, 15 Apr 2015, Mel Gorman wrote:
> 
> > Page reclaim batches multiple TLB flushes into one IPI and this patch teaches
> > page migration to also batch any necessary flushes. MMtests has a THP scale
> > microbenchmark that deliberately fragments memory and then allocates THPs
> > to stress compaction. It's not a page reclaim benchmark and recent kernels
> > avoid excessive compaction but this patch reduced system CPU usage
> > 
> >                4.0.0       4.0.0
> >             baseline batchmigrate-v1
> > User          970.70     1012.24
> > System       2067.48     1840.00
> > Elapsed      1520.63     1529.66
> > 
> > Note that this particular workload was not TLB flush intensive with peaks
> > in interrupts during the compaction phase. The 4.0 kernel peaked at 345K
> > interrupts/second, the kernel that batches reclaim TLB entries peaked at
> > 13K interrupts/second and this patch peaked at 10K interrupts/second.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/internal.h | 5 +++++
> >  mm/migrate.c  | 8 +++++++-
> >  mm/vmscan.c   | 6 +-----
> >  3 files changed, 13 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/internal.h b/mm/internal.h
> > index fe69dd159e34..cb70555a7291 100644
> > --- a/mm/internal.h
> > +++ b/mm/internal.h
> > @@ -436,10 +436,15 @@ struct unmap_batch;
> >  
> >  #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
> >  void try_to_unmap_flush(void);
> > +void alloc_ubc(void);
> >  #else
> >  static inline void try_to_unmap_flush(void)
> >  {
> >  }
> >  
> > +static inline void alloc_ubc(void)
> > +{
> > +}
> > +
> >  #endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
> >  #endif	/* __MM_INTERNAL_H */
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 85e042686031..973d8befe528 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -789,6 +789,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >  		if (current->flags & PF_MEMALLOC)
> >  			goto out;
> >  
> > +		try_to_unmap_flush();
> 
> I have a vested interest in minimizing page migration overhead,
> enthusiastic for more batching if it can be done, so took a quick
> look at this patch (the earliers not so much); but am mystified by
> your placement of the try_to_unmap_flush()s.
> 

The placement is to flush the TLB before sleeping for a long time.  If the
whole approach is safe then it's not necessary but I saw little reason to
leave it as-is. It should be perfectly safe to not flush before locking
the page (which might sleep) or waiting on writeback (also might sleep).
I'll drop these if they're confusing and similarly I can drop the flush
before entering writeback in mm/vmscan.c

> Why would one be needed here, yet not before the trylock_page() above?
> Oh, when might sleep?  Though I still don't grasp why that's necessary,
> and try_to_unmap() below may itself sleep.
> 

It's not necessary, I just was matching the expectation that when we unmap
we should flush "soon".

> >  		lock_page(page);
> >  	}
> >  
> > @@ -805,6 +806,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >  		}
> >  		if (!force)
> >  			goto out_unlock;
> > +		try_to_unmap_flush();
> >  		wait_on_page_writeback(page);
> >  	}
> >  	/*
> > @@ -879,7 +881,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> >  	/* Establish migration ptes or remove ptes */
> >  	if (page_mapped(page)) {
> >  		try_to_unmap(page,
> > -			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> > +			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|TTU_BATCH_FLUSH);
> 
> But isn't this the only place for the try_to_unmap_flush(), unless you
> make much more change to the way page migration works?  Would batch
> together the TLB flushes from multiple mappings of the same page,
> though that's not a very ambitious goal.
> 

Hmm, I don't quite get this. When the page is unmapped, the masks for the
CPU will be or'd together so the PFN will be flushed from the TLB of any
CPU that was accessing it.

> Delayed much later than this point, and user modifications to the old
> page could continue while we're copying it into the new page and after,
> so the new page receives only some undefined part of the modifications.
> 

For patch 2 or 4 to be safe, there must be an architectural guarantee
that clean->dirty transitions after an unmap triggers a fault. I accept
that in this series that previously dirty PTE can indeed leak through
causing corruption and I've noted it in the leader. It's already in V2
which currently is being tested.

> Or perhaps this is the last minute point you were making about
> page lock in the 0/4, though page lock not so relevant here. 
> 

Yes for the writes leaking through after the unmap if it was previously
dirty. The flush before lock page is not related.

> Or your paragraph in the 0/4 "If a clean page is unmapped and not
> immediately flushed..." but I don't see where that is being enforced.
> 

I'm assuming hardware but I need the architecture guys to confirm that.

> I can imagine more optimization possible on !pte_write pages than
> on pte_write pages, but don't see any sign of that.
> 

It's in rmap.c near the should_defer_flush part. I think that's what you're
looking for or I'm misunderstanding the question.

> Or am I just skimming this series too carelessly, and making a fool of
> myself by missing the important bits?  Sorry if I'm wasting your time.
> 

Not at all. The more eyes on this the better.

> >  		page_was_mapped = 1;
> >  	}
> >  
> > @@ -1098,6 +1100,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> >  	if (!swapwrite)
> >  		current->flags |= PF_SWAPWRITE;
> >  
> > +	alloc_ubc();
> > +
> >  	for(pass = 0; pass < 10 && retry; pass++) {
> >  		retry = 0;
> >  
> > @@ -1144,6 +1148,8 @@ out:
> >  	if (!swapwrite)
> >  		current->flags &= ~PF_SWAPWRITE;
> >  
> > +	try_to_unmap_flush();
> > +
> >  	return rc;
> >  }
> >  
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 68bcc0b73a76..d659e3655575 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2767,7 +2767,7 @@ out:
> >  }
> >  
> >  #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
> > -static inline void alloc_ubc(void)
> > +void alloc_ubc(void)
> 
> Looking at this patch first, I wondered what on earth a ubc is.
> The letters "tlb" in the name might help people to locate its
> place in the world better.
> 

I can do that. It'll be struct tlb_unmap_batch and tlb_ubc;

> And then curious that it works with pfns rather than page pointers,

Because the TLB flush is about the physical address, not the page pointer. I
felt that the PFN was both a more natural interface and this avoids a
page_to_pfn lookup in the per-cpu TLB flush handler.

> as its natural cousin mmu_gather does (oops, no "tlb" there either,
> though that's compensated by naming its pointer "tlb" everywhere).
> 
> pfns: are you thinking ahead to struct page-less persistent memory
> considerations?

Nothing so fancy, I wanted to avoid the page_to_pfn lookup. On VMEMMAP,
that is a negligible cost but even so.

> Though would they ever arrive here?  I'd have
> thought it better to carry on with struct pages at least for now -
> or are they becoming unfashionable?  (I think some tracing struct
> page pointers were converted to pfns recently.)  But no big deal.
> 

FWIW, I did not consider the current debate on whether persistent memory
would use struct pages or not. I simply see zero advantage to using the
struct page unnecessarily.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
