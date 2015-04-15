Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 951646B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 19:50:44 -0400 (EDT)
Received: by pdea3 with SMTP id a3so69900283pde.3
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 16:50:44 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id t3si9294049pdd.153.2015.04.15.16.50.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 16:50:43 -0700 (PDT)
Received: by pabsx10 with SMTP id sx10so67890931pab.3
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 16:50:43 -0700 (PDT)
Date: Wed, 15 Apr 2015 16:50:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 4/4] mm: migrate: Batch TLB flushing when unmapping pages
 for migration
In-Reply-To: <20150415214447.GJ14842@suse.de>
Message-ID: <alpine.LSU.2.11.1504151609170.14500@eggly.anvils>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de> <1429094576-5877-5-git-send-email-mgorman@suse.de> <alpine.LSU.2.11.1504151302490.13387@eggly.anvils> <20150415214447.GJ14842@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 15 Apr 2015, Mel Gorman wrote:
> On Wed, Apr 15, 2015 at 02:06:19PM -0700, Hugh Dickins wrote:
> > On Wed, 15 Apr 2015, Mel Gorman wrote:
> > 
> > > diff --git a/mm/migrate.c b/mm/migrate.c
> > > index 85e042686031..973d8befe528 100644
> > > --- a/mm/migrate.c
> > > +++ b/mm/migrate.c
> > > @@ -789,6 +789,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> > >  		if (current->flags & PF_MEMALLOC)
> > >  			goto out;
> > >  
> > > +		try_to_unmap_flush();
> > 
> > I have a vested interest in minimizing page migration overhead,
> > enthusiastic for more batching if it can be done, so took a quick
> > look at this patch (the earliers not so much); but am mystified by
> > your placement of the try_to_unmap_flush()s.
> > 
> 
> The placement is to flush the TLB before sleeping for a long time.  If the
> whole approach is safe then it's not necessary but I saw little reason to
> leave it as-is. It should be perfectly safe to not flush before locking
> the page (which might sleep) or waiting on writeback (also might sleep).
> I'll drop these if they're confusing and similarly I can drop the flush
> before entering writeback in mm/vmscan.c

Yes, I think I would prefer you to drop them: if it's unnecessary
to flush in these places, why choose to do so and lose the batching?

> 
> > Why would one be needed here, yet not before the trylock_page() above?
> > Oh, when might sleep?  Though I still don't grasp why that's necessary,
> > and try_to_unmap() below may itself sleep.
> > 
> 
> It's not necessary, I just was matching the expectation that when we unmap
> we should flush "soon".

But no sooner than necessary: that's why you're batching.

