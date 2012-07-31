Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 984656B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 09:21:41 -0400 (EDT)
Date: Tue, 31 Jul 2012 15:21:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
Message-ID: <20120731132138.GA7867@tiehlicka.suse.cz>
References: <20120720134937.GG9222@suse.de>
 <20120720141108.GH9222@suse.de>
 <20120720143635.GE12434@tiehlicka.suse.cz>
 <20120720145121.GJ9222@suse.de>
 <alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
 <50118E7F.8000609@redhat.com>
 <50120FA8.20409@redhat.com>
 <20120727102356.GD612@suse.de>
 <5016DC5F.7030604@redhat.com>
 <20120731124650.GO612@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120731124650.GO612@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 31-07-12 13:46:50, Mel Gorman wrote:
[...]
> mm: hugetlbfs: Correctly detect if page tables have just been shared
> 
> Each page mapped in a processes address space must be correctly
> accounted for in _mapcount. Normally the rules for this are
> straight-forward but hugetlbfs page table sharing is different.
> The page table pages at the PMD level are reference counted while
> the mapcount remains the same. If this accounting is wrong, it causes
> bugs like this one reported by Larry Woodman
> 
> [ 1106.156569] ------------[ cut here ]------------
> [ 1106.161731] kernel BUG at mm/filemap.c:135!
> [ 1106.166395] invalid opcode: 0000 [#1] SMP
> [ 1106.170975] CPU 22
> [ 1106.173115] Modules linked in: bridge stp llc sunrpc binfmt_misc dcdbas microcode pcspkr acpi_pad acpi]
> [ 1106.201770]
> [ 1106.203426] Pid: 18001, comm: mpitest Tainted: G        W    3.3.0+ #4 Dell Inc. PowerEdge R620/07NDJ2
> [ 1106.213822] RIP: 0010:[<ffffffff8112cfed>]  [<ffffffff8112cfed>] __delete_from_page_cache+0x15d/0x170
> [ 1106.224117] RSP: 0018:ffff880428973b88  EFLAGS: 00010002
> [ 1106.230032] RAX: 0000000000000001 RBX: ffffea0006b80000 RCX: 00000000ffffffb0
> [ 1106.237979] RDX: 0000000000016df1 RSI: 0000000000000009 RDI: ffff88043ffd9e00
> [ 1106.245927] RBP: ffff880428973b98 R08: 0000000000000050 R09: 0000000000000003
> [ 1106.253876] R10: 000000000000000d R11: 0000000000000000 R12: ffff880428708150
> [ 1106.261826] R13: ffff880428708150 R14: 0000000000000000 R15: ffffea0006b80000
> [ 1106.269780] FS:  0000000000000000(0000) GS:ffff88042fd60000(0000) knlGS:0000000000000000
> [ 1106.278794] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1106.285193] CR2: 0000003a1d38c4a8 CR3: 000000000187d000 CR4: 00000000000406e0
> [ 1106.293149] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 1106.301097] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 1106.309046] Process mpitest (pid: 18001, threadinfo ffff880428972000, task ffff880428b5cc20)
> [ 1106.318447] Stack:
> [ 1106.320690]  ffffea0006b80000 0000000000000000 ffff880428973bc8 ffffffff8112d040
> [ 1106.328958]  ffff880428973bc8 00000000000002ab 00000000000002a0 ffff880428973c18
> [ 1106.337234]  ffff880428973cc8 ffffffff8125b405 ffff880400000001 0000000000000000
> [ 1106.345513] Call Trace:
> [ 1106.348235]  [<ffffffff8112d040>] delete_from_page_cache+0x40/0x80
> [ 1106.355128]  [<ffffffff8125b405>] truncate_hugepages+0x115/0x1f0
> [ 1106.361826]  [<ffffffff8125b4f8>] hugetlbfs_evict_inode+0x18/0x30
> [ 1106.368615]  [<ffffffff811ab1af>] evict+0x9f/0x1b0
> [ 1106.373951]  [<ffffffff811ab3a3>] iput_final+0xe3/0x1e0
> [ 1106.379773]  [<ffffffff811ab4de>] iput+0x3e/0x50
> [ 1106.384922]  [<ffffffff811a8e18>] d_kill+0xf8/0x110
> [ 1106.390356]  [<ffffffff811a8f12>] dput+0xe2/0x1b0
> [ 1106.395595]  [<ffffffff81193612>] __fput+0x162/0x240
> 
> During fork(), copy_hugetlb_page_range() detects if huge_pte_alloc()
> shared page tables with the check dst_pte == src_pte. The logic is if
> the PMD page is the same, they must be shared. This assumes that the
> sharing is between the parent and child. However, if the sharing is with
> a different process entirely then this check fails as in this diagram.
> 
> parent
>   |
>   ------------>pmd
>                src_pte----------> data page
>                                       ^
> other--------->pmd--------------------|
>                 ^
> child-----------|
>                dst_pte
> 
> For this situation to occur, it must be possible for Parent and Other
> to have faulted and failed to share page tables with each other. This is
> possible due to the following style of race.
> 
> PROC A						PROC B
> copy_hugetlb_page_range				copy_hugetlb_page_range
>   src_pte == huge_pte_offset			  src_pte == huge_pte_offset
>   !src_pte so no sharing			  !src_pte so no sharing
> 
> (time passes)
> 
> hugetlb_fault					hugetlb_fault
>   huge_pte_alloc				  huge_pte_alloc
>     huge_pmd_share				   huge_pmd_share
>       LOCK(i_mmap_mutex)
>       find nothing, no sharing
>       UNLOCK(i_mmap_mutex)
>       						    LOCK(i_mmap_mutex)
>       						    find nothing, no sharing
>       						    UNLOCK(i_mmap_mutex)
>     pmd_alloc					    pmd_alloc
>     LOCK(instantiation_mutex)
>     fault
>     UNLOCK(instantiation_mutex)
>     						LOCK(instantiation_mutex)
>     						fault
>     						UNLOCK(instantiation_mutex)

