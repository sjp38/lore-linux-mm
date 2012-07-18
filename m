Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 49E976B005A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 13:04:33 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 18 Jul 2012 13:04:31 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C91056E854B
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 12:58:35 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6IGu3tg350558
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 12:56:03 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6IGu2Fn026575
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 13:56:02 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 3/3] zsmalloc: add page table mapping method
Date: Wed, 18 Jul 2012 11:55:56 -0500
Message-Id: <1342630556-28686-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This patchset provides page mapping via the page table.
On some archs, most notably ARM, this method has been
demonstrated to be faster than copying.

The logic controlling the method selection (copy vs page table)
is controlled by the definition of USE_PGTABLE_MAPPING which
is/can be defined for any arch that performs better with page
table mapping.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |  182 ++++++++++++++++++++++--------
 drivers/staging/zsmalloc/zsmalloc_int.h  |    6 -
 2 files changed, 134 insertions(+), 54 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index b86133f..defe350 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -89,6 +89,30 @@
 #define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
 #define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
 
+/*
+ * By default, zsmalloc uses a copy-based object mapping method to access
+ * allocations that span two pages. However, if a particular architecture
+ * 1) Implements local_flush_tlb_kernel_range() and 2) Performs VM mapping
+ * faster than copying, then it should be added here so that
+ * USE_PGTABLE_MAPPING is defined. This causes zsmalloc to use page table
+ * mapping rather than copying
+ * for object mapping.
+*/
+#if defined(CONFIG_ARM)
+#define USE_PGTABLE_MAPPING
+#endif
+
+struct mapping_area {
+#ifdef USE_PGTABLE_MAPPING
+	struct vm_struct *vm; /* vm area for mapping object that span pages */
+#else
+	char *vm_buf; /* copy buffer for objects that span pages */
+#endif
+	char *vm_addr; /* address of kmap_atomic()'ed pages */
+	enum zs_mapmode vm_mm; /* mapping mode */
+};
+
+
 /* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
 static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
 
@@ -471,16 +495,83 @@ static struct page *find_get_zspage(struct size_class *class)
 	return page;
 }
 
-static void zs_copy_map_object(char *buf, struct page *page,
-				int off, int size)
+#ifdef USE_PGTABLE_MAPPING
+static inline int __zs_cpu_up(struct mapping_area *area)
+{
+	/*
+	 * Make sure we don't leak memory if a cpu UP notification
+	 * and zs_init() race and both call zs_cpu_up() on the same cpu
+	 */
+	if (area->vm)
+		return 0;
+	area->vm = alloc_vm_area(PAGE_SIZE * 2, NULL);
+	if (!area->vm)
+		return -ENOMEM;
+	return 0;
+}
+
+static inline void __zs_cpu_down(struct mapping_area *area)
+{
+	if (area->vm)
+		free_vm_area(area->vm);
+	area->vm = NULL;
+}
+
+static inline void *__zs_map_object(struct mapping_area *area,
+				struct page *pages[2], int off, int size)
+{
+	BUG_ON(map_vm_area(area->vm, PAGE_KERNEL, &pages));
+	area->vm_addr = area->vm->addr;
+	return area->vm_addr + off;
+}
+
+static inline void __zs_unmap_object(struct mapping_area *area,
+				struct page *pages[2], int off, int size)
+{
+	unsigned long addr = (unsigned long)area->vm_addr;
+	unsigned long end = addr + (PAGE_SIZE * 2);
+
+	flush_cache_vunmap(addr, end);
+	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
+	local_flush_tlb_kernel_range(addr, end);
+}
+
+#else /* USE_PGTABLE_MAPPING */
+
+static inline int __zs_cpu_up(struct mapping_area *area)
+{
+	/*
+	 * Make sure we don't leak memory if a cpu UP notification
+	 * and zs_init() race and both call zs_cpu_up() on the same cpu
+	 */
+	if (area->vm_buf)
+		return 0;
+	area->vm_buf = (char *)__get_free_page(GFP_KERNEL);
+	if (!area->vm_buf)
+		return -ENOMEM;
+	return 0;
+}
+
+static inline void __zs_cpu_down(struct mapping_area *area)
+{
+	if (area->vm_buf)
+		free_page((unsigned long)area->vm_buf);
+	area->vm_buf = NULL;
+}
+
+static void *__zs_map_object(struct mapping_area *area,
+			struct page *pages[2], int off, int size)
 {
-	struct page *pages[2];
 	int sizes[2];
 	void *addr;
+	char *buf = area->vm_buf;
 
-	pages[0] = page;
-	pages[1] = get_next_page(page);
-	BUG_ON(!pages[1]);
+	/* disable page faults to match kmap_atomic() return conditions */
+	pagefault_disable();
+
+	/* no read fastpath */
+	if (area->vm_mm == ZS_MM_WO)
+		goto out;
 
 	sizes[0] = PAGE_SIZE - off;
 	sizes[1] = size - sizes[0];
@@ -492,18 +583,20 @@ static void zs_copy_map_object(char *buf, struct page *page,
 	addr = kmap_atomic(pages[1]);
 	memcpy(buf + sizes[0], addr, sizes[1]);
 	kunmap_atomic(addr);
+out:
+	return area->vm_buf;
 }
 
-static void zs_copy_unmap_object(char *buf, struct page *page,
-				int off, int size)
+static void __zs_unmap_object(struct mapping_area *area,
+			struct page *pages[2], int off, int size)
 {
-	struct page *pages[2];
 	int sizes[2];
 	void *addr;
+	char *buf = area->vm_buf;
 
-	pages[0] = page;
-	pages[1] = get_next_page(page);
-	BUG_ON(!pages[1]);
+	/* no write fastpath */
+	if (area->vm_mm == ZS_MM_RO)
+		goto out;
 
 	sizes[0] = PAGE_SIZE - off;
 	sizes[1] = size - sizes[0];
@@ -515,34 +608,31 @@ static void zs_copy_unmap_object(char *buf, struct page *page,
 	addr = kmap_atomic(pages[1]);
 	memcpy(addr, buf + sizes[0], sizes[1]);
 	kunmap_atomic(addr);
+
+out:
+	/* enable page faults to match kunmap_atomic() return conditions */
+	pagefault_enable();
 }
 
+#endif /* USE_PGTABLE_MAPPING */
+
 static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
 				void *pcpu)
 {
-	int cpu = (long)pcpu;
+	int ret, cpu = (long)pcpu;
 	struct mapping_area *area;
 
 	switch (action) {
 	case CPU_UP_PREPARE:
 		area = &per_cpu(zs_map_area, cpu);
-		/*
-		 * Make sure we don't leak memory if a cpu UP notification
-		 * and zs_init() race and both call zs_cpu_up() on the same cpu
-		 */
-		if (area->vm_buf)
-			return 0;
-		area->vm_buf = (char *)__get_free_page(GFP_KERNEL);
-		if (!area->vm_buf)
-			return -ENOMEM;
-		return 0;
+		ret = __zs_cpu_up(area);
+		if (ret)
+			return notifier_from_errno(ret);
 		break;
 	case CPU_DEAD:
 	case CPU_UP_CANCELED:
 		area = &per_cpu(zs_map_area, cpu);
-		if (area->vm_buf)
-			free_page((unsigned long)area->vm_buf);
-		area->vm_buf = NULL;
+		__zs_cpu_down(area);
 		break;
 	}
 
@@ -759,6 +849,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	enum fullness_group fg;
 	struct size_class *class;
 	struct mapping_area *area;
+	struct page *pages[2];
 
 	BUG_ON(!handle);
 
@@ -775,19 +866,19 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
 	area = &get_cpu_var(zs_map_area);
+	area->vm_mm = mm;
 	if (off + class->size <= PAGE_SIZE) {
 		/* this object is contained entirely within a page */
 		area->vm_addr = kmap_atomic(page);
 		return area->vm_addr + off;
 	}
 
-	/* disable page faults to match kmap_atomic() return conditions */
-	pagefault_disable();
+	/* this object spans two pages */
+	pages[0] = page;
+	pages[1] = get_next_page(page);
+	BUG_ON(!pages[1]);
 
-	if (mm != ZS_MM_WO)
-		zs_copy_map_object(area->vm_buf, page, off, class->size);
-	area->vm_addr = NULL;
-	return area->vm_buf;
+	return __zs_map_object(area, pages, off, class->size);
 }
 EXPORT_SYMBOL_GPL(zs_map_object);
 
@@ -801,17 +892,6 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	struct size_class *class;
 	struct mapping_area *area;
 
-	area = &__get_cpu_var(zs_map_area);
-	/* single-page object fastpath */
-	if (area->vm_addr) {
-		kunmap_atomic(area->vm_addr);
-		goto out;
-	}
-
-	/* no write fastpath */
-	if (area->vm_mm == ZS_MM_RO)
-		goto pfenable;
-
 	BUG_ON(!handle);
 
 	obj_handle_to_location(handle, &page, &obj_idx);
@@ -819,12 +899,18 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	class = &pool->size_class[class_idx];
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
-	zs_copy_unmap_object(area->vm_buf, page, off, class->size);
+	area = &__get_cpu_var(zs_map_area);
+	if (off + class->size <= PAGE_SIZE)
+		kunmap_atomic(area->vm_addr);
+	else {
+		struct page *pages[2];
+
+		pages[0] = page;
+		pages[1] = get_next_page(page);
+		BUG_ON(!pages[1]);
 
-pfenable:
-	/* enable page faults to match kunmap_atomic() return conditions */
-	pagefault_enable();
-out:
+		__zs_unmap_object(area, pages, off, class->size);
+	}
 	put_cpu_var(zs_map_area);
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
diff --git a/drivers/staging/zsmalloc/zsmalloc_int.h b/drivers/staging/zsmalloc/zsmalloc_int.h
index 52805176..8c0b344 100644
--- a/drivers/staging/zsmalloc/zsmalloc_int.h
+++ b/drivers/staging/zsmalloc/zsmalloc_int.h
@@ -109,12 +109,6 @@ enum fullness_group {
  */
 static const int fullness_threshold_frac = 4;
 
-struct mapping_area {
-	char *vm_buf; /* copy buffer for objects that span pages */
-	char *vm_addr; /* address of kmap_atomic()'ed pages */
-	enum zs_mapmode vm_mm; /* mapping mode */
-};
-
 struct size_class {
 	/*
 	 * Size of objects stored in this class. Must be multiple
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
