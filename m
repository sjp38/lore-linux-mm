Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id A0AD76B0069
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 02:09:27 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so1345514eaj.7
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 23:09:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e2si8187255eeg.240.2013.12.08.23.09.26
        for <linux-mm@kvack.org>;
        Sun, 08 Dec 2013 23:09:26 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/18] mm: numa: Limit scope of lock for NUMA migrate rate limiting
Date: Mon,  9 Dec 2013 07:09:08 +0000
Message-Id: <1386572952-1191-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-1-git-send-email-mgorman@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NUMA migrate rate limiting protects a migration counter and window using
a lock but in some cases this can be a contended lock. It is not
critical that the number of pages be perfect, lost updates are
acceptable. Reduce the importance of this lock.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |  5 +----
 mm/migrate.c           | 21 ++++++++++++---------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bd791e4..b835d3f 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -758,10 +758,7 @@ typedef struct pglist_data {
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
 #ifdef CONFIG_NUMA_BALANCING
-	/*
-	 * Lock serializing the per destination node AutoNUMA memory
-	 * migration rate limiting data.
-	 */
+	/* Lock serializing the migrate rate limiting window */
 	spinlock_t numabalancing_migrate_lock;
 
 	/* Rate limiting time interval */
diff --git a/mm/migrate.c b/mm/migrate.c
index 77147bd..8b560d5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1596,26 +1596,29 @@ bool migrate_ratelimited(int node)
 static bool numamigrate_update_ratelimit(pg_data_t *pgdat,
 					unsigned long nr_pages)
 {
-	bool rate_limited = false;
-
 	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
 	 * Optimal placement is no good if the memory bus is saturated and
 	 * all the time is being spent migrating!
 	 */
-	spin_lock(&pgdat->numabalancing_migrate_lock);
 	if (time_after(jiffies, pgdat->numabalancing_migrate_next_window)) {
+		spin_lock(&pgdat->numabalancing_migrate_lock);
 		pgdat->numabalancing_migrate_nr_pages = 0;
 		pgdat->numabalancing_migrate_next_window = jiffies +
 			msecs_to_jiffies(migrate_interval_millisecs);
+		spin_unlock(&pgdat->numabalancing_migrate_lock);
 	}
 	if (pgdat->numabalancing_migrate_nr_pages > ratelimit_pages)
-		rate_limited = true;
-	else
-		pgdat->numabalancing_migrate_nr_pages += nr_pages;
-	spin_unlock(&pgdat->numabalancing_migrate_lock);
-	
-	return rate_limited;
+		return true;
+
+	/*
+	 * This is an unlocked non-atomic update so errors are possible.
+	 * The consequences are failing to migrate when we potentiall should
+	 * have which is not severe enough to warrant locking. If it is ever
+	 * a problem, it can be converted to a per-cpu counter.
+	 */
+	pgdat->numabalancing_migrate_nr_pages += nr_pages;
+	return false;
 }
 
 static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
