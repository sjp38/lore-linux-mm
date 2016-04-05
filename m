Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id E79516B0297
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 18:03:57 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id n1so19039746pfn.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 15:03:57 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id uk4si10185636pab.234.2016.04.05.15.03.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 15:03:57 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id 184so19097526pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 15:03:57 -0700 (PDT)
Date: Tue, 5 Apr 2016 15:03:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 29/31] huge tmpfs recovery: page migration call back into
 shmem
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051502170.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

What we have works; but involves tricky "account_head" handling, and more
trips around the shmem_recovery_populate() loop than I'm comfortable with.

Tighten it all up with a MIGRATE_SHMEM_RECOVERY mode, and
shmem_recovery_migrate_page() callout from migrate_page_move_mapping(),
so that the migrated page can be made PageTeam immediately.

Which allows the SHMEM_RETRY_HUGE_PAGE hugehint to be reintroduced,
for what little that's worth.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/migrate_mode.h   |    2 
 include/linux/shmem_fs.h       |    6 +
 include/trace/events/migrate.h |    3 
 mm/migrate.c                   |   17 ++++-
 mm/shmem.c                     |   99 ++++++++++++-------------------
 5 files changed, 62 insertions(+), 65 deletions(-)

--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -6,11 +6,13 @@
  *	on most operations but not ->writepage as the potential stall time
  *	is too significant
  * MIGRATE_SYNC will block when migrating pages
