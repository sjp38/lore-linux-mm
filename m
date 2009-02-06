Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D456E6B005C
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:13:13 -0500 (EST)
Message-Id: <20090206031323.916297777@cmpxchg.org>
Date: Fri, 06 Feb 2009 04:11:27 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/3] swsusp: dont fiddle with swappiness
References: <20090206031125.693559239@cmpxchg.org>
Content-Disposition: inline; filename=swsusp-dont-fiddle-with-swappiness.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

sc.swappiness is not used in the swsusp memory shrinking path, do not
set it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2111,7 +2111,6 @@ unsigned long shrink_all_memory(unsigned
 		.may_swap = 0,
 		.swap_cluster_max = nr_pages,
 		.may_writepage = 1,
-		.swappiness = vm_swappiness,
 		.isolate_pages = isolate_pages_global,
 	};
 
@@ -2145,10 +2144,8 @@ unsigned long shrink_all_memory(unsigned
 		int prio;
 
 		/* Force reclaiming mapped pages in the passes #3 and #4 */
-		if (pass > 2) {
+		if (pass > 2)
 			sc.may_swap = 1;
-			sc.swappiness = 100;
-		}
 
 		for (prio = DEF_PRIORITY; prio >= 0; prio--) {
 			unsigned long nr_to_scan = nr_pages - ret;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
