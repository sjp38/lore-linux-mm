Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BE6C76B005C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 04:03:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5B83hRU015683
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Jun 2009 17:03:43 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 515B545DE55
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:03:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 283BA45DD79
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:03:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F7781DB803A
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:03:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BB32D1DB803B
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:03:42 +0900 (JST)
Date: Thu, 11 Jun 2009 17:01:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/3] check unevictable flag in lumy reclaim
Message-Id: <20090611170152.7a43b13b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, apw@canonical.com, riel@redhat.com, minchan.kim@gmail.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Lumpy reclaim scans pages from their pfn. Then, it can find unevictable pages
in its loop. Abort lumpy reclaim when we find Unevictable page, we never get a
block of pages for requested order.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: lumpy-reclaim-trial/mm/vmscan.c
===================================================================
--- lumpy-reclaim-trial.orig/mm/vmscan.c
+++ lumpy-reclaim-trial/mm/vmscan.c
@@ -936,6 +936,9 @@ static unsigned long isolate_lru_pages(u
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
+			/* Abort when the page is mlocked */
+			if (unlikely(PageUnevictable(cursor_page)))
+				break;
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				list_move(&cursor_page->lru, dst);
 				nr_taken++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
