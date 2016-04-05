Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DA1D7828DF
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:55:00 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id td3so18591953pab.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:55:00 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id kq10si10128376pab.242.2016.04.05.14.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:54:59 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id n1so18905676pfn.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:54:59 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:54:57 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 24/31] huge tmpfs recovery: shmem_recovery_populate to fill
 huge page
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051453360.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The outline of shmem_recovery_populate() is straightforward: a loop
applying shmem_getpage_gfp() to each offset that belongs to the extent,
converting swapcache to pagecache, checking existing pagecache, or
allocating new pagecache; adding each correctly placed page into the
team, or isolating each misplaced page, for passing to migrate_pages()
at the end of the loop.  Repeated (skipping quickly over those pages
resolved in the previous pass) to add in those pages just migrated,
until the team is complete, or cannot be completed.

But the details are difficult: not so much an architected design,
as a series of improvisations arrived at by trial and much error,
which in the end works well.  It has to cope with a variety of races:
pages being concurrently created or swapped in or disbanded or deleted
by other actors.

Most awkward is the handling of the head page of the team: which,
as usual, needs PageTeam and mapping and index set even before it
is instantiated (so that shmem_hugeteam_lookup() can validate tails
against it); but must not be confused with an instantiated team page
until PageSwapBacked is set.  This awkwardness is compounded by the
(unlocked) interval between when migrate_pages() migrates an old page
into its new team location, and the next repeat of the loop which fixes
the new location as PageTeam.  Yet migrate_page_move_mapping() will have
already composed PageSwapBacked (from old page) with PageTeam (from new)
in the case of the team head: "account_head" to track this case correctly,
but a later patch offers a tighter alternative to remove the need for it.

That interval between migration and enteamment also involves giving
up on the SHMEM_RETRY_HUGE_PAGE option from shmem_hugeteam_lookup():
SHMEM_ALLOC_SMALL_PAGE is not ideal, but does for now; and the later
patch can restore the SHMEM_RETRY_HUGE_PAGE optimization.

Note: this series was originally written with a swapin pass before
population, whereas this commit simply lets shmem_getpage_gfp() do the
swapin synchronously.  The swapin pass is reintroduced as an optimization
afterwards, but some comments on swap in this commit may anticipate that:
sorry, a precise sequence of developing comments took too much trouble.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/migrate.h        |    1 
 include/trace/events/migrate.h |    3 
 mm/migrate.c                   |   15 +
 mm/shmem.c                     |  339 +++++++++++++++++++++++++++++--
 4 files changed, 338 insertions(+), 20 deletions(-)

--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -25,6 +25,7 @@ enum migrate_reason {
 	MR_NUMA_MISPLACED,
 	MR_CMA,
 	MR_SHMEM_HUGEHOLE,
+	MR_SHMEM_RECOVERY,
 	MR_TYPES
 };
 
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -20,7 +20,8 @@
 	EM( MR_MEMPOLICY_MBIND,	"mempolicy_mbind")		\
 	EM( MR_NUMA_MISPLACED,	"numa_misplaced")		\
 	EM( MR_CMA,		"cma")				\
