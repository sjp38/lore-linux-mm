Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6B6876B0036
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:21 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 14:24:20 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 88635C9008A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:01 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AIO1aA269418
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:01 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AIO0uI004737
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:24:01 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 04/11] mm/page_alloc: protect pcp->batch accesses with ACCESS_ONCE
Date: Wed, 10 Apr 2013 11:23:32 -0700
Message-Id: <1365618219-17154-5-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

pcp->batch could change at any point, avoid relying on it being a stable value.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f2929df..9dd0dc0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1181,10 +1181,12 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 {
 	unsigned long flags;
 	int to_drain;
+	unsigned long batch;
 
 	local_irq_save(flags);
-	if (pcp->count >= pcp->batch)
-		to_drain = pcp->batch;
+	batch = ACCESS_ONCE(pcp->batch);
+	if (pcp->count >= batch)
+		to_drain = batch;
 	else
 		to_drain = pcp->count;
 	if (to_drain > 0) {
@@ -1352,8 +1354,9 @@ void free_hot_cold_page(struct page *page, int cold)
 		list_add(&page->lru, &pcp->lists[migratetype]);
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
-		free_pcppages_bulk(zone, pcp->batch, pcp);
-		pcp->count -= pcp->batch;
+		unsigned long batch = ACCESS_ONCE(pcp->batch);
+		free_pcppages_bulk(zone, batch, pcp);
+		pcp->count -= batch;
 	}
 
 out:
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
