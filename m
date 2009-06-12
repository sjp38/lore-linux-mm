Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 51E366B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 21:27:28 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5C1SHE4018403
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Jun 2009 10:28:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 430D345DE70
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:28:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE7CA45DE60
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:28:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 850861DB8041
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:28:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 313321DB803E
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:28:16 +0900 (JST)
Date: Fri, 12 Jun 2009 10:26:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] fix lumpy reclaim lru handiling at
 isolate_lru_pages v2
Message-Id: <20090612102644.a3e7ad3a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Sorry for noisy posts. I hope this should be the last trial.
Thank you for all helps.

-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

At lumpy reclaim, a page failed to be taken by __isolate_lru_page() can
be pushed back to "src" list by list_move(). But the page may not be from
"src" list. This pushes the page back to wrong LRU.
And list_move() itself is unnecessary because the page is
not on top of LRU. Then, leave it as it is if __isolate_lru_page() fails.

Changelog: v1->v2
 - removed buggy break.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

Index: lumpy-reclaim-trial/mm/vmscan.c
===================================================================
--- lumpy-reclaim-trial.orig/mm/vmscan.c
+++ lumpy-reclaim-trial/mm/vmscan.c
@@ -936,18 +936,10 @@ static unsigned long isolate_lru_pages(u
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
-			switch (__isolate_lru_page(cursor_page, mode, file)) {
-			case 0:
+			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				list_move(&cursor_page->lru, dst);
 				nr_taken++;
 				scan++;
-				break;
-
-			case -EBUSY:
-				/* else it is being freed elsewhere */
-				list_move(&cursor_page->lru, src);
-			default:
-				break;	/* ! on LRU or wrong list */
 			}
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
