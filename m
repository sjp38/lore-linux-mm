Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id DAB95828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:37:33 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id c1so15724698lbw.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:37:33 -0700 (PDT)
Received: from mail-lf0-f65.google.com (mail-lf0-f65.google.com. [209.85.215.65])
        by mx.google.com with ESMTPS id g25si29407461lji.63.2016.06.21.07.37.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 07:37:32 -0700 (PDT)
Received: by mail-lf0-f65.google.com with SMTP id l188so4059740lfe.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:37:32 -0700 (PDT)
Date: Tue, 21 Jun 2016 16:37:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/huge_memory: fix the memory leak due to the race
Message-ID: <20160621143731.GH30848@dhcp22.suse.cz>
References: <1466517956-13875-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466517956-13875-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

[CCing Kirill]

On Tue 21-06-16 22:05:56, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> with great pressure, I run some test cases. As a result, I found
> that the THP is not freed, it is detected by check_mm().
> 
> BUG: Bad rss-counter state mm:ffff8827edb70000 idx:1 val:512
> 
> Consider the following race :
> 
> 	CPU0                               CPU1
>   __handle_mm_fault()
>         wp_huge_pmd()
>    	    do_huge_pmd_wp_page()
> 		pmdp_huge_clear_flush_notify()
>                 (pmd_none = true)
> 					exit_mmap()
> 					   unmap_vmas()
> 					     zap_pmd_range()
> 						pmd_none_or_trans_huge_or_clear_bad()
> 						   (result in memory leak)
>                 set_pmd_at()
>
> because of CPU0 have allocated huge page before pmdp_huge_clear_notify,
> and it make the pmd entry to be null. Therefore, The memory leak can occur.

I do not understand this description. CPU1 is in the exit path with last
mm user gone. So CPU0 is a different process with its own mm. How can
they influence each other. But maybe I am just missing your point.
 
> The patch fix the scenario that the pmd entry can lead to be null.
> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/huge_memory.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e10a4fe..ef04b94 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1340,11 +1340,11 @@ alloc:
>  		pmd_t entry;
>  		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
>  		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> -		pmdp_huge_clear_flush_notify(vma, haddr, pmd);
> +		pmdp_invalidate(vma, haddr, pmd);	
>  		page_add_new_anon_rmap(new_page, vma, haddr, true);
>  		mem_cgroup_commit_charge(new_page, memcg, false, true);
>  		lru_cache_add_active_or_unevictable(new_page, vma);
> -		set_pmd_at(mm, haddr, pmd, entry);
> +		pmd_populate(mm, pmd, entry);
>  		update_mmu_cache_pmd(vma, address, pmd);
>  		if (!page) {
>  			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
