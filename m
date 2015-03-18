Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 61F3D6B0070
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:34:54 -0400 (EDT)
Received: by webcq43 with SMTP id cq43so33916479web.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:34:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pd4si4090797wic.0.2015.03.18.07.34.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 07:34:52 -0700 (PDT)
Message-ID: <55098D0A.8090605@suse.cz>
Date: Wed, 18 Mar 2015 15:34:50 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, memcg: sync allocation and memcg charge gfp flags
 for THP
References: <1426514892-7063-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <1426514892-7063-1-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 03/16/2015 03:08 PM, Michal Hocko wrote:
> memcg currently uses hardcoded GFP_TRANSHUGE gfp flags for all THP
> charges. THP allocations, however, might be using different flags
> depending on /sys/kernel/mm/transparent_hugepage/{,khugepaged/}defrag
> and the current allocation context.
>
> The primary difference is that defrag configured to "madvise" value will
> clear __GFP_WAIT flag from the core gfp mask to make the allocation
> lighter for all mappings which are not backed by VM_HUGEPAGE vmas.
> If memcg charge path ignores this fact we will get light allocation but
> the a potential memcg reclaim would kill the whole point of the
> configuration.
>
> Fix the mismatch by providing the same gfp mask used for the
> allocation to the charge functions. This is quite easy for all
> paths except for hugepaged kernel thread with !CONFIG_NUMA which is
> doing a pre-allocation long before the allocated page is used in
> collapse_huge_page via khugepaged_alloc_page. To prevent from cluttering
> the whole code path from khugepaged_do_scan we simply return the current
> flags as per khugepaged_defrag() value which might have changed since
> the preallocation. If somebody changed the value of the knob we would
> charge differently but this shouldn't happen often and it is definitely
> not critical because it would only lead to a reduced success rate of
> one-off THP promotion.
>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

(a nitpick below)

> ---
>   mm/huge_memory.c | 36 ++++++++++++++++++++----------------
>   1 file changed, 20 insertions(+), 16 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 625eb556b509..91898b010406 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -708,7 +708,7 @@ static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
>   static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>   					struct vm_area_struct *vma,
>   					unsigned long haddr, pmd_t *pmd,
> -					struct page *page)
> +					struct page *page, gfp_t gfp)
>   {
>   	struct mem_cgroup *memcg;
>   	pgtable_t pgtable;
> @@ -716,7 +716,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>
>   	VM_BUG_ON_PAGE(!PageCompound(page), page);
>
> -	if (mem_cgroup_try_charge(page, mm, GFP_TRANSHUGE, &memcg))
> +	if (mem_cgroup_try_charge(page, mm, gfp, &memcg))
>   		return VM_FAULT_OOM;
>
>   	pgtable = pte_alloc_one(mm, haddr);
> @@ -822,7 +822,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   		count_vm_event(THP_FAULT_FALLBACK);
>   		return VM_FAULT_FALLBACK;
>   	}
> -	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page))) {
> +	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page, gfp))) {
>   		put_page(page);
>   		count_vm_event(THP_FAULT_FALLBACK);
>   		return VM_FAULT_FALLBACK;
> @@ -1080,6 +1080,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   	unsigned long haddr;
>   	unsigned long mmun_start;	/* For mmu_notifiers */
>   	unsigned long mmun_end;		/* For mmu_notifiers */
> +	gfp_t huge_gfp = GFP_TRANSHUGE;	/* for allocation and charge */

This value is actually never used. Is it here because the compiler emits 
a spurious non-initialized value warning otherwise? It should be easy 
for it to prove that setting new_page to something non-null implies 
initializing huge_gfp (in the hunk below), and NULL new_page means it 
doesn't reach the mem_cgroup_try_charge() call?

>
>   	ptl = pmd_lockptr(mm, pmd);
>   	VM_BUG_ON_VMA(!vma->anon_vma, vma);
> @@ -1106,10 +1107,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   alloc:
>   	if (transparent_hugepage_enabled(vma) &&
>   	    !transparent_hugepage_debug_cow()) {
> -		gfp_t gfp;
> -
> -		gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
> -		new_page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
> +		huge_gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
> +		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
>   	} else
>   		new_page = NULL;
>
> @@ -1131,7 +1130,7 @@ alloc:
>   	}
>
>   	if (unlikely(mem_cgroup_try_charge(new_page, mm,
> -					   GFP_TRANSHUGE, &memcg))) {
> +					   huge_gfp, &memcg))) {
>   		put_page(new_page);
>   		if (page) {
>   			split_huge_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
