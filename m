From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 13/17] resource: Add walk_iomem_res_desc()
Date: Tue, 26 Jan 2016 21:57:29 +0100
Message-ID: <1453841853-11383-14-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Jakub Sitnicki <jsitnicki@gmail.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-arch@vger.kernel.org, linux-mm <linux-mm@kvack.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

Add a new interface, walk_iomem_res_desc(), which walks through the
iomem table by identifying a target with @flags and @desc. This
interface provides the same functionality as walk_iomem_res(), but does
not use strcmp() to @name for better efficiency.

walk_iomem_res() is deprecated and will be removed in a later patch.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Requested-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Hanjun Guo <hanjun.guo@linaro.org>
Cc: Jakub Sitnicki <jsitnicki@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Link: http://lkml.kernel.org/r/1452020081-26534-13-git-send-email-toshi.kani@hpe.com
[ Boris: fixup comments. ]
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 include/linux/ioport.h |  3 +++
 kernel/resource.c      | 66 ++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 59 insertions(+), 10 deletions(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 983bea05d69c..2a4a5e839965 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -268,6 +268,9 @@ extern int
 walk_system_ram_res(u64 start, u64 end, void *arg,
 		    int (*func)(u64, u64, void *));
 extern int
+walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start, u64 end,
+		    void *arg, int (*func)(u64, u64, void *));
+extern int
 walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end, void *arg,
 	       int (*func)(u64, u64, void *));
 
diff --git a/kernel/resource.c b/kernel/resource.c
index 0041cedc47d6..37ed2fcb8246 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -333,14 +333,15 @@ int release_resource(struct resource *old)
 EXPORT_SYMBOL(release_resource);
 
 /*
- * Finds the lowest iomem reosurce exists with-in [res->start.res->end)
- * the caller must specify res->start, res->end, res->flags and "name".
- * If found, returns 0, res is overwritten, if not found, returns -1.
- * This walks through whole tree and not just first level children
- * until and unless first_level_children_only is true.
+ * Finds the lowest iomem resource existing within [res->start.res->end).
+ * The caller must specify res->start, res->end, res->flags, and optionally
+ * desc and "name".  If found, returns 0, res is overwritten, if not found,
+ * returns -1.
+ * This function walks the whole tree and not just first level children until
+ * and unless first_level_children_only is true.
  */
-static int find_next_iomem_res(struct resource *res, char *name,
-			       bool first_level_children_only)
+static int find_next_iomem_res(struct resource *res, unsigned long desc,
+			       char *name, bool first_level_children_only)
 {
 	resource_size_t start, end;
 	struct resource *p;
@@ -360,6 +361,8 @@ static int find_next_iomem_res(struct resource *res, char *name,
 	for (p = iomem_resource.child; p; p = next_resource(p, sibling_only)) {
 		if ((p->flags & res->flags) != res->flags)
 			continue;
+		if ((desc != IORES_DESC_NONE) && (desc != p->desc))
+			continue;
 		if (name && strcmp(p->name, name))
 			continue;
 		if (p->start > end) {
@@ -385,12 +388,55 @@ static int find_next_iomem_res(struct resource *res, char *name,
  * Walks through iomem resources and calls func() with matching resource
  * ranges. This walks through whole tree and not just first level children.
  * All the memory ranges which overlap start,end and also match flags and
+ * desc are valid candidates.
+ *
+ * @desc: I/O resource descriptor. Use IORES_DESC_NONE to skip @desc check.
+ * @flags: I/O resource flags
+ * @start: start addr
+ * @end: end addr
+ *
+ * NOTE: For a new descriptor search, define a new IORES_DESC in
+ * <linux/ioport.h> and set it in 'desc' of a target resource entry.
+ */
+int walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start,
+		u64 end, void *arg, int (*func)(u64, u64, void *))
+{
+	struct resource res;
+	u64 orig_end;
+	int ret = -1;
+
+	res.start = start;
+	res.end = end;
+	res.flags = flags;
+	orig_end = res.end;
+
+	while ((res.start < res.end) &&
+		(!find_next_iomem_res(&res, desc, NULL, false))) {
+
+		ret = (*func)(res.start, res.end, arg);
+		if (ret)
+			break;
+
+		res.start = res.end + 1;
+		res.end = orig_end;
+	}
+
+	return ret;
+}
+
+/*
+ * Walks through iomem resources and calls @func with matching resource
+ * ranges. This walks the whole tree and not just first level children.
+ * All the memory ranges which overlap start,end and also match flags and
  * name are valid candidates.
  *
  * @name: name of resource
  * @flags: resource flags
  * @start: start addr
  * @end: end addr
+ *
+ * NOTE: This function is deprecated and should not be used in new code.
+ * Use walk_iomem_res_desc(), instead.
  */
 int walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end,
 		void *arg, int (*func)(u64, u64, void *))
@@ -404,7 +450,7 @@ int walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end,
 	res.flags = flags;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, name, false))) {
+		(!find_next_iomem_res(&res, IORES_DESC_NONE, name, false))) {
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
 			break;
@@ -433,7 +479,7 @@ int walk_system_ram_res(u64 start, u64 end, void *arg,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, NULL, true))) {
+		(!find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true))) {
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
 			break;
@@ -463,7 +509,7 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(find_next_iomem_res(&res, NULL, true) >= 0)) {
+		(find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true) >= 0)) {
 		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		end_pfn = (res.end + 1) >> PAGE_SHIFT;
 		if (end_pfn > pfn)
-- 
2.3.5
