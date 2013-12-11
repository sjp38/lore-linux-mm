Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id E144A6B0037
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 21:04:38 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so8972857pbb.28
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 18:04:38 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id v7si12020997pbi.8.2013.12.10.18.04.36
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 18:04:37 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v9 1/4] zsmalloc: add Kconfig for enabling page table method
Date: Wed, 11 Dec 2013 11:04:36 +0900
Message-Id: <1386727479-18502-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1386727479-18502-1-git-send-email-minchan@kernel.org>
References: <1386727479-18502-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

Zsmalloc has two methods 1) copy-based and 2) pte based to
access objects that span two pages.
You can see history why we supported two approach from [1].

But it was bad choice that adding hard coding to select arch
which want to use pte based method because there are lots of
SoC in an architecure and they can have different cache size,
CPU speed and so on so it would be better to expose it to user
as selectable Kconfig option like Andrew Morton suggested.

[1] https://lkml.org/lkml/2012/7/11/58

Acked-by: Nitin Gupta <ngupta@vflare.org>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/Kconfig         |   13 +++++++++++++
 drivers/staging/zsmalloc/zsmalloc-main.c |   19 ++++---------------
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
index 0ae13cd0908e..9d1f2a24ad62 100644
--- a/drivers/staging/zsmalloc/Kconfig
+++ b/drivers/staging/zsmalloc/Kconfig
@@ -9,3 +9,16 @@ config ZSMALLOC
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
index 3b950e5a918f..5bd53a835f6d 100644
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
@@ -631,7 +620,7 @@ static struct page *find_get_zspage(struct size_class *class)
 	return page;
 }
 
-#ifdef USE_PGTABLE_MAPPING
+#ifdef CONFIG_PGTABLE_MAPPING
 static inline int __zs_cpu_up(struct mapping_area *area)
 {
 	/*
@@ -669,7 +658,7 @@ static inline void __zs_unmap_object(struct mapping_area *area,
 	unmap_kernel_range(addr, PAGE_SIZE * 2);
 }
 
-#else /* USE_PGTABLE_MAPPING */
+#else /* CONFIG_PGTABLE_MAPPING */
 
 static inline int __zs_cpu_up(struct mapping_area *area)
 {
@@ -747,7 +736,7 @@ out:
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
