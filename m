Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5BD575F0001
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 02:25:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3I6Q4eO008750
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 18 Apr 2009 15:26:04 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DEA0045DE61
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:26:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B3C0E45DE55
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:26:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 97E581DB803C
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:26:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 430331DB8038
	for <linux-mm@kvack.org>; Sat, 18 Apr 2009 15:26:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH for mmotm 0414] vmscan,memcg: reintroduce sc->may_swap
Message-Id: <20090418152100.125A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat, 18 Apr 2009 15:26:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Subject: vmscan,memcg: reintroduce sc->may_swap

vmscan-rename-scmay_swap-to-may_unmap.patch removed may_swap flag,
but memcg had used it as a flag for "we need to use swap?", as the
name indicate.

And in current implementation, memcg cannot reclaim mapped file caches
when mem+swap hits the limit.

re-introduce may_swap flag and handle it at get_scan_ratio().
This patch doesn't influence any scan_control users other than memcg.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
--
 mm/vmscan.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c	2009-04-16 21:25:41.000000000 +0900
+++ b/mm/vmscan.c	2009-04-16 21:56:54.000000000 +0900
@@ -64,6 +64,9 @@ struct scan_control {
 	/* Can mapped pages be reclaimed? */
 	int may_unmap;
 
+	/* Can pages be swapped as part of reclaim? */
+	int may_swap;
+
 	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
 	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
 	 * In this context, it doesn't matter that we scan the
@@ -1387,7 +1390,7 @@ static void get_scan_ratio(struct zone *
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
 	/* If we have no swap space, do not bother scanning anon pages. */
-	if (nr_swap_pages <= 0) {
+	if (!sc->may_swap || (nr_swap_pages <= 0)) {
 		percent[0] = 0;
 		percent[1] = 100;
 		return;
@@ -1704,6 +1707,7 @@ unsigned long try_to_free_pages(struct z
 		.may_writepage = !laptop_mode,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
+		.may_swap = 1,
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
@@ -1724,6 +1728,7 @@ unsigned long try_to_free_mem_cgroup_pag
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
+		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
@@ -1734,7 +1739,7 @@ unsigned long try_to_free_mem_cgroup_pag
 	struct zonelist *zonelist;
 
 	if (noswap)
-		sc.may_unmap = 0;
+		sc.may_swap = 0;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -1774,6 +1779,7 @@ static unsigned long balance_pgdat(pg_da
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
+		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = vm_swappiness,
 		.order = order,
@@ -2120,6 +2126,7 @@ unsigned long shrink_all_memory(unsigned
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 0,
+		.may_swap = 1,
 		.may_writepage = 1,
 		.isolate_pages = isolate_pages_global,
 	};
@@ -2304,6 +2311,7 @@ static int __zone_reclaim(struct zone *z
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
+		.may_swap = 1,
 		.swap_cluster_max = max_t(unsigned long, nr_pages,
 					SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
