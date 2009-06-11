Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C51A16B0055
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 04:38:39 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5B8doJa015234
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Jun 2009 17:39:50 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D63845DE6F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:39:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A42B45DE6E
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:39:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 457E01DB8040
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:39:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F35851DB803F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:39:49 +0900 (JST)
Date: Thu, 11 Jun 2009 17:38:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/3] check unevictable flag in lumy reclaim v2
Message-Id: <20090611173819.0f76e431.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090611172249.6D3C.A69D9226@jp.fujitsu.com>
References: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com>
	<20090611170152.7a43b13b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090611172249.6D3C.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, apw@canonical.com, riel@redhat.com, minchan.kim@gmail.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

How about this ?

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Lumpy reclaim check pages from their pfn. Then, it can find unevictable pages
in its loop.
Abort lumpy reclaim when we find Unevictable page, we never get a lump
of pages for requested order.

Changelog: v1->v2
 - rewrote commet.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: lumpy-reclaim-trial/mm/vmscan.c
===================================================================
--- lumpy-reclaim-trial.orig/mm/vmscan.c
+++ lumpy-reclaim-trial/mm/vmscan.c
@@ -936,6 +936,15 @@ static unsigned long isolate_lru_pages(u
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
+			/*
+			 * We tries to free all pages in this range to create
+			 * a free large page. Then, if the range includes a page
+			 * never be reclaimed, we have no reason to do more.
+			 * PageUnevictable page is not a page which can be
+			 * easily freed. Abort this scan now.
+			 */
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
