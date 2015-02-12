Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3DEA96B0080
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 17:27:04 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id va2so13516948obc.1
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 14:27:04 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id oj5si194083oeb.50.2015.02.12.14.27.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Feb 2015 14:27:03 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH v5 2/3] mm: cma: allocation trigger
Date: Thu, 12 Feb 2015 17:26:47 -0500
Message-Id: <1423780008-16727-3-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
References: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: iamjoonsoo.kim@lge.com, m.szyprowski@samsung.com, akpm@linux-foundation.org, lauraa@codeaurora.org, s.strogin@partner.samsung.com, Sasha Levin <sasha.levin@oracle.com>

Provides a userspace interface to trigger a CMA allocation.

Usage:

	echo [pages] > alloc

This would provide testing/fuzzing access to the CMA allocation paths.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/cma.c       |    6 ++++++
 mm/cma.h       |    4 ++++
 mm/cma_debug.c |   56 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 64 insertions(+), 2 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index e093b53..9e3d44a 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -121,6 +121,12 @@ static int __init cma_activate_area(struct cma *cma)
 	} while (--i);
 
 	mutex_init(&cma->lock);
+
+#ifdef CONFIG_CMA_DEBUGFS
+	INIT_HLIST_HEAD(&cma->mem_head);
+	spin_lock_init(&cma->mem_head_lock);
+#endif
+
 	return 0;
 
 err:
diff --git a/mm/cma.h b/mm/cma.h
index 4141887..1132d73 100644
--- a/mm/cma.h
+++ b/mm/cma.h
@@ -7,6 +7,10 @@ struct cma {
 	unsigned long   *bitmap;
 	unsigned int order_per_bit; /* Order of pages represented by one bit */
 	struct mutex    lock;
+#ifdef CONFIG_CMA_DEBUGFS
+	struct hlist_head mem_head;
+	spinlock_t mem_head_lock;
+#endif
 };
 
 extern struct cma cma_areas[MAX_CMA_AREAS];
diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 3a25413..5bd6863 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -7,9 +7,18 @@
 
 #include <linux/debugfs.h>
 #include <linux/cma.h>
+#include <linux/list.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
 
 #include "cma.h"
 
+struct cma_mem {
+	struct hlist_node node;
+	struct page *p;
+	unsigned long n;
+};
+
 static struct dentry *cma_debugfs_root;
 
 static int cma_debugfs_get(void *data, u64 *val)
@@ -23,8 +32,48 @@ static int cma_debugfs_get(void *data, u64 *val)
 
 DEFINE_SIMPLE_ATTRIBUTE(cma_debugfs_fops, cma_debugfs_get, NULL, "%llu\n");
 
-static void cma_debugfs_add_one(struct cma *cma, int idx)
+static void cma_add_to_cma_mem_list(struct cma *cma, struct cma_mem *mem)
+{
+	spin_lock(&cma->mem_head_lock);
+	hlist_add_head(&mem->node, &cma->mem_head);
+	spin_unlock(&cma->mem_head_lock);
+}
+
+static int cma_alloc_mem(struct cma *cma, int count)
+{
+	struct cma_mem *mem;
+	struct page *p;
+
+	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
+	if (!mem) 
+		return -ENOMEM;
+
+	p = cma_alloc(cma, count, CONFIG_CMA_ALIGNMENT);
+	if (!p) {
+		kfree(mem);
+		return -ENOMEM;
+	}
+
+	mem->p = p;
+	mem->n = count;
+
+	cma_add_to_cma_mem_list(cma, mem);
+
+	return 0;
+}
+
+static int cma_alloc_write(void *data, u64 val)
 {
+	int pages = val;
+	struct cma *cma = data;
+
+	return cma_alloc_mem(cma, pages);
+}
+
+DEFINE_SIMPLE_ATTRIBUTE(cma_alloc_fops, NULL, cma_alloc_write, "%llu\n");
+
+static void cma_debugfs_add_one(struct cma *cma, int idx)
+{       
 	struct dentry *tmp;
 	char name[16];
 	int u32s;
@@ -33,12 +82,15 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 
 	tmp = debugfs_create_dir(name, cma_debugfs_root);
 
+	debugfs_create_file("alloc", S_IWUSR, cma_debugfs_root, cma,
+				&cma_alloc_fops);
+
 	debugfs_create_file("base_pfn", S_IRUGO, tmp,
 				&cma->base_pfn, &cma_debugfs_fops);
 	debugfs_create_file("count", S_IRUGO, tmp,
 				&cma->count, &cma_debugfs_fops);
 	debugfs_create_file("order_per_bit", S_IRUGO, tmp,
-			&cma->order_per_bit, &cma_debugfs_fops);
+				&cma->order_per_bit, &cma_debugfs_fops);
 
 	u32s = DIV_ROUND_UP(cma_bitmap_maxno(cma), BITS_PER_BYTE * sizeof(u32));
 	debugfs_create_u32_array("bitmap", S_IRUGO, tmp, (u32*)cma->bitmap, u32s);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
