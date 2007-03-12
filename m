From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/3] lumpy: back out removal of active check in isolate_lru_pages
References: <exportbomb.1173723760@pinky>
Message-ID: <6619d81fbc4236897250d4b1ee9b4081@pinky>
Date: Mon, 12 Mar 2007 18:23:47 +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

As pointed out by Christop Lameter it should not be possible for a
page to change its active/inactive state without taking the lru_lock.
Reinstate this safety net.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bda63a0..d7a0860 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -691,10 +691,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			nr_taken++;
 			break;
 
-		default:
-			/* page is being freed, or is a missmatch */
+		case -EBUSY:
+			/* else it is being freed elsewhere */
 			list_move(&page->lru, src);
 			continue;
+
+		default:
+			BUG();
 		}
 
 		if (!order)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
