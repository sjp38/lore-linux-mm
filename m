Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 68C306B0070
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 11:52:22 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id v10so29388281pde.3
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 08:52:22 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id fw3si8778206pbb.182.2015.01.21.08.52.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 21 Jan 2015 08:52:16 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIJ00IL6DPN51A0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jan 2015 16:56:11 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v9 03/17] mm: page_alloc: add kasan hooks on alloc and free
 paths
Date: Wed, 21 Jan 2015 19:51:31 +0300
Message-id: <1421859105-25253-4-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org

Add kernel address sanitizer hooks to mark allocated page's addresses
as accessible in corresponding shadow region.
Mark freed pages as inaccessible.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/kasan.h |  7 +++++++
 mm/compaction.c       |  2 ++
 mm/kasan/kasan.c      | 14 ++++++++++++++
 mm/kasan/report.c     | 11 +++++++++++
 mm/page_alloc.c       |  3 +++
 5 files changed, 37 insertions(+)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 063a3f3..a278ccc 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -11,6 +11,7 @@ struct page;
 #define KASAN_SHADOW_SCALE_SHIFT 3
 #define KASAN_SHADOW_OFFSET _AC(CONFIG_KASAN_SHADOW_OFFSET, UL)
 
+#define KASAN_FREE_PAGE         0xFF  /* page was freed */
 #define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
 
 #include <asm/kasan.h>
@@ -33,6 +34,9 @@ static inline void kasan_disable_local(void)
 
 void kasan_unpoison_shadow(const void *address, size_t size);
 
+void kasan_alloc_pages(struct page *page, unsigned int order);
+void kasan_free_pages(struct page *page, unsigned int order);
+
 #else /* CONFIG_KASAN */
 
 static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
@@ -40,6 +44,9 @@ static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
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
index 740d5b2..efe8105 100644
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
 #define DECLARE_ASAN_CHECK(size)				\
 	void __asan_load##size(unsigned long addr)		\
 	{							\
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 62b942a..7983ebb 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -54,6 +54,9 @@ static void print_error_description(struct access_info *info)
 	shadow_val = *(u8 *)kasan_mem_to_shadow(info->first_bad_addr);
 
 	switch (shadow_val) {
+	case KASAN_FREE_PAGE:
+		bug_type = "use after free";
+		break;
 	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
 		bug_type = "out of bounds access";
 		break;
@@ -72,6 +75,14 @@ static void print_error_description(struct access_info *info)
 
 static void print_address_description(struct access_info *info)
 {
+	unsigned long addr = info->access_addr;
+
+	if ((addr >= PAGE_OFFSET) &&
+		(addr < (unsigned long)high_memory)) {
+		struct page *page = virt_to_head_page((void *)addr);
+		dump_page(page, "kasan: bad access detected");
+	}
+
 	dump_stack();
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7633c50..3a75171 100644
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
@@ -807,6 +808,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 
 	trace_mm_page_free(page, order);
 	kmemcheck_free_shadow(page, order);
+	kasan_free_pages(page, order);
 
 	if (PageAnon(page))
 		page->mapping = NULL;
@@ -985,6 +987,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags)
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
+	kasan_alloc_pages(page, order);
 
 	if (gfp_flags & __GFP_ZERO)
 		prep_zero_page(page, order, gfp_flags);
-- 
2.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
