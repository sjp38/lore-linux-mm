Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5CA6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 11:24:41 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id y13so12529107pdi.8
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 08:24:41 -0800 (PST)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id t3si16925084pdc.177.2015.01.19.08.24.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 08:24:38 -0800 (PST)
Received: by mail-pd0-f175.google.com with SMTP id fl12so4465949pdb.6
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 08:24:37 -0800 (PST)
Date: Mon, 19 Jan 2015 11:24:07 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 4/6] HMM: add HMM page table.
Message-ID: <20150119162403.GA3731@gmail.com>
References: <1420497889-10088-1-git-send-email-j.glisse@gmail.com>
 <1420497889-10088-5-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1420497889-10088-5-git-send-email-j.glisse@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

On Mon, Jan 05, 2015 at 05:44:47PM -0500, j.glisse@gmail.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> Heterogeneous memory management main purpose is to mirror a process address.
> To do so it must maintain a secondary page table that is use by the device
> driver to program the device or build a device specific page table.
> 
> Radix tree can not be use to create this secondary page table because HMM
> needs more flags than RADIX_TREE_MAX_TAGS (while this can be increase we
> believe HMM will require so much flags that cost will becomes prohibitive
> to others users of radix tree).
> 
> Moreover radix tree is built around long but for HMM we need to store dma
> address and on some platform sizeof(dma_addr_t) > sizeof(long). Thus radix
> tree is unsuitable to fulfill HMM requirement hence why we introduce this
> code which allows to create page table that can grow and shrink dynamicly.
> 
> The design is very clause to CPU page table as it reuse some of the feature
> such as spinlock embedded in struct page.

Hi Linus,

I was hopping that after LCA or maybe on a plane back from it, you could take
a look at this version of the patchset and share your view on them, especialy
the page table one as it seemed to be the contentious point of previous version.

I would really like to know where we stand on this. Hardware using this feature
is coming fast and i would rather have linux kernel support early.

Hope you will be mildly happier with that version.

Cheers,
Jerome

> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
> ---
>  MAINTAINERS            |   2 +
>  include/linux/hmm_pt.h | 261 ++++++++++++++++++++++++++++++
>  mm/Makefile            |   2 +-
>  mm/hmm_pt.c            | 425 +++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 689 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/hmm_pt.h
>  create mode 100644 mm/hmm_pt.c
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 3ec87c4..4090e86 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4539,6 +4539,8 @@ L:	linux-mm@kvack.org
>  S:	Maintained
>  F:	mm/hmm.c
>  F:	include/linux/hmm.h
> +F:	mm/hmm_pt.c
> +F:	include/linux/hmm_pt.h
>  
>  HOST AP DRIVER
>  M:	Jouni Malinen <j@w1.fi>
> diff --git a/include/linux/hmm_pt.h b/include/linux/hmm_pt.h
> new file mode 100644
> index 0000000..88fc519
> --- /dev/null
> +++ b/include/linux/hmm_pt.h
> @@ -0,0 +1,261 @@
> +/*
> + * Copyright 2014 Red Hat Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Authors: Jerome Glisse <jglisse@redhat.com>
> + */
> +/*
> + * This provide a set of helpers for HMM page table. See include/linux/hmm.h
> + * for a description of what HMM is.
> + *
> + * HMM page table rely on a locking mecanism similar to CPU page table for page
> + * table update. It use the spinlock embedded inside the struct page to protect
> + * change to page table directory which should minimize lock contention for
> + * concurrent update.
> + *
> + * It does also provide a directory tree protection mechanism. Unlike CPU page
> + * table there is no mmap semaphore to protect directory tree from removal and
> + * this is done intentionaly so that concurrent removal/insertion of directory
> + * inside the tree can happen.
> + *
> + * So anyone walking down the page table must protect directory it traverses so
> + * they are not free by some other thread. This is done by using a reference
> + * counter for each directory. Before traversing a directory a reference is
> + * taken and once traversal is done the reference is drop.
> + *
> + * A directory entry dereference and refcount increment of sub-directory page
> + * must happen in a critical rcu section so that directory page removal can
> + * gracefully wait for all possible other threads that might have dereferenced
> + * the directory.
> + */
> +#ifndef _HMM_PT_H
> +#define _HMM_PT_H
> +
> +/*
> + * The HMM page table entry does not reflect any specific hardware. It is just
> + * a common entry format use by HMM internal and expose to HMM user so they can
> + * extract information out of HMM page table.
> + */
> +#define HMM_PTE_VALID		(1 << 0)
> +#define HMM_PTE_WRITE		(1 << 1)
> +#define HMM_PTE_DIRTY		(1 << 2)
> +#define HMM_PFN_SHIFT		4
> +#define HMM_PFN_MASK		(~((dma_addr_t)((1 << HMM_PFN_SHIFT) - 1)))
> +
> +static inline dma_addr_t hmm_pte_from_pfn(dma_addr_t pfn)
> +{
> +	return (pfn << HMM_PFN_SHIFT) | HMM_PTE_VALID;
> +}
> +
> +static inline unsigned long hmm_pte_pfn(dma_addr_t pte)
> +{
> +	return pte >> HMM_PFN_SHIFT;
> +}
> +
> +#define HMM_PT_MAX_LEVEL	6
> +
> +/* struct hmm_pt - HMM page table structure.
> + *
> + * @mask: Array of address mask value of each level.
> + * @directory_mask: Mask for directory index (see below).
> + * @last: Last valid address (inclusive).
> + * @pgd: page global directory (top first level of the directory tree).
> + * @lock: Share lock if spinlock_t does not fit in struct page.
> + * @shift: Array of address shift value of each level.
> + * @llevel: Last level.
> + *
> + * The index into each directory for a given address and level is :
> + *   (address >> shift[level]) & directory_mask
> + *
> + * Only hmm_pt.last field needs to be set before calling hmm_pt_init().
> + */
> +struct hmm_pt {
> +	unsigned long		mask[HMM_PT_MAX_LEVEL];
> +	unsigned long		directory_mask;
> +	unsigned long		last;
> +	dma_addr_t		*pgd;
> +	spinlock_t		lock;
> +	unsigned char		shift[HMM_PT_MAX_LEVEL];
> +	unsigned char		llevel;
> +};
> +
> +int hmm_pt_init(struct hmm_pt *pt);
> +void hmm_pt_fini(struct hmm_pt *pt);
> +
> +static inline unsigned hmm_pt_index(struct hmm_pt *pt,
> +				    unsigned long addr,
> +				    unsigned level)
> +{
> +	return (addr >> pt->shift[level]) & pt->directory_mask;
> +}
> +
> +#if USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS
> +static inline void hmm_pt_directory_lock(struct hmm_pt *pt,
> +					 struct page *ptd,
> +					 unsigned level)
> +{
> +	if (level)
> +		spin_lock(&ptd->ptl);
> +	else
> +		spin_lock(&pt->lock);
> +}
> +
> +static inline void hmm_pt_directory_unlock(struct hmm_pt *pt,
> +					   struct page *ptd,
> +					   unsigned level)
> +{
> +	if (level)
> +		spin_unlock(&ptd->ptl);
> +	else
> +		spin_unlock(&pt->lock);
> +}
> +#else /* USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS */
> +static inline void hmm_pt_directory_lock(struct hmm_pt *pt,
> +					 struct page *ptd,
> +					 unsigned level)
> +{
> +	spin_lock(&pt->lock);
> +}
> +
> +static inline void hmm_pt_directory_unlock(struct hmm_pt *pt,
> +					   struct page *ptd,
> +					   unsigned level)
> +{
> +	spin_unlock(&pt->lock);
> +}
> +#endif
> +
> +static inline unsigned long hmm_pt_level_start(struct hmm_pt *pt,
> +					       unsigned long addr,
> +					       unsigned level)
> +{
> +	return addr & pt->mask[level];
> +}
> +
> +static inline unsigned long hmm_pt_level_end(struct hmm_pt *pt,
> +					     unsigned long addr,
> +					     unsigned level)
> +{
> +	return (addr | (~pt->mask[level])) + 1UL;
> +}
> +
> +static inline unsigned long hmm_pt_level_next(struct hmm_pt *pt,
> +					      unsigned long addr,
> +					      unsigned long end,
> +					      unsigned level)
> +{
> +	addr = (addr | (~pt->mask[level])) + 1UL;
> +	return (addr - 1 < end - 1) ? addr : end;
> +}
> +
> +
> +/* struct hmm_pt_iter - page table iterator states.
> + *
> + * @ptd: Array of directory struct page pointer for each levels.
> + * @ptdp: Array of pointer to mapped directory levels.
> + * @dead_directories: List of directories that died while walking page table.
> + * @cur: Current address.
> + */
> +struct hmm_pt_iter {
> +	struct page		*ptd[HMM_PT_MAX_LEVEL - 1];
> +	dma_addr_t		*ptdp[HMM_PT_MAX_LEVEL - 1];
> +	struct list_head	dead_directories;
> +	unsigned long		cur;
> +};
> +
> +void hmm_pt_iter_init(struct hmm_pt_iter *iter);
> +void hmm_pt_iter_fini(struct hmm_pt_iter *iter, struct hmm_pt *pt);
> +unsigned long hmm_pt_iter_next(struct hmm_pt_iter *iter,
> +			       struct hmm_pt *pt,
> +			       unsigned long addr,
> +			       unsigned long end);
> +dma_addr_t *hmm_pt_iter_update(struct hmm_pt_iter *iter,
> +			       struct hmm_pt *pt,
> +			       unsigned long addr);
> +dma_addr_t *hmm_pt_iter_fault(struct hmm_pt_iter *iter,
> +			      struct hmm_pt *pt,
> +			      unsigned long addr);
> +
> +/* hmm_pt_protect_directory_unref() - reference a directory.
> + *
> + * @iter: Iterator states that currently protect the directory.
> + * @level: Level of the directory to reference.
> + *
> + * This function will reference a directory but it is illegal for refcount to
> + * be 0 as this helper should only be call when iterator is protecting the
> + * directory (ie iterator hold a reference for the directory).
> + *
> + * HMM user will call this with level = pt.llevel any other value is supicious
> + * outside of hmm_pt code.
> + */
> +static inline void hmm_pt_iter_directory_ref(struct hmm_pt_iter *iter,
> +					     char level)
> +{
> +	/* Nothing to do for root level. */
> +	if (!level)
> +		return;
> +
> +	if (!atomic_inc_not_zero(&iter->ptd[level - 1]->_mapcount))
> +		/* Illegal this should not happen. */
> +		BUG();
> +}
> +
> +/* hmm_pt_protect_directory_unref() - unreference a directory.
> + *
> + * @iter: Iterator states that currently protect the directory.
> + * @level: Level of the directory to unreference.
> + *
> + * This function will unreference a directory but it is illegal for refcount to
> + * reach 0 here as this helper should only be call when iterator is protecting
> + * the directory (ie iterator hold a reference for the directory).
> + *
> + * HMM user will call this with level = pt.llevel any other value is supicious
> + * outside of hmm_pt code.
> + */
> +static inline void hmm_pt_iter_directory_unref(struct hmm_pt_iter *iter,
> +					       char level)
> +{
> +	/* Nothing to do for root level. */
> +	if (!level)
> +		return;
> +
> +	if (!atomic_dec_and_test(&iter->ptd[level - 1]->_mapcount))
> +		return;
> +
> +	/* Illegal this should not happen. */
> +	BUG();
> +}
> +
> +static inline dma_addr_t *hmm_pt_iter_ptdp(struct hmm_pt_iter *iter,
> +					   struct hmm_pt *pt,
> +					   unsigned long addr)
> +{
> +	BUG_ON(!iter->ptd[pt->llevel - 1] ||
> +	       addr < hmm_pt_level_start(pt, iter->cur, pt->llevel) ||
> +	       addr >= hmm_pt_level_end(pt, iter->cur, pt->llevel));
> +	return &iter->ptdp[pt->llevel - 1][hmm_pt_index(pt, addr, pt->llevel)];
> +}
> +
> +static inline void hmm_pt_iter_directory_lock(struct hmm_pt_iter *iter,
> +					      struct hmm_pt *pt)
> +{
> +	hmm_pt_directory_lock(pt, iter->ptd[pt->llevel - 1], pt->llevel);
> +}
> +
> +static inline void hmm_pt_iter_directory_unlock(struct hmm_pt_iter *iter,
> +						struct hmm_pt *pt)
> +{
> +	hmm_pt_directory_unlock(pt, iter->ptd[pt->llevel - 1], pt->llevel);
> +}
> +
> +
> +#endif /* _HMM_PT_H */
> diff --git a/mm/Makefile b/mm/Makefile
> index cb2f9ed..d2e50f2 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -73,4 +73,4 @@ obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
>  obj-$(CONFIG_CMA)	+= cma.o
>  obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
>  obj-$(CONFIG_PAGE_EXTENSION) += page_ext.o
> -obj-$(CONFIG_HMM) += hmm.o
> +obj-$(CONFIG_HMM) += hmm.o hmm_pt.o
> diff --git a/mm/hmm_pt.c b/mm/hmm_pt.c
> new file mode 100644
> index 0000000..4af7ca8
> --- /dev/null
> +++ b/mm/hmm_pt.c
> @@ -0,0 +1,425 @@
> +/*
> + * Copyright 2014 Red Hat Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Authors: Jerome Glisse <jglisse@redhat.com>
> + */
> +/*
> + * This provide a set of helpers for HMM page table. See include/linux/hmm.h
> + * for a description of what HMM is and include/linux/hmm_pt.h.
> + */
> +#include <linux/highmem.h>
> +#include <linux/slab.h>
> +#include <linux/hmm_pt.h>
> +
> +/* hmm_pt_init() - initialize HMM page table.
> + *
> + * @pt: HMM page table to initialize.
> + *
> + * This function will initialize HMM page table and allocate memory for global
> + * directory. Only the hmm_pt.last fields need to be set prior to calling this
> + * function.
> + */
> +int hmm_pt_init(struct hmm_pt *pt)
> +{
> +	unsigned directory_shift, i = 0, npgd;
> +
> +	pt->last &= PAGE_MASK;
> +	spin_lock_init(&pt->lock);
> +	/* Directory shift is the number of bits that a single directory level
> +	 * represent. For instance if PAGE_SIZE is 4096 and each entry takes 8
> +	 * bytes (sizeof(dma_addr_t) == 8) then directory_shift = 9.
> +	 */
> +	directory_shift = PAGE_SHIFT - ilog2(sizeof(dma_addr_t));
> +	/* Level 0 is the root level of the page table. It might use less
> +	 * bits than directory_shift but all sub-directory level will use all
> +	 * directory_shift bits.
> +	 *
> +	 * For instance if hmm_pt.last == (1 << 48), PAGE_SHIFT == 12 and
> +	 * sizeof(dma_addr_t) == 8 then :
> +	 *   directory_shift = 9
> +	 *   shift[0] = 39
> +	 *   shift[1] = 30
> +	 *   shift[2] = 21
> +	 *   shift[3] = 12
> +	 *   llevel = 3
> +	 *
> +	 * Note that shift[llevel] == PAGE_SHIFT because the last level
> +	 * correspond to the page table entry level (ignoring the case of huge
> +	 * page).
> +	 */
> +	pt->shift[0] = ((__fls(pt->last >> PAGE_SHIFT) / directory_shift) *
> +			directory_shift) + PAGE_SHIFT;
> +	while (pt->shift[i++] > PAGE_SHIFT)
> +		pt->shift[i] = pt->shift[i - 1] - directory_shift;
> +	pt->llevel = i - 1;
> +	pt->directory_mask = (1 << directory_shift) - 1;
> +
> +	for (i = 0; i <= pt->llevel; ++i)
> +		pt->mask[i] = ~((1UL << pt->shift[i]) - 1);
> +
> +	npgd = (pt->last >> pt->shift[0]) + 1;
> +	pt->pgd = kzalloc(npgd * sizeof(dma_addr_t), GFP_KERNEL);
> +	if (!pt->pgd)
> +		return -ENOMEM;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(hmm_pt_init);
> +
> +static void hmm_pt_fini_directory(struct hmm_pt *pt,
> +				  struct page *ptd,
> +				  unsigned level)
> +{
> +	dma_addr_t *ptdp;
> +	unsigned i;
> +
> +	if (level == pt->llevel)
> +		return;
> +
> +	ptdp = kmap(ptd);
> +	for (i = 0; i <= pt->directory_mask; ++i) {
> +		struct page *lptd;
> +
> +		if (!(ptdp[i] & HMM_PTE_VALID))
> +			continue;
> +		lptd = pfn_to_page(hmm_pte_pfn(ptdp[i]));
> +		ptdp[i] = 0;
> +		hmm_pt_fini_directory(pt, lptd, level + 1);
> +		atomic_set(&ptd->_mapcount, -1);
> +		__free_page(ptd);
> +	}
> +	kunmap(ptd);
> +}
> +
> +/* hmm_pt_fini() - finalize HMM page table.
> + *
> + * @pt: HMM page table to finalize.
> + *
> + * This function will free all resources of a directory page table.
> + */
> +void hmm_pt_fini(struct hmm_pt *pt)
> +{
> +	unsigned i;
> +
> +	/* Free all directory. */
> +	for (i = 0; i <= (pt->last >> pt->shift[0]); ++i) {
> +		struct page *ptd;
> +
> +		if (!(pt->pgd[i] & HMM_PTE_VALID))
> +			continue;
> +		ptd = pfn_to_page(hmm_pte_pfn(pt->pgd[i]));
> +		pt->pgd[i] = 0;
> +		hmm_pt_fini_directory(pt, ptd, 1);
> +		atomic_set(&ptd->_mapcount, -1);
> +		__free_page(ptd);
> +	}
> +
> +	kfree(pt->pgd);
> +	pt->pgd = NULL;
> +}
> +EXPORT_SYMBOL(hmm_pt_fini);
> +
> +
> +/* hmm_pt_init() - initialize iterator states.
> + *
> + * @iter: Iterator states.
> + *
> + * This function will initialize iterator states. It must always be pair with a
> + * call to hmm_pt_iter_fini().
> + */
> +void hmm_pt_iter_init(struct hmm_pt_iter *iter)
> +{
> +	memset(iter->ptd, 0, sizeof(void *) * (HMM_PT_MAX_LEVEL - 1));
> +	memset(iter->ptdp, 0, sizeof(void *) * (HMM_PT_MAX_LEVEL - 1));
> +	INIT_LIST_HEAD(&iter->dead_directories);
> +}
> +EXPORT_SYMBOL(hmm_pt_iter_init);
> +
> +/* hmm_pt_iter_directory_unref_safe() - unref a directory that is safe to free.
> + *
> + * @iter: Iterator states.
> + * @pt: HMM page table.
> + * @level: Level of the directory to unref.
> + *
> + * This function will unreference a directory and add it to dead list if
> + * directory no longer have any reference. It will also clear the entry to
> + * that directory into the upper level directory as well as dropping ref
> + * on the upper directory.
> + */
> +static void hmm_pt_iter_directory_unref_safe(struct hmm_pt_iter *iter,
> +					     struct hmm_pt *pt,
> +					     unsigned level)
> +{
> +	struct page *upper_ptd;
> +	dma_addr_t *upper_ptdp;
> +
> +	/* Nothing to do for root level. */
> +	if (!level)
> +		return;
> +
> +	if (!atomic_dec_and_test(&iter->ptd[level - 1]->_mapcount))
> +		return;
> +
> +	upper_ptd = level > 1 ? iter->ptd[level - 2] : NULL;
> +	upper_ptdp = level > 1 ? iter->ptdp[level - 2] : pt->pgd;
> +	upper_ptdp = &upper_ptdp[hmm_pt_index(pt, iter->cur, level - 1)];
> +	hmm_pt_directory_lock(pt, upper_ptd, level - 1);
> +	/*
> +	 * There might be race btw decrementing reference count on a directory
> +	 * and another thread trying to fault in a new directory. To avoid
> +	 * erasing the new directory entry we need to check that the entry
> +	 * still correspond to the directory we are removing.
> +	 */
> +	if (hmm_pte_pfn(*upper_ptdp) == page_to_pfn(iter->ptd[level - 1]))
> +		*upper_ptdp = 0;
> +	hmm_pt_directory_unlock(pt, upper_ptd, level - 1);
> +
> +	/* Add it to delayed free list. */
> +	list_add_tail(&iter->ptd[level - 1]->lru, &iter->dead_directories);
> +
> +	/*
> +	 * The upper directory is not safe to unref as we have an extra ref and
> +	 * thus refcount should not reach 0.
> +	 */
> +	hmm_pt_iter_directory_unref(iter, level - 1);
> +}
> +
> +static void hmm_pt_iter_unprotect_directory(struct hmm_pt_iter *iter,
> +					    struct hmm_pt *pt,
> +					    unsigned level)
> +{
> +	if (!iter->ptd[level - 1])
> +		return;
> +	kunmap(iter->ptd[level - 1]);
> +	hmm_pt_iter_directory_unref_safe(iter, pt, level);
> +	iter->ptd[level - 1] = NULL;
> +}
> +
> +/* hmm_pt_iter_protect_directory() - protect a directory.
> + *
> + * @iter: Iterator states.
> + * @ptd: directory struct page to protect.
> + * @addr: Address of the directory.
> + * @level: Level of this directory (> 0).
> + * Returns -EINVAL on error, 1 if protection succeeded, 0 otherwise.
> + *
> + * This function will proctect a directory by taking a reference. It will also
> + * map the directory to allow cpu access.
> + *
> + * Call to this function must be made from inside the rcu read critical section
> + * that convert the table entry to the directory struct page. Doing so allow to
> + * support concurrent removal of directory because this function will take the
> + * reference inside the rcu critical section and thus rcu synchronization will
> + * garanty that we can safely free directory.
> + */
> +int hmm_pt_iter_protect_directory(struct hmm_pt_iter *iter,
> +				  struct page *ptd,
> +				  unsigned long addr,
> +				  unsigned level)
> +{
> +	/* This must be call inside rcu read section. */
> +	BUG_ON(!rcu_read_lock_held());
> +
> +	if (!level || iter->ptd[level - 1]) {
> +		rcu_read_unlock();
> +		return -EINVAL;
> +	}
> +
> +	if (!atomic_inc_not_zero(&ptd->_mapcount)) {
> +		rcu_read_unlock();
> +		return 0;
> +	}
> +
> +	rcu_read_unlock();
> +
> +	iter->ptd[level - 1] = ptd;
> +	iter->ptdp[level - 1] = kmap(ptd);
> +	iter->cur = addr;
> +
> +	return 1;
> +}
> +
> +unsigned long hmm_pt_iter_next(struct hmm_pt_iter *iter,
> +			       struct hmm_pt *pt,
> +			       unsigned long addr,
> +			       unsigned long end)
> +{
> +	unsigned i;
> +
> +	for (i = pt->llevel; i >= 1; --i) {
> +		if (!iter->ptd[i - 1])
> +			continue;
> +		if (addr >= hmm_pt_level_start(pt, iter->cur, i) &&
> +		    addr < hmm_pt_level_end(pt, iter->cur, i))
> +			return hmm_pt_level_next(pt, iter->cur, end, i);
> +	}
> +
> +	/*
> +	 * No need for rcu protection worst case is we return a now dead
> +	 * address.
> +	 */
> +	if (pt->pgd[hmm_pt_index(pt, addr, 0)] & HMM_PTE_VALID)
> +		return hmm_pt_level_next(pt, addr, end, pt->llevel);
> +	for (; addr < end; addr = hmm_pt_level_next(pt, addr, end, 0))
> +		if (pt->pgd[hmm_pt_index(pt, addr, 0)] & HMM_PTE_VALID)
> +			return addr;
> +	return end;
> +}
> +EXPORT_SYMBOL(hmm_pt_iter_next);
> +
> +dma_addr_t *hmm_pt_iter_update(struct hmm_pt_iter *iter,
> +			       struct hmm_pt *pt,
> +			       unsigned long addr)
> +{
> +	int i;
> +
> +	addr &= PAGE_MASK;
> +
> +	if (iter->ptd[pt->llevel - 1] &&
> +	    addr >= hmm_pt_level_start(pt, iter->cur, pt->llevel) &&
> +	    addr < hmm_pt_level_end(pt, iter->cur, pt->llevel))
> +		return hmm_pt_iter_ptdp(iter, pt, addr);
> +
> +	/* First unprotect any directory that do not cover the address. */
> +	for (i = pt->llevel; i >= 1; --i) {
> +		if (!iter->ptd[i - 1])
> +			continue;
> +		if (addr >= hmm_pt_level_start(pt, iter->cur, i) &&
> +		    addr < hmm_pt_level_end(pt, iter->cur, i))
> +			break;
> +		hmm_pt_iter_unprotect_directory(iter, pt, i);
> +	}
> +
> +	/* Walk down to last level of the directory tree. */
> +	for (; i < pt->llevel; ++i) {
> +		struct page *ptd;
> +		dma_addr_t pte, *ptdp;
> +
> +		rcu_read_lock();
> +		ptdp = i ? iter->ptdp[i - 1] : pt->pgd;
> +		pte = ACCESS_ONCE(ptdp[hmm_pt_index(pt, addr, i)]);
> +		if (!(pte & HMM_PTE_VALID)) {
> +			rcu_read_unlock();
> +			return NULL;
> +		}
> +		ptd = pfn_to_page(hmm_pte_pfn(pte));
> +		/* RCU read unlock inside hmm_pt_iter_protect_directory(). */
> +		if (hmm_pt_iter_protect_directory(iter, ptd, addr, i + 1) != 1)
> +			return NULL;
> +	}
> +
> +	return hmm_pt_iter_ptdp(iter, pt, addr);
> +}
> +EXPORT_SYMBOL(hmm_pt_iter_update);
> +
> +dma_addr_t *hmm_pt_iter_fault(struct hmm_pt_iter *iter,
> +			      struct hmm_pt *pt,
> +			      unsigned long addr)
> +{
> +	dma_addr_t *ptdp = hmm_pt_iter_update(iter, pt, addr);
> +	struct page *new = NULL;
> +	int i;
> +
> +	if (ptdp)
> +		return ptdp;
> +
> +	/* Populate directory tree structures. */
> +	for (i = 1; i <= pt->llevel; ++i) {
> +		struct page *upper_ptd;
> +		dma_addr_t *upper_ptdp;
> +
> +		if (iter->ptd[i - 1])
> +			continue;
> +
> +		new = new ? new : alloc_page(GFP_HIGHUSER | __GFP_ZERO);
> +		if (!new)
> +			return NULL;
> +
> +		upper_ptd = i > 1 ? iter->ptd[i - 2] : NULL;
> +		upper_ptdp = i > 1 ? iter->ptdp[i - 2] : pt->pgd;
> +		upper_ptdp = &upper_ptdp[hmm_pt_index(pt, addr, i - 1)];
> +		hmm_pt_directory_lock(pt, upper_ptd, i - 1);
> +		if (((*upper_ptdp) & HMM_PTE_VALID)) {
> +			struct page *ptd;
> +
> +			ptd = pfn_to_page(hmm_pte_pfn(*upper_ptdp));
> +			if (atomic_inc_not_zero(&ptd->_mapcount)) {
> +				/* Already allocated by another thread. */
> +				iter->ptd[i - 1] = ptd;
> +				hmm_pt_directory_unlock(pt, upper_ptd, i - 1);
> +				iter->ptdp[i - 1] = kmap(ptd);
> +				iter->cur = hmm_pt_level_start(pt, addr, i);
> +				continue;
> +			}
> +			/*
> +			 * Means we raced with removal of dead directory it is
> +			 * safe to overwritte *upper_ptdp entry with new entry.
> +			 */
> +		}
> +		/* Initialize struct page field for the directory. */
> +		atomic_set(&new->_mapcount, 1);
> +#if USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS
> +		spin_lock_init(&new->ptl);
> +#endif
> +		*upper_ptdp = hmm_pte_from_pfn(page_to_pfn(new));
> +		hmm_pt_iter_directory_ref(iter, i - 1);
> +		/* Unlock upper directory and map the new directory. */
> +		hmm_pt_directory_unlock(pt, upper_ptd, i - 1);
> +		iter->ptd[i - 1] = new;
> +		iter->ptdp[i - 1] = kmap(new);
> +		iter->cur = hmm_pt_level_start(pt, addr, i);
> +		new = NULL;
> +	}
> +	if (new)
> +		__free_page(new);
> +	return hmm_pt_iter_ptdp(iter, pt, addr);
> +}
> +
> +/* hmm_pt_iter_fini() - finalize iterator.
> + *
> + * @iter: Iterator states.
> + * @pt: HMM page table.
> + *
> + * This function will cleanup iterator by unmapping and unreferencing any
> + * directory still mapped and referenced. It will also free any dead directory.
> + */
> +void hmm_pt_iter_fini(struct hmm_pt_iter *iter, struct hmm_pt *pt)
> +{
> +	struct page *ptd, *tmp;
> +	unsigned i;
> +
> +	for (i = pt->llevel; i >= 1; --i) {
> +		if (!iter->ptd[i - 1])
> +			continue;
> +		hmm_pt_iter_unprotect_directory(iter, pt, i);
> +	}
> +
> +	/* Avoid useless synchronize_rcu() if there is no directory to free. */
> +	if (list_empty(&iter->dead_directories))
> +		return;
> +
> +	/*
> +	 * Some iterator may have dereferenced a dead directory entry and looked
> +	 * up the struct page but haven't check yet the reference count. As all
> +	 * the above happen in rcu read critical section we know that we need
> +	 * to wait for grace period before being able to free any of the dead
> +	 * directory page.
> +	 */
> +	synchronize_rcu();
> +	list_for_each_entry_safe(ptd, tmp, &iter->dead_directories, lru) {
> +		list_del(&ptd->lru);
> +		atomic_set(&ptd->_mapcount, -1);
> +		__free_page(ptd);
> +	}
> +}
> +EXPORT_SYMBOL(hmm_pt_iter_fini);
> -- 
> 1.9.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
