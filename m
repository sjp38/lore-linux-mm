Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id D65C36B0099
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 08:04:53 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: use IS_ENABLED(CONFIG_COMPACTION) instead of COMPACTION_BUILD
Date: Mon, 15 Oct 2012 15:05:35 +0300
Message-Id: <1350302735-8416-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't need custom COMPACTION_BUILD anymore, since we have handy
IS_ENABLED().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/kernel.h |    7 -------
 mm/vmscan.c            |    8 ++++----
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 6bc5fa8..d85c530 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -687,13 +687,6 @@ static inline void ftrace_dump(enum ftrace_dump_mode oops_dump_mode) { }
 /* Trap pasters of __FUNCTION__ at compile-time */
 #define __FUNCTION__ (__func__)
 
-/* This helps us avoid #ifdef CONFIG_COMPACTION */
-#ifdef CONFIG_COMPACTION
-#define COMPACTION_BUILD 1
-#else
-#define COMPACTION_BUILD 0
-#endif
-
 /* Rebuild everything on CONFIG_FTRACE_MCOUNT_RECORD */
 #ifdef CONFIG_FTRACE_MCOUNT_RECORD
 # define REBUILD_DUE_TO_FTRACE_MCOUNT_RECORD
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2624edc..d4257f6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1752,7 +1752,7 @@ out:
 /* Use reclaim/compaction for costly allocs or under memory pressure */
 static bool in_reclaim_compaction(struct scan_control *sc)
 {
-	if (COMPACTION_BUILD && sc->order &&
+	if (IS_ENABLED(CONFIG_COMPACTION) && sc->order &&
 			(sc->order > PAGE_ALLOC_COSTLY_ORDER ||
 			 sc->priority < DEF_PRIORITY - 2))
 		return true;
@@ -2030,7 +2030,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			if (zone->all_unreclaimable &&
 					sc->priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
-			if (COMPACTION_BUILD) {
+			if (IS_ENABLED(CONFIG_COMPACTION)) {
 				/*
 				 * If we already have plenty of memory free for
 				 * compaction in this zone, don't free any more.
@@ -2681,7 +2681,7 @@ loop_again:
 			 * Do not reclaim more than needed for compaction.
 			 */
 			testorder = order;
-			if (COMPACTION_BUILD && order &&
+			if (IS_ENABLED(CONFIG_COMPACTION) && order &&
 					compaction_suitable(zone, order) !=
 						COMPACT_SKIPPED)
 				testorder = 0;
@@ -2827,7 +2827,7 @@ out:
 				continue;
 
 			/* Would compaction fail due to lack of free memory? */
-			if (COMPACTION_BUILD &&
+			if (IS_ENABLED(CONFIG_COMPACTION) &&
 			    compaction_suitable(zone, order) == COMPACT_SKIPPED)
 				goto loop_again;
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
