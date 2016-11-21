Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B44466B04D7
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 00:31:31 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b132so83227715iti.5
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 21:31:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i9si8755770itb.15.2016.11.20.21.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 21:31:30 -0800 (PST)
Date: Mon, 21 Nov 2016 00:31:26 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 16/18] mm/hmm/migrate: new memory migration helper for
 use with device memory
Message-ID: <20161121053125.GG7872@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-17-git-send-email-jglisse@redhat.com>
 <fd02ccec-800f-e0ff-a51f-b42df13b4c9b@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <fd02ccec-800f-e0ff-a51f-b42df13b4c9b@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Mon, Nov 21, 2016 at 02:30:46PM +1100, Balbir Singh wrote:
> On 19/11/16 05:18, Jerome Glisse wrote:

[...]

> > +
> > +
> > +#if defined(CONFIG_HMM)
> > +struct hmm_migrate {
> > +	struct vm_area_struct	*vma;
> > +	unsigned long		start;
> > +	unsigned long		end;
> > +	unsigned long		npages;
> > +	hmm_pfn_t		*pfns;
> 
> I presume the destination is pfns[] or is the source?

Both when alloca_and_copy() is call it is fill with source memory, but once
that callback returns it must have set the destination memory inside that
array. This is what i discussed with Aneesh in this thread.

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
> 
> OK., so we always split THP before migration

Yes because i need special swap entry and those does not exist for pmd.

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
> 
> Why hard code this, in general the ability to migrate a VMA
> start/end range seems like a useful API.

Some memory can not be migrated, can not migrate something that is already
being migrated or something that is swap or something that is bad memory
... I only try to migrate valid memory.

> > +				continue;
> > +			}
> > +
> > +			flags = HMM_PFN_DEVICE | HMM_PFN_UNADDRESSABLE;
> 
> Currently UNADDRESSABLE?

Yes, this is a special device swap entry and those it is unaddressable memory.
The destination memory might also be unaddressable (migrating from one device
to another device).


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
> 
> Didn't we split the THP above?

We splited huge pmd not huge page. Intention is to support huge page but i wanted
to keep patch simple and THP need special handling when it comes to refcount to
check for pin (either on huge page or on one of its tail page).

> 
> > +
> > +		*pfns = hmm_pfn_from_pfn(pfn) | HMM_PFN_MIGRATE | flags;
> > +		*pfns |= write ? HMM_PFN_WRITE : 0;
> > +		migrate->npages++;
> > +		get_page(page);
> > +
> > +		if (!trylock_page(page)) {
> > +			set_pte_at(mm, addr, ptep, pte);
> 
> put_page()?

No, we will try latter to lock the page and thus we want to keep a ref on the page.

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
> 
> PageTransCompound()?

Yes, right now i think on all arch it is equivalent.


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
> Why do we do the rmap bits here?

Because we did page_remove_rmap() in hmm_migrate_collect() so we need to restore
rmap.


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
> 
> I thought HMM supported page cache migration as well.

Not for un-addressable memory. Un-addressable memory need more change to filesystem
to handle read/write and writeback. This will be part of a separate patchset.


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
> 
> What is the expectation from alloc_and_copy()? Can it fail?

It can fail, there is no global status it is all handled on individual page
basis. So for instance if a device can only allocate its device memory as 64
chunk than it  can migrate any chunk that match this constraint and fail for
anything smaller than that.


> > +
> > +	/* This does the real migration of struct page */
> > +	hmm_migrate_struct_page(&migrate);
> > +
> > +	ops->finalize_and_map(vma, start, end, pfns, private);
> 
> Is this just notification to the driver or more?

Just a notification to driver.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
