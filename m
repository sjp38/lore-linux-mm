Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C57356B0261
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 03:42:40 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id r196so16791226itc.4
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 00:42:40 -0800 (PST)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id r102si10765962ioe.79.2017.12.05.00.42.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 00:42:35 -0800 (PST)
Subject: Re: [PATCH] dax: fix potential overflow on 32bit machine
References: <20171205033210.38338-1-yi.zhang@huawei.com>
 <20171205052407.GA20757@bombadil.infradead.org>
From: "zhangyi (F)" <yi.zhang@huawei.com>
Message-ID: <f2c991bd-559c-6e06-123d-20790db6621c@huawei.com>
Date: Tue, 5 Dec 2017 16:40:01 +0800
MIME-Version: 1.0
In-Reply-To: <20171205052407.GA20757@bombadil.infradead.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, viro@zeniv.linux.org.uk, miaoxie@huawei.com

On 2017/12/5 13:24, Matthew Wilcox Wrote:
> On Tue, Dec 05, 2017 at 11:32:10AM +0800, zhangyi (F) wrote:
>> On 32bit machine, when mmap2 a large enough file with pgoff more than
>> ULONG_MAX >> PAGE_SHIFT, it will trigger offset overflow and lead to
>> unmap the wrong page in dax_insert_mapping_entry(). This patch cast
>> pgoff to 64bit to prevent the overflow.
> 
> You're quite correct, and you've solved this problem the same way as the
> other half-dozen users in the kernel with the problem, so good job.
> 
> I think we can do better though.  How does this look?

Yes, It looks better to me. I notice that unmap_mapping_range() have
an empty instance in nommu.c for the no mmu machine, do we need another
unmap_mapping_pages() too ? Not test it.

Thanks,
Yi.

