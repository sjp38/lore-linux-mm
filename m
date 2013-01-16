Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 61C3B6B0082
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:26:34 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 17:26:33 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 82621C40006
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:28 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0PcaY098120
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:38 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PcKS020414
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:38 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 04/17] mm: add helper ensure_zone_is_initialized()
Date: Tue, 15 Jan 2013 16:24:41 -0800
Message-Id: <1358295894-24167-5-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <jmesmon@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

From: Cody P Schafer <jmesmon@gmail.com>

ensure_zone_is_initialized() checks if a zone is in a empty & not
initialized state (typically occuring after it is created in memory
hotplugging), and, if so, calls init_currently_empty_zone() to
initialize the zone.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d04ed87..875bdfe 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -253,6 +253,17 @@ static void fix_zone_id(struct zone *zone, unsigned long start_pfn,
 		set_page_links(pfn_to_page(pfn), zid, nid, pfn);
 }
 
+/* Can fail with -ENOMEM from allocating a wait table with vmalloc() or
+ * alloc_bootmem_node_nopanic() */
+static int __ref ensure_zone_is_initialized(struct zone *zone,
+			unsigned long start_pfn, unsigned long num_pages)
+{
+	if (!zone_is_initialized(zone))
+		return init_currently_empty_zone(zone, start_pfn, num_pages,
+						 MEMMAP_HOTPLUG);
+	return 0;
+}
+
 static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 		unsigned long start_pfn, unsigned long end_pfn)
 {
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
