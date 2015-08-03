Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 063176B025A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 04:19:27 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so109906906wib.0
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 01:19:26 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id q5si12589193wia.117.2015.08.03.01.19.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Aug 2015 01:19:25 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id ADAA3988F4
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 08:19:24 +0000 (UTC)
Date: Mon, 3 Aug 2015 09:19:22 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm: initialize hotplugged pages as reserved
Message-ID: <20150803081922.GG5840@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Vrabel <david.vrabel@citrix.com>, Alex Ng <alexng@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit 92923ca3aace (mm: meminit: only set page reserved in the memblock
region) broke memory hotplug which expects the memmap for newly added
sections to be reserved until onlined by online_pages_range(). This patch
marks hotplugged pages as reserved when adding new zones.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reported-and-tested-by: David Vrabel <david.vrabel@citrix.com>
---
 mm/memory_hotplug.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 460d0fe..169770a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -446,7 +446,7 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 	int nr_pages = PAGES_PER_SECTION;
 	int nid = pgdat->node_id;
 	int zone_type;
-	unsigned long flags;
+	unsigned long flags, pfn;
 	int ret;
 
 	zone_type = zone - pgdat->node_zones;
@@ -461,6 +461,14 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 	memmap_init_zone(nr_pages, nid, zone_type,
 			 phys_start_pfn, MEMMAP_HOTPLUG);
+
+	/* online_page_range is called later and expects pages reserved */
+	for (pfn = phys_start_pfn; pfn < phys_start_pfn + nr_pages; pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+
+		SetPageReserved(pfn_to_page(pfn));
+	}
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
