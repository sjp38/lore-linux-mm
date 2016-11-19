Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C318D6B049D
	for <linux-mm@kvack.org>; Sat, 19 Nov 2016 12:18:04 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b123so27380612itb.3
        for <linux-mm@kvack.org>; Sat, 19 Nov 2016 09:18:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 82si5397441itf.114.2016.11.19.09.18.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Nov 2016 09:18:02 -0800 (PST)
Date: Sat, 19 Nov 2016 12:17:58 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 16/18] mm/hmm/migrate: new memory migration helper for
 use with device memory
Message-ID: <20161119171757.GA2194@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-17-git-send-email-jglisse@redhat.com>
 <87a8cvmtfp.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87a8cvmtfp.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Sat, Nov 19, 2016 at 08:02:26PM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <jglisse@redhat.com> writes:
> 
> > This patch add a new memory migration helpers, which migrate memory
> > backing a range of virtual address of a process to different memory
> > (which can be allocated through special allocator). It differs from
> > numa migration by working on a range of virtual address and thus by
> > doing migration in chunk that can be large enough to use DMA engine
> > or special copy offloading engine.
> >
> > Expected users are any one with heterogeneous memory where different
> > memory have different characteristics (latency, bandwidth, ...). As
> > an example IBM platform with CAPI bus can make use of this feature
> > to migrate between regular memory and CAPI device memory. New CPU
> > architecture with a pool of high performance memory not manage as
> > cache but presented as regular memory (while being faster and with
> > lower latency than DDR) will also be prime user of this patch.
> >
> > Migration to private device memory will be usefull for device that
> > have large pool of such like GPU, NVidia plans to use HMM for that.
> >
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
> > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> > Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> > Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> > Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> > ---
> >  include/linux/hmm.h |  54 ++++-
> >  mm/migrate.c        | 584 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 635 insertions(+), 3 deletions(-)
> >
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index c79abfc..9777309 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -101,10 +101,13 @@ struct hmm;
> >   * HMM_PFN_EMPTY: corresponding CPU page table entry is none (pte_none() true)
> >   * HMM_PFN_FAULT: use by hmm_vma_fault() to signify which address need faulting
> >   * HMM_PFN_DEVICE: this is device memory (ie a ZONE_DEVICE page)
> > + * HMM_PFN_LOCKED: underlying struct page is lock
> >   * HMM_PFN_SPECIAL: corresponding CPU page table entry is special ie result of
> >   *      vm_insert_pfn() or vm_insert_page() and thus should not be mirror by a
> >   *      device (the entry will never have HMM_PFN_VALID set and the pfn value
> >   *      is undefine)
> > + * HMM_PFN_MIGRATE: use by hmm_vma_migrate() to signify which address can be
> > + *      migrated
> >   * HMM_PFN_UNADDRESSABLE: unaddressable device memory (ZONE_DEVICE)
> >   */
> >  typedef unsigned long hmm_pfn_t;
> > @@ -116,9 +119,11 @@ typedef unsigned long hmm_pfn_t;
> >  #define HMM_PFN_EMPTY (1 << 4)
> >  #define HMM_PFN_FAULT (1 << 5)
> >  #define HMM_PFN_DEVICE (1 << 6)
> > -#define HMM_PFN_SPECIAL (1 << 7)
> > -#define HMM_PFN_UNADDRESSABLE (1 << 8)
> > -#define HMM_PFN_SHIFT 9
> > +#define HMM_PFN_LOCKED (1 << 7)
> > +#define HMM_PFN_SPECIAL (1 << 8)
> > +#define HMM_PFN_MIGRATE (1 << 9)
> > +#define HMM_PFN_UNADDRESSABLE (1 << 10)
> > +#define HMM_PFN_SHIFT 11
> >  
> >  static inline struct page *hmm_pfn_to_page(hmm_pfn_t pfn)
> >  {
> > @@ -323,6 +328,49 @@ bool hmm_vma_fault(struct vm_area_struct *vma,
> >  		   hmm_pfn_t *pfns);
> >  
> >  
> > +/*
> > + * struct hmm_migrate_ops - migrate operation callback
> > + *
> > + * @alloc_and_copy: alloc destination memoiry and copy source to it
> > + * @finalize_and_map: allow caller to inspect successfull migrated page
> > + *
> > + * The new HMM migrate helper hmm_vma_migrate() allow memory migration to use
> > + * device DMA engine to perform copy from source to destination memory it also
> > + * allow caller to use its own memory allocator for destination memory.
> > + *
> > + * Note that in alloc_and_copy device driver can decide not to migrate some of
> > + * the entry, for those it must clear the HMM_PFN_MIGRATE flag. The destination
> > + * page must lock and the corresponding hmm_pfn_t value in the array updated
> > + * with the HMM_PFN_MIGRATE and HMM_PFN_LOCKED flag set (and of course be a
> > + * valid entry). It is expected that the page allocated will have an elevated
> > + * refcount and that a put_page() will free the page. Device driver might want
> > + * to allocate with an extra-refcount if they want to control deallocation of
> > + * failed migration inside the finalize_and_map() callback.
> > + *
> > + * Inside finalize_and_map() device driver must use the HMM_PFN_MIGRATE flag to
> > + * determine which page have been successfully migrated.
> > + */
> > +struct hmm_migrate_ops {
> > +	void (*alloc_and_copy)(struct vm_area_struct *vma,
> > +			       unsigned long start,
> > +			       unsigned long end,
> > +			       hmm_pfn_t *pfns,
> > +			       void *private);
> > +	void (*finalize_and_map)(struct vm_area_struct *vma,
> > +				 unsigned long start,
> > +				 unsigned long end,
> > +				 hmm_pfn_t *pfns,
> > +				 void *private);
> > +};
> > +
> > +int hmm_vma_migrate(const struct hmm_migrate_ops *ops,
> > +		    struct vm_area_struct *vma,
> > +		    unsigned long start,
> > +		    unsigned long end,
> > +		    hmm_pfn_t *pfns,
> > +		    void *private);
> > +
> > +
> >  /* Below are for HMM internal use only ! Not to be use by device driver ! */
> >  void hmm_mm_destroy(struct mm_struct *mm);
> >  
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index d9ce8db..393d592 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -41,6 +41,7 @@
> >  #include <linux/page_idle.h>
> >  #include <linux/page_owner.h>
> >  #include <linux/memremap.h>
> > +#include <linux/hmm.h>
> >  
> >  #include <asm/tlbflush.h>
> >  
> > @@ -421,6 +422,14 @@ int migrate_page_move_mapping(struct address_space *mapping,
> >  	int expected_count = 1 + extra_count;
> >  	void **pslot;
> >  
> > +	/*
> > +	 * ZONE_DEVICE pages have 1 refcount always held by their device
> > +	 *
> > +	 * Note that DAX memory will never reach that point as it does not have
> > +	 * the MEMORY_MOVABLE flag set (see include/linux/memory_hotplug.h).
> > +	 */
> > +	expected_count += is_zone_device_page(page);
> > +
> >  	if (!mapping) {
> >  		/* Anonymous page without mapping */
> >  		if (page_count(page) != expected_count)
> > @@ -2087,3 +2096,578 @@ out_unlock:
> >  #endif /* CONFIG_NUMA_BALANCING */
> >  
> >  #endif /* CONFIG_NUMA */
> > +
> > +
> > +#if defined(CONFIG_HMM)
> > +struct hmm_migrate {
> > +	struct vm_area_struct	*vma;
> > +	unsigned long		start;
> > +	unsigned long		end;
> > +	unsigned long		npages;
> > +	hmm_pfn_t		*pfns;
> > +};
> > +
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
> 
> Will that is_zone_device_page() be ever true ?, The pte is present in
> the else patch can the struct page backing that come from zone device ?

Yes, for ZONE_DEVICE on architecture with CAPI like bus you can have ZONE_DEVICE
memory map as device memory is accessible.

> 
> 
> > +		}
> > +
> > +		/* FIXME support THP see hmm_migrate_page_check() */
> > +		if (PageTransCompound(page))
> > +			continue;
> 
> What about page cache pages. Do we support that ? If not may be skip
> that here ?

No, page cache is supported, it will fail latter in the process if it try to
migrate to un-accessible memory which need special handling from address_space
point of view (handling read/write and writeback).


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
> If this is an optimization, can we get that as a seperate patch with
> addtional comments. ? How does take a successful page lock implies it is
> not a shared mapping ?

It can be a share mapping and that's fine, migration only fail if page is
pin.
 

> > +	}
> > +
> > +	arch_leave_lazy_mmu_mode();
> > +	pte_unmap_unlock(ptep - 1, ptl);
> > +
> > +	/* Only flush the TLB if we actually modified any entries */
> > +	if (pages)
> > +		flush_tlb_range(walk->vma, start, end);
> > +
> > +	return 0;
> > +}
> 
> 
> So without the optimization the above function is suppose to raise the
> refcount and collect all possible pfns tha we can migrate in the array ?

