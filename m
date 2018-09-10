Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B675D8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 08:35:36 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id y135-v6so26477178oie.11
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 05:35:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b5-v6si10367170oic.185.2018.09.10.05.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 05:35:34 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8ACYYp6038897
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 08:35:34 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mdrc0927a-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 08:35:33 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.ibm.com>;
	Mon, 10 Sep 2018 13:35:31 +0100
From: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Subject: [PATCH] memory_hotplug: fix the panic when memory end is not on the section boundary
Date: Mon, 10 Sep 2018 14:35:27 +0200
Message-Id: <20180910123527.71209-1-zaslonko@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, osalvador@suse.de, gerald.schaefer@de.ibm.com, zaslonko@linux.ibm.com

If memory end is not aligned with the linux memory section boundary, such
a section is only partly initialized. This may lead to VM_BUG_ON due to
uninitialized struct pages access from is_mem_section_removable() or
test_pages_in_a_zone() function.

Here is one of the panic examples:
 CONFIG_DEBUG_VM_PGFLAGS=y
 kernel parameter mem=3075M

 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 ------------[ cut here ]------------
 Call Trace:
 ([<000000000039b8a4>] is_mem_section_removable+0xcc/0x1c0)
  [<00000000009558ba>] show_mem_removable+0xda/0xe0
  [<00000000009325fc>] dev_attr_show+0x3c/0x80
  [<000000000047e7ea>] sysfs_kf_seq_show+0xda/0x160
  [<00000000003fc4e0>] seq_read+0x208/0x4c8
  [<00000000003cb80e>] __vfs_read+0x46/0x180
  [<00000000003cb9ce>] vfs_read+0x86/0x148
  [<00000000003cc06a>] ksys_read+0x62/0xc0
  [<0000000000c001c0>] system_call+0xdc/0x2d8

This fix checks if the page lies within the zone boundaries before
accessing the struct page data. The check is added to both functions.
Actually similar check has already been present in
is_pageblock_removable_nolock() function but only after the struct page
is accessed.

Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: <stable@vger.kernel.org>
---
 mm/memory_hotplug.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9eea6e809a4e..8e20e8fcc3b0 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1229,9 +1229,8 @@ static struct page *next_active_pageblock(struct page *page)
 	return page + pageblock_nr_pages;
 }
 
-static bool is_pageblock_removable_nolock(struct page *page)
+static bool is_pageblock_removable_nolock(struct page *page, struct zone **zone)
 {
-	struct zone *zone;
 	unsigned long pfn;
 
 	/*
@@ -1241,15 +1240,14 @@ static bool is_pageblock_removable_nolock(struct page *page)
 	 * We have to take care about the node as well. If the node is offline
 	 * its NODE_DATA will be NULL - see page_zone.
 	 */
-	if (!node_online(page_to_nid(page)))
-		return false;
-
-	zone = page_zone(page);
 	pfn = page_to_pfn(page);
-	if (!zone_spans_pfn(zone, pfn))
+	if (*zone && !zone_spans_pfn(*zone, pfn))
 		return false;
+	if (!node_online(page_to_nid(page)))
+		return false;
+	*zone = page_zone(page);
 
-	return !has_unmovable_pages(zone, page, 0, MIGRATE_MOVABLE, true);
+	return !has_unmovable_pages(*zone, page, 0, MIGRATE_MOVABLE, true);
 }
 
 /* Checks if this range of memory is likely to be hot-removable. */
@@ -1257,10 +1255,11 @@ bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
 	struct page *page = pfn_to_page(start_pfn);
 	struct page *end_page = page + nr_pages;
+	struct zone *zone = NULL;
 
 	/* Check the starting page of each pageblock within the range */
 	for (; page < end_page; page = next_active_pageblock(page)) {
-		if (!is_pageblock_removable_nolock(page))
+		if (!is_pageblock_removable_nolock(page, &zone))
 			return false;
 		cond_resched();
 	}
@@ -1296,6 +1295,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 				i++;
 			if (i == MAX_ORDER_NR_PAGES || pfn + i >= end_pfn)
 				continue;
+			/* Check if we got outside of the zone */
+			if (zone && !zone_spans_pfn(zone, pfn))
+				return 0;
 			page = pfn_to_page(pfn + i);
 			if (zone && page_zone(page) != zone)
 				return 0;
-- 
2.16.4
