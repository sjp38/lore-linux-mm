Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2390A6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 21:32:16 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d185so219933009pgc.2
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 18:32:16 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id v128si17470271pgv.72.2017.01.23.18.32.14
        for <linux-mm@kvack.org>;
        Mon, 23 Jan 2017 18:32:15 -0800 (PST)
Date: Tue, 24 Jan 2017 11:32:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: write protect MADV_FREE pages
Message-ID: <20170124023212.GA24523@bbox>
References: <791151284cd6941296f08488b8cb7f1968175a0a.1485212872.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <791151284cd6941296f08488b8cb7f1968175a0a.1485212872.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@surriel.com>, stable@kernel.org

Hi Shaohua,

On Mon, Jan 23, 2017 at 03:15:52PM -0800, Shaohua Li wrote:
> The page reclaim has an assumption writting to a page with clean pte
> should trigger a page fault, because there is a window between pte zero
> and tlb flush where a new write could come. If the new write doesn't
> trigger page fault, page reclaim will not notice it and think the page
> is clean and reclaim it. The MADV_FREE pages don't comply with the rule
> and the pte is just cleaned without writeprotect, so there will be no
> pagefault for new write. This will cause data corruption.

It's hard to understand.
Could you show me exact scenario seqence you have in mind?

Thanks.

> 
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: stable@kernel.org
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---
>  mm/huge_memory.c | 1 +
>  mm/madvise.c     | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 9a6bd6c..9cc5de5 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1381,6 +1381,7 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  			tlb->fullmm);
>  		orig_pmd = pmd_mkold(orig_pmd);
>  		orig_pmd = pmd_mkclean(orig_pmd);
> +		orig_pmd = pmd_wrprotect(orig_pmd);
>  
>  		set_pmd_at(mm, addr, pmd, orig_pmd);
>  		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 0e3828e..bfb6800 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -373,6 +373,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  
>  			ptent = pte_mkold(ptent);
>  			ptent = pte_mkclean(ptent);
> +			ptent = pte_wrprotect(ptent);
>  			set_pte_at(mm, addr, pte, ptent);
>  			if (PageActive(page))
>  				deactivate_page(page);
> -- 
> 2.9.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
