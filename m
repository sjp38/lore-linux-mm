Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 903286B004F
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:29:55 -0400 (EDT)
Date: Wed, 3 Jun 2009 15:27:52 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch][v2] swap: virtual swap readahead
Message-ID: <20090603132751.GA1813@cmpxchg.org>
References: <20090602223738.GA15475@cmpxchg.org> <20090602233457.GY1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602233457.GY1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 03, 2009 at 01:34:57AM +0200, Andi Kleen wrote:
> On Wed, Jun 03, 2009 at 12:37:39AM +0200, Johannes Weiner wrote:
> > + *
> > + * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
> > + */
> > +struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> > +			struct vm_area_struct *vma, unsigned long addr)
> > +{
> > +	unsigned long start, pos, end;
> > +	unsigned long pmin, pmax;
> > +	int cluster, window;
> > +
> > +	if (!vma || !vma->vm_mm)	/* XXX: shmem case */
> > +		return swapin_readahead_phys(entry, gfp_mask, vma, addr);
> > +
> > +	cluster = 1 << page_cluster;
> > +	window = cluster << PAGE_SHIFT;
> > +
> > +	/* Physical range to read from */
> > +	pmin = swp_offset(entry) & ~(cluster - 1);
> 
> Is cluster really properly sign extended on 64bit? Looks a little
> dubious. long from the start would be safer

Fixed.

> > +	/* Virtual range to read from */
> > +	start = addr & ~(window - 1);
> 
> Same.

Fixed.

> > +		pgd = pgd_offset(vma->vm_mm, pos);
> > +		if (!pgd_present(*pgd))
> > +			continue;
> > +		pud = pud_offset(pgd, pos);
> > +		if (!pud_present(*pud))
> > +			continue;
> > +		pmd = pmd_offset(pud, pos);
> > +		if (!pmd_present(*pmd))
> > +			continue;
> > +		pte = pte_offset_map_lock(vma->vm_mm, pmd, pos, &ptl);
> 
> You could be more efficient here by using the standard mm/* nested loop
> pattern that avoids relookup of everything in each iteration. I suppose
> it would mainly make a difference with 32bit highpte where mapping a pte
> can be somewhat costly. And you would take less locks this way.

I ran into weird problems here.  The above version is actually faster
in the benchmarks than writing a nested level walker or using
walk_page_range().  Still digging but it can take some time.  Busy
week :(

> > +		page = read_swap_cache_async(swp, gfp_mask, vma, pos);
> > +		if (!page)
> > +			continue;
> 
> That's out of memory, break would be better here because prefetch
> while oom is usually harmful.

It can also happen due to a race with something releasing the swap
slot (i.e. swap_duplicate() fails).  But the old version did a break
too and this patch shouldn't do it differently.  Fixed.

> > +		page_cache_release(page);
> > +	}
> > +	lru_add_drain();	/* Push any new pages onto the LRU now */
> > +	return read_swap_cache_async(entry, gfp_mask, vma, addr);
> 
> Shouldn't that page be already handled in the loop earlier? Why doing that
> again? It would be better to remember it from there.

When doing the nested page table level walker, communicating even more
state back and forth gets pretty ugly.  I see what I can do.

Thanks for your input Andi,

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
