Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDB86B029D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 09:29:18 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xy5so47888123wjc.0
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:29:18 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id i8si18628131wjo.262.2016.12.19.06.29.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 06:29:16 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id he10so23887992wjc.2
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:29:16 -0800 (PST)
Date: Mon, 19 Dec 2016 15:29:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] mm: drop zap_details::check_swap_entries
Message-ID: <20161219142914.GI5164@dhcp22.suse.cz>
References: <20161216141556.75130-1-kirill.shutemov@linux.intel.com>
 <20161216141556.75130-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216141556.75130-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-12-16 17:15:54, Kirill A. Shutemov wrote:
> detail == NULL would give the same functionality as
> .check_swap_entries==true.

Yes, now that check_swap_entries is the only used flag from there we can
safely rely on detail == NULL check.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm.h | 1 -
>  mm/memory.c        | 4 ++--
>  mm/oom_kill.c      | 3 +--
>  3 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7b8e425ac41c..5f6bea4c9d41 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1148,7 +1148,6 @@ struct zap_details {
>  	struct address_space *check_mapping;	/* Check page->mapping if set */
>  	pgoff_t	first_index;			/* Lowest page->index to unmap */
>  	pgoff_t last_index;			/* Highest page->index to unmap */
> -	bool check_swap_entries;		/* Check also swap entries */
>  };
>  
>  struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> diff --git a/mm/memory.c b/mm/memory.c
> index 6ac8fa56080f..c03b18f13619 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1173,8 +1173,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  			}
>  			continue;
>  		}
> -		/* only check swap_entries if explicitly asked for in details */
> -		if (unlikely(details && !details->check_swap_entries))
> +		/* If details->check_mapping, we leave swap entries. */
> +		if (unlikely(details))
>  			continue;
>  
>  		entry = pte_to_swp_entry(ptent);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f101db68e760..96a53ab0c9eb 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -465,7 +465,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  {
>  	struct mmu_gather tlb;
>  	struct vm_area_struct *vma;
> -	struct zap_details details = {.check_swap_entries = true};
>  	bool ret = true;
>  
>  	/*
> @@ -531,7 +530,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  		 */
>  		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
>  			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
> -					 &details);
> +					 NULL);
>  	}
>  	tlb_finish_mmu(&tlb, 0, -1);
>  	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> -- 
> 2.10.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
