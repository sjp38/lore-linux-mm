Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 243F66B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 01:39:23 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6D60AMm017031
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 13 Jul 2009 15:00:10 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A916945DE53
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 15:00:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 82B3B45DE54
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 15:00:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 29A6A1DB8046
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 15:00:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FAB1E3800C
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 15:00:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/4][resend] add per-zone statistics to show_free_areas()
In-Reply-To: <20090713144924.6257.A69D9226@jp.fujitsu.com>
References: <20090713144924.6257.A69D9226@jp.fujitsu.com>
Message-Id: <20090713145732.625A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 13 Jul 2009 15:00:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] add per-zone statistics to show_free_areas()

show_free_areas() displays only a limited amount of zone counters. This
patch includes additional counters in the display to allow easier
debugging. This may be especially useful if an OOM is due to running out
of DMA memory.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
Acked-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/page_alloc.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2151,6 +2151,16 @@ void show_free_areas(void)
 			" inactive_file:%lukB"
 			" unevictable:%lukB"
 			" present:%lukB"
+			" mlocked:%lukB"
+			" dirty:%lukB"
+			" writeback:%lukB"
+			" mapped:%lukB"
+			" slab_reclaimable:%lukB"
+			" slab_unreclaimable:%lukB"
+			" pagetables:%lukB"
+			" unstable:%lukB"
+			" bounce:%lukB"
+			" writeback_tmp:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
 			"\n",
@@ -2165,6 +2175,16 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_INACTIVE_FILE)),
 			K(zone_page_state(zone, NR_UNEVICTABLE)),
 			K(zone->present_pages),
+			K(zone_page_state(zone, NR_MLOCK)),
+			K(zone_page_state(zone, NR_FILE_DIRTY)),
+			K(zone_page_state(zone, NR_WRITEBACK)),
+			K(zone_page_state(zone, NR_FILE_MAPPED)),
+			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
+			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
+			K(zone_page_state(zone, NR_PAGETABLE)),
+			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
+			K(zone_page_state(zone, NR_BOUNCE)),
+			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			zone->pages_scanned,
 			(zone_is_all_unreclaimable(zone) ? "yes" : "no")
 			);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
