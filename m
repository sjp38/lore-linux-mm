Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 050906B00BE
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:54 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 33/49] mm: numa: Rate limit the amount of memory that is migrated between nodes
Date: Fri,  7 Dec 2012 10:23:36 +0000
Message-Id: <1354875832-9700-34-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NOTE: This is very heavily based on similar logic in autonuma. It should
	be signed off by Andrea but because there was no standalone
	patch and it's sufficiently different from what he did that
	the signed-off is omitted. Will be added back if requested.

If a large number of pages are misplaced then the memory bus can be
saturated just migrating pages between nodes. This patch rate-limits
the amount of memory that can be migrating between nodes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c |   30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 4f55694..b2e6d4c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1461,12 +1461,21 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 }
 
 /*
+ * page migration rate limiting control.
+ * Do not migrate more than @pages_to_migrate in a @migrate_interval_millisecs
+ * window of time. Default here says do not migrate more than 1280M per second.
+ */
+static unsigned int migrate_interval_millisecs __read_mostly = 100;
+static unsigned int ratelimit_pages __read_mostly = 128 << (20 - PAGE_SHIFT);
+
+/*
  * Attempt to migrate a misplaced page to the specified destination
  * node. Caller is expected to have an elevated reference count on
  * the page that will be dropped by this function before returning.
  */
 int migrate_misplaced_page(struct page *page, int node)
 {
+	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated = 0;
 	LIST_HEAD(migratepages);
 
@@ -1479,8 +1488,27 @@ int migrate_misplaced_page(struct page *page, int node)
 		goto out;
 	}
 
+	/*
+	 * Rate-limit the amount of data that is being migrated to a node.
+	 * Optimal placement is no good if the memory bus is saturated and
+	 * all the time is being spent migrating!
+	 */
+	spin_lock(&pgdat->balancenuma_migrate_lock);
+	if (time_after(jiffies, pgdat->balancenuma_migrate_next_window)) {
+		pgdat->balancenuma_migrate_nr_pages = 0;
+		pgdat->balancenuma_migrate_next_window = jiffies +
+			msecs_to_jiffies(migrate_interval_millisecs);
+	}
+	if (pgdat->balancenuma_migrate_nr_pages > ratelimit_pages) {
+		spin_unlock(&pgdat->balancenuma_migrate_lock);
+		put_page(page);
+		goto out;
+	}
+	pgdat->balancenuma_migrate_nr_pages++;
+	spin_unlock(&pgdat->balancenuma_migrate_lock);
+
 	/* Avoid migrating to a node that is nearly full */
-	if (migrate_balanced_pgdat(NODE_DATA(node), 1)) {
+	if (migrate_balanced_pgdat(pgdat, 1)) {
 		int page_lru;
 
 		if (isolate_lru_page(page)) {
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
