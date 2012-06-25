Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 01BD46B036E
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:42:16 -0400 (EDT)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 25 Jun 2012 12:42:14 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id A448A38C820A
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:14:49 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5PGEnpW176630
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:14:49 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5PGEmLT002623
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:14:48 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 2/3] zsmalloc: add generic path and remove x86 dependency
Date: Mon, 25 Jun 2012 11:14:37 -0500
Message-Id: <1340640878-27536-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This patch adds generic pages mapping methods that
work on all archs in the absence of support for
local_tlb_flush_kernel_range() advertised by the
arch through __HAVE_LOCAL_TLB_FLUSH_KERNEL_RANGE

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zsmalloc/Kconfig         |    4 -
 drivers/staging/zsmalloc/zsmalloc-main.c |  136 ++++++++++++++++++++++++------
 drivers/staging/zsmalloc/zsmalloc_int.h  |    5 +-
 3 files changed, 115 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
index a5ab720..9084565 100644
--- a/drivers/staging/zsmalloc/Kconfig
+++ b/drivers/staging/zsmalloc/Kconfig
@@ -1,9 +1,5 @@
 config ZSMALLOC
 	tristate "Memory allocator for compressed pages"
-	# X86 dependency is because of the use of __flush_tlb_one and set_pte
-	# in zsmalloc-main.c.
-	# TODO: convert these to portable functions
-	depends on X86
 	default n
 	help
 	  zsmalloc is a slab-based memory allocator designed to store
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 10b0d60..14f04d8 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -470,28 +470,116 @@ static struct page *find_get_zspage(struct size_class *class)
 	return page;
 }
 
+#ifdef __HAVE_LOCAL_FLUSH_TLB_KERNEL_RANGE
+static inline int zs_arch_cpu_up(struct mapping_area *area)
+{
+	if (area->vm)
+		return 0;
+	area->vm = alloc_vm_area(PAGE_SIZE * 2, NULL);
+	if (!area->vm)
+		return -ENOMEM;
+	return 0;
+}
+
+static inline void zs_arch_cpu_down(struct mapping_area *area)
+{
+	if (area->vm)
+		free_vm_area(area->vm);
+	area->vm = NULL;
+}
+
+static inline void zs_arch_map_object(struct mapping_area *area,
+				struct page *pages[2], int off, int size)
+{
+	BUG_ON(map_vm_area(area->vm, PAGE_KERNEL, &pages));
+	area->vm_addr = area->vm->addr;
+}
+
+static inline void zs_arch_unmap_object(struct mapping_area *area,
+				struct page *pages[2], int off, int size)
+{
+	unsigned long addr = (unsigned long)area->vm_addr;
+	unsigned long end = addr + (PAGE_SIZE * 2);
+
+	flush_cache_vunmap(addr, end);
+	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
+	local_flush_tlb_kernel_range(addr, end);
+}
+#else
+static inline int zs_arch_cpu_up(struct mapping_area *area)
+{
+	if (area->vm_buf)
+		return 0;
+	area->vm_buf = (char *)__get_free_pages(GFP_KERNEL, 1);
+	if (!area->vm_buf)
+		return -ENOMEM;
+	return 0;
+}
+
+static inline void zs_arch_cpu_down(struct mapping_area *area)
+{
+	if (area->vm_buf)
+		free_pages((unsigned long)area->vm_buf, 1);
+	area->vm_buf = NULL;
+}
+
+static void zs_arch_map_object(struct mapping_area *area,
+				struct page *pages[2], int off, int size)
+{
+	int sizes[2];
+	char *buf = area->vm_buf + off;
+	void *addr;
+
+	sizes[0] = PAGE_SIZE - off;
+	sizes[1] = size - sizes[0];
+
+	/* copy object to temp buffer */
+	addr = kmap_atomic(pages[0]);
+	memcpy(buf, addr + off, sizes[0]);
+	kunmap_atomic(addr);
+	addr = kmap_atomic(pages[1]);
+	memcpy(buf + sizes[0], addr, sizes[1]);
+	kunmap_atomic(addr);
+	area->vm_addr = area->vm_buf;
+}
+
+static void zs_arch_unmap_object(struct mapping_area *area,
+				struct page *pages[2], int off, int size)
+{
+	int sizes[2];
+	char *buf = area->vm_buf + off;
+	void *addr;
+
+	sizes[0] = PAGE_SIZE - off;
+	sizes[1] = size - sizes[0];
+
+	/* copy temp buffer to obj*/
+	addr = kmap_atomic(pages[0]);
+	memcpy(addr + off, buf, sizes[0]);
+	kunmap_atomic(addr);
+	addr = kmap_atomic(pages[1]);
+	memcpy(addr, buf + sizes[0], sizes[1]);
+	kunmap_atomic(addr);
+}
+#endif
 
 static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
 				void *pcpu)
 {
-	int cpu = (long)pcpu;
+	int ret, cpu = (long)pcpu;
 	struct mapping_area *area;
 
 	switch (action) {
 	case CPU_UP_PREPARE:
 		area = &per_cpu(zs_map_area, cpu);
-		if (area->vm)
-			break;
-		area->vm = alloc_vm_area(2 * PAGE_SIZE, area->vm_ptes);
-		if (!area->vm)
-			return notifier_from_errno(-ENOMEM);
+		ret = zs_arch_cpu_up(area);
+		if (ret)
+			return notifier_from_errno(ret);
 		break;
 	case CPU_DEAD:
 	case CPU_UP_CANCELED:
 		area = &per_cpu(zs_map_area, cpu);
-		if (area->vm)
-			free_vm_area(area->vm);
-		area->vm = NULL;
+		zs_arch_cpu_down(area);
 		break;
 	}
 
@@ -716,19 +804,14 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle)
 		area->vm_addr = kmap_atomic(page);
 	} else {
 		/* this object spans two pages */
-		struct page *nextp;
-
-		nextp = get_next_page(page);
-		BUG_ON(!nextp);
+		struct page *pages[2];
 
+		pages[0] = page;
+		pages[1] = get_next_page(page);
+		BUG_ON(!pages[1]);
 
-		set_pte(area->vm_ptes[0], mk_pte(page, PAGE_KERNEL));
-		set_pte(area->vm_ptes[1], mk_pte(nextp, PAGE_KERNEL));
-
-		/* We pre-allocated VM area so mapping can never fail */
-		area->vm_addr = area->vm->addr;
+		zs_arch_map_object(area, pages, off, class->size);
 	}
