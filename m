Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 273D96B007D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 17:27:00 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id va2so13516334obc.1
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 14:26:59 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 186si190849oip.98.2015.02.12.14.26.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Feb 2015 14:26:59 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH v5 1/3] mm: cma: debugfs interface
Date: Thu, 12 Feb 2015 17:26:46 -0500
Message-Id: <1423780008-16727-2-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
References: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: iamjoonsoo.kim@lge.com, m.szyprowski@samsung.com, akpm@linux-foundation.org, lauraa@codeaurora.org, s.strogin@partner.samsung.com, Sasha Levin <sasha.levin@oracle.com>

Implement a simple debugfs interface to expose information about CMA areas
in the system.

Useful for testing/sanity checks for CMA since it was impossible to previously
retrieve this information in userspace.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/Kconfig     |    6 ++++++
 mm/Makefile    |    1 +
 mm/cma.c       |   19 ++++--------------
 mm/cma.h       |   20 +++++++++++++++++++
 mm/cma_debug.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 92 insertions(+), 15 deletions(-)
 create mode 100644 mm/cma.h
 create mode 100644 mm/cma_debug.c

diff --git a/mm/Kconfig b/mm/Kconfig
index a03131b..390214d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -517,6 +517,12 @@ config CMA_DEBUG
 	  processing calls such as dma_alloc_from_contiguous().
 	  This option does not affect warning and error messages.
 
+config CMA_DEBUGFS
+	bool "CMA debugfs interface"
+	depends on CMA && DEBUG_FS
+	help
+	  Turns on the DebugFS interface for CMA.
+
 config CMA_AREAS
 	int "Maximum count of the CMA areas"
 	depends on CMA
diff --git a/mm/Makefile b/mm/Makefile
index 3c1caa2..51052ba 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -76,3 +76,4 @@ obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
 obj-$(CONFIG_CMA)	+= cma.o
 obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
 obj-$(CONFIG_PAGE_EXTENSION) += page_ext.o
+obj-$(CONFIG_CMA_DEBUGFS) += cma_debug.o
diff --git a/mm/cma.c b/mm/cma.c
index 75016fd..e093b53 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -35,16 +35,10 @@
 #include <linux/highmem.h>
 #include <linux/io.h>
 
-struct cma {
-	unsigned long	base_pfn;
-	unsigned long	count;
-	unsigned long	*bitmap;
-	unsigned int order_per_bit; /* Order of pages represented by one bit */
-	struct mutex	lock;
-};
-
-static struct cma cma_areas[MAX_CMA_AREAS];
-static unsigned cma_area_count;
+#include "cma.h"
+
+struct cma cma_areas[MAX_CMA_AREAS];
+unsigned cma_area_count;
 static DEFINE_MUTEX(cma_mutex);
 
 phys_addr_t cma_get_base(struct cma *cma)
@@ -75,11 +69,6 @@ static unsigned long cma_bitmap_aligned_offset(struct cma *cma, int align_order)
 		(cma->base_pfn >> cma->order_per_bit);
 }
 
-static unsigned long cma_bitmap_maxno(struct cma *cma)
-{
-	return cma->count >> cma->order_per_bit;
-}
-
 static unsigned long cma_bitmap_pages_to_bits(struct cma *cma,
 						unsigned long pages)
 {
diff --git a/mm/cma.h b/mm/cma.h
new file mode 100644
index 0000000..4141887
--- /dev/null
+++ b/mm/cma.h
@@ -0,0 +1,20 @@
+#ifndef __MM_CMA_H__
+#define __MM_CMA_H__
+
+struct cma {
+	unsigned long   base_pfn;
+	unsigned long   count;
+	unsigned long   *bitmap;
+	unsigned int order_per_bit; /* Order of pages represented by one bit */
+	struct mutex    lock;
+};
+
+extern struct cma cma_areas[MAX_CMA_AREAS];
+extern unsigned cma_area_count;
+
+static unsigned long cma_bitmap_maxno(struct cma *cma)
+{
+	return cma->count >> cma->order_per_bit;
+}
+
+#endif
diff --git a/mm/cma_debug.c b/mm/cma_debug.c
new file mode 100644
index 0000000..3a25413
--- /dev/null
+++ b/mm/cma_debug.c
@@ -0,0 +1,61 @@
+/*
+ * CMA DebugFS Interface
+ *
+ * Copyright (c) 2015 Sasha Levin <sasha.levin@oracle.com>
+ */
+ 
+
+#include <linux/debugfs.h>
+#include <linux/cma.h>
+
+#include "cma.h"
+
+static struct dentry *cma_debugfs_root;
+
+static int cma_debugfs_get(void *data, u64 *val)
+{
+	unsigned long *p = data;
+
+	*val = *p;
+
+	return 0;
+} 
+
+DEFINE_SIMPLE_ATTRIBUTE(cma_debugfs_fops, cma_debugfs_get, NULL, "%llu\n");
+
+static void cma_debugfs_add_one(struct cma *cma, int idx)
+{
+	struct dentry *tmp;
+	char name[16];
+	int u32s;
+
+	sprintf(name, "cma-%d", idx);
+
+	tmp = debugfs_create_dir(name, cma_debugfs_root);
+
+	debugfs_create_file("base_pfn", S_IRUGO, tmp,
+				&cma->base_pfn, &cma_debugfs_fops);
+	debugfs_create_file("count", S_IRUGO, tmp,
+				&cma->count, &cma_debugfs_fops);
+	debugfs_create_file("order_per_bit", S_IRUGO, tmp,
+			&cma->order_per_bit, &cma_debugfs_fops);
+
+	u32s = DIV_ROUND_UP(cma_bitmap_maxno(cma), BITS_PER_BYTE * sizeof(u32));
+	debugfs_create_u32_array("bitmap", S_IRUGO, tmp, (u32*)cma->bitmap, u32s);
+}
+
+static int __init cma_debugfs_init(void)
+{
+	int i;
+
+	cma_debugfs_root = debugfs_create_dir("cma", NULL);
+	if (!cma_debugfs_root)
+		return -ENOMEM;
+
+	for (i = 0; i < cma_area_count; i++)
+		cma_debugfs_add_one(&cma_areas[i], i);
+
+	return 0;
+}
+late_initcall(cma_debugfs_init);
+
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
