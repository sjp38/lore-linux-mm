Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id C72E26B0071
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 23:18:03 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id ro12so678701pbb.10
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 20:18:03 -0800 (PST)
Date: Tue, 8 Jan 2013 20:17:59 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: migrate: Check page_count of THP before migrating
In-Reply-To: <20130107170815.GO3885@suse.de>
Message-ID: <alpine.LNX.2.00.1301081931530.20504@eggly.anvils>
References: <20130107170815.GO3885@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 7 Jan 2013, Mel Gorman wrote:

> Hugh Dickins pointed out that migrate_misplaced_transhuge_page() does not
> check page_count before migrating like base page migration and khugepage. He
> could not see why this was safe and he is right.
> 
> The potential impact of the bug is avoided due to the limitations of NUMA
> balancing.  The page_mapcount() check ensures that only a single address
> space is using this page and as THPs are typically private it should not be
> possible for another address space to fault it in parallel. If the address
> space has one associated task then it's difficult to have both a GUP pin
> and be referencing the page at the same time. If there are multiple tasks
> then a buggy scenario requires that another thread be accessing the page
> while the direct IO is in flight. This is dodgy behaviour as there is
> a possibility of corruption with or without THP migration. It would be
> difficult to identify the corruption as being a migration bug.
> 
> While we happen to be safe for the most part it is shoddy to depend on
> such "safety" so this patch checks the page count similar to anonymous
> pages. Note that this does not mean that the page_mapcount() check can go
> away. If we were to remove the page_mapcount() check the the THP would
> have to be unmapped from all referencing PTEs, replaced with migration
> PTEs and restored properly afterwards.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Sorry, Mel, it's a NAK: you will have expected an ack from me two weeks
or more ago; but somehow I had an intuition that if I sat on it for
long enough, a worm would crawl out.  Got down to looking again today,
and I notice that although the putback_lru_page() is right,
NR_ISOLATED_ANON is not restored on this path, so that would leak.

I expect you'll want to do something like:
	if (isolated) {
		putback_lru_page(page);
		isolated = 0;
		goto out;
	}
and that may be the appropriate fix right now.

But I do still dislike the way you always put_page in
numamigrate_isolate_page(): it makes sense in the case when
isolate_lru_page() succeeds (I've long thought that weird both to
insist on an existing page reference and add one of its own), but
I find it very confusing on the failure paths, to have the put_page
far away from the unlock_page - and I get worried when I see put_page
followed by unlock_page rather than vice versa (it happens on !pmd_same
paths: if the pmd is not the same, then can we be sure that the put_page
does not free the page?)

At the bottom I've put my own cleanup for this, which simplifies by
doing the putback_lru_page() inside numamigrate_isolate_page(), and
doesn't put_page when it doesn't isolate.

I think the only functional difference from yours (aside from fixing
up NR_ISOLATED) is that migrate_misplaced_transhuge_page() doesn't
have to pretend to its caller that it succeeded when actually it
failed at the last hurdle (because it already did the unlock_page,
which in yours the caller expects to do on failure).  Oh, and I'm
not holding page lock (sometimes) at clear_pmdnuma: I didn't see
the reason for that, perhaps I'm missing something important there.

Maybe our tastes differ, and you won't see mine as an improvement.
And I've hardly tested, so haven't signed off, and won't be
surprised if its own worms crawl out.

Hugh

> ---
>  mm/migrate.c |   11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 3b676b0..f466827 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1679,9 +1679,18 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  	page_xchg_last_nid(new_page, page_last_nid(page));
>  
>  	isolated = numamigrate_isolate_page(pgdat, page);
> -	if (!isolated) {
> +
> +	/*
> +	 * Failing to isolate or a GUP pin prevents migration. The expected
> +	 * page count is 2. 1 for anonymous pages without a mapping and 1
> +	 * for the callers pin. If the page was isolated, the page will
> +	 * need to be put back on the LRU.
> +	 */
> +	if (!isolated || page_count(page) != 2) {
>  		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
>  		put_page(new_page);
> +		if (isolated)
> +			putback_lru_page(page);
>  		goto out_keep_locked;
>  	}

Not-signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/huge_memory.c |   28 +++++----------
 mm/migrate.c     |   79 ++++++++++++++++++++++-----------------------
 2 files changed, 48 insertions(+), 59 deletions(-)

--- 3.8-rc2/mm/huge_memory.c	2012-12-22 09:43:27.616015582 -0800
+++ linux/mm/huge_memory.c	2013-01-08 17:39:06.340407864 -0800
@@ -1298,7 +1298,6 @@ int do_huge_pmd_numa_page(struct mm_stru
 	int target_nid;
 	int current_nid = -1;
 	bool migrated;
-	bool page_locked = false;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
@@ -1320,7 +1319,6 @@ int do_huge_pmd_numa_page(struct mm_stru
 	/* Acquire the page lock to serialise THP migrations */
 	spin_unlock(&mm->page_table_lock);
 	lock_page(page);
-	page_locked = true;
 
 	/* Confirm the PTE did not while locked */
 	spin_lock(&mm->page_table_lock);
@@ -1333,34 +1331,26 @@ int do_huge_pmd_numa_page(struct mm_stru
 
 	/* Migrate the THP to the requested node */
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
-				pmdp, pmd, addr,
-				page, target_nid);
-	if (migrated)
-		current_nid = target_nid;
-	else {
-		spin_lock(&mm->page_table_lock);
-		if (unlikely(!pmd_same(pmd, *pmdp))) {
-			unlock_page(page);
-			goto out_unlock;
-		}
-		goto clear_pmdnuma;
-	}
+				pmdp, pmd, addr, page, target_nid);
+	if (!migrated)
+		goto check_same;
 
-	task_numa_fault(current_nid, HPAGE_PMD_NR, migrated);
+	task_numa_fault(target_nid, HPAGE_PMD_NR, true);
 	return 0;
 
+check_same:
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(pmd, *pmdp)))
+		goto out_unlock;
 clear_pmdnuma:
 	pmd = pmd_mknonnuma(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
 	VM_BUG_ON(pmd_numa(*pmdp));
 	update_mmu_cache_pmd(vma, addr, pmdp);
-	if (page_locked)
-		unlock_page(page);
-
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
 	if (current_nid != -1)
-		task_numa_fault(current_nid, HPAGE_PMD_NR, migrated);
+		task_numa_fault(current_nid, HPAGE_PMD_NR, false);
 	return 0;
 }
 
