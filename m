Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 44BAA6B0070
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 11:01:32 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so5139409pac.8
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 08:01:32 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id s4si12168409pdj.117.2014.11.27.08.01.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 27 Nov 2014 08:01:30 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFP002ZXGN8ED60@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 27 Nov 2014 16:04:20 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v8 04/12] mm: page_alloc: add kasan hooks on alloc and free
 paths
Date: Thu, 27 Nov 2014 19:00:48 +0300
Message-id: <1417104057-20335-5-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Add kernel address sanitizer hooks to mark allocated page's addresses
as accessible in corresponding shadow region.
Mark freed pages as inaccessible.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/kasan.h |  6 ++++++
 mm/compaction.c       |  2 ++
 mm/kasan/kasan.c      | 14 ++++++++++++++
 mm/kasan/kasan.h      |  1 +
 mm/kasan/report.c     |  7 +++++++
 mm/page_alloc.c       |  3 +++
 6 files changed, 33 insertions(+)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 01c99fe..9714fba 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -30,6 +30,9 @@ static inline void kasan_disable_local(void)
 
 void kasan_unpoison_shadow(const void *address, size_t size);
 
+void kasan_alloc_pages(struct page *page, unsigned int order);
+void kasan_free_pages(struct page *page, unsigned int order);
+
 #else /* CONFIG_KASAN */
 
 static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
@@ -37,6 +40,9 @@ static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
 static inline void kasan_enable_local(void) {}
 static inline void kasan_disable_local(void) {}
 
+static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
+static inline void kasan_free_pages(struct page *page, unsigned int order) {}
+
 #endif /* CONFIG_KASAN */
 
 #endif /* LINUX_KASAN_H */
diff --git a/mm/compaction.c b/mm/compaction.c
index 546e571..12f2c7d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -16,6 +16,7 @@
 #include <linux/sysfs.h>
 #include <linux/balloon_compaction.h>
 #include <linux/page-isolation.h>
+#include <linux/kasan.h>
 #include "internal.h"
 
 #ifdef CONFIG_COMPACTION
@@ -61,6 +62,7 @@ static void map_pages(struct list_head *list)
 	list_for_each_entry(page, list, lru) {
 		arch_alloc_page(page, 0);
 		kernel_map_pages(page, 1, 1);
+		kasan_alloc_pages(page, 0);
 	}
 }
 
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index f77be01..b336073 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -247,6 +247,20 @@ static __always_inline void check_memory_region(unsigned long addr,
 	kasan_report(addr, size, write);
 }
 
+void kasan_alloc_pages(struct page *page, unsigned int order)
+{
+	if (likely(!PageHighMem(page)))
+		kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
+}
+
+void kasan_free_pages(struct page *page, unsigned int order)
+{
+	if (likely(!PageHighMem(page)))
+		kasan_poison_shadow(page_address(page),
+				PAGE_SIZE << order,
+				KASAN_FREE_PAGE);
+}
+
 void __asan_load1(unsigned long addr)
 {
 	check_memory_region(addr, 1, false);
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 6da1d78..2a6a961 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -6,6 +6,7 @@
 #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
 #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
 
+#define KASAN_FREE_PAGE         0xFF  /* page was freed */
 #define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
 
 struct access_info {
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 56a2089..8ac3b6b 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -57,6 +57,9 @@ static void print_error_description(struct access_info *info)
 	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
 		bug_type = "out of bounds access";
 		break;
+	case KASAN_FREE_PAGE:
+		bug_type = "use after free";
+		break;
 	case KASAN_SHADOW_GAP:
 		bug_type = "wild memory access";
 		break;
@@ -78,6 +81,10 @@ static void print_address_description(struct access_info *info)
 	page = virt_to_head_page((void *)info->access_addr);
 
 	switch (shadow_val) {
+	case KASAN_FREE_PAGE:
+		dump_page(page, "kasan error");
+		dump_stack();
+		break;
 	case KASAN_SHADOW_GAP:
 		pr_err("No metainfo is available for this access.\n");
 		dump_stack();
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0b2f5a6..4ea0e33 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -25,6 +25,7 @@
 #include <linux/compiler.h>
 #include <linux/kernel.h>
 #include <linux/kmemcheck.h>
+#include <linux/kasan.h>
 #include <linux/module.h>
 #include <linux/suspend.h>
 #include <linux/pagevec.h>
@@ -804,6 +805,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 
 	trace_mm_page_free(page, order);
 	kmemcheck_free_shadow(page, order);
+	kasan_free_pages(page, order);
 
 	if (PageAnon(page))
 		page->mapping = NULL;
@@ -982,6 +984,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags)
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
+	kasan_alloc_pages(page, order);
 
 	if (gfp_flags & __GFP_ZERO)
 		prep_zero_page(page, order, gfp_flags);
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
