Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 98F746B067B
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 04:35:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g71so1313031wmg.13
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 01:35:56 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id q45si1344818edq.83.2017.08.03.01.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 01:35:55 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id x64so1312578wmg.1
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 01:35:55 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, hugetlb: do not allocate non-migrateable gigantic pages from movable zones
Date: Thu,  3 Aug 2017 10:35:49 +0200
Message-Id: <20170803083549.21407-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Luiz Capitulino <lcapitulino@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

alloc_gigantic_page doesn't consider movability of the gigantic hugetlb
when scanning eligible ranges for the allocation. As 1GB hugetlb pages
are not movable currently this can break the movable zone assumption
that all allocations are migrateable and as such break memory hotplug.

Reorganize the code and use the standard zonelist allocations scheme
that we use for standard hugetbl pages. htlb_alloc_mask will ensure that
only migratable hugetlb pages will ever see a movable zone.

Fixes: 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at runtime")
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
I have posted this previously more or less as an RFC [1] because the
patch is a result of a code review not a real bug report. I wanted to
know more about the motivation why the original patch (944d9fec8d7a)
did the allocation that way but the more I think about it the more I am
convinced that this was just an omission because not everybody is aware
of zone movable semantic.

Mike has reviewed the code and did some smoke testing. I've done some
testing as well.

Therefore I am sending the patch for inclusion.

[1] http://lkml.kernel.org/r/20170726105004.GI2981@dhcp22.suse.cz

 mm/hugetlb.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bc48ee783dd9..60530bb3d228 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1066,11 +1066,11 @@ static void free_gigantic_page(struct page *page, unsigned int order)
 }
 
 static int __alloc_gigantic_page(unsigned long start_pfn,
-				unsigned long nr_pages)
+				unsigned long nr_pages, gfp_t gfp_mask)
 {
 	unsigned long end_pfn = start_pfn + nr_pages;
 	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE,
-				  GFP_KERNEL);
+				  gfp_mask);
 }
 
 static bool pfn_range_valid_gigantic(struct zone *z,
@@ -1108,19 +1108,24 @@ static bool zone_spans_last_pfn(const struct zone *zone,
 	return zone_spans_pfn(zone, last_pfn);
 }
 
-static struct page *alloc_gigantic_page(int nid, unsigned int order)
+static struct page *alloc_gigantic_page(int nid, struct hstate *h)
 {
+	unsigned int order = huge_page_order(h);
 	unsigned long nr_pages = 1 << order;
 	unsigned long ret, pfn, flags;
-	struct zone *z;
+	struct zonelist *zonelist;
+	struct zone *zone;
+	struct zoneref *z;
+	gfp_t gfp_mask;
 
-	z = NODE_DATA(nid)->node_zones;
-	for (; z - NODE_DATA(nid)->node_zones < MAX_NR_ZONES; z++) {
-		spin_lock_irqsave(&z->lock, flags);
+	gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
+	zonelist = node_zonelist(nid, gfp_mask);
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), NULL) {
+		spin_lock_irqsave(&zone->lock, flags);
 
-		pfn = ALIGN(z->zone_start_pfn, nr_pages);
-		while (zone_spans_last_pfn(z, pfn, nr_pages)) {
-			if (pfn_range_valid_gigantic(z, pfn, nr_pages)) {
+		pfn = ALIGN(zone->zone_start_pfn, nr_pages);
+		while (zone_spans_last_pfn(zone, pfn, nr_pages)) {
+			if (pfn_range_valid_gigantic(zone, pfn, nr_pages)) {
 				/*
 				 * We release the zone lock here because
 				 * alloc_contig_range() will also lock the zone
@@ -1128,16 +1133,16 @@ static struct page *alloc_gigantic_page(int nid, unsigned int order)
 				 * spinning on this lock, it may win the race
 				 * and cause alloc_contig_range() to fail...
 				 */
-				spin_unlock_irqrestore(&z->lock, flags);
-				ret = __alloc_gigantic_page(pfn, nr_pages);
+				spin_unlock_irqrestore(&zone->lock, flags);
+				ret = __alloc_gigantic_page(pfn, nr_pages, gfp_mask);
 				if (!ret)
 					return pfn_to_page(pfn);
-				spin_lock_irqsave(&z->lock, flags);
+				spin_lock_irqsave(&zone->lock, flags);
 			}
 			pfn += nr_pages;
 		}
 
-		spin_unlock_irqrestore(&z->lock, flags);
+		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 
 	return NULL;
@@ -1150,7 +1155,7 @@ static struct page *alloc_fresh_gigantic_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
 
-	page = alloc_gigantic_page(nid, huge_page_order(h));
+	page = alloc_gigantic_page(nid, h);
 	if (page) {
 		prep_compound_gigantic_page(page, huge_page_order(h));
 		prep_new_huge_page(h, page, nid);
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
