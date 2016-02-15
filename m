Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4616B0005
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:44:47 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ho8so78528779pac.2
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 18:44:47 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id rp7si39860525pab.99.2016.02.14.18.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 18:44:46 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id w128so6307021pfb.2
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 18:44:46 -0800 (PST)
Message-ID: <1455504278.16012.18.camel@gmail.com>
Subject: Re: [PATCH V3] powerpc/mm: Fix Multi hit ERAT cause by recent THP
 update
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 15 Feb 2016 13:44:38 +1100
In-Reply-To: <1454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: 
	<1454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2016-02-09 at 06:50 +0530, Aneesh Kumar K.V wrote:
>A 
> Also make sure we wait for irq disable section in other cpus to finish
> before flipping a huge pte entry with a regular pmd entry. Code paths
> like find_linux_pte_or_hugepte depend on irq disable to get
> a stable pte_t pointer. A parallel thp split need to make sure we
> don't convert a pmd pte to a regular pmd entry without waiting for the
> irq disable section to finish.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> A arch/powerpc/include/asm/book3s/64/pgtable.h |A A 4 ++++
> A arch/powerpc/mm/pgtable_64.cA A A A A A A A A A A A A A A A A | 35
> +++++++++++++++++++++++++++-
> A include/asm-generic/pgtable.hA A A A A A A A A A A A A A A A |A A 8 +++++++
> A mm/huge_memory.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A |A A 1 +
> A 4 files changed, 47 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h
> b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 8d1c41d28318..ac07a30a7934 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -281,6 +281,10 @@ extern pgtable_t pgtable_trans_huge_withdraw(struct
> mm_struct *mm, pmd_t *pmdp);
> A extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long
> address,
> A 			A A A A pmd_t *pmdp);
> A 
> +#define __HAVE_ARCH_PMDP_HUGE_SPLIT_PREPARE
> +extern void pmdp_huge_split_prepare(struct vm_area_struct *vma,
> +				A A A A unsigned long address, pmd_t *pmdp);
> +
> A #define pmd_move_must_withdraw pmd_move_must_withdraw
> A struct spinlock;
> A static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
> index 3124a20d0fab..c8a00da39969 100644
> --- a/arch/powerpc/mm/pgtable_64.c
> +++ b/arch/powerpc/mm/pgtable_64.c
> @@ -646,6 +646,30 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct
> *mm, pmd_t *pmdp)
> A 	return pgtable;
> A }
> A 
> +void pmdp_huge_split_prepare(struct vm_area_struct *vma,
> +			A A A A A unsigned long address, pmd_t *pmdp)
> +{
> +	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> +
> +#ifdef CONFIG_DEBUG_VM
> +	BUG_ON(REGION_ID(address) != USER_REGION_ID);
> +#endif
> +	/*
> +	A * We can't mark the pmd none here, because that will cause a race
> +	A * against exit_mmap. We need to continue mark pmd TRANS HUGE, while
> +	A * we spilt, but at the same time we wan't rest of the ppc64 code
> +	A * not to insert hash pte on this, because we will be modifying
> +	A * the deposited pgtable in the caller of this function. Hence
> +	A * clear the _PAGE_USER so that we move the fault handling to
> +	A * higher level function and that will serialize against ptl.
> +	A * We need to flush existing hash pte entries here even though,
> +	A * the translation is still valid, because we will withdraw
> +	A * pgtable_t after this.
> +	A */
> +	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_USER, 0);

Can this break any checks for _PAGE_USER? From other paths?

> +}
> +
> +
> A /*
> A  * set a new huge pmd. We should not be called for updating
> A  * an existing pmd entry. That should go via pmd_hugepage_update.
> @@ -663,10 +687,19 @@ void set_pmd_at(struct mm_struct *mm, unsigned long
> addr,
> A 	return set_pte_at(mm, addr, pmdp_ptep(pmdp), pmd_pte(pmd));
> A }
> A 
> +/*
> + * We use this to invalidate a pmdp entry before switching from a
> + * hugepte to regular pmd entry.
> + */
> A void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
> A 		A A A A A pmd_t *pmdp)
> A {
> -	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_PRESENT, 0);
> +	pmd_hugepage_update(vma->vm_mm, address, pmdp, ~0UL, 0);
> +	/*
> +	A * This ensures that generic code that rely on IRQ disabling
> +	A * to prevent a parallel THP split work as expected.
> +	A */
> +	kick_all_cpus_sync();

Seems expensive, anyway I think the right should do something like or a wrapper
for it

on_each_cpu_mask(mm_cpumask(vma->vm_mm), do_nothing, NULL, 1);

do_nothing is not exported, but that can be fixed :)

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
