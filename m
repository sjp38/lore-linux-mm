From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/2] ensure we count pages transitioning inactive via clear_active_flags
References: <exportbomb.1185662485@pinky>
Message-ID: <06a9050c636e7b489c2a4c91951d2141@pinky>
Date: Sat, 28 Jul 2007 23:51:59 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

We are transitioning pages from active to inactive in
clear_active_flags, those need counting as PGDEACTIVATE vm events.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d419e10..99ec7fa 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -777,6 +777,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
 					     ISOLATE_BOTH : ISOLATE_INACTIVE);
 		nr_active = clear_active_flags(&page_list);
+		__count_vm_events(PGDEACTIVATE, nr_active);
 
 		__mod_zone_page_state(zone, NR_ACTIVE, -nr_active);
 		__mod_zone_page_state(zone, NR_INACTIVE,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
