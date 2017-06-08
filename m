Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB606B02F4
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 06:52:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 204so3077681wmy.1
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 03:52:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i24si5128296wrb.191.2017.06.08.03.52.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 03:52:08 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: migrate: Stabilise page count when migrating
 transparent hugepages
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-4-git-send-email-will.deacon@arm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <33165470-21b8-15d2-b952-a7bbf74ee83d@suse.cz>
Date: Thu, 8 Jun 2017 12:52:07 +0200
MIME-Version: 1.0
In-Reply-To: <1496771916-28203-4-git-send-email-will.deacon@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mark.rutland@arm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On 06/06/2017 07:58 PM, Will Deacon wrote:
> When migrating a transparent hugepage, migrate_misplaced_transhuge_page
> guards itself against a concurrent fastgup of the page by checking that
> the page count is equal to 2 before and after installing the new pmd.
> 
> If the page count changes, then the pmd is reverted back to the original
> entry, however there is a small window where the new (possibly writable)
> pmd is installed and the underlying page could be written by userspace.
> Restoring the old pmd could therefore result in loss of data.
> 
> This patch fixes the problem by freezing the page count whilst updating
> the page tables, which protects against a concurrent fastgup without the
> need to restore the old pmd in the failure case (since the page count can
> no longer change under our feet).
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> ---
>  mm/migrate.c | 15 ++-------------
>  1 file changed, 2 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 89a0a1707f4c..8b21f1b1ec6e 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1913,7 +1913,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  	int page_lru = page_is_file_cache(page);
>  	unsigned long mmun_start = address & HPAGE_PMD_MASK;
>  	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
> -	pmd_t orig_entry;
>  
>  	/*
>  	 * Rate-limit the amount of data that is being migrated to a node.
> @@ -1956,8 +1955,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  	/* Recheck the target PMD */
>  	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>  	ptl = pmd_lock(mm, pmd);
> -	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
> -fail_putback:
> +	if (unlikely(!pmd_same(*pmd, entry) || !page_ref_freeze(page, 2))) {
>  		spin_unlock(ptl);
>  		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>  
> @@ -1979,7 +1977,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  		goto out_unlock;
>  	}
>  
> -	orig_entry = *pmd;
>  	entry = mk_huge_pmd(new_page, vma->vm_page_prot);
>  	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
>  
> @@ -1996,15 +1993,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,

There's a comment above this:

       /*
         * Clear the old entry under pagetable lock and establish the new PTE.
         * Any parallel GUP will either observe the old page blocking on the
         * page lock, block on the page table lock or observe the new page.
         * The SetPageUptodate on the new page and page_add_new_anon_rmap
         * guarantee the copy is visible before the pagetable update.
         */

Is it still correct? Didn't the freezing prevent some of the cases above?

>  	set_pmd_at(mm, mmun_start, pmd, entry);
>  	update_mmu_cache_pmd(vma, address, &entry);
>  
> -	if (page_count(page) != 2) {

BTW, how did the old code recognize that page count would increase and then
decrease back?

> -		set_pmd_at(mm, mmun_start, pmd, orig_entry);
> -		flush_pmd_tlb_range(vma, mmun_start, mmun_end);
> -		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
> -		update_mmu_cache_pmd(vma, address, &entry);
> -		page_remove_rmap(new_page, true);
> -		goto fail_putback;
> -	}
> -
> +	page_ref_unfreeze(page, 2);
>  	mlock_migrate_page(new_page, page);
>  	page_remove_rmap(page, true);
>  	set_page_owner_migrate_reason(new_page, MR_NUMA_MISPLACED);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
