Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 901BF6B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 16:20:33 -0500 (EST)
Received: by mail-da0-f47.google.com with SMTP id s35so934441dak.6
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 13:20:32 -0800 (PST)
Date: Sun, 27 Jan 2013 13:20:28 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/6] mm: numa: Cleanup flow of transhuge page migration
In-Reply-To: <1358874762-19717-7-git-send-email-mgorman@suse.de>
Message-ID: <alpine.LNX.2.00.1301271301001.16981@eggly.anvils>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de> <1358874762-19717-7-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 22 Jan 2013, Mel Gorman wrote:
> From: Hugh Dickins <hughd@google.com>
> 
> When correcting commit 04fa5d6a (mm: migrate: check page_count of
> THP before migrating) Hugh Dickins noted that the control flow for
> transhuge migration was difficult to follow. Unconditionally calling
> put_page() in numamigrate_isolate_page() made the failure paths of both
> migrate_misplaced_transhuge_page() and migrate_misplaced_page() more complex
> that they should be. Further, he was extremely wary that an unlock_page()
> should ever happen after a put_page() even if the put_page() should never
> be the final put_page.

Yes, I wasn't entirely convinced by your argument for why the unlock_page()
after put_page() had to be safe, given that it was coming on !pmd_same()
paths where we were backing out because the situation has changed beyond
our ken.  Not that I'd ever experienced any trouble from those (a final
free with page locked is sure to complain of bad page state).

It left me wondering whether some of those !pmd_same checks are simply
unnecessary: can others change the pmd_numa once we hold the page lock?

It would be nice ot eliminate some of the backtracking (most especially
the "Reverse changes made by migrate_page_copy()" area - though that's
a path which was managing its own unlock_page before putback_lru_page)
if it actually cannot play a part; but I've done nothing to investigate
further, and it may be obvious to you that I'm just blathering.

And certainly not something to get into in this patch.

> 
> Hugh implemented the following cleanup to simplify the path by
> calling putback_lru_page() inside numamigrate_isolate_page()
> if it failed to isolate and always calling unlock_page() within
> migrate_misplaced_transhuge_page(). There is no functional change after
> this patch is applied but the code is easier to follow and unlock_page()
> always happens before put_page().
> 
> [mgorman@suse.de: changelog only]

Thanks a lot for taking this on board, Mel, doing changelog and updiff.
I've now checked against what I was running with troublefree for the
week of 3.8-rc3, and am happy for Andrew now to insert my

Signed-off-by: Hugh Dickins <hughd@google.com>

> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/huge_memory.c |   28 ++++++----------
>  mm/migrate.c     |   95 ++++++++++++++++++++++++------------------------------
>  2 files changed, 52 insertions(+), 71 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 6001ee6..648c102 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1298,7 +1298,6 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	int target_nid;
>  	int current_nid = -1;
>  	bool migrated;
> -	bool page_locked = false;
>  
>  	spin_lock(&mm->page_table_lock);
>  	if (unlikely(!pmd_same(pmd, *pmdp)))
> @@ -1320,7 +1319,6 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	/* Acquire the page lock to serialise THP migrations */
>  	spin_unlock(&mm->page_table_lock);
>  	lock_page(page);
> -	page_locked = true;
>  
>  	/* Confirm the PTE did not while locked */
>  	spin_lock(&mm->page_table_lock);
> @@ -1333,34 +1331,26 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	/* Migrate the THP to the requested node */
>  	migrated = migrate_misplaced_transhuge_page(mm, vma,
> -				pmdp, pmd, addr,
> -				page, target_nid);
> -	if (migrated)
> -		current_nid = target_nid;
> -	else {
> -		spin_lock(&mm->page_table_lock);
> -		if (unlikely(!pmd_same(pmd, *pmdp))) {
> -			unlock_page(page);
> -			goto out_unlock;
> -		}
> -		goto clear_pmdnuma;
> -	}
> +				pmdp, pmd, addr, page, target_nid);
> +	if (!migrated)
> +		goto check_same;
>  
> -	task_numa_fault(current_nid, HPAGE_PMD_NR, migrated);
> +	task_numa_fault(target_nid, HPAGE_PMD_NR, true);
>  	return 0;
>  
> +check_same:
> +	spin_lock(&mm->page_table_lock);
> +	if (unlikely(!pmd_same(pmd, *pmdp)))
> +		goto out_unlock;
>  clear_pmdnuma:
>  	pmd = pmd_mknonnuma(pmd);
>  	set_pmd_at(mm, haddr, pmdp, pmd);
>  	VM_BUG_ON(pmd_numa(*pmdp));
>  	update_mmu_cache_pmd(vma, addr, pmdp);
> -	if (page_locked)
> -		unlock_page(page);
> -
>  out_unlock:
>  	spin_unlock(&mm->page_table_lock);
>  	if (current_nid != -1)
> -		task_numa_fault(current_nid, HPAGE_PMD_NR, migrated);
> +		task_numa_fault(current_nid, HPAGE_PMD_NR, false);
>  	return 0;
>  }
>  
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 73e432d..8ef1cbf 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1555,41 +1555,40 @@ bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
>  
>  int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>  {
> -	int ret = 0;
> +	int page_lru;
>  
>  	VM_BUG_ON(compound_order(page) && !PageTransHuge(page));
>  
>  	/* Avoid migrating to a node that is nearly full */
> -	if (migrate_balanced_pgdat(pgdat, 1UL << compound_order(page))) {
> -		int page_lru;
> +	if (!migrate_balanced_pgdat(pgdat, 1UL << compound_order(page)))
> +		return 0;
>  
> -		if (isolate_lru_page(page)) {
> -			put_page(page);
> -			return 0;
> -		}
> +	if (isolate_lru_page(page))
> +		return 0;
>  
> -		/* Page is isolated */
> -		ret = 1;
> -		page_lru = page_is_file_cache(page);
> -		if (!PageTransHuge(page))
> -			inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
> -		else
> -			mod_zone_page_state(page_zone(page),
> -					NR_ISOLATED_ANON + page_lru,
> -					HPAGE_PMD_NR);
> +	/*
> +	 * migrate_misplaced_transhuge_page() skips page migration's usual
> +	 * check on page_count(), so we must do it here, now that the page
> +	 * has been isolated: a GUP pin, or any other pin, prevents migration.
> +	 * The expected page count is 3: 1 for page's mapcount and 1 for the
> +	 * caller's pin and 1 for the reference taken by isolate_lru_page().
> +	 */
> +	if (PageTransHuge(page) && page_count(page) != 3) {
> +		putback_lru_page(page);
> +		return 0;
>  	}
>  
> +	page_lru = page_is_file_cache(page);
> +	mod_zone_page_state(page_zone(page), NR_ISOLATED_ANON + page_lru,
> +				hpage_nr_pages(page));
> +
>  	/*
> -	 * Page is either isolated or there is not enough space on the target
> -	 * node. If isolated, then it has taken a reference count and the
> -	 * callers reference can be safely dropped without the page
> -	 * disappearing underneath us during migration. Otherwise the page is
> -	 * not to be migrated but the callers reference should still be
> -	 * dropped so it does not leak.
> +	 * Isolating the page has taken another reference, so the
> +	 * caller's reference can be safely dropped without the page
> +	 * disappearing underneath us during migration.
>  	 */
>  	put_page(page);
> -
> -	return ret;
> +	return 1;
>  }
>  
>  /*
> @@ -1600,7 +1599,7 @@ int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>  int migrate_misplaced_page(struct page *page, int node)
>  {
>  	pg_data_t *pgdat = NODE_DATA(node);
> -	int isolated = 0;
> +	int isolated;
>  	int nr_remaining;
>  	LIST_HEAD(migratepages);
>  
> @@ -1608,20 +1607,16 @@ int migrate_misplaced_page(struct page *page, int node)
>  	 * Don't migrate pages that are mapped in multiple processes.
>  	 * TODO: Handle false sharing detection instead of this hammer
>  	 */
> -	if (page_mapcount(page) != 1) {
> -		put_page(page);
> +	if (page_mapcount(page) != 1)
>  		goto out;
> -	}
>  
>  	/*
>  	 * Rate-limit the amount of data that is being migrated to a node.
>  	 * Optimal placement is no good if the memory bus is saturated and
>  	 * all the time is being spent migrating!
>  	 */
> -	if (numamigrate_update_ratelimit(pgdat, 1)) {
> -		put_page(page);
> +	if (numamigrate_update_ratelimit(pgdat, 1))
>  		goto out;
> -	}
>  
>  	isolated = numamigrate_isolate_page(pgdat, page);
>  	if (!isolated)
> @@ -1638,12 +1633,19 @@ int migrate_misplaced_page(struct page *page, int node)
>  	} else
>  		count_vm_numa_event(NUMA_PAGE_MIGRATE);
>  	BUG_ON(!list_empty(&migratepages));
> -out:
>  	return isolated;
> +
> +out:
> +	put_page(page);
> +	return 0;
>  }
>  #endif /* CONFIG_NUMA_BALANCING */
>  
>  #if defined(CONFIG_NUMA_BALANCING) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
> +/*
> + * Migrates a THP to a given target node. page must be locked and is unlocked
> + * before returning.
> + */
>  int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  				struct vm_area_struct *vma,
>  				pmd_t *pmd, pmd_t entry,
> @@ -1674,29 +1676,15 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  
>  	new_page = alloc_pages_node(node,
>  		(GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT, HPAGE_PMD_ORDER);
> -	if (!new_page) {
> -		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
> -		goto out_dropref;
> -	}
> +	if (!new_page)
> +		goto out_fail;
> +
>  	page_xchg_last_nid(new_page, page_last_nid(page));
>  
>  	isolated = numamigrate_isolate_page(pgdat, page);
> -
> -	/*
> -	 * Failing to isolate or a GUP pin prevents migration. The expected
> -	 * page count is 2. 1 for anonymous pages without a mapping and 1
> -	 * for the callers pin. If the page was isolated, the page will
> -	 * need to be put back on the LRU.
> -	 */
> -	if (!isolated || page_count(page) != 2) {
> -		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
> +	if (!isolated) {
>  		put_page(new_page);
> -		if (isolated) {
> -			putback_lru_page(page);
> -			isolated = 0;
> -			goto out;
> -		}
> -		goto out_keep_locked;
> +		goto out_fail;
>  	}
>  
>  	/* Prepare a page as a migration target */
> @@ -1728,6 +1716,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  		putback_lru_page(page);
>  
>  		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
> +		isolated = 0;
>  		goto out;
>  	}
>  
> @@ -1772,9 +1761,11 @@ out:
>  			-HPAGE_PMD_NR);
>  	return isolated;
>  
> +out_fail:
> +	count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
>  out_dropref:
> +	unlock_page(page);
>  	put_page(page);
> -out_keep_locked:
>  	return 0;
>  }
>  #endif /* CONFIG_NUMA_BALANCING */
> -- 
> 1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
