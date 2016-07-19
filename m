Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F58C6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 22:07:43 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so8652472pab.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 19:07:43 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id lq9si29839803pab.205.2016.07.18.19.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 19:07:42 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id hh10so330765pac.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 19:07:42 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/vmscan: remove pglist_data->inactive_ratio
Date: Tue, 19 Jul 2016 10:07:29 +0800
Message-Id: <1468894049-786-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, minchan@kernel.org, hannes@cmpxchg.org, mhocko@suse.com, riel@redhat.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, kirill.shutemov@linux.intel.com, cl@linux.com, hughd@google.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

In patch [1], the inactive_ratio is now automatically calculated
in inactive_list_is_low(). So there is no need to keep inactive_ratio
in pglist_data, and shown in zoneinfo.

[1] mm: vmscan: reduce size of inactive file list

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
 include/linux/mmzone.h | 6 ------
 mm/vmscan.c            | 2 +-
 mm/vmstat.c            | 6 ++----
 3 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index a3b7f45..b3ade54 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -700,12 +700,6 @@ typedef struct pglist_data {
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
index 429bf3a..3c1de58 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1915,7 +1915,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
  * page has a chance to be referenced again before it is reclaimed.
  *
  * The inactive_ratio is the target ratio of ACTIVE to INACTIVE pages
- * on this LRU, maintained by the pageout code. A zone->inactive_ratio
+ * on this LRU, maintained by the pageout code. A inactive_ratio
  * of 3 means 3:1 or 25% of the pages are kept on the inactive list.
  *
  * total     target    max
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 91ecca9..74a0eca 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1491,11 +1491,9 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	}
 	seq_printf(m,
 		   "\n  node_unreclaimable:  %u"
-		   "\n  start_pfn:           %lu"
-		   "\n  node_inactive_ratio: %u",
+		   "\n  start_pfn:           %lu",
 		   !pgdat_reclaimable(zone->zone_pgdat),
-		   zone->zone_start_pfn,
-		   zone->zone_pgdat->inactive_ratio);
+		   zone->zone_start_pfn);
 	seq_putc(m, '\n');
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
