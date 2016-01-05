Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id C43F9800CA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:55:45 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id o124so279614829oia.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:55:45 -0800 (PST)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id y6si9888750obk.21.2016.01.05.10.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:55:45 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 13/17] resource: Add walk_iomem_res_desc()
Date: Tue,  5 Jan 2016 11:54:37 -0700
Message-Id: <1452020081-26534-13-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
References: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Toshi Kani <toshi.kani@hpe.com>

Add a new interface, walk_iomem_res_desc(), which walks through
the iomem table by identifying a target with @flags and @desc.
This interface provides the same functionality as walk_iomem_res(),
but does not use strcmp() to @name for better efficiency.

walk_iomem_res() is deprecated and will be removed in a later
patch.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 include/linux/ioport.h |    3 ++
 kernel/resource.c      |   58 ++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 54 insertions(+), 7 deletions(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 983bea0..2a4a5e8 100644
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
index 52e6380..7b26f58 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -334,13 +334,14 @@ EXPORT_SYMBOL(release_resource);
 
 /*
  * Finds the lowest iomem reosurce exists with-in [res->start.res->end)
- * the caller must specify res->start, res->end, res->flags and "name".
- * If found, returns 0, res is overwritten, if not found, returns -1.
+ * the caller must specify res->start, res->end, res->flags, and optionally
+ * desc and "name".  If found, returns 0, res is overwritten, if not found,
+ * returns -1.
  * This walks through whole tree and not just first level children
  * until and unless first_level_children_only is true.
  */
-static int find_next_iomem_res(struct resource *res, char *name,
-			       bool first_level_children_only)
+static int find_next_iomem_res(struct resource *res, unsigned long desc,
+				char *name, bool first_level_children_only)
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
@@ -385,12 +388,53 @@ static int find_next_iomem_res(struct resource *res, char *name,
  * Walks through iomem resources and calls func() with matching resource
  * ranges. This walks through whole tree and not just first level children.
  * All the memory ranges which overlap start,end and also match flags and
+ * desc are valid candidates.
+ *
+ * @desc: I/O resource descriptor. Use IORES_DESC_NONE to skip this check.
+ * @flags: I/O resource flags
+ * @start: start addr
+ * @end: end addr
+ *
+ * NOTE: For a new descriptor search, define a new IORES_DESC in
+ * <linux/ioport.h> and set it to 'desc' of a target resource entry.
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
+		ret = (*func)(res.start, res.end, arg);
+		if (ret)
+			break;
+		res.start = res.end + 1;
+		res.end = orig_end;
+	}
+
+	return ret;
+}
+
+/*
+ * Walks through iomem resources and calls func() with matching resource
+ * ranges. This walks through whole tree and not just first level children.
+ * All the memory ranges which overlap start,end and also match flags and
  * name are valid candidates.
  *
  * @name: name of resource
  * @flags: resource flags
  * @start: start addr
  * @end: end addr
+ *
+ * NOTE: This function is deprecated and should not be used in new code.
+ *       Use walk_iomem_res_desc(), instead.
  */
 int walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end,
 		void *arg, int (*func)(u64, u64, void *))
@@ -404,7 +448,7 @@ int walk_iomem_res(char *name, unsigned long flags, u64 start, u64 end,
 	res.flags = flags;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, name, false))) {
+		(!find_next_iomem_res(&res, IORES_DESC_NONE, name, false))) {
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
 			break;
@@ -433,7 +477,7 @@ int walk_system_ram_res(u64 start, u64 end, void *arg,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, NULL, true))) {
+		(!find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true))) {
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
 			break;
@@ -463,7 +507,7 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(find_next_iomem_res(&res, NULL, true) >= 0)) {
+		(find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true) >= 0)) {
 		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		end_pfn = (res.end + 1) >> PAGE_SHIFT;
 		if (end_pfn > pfn)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
