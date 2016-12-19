Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEEDC6B029B
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 09:22:19 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so19870085wme.4
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:22:19 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id n64si14939265wmn.101.2016.12.19.06.22.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 06:22:18 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id kp2so23804251wjc.0
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:22:18 -0800 (PST)
Date: Mon, 19 Dec 2016 15:22:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm: drop zap_details::ignore_dirty
Message-ID: <20161219142216.GH5164@dhcp22.suse.cz>
References: <20161216141556.75130-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216141556.75130-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-12-16 17:15:53, Kirill A. Shutemov wrote:
> The only user of ignore_dirty is oom-reaper. But it doesn't really use
> it.
> 
> ignore_dirty only has effect on file pages mapped with dirty pte.
> But oom-repear skips shared VMAs, so there's no way we can dirty file
> pte in them.

Hmm, I am trying to rememeber why I've done that and it seems I was just
too paranoid and wanted to make sure that we never touch dirty mapped
pages. As you say this is not possible with the current implementation
so the patch should be OK.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm.h | 1 -
>  mm/memory.c        | 6 ------
>  mm/oom_kill.c      | 3 +--
>  3 files changed, 1 insertion(+), 9 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4424784ac374..7b8e425ac41c 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1148,7 +1148,6 @@ struct zap_details {
>  	struct address_space *check_mapping;	/* Check page->mapping if set */
>  	pgoff_t	first_index;			/* Lowest page->index to unmap */
>  	pgoff_t last_index;			/* Highest page->index to unmap */
> -	bool ignore_dirty;			/* Ignore dirty pages */
>  	bool check_swap_entries;		/* Check also swap entries */
>  };
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 455c3e628d52..6ac8fa56080f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1155,12 +1155,6 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  
>  			if (!PageAnon(page)) {
>  				if (pte_dirty(ptent)) {
> -					/*
> -					 * oom_reaper cannot tear down dirty
> -					 * pages
> -					 */
> -					if (unlikely(details && details->ignore_dirty))
> -						continue;
>  					force_flush = 1;
>  					set_page_dirty(page);
>  				}
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ec9f11d4f094..f101db68e760 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -465,8 +465,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  {
>  	struct mmu_gather tlb;
>  	struct vm_area_struct *vma;
> -	struct zap_details details = {.check_swap_entries = true,
> -				      .ignore_dirty = true};
> +	struct zap_details details = {.check_swap_entries = true};
>  	bool ret = true;
>  
>  	/*
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
