Date: Sun, 22 Feb 2004 15:39:11 -0800
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040222233911.GB1311@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20040216190927.GA2969@us.ibm.com> <200402201800.12077.phillips@arcor.de> <20040220161738.GF1269@us.ibm.com> <200402211400.16779.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200402211400.16779.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello, Dan,

How about the following?

EXPORT_SYMBOL(invalidate_filemap_range);

						Thanx, Paul

On Sat, Feb 21, 2004 at 02:00:16PM -0500, Daniel Phillips wrote:
> Hi Paul et al,
> 
> Here is an updated patch.  The name of the exported function is changed to
> "invalidate_filemap_range" to reflect the fact that only file-backed pages are
> invalidated, and to distinguish the three parameter flavour from the four
> parameter version called from vmtruncate.  The inner loop in zap_pte_range is
> hopefully correct now.
> 
> While I'm in here, why is the assignment "pte =" at line 411 of memory.c not
> redundant?
> 
>    http://lxr.linux.no/source/mm/memory.c?v=2.6.1#L411
> 
> As far as I can see, the ->filemap spinlock protects the pte from modification
> and pte was already assigned at line 405.
> 
> Anyway, we can now see that the full cost of this DFS-specific feature in the inner
> loop is a single (unlikely) branch.
> 
> I'll repeat my proposition here: providing local filesystem semantics for
> MAP_PRIVATE on any distributed filesystem requires these decorations on the
> unmap path.  Though there is no benefit for local filesystems, the cost is
> insignificant.
> 
> Regards,
> 
> Daniel
> 
> --- 2.6.3.clean/include/linux/mm.h	2004-02-17 22:57:13.000000000 -0500
> +++ 2.6.3/include/linux/mm.h	2004-02-21 12:59:16.000000000 -0500
> @@ -430,23 +430,23 @@
>  void shmem_lock(struct file * file, int lock);
>  int shmem_zero_setup(struct vm_area_struct *);
>  
> -void zap_page_range(struct vm_area_struct *vma, unsigned long address,
> -			unsigned long size);
>  int unmap_vmas(struct mmu_gather **tlbp, struct mm_struct *mm,
>  		struct vm_area_struct *start_vma, unsigned long start_addr,
> -		unsigned long end_addr, unsigned long *nr_accounted);
> -void unmap_page_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
> -			unsigned long address, unsigned long size);
> +		unsigned long end_addr, unsigned long *nr_accounted, int zap);
>  void clear_page_tables(struct mmu_gather *tlb, unsigned long first, int nr);
>  int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
>  			struct vm_area_struct *vma);
>  int zeromap_page_range(struct vm_area_struct *vma, unsigned long from,
>  			unsigned long size, pgprot_t prot);
> -
> -extern void invalidate_mmap_range(struct address_space *mapping,
> -				  loff_t const holebegin,
> -				  loff_t const holelen);
> +extern void invalidate_filemap_range(struct address_space *mapping, loff_t const start, loff_t const length);
>  extern int vmtruncate(struct inode * inode, loff_t offset);
> +void invalidate_page_range(struct vm_area_struct *vma, unsigned long address, unsigned long size, int all);
> +
> +static inline void zap_page_range(struct vm_area_struct *vma, ulong address, ulong size)
> +{
> +	invalidate_page_range(vma, address, size, 1);
> +}
> +
>  extern pmd_t *FASTCALL(__pmd_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address));
>  extern pte_t *FASTCALL(pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
>  extern pte_t *FASTCALL(pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
> --- 2.6.3.clean/mm/memory.c	2004-02-17 22:57:47.000000000 -0500
> +++ 2.6.3/mm/memory.c	2004-02-21 13:23:36.000000000 -0500
> @@ -384,9 +384,13 @@
>  	return -ENOMEM;
>  }
>  
> -static void
> -zap_pte_range(struct mmu_gather *tlb, pmd_t * pmd,
> -		unsigned long address, unsigned long size)
> +static inline int is_anon(struct page *page)
> +{
> +	return !page->mapping || PageSwapCache(page);
> +}
> +
> +static void zap_pte_range(struct mmu_gather *tlb, pmd_t * pmd,
> +		unsigned long address, unsigned long size, int all)
>  {
>  	unsigned long offset;
>  	pte_t *ptep;
> @@ -409,7 +413,8 @@
>  			continue;
>  		if (pte_present(pte)) {
>  			unsigned long pfn = pte_pfn(pte);
> -
> +			if (unlikely(!all) && is_anon(pfn_to_page(pfn)))
> +				continue;
>  			pte = ptep_get_and_clear(ptep);
>  			tlb_remove_tlb_entry(tlb, ptep, address+offset);
>  			if (pfn_valid(pfn)) {
> @@ -426,7 +431,7 @@
>  				}
>  			}
>  		} else {
> -			if (!pte_file(pte))
> +			if (!pte_file(pte) && all)
>  				free_swap_and_cache(pte_to_swp_entry(pte));
>  			pte_clear(ptep);
>  		}
> @@ -434,9 +439,8 @@
>  	pte_unmap(ptep-1);
>  }
>  
> -static void
> -zap_pmd_range(struct mmu_gather *tlb, pgd_t * dir,
> -		unsigned long address, unsigned long size)
> +static void zap_pmd_range(struct mmu_gather *tlb, pgd_t * dir,
> +		unsigned long address, unsigned long size, int all)
>  {
>  	pmd_t * pmd;
>  	unsigned long end;
> @@ -453,14 +457,14 @@
>  	if (end > ((address + PGDIR_SIZE) & PGDIR_MASK))
>  		end = ((address + PGDIR_SIZE) & PGDIR_MASK);
>  	do {
> -		zap_pte_range(tlb, pmd, address, end - address);
> -		address = (address + PMD_SIZE) & PMD_MASK; 
> +		zap_pte_range(tlb, pmd, address, end - address, all);
> +		address = (address + PMD_SIZE) & PMD_MASK;
>  		pmd++;
>  	} while (address < end);
>  }
>  
> -void unmap_page_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
> -			unsigned long address, unsigned long end)
> +static void unmap_page_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
> +		unsigned long address, unsigned long end, int all)
>  {
>  	pgd_t * dir;
>  
> @@ -474,7 +478,7 @@
>  	dir = pgd_offset(vma->vm_mm, address);
>  	tlb_start_vma(tlb, vma);
>  	do {
> -		zap_pmd_range(tlb, dir, address, end - address);
> +		zap_pmd_range(tlb, dir, address, end - address, all);
>  		address = (address + PGDIR_SIZE) & PGDIR_MASK;
>  		dir++;
>  	} while (address && (address < end));
> @@ -524,7 +528,7 @@
>   */
>  int unmap_vmas(struct mmu_gather **tlbp, struct mm_struct *mm,
>  		struct vm_area_struct *vma, unsigned long start_addr,
> -		unsigned long end_addr, unsigned long *nr_accounted)
> +		unsigned long end_addr, unsigned long *nr_accounted, int all)
>  {
>  	unsigned long zap_bytes = ZAP_BLOCK_SIZE;
>  	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
> @@ -568,7 +572,7 @@
>  				tlb_start_valid = 1;
>  			}
>  
> -			unmap_page_range(*tlbp, vma, start, start + block);
> +			unmap_page_range(*tlbp, vma, start, start + block, all);
>  			start += block;
>  			zap_bytes -= block;
>  			if ((long)zap_bytes > 0)
> @@ -594,8 +598,8 @@
>   * @address: starting address of pages to zap
>   * @size: number of bytes to zap
>   */
> -void zap_page_range(struct vm_area_struct *vma,
> -			unsigned long address, unsigned long size)
> +void invalidate_page_range(struct vm_area_struct *vma,
> +		unsigned long address, unsigned long size, int all)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	struct mmu_gather *tlb;
> @@ -612,7 +616,7 @@
>  	lru_add_drain();
>  	spin_lock(&mm->page_table_lock);
>  	tlb = tlb_gather_mmu(mm, 0);
> -	unmap_vmas(&tlb, mm, vma, address, end, &nr_accounted);
> +	unmap_vmas(&tlb, mm, vma, address, end, &nr_accounted, all);
>  	tlb_finish_mmu(tlb, address, end);
>  	spin_unlock(&mm->page_table_lock);
>  }
> @@ -1071,10 +1075,8 @@
>   * Both hba and hlen are page numbers in PAGE_SIZE units.
>   * An hlen of zero blows away the entire portion file after hba.
>   */
> -static void
> -invalidate_mmap_range_list(struct list_head *head,
> -			   unsigned long const hba,
> -			   unsigned long const hlen)
> +static void invalidate_mmap_range_list(struct list_head *head,
> +		 unsigned long const hba,  unsigned long const hlen, int all)
>  {
>  	struct list_head *curr;
>  	unsigned long hea;	/* last page of hole. */
> @@ -1095,9 +1097,9 @@
>  		    	continue;	/* Mapping disjoint from hole. */
>  		zba = (hba <= vba) ? vba : hba;
>  		zea = (vea <= hea) ? vea : hea;
> -		zap_page_range(vp,
> +		invalidate_page_range(vp,
>  			       ((zba - vba) << PAGE_SHIFT) + vp->vm_start,
> -			       (zea - zba + 1) << PAGE_SHIFT);
> +			       (zea - zba + 1) << PAGE_SHIFT, all);
>  	}
>  }
>  
> @@ -1115,8 +1117,8 @@
>   * up to a PAGE_SIZE boundary.  A holelen of zero truncates to the
>   * end of the file.
>   */
> -void invalidate_mmap_range(struct address_space *mapping,
> -		      loff_t const holebegin, loff_t const holelen)
> +static void invalidate_mmap_range(struct address_space *mapping,
> +		loff_t const holebegin, loff_t const holelen, int all)
>  {
>  	unsigned long hba = holebegin >> PAGE_SHIFT;
>  	unsigned long hlen = (holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
> @@ -1133,12 +1135,19 @@
>  	/* Protect against page fault */
>  	atomic_inc(&mapping->truncate_count);
>  	if (unlikely(!list_empty(&mapping->i_mmap)))
> -		invalidate_mmap_range_list(&mapping->i_mmap, hba, hlen);
> +		invalidate_mmap_range_list(&mapping->i_mmap, hba, hlen, all);
>  	if (unlikely(!list_empty(&mapping->i_mmap_shared)))
> -		invalidate_mmap_range_list(&mapping->i_mmap_shared, hba, hlen);
> +		invalidate_mmap_range_list(&mapping->i_mmap_shared, hba, hlen, all);
>  	up(&mapping->i_shared_sem);
>  }
> -EXPORT_SYMBOL_GPL(invalidate_mmap_range);
> +
> + void invalidate_filemap_range(struct address_space *mapping,
> +		loff_t const start, loff_t const length)
> +{
> +	invalidate_mmap_range(mapping, start, length, 0);
> +}
> +
> +EXPORT_SYMBOL_GPL(invalidate_filemap_range);
>  
>  /*
>   * Handle all mappings that got truncated by a "truncate()"
> @@ -1156,7 +1165,7 @@
>  	if (inode->i_size < offset)
>  		goto do_expand;
>  	i_size_write(inode, offset);
> -	invalidate_mmap_range(mapping, offset + PAGE_SIZE - 1, 0);
> +	invalidate_mmap_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
>  	truncate_inode_pages(mapping, offset);
>  	goto out_truncate;
>  
> --- 2.6.3.clean/mm/mmap.c	2004-02-17 22:58:32.000000000 -0500
> +++ 2.6.3/mm/mmap.c	2004-02-19 22:46:01.000000000 -0500
> @@ -1134,7 +1134,7 @@
>  
>  	lru_add_drain();
>  	tlb = tlb_gather_mmu(mm, 0);
> -	unmap_vmas(&tlb, mm, vma, start, end, &nr_accounted);
> +	unmap_vmas(&tlb, mm, vma, start, end, &nr_accounted, 1);
>  	vm_unacct_memory(nr_accounted);
>  
>  	if (is_hugepage_only_range(start, end - start))
> @@ -1436,7 +1436,7 @@
>  	flush_cache_mm(mm);
>  	/* Use ~0UL here to ensure all VMAs in the mm are unmapped */
>  	mm->map_count -= unmap_vmas(&tlb, mm, mm->mmap, 0,
> -					~0UL, &nr_accounted);
> +					~0UL, &nr_accounted, 1);
>  	vm_unacct_memory(nr_accounted);
>  	BUG_ON(mm->map_count);	/* This is just debugging */
>  	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
> 
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
