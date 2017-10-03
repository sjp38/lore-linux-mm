Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDBC6B0260
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:23:28 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y192so23639431pgd.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:23:28 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0103.outbound.protection.outlook.com. [104.47.0.103])
        by mx.google.com with ESMTPS id y131si9994229pfg.299.2017.10.03.08.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 08:23:26 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm: remove unused pgdat->inactive_ratio
Date: Tue,  3 Oct 2017 18:26:11 +0300
Message-Id: <20171003152611.27483-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Since commit 59dc76b0d4df ("mm: vmscan: reduce size of inactive file list")
'pgdat->inactive_ratio' is not used, except for printing
"node_inactive_ratio: 0" in /proc/zoneinfo output.

Remove it.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 include/linux/mmzone.h | 6 ------
 mm/vmscan.c            | 2 +-
 mm/vmstat.c            | 6 ++----
 3 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c8f89417740b..a6f361931d52 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -711,12 +711,6 @@ typedef struct pglist_data {
 	/* Fields commonly accessed by the page reclaim scanner */
 	struct lruvec		lruvec;
 
-	/*
-	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
-	 * this node's LRU.  Maintained by the pageout code.
-	 */
-	unsigned int inactive_ratio;
-
 	unsigned long		flags;
 
 	ZONE_PADDING(_pad2_)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d811c81ddb69..245b3d482791 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2081,7 +2081,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
  * If that fails and refaulting is observed, the inactive list grows.
  *
  * The inactive_ratio is the target ratio of ACTIVE to INACTIVE pages
- * on this LRU, maintained by the pageout code. A zone->inactive_ratio
+ * on this LRU, maintained by the pageout code. An inactive_ratio
  * of 3 means 3:1 or 25% of the pages are kept on the inactive list.
  *
  * total     target    max
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7255c0a2a972..89d29802e709 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1682,11 +1682,9 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	}
 	seq_printf(m,
 		   "\n  node_unreclaimable:  %u"
-		   "\n  start_pfn:           %lu"
-		   "\n  node_inactive_ratio: %u",
+		   "\n  start_pfn:           %lu",
 		   pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES,
-		   zone->zone_start_pfn,
-		   zone->zone_pgdat->inactive_ratio);
+		   zone->zone_start_pfn);
 	seq_putc(m, '\n');
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
