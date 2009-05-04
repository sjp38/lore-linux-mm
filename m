Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F2F466B0088
	for <linux-mm@kvack.org>; Mon,  4 May 2009 06:09:43 -0400 (EDT)
Date: Mon, 4 May 2009 12:08:03 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] mm: use generic follow_pte() in follow_phys()
Message-ID: <20090504100803.GA12726@cmpxchg.org>
References: <20090501181449.GA8912@cmpxchg.org> <1241430874-12667-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1241430874-12667-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, May 04, 2009 at 11:54:33AM +0200, Johannes Weiner wrote:
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memory.c |   37 ++++++-------------------------------
>  1 files changed, 6 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index a621319..aee167d 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3051,50 +3051,25 @@ int follow_phys(struct vm_area_struct *vma,
>  		unsigned long address, unsigned int flags,
>  		unsigned long *prot, resource_size_t *phys)
>  {
> -	pgd_t *pgd;
> -	pud_t *pud;
> -	pmd_t *pmd;
> +	int ret = -EINVAL;
>  	pte_t *ptep, pte;
>  	spinlock_t *ptl;
> -	resource_size_t phys_addr = 0;
> -	struct mm_struct *mm = vma->vm_mm;
> -	int ret = -EINVAL;
>  
>  	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP)))
>  		goto out;
>  
> -	pgd = pgd_offset(mm, address);
> -	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
> -		goto out;
> -
> -	pud = pud_offset(pgd, address);
> -	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
> -		goto out;
> -
> -	pmd = pmd_offset(pud, address);
> -	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
> -		goto out;
> -
> -	/* We cannot handle huge page PFN maps. Luckily they don't exist. */
> -	if (pmd_huge(*pmd))
> +	if (follow_pte(vma->vm_mm, address, &ptep, &ptl))
>  		goto out;
> -
> -	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
> -	if (!ptep)
> -		goto out;
> -
>  	pte = *ptep;
> -	if (!pte_present(pte))
> -		goto unlock;
> +
>  	if ((flags & FOLL_WRITE) && !pte_write(pte))
>  		goto unlock;
> -	phys_addr = pte_pfn(pte);
> -	phys_addr <<= PAGE_SHIFT; /* Shift here to avoid overflow on PAE */
>  
>  	*prot = pgprot_val(pte_pgprot(pte));
> -	*phys = phys_addr;
> -	ret = 0;
> +	/* Shift here to avoid overflow on PAE */
> +	*phys = pte_pfn(pte) << PAGE_SHIFT;

Yuk, had my head in the butt here.  Changed to

	*phys = (resource_size_t)pte_pfn(pte) << PAGE_SHIFT;

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: mm: use generic follow_pte() in follow_phys()

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memory.c |   36 +++++-------------------------------
 1 files changed, 5 insertions(+), 31 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index a621319..c047950 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3051,50 +3051,24 @@ int follow_phys(struct vm_area_struct *vma,
 		unsigned long address, unsigned int flags,
 		unsigned long *prot, resource_size_t *phys)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
+	int ret = -EINVAL;
 	pte_t *ptep, pte;
 	spinlock_t *ptl;
-	resource_size_t phys_addr = 0;
-	struct mm_struct *mm = vma->vm_mm;
-	int ret = -EINVAL;
 
 	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP)))
 		goto out;
 
-	pgd = pgd_offset(mm, address);
-	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		goto out;
-
-	pud = pud_offset(pgd, address);
-	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
-		goto out;
-
-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
-		goto out;
-
-	/* We cannot handle huge page PFN maps. Luckily they don't exist. */
-	if (pmd_huge(*pmd))
+	if (follow_pte(vma->vm_mm, address, &ptep, &ptl))
 		goto out;
-
-	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (!ptep)
-		goto out;
-
 	pte = *ptep;
-	if (!pte_present(pte))
-		goto unlock;
+
 	if ((flags & FOLL_WRITE) && !pte_write(pte))
 		goto unlock;
-	phys_addr = pte_pfn(pte);
-	phys_addr <<= PAGE_SHIFT; /* Shift here to avoid overflow on PAE */
 
 	*prot = pgprot_val(pte_pgprot(pte));
-	*phys = phys_addr;
-	ret = 0;
+	*phys = (resource_size_t)pte_pfn(pte) << PAGE_SHIFT;
 
+	ret = 0;
 unlock:
 	pte_unmap_unlock(ptep, ptl);
 out:
-- 
1.6.2.1.135.gde769

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
