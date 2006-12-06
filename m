Date: Wed, 6 Dec 2006 17:01:05 +0000
Subject: [PATCH 4/4] lumpy take the other active inactive pages in the area
Message-ID: <4fe113c0c99477e6ccb24e1d848e7ae5@pinky>
References: <exportbomb.1165424343@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When we scan an order N aligned area around our tag page take any
other pages with a matching active state to that of the tag page.
This will tend to demote areas of the order we are interested from
the active list to the inactive list and from the end of the inactive
list, increasing the chances of such areas coming free together.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 85f626b..fc23d87 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -710,7 +710,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			case 0:
 				list_move(&tmp->lru, dst);
 				nr_taken++;
-				continue;
+				break;
 
 			case -EBUSY:
 				/* else it is being freed elsewhere */
@@ -718,7 +718,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			default:
 				break;
 			}
-			break;
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
