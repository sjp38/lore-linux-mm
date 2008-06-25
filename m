Date: Wed, 25 Jun 2008 19:07:47 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [-mm][PATCH 7/10]  prevent incorrect oom under split_lru
In-Reply-To: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080625190639.D861.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

if zone->recent_scanned parameter become inbalanceing anon and file,
OOM killer can happened although swappable page exist.

So, if priority==0, We should try to reclaim all page for prevent OOM.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Rik van Riel <riel@redhat.com>

---
 mm/vmscan.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1460,8 +1460,10 @@ static unsigned long shrink_zone(int pri
 			 * kernel will slowly sift through each list.
 			 */
 			scan = zone_page_state(zone, NR_LRU_BASE + l);
-			scan >>= priority;
-			scan = (scan * percent[file]) / 100;
+			if (priority) {
+				scan >>= priority;
+				scan = (scan * percent[file]) / 100;
+			}
 			zone->lru[l].nr_scan += scan + 1;
 			nr[l] = zone->lru[l].nr_scan;
 			if (nr[l] >= sc->swap_cluster_max)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