> 
> > >  		lock_page(page);
> > >  	}
> > >  
> > > @@ -805,6 +806,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> > >  		}
> > >  		if (!force)
> > >  			goto out_unlock;
> > > +		try_to_unmap_flush();
> > >  		wait_on_page_writeback(page);
> > >  	}
> > >  	/*
> > > @@ -879,7 +881,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> > >  	/* Establish migration ptes or remove ptes */
> > >  	if (page_mapped(page)) {
> > >  		try_to_unmap(page,
> > > -			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> > > +			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|TTU_BATCH_FLUSH);
> > 
> > But isn't this the only place for the try_to_unmap_flush(), unless you
> > make much more change to the way page migration works?  Would batch
> > together the TLB flushes from multiple mappings of the same page,
> > though that's not a very ambitious goal.
> > 
> 
> Hmm, I don't quite get this. When the page is unmapped, the masks for the
> CPU will be or'd together so the PFN will be flushed from the TLB of any
> CPU that was accessing it.

It appears that I am focused on the pte_write pte_dirty case, whereas
you're thinking that you already admitted to that error with your
"Last minute note" about page lock and IO in 0/4.  Right, they're
different aspects of the same issue, which I didn't catch at first.

> 
> > Delayed much later than this point, and user modifications to the old
> > page could continue while we're copying it into the new page and after,
> > so the new page receives only some undefined part of the modifications.
> > 
> 
> For patch 2 or 4 to be safe, there must be an architectural guarantee
> that clean->dirty transitions after an unmap triggers a fault. I accept
> that in this series that previously dirty PTE can indeed leak through
> causing corruption and I've noted it in the leader. It's already in V2
> which currently is being tested.

Right, I've only been telling you what you had already realized.
I should wait for V2 or V3 before commenting further.

> 
> > Or perhaps this is the last minute point you were making about
> > page lock in the 0/4, though page lock not so relevant here. 
> > 
> 
> Yes for the writes leaking through after the unmap if it was previously
> dirty. The flush before lock page is not related.
> 
> > Or your paragraph in the 0/4 "If a clean page is unmapped and not
> > immediately flushed..." but I don't see where that is being enforced.
> > 
> 
> I'm assuming hardware but I need the architecture guys to confirm that.
> 
> > I can imagine more optimization possible on !pte_write pages than
> > on pte_write pages, but don't see any sign of that.
> > 
> 
> It's in rmap.c near the should_defer_flush part. I think that's what you're
> looking for or I'm misunderstanding the question.

"It" being what?  Again I think we're misunderstanding each other.
Seeing that the pte_write case looked dangerous (and yes, it's actually
only the pte_write pte_dirty case), I was expecting to find some special
treatment of pte_write pages versus !pte_write pages somewhere; whereas
that's the case which your "Last minute note" admits is not handled in
this version.

> 
> > Or am I just skimming this series too carelessly, and making a fool of
> > myself by missing the important bits?  Sorry if I'm wasting your time.
> > 
> 
> Not at all. The more eyes on this the better.
> 
> > >  		page_was_mapped = 1;
> > >  	}
> > >  
> > > @@ -1098,6 +1100,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> > >  	if (!swapwrite)
> > >  		current->flags |= PF_SWAPWRITE;
> > >  
> > > +	alloc_ubc();
> > > +
> > >  	for(pass = 0; pass < 10 && retry; pass++) {
> > >  		retry = 0;
> > >  
> > > @@ -1144,6 +1148,8 @@ out:
> > >  	if (!swapwrite)
> > >  		current->flags &= ~PF_SWAPWRITE;
> > >  
> > > +	try_to_unmap_flush();
> > > +
> > >  	return rc;
> > >  }
> > >  
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 68bcc0b73a76..d659e3655575 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2767,7 +2767,7 @@ out:
> > >  }
> > >  
> > >  #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
> > > -static inline void alloc_ubc(void)
> > > +void alloc_ubc(void)
> > 
> > Looking at this patch first, I wondered what on earth a ubc is.
> > The letters "tlb" in the name might help people to locate its
> > place in the world better.
> > 
> 
> I can do that. It'll be struct tlb_unmap_batch and tlb_ubc;

Thanks.

> 
> > And then curious that it works with pfns rather than page pointers,
> 
> Because the TLB flush is about the physical address, not the page pointer. I
> felt that the PFN was both a more natural interface and this avoids a
> page_to_pfn lookup in the per-cpu TLB flush handler.

Right, that's a good reason, I missed that.

> 
> > as its natural cousin mmu_gather does (oops, no "tlb" there either,
> > though that's compensated by naming its pointer "tlb" everywhere).
> > 
> > pfns: are you thinking ahead to struct page-less persistent memory
> > considerations?
> 
> Nothing so fancy, I wanted to avoid the page_to_pfn lookup. On VMEMMAP,
> that is a negligible cost but even so.
> 
> > Though would they ever arrive here?  I'd have
> > thought it better to carry on with struct pages at least for now -
> > or are they becoming unfashionable?  (I think some tracing struct
> > page pointers were converted to pfns recently.)  But no big deal.
> > 
> 
> FWIW, I did not consider the current debate on whether persistent memory
> would use struct pages or not. I simply see zero advantage to using the
> struct page unnecessarily.

Agreed.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
