Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 672786B025D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 18:38:10 -0500 (EST)
Received: by obcno2 with SMTP id no2so25860247obc.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:38:10 -0800 (PST)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id cs7si1618004oeb.78.2015.12.14.15.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 15:38:09 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 09/11] resource: Change walk_system_ram to use System RAM type
Date: Mon, 14 Dec 2015 16:37:24 -0700
Message-Id: <1450136246-17053-9-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Toshi Kani <toshi.kani@hpe.com>

Change walk_system_ram_res() and walk_system_ram_range() to
call find_next_iomem_res() by setting IORESOURCE_SYSTEM_RAM
to @res->flags and NULL to @name.  With this change, they
walk through the resource table without doing strcmp().

No functional change is made to the interfaces.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 kernel/resource.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 56bed6d..c6f13d0 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -334,8 +334,8 @@ EXPORT_SYMBOL(release_resource);
 
 /*
  * Finds the lowest iomem reosurce exists with-in [res->start.res->end)
- * the caller must specify res->start, res->end, res->flags and "name".
- * If found, returns 0, res is overwritten, if not found, returns -1.
+ * the caller must specify res->start, res->end, res->flags and optionally
+ * "name".  If found, returns 0, res is overwritten, if not found, returns -1.
  * This walks through whole tree and not just first level children
  * until and unless first_level_children_only is true.
  */
@@ -415,9 +415,9 @@ int walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end,
 }
 
 /*
- * This function calls callback against all memory range of "System RAM"
- * which are marked as IORESOURCE_MEM and IORESOUCE_BUSY.
- * Now, this function is only for "System RAM". This function deals with
+ * This function calls callback against all memory range of System RAM
+ * which are marked as IORESOURCE_SYSTEM_RAM and IORESOUCE_BUSY.
+ * Now, this function is only for System RAM. This function deals with
  * full ranges and not pfn. If resources are not pfn aligned, dealing
  * with pfn can truncate ranges.
  */
@@ -430,10 +430,10 @@ int walk_system_ram_res(u64 start, u64 end, void *arg,
 
 	res.start = start;
 	res.end = end;
-	res.flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, "System RAM", true))) {
+		(!find_next_iomem_res(&res, NULL, true))) {
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
 			break;
@@ -446,9 +446,9 @@ int walk_system_ram_res(u64 start, u64 end, void *arg,
 #if !defined(CONFIG_ARCH_HAS_WALK_MEMORY)
 
 /*
- * This function calls callback against all memory range of "System RAM"
- * which are marked as IORESOURCE_MEM and IORESOUCE_BUSY.
- * Now, this function is only for "System RAM".
+ * This function calls callback against all memory range of System RAM
+ * which are marked as IORESOURCE_SYSTEM_RAM and IORESOUCE_BUSY.
+ * Now, this function is only for System RAM.
  */
 int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 		void *arg, int (*func)(unsigned long, unsigned long, void *))
@@ -460,10 +460,10 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 
 	res.start = (u64) start_pfn << PAGE_SHIFT;
 	res.end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
-	res.flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(find_next_iomem_res(&res, "System RAM", true) >= 0)) {
+		(find_next_iomem_res(&res, NULL, true) >= 0)) {
 		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		end_pfn = (res.end + 1) >> PAGE_SHIFT;
 		if (end_pfn > pfn)
@@ -484,7 +484,7 @@ static int __is_ram(unsigned long pfn, unsigned long nr_pages, void *arg)
 }
 /*
  * This generic page_is_ram() returns true if specified address is
- * registered as "System RAM" in iomem_resource list.
+ * registered as System RAM in iomem_resource list.
  */
 int __weak page_is_ram(unsigned long pfn)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