+ * MIGRATE_SHMEM_RECOVERY is a MIGRATE_SYNC specific to huge tmpfs recovery.
  */
 enum migrate_mode {
 	MIGRATE_ASYNC,
 	MIGRATE_SYNC_LIGHT,
 	MIGRATE_SYNC,
+	MIGRATE_SHMEM_RECOVERY,
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -85,6 +85,7 @@ static inline long shmem_fcntl(struct fi
 #endif /* CONFIG_TMPFS */
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && defined(CONFIG_SHMEM)
+extern bool shmem_recovery_migrate_page(struct page *new, struct page *page);
 # ifdef CONFIG_SYSCTL
 struct ctl_table;
 extern int shmem_huge, shmem_huge_min, shmem_huge_max;
@@ -92,6 +93,11 @@ extern int shmem_huge_recoveries;
 extern int shmem_huge_sysctl(struct ctl_table *table, int write,
 			     void __user *buffer, size_t *lenp, loff_t *ppos);
 # endif /* CONFIG_SYSCTL */
+#else
+static inline bool shmem_recovery_migrate_page(struct page *new, struct page *p)
+{
+	return true;	/* Never called: true will optimize out the fallback */
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE && CONFIG_SHMEM */
 
 #endif
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -9,7 +9,8 @@
 #define MIGRATE_MODE						\
 	EM( MIGRATE_ASYNC,	"MIGRATE_ASYNC")		\
 	EM( MIGRATE_SYNC_LIGHT,	"MIGRATE_SYNC_LIGHT")		\
-	EMe(MIGRATE_SYNC,	"MIGRATE_SYNC")
+	EM( MIGRATE_SYNC,	"MIGRATE_SYNC")			\
+	EMe(MIGRATE_SHMEM_RECOVERY, "MIGRATE_SHMEM_RECOVERY")
 
 
 #define MIGRATE_REASON						\
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -23,6 +23,7 @@
 #include <linux/pagevec.h>
 #include <linux/ksm.h>
 #include <linux/rmap.h>
+#include <linux/shmem_fs.h>
 #include <linux/topology.h>
 #include <linux/cpu.h>
 #include <linux/cpuset.h>
@@ -371,6 +372,15 @@ int migrate_page_move_mapping(struct add
 		return -EAGAIN;
 	}
 
+	if (mode == MIGRATE_SHMEM_RECOVERY) {
+		if (!shmem_recovery_migrate_page(newpage, page)) {
+			page_ref_unfreeze(page, expected_count);
+			spin_unlock_irq(&mapping->tree_lock);
+			return -ENOMEM;	/* quit migrate_pages() immediately */
+		}
+	} else
+		get_page(newpage);	/* add cache reference */
+
 	/*
 	 * Now we know that no one else is looking at the page:
 	 * no turning back from here.
@@ -380,7 +390,6 @@ int migrate_page_move_mapping(struct add
 	if (PageSwapBacked(page))
 		__SetPageSwapBacked(newpage);
 
-	get_page(newpage);	/* add cache reference */
 	if (PageSwapCache(page)) {
 		SetPageSwapCache(newpage);
 		set_page_private(newpage, page_private(page));
@@ -786,7 +795,7 @@ static int move_to_new_page(struct page
 }
 
 static int __unmap_and_move(struct page *page, struct page *newpage,
-		int force, enum migrate_mode mode, enum migrate_reason reason)
+				int force, enum migrate_mode mode)
 {
 	int rc = -EAGAIN;
 	int page_was_mapped = 0;
@@ -821,7 +830,7 @@ static int __unmap_and_move(struct page
 	 * already in use, on lru, with data newly written for that offset.
 	 * We can only be sure of this check once we have the page locked.
 	 */
-	if (reason == MR_SHMEM_RECOVERY && !page->mapping) {
+	if (mode == MIGRATE_SHMEM_RECOVERY && !page->mapping) {
 		rc = -ENOMEM;	/* quit migrate_pages() immediately */
 		goto out_unlock;
 	}
@@ -973,7 +982,7 @@ static ICE_noinline int unmap_and_move(n
 			goto out;
 	}
 
-	rc = __unmap_and_move(page, newpage, force, mode, reason);
+	rc = __unmap_and_move(page, newpage, force, mode);
 	if (rc == MIGRATEPAGE_SUCCESS) {
 		put_new_page = NULL;
 		set_page_owner_migrate_reason(newpage, reason);
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -306,6 +306,7 @@ static bool shmem_confirm_swap(struct ad
 /* hugehint values: NULL to choose a small page always */
 #define SHMEM_ALLOC_SMALL_PAGE	((struct page *)1)
 #define SHMEM_ALLOC_HUGE_PAGE	((struct page *)2)
+#define SHMEM_RETRY_HUGE_PAGE	((struct page *)3)
 /* otherwise hugehint is the hugeteam page to be used */
 
 /* tag for shrinker to locate unfilled hugepages */
@@ -368,20 +369,6 @@ restart:
 			put_page(page);
 		return SHMEM_ALLOC_SMALL_PAGE;
 	}
-	if (PageSwapBacked(page)) {
-		if (speculative)
-			put_page(page);
-		/*
-		 * This is very often a case of two tasks racing to instantiate
-		 * the same hole in the huge page, and we don't particularly
-		 * want to allocate a small page.  But holepunch racing with
-		 * recovery migration, in between migrating to the page and
-		 * marking it team, can leave a PageSwapBacked NULL mapping
-		 * page here which we should avoid, and this is the easiest
-		 * way to handle all the cases correctly.
-		 */
-		return SHMEM_ALLOC_SMALL_PAGE;
-	}
 	return page;
 }
 
@@ -784,7 +771,6 @@ struct recovery {
 	struct inode *inode;
 	struct page *page;
 	pgoff_t head_index;
-	struct page *migrated_head;
 	bool exposed_team;
 };
 
@@ -988,8 +974,7 @@ static void shmem_recovery_swapin(struct
 static struct page *shmem_get_recovery_page(struct page *page,
 					unsigned long private, int **result)
 {
-	struct recovery *recovery = (struct recovery *)private;
-	struct page *head = recovery->page;
+	struct page *head = (struct page *)private;
 	struct page *newpage = head + (page->index & (HPAGE_PMD_NR-1));
 
 	/* Increment refcount to match other routes through recovery_populate */
@@ -999,19 +984,33 @@ static struct page *shmem_get_recovery_p
 		put_page(newpage);
 		return NULL;
 	}
-	/* Note when migrating to head: tricky case because already PageTeam */
-	if (newpage == head)
-		recovery->migrated_head = head;
 	return newpage;
 }
 
-static void shmem_put_recovery_page(struct page *newpage, unsigned long private)
+/*
+ * shmem_recovery_migrate_page() is called from the heart of page migration's
+ * migrate_page_move_mapping(): with interrupts disabled, mapping->tree_lock
+ * held, page's reference count frozen to 0, and no other reason to turn back.
+ */
+bool shmem_recovery_migrate_page(struct page *newpage, struct page *page)
 {
-	struct recovery *recovery = (struct recovery *)private;
+	struct page *head = newpage - (page->index & (HPAGE_PMD_NR-1));
+
+	if (!PageTeam(head))
+		return false;
+	if (newpage != head) {
+		/* Needs to be initialized before shmem_added_to_hugeteam() */
+		atomic_long_set(&newpage->team_usage, TEAM_LRU_WEIGHT_ONE);
+		SetPageTeam(newpage);
+		newpage->mapping = page->mapping;
+		newpage->index = page->index;
+	}
+	shmem_added_to_hugeteam(newpage, page_zone(newpage), NULL);
+	return true;
+}
 
-	/* Must reset migrated_head if in the end it was not used */
-	if (recovery->migrated_head == newpage)
-		recovery->migrated_head = NULL;
+static void shmem_put_recovery_page(struct page *newpage, unsigned long private)
+{
 	/* Decrement refcount again if newpage was not used */
 	put_page(newpage);
 }
@@ -1024,9 +1023,7 @@ static int shmem_recovery_populate(struc
 	struct zone *zone = page_zone(head);
 	pgoff_t index;
 	bool drained_all = false;
-	bool account_head = false;
-	int migratable;
-	int unmigratable;
+	int unmigratable = 0;
 	struct page *team;
 	struct page *endteam = head + HPAGE_PMD_NR;
 	struct page *page;
@@ -1039,12 +1036,9 @@ static int shmem_recovery_populate(struc
 
 	shmem_recovery_swapin(recovery, head);
 again:
-	migratable = 0;
-	unmigratable = 0;
 	index = recovery->head_index;
 	for (team = head; team < endteam && !error; index++, team++) {
-		if (PageTeam(team) && PageUptodate(team) && PageDirty(team) &&
-		    !account_head)
+		if (PageTeam(team) && PageUptodate(team) && PageDirty(team))
 			continue;
 
 		page = team;	/* used as hint if not yet instantiated */
@@ -1070,8 +1064,7 @@ again:
 			 */
 			if (page != team)
 				error = -ENOENT;
-			if (error || !account_head)
-				goto unlock;
+			goto unlock;
 		}
 
 		if (PageSwapBacked(team) && page != team) {
@@ -1098,8 +1091,6 @@ again:
 			SetPageTeam(head);
 			head->mapping = mapping;
 			head->index = index;
-			if (page == head)
-				account_head = true;
 		}
 
 		/* Eviction or truncation or hole-punch already disbanded? */
@@ -1132,12 +1123,9 @@ again:
 							TEAM_LRU_WEIGHT_ONE);
 					SetPageTeam(page);
 				}
-				if (page != head || account_head) {
-					shmem_added_to_hugeteam(page, zone,
-								NULL);
-					put_page(page);
-					shr_stats(page_teamed);
-				}
+				shmem_added_to_hugeteam(page, zone, NULL);
+				put_page(page);
+				shr_stats(page_teamed);
 			}
 			spin_unlock_irq(&mapping->tree_lock);
 			if (page_mapped(page)) {
@@ -1145,16 +1133,13 @@ again:
 				page_remove_rmap(page, false);
 				preempt_enable();
 			}
-			account_head = false;
 		} else {
-			VM_BUG_ON(account_head);
 			if (!PageLRU(page))
 				lru_add_drain();
 			if (isolate_lru_page(page) == 0) {
 				inc_zone_page_state(page, NR_ISOLATED_ANON);
 				list_add_tail(&page->lru, &migrate);
 				shr_stats(page_migrate);
-				migratable++;
 			} else {
 				shr_stats(page_off_lru);
 				unmigratable++;
@@ -1169,12 +1154,9 @@ unlock:
 	if (!list_empty(&migrate)) {
 		lru_add_drain(); /* not necessary but may help debugging */
 		if (!error) {
-			VM_BUG_ON(recovery->page != head);
-			recovery->migrated_head = NULL;
 			nr = migrate_pages(&migrate, shmem_get_recovery_page,
-				shmem_put_recovery_page, (unsigned long)
-				recovery, MIGRATE_SYNC, MR_SHMEM_RECOVERY);
-			account_head = !!recovery->migrated_head;
+				shmem_put_recovery_page, (unsigned long)head,
+				MIGRATE_SHMEM_RECOVERY, MR_SHMEM_RECOVERY);
 			if (nr < 0) {
 				/*
 				 * If migrate_pages() returned error (-ENOMEM)
@@ -1189,7 +1171,6 @@ unlock:
 			if (nr > 0) {
 				shr_stats_add(page_unmigrated, nr);
 				unmigratable += nr;
-				migratable -= nr;
 			}
 		}
 		putback_movable_pages(&migrate);
@@ -1208,10 +1189,6 @@ unlock:
 			shr_stats(recov_retried);
 			goto again;
 		}
-		if (migratable) {
-			/* Make another pass to SetPageTeam on them */
-			goto again;
-		}
 	}
 
 	lock_page(head);
@@ -2687,11 +2664,9 @@ static struct page *shmem_alloc_page(gfp
 			 * add_to_page_cache has the tree_lock.
 			 */
 			lock_page(page);
-			if (!PageSwapBacked(page) && PageTeam(head))
-				goto out;
-			unlock_page(page);
-			put_page(page);
-			*hugehint = SHMEM_ALLOC_SMALL_PAGE;
+			if (PageSwapBacked(page) || !PageTeam(head))
+				*hugehint = SHMEM_RETRY_HUGE_PAGE;
+			goto out;
 		}
 	}
 
@@ -2991,6 +2966,10 @@ repeat:
 			error = -ENOMEM;
 			goto decused;
 		}
+		if (hugehint == SHMEM_RETRY_HUGE_PAGE) {
+			error = -EEXIST;
+			goto decused;
+		}
 		if (sgp == SGP_WRITE)
 			__SetPageReferenced(page);
 memcg:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
