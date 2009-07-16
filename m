Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9B9BC6B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 04:40:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G8eIfl017812
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 17:40:18 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E969345DE5D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:40:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C9E3645DE51
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:40:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D23A1DB803A
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:40:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 706C51DB8038
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:40:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/5] Use add_page_to_lru_list() helper function
In-Reply-To: <20090716173449.9D4B.A69D9226@jp.fujitsu.com>
References: <20090716173449.9D4B.A69D9226@jp.fujitsu.com>
Message-Id: <20090716173921.9D54.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 17:40:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Subject: Use add_page_to_lru_list() helper function

add_page_to_lru_list() is equivalent to
  - add lru list (global)
  - add lru list (mem-cgroup)
  - modify zone stat

We can use it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1225,12 +1225,12 @@ static void move_active_pages_to_lru(str
 
 	while (!list_empty(list)) {
 		page = lru_to_page(list);
+		list_del(&page->lru);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
-		list_move(&page->lru, &zone->lru[lru].list);
-		mem_cgroup_add_lru_list(page, lru);
+		add_page_to_lru_list(zone, page, lru);
 		pgmoved++;
 
 		if (!pagevec_add(&pvec, page) || list_empty(list)) {
@@ -1241,7 +1241,6 @@ static void move_active_pages_to_lru(str
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
