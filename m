Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6016B030A
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 02:45:43 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so187668237pgq.7
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 23:45:43 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a187si2059885pge.103.2016.11.16.23.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 23:45:41 -0800 (PST)
Date: Thu, 17 Nov 2016 15:45:38 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH] mremap: fix race between mremap() and page cleanning
Message-ID: <20161117074538.GA1713@aaronlu.sh.intel.com>
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
Content-Disposition: inline
In-Reply-To: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

+LKML.

Also attached the kernel patch that enlarges the race window and the
user space test code raceremap.c, which you can put in will-it-scale's
tests directory and run it as:
# ./raceremap_threads -t 2 -s 1

Make sure "cpu0 runs" appeared in the first line.

If you get SEGFAULT:
[aaron@aaronlu will-it-scale]$ sudo ./raceremap_threads -t 2 -s 1
cpu0 runs
cpu1 runs
cpu0: going to remap
testcase:mremap
warmup
cpu1: going to clean the page
cpu1: going to write 2
min:0 max:0 total:0
min:0 max:0 total:0
cpu0: remap done
Segmentation fault

That means the race doesn't occur.

If you get "*cpu1 wrote 2 gets lost":
[aaron@aaronlu will-it-scale]$ sudo ./raceremap_threads -t 2 -s 1
cpu1 runs
testcase:mremap
warmup
cpu0 runs
cpu0: going to remap
cpu1: going to clean the page
cpu1: going to write 2
cpu1 wrote 2
min:0 max:0 total:0
min:0 max:0 total:0
cpu0: remap done
*cpu1 wrote 2 gets lost

That means the race occurred.

Thanks,
Aaron

