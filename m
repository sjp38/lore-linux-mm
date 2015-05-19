Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7E46B00B6
	for <linux-mm@kvack.org>; Tue, 19 May 2015 09:55:15 -0400 (EDT)
Received: by wgfl8 with SMTP id l8so18919774wgf.2
        for <linux-mm@kvack.org>; Tue, 19 May 2015 06:55:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kz7si1360956wjb.155.2015.05.19.06.55.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 06:55:13 -0700 (PDT)
Message-ID: <555B40C0.3050703@suse.cz>
Date: Tue, 19 May 2015 15:55:12 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 23/28] thp: add option to setup migration entiries during
 PMD split
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-24-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-24-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> We are going to use migration PTE entires to stabilize page counts.
> If the page is mapped with PMDs we need to split the PMD and setup
> migration enties. It's reasonable to combine these operations to avoid
> double-scanning over the page table.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/huge_memory.c | 23 +++++++++++++++--------
>   1 file changed, 15 insertions(+), 8 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 5885ef8f0fad..2f9e2e882bab 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -23,6 +23,7 @@
>   #include <linux/pagemap.h>
>   #include <linux/migrate.h>
>   #include <linux/hashtable.h>
> +#include <linux/swapops.h>
>
>   #include <asm/tlb.h>
>   #include <asm/pgalloc.h>
> @@ -2551,7 +2552,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
>   }
>
>   static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> -		unsigned long haddr)
> +		unsigned long haddr, bool freeze)
>   {
>   	struct mm_struct *mm = vma->vm_mm;
>   	struct page *page;
> @@ -2593,12 +2594,18 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>   		 * transferred to avoid any possibility of altering
>   		 * permissions across VMAs.
>   		 */
> -		entry = mk_pte(page + i, vma->vm_page_prot);
> -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> -		if (!write)
> -			entry = pte_wrprotect(entry);
> -		if (!young)
> -			entry = pte_mkold(entry);
> +		if (freeze) {
> +			swp_entry_t swp_entry;
> +			swp_entry = make_migration_entry(page + i, write);
> +			entry = swp_entry_to_pte(swp_entry);
> +		} else {
> +			entry = mk_pte(page + i, vma->vm_page_prot);
> +			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +			if (!write)
> +				entry = pte_wrprotect(entry);
> +			if (!young)
> +				entry = pte_mkold(entry);
> +		}
>   		pte = pte_offset_map(&_pmd, haddr);
>   		BUG_ON(!pte_none(*pte));
>   		set_pte_at(mm, haddr, pte, entry);
> @@ -2625,7 +2632,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>   	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
>   	ptl = pmd_lock(mm, pmd);
>   	if (likely(pmd_trans_huge(*pmd)))
> -		__split_huge_pmd_locked(vma, pmd, haddr);
> +		__split_huge_pmd_locked(vma, pmd, haddr, false);
>   	spin_unlock(ptl);
>   	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
>   }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
