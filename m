Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3002A6B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 23:02:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f185so29479870pgc.10
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 20:02:53 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id l13si848480plk.441.2017.06.15.20.02.51
        for <linux-mm@kvack.org>;
        Thu, 15 Jun 2017 20:02:52 -0700 (PDT)
Date: Fri, 16 Jun 2017 12:02:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv2 3/3] mm: Use updated pmdp_invalidate() inteface to
 track dirty/accessed bits
Message-ID: <20170616030250.GA27637@bbox>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-4-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615145224.66200-4-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Thu, Jun 15, 2017 at 05:52:24PM +0300, Kirill A. Shutemov wrote:
> This patch uses modifed pmdp_invalidate(), that return previous value of pmd,
> to transfer dirty and accessed bits.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  fs/proc/task_mmu.c |  8 ++++----
>  mm/huge_memory.c   | 29 ++++++++++++-----------------
>  2 files changed, 16 insertions(+), 21 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index f0c8b33d99b1..f2fc1ef5bba2 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -906,13 +906,13 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
>  static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
>  		unsigned long addr, pmd_t *pmdp)
>  {
> -	pmd_t pmd = *pmdp;
> +	pmd_t old, pmd = *pmdp;
>  
>  	/* See comment in change_huge_pmd() */
> -	pmdp_invalidate(vma, addr, pmdp);
> -	if (pmd_dirty(*pmdp))
> +	old = pmdp_invalidate(vma, addr, pmdp);
> +	if (pmd_dirty(old))
>  		pmd = pmd_mkdirty(pmd);
> -	if (pmd_young(*pmdp))
> +	if (pmd_young(old))
>  		pmd = pmd_mkyoung(pmd);
>  
>  	pmd = pmd_wrprotect(pmd);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index a84909cf20d3..0433e73531bf 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1777,17 +1777,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	 * pmdp_invalidate() is required to make sure we don't miss
>  	 * dirty/young flags set by hardware.
>  	 */
> -	entry = *pmd;
> -	pmdp_invalidate(vma, addr, pmd);
> -
> -	/*
> -	 * Recover dirty/young flags.  It relies on pmdp_invalidate to not
> -	 * corrupt them.
> -	 */
> -	if (pmd_dirty(*pmd))
> -		entry = pmd_mkdirty(entry);
> -	if (pmd_young(*pmd))
> -		entry = pmd_mkyoung(entry);
> +	entry = pmdp_invalidate(vma, addr, pmd);
>  
>  	entry = pmd_modify(entry, newprot);
>  	if (preserve_write)
> @@ -1927,8 +1917,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	struct mm_struct *mm = vma->vm_mm;
>  	struct page *page;
>  	pgtable_t pgtable;
> -	pmd_t _pmd;
> -	bool young, write, dirty, soft_dirty;
> +	pmd_t old, _pmd;
> +	bool young, write, soft_dirty;
>  	unsigned long addr;
>  	int i;
>  
> @@ -1965,7 +1955,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	page_ref_add(page, HPAGE_PMD_NR - 1);
>  	write = pmd_write(*pmd);
>  	young = pmd_young(*pmd);
> -	dirty = pmd_dirty(*pmd);
>  	soft_dirty = pmd_soft_dirty(*pmd);
>  
>  	pmdp_huge_split_prepare(vma, haddr, pmd);
> @@ -1995,8 +1984,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  			if (soft_dirty)
>  				entry = pte_mksoft_dirty(entry);
>  		}
> -		if (dirty)
> -			SetPageDirty(page + i);
>  		pte = pte_offset_map(&_pmd, addr);
>  		BUG_ON(!pte_none(*pte));
>  		set_pte_at(mm, addr, pte, entry);
> @@ -2045,7 +2032,15 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	 * and finally we write the non-huge version of the pmd entry with
>  	 * pmd_populate.
>  	 */
> -	pmdp_invalidate(vma, haddr, pmd);
> +	old = pmdp_invalidate(vma, haddr, pmd);
> +
> +	/*
> +	 * Transfer dirty bit using value returned by pmd_invalidate() to be
> +	 * sure we don't race with CPU that can set the bit under us.
> +	 */
> +	if (pmd_dirty(old))
> +		SetPageDirty(page);
> +

When I see this, without this patch, MADV_FREE has been broken because
it can lose dirty bit by early checking. Right?
If so, isn't it a candidate for -stable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
