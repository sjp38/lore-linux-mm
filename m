Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 9A3C36B02A4
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:02:10 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:02:09 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 99FDC3E40044
	for <linux-mm@kvack.org>; Thu,  2 May 2013 18:00:58 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301CNh358652
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:12 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301Chm029527
	for <linux-mm@kvack.org>; Thu, 2 May 2013 18:01:12 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 04/31] memory_hotplug: export ensure_zone_is_initialized() in mm/internal.h
Date: Thu,  2 May 2013 17:00:36 -0700
Message-Id: <1367539263-19999-5-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Export ensure_zone_is_initialized() so that it can be used to initialize
new zones within the dynamic numa code.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/internal.h       | 8 ++++++++
 mm/memory_hotplug.c | 2 +-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/internal.h b/mm/internal.h
index 8562de0..b11e574 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -105,6 +105,14 @@ extern void prep_compound_page(struct page *page, unsigned long order);
 extern bool is_free_buddy_page(struct page *page);
 #endif
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+/*
+ * in mm/memory_hotplug.c
+ */
+extern int ensure_zone_is_initialized(struct zone *zone,
+			unsigned long start_pfn, unsigned long num_pages);
+#endif
+
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 
 /*
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index fafeaae..f4cb01a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -284,7 +284,7 @@ static void fix_zone_id(struct zone *zone, unsigned long start_pfn,
 
 /* Can fail with -ENOMEM from allocating a wait table with vmalloc() or
  * alloc_bootmem_node_nopanic() */
-static int __ref ensure_zone_is_initialized(struct zone *zone,
+int __ref ensure_zone_is_initialized(struct zone *zone,
 			unsigned long start_pfn, unsigned long num_pages)
 {
 	if (!zone_is_initialized(zone))
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
