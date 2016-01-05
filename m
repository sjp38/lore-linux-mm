Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 097E3800CA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:55:52 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id ba1so281214217obb.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:55:52 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id qh6si31249792obc.22.2016.01.05.10.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:55:51 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 16/17] resource: Kill walk_iomem_res()
Date: Tue,  5 Jan 2016 11:54:40 -0700
Message-Id: <1452020081-26534-16-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
References: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Toshi Kani <toshi.kani@hpe.com>

walk_iomem_res_desc() replaced walk_iomem_res(), and there is no
caller to walk_iomem_res() any more.

Kill walk_iomem_res().  Also remove @name from find_next_iomem_res()
as it is no longer used.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Young <dyoung@redhat.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 include/linux/ioport.h |    3 ---
 kernel/resource.c      |   49 +++++-------------------------------------------
 2 files changed, 5 insertions(+), 47 deletions(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 2a4a5e8..afb4559 100644
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
index 7b26f58..3ed5901 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -335,13 +335,12 @@ EXPORT_SYMBOL(release_resource);
 /*
  * Finds the lowest iomem reosurce exists with-in [res->start.res->end)
  * the caller must specify res->start, res->end, res->flags, and optionally
- * desc and "name".  If found, returns 0, res is overwritten, if not found,
- * returns -1.
+ * desc.  If found, returns 0, res is overwritten, if not found, returns -1.
  * This walks through whole tree and not just first level children
  * until and unless first_level_children_only is true.
  */
 static int find_next_iomem_res(struct resource *res, unsigned long desc,
-				char *name, bool first_level_children_only)
+				bool first_level_children_only)
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
 			break;
@@ -423,42 +420,6 @@ int walk_iomem_res_desc(unsigned long desc, unsigned long flags, u64 start,
 }
 
 /*
- * Walks through iomem resources and calls func() with matching resource
- * ranges. This walks through whole tree and not just first level children.
- * All the memory ranges which overlap start,end and also match flags and
- * name are valid candidates.
- *
- * @name: name of resource
- * @flags: resource flags
- * @start: start addr
- * @end: end addr
- *
- * NOTE: This function is deprecated and should not be used in new code.
- *       Use walk_iomem_res_desc(), instead.
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
  * This function calls callback against all memory range of System RAM
  * which are marked as IORESOURCE_SYSTEM_RAM and IORESOUCE_BUSY.
  * Now, this function is only for System RAM. This function deals with
@@ -477,7 +438,7 @@ int walk_system_ram_res(u64 start, u64 end, void *arg,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(!find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true))) {
+		(!find_next_iomem_res(&res, IORES_DESC_NONE, true))) {
 		ret = (*func)(res.start, res.end, arg);
 		if (ret)
 			break;
@@ -507,7 +468,7 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 	res.flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) &&
-		(find_next_iomem_res(&res, IORES_DESC_NONE, NULL, true) >= 0)) {
+		(find_next_iomem_res(&res, IORES_DESC_NONE, true) >= 0)) {
 		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		end_pfn = (res.end + 1) >> PAGE_SHIFT;
 		if (end_pfn > pfn)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
