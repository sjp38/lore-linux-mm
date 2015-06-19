Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 51A456B0085
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 22:06:21 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so73969338pac.2
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 19:06:21 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id vt3si13751948pbc.189.2015.06.18.19.06.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Jun 2015 19:06:20 -0700 (PDT)
Date: Thu, 18 Jun 2015 19:06:08 -0700
From: Mark Hairgrove <mhairgrove@nvidia.com>
Subject: Re: [PATCH 06/36] HMM: add HMM page table v2.
In-Reply-To: <1432236705-4209-7-git-send-email-j.glisse@gmail.com>
Message-ID: <alpine.DEB.2.00.1506171724110.32592@mdh-linux64-2.nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-7-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="8323329-1726233351-1434679578=:32592"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "j.glisse@gmail.com" <j.glisse@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

--8323329-1726233351-1434679578=:32592
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT



On Thu, 21 May 2015, j.glisse@gmail.com wrote:

> From: JA(C)rA'me Glisse <jglisse@redhat.com>
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

s/clause/close

> such as spinlock embedded in struct page.
> 
> Changed since v1:
>   - Use PAGE_SHIFT as shift value to reserve low bit for private device
>     specific flags. This is to allow device driver to use and some of the
>     lower bits for their own device specific purpose.
>   - Add set of helper for atomically clear, setting and testing bit on
>     dma_addr_t pointer. Atomicity being usefull only for dirty bit.
>   - Differentiate btw DMA mapped entry and non mapped entry (pfn).
>   - Split page directory entry and page table entry helpers.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
> ---
>  MAINTAINERS            |   2 +
>  include/linux/hmm_pt.h | 380 +++++++++++++++++++++++++++++++++++++++++++
>  mm/Makefile            |   2 +-
>  mm/hmm_pt.c            | 425 +++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 808 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/hmm_pt.h
>  create mode 100644 mm/hmm_pt.c
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 2f2a2be..8cd0aa7 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4736,6 +4736,8 @@ L:	linux-mm@kvack.org
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
> index 0000000..330edb2
> --- /dev/null
> +++ b/include/linux/hmm_pt.h
> @@ -0,0 +1,380 @@
> +/*
> [...]
> +
> +static inline dma_addr_t hmm_pde_from_pfn(dma_addr_t pfn)
> +{
> +	return (pfn << PAGE_SHIFT) | HMM_PDE_VALID;
> +}
> +
> +static inline unsigned long hmm_pde_pfn(dma_addr_t pde)
> +{
> +	return (pde & HMM_PDE_VALID) ? pde >> PAGE_SHIFT : 0;
> +}
> +

Does hmm_pde_pfn return a dma_addr_t pfn or a system memory pfn?

The types between these two functions don't match. According to 
hmm_pde_from_pfn, both the pde and the pfn are supposed to be dma_addr_t. 
But hmm_pde_pfn returns an unsigned long as a pfn instead of a dma_addr_t. 
If hmm_pde_pfn sometimes used to get a dma_addr_t pfn then shouldn't it 
also return a dma_addr_t, since as you pointed out in the commit message, 
dma_addr_t might be bigger than an unsigned long?

> [...]
> +
> +static inline dma_addr_t hmm_pte_from_pfn(dma_addr_t pfn)
> +{
> +	return (pfn << PAGE_SHIFT) | (1 << HMM_PTE_VALID_PFN_BIT);
> +}
> +
> +static inline unsigned long hmm_pte_pfn(dma_addr_t pte)
> +{
> +	return hmm_pte_test_valid_pfn(&pte) ? pte >> PAGE_SHIFT : 0;
> +}

Same question as hmm_pde_pfn above.


> [...]
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

These are sized to be HMM_PT_MAX_LEVEL - 1 rather than HMM_PT_MAX_LEVEL 
because the iterator doesn't store the top level, correct? This results in 
a lot of "level - 1" and "level - 2" logic when dealing with the iterator. 
Have you considered keeping the levels consistent to get rid of all the 
extra offset-by-1 logic?

> +	struct list_head	dead_directories;
> +	unsigned long		cur;
> +};
> [...]
> +
> +/* hmm_pt_protect_directory_unref() - reference a directory.

s/unref/ref

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
> [...]
> +
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

This example should say that hmm_pt.last == (1 << 48) - 1, since last is 
inclusive. Otherwise llevel will be 4.

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

Does this need to be EXPORT_SYMBOL? It seems like a driver would never 
need to call this, only core hmm. Same question for hmm_pt_fini.


> [...]
> +
> +/* hmm_pt_init() - initialize iterator states.

This should say hmm_pt_iter_init.

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

The memset sizes can simply be sizeof(iter->ptd) and sizeof(iter->ptdp).

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
> +	if (hmm_pde_pfn(*upper_ptdp) == page_to_pfn(iter->ptd[level - 1]))
> +		*upper_ptdp = 0;
> +	hmm_pt_directory_unlock(pt, upper_ptd, level - 1);
> +
> +	/* Add it to delayed free list. */
> +	list_add_tail(&iter->ptd[level - 1]->lru, &iter->dead_directories);
> +
> +	/*
> +	 * The upper directory is not safe to unref as we have an extra ref and

This should be "IS safe to unref", correct?

> +	 * thus refcount should not reach 0.
> +	 */
> +	hmm_pt_iter_directory_unref(iter, level - 1);
> +}
> [...]
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

If I'm following this correctly, a migrate to the device will allocate HMM 
page tables and the subsequent migrate from the device will free them. 
Assuming that's the case, might thrashing of page allocations be a 
problem? What about keeping the HMM page tables around until the actual 
munmap() of the corresponding VA range?
--8323329-1726233351-1434679578=:32592--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
