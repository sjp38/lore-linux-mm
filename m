Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id CDE706B00D7
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:25:18 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 47/49] mm: migrate: Account a transhuge page properly when rate limiting
Date: Fri,  7 Dec 2012 10:23:50 +0000
Message-Id: <1354875832-9700-48-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If there is excessive migration due to NUMA balancing it gets rate
limited. It does this by counting the number of pages it has migrated
recently but counts a transhuge page as 1 page. Account for it properly.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index eb155c9..6b6567f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1492,7 +1492,7 @@ bool migrate_ratelimited(int node)
 }
 
 /* Returns true if the node is migrate rate-limited after the update */
-bool numamigrate_update_ratelimit(pg_data_t *pgdat)
+bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
 {
 	bool rate_limited = false;
 
@@ -1510,7 +1510,7 @@ bool numamigrate_update_ratelimit(pg_data_t *pgdat)
 	if (pgdat->balancenuma_migrate_nr_pages > ratelimit_pages)
 		rate_limited = true;
 	else
-		pgdat->balancenuma_migrate_nr_pages++;
+		pgdat->balancenuma_migrate_nr_pages += nr_pages;
 	spin_unlock(&pgdat->balancenuma_migrate_lock);
 	
 	return rate_limited;
@@ -1579,7 +1579,7 @@ int migrate_misplaced_page(struct page *page, int node)
 	 * Optimal placement is no good if the memory bus is saturated and
 	 * all the time is being spent migrating!
 	 */
-	if (numamigrate_update_ratelimit(pgdat)) {
+	if (numamigrate_update_ratelimit(pgdat, 1)) {
 		put_page(page);
 		goto out;
 	}
@@ -1630,7 +1630,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	 * Optimal placement is no good if the memory bus is saturated and
 	 * all the time is being spent migrating!
 	 */
-	if (numamigrate_update_ratelimit(pgdat))
+	if (numamigrate_update_ratelimit(pgdat, HPAGE_PMD_NR))
 		goto out_dropref;
 
 	new_page = alloc_pages_node(node,
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
