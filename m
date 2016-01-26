From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 10/17] resource: Change walk_system_ram() to use System RAM type
Date: Tue, 26 Jan 2016 21:57:26 +0100
Message-ID: <1453841853-11383-11-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
Sender: linux-arch-owner@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jakub Sitnicki <jsitnicki@gmail.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-arch@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

Now that all System RAM resource entries have been initialized
to IORESOURCE_SYSTEM_RAM type, change walk_system_ram_res() and
walk_system_ram_range() to call find_next_iomem_res() by setting
@res.flags to IORESOURCE_SYSTEM_RAM and @name to NULL. With this
change, they walk through the iomem table to find System RAM
ranges without the need to do strcmp() on the resource names.

No functional change is made to the interfaces.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Jakub Sitnicki <jsitnicki@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Link: http://lkml.kernel.org/r/1452020081-26534-10-git-send-email-toshi.kani@hpe.com
[ Boris: fixup comments. ]
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 kernel/resource.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 61512e972ece..994f1e41269b 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -415,11 +415,11 @@ int walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end,
 }
 
 /*
- * This function calls callback against all memory range of "System RAM"
- * which are marked as IORESOURCE_MEM and IORESOUCE_BUSY.
- * Now, this function is only for "System RAM". This function deals with
- * full ranges and not pfn. If resources are not pfn aligned, dealing
- * with pfn can truncate ranges.
+ * This function calls the @func callback against all memory ranges of type
+ * System RAM which are marked as IORESOURCE_SYSTEM_RAM and IORESOUCE_BUSY.
+ * Now, this function is only for System RAM, it deals with full ranges and
+ * not PFNs. If resources are not PFN-aligned, dealing with PFNs can truncate
+ * ranges.
  */
 int walk_system_ram_res(u64 start, u64 end, void *arg,
 				int (*func)(u64, u64, void *))
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
+ * This function calls the @func callback against all memory ranges of type
+ * System RAM which are marked as IORESOURCE_SYSTEM_RAM and IORESOUCE_BUSY.
+ * It is to be used only for System RAM.
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
2.3.5