On Thu, Nov 10, 2016 at 05:16:33PM +0800, Aaron Lu wrote:
> Prior to 3.15, there was a race between zap_pte_range() and
> page_mkclean() where writes to a page could be lost.  Dave Hansen
> discovered by inspection that there is a similar race between
> move_ptes() and  page_mkclean().
> 
> We've been able to reproduce the issue by enlarging the race window with
> a msleep(), but have not been able to hit it without modifying the code.
> So, we think it's a real issue, but is difficult or impossible to hit
> in practice.
> 
> The zap_pte_range() issue is fixed by commit 1cf35d47712d("mm: split
> 'tlb_flush_mmu()' into tlb flushing and memory freeing parts"). And
> this patch is to fix the race between page_mkclean() and mremap().
> 
> Here is one possible way to hit the race: suppose a process mmapped a
> file with READ | WRITE and SHARED, it has two threads and they are bound
> to 2 different CPUs, e.g. CPU1 and CPU2. mmap returned X, then thread 1
> did a write to addr X so that CPU1 now has a writable TLB for addr X
> on it. Thread 2 starts mremaping from addr X to Y while thread 1 cleaned
> the page and then did another write to the old addr X again. The 2nd
> write from thread 1 could succeed but the value will get lost.
> 
>         thread 1                           thread 2
>      (bound to CPU1)                    (bound to CPU2)
> 
>   1: write 1 to addr X to get a
>      writeable TLB on this CPU
> 
>                                         2: mremap starts
> 
>                                         3: move_ptes emptied PTE for addr X
>                                            and setup new PTE for addr Y and
>                                            then dropped PTL for X and Y
> 
>   4: page laundering for N by doing
>      fadvise FADV_DONTNEED. When done,
>      pageframe N is deemed clean.
> 
>   5: *write 2 to addr X
> 
>                                         6: tlb flush for addr X
> 
>   7: munmap (Y, pagesize) to make the
>      page unmapped
> 
>   8: fadvise with FADV_DONTNEED again
>      to kick the page off the pagecache
> 
>   9: pread the page from file to verify
>      the value. If 1 is there, it means
>      we have lost the written 2.
> 
>   *the write may or may not cause segmentation fault, it depends on
>   if the TLB is still on the CPU.
> 
> Please note that this is only one specific way of how the race could
> occur, it didn't mean that the race could only occur in exact the above
> config, e.g. more than 2 threads could be involved and fadvise() could
> be done in another thread, etc.
> 
> For anonymous pages, they could race between mremap() and page reclaim:
> THP: a huge PMD is moved by mremap to a new huge PMD, then the new huge PMD
> gets unmapped/splitted/pagedout before the flush tlb happened for the old
> huge PMD in move_page_tables() and we could still write data to it.
> The normal anonymous page has similar situation.
> 
> To fix this, check for any dirty PTE in move_ptes()/move_huge_pmd() and
> if any, did the flush before dropping the PTL. If we did the flush for
> every move_ptes()/move_huge_pmd() call then we do not need to do the
> flush in move_pages_tables() for the whole range. But if we didn't, we
> still need to do the whole range flush.
> 
> Alternatively, we can track which part of the range is flushed in
> move_ptes()/move_huge_pmd() and which didn't to avoid flushing the whole
> range in move_page_tables(). But that would require multiple tlb flushes
> for the different sub-ranges and should be less efficient than the
> single whole range flush.
> 
> KBuild test on my Sandybridge desktop doesn't show any noticeable change.
> v4.9-rc4:
> real    5m14.048s
> user    32m19.800s
> sys     4m50.320s
> 
> With this commit:
> real    5m13.888s
> user    32m19.330s
> sys     4m51.200s
> 
> Reported-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> ---
>  include/linux/huge_mm.h |  2 +-
>  mm/huge_memory.c        |  9 ++++++++-
>  mm/mremap.c             | 30 +++++++++++++++++++++---------
>  3 files changed, 30 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 9b9f65d99873..e35e6de633b9 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -22,7 +22,7 @@ extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  			unsigned char *vec);
>  extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
>  			 unsigned long new_addr, unsigned long old_end,
> -			 pmd_t *old_pmd, pmd_t *new_pmd);
> +			 pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush);
>  extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  			unsigned long addr, pgprot_t newprot,
>  			int prot_numa);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index cdcd25cb30fe..eff3de359d50 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1426,11 +1426,12 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  
>  bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
>  		  unsigned long new_addr, unsigned long old_end,
> -		  pmd_t *old_pmd, pmd_t *new_pmd)
> +		  pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush)
>  {
>  	spinlock_t *old_ptl, *new_ptl;
>  	pmd_t pmd;
>  	struct mm_struct *mm = vma->vm_mm;
> +	bool force_flush = false;
>  
>  	if ((old_addr & ~HPAGE_PMD_MASK) ||
>  	    (new_addr & ~HPAGE_PMD_MASK) ||
> @@ -1455,6 +1456,8 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
>  		new_ptl = pmd_lockptr(mm, new_pmd);
>  		if (new_ptl != old_ptl)
>  			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
> +		if (pmd_present(*old_pmd) && pmd_dirty(*old_pmd))
> +			force_flush = true;
>  		pmd = pmdp_huge_get_and_clear(mm, old_addr, old_pmd);
>  		VM_BUG_ON(!pmd_none(*new_pmd));
>  
> @@ -1467,6 +1470,10 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
>  		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
>  		if (new_ptl != old_ptl)
>  			spin_unlock(new_ptl);
> +		if (force_flush)
> +			flush_tlb_range(vma, old_addr, old_addr + PMD_SIZE);
> +		else
> +			*need_flush = true;
>  		spin_unlock(old_ptl);
>  		return true;
>  	}
> diff --git a/mm/mremap.c b/mm/mremap.c
> index da22ad2a5678..6ccecc03f56a 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -104,11 +104,13 @@ static pte_t move_soft_dirty_pte(pte_t pte)
>  static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
>  		unsigned long old_addr, unsigned long old_end,
>  		struct vm_area_struct *new_vma, pmd_t *new_pmd,
> -		unsigned long new_addr, bool need_rmap_locks)
> +		unsigned long new_addr, bool need_rmap_locks, bool *need_flush)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	pte_t *old_pte, *new_pte, pte;
>  	spinlock_t *old_ptl, *new_ptl;
> +	bool force_flush = false;
> +	unsigned long len = old_end - old_addr;
>  
>  	/*
>  	 * When need_rmap_locks is true, we take the i_mmap_rwsem and anon_vma
> @@ -146,6 +148,14 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
>  				   new_pte++, new_addr += PAGE_SIZE) {
>  		if (pte_none(*old_pte))
>  			continue;
> +
> +		/*
> +		 * We are remapping a dirty PTE, make sure to
> +		 * flush TLB before we drop the PTL for the
> +		 * old PTE or we may race with page_mkclean().
> +		 */
> +		if (pte_present(*old_pte) && pte_dirty(*old_pte))
> +			force_flush = true;
>  		pte = ptep_get_and_clear(mm, old_addr, old_pte);
>  		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
>  		pte = move_soft_dirty_pte(pte);
> @@ -156,6 +166,10 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
>  	if (new_ptl != old_ptl)
>  		spin_unlock(new_ptl);
>  	pte_unmap(new_pte - 1);
> +	if (force_flush)
> +		flush_tlb_range(vma, old_end - len, old_end);
> +	else
> +		*need_flush = true;
>  	pte_unmap_unlock(old_pte - 1, old_ptl);
>  	if (need_rmap_locks)
>  		drop_rmap_locks(vma);
> @@ -201,13 +215,12 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  				if (need_rmap_locks)
>  					take_rmap_locks(vma);
>  				moved = move_huge_pmd(vma, old_addr, new_addr,
> -						    old_end, old_pmd, new_pmd);
> +						    old_end, old_pmd, new_pmd,
> +						    &need_flush);
>  				if (need_rmap_locks)
>  					drop_rmap_locks(vma);
> -				if (moved) {
> -					need_flush = true;
> +				if (moved)
>  					continue;
> -				}
>  			}
>  			split_huge_pmd(vma, old_pmd, old_addr);
>  			if (pmd_trans_unstable(old_pmd))
> @@ -220,11 +233,10 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  			extent = next - new_addr;
>  		if (extent > LATENCY_LIMIT)
>  			extent = LATENCY_LIMIT;
> -		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
> -			  new_vma, new_pmd, new_addr, need_rmap_locks);
> -		need_flush = true;
> +		move_ptes(vma, old_pmd, old_addr, old_addr + extent, new_vma,
> +			  new_pmd, new_addr, need_rmap_locks, &need_flush);
>  	}
> -	if (likely(need_flush))
> +	if (need_flush)
>  		flush_tlb_range(vma, old_end-len, old_addr);
>  
>  	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
> -- 
> 2.5.5
> 

--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-mremap-add-a-2s-delay-for-MAP_FIXED-case.patch"


--AqsLC8rIMeq19msA--
