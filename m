Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1RJblPT009022
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 14:37:47 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1RJaPVb086990
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 14:36:25 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1RJaPxs006688
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 14:36:25 -0500
From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 5/5] lumpy: only check for valid pages when holes are present
References: <exportbomb.1172604830@kernel>
Message-ID: <297d400448043264b3e5afe21291485e@kernel>
Date: Tue, 27 Feb 2007 11:36:24 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

We only need to check that each page is valid with pfn_valid when
we are on an architecture which had holes within zones.  Make this
check conditional.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bef7e92..f249ad7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -725,9 +725,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			/* The target page is in the block, ignore it. */
 			if (unlikely(pfn == page_pfn))
 				continue;
+#ifdef CONFIG_HOLES_IN_ZONE
 			/* Avoid holes within the zone. */
 			if (unlikely(!pfn_valid(pfn)))
 				break;
+#endif
 
 			cursor_page = pfn_to_page(pfn);
 			/* Check that we have not crossed a zone boundary. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