Yes correct, this function collect all page we can migrate in the range.
 

> > +
> > +static void hmm_migrate_collect(struct hmm_migrate *migrate)
> > +{
> > +	struct mm_walk mm_walk;
> > +
> > +	mm_walk.pmd_entry = hmm_collect_walk_pmd;
> > +	mm_walk.pte_entry = NULL;
> > +	mm_walk.pte_hole = NULL;
> > +	mm_walk.hugetlb_entry = NULL;
> > +	mm_walk.test_walk = NULL;
> > +	mm_walk.vma = migrate->vma;
> > +	mm_walk.mm = migrate->vma->vm_mm;
> > +	mm_walk.private = migrate;
> > +
> > +	mmu_notifier_invalidate_range_start(mm_walk.mm,
> > +					    migrate->start,
> > +					    migrate->end);
> > +	walk_page_range(migrate->start, migrate->end, &mm_walk);
> > +	mmu_notifier_invalidate_range_end(mm_walk.mm,
> > +					  migrate->start,
> > +					  migrate->end);
> > +}
> > +
> > +static inline bool hmm_migrate_page_check(struct page *page, int extra)
> > +{
> > +	/*
> > +	 * FIXME support THP (transparent huge page), it is bit more complex to
> > +	 * check them then regular page because they can be map with a pmd or
> > +	 * with a pte (split pte mapping).
> > +	 */
> > +	if (PageCompound(page))
> > +		return false;
> > +
> > +	if (is_zone_device_page(page))
> > +		extra++;
> > +
> > +	if ((page_count(page) - extra) > page_mapcount(page))
> > +		return false;
> > +
> > +	return true;
> > +}
> > +
> > +static void hmm_migrate_lock_and_isolate(struct hmm_migrate *migrate)
> > +{
> > +	unsigned long addr = migrate->start, i = 0;
> > +	struct mm_struct *mm = migrate->vma->vm_mm;
> > +	struct vm_area_struct *vma = migrate->vma;
> > +	unsigned long restore = 0;
> > +	bool allow_drain = true;
> > +
> > +	lru_add_drain();
> > +
> > +again:
> > +	for (; addr < migrate->end; addr += PAGE_SIZE, i++) {
> > +		struct page *page = hmm_pfn_to_page(migrate->pfns[i]);
> > +
> > +		if (!page)
> > +			continue;
> > +
> > +		if (!(migrate->pfns[i] & HMM_PFN_LOCKED)) {
> > +			lock_page(page);
> > +			migrate->pfns[i] |= HMM_PFN_LOCKED;
> > +		}
> 
> What does taking a page_lock protect against ? Can we document that ?

This usual page migration process like existing code, page lock protect against
anyone trying to map the page inside another process or at different address. It
also block few fs operations. I don't think there is a comprehensive list anywhere
but i can try to make one.
 
> > +
> > +		/* ZONE_DEVICE page are not on LRU */
> > +		if (is_zone_device_page(page))
> > +			goto check;
> > +
> > +		if (!PageLRU(page) && allow_drain) {
> > +			/* Drain CPU's pagevec so page can be isolated */
> > +			lru_add_drain_all();
> > +			allow_drain = false;
> > +			goto again;
> > +		}
> > +
> > +		if (isolate_lru_page(page)) {
> > +			migrate->pfns[i] &= ~HMM_PFN_MIGRATE;
> > +			migrate->npages--;
> > +			put_page(page);
> > +			restore++;
> > +		} else
> > +			/* Drop the reference we took in collect */
> > +			put_page(page);
> > +
> > +check:
> > +		if (!hmm_migrate_page_check(page, 1)) {
> > +			migrate->pfns[i] &= ~HMM_PFN_MIGRATE;
> > +			migrate->npages--;
> > +			restore++;
> > +		}
> > +	}
> > +
> > +	if (!restore)
> > +		return;
> > +
> > +	for (addr = migrate->start, i = 0; addr < migrate->end;) {
> > +		struct page *page = hmm_pfn_to_page(migrate->pfns[i]);
> > +		unsigned long next, restart;
> > +		spinlock_t *ptl;
> > +		pgd_t *pgdp;
> > +		pud_t *pudp;
> > +		pmd_t *pmdp;
> > +		pte_t *ptep;
> > +
> > +		if (!page || !(migrate->pfns[i] & HMM_PFN_MIGRATE)) {
> > +			addr += PAGE_SIZE;
> > +			i++;
> > +			continue;
> > +		}
> > +
> > +		restart = addr;
> > +		pgdp = pgd_offset(mm, addr);
> > +		if (!pgdp || pgd_none_or_clear_bad(pgdp)) {
> > +			addr = pgd_addr_end(addr, migrate->end);
> > +			i = (addr - migrate->start) >> PAGE_SHIFT;
> > +			continue;
> > +		}
> > +		pudp = pud_offset(pgdp, addr);
> > +		if (!pudp || pud_none(*pudp)) {
> > +			addr = pgd_addr_end(addr, migrate->end);
> > +			i = (addr - migrate->start) >> PAGE_SHIFT;
> > +			continue;
> > +		}
> > +		pmdp = pmd_offset(pudp, addr);
> > +		next = pmd_addr_end(addr, migrate->end);
> > +		if (!pmdp || pmd_none(*pmdp) || pmd_trans_huge(*pmdp)) {
> > +			addr = next;
> > +			i = (addr - migrate->start) >> PAGE_SHIFT;
> > +			continue;
> > +		}
> > +		ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
> > +		for (; addr < next; addr += PAGE_SIZE, i++, ptep++) {
> > +			swp_entry_t entry;
> > +			bool write;
> > +			pte_t pte;
> > +
> > +			page = hmm_pfn_to_page(migrate->pfns[i]);
> > +			if (!page || (migrate->pfns[i] & HMM_PFN_MIGRATE))
> > +				continue;
> > +
> > +			write = migrate->pfns[i] & HMM_PFN_WRITE;
> > +			write &= (vma->vm_flags & VM_WRITE);
> > +
> > +			/* Here it means pte must be a valid migration entry */
> > +			pte = ptep_get_and_clear(mm, addr, ptep);
> 
> 
> It is already a non present pte, so why use ptep_get_and_clear ? why not
> *ptep ? Some archs does lot of additional stuff in get_and_clear. 

Yes i can switch to *ptep, if memory serve this most likely because it was
cut and paste from collect function so there is no motivation behind the use
of get_and_clear

> > +			if (pte_none(pte) || pte_present(pte))
> > +				/* SOMETHING BAD IS GOING ON ! */
> > +				continue;
> > +			entry = pte_to_swp_entry(pte);
> > +			if (!is_migration_entry(entry))
> > +				/* SOMETHING BAD IS GOING ON ! */
> > +				continue;
> > +
> > +			if (is_zone_device_page(page) &&
> > +			    !is_addressable_page(page)) {
> > +				entry = make_device_entry(page, write);
> > +				pte = swp_entry_to_pte(entry);
> > +			} else {
> > +				pte = mk_pte(page, vma->vm_page_prot);
> > +				pte = pte_mkold(pte);
> > +				if (write)
> > +					pte = pte_mkwrite(pte);
> > +			}
> > +			if (pte_swp_soft_dirty(*ptep))
> > +				pte = pte_mksoft_dirty(pte);
> > +
> > +			get_page(page);
> > +			set_pte_at(mm, addr, ptep, pte);
> > +			if (PageAnon(page))
> > +				page_add_anon_rmap(page, vma, addr, false);
> > +			else
> > +				page_add_file_rmap(page, false);
> 
> Do we support pagecache already ? Or is thise just a place holder ? if
> so may be we can drop it and add it later when we add page cache
> support. ?

It support pagecache already. It does not support page cache migration to
un-addressable memory. So in CAPI case pagecache works but in x86/PCIE it
does not.

> 
> > +		}
> > +		pte_unmap_unlock(ptep - 1, ptl);
> > +
> > +		addr = restart;
> > +		i = (addr - migrate->start) >> PAGE_SHIFT;
> > +		for (; addr < next && restore; addr += PAGE_SHIFT, i++) {
> > +			page = hmm_pfn_to_page(migrate->pfns[i]);
> > +			if (!page || (migrate->pfns[i] & HMM_PFN_MIGRATE))
> > +				continue;
> > +
> > +			migrate->pfns[i] = 0;
> > +			unlock_page(page);
> > +			restore--;
> > +
> > +			if (is_zone_device_page(page)) {
> > +				put_page(page);
> > +				continue;
> > +			}
> > +
> > +			putback_lru_page(page);
> > +		}
> > +
> > +		if (!restore)
> > +			break;
> > +	}
> 
> 
> All the above restore won't be needed if we didn't do that migration
> entry setup in the first function right ? We just need to drop the
> refcount for pages that we failed to isolated ? No need to walk the page
> table etc ?

Well the migration entry setup is important so that no concurrent migration
can race with each other, the one that set the migration entry first is the
one that win in respect of migration. Also the CPU page table entry need to
be clear so that page content is stable and DMA copy does not miss any data
left over in some cache.

> 
> > +}
> > +
> > +static void hmm_migrate_unmap(struct hmm_migrate *migrate)
> > +{
> > +	int flags = TTU_MIGRATION | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
> > +	unsigned long addr = migrate->start, i = 0, restore = 0;
> > +
> > +	for (; addr < migrate->end; addr += PAGE_SIZE, i++) {
> > +		struct page *page = hmm_pfn_to_page(migrate->pfns[i]);
> > +
> > +		if (!page || !(migrate->pfns[i] & HMM_PFN_MIGRATE))
> > +			continue;
> > +
> > +		try_to_unmap(page, flags);
> > +		if (page_mapped(page) || !hmm_migrate_page_check(page, 1)) {
> > +			migrate->pfns[i] &= ~HMM_PFN_MIGRATE;
> > +			migrate->npages--;
> > +			restore++;
> > +		}
> > +	}
> > +
> > +	for (; (addr < migrate->end) && restore; addr += PAGE_SIZE, i++) {
> > +		struct page *page = hmm_pfn_to_page(migrate->pfns[i]);
> > +
> > +		if (!page || (migrate->pfns[i] & HMM_PFN_MIGRATE))
> > +			continue;
> > +
> > +		remove_migration_ptes(page, page, false);
> > +
> > +		migrate->pfns[i] = 0;
> > +		unlock_page(page);
> > +		restore--;
> > +
> > +		if (is_zone_device_page(page)) {
> > +			put_page(page);
> > +			continue;
> > +		}
> > +
> > +		putback_lru_page(page);
> 
> May be 
> 
>      } else 
> 	putback_lru_page(page);

Yes it probably clearer to use an else branch there.

> > +	}
> > +}
> > +
> > +static void hmm_migrate_struct_page(struct hmm_migrate *migrate)
> > +{
> > +	unsigned long addr = migrate->start, i = 0;
> > +	struct mm_struct *mm = migrate->vma->vm_mm;
> > +
> > +	for (; addr < migrate->end;) {
> > +		unsigned long next;
> > +		pgd_t *pgdp;
> > +		pud_t *pudp;
> > +		pmd_t *pmdp;
> > +		pte_t *ptep;
> > +
> > +		pgdp = pgd_offset(mm, addr);
> > +		if (!pgdp || pgd_none_or_clear_bad(pgdp)) {
> > +			addr = pgd_addr_end(addr, migrate->end);
> > +			i = (addr - migrate->start) >> PAGE_SHIFT;
> > +			continue;
> > +		}
> > +		pudp = pud_offset(pgdp, addr);
> > +		if (!pudp || pud_none(*pudp)) {
> > +			addr = pgd_addr_end(addr, migrate->end);
> > +			i = (addr - migrate->start) >> PAGE_SHIFT;
> > +			continue;
> > +		}
> > +		pmdp = pmd_offset(pudp, addr);
> > +		next = pmd_addr_end(addr, migrate->end);
> > +		if (!pmdp || pmd_none(*pmdp) || pmd_trans_huge(*pmdp)) {
> > +			addr = next;
> > +			i = (addr - migrate->start) >> PAGE_SHIFT;
> > +			continue;
> > +		}
> > +
> > +		/* No need to lock nothing can change from under us */
> > +		ptep = pte_offset_map(pmdp, addr);
> > +		for (; addr < next; addr += PAGE_SIZE, i++, ptep++) {
> > +			struct address_space *mapping;
> > +			struct page *newpage, *page;
> > +			swp_entry_t entry;
> > +			int r;
> > +
> > +			newpage = hmm_pfn_to_page(migrate->pfns[i]);
> > +			if (!newpage || !(migrate->pfns[i] & HMM_PFN_MIGRATE))
> > +				continue;
> > +			if (pte_none(*ptep) || pte_present(*ptep)) {
> > +				/* This should not happen but be nice */
> > +				migrate->pfns[i] = 0;
> > +				put_page(newpage);
> > +				continue;
> > +			}
> > +			entry = pte_to_swp_entry(*ptep);
> > +			if (!is_migration_entry(entry)) {
> > +				/* This should not happen but be nice */
> > +				migrate->pfns[i] = 0;
> > +				put_page(newpage);
> > +				continue;
> > +			}
> > +
> > +			page = migration_entry_to_page(entry);
> > +			mapping = page_mapping(page);
> > +
> > +			/*
> > +			 * For now only support private anonymous when migrating
> > +			 * to un-addressable device memory.
> > +			 */
> > +			if (mapping && is_zone_device_page(newpage) &&
> > +			    !is_addressable_page(newpage)) {
> > +				migrate->pfns[i] &= ~HMM_PFN_MIGRATE;
> > +				continue;
> > +			}
> > +
> > +			r = migrate_page(mapping, newpage, page,
> > +					 MIGRATE_SYNC, false);
> > +			if (r != MIGRATEPAGE_SUCCESS)
> > +				migrate->pfns[i] &= ~HMM_PFN_MIGRATE;
> > +		}
> > +		pte_unmap(ptep - 1);
> > +	}
> > +}
> 
> 
> Why are we walking the page table multiple times ? Is it that after
> alloc_copy the content of migrate->pfns pfn array is now the new pfns ?
> It is confusing that each of these functions walk one page table
> multiple times (even when page can be shared). I was expecting us to
> walk the page table once to collect the pfns/pages and then use that
> in rest of the calls. Any specific reason you choose to implement it
> this way ?

