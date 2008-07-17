Date: Thu, 17 Jul 2008 12:27:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mmtom][BUGFIX]
 vmscan-second-chance-replacement-for-anonymous-pages-fix.patch
Message-Id: <20080717122751.92525032.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Under memcg, active anon tend not to go to inactive anon.
This will cause OOM in memcg easily when tons of anon was used at once.
This check was lacked in split-lru.

This patch is a fix agaisnt
vmscan-second-chance-replacement-for-anonymous-pages.patch


Changelog: v1 -> v2:
 - avoid adding "else".

Signed-off-by:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Rik van Riel <riel@redhat.com>

 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmtom-stamp-2008-07-15-15-39/mm/vmscan.c
===================================================================
--- mmtom-stamp-2008-07-15-15-39.orig/mm/vmscan.c
+++ mmtom-stamp-2008-07-15-15-39/mm/vmscan.c
@@ -1351,7 +1351,7 @@ static unsigned long shrink_zone(int pri
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (scan_global_lru(sc) && inactive_anon_is_low(zone))
+	if (!scan_global_lru(sc) || inactive_anon_is_low(zone))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
