Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2CACE6B000A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 10:04:18 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x1-v6so5438193edh.8
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 07:04:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j2-v6si5490209ejj.39.2018.11.05.07.04.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 07:04:16 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA5F4Dhs026790
	for <linux-mm@kvack.org>; Mon, 5 Nov 2018 10:04:15 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2njpgkdsmx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Nov 2018 10:04:14 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.ibm.com>;
	Mon, 5 Nov 2018 15:04:07 -0000
From: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Subject: [PATCH v2 1/1] memory_hotplug: fix the panic when memory end is not on the section boundary
Date: Mon,  5 Nov 2018 16:04:01 +0100
In-Reply-To: <20181105150401.97287-1-zaslonko@linux.ibm.com>
References: <20181105150401.97287-1-zaslonko@linux.ibm.com>
Message-Id: <20181105150401.97287-2-zaslonko@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com, zaslonko@linux.ibm.com

If memory end is not aligned with the sparse memory section boundary, the
mapping of such a section is only partly initialized. This may lead to
VM_BUG_ON due to uninitialized struct pages access from
is_mem_section_removable() or test_pages_in_a_zone() function triggered by
memory_hotplug sysfs handlers.

Here are the the panic examples:
 CONFIG_DEBUG_VM_PGFLAGS=y
 kernel parameter mem=2050M
 --------------------------
 page:000003d082008000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
 ([<0000000000385b26>] test_pages_in_a_zone+0xde/0x160)
  [<00000000008f15c4>] show_valid_zones+0x5c/0x190
  [<00000000008cf9c4>] dev_attr_show+0x34/0x70
  [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
  [<00000000003e4194>] seq_read+0x204/0x480
  [<00000000003b53ea>] __vfs_read+0x32/0x178
  [<00000000003b55b2>] vfs_read+0x82/0x138
  [<00000000003b5be2>] ksys_read+0x5a/0xb0
  [<0000000000b86ba0>] system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
  [<0000000000385b26>] test_pages_in_a_zone+0xde/0x160
 Kernel panic - not syncing: Fatal exception: panic_on_oops

 CONFIG_DEBUG_VM_PGFLAGS=y
 kernel parameter mem=3075M
 --------------------------
 page:000003d08300c000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
 ([<000000000038596c>] is_mem_section_removable+0xb4/0x190)
  [<00000000008f12fa>] show_mem_removable+0x9a/0xd8
  [<00000000008cf9c4>] dev_attr_show+0x34/0x70
  [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
  [<00000000003e4194>] seq_read+0x204/0x480
  [<00000000003b53ea>] __vfs_read+0x32/0x178
  [<00000000003b55b2>] vfs_read+0x82/0x138
  [<00000000003b5be2>] ksys_read+0x5a/0xb0
  [<0000000000b86ba0>] system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
  [<000000000038596c>] is_mem_section_removable+0xb4/0x190
 Kernel panic - not syncing: Fatal exception: panic_on_oops

This fix checks if the page lies within the zone boundaries before
accessing the struct page data. The check is added to both functions.

Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: <stable@vger.kernel.org>
---
 mm/memory_hotplug.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 38d94b703e9d..8402e70f74c2 100644
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
+			if (zone && !zone_spans_pfn(zone, pfn + i))
+				return 0;
 			page = pfn_to_page(pfn + i);
 			if (zone && page_zone(page) != zone)
 				return 0;
-- 
2.16.4