-
 	return area->vm_addr + off;
 }
 EXPORT_SYMBOL_GPL(zs_map_object);
@@ -751,13 +834,16 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
 	area = &__get_cpu_var(zs_map_area);
-	if (off + class->size <= PAGE_SIZE) {
+	if (off + class->size <= PAGE_SIZE)
 		kunmap_atomic(area->vm_addr);
-	} else {
-		set_pte(area->vm_ptes[0], __pte(0));
-		set_pte(area->vm_ptes[1], __pte(0));
-		__flush_tlb_one((unsigned long)area->vm_addr);
-		__flush_tlb_one((unsigned long)area->vm_addr + PAGE_SIZE);
+	else {
+		struct page *pages[2];
+
+		pages[0] = page;
+		pages[1] = get_next_page(page);
+		BUG_ON(!pages[1]);
+
+		zs_arch_unmap_object(area, pages, off, class->size);
 	}
 	put_cpu_var(zs_map_area);
 }
diff --git a/drivers/staging/zsmalloc/zsmalloc_int.h b/drivers/staging/zsmalloc/zsmalloc_int.h
index 6fd32a9..8a6887e 100644
--- a/drivers/staging/zsmalloc/zsmalloc_int.h
+++ b/drivers/staging/zsmalloc/zsmalloc_int.h
@@ -110,8 +110,11 @@ enum fullness_group {
 static const int fullness_threshold_frac = 4;
 
 struct mapping_area {
+#ifdef __HAVE_LOCAL_FLUSH_TLB_KERNEL_RANGE
 	struct vm_struct *vm;
-	pte_t *vm_ptes[2];
+#else
+	char *vm_buf;
+#endif
 	char *vm_addr;
 };
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
