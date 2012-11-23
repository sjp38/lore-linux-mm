Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id CC7236B006C
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 05:43:33 -0500 (EST)
Date: Fri, 23 Nov 2012 10:43:27 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: numa: Add THP migration for the NUMA working set
 scanning fault case -fixes
Message-ID: <20121123104327.GY8218@suse.de>
References: <1353612353-1576-1-git-send-email-mgorman@suse.de>
 <1353612353-1576-38-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1353612353-1576-38-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hugh pointed out some issues that needed addressing in the THP native
migration patch

o transhuge isolations should be accounted as HPAGE_PMD_NR, not 1
o the migratepages list is doing nothing and is garbage leftover
  from an attempt to mesh transhuge migration properly with normal
  migration. Looking again now, I think it would trigger errors if list
  debugging was enabled and the THP migration failed. When I had a bunch
  of debugging options set earlier in development, list debugging was not
  one of them. This potentially could take a long time to hit but if you
  see bugs that look like LRU list corruption then this could be it.

Additionally

o Account for transhuage pages that are migrated so we know roughly
  how many MB/sec are being migrated for a given workload.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index d7c5bdf..b84fded 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1532,7 +1532,12 @@ int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 		put_page(page);
 
 		page_lru = page_is_file_cache(page);
-		inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
+		if (!PageTransHuge(page))
+			inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
+		else
+			mod_zone_page_state(page_zone(page),
+					NR_ISOLATED_ANON + page_lru,
+					HPAGE_PMD_NR);
 	}
 
 	return 1;
@@ -1598,7 +1603,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated = 0;
-	LIST_HEAD(migratepages);
 	struct page *new_page = NULL;
 	struct mem_cgroup *memcg = NULL;
 	int page_lru = page_is_file_cache(page);
@@ -1626,7 +1630,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated)
 		goto out_keep_locked;
-	list_add(&page->lru, &migratepages);
 
 	/* Prepare a page as a migration target */
 	__set_page_locked(new_page);
@@ -1655,6 +1658,8 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 		unlock_page(page);
 		putback_lru_page(page);
+
+		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
 		goto out;
 	}
 
@@ -1690,8 +1695,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	put_page(page);			/* Drop the rmap reference */
 	put_page(page);			/* Drop the LRU isolation reference */
 
+	count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
+	count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
+
 out:
-	dec_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
+	mod_zone_page_state(page_zone(page),
+			NR_ISOLATED_ANON + page_lru,
+			-HPAGE_PMD_NR);
 	return isolated;
 
 out_dropref:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
