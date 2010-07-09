Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 488EA6B02A3
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 06:14:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o69AE5Ip005262
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Jul 2010 19:14:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C144E45DE4F
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 19:14:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8334745DE55
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 19:14:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C17231DB8044
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 19:14:02 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E52091DB803F
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 19:13:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] vmscan: stop meaningless loop iteration when no reclaimable slab
In-Reply-To: <20100709171850.FA22.A69D9226@jp.fujitsu.com>
References: <20100708133152.5e556508.akpm@linux-foundation.org> <20100709171850.FA22.A69D9226@jp.fujitsu.com>
Message-Id: <20100709191308.FA25.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  9 Jul 2010 19:13:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

If number of reclaimable slabs are zero, shrink_icache_memory() and
shrink_dcache_memory() return 0. but strangely shrink_slab() ignore
it and continue meaningless loop iteration.

This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0f9f624..8f61adb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -243,6 +243,11 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 			int nr_before;
 
 			nr_before = (*shrinker->shrink)(0, gfp_mask);
+			/* no slab objects, no more reclaim. */
+			if (nr_before == 0) {
+				total_scan = 0;
+				break;
+			}
 			shrink_ret = (*shrinker->shrink)(this_scan, gfp_mask);
 			if (shrink_ret == -1)
 				break;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
