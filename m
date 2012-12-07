Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 632E06B00A9
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:32 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 20/49] mm: migrate: Drop the misplaced pages reference count if the target node is full
Date: Fri,  7 Dec 2012 10:23:23 +0000
Message-Id: <1354875832-9700-21-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If we have to avoid migrating to a node that is nearly full, put page
and return zero.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index a2c4567..49878d7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1489,18 +1489,21 @@ int migrate_misplaced_page(struct page *page, int node)
 		}
 		isolated = 1;
 
-		/*
-		 * Page is isolated which takes a reference count so now the
-		 * callers reference can be safely dropped without the page
-		 * disappearing underneath us during migration
-		 */
-		put_page(page);
-
 		page_lru = page_is_file_cache(page);
 		inc_zone_page_state(page, NR_ISOLATED_ANON + page_lru);
 		list_add(&page->lru, &migratepages);
 	}
 
+	/*
+	 * Page is either isolated or there is not enough space on the target
+	 * node. If isolated, then it has taken a reference count and the
+	 * callers reference can be safely dropped without the page
+	 * disappearing underneath us during migration. Otherwise the page is
+	 * not to be migrated but the callers reference should still be
+	 * dropped so it does not leak.
+	 */
+	put_page(page);
+
 	if (isolated) {
 		int nr_remaining;
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