>>From 9f8f30197eba970c82eea909624299c86b2c5f7e Mon Sep 17 00:00:00 2001
> From: Matthew Wilcox <mawilcox@microsoft.com>
> Date: Tue, 5 Dec 2017 00:15:54 -0500
> Subject: [PATCH] mm: Add unmap_mapping_pages
> 
> Several users of unmap_mapping_range() would much prefer to express
> their range in pages rather than bytes.  This leads to four places
> in the current tree where there are bugs on 32-bit kernels because of
> missing casts.
> 
> Conveniently, unmap_mapping_range() actually converts from bytes into
> pages, so hoist the guts of unmap_mapping_range() into a new function
> unmap_mapping_pages() and convert the callers.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Reported-by: "zhangyi (F)" <yi.zhang@huawei.com>
> ---
>  fs/dax.c           | 19 ++++++-------------
>  include/linux/mm.h |  2 ++
>  mm/khugepaged.c    |  3 +--
>  mm/memory.c        | 41 +++++++++++++++++++++++++++++------------
>  mm/truncate.c      | 23 +++++++----------------
>  5 files changed, 45 insertions(+), 43 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 95981591977a..6dd481f8216c 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -44,6 +44,7 @@
>  
>  /* The 'colour' (ie low bits) within a PMD of a page offset.  */
>  #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
> +#define PG_PMD_NR	(PMD_SIZE >> PAGE_SHIFT)
>  
>  static wait_queue_head_t wait_table[DAX_WAIT_TABLE_ENTRIES];
>  
> @@ -375,8 +376,8 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
>  		 * unmapped.
>  		 */
>  		if (pmd_downgrade && dax_is_zero_entry(entry))
> -			unmap_mapping_range(mapping,
> -				(index << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
> +			unmap_mapping_pages(mapping, index & ~PG_PMD_COLOUR,
> +							PG_PMD_NR, 0);
>  
>  		err = radix_tree_preload(
>  				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
> @@ -538,12 +539,10 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
>  	if (dax_is_zero_entry(entry) && !(flags & RADIX_DAX_ZERO_PAGE)) {
>  		/* we are replacing a zero page with block mapping */
>  		if (dax_is_pmd_entry(entry))
> -			unmap_mapping_range(mapping,
> -					(vmf->pgoff << PAGE_SHIFT) & PMD_MASK,
> -					PMD_SIZE, 0);
> +			unmap_mapping_pages(mapping, vmf->pgoff & PG_PMD_COLOUR,
> +							PG_PMD_NR, 0);
>  		else /* pte entry */
> -			unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
> -					PAGE_SIZE, 0);
> +			unmap_mapping_pages(mapping, vmf->pgoff, 1, 0);
>  	}
>  
>  	spin_lock_irq(&mapping->tree_lock);
> @@ -1269,12 +1268,6 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
>  }
>  
>  #ifdef CONFIG_FS_DAX_PMD
> -/*
> - * The 'colour' (ie low bits) within a PMD of a page offset.  This comes up
> - * more often than one might expect in the below functions.
> - */
> -#define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
> -
>  static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
>  		void *entry)
>  {
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ee073146aaa7..0fa4b2d826fa 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1311,6 +1311,8 @@ void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
>  		unsigned long end, unsigned long floor, unsigned long ceiling);
>  int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
>  			struct vm_area_struct *vma);
> +void unmap_mapping_pages(struct address_space *mapping,
> +		pgoff_t start, pgoff_t nr, bool even_cows);
>  void unmap_mapping_range(struct address_space *mapping,
>  		loff_t const holebegin, loff_t const holelen, int even_cows);
>  int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index ea4ff259b671..431b4051b46c 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1399,8 +1399,7 @@ static void collapse_shmem(struct mm_struct *mm,
>  		}
>  
>  		if (page_mapped(page))
> -			unmap_mapping_range(mapping, index << PAGE_SHIFT,
> -					PAGE_SIZE, 0);
> +			unmap_mapping_pages(mapping, index, 1, 0);
>  
>  		spin_lock_irq(&mapping->tree_lock);
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 85e7a87da79f..88aad8784421 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2791,9 +2791,36 @@ static inline void unmap_mapping_range_tree(struct rb_root_cached *root,
>  	}
>  }
>  
> +/**
> + * unmap_mapping_pages() - Unmap pages from processes.
> + * @mapping: The address space containing pages to be unmapped.
> + * @start: Index of first page to be unmapped.
> + * @nr: Number of pages to be unmapped.  0 to unmap to end of file.
> + * @even_cows: Whether to unmap even private COWed pages.
> + *
> + * Unmap the pages in this address space from any userspace process which
> + * has them mmaped.
> + */
> +void unmap_mapping_pages(struct address_space *mapping, pgoff_t start,
> +		pgoff_t nr, bool even_cows)
> +{
> +	struct zap_details details = { };
> +
> +	details.check_mapping = even_cows ? NULL : mapping;
> +	details.first_index = start;
> +	details.last_index = start + nr - 1;
> +	if (details.last_index < details.first_index)
> +		details.last_index = ULONG_MAX;
> +
> +	i_mmap_lock_write(mapping);
> +	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root)))
> +		unmap_mapping_range_tree(&mapping->i_mmap, &details);
> +	i_mmap_unlock_write(mapping);
> +}
> +
>  /**
>   * unmap_mapping_range - unmap the portion of all mmaps in the specified
> - * address_space corresponding to the specified page range in the underlying
> + * address_space corresponding to the specified byte range in the underlying
>   * file.
>   *
>   * @mapping: the address space containing mmaps to be unmapped.
> @@ -2811,7 +2838,6 @@ static inline void unmap_mapping_range_tree(struct rb_root_cached *root,
>  void unmap_mapping_range(struct address_space *mapping,
>  		loff_t const holebegin, loff_t const holelen, int even_cows)
>  {
> -	struct zap_details details = { };
>  	pgoff_t hba = holebegin >> PAGE_SHIFT;
>  	pgoff_t hlen = (holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
>  
> @@ -2823,16 +2849,7 @@ void unmap_mapping_range(struct address_space *mapping,
>  			hlen = ULONG_MAX - hba + 1;
>  	}
>  
> -	details.check_mapping = even_cows ? NULL : mapping;
> -	details.first_index = hba;
> -	details.last_index = hba + hlen - 1;
> -	if (details.last_index < details.first_index)
> -		details.last_index = ULONG_MAX;
> -
> -	i_mmap_lock_write(mapping);
> -	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root)))
> -		unmap_mapping_range_tree(&mapping->i_mmap, &details);
> -	i_mmap_unlock_write(mapping);
> +	unmap_mapping_pages(mapping, hba, hlen, even_cows);
>  }
>  EXPORT_SYMBOL(unmap_mapping_range);
>  
> diff --git a/mm/truncate.c b/mm/truncate.c
> index e4b4cf0f4070..55dd8e1b1564 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -179,12 +179,8 @@ static void
>  truncate_cleanup_page(struct address_space *mapping, struct page *page)
>  {
>  	if (page_mapped(page)) {
> -		loff_t holelen;
> -
> -		holelen = PageTransHuge(page) ? HPAGE_PMD_SIZE : PAGE_SIZE;
> -		unmap_mapping_range(mapping,
> -				   (loff_t)page->index << PAGE_SHIFT,
> -				   holelen, 0);
> +		pgoff_t nr = PageTransHuge(page) ? HPAGE_PMD_NR : 1;
> +		unmap_mapping_pages(mapping, page->index, nr, 0);
>  	}
>  
>  	if (page_has_private(page))
> @@ -715,19 +711,15 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
>  					/*
>  					 * Zap the rest of the file in one hit.
>  					 */
> -					unmap_mapping_range(mapping,
> -					   (loff_t)index << PAGE_SHIFT,
> -					   (loff_t)(1 + end - index)
> -							 << PAGE_SHIFT,
> -							 0);
> +					unmap_mapping_pages(mapping, index,
> +							(1 + end - index), 0);
>  					did_range_unmap = 1;
>  				} else {
>  					/*
>  					 * Just zap this page
>  					 */
> -					unmap_mapping_range(mapping,
> -					   (loff_t)index << PAGE_SHIFT,
> -					   PAGE_SIZE, 0);
> +					unmap_mapping_pages(mapping, index,
> +							1, 0);
>  				}
>  			}
>  			BUG_ON(page_mapped(page));
> @@ -753,8 +745,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
>  	 * get remapped later.
>  	 */
>  	if (dax_mapping(mapping)) {
> -		unmap_mapping_range(mapping, (loff_t)start << PAGE_SHIFT,
> -				    (loff_t)(end - start + 1) << PAGE_SHIFT, 0);
> +		unmap_mapping_pages(mapping, start, end - start + 1, 0);
>  	}
>  out:
>  	cleancache_invalidate_inode(mapping);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
