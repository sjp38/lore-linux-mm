Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id CA6746B005C
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:36:42 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so8883962pde.17
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:36:42 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id ej14si7240532pdb.261.2014.07.09.04.36.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:36:39 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8G00F6F08UAQ60@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:36:30 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH RESEND -next 08/21] mm: page_alloc: add kasan hooks on
 alloc and free pathes
Date: Wed, 09 Jul 2014 15:30:02 +0400
Message-id: <1404905415-9046-9-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

Add kernel address sanitizer hooks to mark allocated page's addresses
as accessible in corresponding shadow region.
Mark freed pages as unaccessible.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/kasan.h |  6 ++++++
 mm/Makefile           |  2 ++
 mm/kasan/kasan.c      | 18 ++++++++++++++++++
 mm/kasan/kasan.h      |  1 +
 mm/kasan/report.c     |  7 +++++++
 mm/page_alloc.c       |  4 ++++
 6 files changed, 38 insertions(+)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 7efc3eb..4adc0a1 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -17,6 +17,9 @@ void kasan_disable_local(void);
 void kasan_alloc_shadow(void);
 void kasan_init_shadow(void);
 
+void kasan_alloc_pages(struct page *page, unsigned int order);
+void kasan_free_pages(struct page *page, unsigned int order);
+
 #else /* CONFIG_KASAN */
 
 static inline void unpoison_shadow(const void *address, size_t size) {}
@@ -28,6 +31,9 @@ static inline void kasan_disable_local(void) {}
 static inline void kasan_init_shadow(void) {}
 static inline void kasan_alloc_shadow(void) {}
 
+static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
+static inline void kasan_free_pages(struct page *page, unsigned int order) {}
+
 #endif /* CONFIG_KASAN */
 
 #endif /* LINUX_KASAN_H */
diff --git a/mm/Makefile b/mm/Makefile
index dbe9a22..6a9c3f8 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -2,6 +2,8 @@
 # Makefile for the linux memory manager.
 #
 
+KASAN_SANITIZE_page_alloc.o := n
+
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= gup.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index e2cd345..109478e 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -177,6 +177,24 @@ void __init kasan_init_shadow(void)
 	}
 }
 
+void kasan_alloc_pages(struct page *page, unsigned int order)
+{
+	if (unlikely(!kasan_initialized))
+		return;
+
+	if (likely(page && !PageHighMem(page)))
+		unpoison_shadow(page_address(page), PAGE_SIZE << order);
+}
+
+void kasan_free_pages(struct page *page, unsigned int order)
+{
+	if (unlikely(!kasan_initialized))
+		return;
+
+	if (likely(!PageHighMem(page)))
+		poison_shadow(page_address(page), PAGE_SIZE << order, KASAN_FREE_PAGE);
+}
+
 void *kasan_memcpy(void *dst, const void *src, size_t len)
 {
 	if (unlikely(len == 0))
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 711ae4f..be9597e 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -5,6 +5,7 @@
 #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
 #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
 
+#define KASAN_FREE_PAGE         0xFF  /* page was freed */
 #define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
 
 struct access_info {
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 2430e05..6ef9e57 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -46,6 +46,9 @@ static void print_error_description(struct access_info *info)
 	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
 		bug_type = "buffer overflow";
 		break;
+	case KASAN_FREE_PAGE:
+		bug_type = "use after free";
+		break;
 	case KASAN_SHADOW_GAP:
 		bug_type = "wild memory access";
 		break;
@@ -67,6 +70,10 @@ static void print_address_description(struct access_info *info)
 	page = virt_to_page(info->access_addr);
 
 	switch (shadow_val) {
+	case KASAN_FREE_PAGE:
+		dump_page(page, "kasan error");
+		dump_stack();
+		break;
 	case KASAN_SHADOW_GAP:
 		pr_err("No metainfo is available for this access.\n");
 		dump_stack();
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8c9eeec..67833d1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -61,6 +61,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
+#include <linux/kasan.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -747,6 +748,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 
 	trace_mm_page_free(page, order);
 	kmemcheck_free_shadow(page, order);
+	kasan_free_pages(page, order);
 
 	if (PageAnon(page))
 		page->mapping = NULL;
@@ -2807,6 +2809,7 @@ out:
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 
+	kasan_alloc_pages(page, order);
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
@@ -6415,6 +6418,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	if (end != outer_end)
 		free_contig_range(end, outer_end - end);
 
+	kasan_alloc_pages(pfn_to_page(start), end - start);
 done:
 	undo_isolate_page_range(pfn_max_align_down(start),
 				pfn_max_align_up(end), migratetype);
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
