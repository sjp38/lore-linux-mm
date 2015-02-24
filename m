Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id BC9F96B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 08:45:33 -0500 (EST)
Received: by wghk14 with SMTP id k14so5363085wgh.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 05:45:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jj6si23661589wid.41.2015.02.24.05.45.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 05:45:30 -0800 (PST)
Date: Tue, 24 Feb 2015 14:45:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V5 2/4] mm: Refactor do_wp_page - rewrite the unlock flow
Message-ID: <20150224134528.GB15626@dhcp22.suse.cz>
References: <1424612538-25889-1-git-send-email-raindel@mellanox.com>
 <1424612538-25889-3-git-send-email-raindel@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424612538-25889-3-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com, Dave Hansen <dave.hansen@intel.com>

On Sun 22-02-15 15:42:16, Shachar Raindel wrote:
> When do_wp_page is ending, in several cases it needs to unlock the
> pages and ptls it was accessing.
> 
> Currently, this logic was "called" by using a goto jump. This makes
> following the control flow of the function harder. Readability was
> further hampered by the unlock case containing large amount of logic
> needed only in one of the 3 cases.
> 
> Using goto for cleanup is generally allowed. However, moving the
> trivial unlocking flows to the relevant call sites allow deeper
> refactoring in the next patch.
> 
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>
> Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Acked-by: Haggai Eran <haggaie@mellanox.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Peter Feiner <pfeiner@google.com>
> Cc: Michel Lespinasse <walken@google.com>

Neat!
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memory.c | 21 ++++++++++++---------
>  1 file changed, 12 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 7a04414..3afd9ce 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2066,7 +2066,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  {
>  	struct page *old_page, *new_page = NULL;
>  	pte_t entry;
> -	int ret = 0;
> +	int page_copied = 0;
>  	unsigned long mmun_start = 0;	/* For mmu_notifiers */
>  	unsigned long mmun_end = 0;	/* For mmu_notifiers */
>  	struct mem_cgroup *memcg;
> @@ -2101,7 +2101,9 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  							 &ptl);
>  			if (!pte_same(*page_table, orig_pte)) {
>  				unlock_page(old_page);
> -				goto unlock;
> +				pte_unmap_unlock(page_table, ptl);
> +				page_cache_release(old_page);
> +				return 0;
>  			}
>  			page_cache_release(old_page);
>  		}
> @@ -2148,7 +2150,9 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  							 &ptl);
>  			if (!pte_same(*page_table, orig_pte)) {
>  				unlock_page(old_page);
> -				goto unlock;
> +				pte_unmap_unlock(page_table, ptl);
> +				page_cache_release(old_page);
> +				return 0;
>  			}
>  			page_mkwrite = 1;
>  		}
> @@ -2246,29 +2250,28 @@ gotten:
>  
>  		/* Free the old page.. */
>  		new_page = old_page;
> -		ret |= VM_FAULT_WRITE;
> +		page_copied = 1;
>  	} else
>  		mem_cgroup_cancel_charge(new_page, memcg);
>  
>  	if (new_page)
>  		page_cache_release(new_page);
> -unlock:
> +
>  	pte_unmap_unlock(page_table, ptl);
> -	if (mmun_end > mmun_start)
> -		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>  	if (old_page) {
>  		/*
>  		 * Don't let another task, with possibly unlocked vma,
>  		 * keep the mlocked page.
>  		 */
> -		if ((ret & VM_FAULT_WRITE) && (vma->vm_flags & VM_LOCKED)) {
> +		if (page_copied && (vma->vm_flags & VM_LOCKED)) {
>  			lock_page(old_page);	/* LRU manipulation */
>  			munlock_vma_page(old_page);
>  			unlock_page(old_page);
>  		}
>  		page_cache_release(old_page);
>  	}
> -	return ret;
> +	return page_copied ? VM_FAULT_WRITE : 0;
>  oom_free_new:
>  	page_cache_release(new_page);
>  oom:
> -- 
> 1.7.11.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
