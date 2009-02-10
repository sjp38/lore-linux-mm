Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 315F86B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 07:58:10 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1ACw7ZI026512
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 21:58:07 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EAFEA45DD72
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:58:06 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BF6F945DE53
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:58:06 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B649E3800B
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:58:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3981CE18003
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 21:58:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] vmscan: initialize sc->nr_reclaimed properly take2
In-Reply-To: <28c262360902100440v765d3f7bnd56cc4b5510349c0@mail.gmail.com>
References: <20090210213502.7007.KOSAKI.MOTOHIRO@jp.fujitsu.com> <28c262360902100440v765d3f7bnd56cc4b5510349c0@mail.gmail.com>
Message-Id: <20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 21:58:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


How about this?

===
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] vmscan: initialize sc->nr_reclaimed properly

Commit a79311c14eae4bb946a97af25f3e1b17d625985d "vmscan: bail out of
direct reclaim after swap_cluster_max pages" moved the nr_reclaimed
counter into the scan control to accumulate the number of all
reclaimed pages in one direct reclaim invocation.

The commit missed to actually adjust try_to_free_pages() and __zone_reclaim()
which now does not initialize sc.nr_reclaimed and makes shrink_zone() make
assumptions on whether to bail out of the reclaim cycle based on an
uninitialized value.

Fix it up. 

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    3 +++
 1 file changed, 3 insertions(+)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1665,6 +1665,7 @@ unsigned long try_to_free_pages(struct z
 								gfp_t gfp_mask)
 {
 	struct scan_control sc = {
+		.nr_reclaimed = 0,
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
@@ -1686,6 +1687,7 @@ unsigned long try_to_free_mem_cgroup_pag
 					   unsigned int swappiness)
 {
 	struct scan_control sc = {
+		.nr_reclaimed = 0,
 		.may_writepage = !laptop_mode,
 		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
@@ -2245,6 +2247,7 @@ static int __zone_reclaim(struct zone *z
 	struct reclaim_state reclaim_state;
 	int priority;
 	struct scan_control sc = {
+		.nr_reclaimed = 0,
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.swap_cluster_max = max_t(unsigned long, nr_pages,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
