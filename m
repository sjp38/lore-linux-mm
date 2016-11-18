Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 798C06B0477
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 15:15:10 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b132so41079142iti.5
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:15:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a22si3157262itd.26.2016.11.18.12.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 12:15:09 -0800 (PST)
Date: Fri, 18 Nov 2016 15:15:05 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 16/18] mm/hmm/migrate: new memory migration helper for
 use with device memory
Message-ID: <20161118201505.GB3222@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-17-git-send-email-jglisse@redhat.com>
 <87k2c0muhj.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87k2c0muhj.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Sat, Nov 19, 2016 at 01:27:28AM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <jglisse@redhat.com> writes:
>  
>
> [...]
>
> >+
> > +static int hmm_collect_walk_pmd(pmd_t *pmdp,
> > +				unsigned long start,
> > +				unsigned long end,
> > +				struct mm_walk *walk)
> > +{
> > +	struct hmm_migrate *migrate = walk->private;
> > +	struct mm_struct *mm = walk->vma->vm_mm;
> > +	unsigned long addr = start;
> > +	spinlock_t *ptl;
> > +	hmm_pfn_t *pfns;
> > +	int pages = 0;
> > +	pte_t *ptep;
> > +
> > +again:
> > +	if (pmd_none(*pmdp))
> > +		return 0;
> > +
> > +	split_huge_pmd(walk->vma, pmdp, addr);
> > +	if (pmd_trans_unstable(pmdp))
> > +		goto again;
> > +
> > +	pfns = &migrate->pfns[(addr - migrate->start) >> PAGE_SHIFT];
> > +	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
> > +	arch_enter_lazy_mmu_mode();
> > +
> > +	for (; addr < end; addr += PAGE_SIZE, pfns++, ptep++) {
> > +		unsigned long pfn;
> > +		swp_entry_t entry;
> > +		struct page *page;
> > +		hmm_pfn_t flags;
> > +		bool write;
> > +		pte_t pte;
> > +
> > +		pte = ptep_get_and_clear(mm, addr, ptep);
> > +		if (!pte_present(pte)) {
> > +			if (pte_none(pte))
> > +				continue;
> > +
> > +			entry = pte_to_swp_entry(pte);
> > +			if (!is_device_entry(entry)) {
> > +				set_pte_at(mm, addr, ptep, pte);
> > +				continue;
> > +			}
> > +
> > +			flags = HMM_PFN_DEVICE | HMM_PFN_UNADDRESSABLE;
> > +			page = device_entry_to_page(entry);
> > +			write = is_write_device_entry(entry);
> > +			pfn = page_to_pfn(page);
> > +
> > +			if (!(page->pgmap->flags & MEMORY_MOVABLE)) {
> > +				set_pte_at(mm, addr, ptep, pte);
> > +				continue;
> > +			}
> > +
> > +		} else {
> > +			pfn = pte_pfn(pte);
> > +			page = pfn_to_page(pfn);
> > +			write = pte_write(pte);
> > +			flags = is_zone_device_page(page) ? HMM_PFN_DEVICE : 0;
> > +		}
> > +
> > +		/* FIXME support THP see hmm_migrate_page_check() */
> > +		if (PageTransCompound(page))
> > +			continue;
> > +
> > +		*pfns = hmm_pfn_from_pfn(pfn) | HMM_PFN_MIGRATE | flags;
> > +		*pfns |= write ? HMM_PFN_WRITE : 0;
> > +		migrate->npages++;
> > +		get_page(page);
> > +
> > +		if (!trylock_page(page)) {
> > +			set_pte_at(mm, addr, ptep, pte);
> > +		} else {
> > +			pte_t swp_pte;
> > +
> > +			*pfns |= HMM_PFN_LOCKED;
> > +
> > +			entry = make_migration_entry(page, write);
> > +			swp_pte = swp_entry_to_pte(entry);
> > +			if (pte_soft_dirty(pte))
> > +				swp_pte = pte_swp_mksoft_dirty(swp_pte);
> > +			set_pte_at(mm, addr, ptep, swp_pte);
> > +
> > +			page_remove_rmap(page, false);
> > +			put_page(page);
> > +			pages++;
> > +		}
> 
> Can you explain this. What does a failure to lock means here. Also why
> convert the pte to migration entries here ? We do that in try_to_unmap right ?

This an optimization for the usual case where the memory is only use in one
process and that no concurrent migration/memory event is happening. Basicly
if we can lock the page without waiting then we unmap it and the later call
to try_to_unmap() is a no op.

This is purely to optimize this common case. In short it is doing try_to_unmap()
work ahead of time.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
