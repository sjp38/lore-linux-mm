Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 671B26B005D
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:50 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 19:25:49 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 7520F6E8041
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:44 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0PjVi278368
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:45 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PiwZ015757
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:44 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 08/17] mm/page_alloc: use zone_spans_pfn() instead of open coded checks.
Date: Tue, 15 Jan 2013 16:24:45 -0800
Message-Id: <1358295894-24167-9-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <jmesmon@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

From: Cody P Schafer <jmesmon@gmail.com>

In 2 VM_BUG()s, avoid open coding zone ownership of pfns.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3911c1a..c5d70ce 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -242,9 +242,7 @@ static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 
 	do {
 		seq = zone_span_seqbegin(zone);
-		if (pfn >= zone->zone_start_pfn + zone->spanned_pages)
-			ret = 1;
-		else if (pfn < zone->zone_start_pfn)
+		if (!zone_spans_pfn(zone, pfn))
 			ret = 1;
 	} while (zone_span_seqretry(zone, seq));
 
@@ -5639,8 +5637,7 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
 	pfn = page_to_pfn(page);
 	bitmap = get_pageblock_bitmap(zone, pfn);
 	bitidx = pfn_to_bitidx(zone, pfn);
-	VM_BUG_ON(pfn < zone->zone_start_pfn);
-	VM_BUG_ON(pfn >= zone->zone_start_pfn + zone->spanned_pages);
+	VM_BUG_ON(!zone_spans_pfn(zone, pfn));
 
 	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
 		if (flags & value)
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
