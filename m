Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1F36B04B5
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 15:06:24 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id c21so25478390ioj.5
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 12:06:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l129si7785063itl.67.2016.11.20.12.06.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 12:06:23 -0800 (PST)
Date: Sun, 20 Nov 2016 15:06:18 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 16/18] mm/hmm/migrate: new memory migration helper for
 use with device memory
Message-ID: <20161120200618.GA3727@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-17-git-send-email-jglisse@redhat.com>
 <87a8cvmtfp.fsf@linux.vnet.ibm.com>
 <20161119171757.GA2194@redhat.com>
 <87ziku1077.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87ziku1077.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Sun, Nov 20, 2016 at 11:51:48PM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <jglisse@redhat.com> writes:
> 
> .....
> 
> >> > +
> >> > +		*pfns = hmm_pfn_from_pfn(pfn) | HMM_PFN_MIGRATE | flags;
> >> > +		*pfns |= write ? HMM_PFN_WRITE : 0;
> >> > +		migrate->npages++;
> >> > +		get_page(page);
> >> > +
> >> > +		if (!trylock_page(page)) {
> >> > +			set_pte_at(mm, addr, ptep, pte);
> >> > +		} else {
> >> > +			pte_t swp_pte;
> >> > +
> >> > +			*pfns |= HMM_PFN_LOCKED;
> >> > +
> >> > +			entry = make_migration_entry(page, write);
> >> > +			swp_pte = swp_entry_to_pte(entry);
> >> > +			if (pte_soft_dirty(pte))
> >> > +				swp_pte = pte_swp_mksoft_dirty(swp_pte);
> >> > +			set_pte_at(mm, addr, ptep, swp_pte);
> >> > +
> >> > +			page_remove_rmap(page, false);
> >> > +			put_page(page);
> >> > +			pages++;
> >> > +		}
> >> 
> >> If this is an optimization, can we get that as a seperate patch with
> >> addtional comments. ? How does take a successful page lock implies it is
> >> not a shared mapping ?
> >
> > It can be a share mapping and that's fine, migration only fail if page is
> > pin.
> >
> 
> In the previous mail you replied above trylock_page() usage is an
> optimization for the usual case where the memory is only use in one
> process and that no concurrent migration/memory event is happening. 
> 
> How did we know that it is only in use by one process. I got the part
> that if we can lock, and since we lock the page early, it avoid
> concurrent migration. But I am not sure about the use by one process
> part. 
> 

The mapcount will reflect that and it is handled latter inside unmap
function. The refcount will be check for pin too.

> 
> >
> >> > +	}
> >> > +
> >> > +	arch_leave_lazy_mmu_mode();
> >> > +	pte_unmap_unlock(ptep - 1, ptl);
> >> > +
> >> > +	/* Only flush the TLB if we actually modified any entries */
> >> > +	if (pages)
> >> > +		flush_tlb_range(walk->vma, start, end);
> >> > +
> >> > +	return 0;
> >> > +}
> >> 
> >> 
> >> So without the optimization the above function is suppose to raise the
> >> refcount and collect all possible pfns tha we can migrate in the array ?
> >
> > Yes correct, this function collect all page we can migrate in the range.
> >
> 
> .....
> 
> >
> >> > +static void hmm_migrate_lock_and_isolate(struct hmm_migrate *migrate)
> >> > +{
> >> > +	unsigned long addr = migrate->start, i = 0;
> >> > +	struct mm_struct *mm = migrate->vma->vm_mm;
> >> > +	struct vm_area_struct *vma = migrate->vma;
> >> > +	unsigned long restore = 0;
> >> > +	bool allow_drain = true;
> >> > +
> >> > +	lru_add_drain();
> >> > +
> >> > +again:
> >> > +	for (; addr < migrate->end; addr += PAGE_SIZE, i++) {
> >> > +		struct page *page = hmm_pfn_to_page(migrate->pfns[i]);
> >> > +
> >> > +		if (!page)
> >> > +			continue;
> >> > +
> >> > +		if (!(migrate->pfns[i] & HMM_PFN_LOCKED)) {
> >> > +			lock_page(page);
> >> > +			migrate->pfns[i] |= HMM_PFN_LOCKED;
> >> > +		}
> >> 
> >> What does taking a page_lock protect against ? Can we document that ?
> >
> > This usual page migration process like existing code, page lock protect against
> > anyone trying to map the page inside another process or at different address. It
> > also block few fs operations. I don't think there is a comprehensive list anywhere
> > but i can try to make one.
> 
> 
> I was comparing it against the trylock_page() usage above. But I guess
> documenting the page lock can be another patch. 

Well trylock_page() in collect function happen under a spinlock (page table spinlock)
hence we can't sleep and don't want to spin either.


> 
> >
> >> > +
> >> > +		/* ZONE_DEVICE page are not on LRU */
> >> > +		if (is_zone_device_page(page))
> >> > +			goto check;
> >> > +
> >> > +		if (!PageLRU(page) && allow_drain) {
> >> > +			/* Drain CPU's pagevec so page can be isolated */
> >> > +			lru_add_drain_all();
> >> > +			allow_drain = false;
> >> > +			goto again;
> >> > +		}
> >> > +
> >> > +		if (isolate_lru_page(page)) {
> >> > +			migrate->pfns[i] &= ~HMM_PFN_MIGRATE;
> >> > +			migrate->npages--;
> >> > +			put_page(page);
> >> > +			restore++;
> >> > +		} else
> >> > +			/* Drop the reference we took in collect */
> >> > +			put_page(page);
> >> > +
> >> > +check:
> >> > +		if (!hmm_migrate_page_check(page, 1)) {
> >> > +			migrate->pfns[i] &= ~HMM_PFN_MIGRATE;
> >> > +			migrate->npages--;
> >> > +			restore++;
> >> > +		}
> >> > +	}
> >> > +
> > 
> 
> .....
> 
> >> > +		}
> >> > +		pte_unmap_unlock(ptep - 1, ptl);
> >> > +
> >> > +		addr = restart;
> >> > +		i = (addr - migrate->start) >> PAGE_SHIFT;
> >> > +		for (; addr < next && restore; addr += PAGE_SHIFT, i++) {
> >> > +			page = hmm_pfn_to_page(migrate->pfns[i]);
> >> > +			if (!page || (migrate->pfns[i] & HMM_PFN_MIGRATE))
> >> > +				continue;
> >> > +
> >> > +			migrate->pfns[i] = 0;
> >> > +			unlock_page(page);
> >> > +			restore--;
> >> > +
> >> > +			if (is_zone_device_page(page)) {
> >> > +				put_page(page);
> >> > +				continue;
> >> > +			}
> >> > +
> >> > +			putback_lru_page(page);
> >> > +		}
> >> > +
> >> > +		if (!restore)
> >> > +			break;
> >> > +	}
> >> 
> >> 
> >> All the above restore won't be needed if we didn't do that migration
> >> entry setup in the first function right ? We just need to drop the
> >> refcount for pages that we failed to isolated ? No need to walk the page
> >> table etc ?
> >
> > Well the migration entry setup is important so that no concurrent migration
> > can race with each other, the one that set the migration entry first is the
> > one that win in respect of migration. Also the CPU page table entry need to
> > be clear so that page content is stable and DMA copy does not miss any data
> > left over in some cache.
> 
> This is the part i am still tryint to understand. 
> hmm_collect_walk_pmd(), did migration entry setup only in one process
> page table. So how can it prevent concurrent migration because one could
> initiate a migration using the va/mapping of another process.
> 

