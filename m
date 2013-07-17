Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 97F2B6B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 01:22:30 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id dn14so1772387obc.30
        for <linux-mm@kvack.org>; Tue, 16 Jul 2013 22:22:29 -0700 (PDT)
Message-ID: <51E62A0E.1070102@gmail.com>
Date: Wed, 17 Jul 2013 13:22:22 +0800
From: Sam Ben <sam.bennn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/18] mm: numa: Scan pages with elevated page_mapcount
References: <1373901620-2021-1-git-send-email-mgorman@suse.de> <1373901620-2021-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1373901620-2021-14-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/15/2013 11:20 PM, Mel Gorman wrote:
> Currently automatic NUMA balancing is unable to distinguish between false
> shared versus private pages except by ignoring pages with an elevated

What's the meaning of false shared?

> page_mapcount entirely. This avoids shared pages bouncing between the
> nodes whose task is using them but that is ignored quite a lot of data.
>
> This patch kicks away the training wheels in preparation for adding support
> for identifying shared/private pages is now in place. The ordering is so
> that the impact of the shared/private detection can be easily measured. Note
> that the patch does not migrate shared, file-backed within vmas marked
> VM_EXEC as these are generally shared library pages. Migrating such pages
> is not beneficial as there is an expectation they are read-shared between
> caches and iTLB and iCache pressure is generally low.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>   include/linux/migrate.h |  7 ++++---
>   mm/memory.c             |  7 ++-----
>   mm/migrate.c            | 17 ++++++-----------
>   mm/mprotect.c           |  4 +---
>   4 files changed, 13 insertions(+), 22 deletions(-)
>
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index a405d3dc..e7e26af 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -92,11 +92,12 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
>   #endif /* CONFIG_MIGRATION */
>   
>   #ifdef CONFIG_NUMA_BALANCING
> -extern int migrate_misplaced_page(struct page *page, int node);
> -extern int migrate_misplaced_page(struct page *page, int node);
> +extern int migrate_misplaced_page(struct page *page,
> +				  struct vm_area_struct *vma, int node);
>   extern bool migrate_ratelimited(int node);
>   #else
> -static inline int migrate_misplaced_page(struct page *page, int node)
> +static inline int migrate_misplaced_page(struct page *page,
> +					 struct vm_area_struct *vma, int node)
>   {
>   	return -EAGAIN; /* can't migrate now */
>   }
> diff --git a/mm/memory.c b/mm/memory.c
> index ab933be..62ae8a7 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3586,7 +3586,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   	}
>   
>   	/* Migrate to the requested node */
> -	migrated = migrate_misplaced_page(page, target_nid);
> +	migrated = migrate_misplaced_page(page, vma, target_nid);
>   	if (migrated)
>   		current_nid = target_nid;
>   
> @@ -3651,9 +3651,6 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   		page = vm_normal_page(vma, addr, pteval);
>   		if (unlikely(!page))
>   			continue;
> -		/* only check non-shared pages */
> -		if (unlikely(page_mapcount(page) != 1))
> -			continue;
>   
>   		/*
>   		 * Note that the NUMA fault is later accounted to either
> @@ -3671,7 +3668,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   
>   		/* Migrate to the requested node */
>   		pte_unmap_unlock(pte, ptl);
> -		migrated = migrate_misplaced_page(page, target_nid);
> +		migrated = migrate_misplaced_page(page, vma, target_nid);
>   		if (migrated)
>   			curr_nid = target_nid;
>   		task_numa_fault(last_nid, curr_nid, 1, migrated);
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 3bbaf5d..23f8122 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1579,7 +1579,8 @@ int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>    * node. Caller is expected to have an elevated reference count on
>    * the page that will be dropped by this function before returning.
>    */
> -int migrate_misplaced_page(struct page *page, int node)
> +int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
> +			   int node)
>   {
>   	pg_data_t *pgdat = NODE_DATA(node);
>   	int isolated;
> @@ -1587,10 +1588,11 @@ int migrate_misplaced_page(struct page *page, int node)
>   	LIST_HEAD(migratepages);
>   
>   	/*
> -	 * Don't migrate pages that are mapped in multiple processes.
> -	 * TODO: Handle false sharing detection instead of this hammer
> +	 * Don't migrate file pages that are mapped in multiple processes
> +	 * with execute permissions as they are probably shared libraries.
>   	 */
> -	if (page_mapcount(page) != 1)
> +	if (page_mapcount(page) != 1 && page_is_file_cache(page) &&
> +	    (vma->vm_flags & VM_EXEC))
>   		goto out;
>   
>   	/*
> @@ -1641,13 +1643,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>   	int page_lru = page_is_file_cache(page);
>   
>   	/*
> -	 * Don't migrate pages that are mapped in multiple processes.
> -	 * TODO: Handle false sharing detection instead of this hammer
> -	 */
> -	if (page_mapcount(page) != 1)
> -		goto out_dropref;
> -
> -	/*
>   	 * Rate-limit the amount of data that is being migrated to a node.
>   	 * Optimal placement is no good if the memory bus is saturated and
>   	 * all the time is being spent migrating!
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 94722a4..cacc64a 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -69,9 +69,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>   					if (last_nid != this_nid)
>   						all_same_node = false;
>   
> -					/* only check non-shared pages */
> -					if (!pte_numa(oldpte) &&
> -					    page_mapcount(page) == 1) {
> +					if (!pte_numa(oldpte)) {
>   						ptent = pte_mknuma(ptent);
>   						updated = true;
>   					}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
