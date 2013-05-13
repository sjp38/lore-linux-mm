Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 0222E6B007B
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:14:04 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 13 May 2013 15:14:03 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id BADB6C90048
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:14:00 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DJE0ps214326
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:14:00 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DJDsO8001755
	for <linux-mm@kvack.org>; Mon, 13 May 2013 13:13:56 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH RESEND v3 04/11] mm/page_alloc: protect pcp->batch accesses with ACCESS_ONCE
Date: Mon, 13 May 2013 12:08:16 -0700
Message-Id: <1368472103-3427-5-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1368472103-3427-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1368472103-3427-1-git-send-email-cody@linux.vnet.ibm.com>
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
index 7e45b91..71d843d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1182,10 +1182,12 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
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
@@ -1353,8 +1355,9 @@ void free_hot_cold_page(struct page *page, int cold)
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
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
