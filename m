Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 58D6F8D0003
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:26:19 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 19:26:18 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 204CA38C804F
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:57 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0Pulm65667232
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:56 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PtPf000810
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 22:25:56 -0200
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 15/17] mm/page_alloc: add informative debugging message in page_outside_zone_boundaries()
Date: Tue, 15 Jan 2013 16:24:52 -0800
Message-Id: <1358295894-24167-16-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Add a debug message which prints when a page is found outside of the
boundaries of the zone it should belong to. Format is:
	"page $pfn outside zone [ $start_pfn - $end_pfn ]"

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f8ed277..f1783cf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -239,13 +239,20 @@ static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 	int ret = 0;
 	unsigned seq;
 	unsigned long pfn = page_to_pfn(page);
+	unsigned long sp, start_pfn;
 
 	do {
 		seq = zone_span_seqbegin(zone);
+		start_pfn = zone->zone_start_pfn;
+		sp = zone->spanned_pages;
 		if (!zone_spans_pfn(zone, pfn))
 			ret = 1;
 	} while (zone_span_seqretry(zone, seq));
 
+	if (ret)
+		pr_debug("page %lu outside zone [ %lu - %lu ]\n",
+			pfn, start_pfn, start_pfn + sp);
+
 	return ret;
 }
 
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
