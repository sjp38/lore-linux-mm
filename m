Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 4F9F96B0033
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 01:55:31 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6 1/5] zsmalloc: add Kconfig for enabling page table method
Date: Wed, 14 Aug 2013 14:55:32 +0900
Message-Id: <1376459736-7384-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1376459736-7384-1-git-send-email-minchan@kernel.org>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

Zsmalloc has two methods 1) copy-based and 2) pte based to
access objects that span two pages.
You can see history why we supported two approach from [1].

But it was bad choice that adding hard coding to select arch
which want to use pte based method because there are lots of
SoC in an architecure and they can have different cache size,
CPU speed and so on so it would be better to expose it to user
as selectable Kconfig option like Andrew Morton suggested.

[1] https://lkml.org/lkml/2012/7/11/58

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/Kconfig         |   13 +++++++++++++
 drivers/staging/zsmalloc/zsmalloc-main.c |   19 ++++---------------
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
index 7fab032..e75611a 100644
--- a/drivers/staging/zsmalloc/Kconfig
+++ b/drivers/staging/zsmalloc/Kconfig
@@ -8,3 +8,16 @@ config ZSMALLOC
 	  non-standard allocator interface where a handle, not a pointer, is
 	  returned by an alloc().  This handle must be mapped in order to
 	  access the allocated space.
+
+config PGTABLE_MAPPING
+	bool "Use page table mapping to access object in zsmalloc"
+	depends on ZSMALLOC
+	help
+	  By default, zsmalloc uses a copy-based object mapping method to
+	  access allocations that span two pages. However, if a particular
+	  architecture (ex, ARM) performs VM mapping faster than copying,
+	  then you should select this. This causes zsmalloc to use page table
+	  mapping rather than copying for object mapping.
+
+	  You can check speed with zsmalloc benchmark[1].
+	  [1] https://github.com/spartacus06/zsmalloc
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 1a67537..f57258fa 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -218,19 +218,8 @@ struct zs_pool {
 #define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
 #define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
 
-/*
- * By default, zsmalloc uses a copy-based object mapping method to access
- * allocations that span two pages. However, if a particular architecture
- * performs VM mapping faster than copying, then it should be added here
- * so that USE_PGTABLE_MAPPING is defined. This causes zsmalloc to use
- * page table mapping rather than copying for object mapping.
- */
-#if defined(CONFIG_ARM) && !defined(MODULE)
-#define USE_PGTABLE_MAPPING
-#endif
-
 struct mapping_area {
-#ifdef USE_PGTABLE_MAPPING
+#ifdef CONFIG_PGTABLE_MAPPING
 	struct vm_struct *vm; /* vm area for mapping object that span pages */
 #else
 	char *vm_buf; /* copy buffer for objects that span pages */
@@ -622,7 +611,7 @@ static struct page *find_get_zspage(struct size_class *class)
 	return page;
 }
 
-#ifdef USE_PGTABLE_MAPPING
+#ifdef CONFIG_PGTABLE_MAPPING
 static inline int __zs_cpu_up(struct mapping_area *area)
 {
 	/*
@@ -660,7 +649,7 @@ static inline void __zs_unmap_object(struct mapping_area *area,
 	unmap_kernel_range(addr, PAGE_SIZE * 2);
 }
 
-#else /* USE_PGTABLE_MAPPING */
+#else /* CONFIG_PGTABLE_MAPPING */
 
 static inline int __zs_cpu_up(struct mapping_area *area)
 {
@@ -738,7 +727,7 @@ out:
 	pagefault_enable();
 }
 
-#endif /* USE_PGTABLE_MAPPING */
+#endif /* CONFIG_PGTABLE_MAPPING */
 
 static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
 				void *pcpu)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
