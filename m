Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 109AD6B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 11:25:22 -0400 (EDT)
Date: Fri, 5 Aug 2011 16:25:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] THP: mremap support and TLB optimization #2
Message-ID: <20110805152516.GI9211@csn.ul.ie>
References: <20110728142631.GI3087@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110728142631.GI3087@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Thu, Jul 28, 2011 at 04:26:31PM +0200, Andrea Arcangeli wrote:
> Here are also some benchmarks with a proggy like this:
> 
> ===
> #define _GNU_SOURCE
> #include <sys/mman.h>
> #include <stdlib.h>
> #include <stdio.h>
> #include <string.h>
> #include <sys/time.h>
> 
> #define SIZE (5UL*1024*1024*1024)
> 
> int main()
> {
>         static struct timeval oldstamp, newstamp;
> 	long diffsec;
> 	char *p, *p2, *p3, *p4;
> 	if (posix_memalign((void **)&p, 2*1024*1024, SIZE))
> 		perror("memalign"), exit(1);
> 	if (posix_memalign((void **)&p2, 2*1024*1024, SIZE))
> 		perror("memalign"), exit(1);
> 	if (posix_memalign((void **)&p3, 2*1024*1024, 4096))
> 		perror("memalign"), exit(1);
> 
> 	memset(p, 0xff, SIZE);
> 	memset(p2, 0xff, SIZE);
> 	memset(p3, 0x77, 4096);
> 	gettimeofday(&oldstamp, NULL);
> 	p4 = mremap(p, SIZE, SIZE, MREMAP_FIXED|MREMAP_MAYMOVE, p3);
> 	gettimeofday(&newstamp, NULL);
> 	diffsec = newstamp.tv_sec - oldstamp.tv_sec;
> 	diffsec = newstamp.tv_usec - oldstamp.tv_usec + 1000000 * diffsec;
> 	printf("usec %ld\n", diffsec);
> 	if (p == MAP_FAILED || p4 != p3)
> 	//if (p == MAP_FAILED)
> 		perror("mremap"), exit(1);
> 	if (memcmp(p4, p2, SIZE))
> 		printf("mremap bug\n"), exit(1);
> 	printf("ok\n");
> 
> 	return 0;
> }
> ===
> 
> THP on
> 
>  Performance counter stats for './largepage13' (3 runs):
> 
>           69195836 dTLB-loads                 ( +-   3.546% )  (scaled from 50.30%)
>              60708 dTLB-load-misses           ( +-  11.776% )  (scaled from 52.62%)
>          676266476 dTLB-stores                ( +-   5.654% )  (scaled from 69.54%)
>              29856 dTLB-store-misses          ( +-   4.081% )  (scaled from 89.22%)
>         1055848782 iTLB-loads                 ( +-   4.526% )  (scaled from 80.18%)
>               8689 iTLB-load-misses           ( +-   2.987% )  (scaled from 58.20%)
> 
>         7.314454164  seconds time elapsed   ( +-   0.023% )
> 
> THP off
> 
>  Performance counter stats for './largepage13' (3 runs):
> 
>         1967379311 dTLB-loads                 ( +-   0.506% )  (scaled from 60.59%)
>            9238687 dTLB-load-misses           ( +-  22.547% )  (scaled from 61.87%)
>         2014239444 dTLB-stores                ( +-   0.692% )  (scaled from 60.40%)
>            3312335 dTLB-store-misses          ( +-   7.304% )  (scaled from 67.60%)
>         6764372065 iTLB-loads                 ( +-   0.925% )  (scaled from 79.00%)
>               8202 iTLB-load-misses           ( +-   0.475% )  (scaled from 70.55%)
> 
>         9.693655243  seconds time elapsed   ( +-   0.069% )
> 
> grep thp /proc/vmstat 
> thp_fault_alloc 35849
> thp_fault_fallback 0
> thp_collapse_alloc 3
> thp_collapse_alloc_failed 0
> thp_split 0
> 
> thp_split 0 confirms no thp split despite plenty of hugepages allocated.
> 
> The measurement of only the mremap time (so excluding the 3 long
> memset and final long 10GB memory accessing memcmp):
> 
> THP on
> 
> usec 14824
> usec 14862
> usec 14859
> 
> THP off
> 
> usec 256416
> usec 255981
> usec 255847
> 
> With an older kernel without the mremap optimizations (the below patch
> optimizes the non THP version too).
> 
> THP on
> 
> usec 392107
> usec 390237
> usec 404124
> 
> THP off
> 
> usec 444294
> usec 445237
> usec 445820
> 
> I guess with a threaded program that sends more IPI on large SMP it'd
> create an even larger difference.
> 
> All debug options are off except DEBUG_VM to avoid skewing the
> results.
> 
> The only problem for native 2M mremap like it happens above both the
> source and destination address must be 2M aligned or the hugepmd can't
> be moved without a split.
> 
> Patch follows:
> 
> ===
> Subject: thp: mremap support and TLB optimization
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> This adds THP support to mremap (decreases the number of split_huge_page
> called).
> 
> This also replaces ptep_clear_flush with ptep_get_and_clear and replaces it
> with a final flush_tlb_range to send a single tlb flush IPI instead of one IPI
> for each page.
> 
> It also removes a bogus (even if harmless) "- 1" subtraction in the
> "next" calculation in move_page_tables().
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -22,6 +22,11 @@ extern int zap_huge_pmd(struct mmu_gathe
>  extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  			unsigned long addr, unsigned long end,
>  			unsigned char *vec);
> +extern int move_huge_pmd(struct vm_area_struct *vma,
> +			 struct vm_area_struct *new_vma,
> +			 unsigned long old_addr,
> +			 unsigned long new_addr, unsigned long old_end,
> +			 pmd_t *old_pmd, pmd_t *new_pmd);
>  extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  			unsigned long addr, pgprot_t newprot);
>  
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1054,6 +1054,52 @@ int mincore_huge_pmd(struct vm_area_stru
>  	return ret;
>  }
>  
> +int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
> +		  unsigned long old_addr,
> +		  unsigned long new_addr, unsigned long old_end,
> +		  pmd_t *old_pmd, pmd_t *new_pmd)
> +{
> +	int ret = 0;
> +	pmd_t pmd;
> +
> +	struct mm_struct *mm = vma->vm_mm;
> +
> +	if ((old_addr & ~HPAGE_PMD_MASK) ||
> +	    (new_addr & ~HPAGE_PMD_MASK) ||

How could these conditions ever be true? We are here because it was
pmd_trans_huge. There should be no way this can be aligned. If this
is paranoia, make it a BUG_ON.

> +	    (old_addr + HPAGE_PMD_SIZE) > old_end ||

Again, is this possible? The old addr was already huge.

> +	    new_vma->vm_flags & VM_NOHUGEPAGE)

This makes sense.

> +		goto out;
> +
> +	/*
> +	 * The destination pmd shouldn't be established, free_pgtables()
> +	 * should have release it.
> +	 */
> +	if (!pmd_none(*new_pmd)) {
> +		WARN_ON(1);
> +		VM_BUG_ON(pmd_trans_huge(*new_pmd));
> +		goto out;
> +	}
> +

Agreed that this should never happen. The mmap_sem is held for writing
and we are remapping to what should be empty space. It should not be
possible for a huge PMD to be established underneath us.

> +	spin_lock(&mm->page_table_lock);
> +	if (likely(pmd_trans_huge(*old_pmd))) {
> +		if (pmd_trans_splitting(*old_pmd)) {
> +			spin_unlock(&mm->page_table_lock);
> +			wait_split_huge_page(vma->anon_vma, old_pmd);
> +			ret = -1;
> +		} else {
> +			pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
> +			VM_BUG_ON(!pmd_none(*new_pmd));
> +			set_pmd_at(mm, new_addr, new_pmd, pmd);
> +			spin_unlock(&mm->page_table_lock);
> +			ret = 1;
> +		}
> +	} else
> +		spin_unlock(&mm->page_table_lock);
> +

The meaning of the return values of -1, 0, 1 with the caller doing

if (err)
...
else if (!err)
	...

is tricky to work out. split_huge_page only needs to be called if
returning 0. Would it be possible to have the split_huge_page called in
this function? The end of the function would then look like

return ret;

out_split:
split_huge_page_pmd()
return ret;

with either success or failure being returned instead of a tristate
which is easier to understand.

> +out:
> +	return ret;
> +}
> +
>  int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  		unsigned long addr, pgprot_t newprot)
>  {
> diff --git a/mm/mremap.c b/mm/mremap.c
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -41,8 +41,7 @@ static pmd_t *get_old_pmd(struct mm_stru
>  		return NULL;
>  
>  	pmd = pmd_offset(pud, addr);
> -	split_huge_page_pmd(mm, pmd);
> -	if (pmd_none_or_clear_bad(pmd))
> +	if (pmd_none(*pmd))
>  		return NULL;
>  

Ok, this is changing to pmd_none because it could be a huge PMD and
pmd_none_or_clear_bad triggers on a huge PMD. Right?

>  	return pmd;
> @@ -65,8 +64,6 @@ static pmd_t *alloc_new_pmd(struct mm_st
>  		return NULL;
>  
>  	VM_BUG_ON(pmd_trans_huge(*pmd));
> -	if (pmd_none(*pmd) && __pte_alloc(mm, vma, pmd, addr))
> -		return NULL;
>  
>  	return pmd;
>  }
> @@ -80,11 +77,7 @@ static void move_ptes(struct vm_area_str
>  	struct mm_struct *mm = vma->vm_mm;
>  	pte_t *old_pte, *new_pte, pte;
>  	spinlock_t *old_ptl, *new_ptl;
> -	unsigned long old_start;
>  
> -	old_start = old_addr;
> -	mmu_notifier_invalidate_range_start(vma->vm_mm,
> -					    old_start, old_end);

The MMU notifier is now being called for a larger range. Previously it
would usually be ranges of 64 pages and now it looks like it happens
once for the entire range being remapped. This is not mentioned in
the leader. What are the consequences of having a large gap between
invalidate_start and invalidate_end? Would it be a big deal to call
the MMU notifier within move_huge_pmd()?

If it's safe to use larger ranges, it would be preferable to see it
in a separate patch or at the very least explained in the changelog.

>  	if (vma->vm_file) {
>  		/*
>  		 * Subtle point from Rajesh Venkatasubramanian: before
> @@ -111,7 +104,7 @@ static void move_ptes(struct vm_area_str
>  				   new_pte++, new_addr += PAGE_SIZE) {
>  		if (pte_none(*old_pte))
>  			continue;
> -		pte = ptep_clear_flush(vma, old_addr, old_pte);
> +		pte = ptep_get_and_clear(mm, old_addr, old_pte);

This looks like an unrelated optimisation. You hint at this in the
patch subject but it needs a separate patch or a better explanation in
the leader. If I'm reading this right, it looks like you are deferring
a TLB flush on a single page and calling one call later at the end of
move_page_tables. At a glance, that seems ok and would reduce IPIs
but I'm not thinking about it properly because I'm trying to think
about THP shenanigans :)

>  		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
>  		set_pte_at(mm, new_addr, new_pte, pte);
>  	}
> @@ -123,7 +116,6 @@ static void move_ptes(struct vm_area_str
>  	pte_unmap_unlock(old_pte - 1, old_ptl);
>  	if (mapping)
>  		mutex_unlock(&mapping->i_mmap_mutex);
> -	mmu_notifier_invalidate_range_end(vma->vm_mm, old_start, old_end);
>  }
>  
>  #define LATENCY_LIMIT	(64 * PAGE_SIZE)
> @@ -134,14 +126,17 @@ unsigned long move_page_tables(struct vm
>  {
>  	unsigned long extent, next, old_end;
>  	pmd_t *old_pmd, *new_pmd;
> +	bool need_flush = false;
>  
>  	old_end = old_addr + len;
>  	flush_cache_range(vma, old_addr, old_end);
>  
> +	mmu_notifier_invalidate_range_start(vma->vm_mm, old_addr, old_end);
> +
>  	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
>  		cond_resched();
>  		next = (old_addr + PMD_SIZE) & PMD_MASK;
> -		if (next - 1 > old_end)
> +		if (next > old_end)
>  			next = old_end;
>  		extent = next - old_addr;
>  		old_pmd = get_old_pmd(vma->vm_mm, old_addr);

You asked if removing this "- 1" is correct. It's an overflow check for
a situation where old_addr + PMD_SIZE overflows. On what architecture
is it possible to call mremap() at the very top of the address space
or am I missing the point?

Otherwise I think the existing check is harmless if obscure. It's
reasonable to assume PAGE_SIZE will be > 1 and I'm not seeing why it is
required by the rest of the patch.

> @@ -150,6 +145,23 @@ unsigned long move_page_tables(struct vm
>  		new_pmd = alloc_new_pmd(vma->vm_mm, vma, new_addr);
>  		if (!new_pmd)
>  			break;
> +		if (pmd_trans_huge(*old_pmd)) {
> +			int err = 0;
> +			if (extent == HPAGE_PMD_SIZE)
> +				err = move_huge_pmd(vma, new_vma, old_addr,
> +						    new_addr, old_end,
> +						    old_pmd, new_pmd);
> +			if (err > 0) {
> +				need_flush = true;
> +				continue;
> +			} else if (!err)
> +				split_huge_page_pmd(vma->vm_mm, old_pmd);
> +			VM_BUG_ON(pmd_trans_huge(*old_pmd));

This tristate is hard to parse but I mentioned this already.

> +		}
> +		if (pmd_none(*new_pmd) && __pte_alloc(new_vma->vm_mm, new_vma,
> +						      new_pmd,
> +						      new_addr))
> +			break;
>  		next = (new_addr + PMD_SIZE) & PMD_MASK;
>  		if (extent > next - new_addr)
>  			extent = next - new_addr;
> @@ -157,7 +169,12 @@ unsigned long move_page_tables(struct vm
>  			extent = LATENCY_LIMIT;
>  		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
>  				new_vma, new_pmd, new_addr);
> +		need_flush = true;
>  	}
> +	if (likely(need_flush))
> +		flush_tlb_range(vma, old_end-len, old_addr);
> +
> +	mmu_notifier_invalidate_range_end(vma->vm_mm, old_end-len, old_end);
>  
>  	return len + old_addr - old_end;	/* how much done */
>  }
> 

Functionally, I can't see a major problem with the patch. The
minor problems are that I'd like to see that tristate replaced for
readability, the optimisation better explained or in a separate patch
and an explanation why the larger ranges for mmu_notifiers is not
a problem.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
