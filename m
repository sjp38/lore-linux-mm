Date: Fri, 4 Jul 2008 18:02:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: memcg: lru scan fix (Was: 2.6.26-rc8-mm1
Message-Id: <20080704180226.46436432.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080703020236.adaa51fa.akpm@linux-foundation.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Since rc5-mm3, memcg easily goes into OOM when limit was low.
This is a fix to split-lru to fix OOM.

==
Under memcg, active anon tend not to go to inactive anon.
This will cause OOM in memcg easily when tons of anon was used at once.
This check was lacked in split-lru.

Signed-off-by:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: test-2.6.26-rc8-mm1/mm/vmscan.c
===================================================================
--- test-2.6.26-rc8-mm1.orig/mm/vmscan.c
+++ test-2.6.26-rc8-mm1/mm/vmscan.c
@@ -1501,6 +1501,8 @@ static unsigned long shrink_zone(int pri
 	 */
 	if (scan_global_lru(sc) && inactive_anon_is_low(zone))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
+	else if (!scan_global_lru(sc))
+		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);
 	return nr_reclaimed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