--- 3.8-rc2/mm/migrate.c	2012-12-22 09:43:27.636015582 -0800
+++ linux/mm/migrate.c	2013-01-08 18:17:02.664144777 -0800
@@ -1555,39 +1555,38 @@ bool numamigrate_update_ratelimit(pg_dat
 
 int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
-	int ret = 0;
+	int page_lru;
 
 	/* Avoid migrating to a node that is nearly full */
-	if (migrate_balanced_pgdat(pgdat, 1)) {
-		int page_lru;
+	if (!migrate_balanced_pgdat(pgdat, 1))
+		return 0;
 
-		if (isolate_lru_page(page)) {
-			put_page(page);
-			return 0;
-		}
-
-		/* Page is isolated */
-		ret = 1;
-		page_lru = page_is_file_cache(page);
-		if (!PageTransHuge(page))
-			inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
-		else
-			mod_zone_page_state(page_zone(page),
-					NR_ISOLATED_ANON + page_lru,
-					HPAGE_PMD_NR);
+	if (isolate_lru_page(page))
+		return 0;
+
+	/*
+	 * migrate_misplaced_transhuge_page() skips page migration's usual
+	 * check on page_count(), so we must do it here, now that the page
+	 * has been isolated: a GUP pin, or any other pin, prevents migration.
+	 * The expected page count is 3: 1 for page's mapcount and 1 for the
+	 * caller's pin and 1 for the reference taken by isolate_lru_page().
+	 */
+	if (PageTransHuge(page) && page_count(page) != 3) {
+		putback_lru_page(page);
+		return 0;
 	}
 
+	page_lru = page_is_file_cache(page);
+	mod_zone_page_state(page_zone(page), NR_ISOLATED_ANON + page_lru,
+				hpage_nr_pages(page));
+
 	/*
-	 * Page is either isolated or there is not enough space on the target
-	 * node. If isolated, then it has taken a reference count and the
-	 * callers reference can be safely dropped without the page
-	 * disappearing underneath us during migration. Otherwise the page is
-	 * not to be migrated but the callers reference should still be
-	 * dropped so it does not leak.
+	 * Isolating the page has taken another reference, so the
+	 * caller's reference can be safely dropped without the page
+	 * disappearing underneath us during migration.
 	 */
 	put_page(page);
-
-	return ret;
+	return 1;
 }
 
 /*
@@ -1598,7 +1597,7 @@ int numamigrate_isolate_page(pg_data_t *
 int migrate_misplaced_page(struct page *page, int node)
 {
 	pg_data_t *pgdat = NODE_DATA(node);
-	int isolated = 0;
+	int isolated;
 	int nr_remaining;
 	LIST_HEAD(migratepages);
 
@@ -1606,20 +1605,16 @@ int migrate_misplaced_page(struct page *
 	 * Don't migrate pages that are mapped in multiple processes.
 	 * TODO: Handle false sharing detection instead of this hammer
 	 */
-	if (page_mapcount(page) != 1) {
-		put_page(page);
+	if (page_mapcount(page) != 1)
 		goto out;
-	}
 
 	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
 	 * Optimal placement is no good if the memory bus is saturated and
 	 * all the time is being spent migrating!
 	 */
-	if (numamigrate_update_ratelimit(pgdat, 1)) {
-		put_page(page);
+	if (numamigrate_update_ratelimit(pgdat, 1))
 		goto out;
-	}
 
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated)
@@ -1636,8 +1631,11 @@ int migrate_misplaced_page(struct page *
 	} else
 		count_vm_numa_event(NUMA_PAGE_MIGRATE);
 	BUG_ON(!list_empty(&migratepages));
-out:
 	return isolated;
+
+out:
+	put_page(page);
+	return 0;
 }
 #endif /* CONFIG_NUMA_BALANCING */
 
@@ -1672,17 +1670,15 @@ int migrate_misplaced_transhuge_page(str
 
 	new_page = alloc_pages_node(node,
 		(GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT, HPAGE_PMD_ORDER);
-	if (!new_page) {
-		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
-		goto out_dropref;
-	}
+	if (!new_page)
+		goto out_fail;
+
 	page_xchg_last_nid(new_page, page_last_nid(page));
 
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated) {
-		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
 		put_page(new_page);
-		goto out_keep_locked;
+		goto out_fail;
 	}
 
 	/* Prepare a page as a migration target */
@@ -1714,6 +1710,7 @@ int migrate_misplaced_transhuge_page(str
 		putback_lru_page(page);
 
 		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
+		isolated = 0;
 		goto out;
 	}
 
@@ -1758,9 +1755,11 @@ out:
 			-HPAGE_PMD_NR);
 	return isolated;
 
+out_fail:
+	count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
 out_dropref:
+	unlock_page(page);
 	put_page(page);
-out_keep_locked:
 	return 0;
 }
 #endif /* CONFIG_NUMA_BALANCING */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
