Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id BF5C16B025F
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 19:14:40 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 68so2163121pfc.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 16:14:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id wg10si5056607pac.23.2015.12.15.16.14.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 16:14:39 -0800 (PST)
Date: Tue, 15 Dec 2015 16:14:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm PATCH v2 23/25] mm, x86: get_user_pages() for dax mappings
Message-Id: <20151215161438.e971fc9b98814513bbacb3ed@linux-foundation.org>
In-Reply-To: <20151210023916.30368.94401.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<20151210023916.30368.94401.stgit@dwillia2-desk3.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, linux-nvdimm@ml01.01.org, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Logan Gunthorpe <logang@deltatee.com>

On Wed, 09 Dec 2015 18:39:16 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> A dax mapping establishes a pte with _PAGE_DEVMAP set when the driver
> has established a devm_memremap_pages() mapping, i.e. when the pfn_t
> return from ->direct_access() has PFN_DEV and PFN_MAP set.  Later, when
> encountering _PAGE_DEVMAP during a page table walk we lookup and pin a
> struct dev_pagemap instance to keep the result of pfn_to_page() valid
> until put_page().

This patch adds a whole bunch of code and cycles to everyone's kernels,
but few of those kernels will ever use it.  What are our options for
reducing that overhead, presumably via Kconfig?

> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -63,6 +63,16 @@ retry:
>  #endif
>  }
>  
> +static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
> +{
> +	while ((*nr) - nr_start) {
> +		struct page *page = pages[--(*nr)];
> +
> +		ClearPageReferenced(page);
> +		put_page(page);
> +	}
> +}

PG_referenced is doing something magical in this code.  Could we have a
nice comment explaining its meaning in this context?  Unless it's
already there and I missed it..

>
> ...
>
> @@ -830,6 +831,20 @@ static inline void put_dev_pagemap(struct dev_pagemap *pgmap)
>  		percpu_ref_put(pgmap->ref);
>  }
>  
> +static inline void get_page(struct page *page)
> +{
> +	if (is_zone_device_page(page))
> +		percpu_ref_get(page->pgmap->ref);
> +
> +	page = compound_head(page);

So we're assuming that is_zone_device_page() against a tail page works
OK.  That's presently true, fingers crossed for the future...

And we're also assuming that device pages are never compound.  How safe
is that assumption?

> +	/*
> +	 * Getting a normal page or the head of a compound page
> +	 * requires to already have an elevated page->_count.
> +	 */
> +	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
> +	atomic_inc(&page->_count);
> +}

The core pagecache lookup bypasses get_page() by using
page_cache_get_speculative(), but get_page() might be a hotpath for
some workloads.  Here we're adding quite a bit of text and math and a
branch.  I'm counting 157 callsites.

So this is a rather unwelcome change.  Why do we need to alter such a
generic function as get_page() anyway?  Is there some way to avoid
altering it?

> +static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
> +		pmd_t *pmd)
> +{
> +	pmd_t _pmd;
> +
> +	/*
> +	 * We should set the dirty bit only for FOLL_WRITE but for now
> +	 * the dirty bit in the pmd is meaningless.  And if the dirty
> +	 * bit will become meaningful and we'll only set it with
> +	 * FOLL_WRITE, an atomic set_bit will be required on the pmd to
> +	 * set the young bit, instead of the current set_pmd_at.
> +	 */
> +	_pmd = pmd_mkyoung(pmd_mkdirty(*pmd));
> +	if (pmdp_set_access_flags(vma, addr & HPAGE_PMD_MASK,
> +				pmd, _pmd,  1))
> +		update_mmu_cache_pmd(vma, addr, pmd);
> +}
> +
> +struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
> +		pmd_t *pmd, int flags)
> +{
> +	unsigned long pfn = pmd_pfn(*pmd);
> +	struct mm_struct *mm = vma->vm_mm;
> +	struct dev_pagemap *pgmap;
> +	struct page *page;
> +
> +	assert_spin_locked(pmd_lockptr(mm, pmd));
> +
> +	if (flags & FOLL_WRITE && !pmd_write(*pmd))
> +		return NULL;
> +
> +	if (pmd_present(*pmd) && pmd_devmap(*pmd))
> +		/* pass */;
> +	else
> +		return NULL;
> +
> +	if (flags & FOLL_TOUCH)
> +		touch_pmd(vma, addr, pmd);
> +
> +	/*
> +	 * device mapped pages can only be returned if the
> +	 * caller will manage the page reference count.
> +	 */
> +	if (!(flags & FOLL_GET))
> +		return ERR_PTR(-EEXIST);
> +
> +	pfn += (addr & ~PMD_MASK) >> PAGE_SHIFT;
> +	pgmap = get_dev_pagemap(pfn, NULL);
> +	if (!pgmap)
> +		return ERR_PTR(-EFAULT);
> +	page = pfn_to_page(pfn);
> +	get_page(page);
> +	put_dev_pagemap(pgmap);
> +
> +	return page;
> +}

hm, so device pages can be huge.  How does this play with get_page()'s
assumption that the pages cannot be compound?

And again, this is bloating up the kernel for not-widely-used stuff.

>  int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
