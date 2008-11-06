Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA60H0oo021776
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 6 Nov 2008 09:17:00 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 088AB45DD7F
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:17:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C54A345DD7B
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:16:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AD30E08007
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:16:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 575FDE08001
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:16:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH] mm: the page of MIGRATE_RESERVE don't insert into pcp
Message-Id: <20081106091431.0D2A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  6 Nov 2008 09:16:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

MIGRATE_RESERVE mean that the page is for emergency.
So it shouldn't be cached in pcp.

otherwise, the system have unnecessary memory starvation risk
because other cpu can't use this emergency pages.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Christoph Lameter <cl@linux-foundation.org>

---
 mm/page_alloc.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2008-11-06 06:01:15.000000000 +0900
+++ b/mm/page_alloc.c	2008-11-06 06:27:41.000000000 +0900
@@ -1002,6 +1002,7 @@ static void free_hot_cold_page(struct pa
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
+	int migratetype = get_pageblock_migratetype(page);
 
 	if (PageAnon(page))
 		page->mapping = NULL;
@@ -1018,16 +1019,25 @@ static void free_hot_cold_page(struct pa
 	pcp = &zone_pcp(zone, get_cpu())->pcp;
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
+
+	set_page_private(page, migratetype);
+
+	/* the page for emergency shouldn't be cached */
+	if (migratetype == MIGRATE_RESERVE) {
+		free_one_page(zone, page, 0);
+		goto out;
+	}
 	if (cold)
 		list_add_tail(&page->lru, &pcp->list);
 	else
 		list_add(&page->lru, &pcp->list);
-	set_page_private(page, get_pageblock_migratetype(page));
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
 		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
 		pcp->count -= pcp->batch;
 	}
+
+out:
 	local_irq_restore(flags);
 	put_cpu();
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
