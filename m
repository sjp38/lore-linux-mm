Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 19006680DC6
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 17:10:25 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id l9so123280532oia.2
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 14:10:25 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id rm7si15260301oeb.42.2015.12.25.14.10.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 14:10:24 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 10/16] resource: Change walk_system_ram to use System RAM type
Date: Fri, 25 Dec 2015 15:09:19 -0700
Message-Id: <1451081365-15190-10-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Toshi Kani <toshi.kani@hpe.com>

Now that all System RAM resource entries have been initialized
to IORESOURCE_SYSTEM_RAM type, change walk_system_ram_res() and
walk_system_ram_range() to call find_next_iomem_res() by setting
IORESOURCE_SYSTEM_RAM to @res.flags and NULL to @name.  With
this change, they walk through the iomem table to find System
RAM ranges without using strcmp().

No functional change is made to the interfaces.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 kernel/resource.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 65eca4d..1d3ea50 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
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