-	EMe(MR_SHMEM_HUGEHOLE,	"shmem_hugehole")
+	EM( MR_SHMEM_HUGEHOLE,	"shmem_hugehole")		\
+	EMe(MR_SHMEM_RECOVERY,	"shmem_recovery")
 
 /*
  * First define the enums in the above macros to be exported to userspace
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -786,7 +786,7 @@ static int move_to_new_page(struct page
 }
 
 static int __unmap_and_move(struct page *page, struct page *newpage,
-				int force, enum migrate_mode mode)
+		int force, enum migrate_mode mode, enum migrate_reason reason)
 {
 	int rc = -EAGAIN;
 	int page_was_mapped = 0;
@@ -815,6 +815,17 @@ static int __unmap_and_move(struct page
 		lock_page(page);
 	}
 
+	/*
+	 * huge tmpfs recovery: must not proceed if page has been truncated,
+	 * because the newpage we are about to migrate into *might* then be
+	 * already in use, on lru, with data newly written for that offset.
+	 * We can only be sure of this check once we have the page locked.
+	 */
+	if (reason == MR_SHMEM_RECOVERY && !page->mapping) {
+		rc = -ENOMEM;	/* quit migrate_pages() immediately */
+		goto out_unlock;
+	}
+
 	if (PageWriteback(page)) {
 		/*
 		 * Only in the case of a full synchronous migration is it
@@ -962,7 +973,7 @@ static ICE_noinline int unmap_and_move(n
 			goto out;
 	}
 
-	rc = __unmap_and_move(page, newpage, force, mode);
+	rc = __unmap_and_move(page, newpage, force, mode, reason);
 	if (rc == MIGRATEPAGE_SUCCESS) {
 		put_new_page = NULL;
 		set_page_owner_migrate_reason(newpage, reason);
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -60,6 +60,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/security.h>
 #include <linux/shrinker.h>
 #include <linux/workqueue.h>
+#include <linux/rmap.h>
 #include <linux/sysctl.h>
 #include <linux/swapops.h>
 #include <linux/pageteam.h>
@@ -305,7 +306,6 @@ static bool shmem_confirm_swap(struct ad
 /* hugehint values: NULL to choose a small page always */
 #define SHMEM_ALLOC_SMALL_PAGE	((struct page *)1)
 #define SHMEM_ALLOC_HUGE_PAGE	((struct page *)2)
-#define SHMEM_RETRY_HUGE_PAGE	((struct page *)3)
 /* otherwise hugehint is the hugeteam page to be used */
 
 /* tag for shrinker to locate unfilled hugepages */
@@ -368,6 +368,20 @@ restart:
 			put_page(page);
 		return SHMEM_ALLOC_SMALL_PAGE;
 	}
+	if (PageSwapBacked(page)) {
+		if (speculative)
+			put_page(page);
+		/*
+		 * This is very often a case of two tasks racing to instantiate
+		 * the same hole in the huge page, and we don't particularly
+		 * want to allocate a small page.  But holepunch racing with
+		 * recovery migration, in between migrating to the page and
+		 * marking it team, can leave a PageSwapBacked NULL mapping
+		 * page here which we should avoid, and this is the easiest
+		 * way to handle all the cases correctly.
+		 */
+		return SHMEM_ALLOC_SMALL_PAGE;
+	}
 	return page;
 }
 
