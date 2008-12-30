Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E9AED6B0044
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 05:55:51 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBUAtmw2032749
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Dec 2008 19:55:49 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CAD3845DE4F
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 19:55:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AF8A545DD72
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 19:55:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CBE61DB8037
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 19:55:48 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A84E1DB8038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 19:55:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: stop kswapd's infinite loop at high order allocation
Message-Id: <20081230195006.1286.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Dec 2008 19:55:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, wassim dagash <wassim.dagash@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


ok, wassim confirmed this patch works well.


==
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: kswapd stop infinite loop at high order allocation

Wassim Dagash reported following kswapd infinite loop problem.

  kswapd runs in some infinite loop trying to swap until order 10 of zone
  highmem is OK, While zone higmem (as I understand) has nothing to do
  with contiguous memory (cause there is no 1-1 mapping) which means
  kswapd will continue to try to balance order 10 of zone highmem
  forever (or until someone release a very large chunk of highmem).

He proposed remove contenious checking on highmem at all.
However hugepage on highmem need contenious highmem page.

To add infinite loop stopper is simple and good.



Reported-by: wassim dagash <wassim.dagash@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1872,6 +1872,17 @@ out:
 
 		try_to_freeze();
 
+		/*
+		 * When highmem is very fragmented,
+		 * alloc_pages(GFP_KERNEL, very-high-order) can cause
+		 * infinite loop because zone_watermark_ok(highmem) failed.
+		 * However, alloc_pages(GFP_KERNEL..) indicate highmem memory
+		 * continuousness isn't necessary.
+		 * Therefore we don't want contenious check at 2nd loop.
+		 */
+		if (nr_reclaimed < SWAP_CLUSTER_MAX)
+			order = sc.order = 0;
+
 		goto loop_again;
 	}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
