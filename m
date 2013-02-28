Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 20B5C6B0009
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:45:03 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 15:45:02 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id AB32A38C801D
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:59 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SKivWS307284
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:58 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SKlSa8026217
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 13:47:28 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 07/24] memory_hotplug: export ensure_zone_is_initialized() in mm/internal.h
Date: Thu, 28 Feb 2013 12:44:15 -0800
Message-Id: <1362084272-11282-8-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <20130228024112.GA24970@negative>
 <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: David Hansen <dave@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Export ensure_zone_is_initialized() so that it can be used to initialize
new zones within the dynamic numa code.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/internal.h       | 8 ++++++++
 mm/memory_hotplug.c | 2 +-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/internal.h b/mm/internal.h
index 1c0c4cc..6c63752 100644
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
index 9e4c32b..9f43c80 100644
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
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
