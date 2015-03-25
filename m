Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0330A6B0078
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:17:49 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so10613876wib.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 23:17:48 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ee3si20818074wib.24.2015.03.24.23.17.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 23:17:47 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 09/12] mm: page_alloc: private memory reserves for OOM-killing allocations
Date: Wed, 25 Mar 2015 02:17:13 -0400
Message-Id: <1427264236-17249-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

The OOM killer connects random tasks in the system with unknown
dependencies between them, and the OOM victim might well get blocked
behind the task that is trying to allocate.  That means that while
allocations can issue OOM kills to improve the low memory situation,
which generally frees more than they are going to take out, they can
not rely on their *own* OOM kills to make forward progress for them.

Secondly, we want to avoid a racing allocation swooping in to steal
the work of the OOM killing allocation, causing spurious allocation
failures.  The one that put in the work must have priority - if its
efforts are enough to serve both allocations that's fine, otherwise
concurrent allocations should be forced to issue their own OOM kills.

Keep some pages below the min watermark reserved for OOM-killing
allocations to protect them from blocking victims and concurrent
allocations not pulling their weight.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |  2 ++
 mm/internal.h          |  3 ++-
 mm/page_alloc.c        | 27 +++++++++++++++++++++++----
 mm/vmstat.c            |  2 ++
 4 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 218f89208e83..284a36c7c1ce 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -239,12 +239,14 @@ struct lruvec {
 typedef unsigned __bitwise__ isolate_mode_t;
 
 enum zone_watermarks {
+	WMARK_OOM,
 	WMARK_MIN,
 	WMARK_LOW,
 	WMARK_HIGH,
 	NR_WMARK
 };
 
+#define oom_wmark_pages(z) (z->watermark[WMARK_OOM])
 #define min_wmark_pages(z) (z->watermark[WMARK_MIN])
 #define low_wmark_pages(z) (z->watermark[WMARK_LOW])
 #define high_wmark_pages(z) (z->watermark[WMARK_HIGH])
diff --git a/mm/internal.h b/mm/internal.h
index edaab69a9c35..f59f3711f26c 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -419,10 +419,11 @@ extern void set_pageblock_order(void);
 unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 					    struct list_head *page_list);
 /* The ALLOC_WMARK bits are used as an index to zone->watermark */
+#define ALLOC_WMARK_OOM		WMARK_OOM
 #define ALLOC_WMARK_MIN		WMARK_MIN
 #define ALLOC_WMARK_LOW		WMARK_LOW
 #define ALLOC_WMARK_HIGH	WMARK_HIGH
-#define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
+#define ALLOC_NO_WATERMARKS	0x08 /* don't check watermarks at all */
 
 /* Mask to get the watermark bits */
 #define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9ce9c4c083a0..3c165016175d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2390,6 +2390,22 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
 			*did_some_progress = 1;
 	}
+
+	/*
+	 * Allocate from the OOM killer reserves.
+	 *
+	 * For one, this prevents parallel allocations from stealing
+	 * our work and cause us to fail the allocation prematurely.
+	 * If our kill is not enough for both, a racing allocation
+	 * should issue a kill on its own.
+	 *
+	 * We might also hold a lock or state that keeps the OOM kill
+	 * from exiting.  While allocations can use OOM kills to free
+	 * memory, they can not necessarily rely on their *own* kills
+	 * to make forward progress.
+	 */
+	alloc_flags &= ~ALLOC_WMARK_MASK;
+	alloc_flags |= ALLOC_WMARK_OOM;
 out:
 	mutex_unlock(&oom_lock);
 alloc:
@@ -3274,6 +3290,7 @@ void show_free_areas(unsigned int filter)
 		show_node(zone);
 		printk("%s"
 			" free:%lukB"
+			" oom:%lukB"
 			" min:%lukB"
 			" low:%lukB"
 			" high:%lukB"
@@ -3306,6 +3323,7 @@ void show_free_areas(unsigned int filter)
 			"\n",
 			zone->name,
 			K(zone_page_state(zone, NR_FREE_PAGES)),
+			K(oom_wmark_pages(zone)),
 			K(min_wmark_pages(zone)),
 			K(low_wmark_pages(zone)),
 			K(high_wmark_pages(zone)),
@@ -5747,17 +5765,18 @@ static void __setup_per_zone_wmarks(void)
 
 			min_pages = zone->managed_pages / 1024;
 			min_pages = clamp(min_pages, SWAP_CLUSTER_MAX, 128UL);
-			zone->watermark[WMARK_MIN] = min_pages;
+			zone->watermark[WMARK_OOM] = min_pages;
 		} else {
 			/*
 			 * If it's a lowmem zone, reserve a number of pages
 			 * proportionate to the zone's size.
 			 */
-			zone->watermark[WMARK_MIN] = tmp;
+			zone->watermark[WMARK_OOM] = tmp;
 		}
 
-		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
-		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
+		zone->watermark[WMARK_MIN]  = oom_wmark_pages(zone) + (tmp >> 3);
+		zone->watermark[WMARK_LOW]  = oom_wmark_pages(zone) + (tmp >> 2);
+		zone->watermark[WMARK_HIGH] = oom_wmark_pages(zone) + (tmp >> 1);
 
 		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
 			high_wmark_pages(zone) - low_wmark_pages(zone) -
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1fd0886a389f..a62f16ef524c 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1188,6 +1188,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
 	seq_printf(m,
 		   "\n  pages free     %lu"
+		   "\n        oom      %lu"
 		   "\n        min      %lu"
 		   "\n        low      %lu"
 		   "\n        high     %lu"
@@ -1196,6 +1197,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n        present  %lu"
 		   "\n        managed  %lu",
 		   zone_page_state(zone, NR_FREE_PAGES),
+		   oom_wmark_pages(zone),
 		   min_wmark_pages(zone),
 		   low_wmark_pages(zone),
 		   high_wmark_pages(zone),
-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
