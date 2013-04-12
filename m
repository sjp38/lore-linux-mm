Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 78D886B0071
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:48 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 21:14:47 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6FCC96E803A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:42 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1Eirl30408924
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:45 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1EhXQ030790
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:44 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 22/25] mm/page_alloc: in page_outside_zone_boundaries(), avoid premature decisions.
Date: Thu, 11 Apr 2013 18:13:54 -0700
Message-Id: <1365729237-29711-23-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

With some code that expands the zone boundaries, VM_BUG_ON(bad_range()) was being triggered.

Previously, page_outside_zone_boundaries() decided that once it detected
a page outside the boundaries, it was certainly outside even if the
seqlock indicated the data was invalid & needed to be reread. This
methodology _almost_ works because zones are only ever grown. However,
becase the zone span is stored as a start and a length, some expantions
momentarily appear as shifts to the left (when the zone_start_pfn is
assigned prior to zone_spanned_pages).

If we want to remove the seqlock around zone_start_pfn & zone
spanned_pages, always writing the spanned_pages first, issuing a memory
barrier, and then writing the new zone_start_pfn _may_ work. The concern
there is that we could be seen as shrinking the span when zone_start_pfn
is written (the entire span would shift to the left). As there will be
no pages in the exsess span that actually belong to the zone being
manipulated, I don't expect there to be issues.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 97bdf6b..a54baa9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -238,12 +238,13 @@ bool oom_killer_disabled __read_mostly;
 #ifdef CONFIG_DEBUG_VM
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
-	int ret = 0;
+	int ret;
 	unsigned seq;
 	unsigned long pfn = page_to_pfn(page);
 	unsigned long sp, start_pfn;
 
 	do {
+		ret = 0;
 		seq = zone_span_seqbegin(zone);
 		start_pfn = zone->zone_start_pfn;
 		sp = zone->spanned_pages;
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
