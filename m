Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 2D93E6B0078
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:26:05 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 19:26:04 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 283ED38C8067
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:45 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0Pijl295972
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:44 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PhPE019021
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:43 -0500
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 07/17] mm/page_alloc: use zone_spans_pfn() instead of open coding.
Date: Tue, 15 Jan 2013 16:24:44 -0800
Message-Id: <1358295894-24167-8-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Use zone_spans_pfn() instead of open coding pfn ownership checks.

This is split from following patch as could slightly degrade the
generated code. Pre-patch, the code uses it's knowledge that start_pfn <
end_pfn to cut down on the number of comparisons. Post-patch, the
compiler has to figure it out.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index da5a5ec..3911c1a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -978,9 +978,9 @@ int move_freepages_block(struct zone *zone, struct page *page,
 	end_pfn = start_pfn + pageblock_nr_pages - 1;
 
 	/* Do not cross zone boundaries */
-	if (start_pfn < zone->zone_start_pfn)
+	if (!zone_spans_pfn(zone, start_pfn))
 		start_page = page;
-	if (end_pfn >= zone->zone_start_pfn + zone->spanned_pages)
+	if (!zone_spans_pfn(zone, end_pfn))
 		return 0;
 
 	return move_freepages(zone, start_page, end_page, migratetype);
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
