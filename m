Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3A1616B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 04:37:36 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G8baNh016546
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 17:37:36 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 77F1845DE4D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:37:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4627345DE6E
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:37:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 10B02E08006
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:37:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 99CBAE0800E
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:37:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/5]  move ClearPageActive from move_active_pages() to shrink_active_list()
Message-Id: <20090716173449.9D4B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 17:37:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

This patch series are several vmscan cleanups.

===================
Subject: [PATCH] move ClearPageActive from move_active_pages() to shrink_active_list()

The mvoe_active_pages_to_lru() function is called under irq disabled and
ClearPageActive() doesn't need irq disabling.

Then, this patch move it into shrink_active_list().


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1230,10 +1230,6 @@ static void move_active_pages_to_lru(str
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		VM_BUG_ON(!PageActive(page));
-		if (!is_active_lru(lru))
-			ClearPageActive(page);	/* we are de-activating */
-
 		list_move(&page->lru, &zone->lru[lru].list);
 		mem_cgroup_add_lru_list(page, lru);
 		pgmoved++;
@@ -1315,6 +1311,7 @@ static void shrink_active_list(unsigned 
 			}
 		}
 
+		ClearPageActive(page);	/* we are de-activating */
 		list_add(&page->lru, &l_inactive);
 	}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
