Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4A86B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 22:08:07 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 85so94152309ioq.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 19:08:07 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id s9si4033653iod.188.2016.06.02.19.08.05
        for <linux-mm@kvack.org>;
        Thu, 02 Jun 2016 19:08:06 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: add NR_ZSMALLOC to vmstat
Date: Fri,  3 Jun 2016 11:08:51 +0900
Message-Id: <1464919731-13255-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Sangseok Lee <sangseok.lee@lge.com>, Chanho Min <chanho.min@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>

Now, zram is very popular for some of embedded world(e.g., TV, mobile
phone). On those system, zsmalloc consumed memory size is never trivial
(one of example from real product system, total memory: 800M, zsmalloc
consumed: 150M), so we have used this out of tree patch to monitor system
memory behavior via /proc/vmstat.

With zsmalloc in vmstat, it helps tracking down system behavior by
memory usage.

Cc: Sangseok Lee <sangseok.lee@lge.com>
Cc: Chanho Min <chanho.min@lge.com>
Cc: Chan Gyun Jeong <chan.jeong@lge.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mmzone.h | 3 +++
 mm/vmstat.c            | 4 +++-
 mm/zsmalloc.c          | 7 ++++++-
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3388ccbab7d6..971d4c9f2550 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -140,6 +140,9 @@ enum zone_stat_item {
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
 	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
+#ifdef CONFIG_ZSMALLOC
+	NR_ZSMALLOC,
+#endif
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1b585f8e3088..3701905f3eb4 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -730,7 +730,9 @@ const char * const vmstat_text[] = {
 	"nr_dirtied",
 	"nr_written",
 	"nr_pages_scanned",
-
+#ifdef CONFIG_ZSMALLOC
+	"nr_zsmalloc",
+#endif
 #ifdef CONFIG_NUMA
 	"numa_hit",
 	"numa_miss",
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index a80100db16d6..8e71ec4f8005 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1022,6 +1022,7 @@ static void __free_zspage(struct zs_pool *pool, struct size_class *class,
 		reset_page(page);
 		unlock_page(page);
 		put_page(page);
+		dec_zone_page_state(page, NR_ZSMALLOC);
 		page = next;
 	} while (page != NULL);
 
@@ -1149,11 +1150,15 @@ static struct zspage *alloc_zspage(struct zs_pool *pool,
 
 		page = alloc_page(gfp);
 		if (!page) {
-			while (--i >= 0)
+			while (--i >= 0) {
 				__free_page(pages[i]);
+				dec_zone_page_state(page, NR_ZSMALLOC);
+			}
 			cache_free_zspage(pool, zspage);
 			return NULL;
 		}
+
+		inc_zone_page_state(page, NR_ZSMALLOC);
 		pages[i] = page;
 	}
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
