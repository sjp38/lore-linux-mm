Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 254C46B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 04:46:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n599GabJ013019
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Jun 2009 18:16:36 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C058845DE4F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:16:35 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A596F45DD72
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:16:35 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AE771DB803A
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:16:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 457051DB8047
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:16:35 +0900 (JST)
Date: Tue, 9 Jun 2009 18:15:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] fix wrong lru rotate back at lumpty reclaim
Message-Id: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>


From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

In lumpty reclaim, "cursor_page" is found just by pfn. Then, we don't know
from which LRU "cursor" page came from. Then, putback it to "src" list is BUG.
Just leave it as it is.
(And I think rotate here is overkilling even if "src" is correct.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: mmotm-2.6.30-Jun4/mm/vmscan.c
===================================================================
--- mmotm-2.6.30-Jun4.orig/mm/vmscan.c
+++ mmotm-2.6.30-Jun4/mm/vmscan.c
@@ -940,10 +940,9 @@ static unsigned long isolate_lru_pages(u
 				nr_taken++;
 				scan++;
 				break;
-
 			case -EBUSY:
-				/* else it is being freed elsewhere */
-				list_move(&cursor_page->lru, src);
+				/* Do nothing because we don't know where
+ 				   cusrsor_page comes from */
 			default:
 				break;	/* ! on LRU or wrong list */
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
