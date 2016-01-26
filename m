From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 16/17] resource: Kill walk_iomem_res()
Date: Tue, 26 Jan 2016 21:57:32 +0100
Message-ID: <1453841853-11383-17-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Hanjun Guo <hanjun.guo@linaro.org>, Jakub Sitnicki <jsitnicki@gmail.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-arch@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Vinod Koul <vinod.koul@intel.com>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

walk_iomem_res_desc() replaced walk_iomem_res() and there is no
caller to walk_iomem_res() any more. Kill it. Also remove @name from
find_next_iomem_res() as it is no longer used.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Acked-by: Dave Young <dyoung@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Young <dyoung@redhat.com>
Cc: Hanjun Guo <hanjun.guo@linaro.org>
Cc: Jakub Sitnicki <jsitnicki@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Vinod Koul <vinod.koul@intel.com>
Link: http://lkml.kernel.org/r/1452020081-26534-16-git-send-email-toshi.kani@hpe.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 include/linux/ioport.h |  3 ---
 kernel/resource.c      | 49 +++++--------------------------------------------
 2 files changed, 5 insertions(+), 47 deletions(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 2a4a5e839965..afb45597fb5f 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -270,9 +270,6 @@ walk_system_ram_res(u64 start, u64 end, void *arg,
 extern int
 walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start, u64 end,
 		    void *arg, int (*func)(u64, u64, void *));
-extern int
-walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end, void *arg,
-	       int (*func)(u64, u64, void *));
 
 /* True if any part of r1 overlaps r2 */
 static inline bool resource_overlaps(struct resource *r1, struct resource *r2)
diff --git a/kernel/resource.c b/kernel/resource.c
index 37ed2fcb8246..49834309043c 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -335,13 +335,12 @@ EXPORT_SYMBOL(release_resource);
 /*
  * Finds the lowest iomem resource existing within [res->start.res->end).
  * The caller must specify res->start, res->end, res->flags, and optionally
- * desc and "name".  If found, returns 0, res is overwritten, if not found,
- * returns -1.
+ * desc.  If found, returns 0, res is overwritten, if not found, returns -1.
  * This function walks the whole tree and not just first level children until
  * and unless first_level_children_only is true.
  */
 static int find_next_iomem_res(struct resource *res, unsigned long desc,
-			       char *name, bool first_level_children_only)
+			       bool first_level_children_only)
 {
 	resource_size_t start, end;
 	struct resource *p;
@@ -363,8 +362,6 @@ static int find_next_iomem_res(struct resource *res, unsigned long desc,
 			continue;
 		if ((desc != IORES_DESC_NONE) && (desc != p->desc))
 			continue;
-		if (name && strcmp(p->name, name))
-			continue;
 		if (p->start > end) {
 			p = NULL;
 			break;
@@ -411,7 +408,7 @@ int walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start,
 	orig_end = res.end;
 
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, desc, NULL, false))) {
+		(!find_next_iomem_res(&res, desc, false))) {
 
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
@@ -425,42 +422,6 @@ int walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start,
 }
 
 /*
- * Walks through iomem resources and calls @func with matching resource
- * ranges. This walks the whole tree and not just first level children.
- * All the memory ranges which overlap start,end and also match flags and
- * name are valid candidates.
- *
- * @name: name of resource
- * @flags: resource flags
- * @start: start addr
- * @end: end addr
- *
- * NOTE: This function is deprecated and should not be used in new code.
- * Use walk_iomem_res_desc(), instead.
- */
-int walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end,
-		void *arg, int (*func)(u64, u64, void *))
-{
-	struct resource res;
-	u64 orig_end;
-	int ret = -1;
-
-	res.start = start;
-	res.end = end;
-	res.flags = flags;
-	orig_end = res.end;
-	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, IORES_DESC_NONE, name, false))) {
-		ret = (*func)(res.start, res.end, arg);
-		if (ret)
-			break;
-		res.start = res.end + 1;
-		res.end = orig_end;
-	}
-	return ret;
-}
-
-/*
  * This function calls the @func callback against all memory ranges of type
  * System RAM which are marked as IORESOURCE_SYSTEM_RAM and IORESOUCE_BUSY.
  * Now, this function is only for System RAM, it deals with full ranges and
@@ -479,7 +440,7 @@ int walk_system_ram_res(u64 start, u64 end, void *arg,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true))) {
+		(!find_next_iomem_res(&res, IORES_DESC_NONE, true))) {
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
 			break;
@@ -509,7 +470,7 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true) >= 0)) {
+		(find_next_iomem_res(&res, IORES_DESC_NONE, true) >= 0)) {
 		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		end_pfn = (res.end + 1) >> PAGE_SHIFT;
 		if (end_pfn > pfn)
-- 
2.3.5