Well hmm_migrate_unmap() will unmap the page in all the process, so before we
call alloc_and_copy(). When alloc_and_copy() is call the page is unmap ie the
mapcount is zero and there is no pin either. Because the page is lock it can
no new mapping to it can be spawn from under us.

This is exactly like existing migration code, the difference is that existing
migration code do not do collect or lock. It expect to get the page locked and
then unmap before trying to migrate.

So ignoring the collect pass and the optimization where i unmap page in the
current process, my logic for migration is otherwise exactly the same as the
existing one.


> Isn't that page lock that is prevent concurrent migration ?

Page lock do prevent concurrent migration yes. But for the collect pass of
my code having the special migration entry is also a important hint that it
is pointless to migrate that page. Moreover the special migration entry do
exist for a reason. It is an indicator in couple place that is important to
have.

> 
> ........
> 
> > 
> >> Why are we walking the page table multiple times ? Is it that after
> >> alloc_copy the content of migrate->pfns pfn array is now the new pfns ?
> >> It is confusing that each of these functions walk one page table
> >> multiple times (even when page can be shared). I was expecting us to
> >> walk the page table once to collect the pfns/pages and then use that
> >> in rest of the calls. Any specific reason you choose to implement it
> >> this way ?
> >
> > Well you need to know the source and destination page, so either i have
> > 2 arrays one for source page and one for destination pages and then i do
> > not need to walk page table multiple time. But needing 2 arrays might be
> > problematic as here we want to migrate reasonable chunk ie few megabyte
> > hence there is a need for vmalloc.
> >
> > My advice to device driver was to pre-allocate this array once (maybe
> > preallocate couple of them). If you really prefer avoiding walking the
> > CPU page table over and over then i can switch to 2 arrays solutions.
> >
> 
> Having two array makes it easy to follow the code. But otherwise I guess
> documenting the above usage of page table above the function will also
> help.
> 
> .....
> 
> >> IMHO If we can get each of the above functions documented properly it will
> >> help with code review. Also if we can avoid that multiple page table
> >> walk, it will make it closer to the existing migration logic.
> >> 
> >
> > What kind of documentation are you looking for ? I thought the high level overview
> > was enough as none of the function do anything out of the ordinary. Do you want
> > more inline documation ? Or a more verbose highlevel overview ?
> 
> 
> Inline documentation for functions will be useful. Also if you can split
> the hmm_collect_walk_pmd() optimization we discussed above into a
> separate patch I guess this will be lot easy to follow.

Ok will do.

> 
> I still haven't understood why we setup that migration entry early and
> that too only on one process page table. If we can explain that as a
> separate patch may be it will much easy to follow.

Well the one process and early is the optimization, i do setup the special
migration entry in all process inside hmm_migrate_unmap(). So my migration
works exactly as existing one except that i optimize the common case where
the page we are interested in is only map in the process we are doing the
migration against.

I will split the optimization as its own patch.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