Well you need to know the source and destination page, so either i have
2 arrays one for source page and one for destination pages and then i do
not need to walk page table multiple time. But needing 2 arrays might be
problematic as here we want to migrate reasonable chunk ie few megabyte
hence there is a need for vmalloc.

My advice to device driver was to pre-allocate this array once (maybe
preallocate couple of them). If you really prefer avoiding walking the
CPU page table over and over then i can switch to 2 arrays solutions.
 

> > +
> > +static void hmm_migrate_remove_migration_pte(struct hmm_migrate *migrate)
> > +{
> > +	unsigned long addr = migrate->start, i = 0;
> > +	struct mm_struct *mm = migrate->vma->vm_mm;
> > +
> > +	for (; addr < migrate->end;) {
> > +		unsigned long next;
> > +		pgd_t *pgdp;
> > +		pud_t *pudp;
> > +		pmd_t *pmdp;
> > +		pte_t *ptep;
> > +
> > +		pgdp = pgd_offset(mm, addr);
> > +		pudp = pud_offset(pgdp, addr);
> > +		pmdp = pmd_offset(pudp, addr);
> > +		next = pmd_addr_end(addr, migrate->end);
> > +
> > +		/* No need to lock nothing can change from under us */
> > +		ptep = pte_offset_map(pmdp, addr);
> > +		for (; addr < next; addr += PAGE_SIZE, i++, ptep++) {
> > +			struct page *page, *newpage;
> > +			swp_entry_t entry;
> > +
> > +			if (pte_none(*ptep) || pte_present(*ptep))
> > +				continue;
> > +			entry = pte_to_swp_entry(*ptep);
> > +			if (!is_migration_entry(entry))
> > +				continue;
> > +
> > +			page = migration_entry_to_page(entry);
> > +			newpage = hmm_pfn_to_page(migrate->pfns[i]);
> > +			if (!newpage)
> > +				newpage = page;
> > +			remove_migration_ptes(page, newpage, false);
> > +
> > +			migrate->pfns[i] = 0;
> > +			unlock_page(page);
> > +			migrate->npages--;
> > +
> > +			if (is_zone_device_page(page))
> > +				put_page(page);
> > +			else
> > +				putback_lru_page(page);
> > +
> > +			if (newpage != page) {
> > +				unlock_page(newpage);
> > +				if (is_zone_device_page(newpage))
> > +					put_page(newpage);
> > +				else
> > +					putback_lru_page(newpage);
> > +			}
> > +		}
> > +		pte_unmap(ptep - 1);
> > +	}
> > +}
> > +
> > +/*
> > + * hmm_vma_migrate() - migrate a range of memory inside vma using accel copy
> > + *
> > + * @ops: migration callback for allocating destination memory and copying
> > + * @vma: virtual memory area containing the range to be migrated
> > + * @start: start address of the range to migrate (inclusive)
> > + * @end: end address of the range to migrate (exclusive)
> > + * @pfns: array of hmm_pfn_t first containing source pfns then destination
> > + * @private: pointer passed back to each of the callback
> > + * Returns: 0 on success, error code otherwise
> > + *
> > + * This will try to migrate a range of memory using callback to allocate and
> > + * copy memory from source to destination. This function will first collect,
> > + * lock and unmap pages in the range and then call alloc_and_copy() callback
> > + * for device driver to allocate destination memory and copy from source.
> > + *
> > + * Then it will proceed and try to effectively migrate the page (struct page
> > + * metadata) a step that can fail for various reasons. Before updating CPU page
> > + * table it will call finalize_and_map() callback so that device driver can
> > + * inspect what have been successfully migrated and update its own page table
> > + * (this latter aspect is not mandatory and only make sense for some user of
> > + * this API).
> > + *
> > + * Finaly the function update CPU page table and unlock the pages before
> > + * returning 0.
> > + *
> > + * It will return an error code only if one of the argument is invalid.
> > + */
> > +int hmm_vma_migrate(const struct hmm_migrate_ops *ops,
> > +		    struct vm_area_struct *vma,
> > +		    unsigned long start,
> > +		    unsigned long end,
> > +		    hmm_pfn_t *pfns,
> > +		    void *private)
> > +{
> > +	struct hmm_migrate migrate;
> > +
> > +	/* Sanity check the arguments */
> > +	start &= PAGE_MASK;
> > +	end &= PAGE_MASK;
> > +	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
> > +		return -EINVAL;
> > +	if (!vma || !ops || !pfns || start >= end)
> > +		return -EINVAL;
> > +	if (start < vma->vm_start || start >= vma->vm_end)
> > +		return -EINVAL;
> > +	if (end <= vma->vm_start || end > vma->vm_end)
> > +		return -EINVAL;
> > +
> > +	migrate.start = start;
> > +	migrate.pfns = pfns;
> > +	migrate.npages = 0;
> > +	migrate.end = end;
> > +	migrate.vma = vma;
> > +
> > +	/* Collect, and try to unmap source pages */
> > +	hmm_migrate_collect(&migrate);
> > +	if (!migrate.npages)
> > +		return 0;
> > +
> > +	/* Lock and isolate page */
> > +	hmm_migrate_lock_and_isolate(&migrate);
> > +	if (!migrate.npages)
> > +		return 0;
> > +
> > +	/* Unmap pages */
> > +	hmm_migrate_unmap(&migrate);
> > +	if (!migrate.npages)
> > +		return 0;
> > +
> > +	/*
> > +	 * At this point pages are lock and unmap and thus they have stable
> > +	 * content and can safely be copied to destination memory that is
> > +	 * allocated by the callback.
> > +	 *
> > +	 * Note that migration can fail in hmm_migrate_struct_page() for each
> > +	 * individual page.
> > +	 */
> > +	ops->alloc_and_copy(vma, start, end, pfns, private);
> > +
> > +	/* This does the real migration of struct page */
> > +	hmm_migrate_struct_page(&migrate);
> > +
> > +	ops->finalize_and_map(vma, start, end, pfns, private);
> > +
> > +	/* Unlock and remap pages */
> > +	hmm_migrate_remove_migration_pte(&migrate);
> > +
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL(hmm_vma_migrate);
> > +#endif /* CONFIG_HMM */
> 
> IMHO If we can get each of the above functions documented properly it will
> help with code review. Also if we can avoid that multiple page table
> walk, it will make it closer to the existing migration logic.
> 

What kind of documentation are you looking for ? I thought the high level overview
was enough as none of the function do anything out of the ordinary. Do you want
more inline documation ? Or a more verbose highlevel overview ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