Makes sense. I was wondering how the child could share with somebody
else and pmd would be different from the parent because parent is
blocked by mmap_sem (for write) so no concurrent faults are allowed.
Other process should see the parents pmd if it is shareable. I obviously
underestimated that the sharing could fail before and that
mapping->i_mmap contains 2 different candidates for sharing for the same
address.
Thanks!

> These two processes are not poing to the same data page but are not sharing
> page tables because the opportunity was missed. When either process later
> forks, the src_pte == dst pte is potentially insufficient.  As the check
> falls through, the wrong PTE information is copied in (harmless but wrong)
> and the mapcount is bumped for a page mapped by a shared page table leading
> to the BUG_ON.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  arch/ia64/mm/hugetlbpage.c    |    3 ++-
>  arch/mips/mm/hugetlbpage.c    |    2 +-
>  arch/powerpc/mm/hugetlbpage.c |    3 ++-
>  arch/s390/mm/hugetlbpage.c    |    3 ++-
>  arch/sh/mm/hugetlbpage.c      |    3 ++-
>  arch/sparc/mm/hugetlbpage.c   |    3 ++-
>  arch/tile/mm/hugetlbpage.c    |    3 ++-
>  arch/x86/mm/hugetlbpage.c     |   13 ++++++++-----
>  include/linux/hugetlb.h       |    3 ++-
>  mm/hugetlb.c                  |   12 +++++++++---
>  10 files changed, 32 insertions(+), 16 deletions(-)
> 
> diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
> index 5ca674b..a0bb307 100644
> --- a/arch/ia64/mm/hugetlbpage.c
> +++ b/arch/ia64/mm/hugetlbpage.c
> @@ -25,7 +25,8 @@ unsigned int hpage_shift = HPAGE_SHIFT_DEFAULT;
>  EXPORT_SYMBOL(hpage_shift);
>  
>  pte_t *
> -huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
> +huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz,
> +	       bool *shared)
>  {
>  	unsigned long taddr = htlbpage_to_page(addr);
>  	pgd_t *pgd;
> diff --git a/arch/mips/mm/hugetlbpage.c b/arch/mips/mm/hugetlbpage.c
> index a7fee0d..06ca4a3 100644
> --- a/arch/mips/mm/hugetlbpage.c
> +++ b/arch/mips/mm/hugetlbpage.c
> @@ -23,7 +23,7 @@
>  #include <asm/tlbflush.h>
>  
>  pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr,
> -		      unsigned long sz)
> +		      unsigned long sz, bool *shared)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index 1a6de0a..5fc6672 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -175,7 +175,8 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>  #define HUGEPD_PUD_SHIFT PMD_SHIFT
>  #endif
>  
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz,
> +		      bool *shared)
>  {
>  	pgd_t *pg;
>  	pud_t *pu;
> diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
> index 532525e..2c3b501 100644
> --- a/arch/s390/mm/hugetlbpage.c
> +++ b/arch/s390/mm/hugetlbpage.c
> @@ -65,7 +65,8 @@ void arch_release_hugepage(struct page *page)
>  }
>  
>  pte_t *huge_pte_alloc(struct mm_struct *mm,
> -			unsigned long addr, unsigned long sz)
> +			unsigned long addr, unsigned long sz,
> +			bool *shared)
>  {
>  	pgd_t *pgdp;
>  	pud_t *pudp;
> diff --git a/arch/sh/mm/hugetlbpage.c b/arch/sh/mm/hugetlbpage.c
> index d776234..bbe154d 100644
> --- a/arch/sh/mm/hugetlbpage.c
> +++ b/arch/sh/mm/hugetlbpage.c
> @@ -22,7 +22,8 @@
>  #include <asm/cacheflush.h>
>  
>  pte_t *huge_pte_alloc(struct mm_struct *mm,
> -			unsigned long addr, unsigned long sz)
> +			unsigned long addr, unsigned long sz,
> +			bool *shared)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
> index 07e1453..d3ef01b 100644
> --- a/arch/sparc/mm/hugetlbpage.c
> +++ b/arch/sparc/mm/hugetlbpage.c
> @@ -194,7 +194,8 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>  }
>  
>  pte_t *huge_pte_alloc(struct mm_struct *mm,
> -			unsigned long addr, unsigned long sz)
> +			unsigned long addr, unsigned long sz,
> +			bool *shared)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
> index 812e2d0..db01091 100644
> --- a/arch/tile/mm/hugetlbpage.c
> +++ b/arch/tile/mm/hugetlbpage.c
> @@ -84,7 +84,8 @@ static pte_t *pte_alloc_hugetlb(struct mm_struct *mm, pmd_t *pmd,
>  #endif
>  
>  pte_t *huge_pte_alloc(struct mm_struct *mm,
> -		      unsigned long addr, unsigned long sz)
> +		      unsigned long addr, unsigned long sz,
> +		      bool *shared)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index f6679a7..8c53064 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -58,7 +58,8 @@ static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
>  /*
>   * search for a shareable pmd page for hugetlb.
>   */
> -static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> +static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud,
> +			   bool *shared)
>  {
>  	struct vm_area_struct *vma = find_vma(mm, addr);
>  	struct address_space *mapping = vma->vm_file->f_mapping;
> @@ -91,9 +92,10 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  		goto out;
>  
>  	spin_lock(&mm->page_table_lock);
> -	if (pud_none(*pud))
> +	if (pud_none(*pud)) {
>  		pud_populate(mm, pud, (pmd_t *)((unsigned long)spte & PAGE_MASK));
> -	else
> +		*shared = true;
> +	} else
>  		put_page(virt_to_page(spte));
>  	spin_unlock(&mm->page_table_lock);
>  out:
> @@ -128,7 +130,8 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
>  }
>  
>  pte_t *huge_pte_alloc(struct mm_struct *mm,
> -			unsigned long addr, unsigned long sz)
> +			unsigned long addr, unsigned long sz,
> +			bool *shared)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> @@ -142,7 +145,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>  		} else {
>  			BUG_ON(sz != PMD_SIZE);
>  			if (pud_none(*pud))
> -				huge_pmd_share(mm, addr, pud);
> +				huge_pmd_share(mm, addr, pud, shared);
>  			pte = (pte_t *) pmd_alloc(mm, pud, addr);
>  		}
>  	}
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 73c7782..68d2597 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -75,7 +75,8 @@ extern struct list_head huge_boot_pages;
>  /* arch callbacks */
>  
>  pte_t *huge_pte_alloc(struct mm_struct *mm,
> -			unsigned long addr, unsigned long sz);
> +			unsigned long addr, unsigned long sz,
> +			bool *shared);
>  pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
>  int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
>  struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 71c93d7..45c2196 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2282,6 +2282,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  	int cow;
>  	struct hstate *h = hstate_vma(vma);
>  	unsigned long sz = huge_page_size(h);
> +	bool shared = false;
>  
>  	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
>  
> @@ -2289,12 +2290,12 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  		src_pte = huge_pte_offset(src, addr);
>  		if (!src_pte)
>  			continue;
> -		dst_pte = huge_pte_alloc(dst, addr, sz);
> +		dst_pte = huge_pte_alloc(dst, addr, sz, &shared);
>  		if (!dst_pte)
>  			goto nomem;
>  
>  		/* If the pagetables are shared don't copy or take references */
> -		if (dst_pte == src_pte)
> +		if (shared)
>  			continue;
>  
>  		spin_lock(&dst->page_table_lock);
> @@ -2817,6 +2818,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct page *pagecache_page = NULL;
>  	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
>  	struct hstate *h = hstate_vma(vma);
> +	bool shared = false;
>  
>  	address &= huge_page_mask(h);
>  
> @@ -2831,10 +2833,14 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  				VM_FAULT_SET_HINDEX(hstate_index(h));
>  	}
>  
> -	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
> +	ptep = huge_pte_alloc(mm, address, huge_page_size(h), &shared);
>  	if (!ptep)
>  		return VM_FAULT_OOM;
>  
> +	/* If the pagetable is shared, no other work is necessary */
> +	if (shared)
> +		return 0;
> +
>  	/*
>  	 * Serialize hugepage allocation and instantiation, so that we don't
>  	 * get spurious allocation failures if two CPUs race to instantiate

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
