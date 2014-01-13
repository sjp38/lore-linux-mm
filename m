Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDCE6B0035
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 02:36:39 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id lx4so687347iec.5
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 23:36:38 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id mg9si25241890icc.50.2014.01.12.23.36.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 12 Jan 2014 23:36:34 -0800 (PST)
Message-ID: <1389598587.4672.121.camel@pasglop>
Subject: Re: [PATCH V4] powerpc: thp: Fix crash on mremap
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 13 Jan 2014 18:36:27 +1100
In-Reply-To: <1389593064-32664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: 
	<1389593064-32664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: paulus@samba.org, kirill.shutemov@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Mon, 2014-01-13 at 11:34 +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This patch fix the below crash

Andrea, can you ack the generic bit please ?

Thanks !

Cheers,
Ben.

> NIP [c00000000004cee4] .__hash_page_thp+0x2a4/0x440
> LR [c0000000000439ac] .hash_page+0x18c/0x5e0
> ...
> Call Trace:
> [c000000736103c40] [00001ffffb000000] 0x1ffffb000000(unreliable)
> [437908.479693] [c000000736103d50] [c0000000000439ac] .hash_page+0x18c/0x5e0
> [437908.479699] [c000000736103e30] [c00000000000924c] .do_hash_page+0x4c/0x58
> 
> On ppc64 we use the pgtable for storing the hpte slot information and
> store address to the pgtable at a constant offset (PTRS_PER_PMD) from
> pmd. On mremap, when we switch the pmd, we need to withdraw and deposit
> the pgtable again, so that we find the pgtable at PTRS_PER_PMD offset
> from new pmd.
> 
> We also want to move the withdraw and deposit before the set_pmd so
> that, when page fault find the pmd as trans huge we can be sure that
> pgtable can be located at the offset.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> Changes from V3:
> * Drop "powerpc: mm: Move ppc64 page table range definitions to separate header"" patch
> 
>  arch/powerpc/include/asm/pgtable-ppc64.h | 14 ++++++++++++++
>  include/asm-generic/pgtable.h            | 12 ++++++++++++
>  mm/huge_memory.c                         | 14 +++++---------
>  3 files changed, 31 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
> index 4a191c472867..d27960c89a71 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> @@ -558,5 +558,19 @@ extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
>  #define __HAVE_ARCH_PMDP_INVALIDATE
>  extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>  			    pmd_t *pmdp);
> +
> +#define pmd_move_must_withdraw pmd_move_must_withdraw
> +typedef struct spinlock spinlock_t;
> +static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
> +					 spinlock_t *old_pmd_ptl)
> +{
> +	/*
> +	 * Archs like ppc64 use pgtable to store per pmd
> +	 * specific information. So when we switch the pmd,
> +	 * we should also withdraw and deposit the pgtable
> +	 */
> +	return true;
> +}
> +
>  #endif /* __ASSEMBLY__ */
>  #endif /* _ASM_POWERPC_PGTABLE_PPC64_H_ */
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index db0923458940..8e4f41d9af4d 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -558,6 +558,18 @@ static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
>  }
>  #endif
>  
> +#ifndef pmd_move_must_withdraw
> +static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
> +					 spinlock_t *old_pmd_ptl)
> +{
> +	/*
> +	 * With split pmd lock we also need to move preallocated
> +	 * PTE page table if new_pmd is on different PMD page table.
> +	 */
> +	return new_pmd_ptl != old_pmd_ptl;
> +}
> +#endif
> +
>  /*
>   * This function is meant to be used by sites walking pagetables with
>   * the mmap_sem hold in read mode to protect against MADV_DONTNEED and
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 95d1acb0f3d2..5d80c53b87cb 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1502,19 +1502,15 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
>  			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
>  		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
>  		VM_BUG_ON(!pmd_none(*new_pmd));
> -		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
> -		if (new_ptl != old_ptl) {
> -			pgtable_t pgtable;
>  
> -			/*
> -			 * Move preallocated PTE page table if new_pmd is on
> -			 * different PMD page table.
> -			 */
> +		if (pmd_move_must_withdraw(new_ptl, old_ptl)) {
> +			pgtable_t pgtable;
>  			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
>  			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
> -
> -			spin_unlock(new_ptl);
>  		}
> +		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
> +		if (new_ptl != old_ptl)
> +			spin_unlock(new_ptl);
>  		spin_unlock(old_ptl);
>  	}
>  out:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