@@ -407,16 +421,18 @@ static void shmem_added_to_hugeteam(stru
 {
 	struct address_space *mapping = page->mapping;
 	struct page *head = team_head(page);
+	long team_usage;
 
-	if (hugehint == SHMEM_ALLOC_HUGE_PAGE) {
-		atomic_long_set(&head->team_usage,
-				TEAM_PAGE_COUNTER + TEAM_LRU_WEIGHT_ONE);
-		radix_tree_tag_set(&mapping->page_tree, page->index,
+	VM_BUG_ON_PAGE(!PageTeam(page), page);
+	team_usage = atomic_long_add_return(TEAM_PAGE_COUNTER,
+					    &head->team_usage);
+	if (team_usage < TEAM_PAGE_COUNTER + TEAM_PAGE_COUNTER) {
+		if (hugehint == SHMEM_ALLOC_HUGE_PAGE)
+			radix_tree_tag_set(&mapping->page_tree, page->index,
 					SHMEM_TAG_HUGEHOLE);
 		__mod_zone_page_state(zone, NR_SHMEM_FREEHOLES, HPAGE_PMD_NR-1);
 	} else {
-		if (atomic_long_add_return(TEAM_PAGE_COUNTER,
-				&head->team_usage) >= TEAM_COMPLETE) {
+		if (team_usage >= TEAM_COMPLETE) {
 			shmem_clear_tag_hugehole(mapping, head->index);
 			__inc_zone_state(zone, NR_SHMEM_HUGEPAGES);
 			mem_cgroup_update_page_stat_treelocked(head,
@@ -644,6 +660,8 @@ static void shmem_disband_hugetails(stru
 		while (++page < endpage) {
 			if (PageTeam(page))
 				ClearPageTeam(page);
+			else if (PageSwapBacked(page))	/* half recovered */
+				put_page(page);
 			else if (put_page_testzero(page))
 				free_hot_cold_page(page, 1);
 		}
@@ -765,9 +783,12 @@ struct recovery {
 	struct inode *inode;
 	struct page *page;
 	pgoff_t head_index;
+	struct page *migrated_head;
+	bool exposed_team;
 };
 
 #define shr_stats(x)	do {} while (0)
+#define shr_stats_add(x, n) do {} while (0)
 /* Stats implemented in a later patch */
 
 static bool shmem_work_still_useful(struct recovery *recovery)
@@ -783,11 +804,295 @@ static bool shmem_work_still_useful(stru
 		!RB_EMPTY_ROOT(&mapping->i_mmap);  /* file is still mapped */
 }
 
+static struct page *shmem_get_recovery_page(struct page *page,
+					unsigned long private, int **result)
+{
+	struct recovery *recovery = (struct recovery *)private;
+	struct page *head = recovery->page;
+	struct page *newpage = head + (page->index & (HPAGE_PMD_NR-1));
+
+	/* Increment refcount to match other routes through recovery_populate */
+	if (!get_page_unless_zero(newpage))
+		return NULL;
+	if (!PageTeam(head)) {
+		put_page(newpage);
+		return NULL;
+	}
+	/* Note when migrating to head: tricky case because already PageTeam */
+	if (newpage == head)
+		recovery->migrated_head = head;
+	return newpage;
+}
+
+static void shmem_put_recovery_page(struct page *newpage, unsigned long private)
+{
+	struct recovery *recovery = (struct recovery *)private;
+
+	/* Must reset migrated_head if in the end it was not used */
+	if (recovery->migrated_head == newpage)
+		recovery->migrated_head = NULL;
+	/* Decrement refcount again if newpage was not used */
+	put_page(newpage);
+}
+
 static int shmem_recovery_populate(struct recovery *recovery, struct page *head)
 {
-	/* Huge page has been split but is not yet PageTeam */
-	shmem_disband_hugetails(head, NULL, 0);
-	return -ENOENT;
+	LIST_HEAD(migrate);
+	struct address_space *mapping = recovery->inode->i_mapping;
+	gfp_t gfp = mapping_gfp_mask(mapping) | __GFP_NORETRY;
+	struct zone *zone = page_zone(head);
+	pgoff_t index;
+	bool drained_all = false;
+	bool account_head = false;
+	int migratable;
+	int unmigratable;
+	struct page *team;
+	struct page *endteam = head + HPAGE_PMD_NR;
+	struct page *page;
+	int error = 0;
+	int nr;
+
+	/* Warning: this optimization relies on disband's ClearPageChecked */
+	if (PageTeam(head) && PageChecked(head))
+		return 0;
+again:
+	migratable = 0;
+	unmigratable = 0;
+	index = recovery->head_index;
+	for (team = head; team < endteam && !error; index++, team++) {
+		if (PageTeam(team) && PageUptodate(team) && PageDirty(team) &&
+		    !account_head)
+			continue;
+
+		error = shmem_getpage_gfp(recovery->inode, index, &page,
+					  SGP_TEAM, gfp, recovery->mm, NULL);
+		if (error)
+			break;
+
+		VM_BUG_ON_PAGE(!PageUptodate(page), page);
+		VM_BUG_ON_PAGE(PageSwapCache(page), page);
+		if (!PageDirty(page))
+			SetPageDirty(page);
+
+		if (PageTeam(page) && PageTeam(team_head(page))) {
+			/*
+			 * The page's old team might be being disbanded, but its
+			 * PageTeam not yet cleared, hence the head check above.
+			 *
+			 * We used to have VM_BUG_ON(page != team) here, and
+			 * never hit it; but I cannot see what else excludes
+			 * the race of two teams being built for the same area
+			 * (one through faulting and another through recovery).
+			 */
+			if (page != team)
+				error = -ENOENT;
+			if (error || !account_head)
+				goto unlock;
+		}
+
+		if (PageSwapBacked(team) && page != team) {
+			/*
+			 * Team page was prepared, yet shmem_getpage_gfp() has
+			 * given us a different page: that implies that this
+			 * offset was truncated or hole-punched meanwhile, so we
+			 * might as well give up now.  It might or might not be
+			 * still PageSwapCache.  We must not go on to use the
+			 * team page while it's swap - its swap entry, where
+			 * team_usage should be, causes crashes and softlockups
+			 * when disbanding.  And even if it has been removed
+			 * from swapcache, it is on (or temporarily off) LRU,
+			 * which crashes putback_lru_page() if we migrate to it.
+			 */
+			error = -ENOENT;
+			goto unlock;
+		}
+
+		if (!recovery->exposed_team) {
+			VM_BUG_ON(team != head);
+			recovery->exposed_team = true;
+			atomic_long_set(&head->team_usage, TEAM_LRU_WEIGHT_ONE);
+			SetPageTeam(head);
+			head->mapping = mapping;
+			head->index = index;
+			if (page == head)
+				account_head = true;
+		}
+
+		/* Eviction or truncation or hole-punch already disbanded? */
+		if (!PageTeam(head)) {
+			error = -ENOENT;
+			goto unlock;
+		}
+
+		if (page == team) {
+			VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+			/*
+			 * A task may have already mapped this page, before
+			 * we set PageTeam: so now we would need to add it
+			 * into head's team_pte_mapped count.  But it might
+			 * get unmapped while we do this: so artificially
+			 * bump the mapcount here, then use page_remove_rmap
+			 * below to get all the counts right.  Luckily our page
+			 * lock forbids it from transitioning from unmapped to
+			 * mapped while we do so: that would be more difficult.
+			 * Preemption disabled to suit zone_page_state updates.
+			 */
+			if (page_mapped(page)) {
+				preempt_disable();
+				page_add_file_rmap(page);
+			}
+			spin_lock_irq(&mapping->tree_lock);
+			if (PageTeam(head)) {
+				if (page != head) {
+					atomic_long_set(&page->team_usage,
+							TEAM_LRU_WEIGHT_ONE);
+					SetPageTeam(page);
+				}
+				if (page != head || account_head) {
+					shmem_added_to_hugeteam(page, zone,
+								NULL);
+					put_page(page);
+					shr_stats(page_teamed);
+				}
+			}
+			spin_unlock_irq(&mapping->tree_lock);
+			if (page_mapped(page)) {
+				inc_team_pte_mapped(page);
+				page_remove_rmap(page, false);
+				preempt_enable();
+			}
+			account_head = false;
+		} else {
+			VM_BUG_ON(account_head);
+			if (!PageLRU(page))
+				lru_add_drain();
+			if (isolate_lru_page(page) == 0) {
+				inc_zone_page_state(page, NR_ISOLATED_ANON);
+				list_add_tail(&page->lru, &migrate);
+				shr_stats(page_migrate);
+				migratable++;
+			} else {
+				shr_stats(page_off_lru);
+				unmigratable++;
+			}
+		}
+unlock:
+		unlock_page(page);
+		put_page(page);
+		cond_resched();
+	}
+
+	if (!list_empty(&migrate)) {
+		lru_add_drain(); /* not necessary but may help debugging */
+		if (!error) {
+			VM_BUG_ON(recovery->page != head);
+			recovery->migrated_head = NULL;
+			nr = migrate_pages(&migrate, shmem_get_recovery_page,
+				shmem_put_recovery_page, (unsigned long)
+				recovery, MIGRATE_SYNC, MR_SHMEM_RECOVERY);
+			account_head = !!recovery->migrated_head;
+			if (nr < 0) {
+				/*
+				 * If migrate_pages() returned error (-ENOMEM)
+				 * instead of number of pages failed, we don't
+				 * know how many failed; but it's irrelevant,
+				 * the team should be disbanded now anyway.
+				 * Increment page_unmigrated?  No, we would not
+				 * if the error were found during the main loop.
+				 */
+				error = -ENOENT;
+			}
+			if (nr > 0) {
+				shr_stats_add(page_unmigrated, nr);
+				unmigratable += nr;
+				migratable -= nr;
+			}
+		}
+		putback_movable_pages(&migrate);
+		lru_add_drain(); /* not necessary but may help debugging */
+	}
+
+	/*
+	 * migrate_pages() is prepared to make ten tries on each page,
+	 * but the preparatory isolate_lru_page() can too easily fail;
+	 * and we refrained from the IPIs of draining all CPUs before.
+	 */
+	if (!error) {
+		if (unmigratable && !drained_all) {
+			drained_all = true;
+			lru_add_drain_all();
+			shr_stats(recov_retried);
+			goto again;
+		}
+		if (migratable) {
+			/* Make another pass to SetPageTeam on them */
+			goto again;
+		}
+	}
+
+	lock_page(head);
+	nr = HPAGE_PMD_NR;
+	if (!recovery->exposed_team) {
+		/* Failed before even setting team head */
+		VM_BUG_ON(!error);
+		shmem_disband_hugetails(head, NULL, 0);
+	} else if (PageTeam(head)) {
+		if (!error) {
+			nr = shmem_freeholes(head);
+			if (nr == HPAGE_PMD_NR) {
+				/* We made no progress so not worth resuming */
+				error = -ENOENT;
+			}
+		}
+		if (error) {
+			/* Unsafe to let shrinker back in on this team */
+			shmem_disband_hugeteam(head);
+		}
+	} else if (!error) {
+		/* A concurrent actor took over our team and disbanded it */
+		error = -ENOENT;
+	}
+
+	if (error) {
+		shr_stats(recov_failed);
+	} else if (!nr) {
+		/* Team is complete and ready for pmd mapping */
+		SetPageChecked(head);
+		shr_stats(recov_completed);
+	} else {
+		struct shmem_inode_info *info = SHMEM_I(recovery->inode);
+		/*
+		 * All swapcache has been transferred to pagecache, but not
+		 * all migrations succeeded, so holes remain to be filled.
+		 * Allow shrinker to take these holes; but also tell later
+		 * recovery attempts where the huge page is, so migration to it
+		 * is resumed, so long as reclaim and shrinker did not disband.
+		 */
+		for (team = head;; team++) {
+			VM_BUG_ON(team >= endteam);
+			if (PageSwapBacked(team)) {
+				VM_BUG_ON(!PageTeam(team));
+				spin_lock_irq(&mapping->tree_lock);
+				radix_tree_tag_set(&mapping->page_tree,
+					team->index, SHMEM_TAG_HUGEHOLE);
+				spin_unlock_irq(&mapping->tree_lock);
+				break;
+			}
+		}
+		if (list_empty(&info->shrinklist)) {
+			spin_lock(&shmem_shrinklist_lock);
+			if (list_empty(&info->shrinklist)) {
+				list_add_tail(&info->shrinklist,
+					      &shmem_shrinklist);
+				shmem_shrinklist_depth++;
+			}
+			spin_unlock(&shmem_shrinklist_lock);
+		}
+		shr_stats(recov_partial);
+		error = -EAGAIN;
+	}
+	unlock_page(head);
+	return error;
 }
 
 static void shmem_recovery_remap(struct recovery *recovery, struct page *head)
@@ -841,6 +1146,7 @@ static void shmem_recovery_work(struct w
 
 	if (head) {
 		/* We are resuming work from a previous partial recovery */
+		recovery->exposed_team = true;
 		if (PageTeam(page))
 			shr_stats(resume_teamed);
 		else
@@ -867,6 +1173,7 @@ static void shmem_recovery_work(struct w
 		split_page(head, HPAGE_PMD_ORDER);
 		get_page(head);
 		shr_stats(huge_alloced);
+		recovery->exposed_team = false;
 	}
 
 	put_page(page);			/* before trying to migrate it */
@@ -2120,9 +2427,11 @@ static struct page *shmem_alloc_page(gfp
 			 * add_to_page_cache has the tree_lock.
 			 */
 			lock_page(page);
-			if (PageSwapBacked(page) || !PageTeam(head))
-				*hugehint = SHMEM_RETRY_HUGE_PAGE;
-			goto out;
+			if (!PageSwapBacked(page) && PageTeam(head))
+				goto out;
+			unlock_page(page);
+			put_page(page);
+			*hugehint = SHMEM_ALLOC_SMALL_PAGE;
 		}
 	}
 
@@ -2390,10 +2699,6 @@ repeat:
 			error = -ENOMEM;
 			goto decused;
 		}
-		if (hugehint == SHMEM_RETRY_HUGE_PAGE) {
-			error = -EEXIST;
-			goto decused;
-		}
 		if (sgp == SGP_WRITE)
 			__SetPageReferenced(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
