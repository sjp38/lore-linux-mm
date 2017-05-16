Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90B7B6B02F4
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:17:55 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l73so58189099pfj.8
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:55 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id t8si7502140pfa.36.2017.05.15.18.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:17:54 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id u26so17848634pfd.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:54 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v1 05/11] mm/kasan: introduce per-page shadow memory infrastructure
Date: Tue, 16 May 2017 10:16:43 +0900
Message-Id: <1494897409-14408-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

1. What is per-page shadow memory

This patch introduces infrastructure to support per-page shadow memory.
Per-page shadow memory is the same with original shadow memory except
the granualarity. It's one byte shows the shadow value for the page.
The purpose of introducing this new shadow memory is to save memory
consumption.

2. Problem of current approach

Until now, KASAN needs shadow memory for all the range of the memory
so the amount of statically allocated memory is so large. It causes
the problem that KASAN cannot run on the system with hard memory
constraint. Even if KASAN can run, large memory consumption due to
KASAN changes behaviour of the workload so we cannot validate
the moment that we want to check.

3. How does this patch fix the problem

This patch tries to fix the problem by reducing memory consumption for
the shadow memory. There are two observations.

1) Type of memory usage can be distinguished well.
2) Shadow memory is manipulated/checked in byte unit only for slab,
kernel stack and global variable. Shadow memory for other usecases
just show KASAN_FREE_PAGE or 0 (means valid) in page unit.

With these two observations, I think an optimized way to support
KASAN feature.

1) Introduces per-page shadow that cover all the memory
2) Checks validity of the access through per-page shadow except
that checking object is a slab, kernel stack, global variable
3) For those byte accessible types of object, allocate/map original
shadow by on-demand and checks validity of the access through
original shadow

Instead original shadow statically consumes 1/8 bytes of the amount of
total memory, per-page shadow statically consumes 1/PAGE_SIZE bytes of it.
Extra memory is required for a slab, kernel stack and global variable by
on-demand in runtime, however, it would not be larger than before.

Following is the result of the memory consumption on my QEMU system.
'runtime' shows the maximum memory usage for on-demand shadow allocation
during the kernel build workload. Note that this patch just introduces
an infrastructure. These benefit will be observed at the last patch
in this series.

Base vs Patched

MemTotal: 858 MB vs 987 MB
runtime: 0 MB vs 30MB
Net Available: 858 MB vs 957 MB

For 4096 MB QEMU system

MemTotal: 3477 MB vs 4000 MB
runtime: 0 MB vs 50MB
Net Available: 3477 MB vs 3950 MB

Memory consumption is reduced by 99 MB and 473 MB, respectively.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/kasan.h | 41 +++++++++++++++++++++
 mm/kasan/kasan.c      | 98 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h      | 12 +++++--
 mm/kasan/kasan_init.c | 31 ++++++++++++++++
 mm/kasan/report.c     | 28 +++++++++++++++
 5 files changed, 207 insertions(+), 3 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 7e501b3..4390788 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -15,6 +15,18 @@ struct task_struct;
 #include <asm/kasan.h>
 #include <asm/pgtable.h>
 
+#ifndef KASAN_PSHADOW_SIZE
+#define KASAN_PSHADOW_SIZE 0
+#endif
+#ifndef KASAN_PSHADOW_START
+#define KASAN_PSHADOW_START 0
+#endif
+#ifndef KASAN_PSHADOW_END
+#define KASAN_PSHADOW_END 0
+#endif
+
+extern unsigned long kasan_pshadow_offset;
+
 extern unsigned char kasan_zero_page[PAGE_SIZE];
 extern pte_t kasan_zero_pte[PTRS_PER_PTE];
 extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
@@ -30,6 +42,13 @@ extern p4d_t kasan_black_p4d[PTRS_PER_P4D];
 void kasan_populate_shadow(const void *shadow_start,
 				const void *shadow_end,
 				bool zero, bool private);
+void kasan_early_init_pshadow(void);
+
+static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
+{
+	return (void *)(((unsigned long)shadow_addr - KASAN_SHADOW_OFFSET)
+		<< KASAN_SHADOW_SCALE_SHIFT);
+}
 
 static inline void *kasan_mem_to_shadow(const void *addr)
 {
@@ -37,6 +56,24 @@ static inline void *kasan_mem_to_shadow(const void *addr)
 		+ KASAN_SHADOW_OFFSET;
 }
 
+static inline void *kasan_mem_to_pshadow(const void *addr)
+{
+	return (void *)((unsigned long)addr >> PAGE_SHIFT)
+		+ kasan_pshadow_offset;
+}
+
+static inline void *kasan_shadow_to_pshadow(const void *addr)
+{
+	/*
+	 * KASAN_SHADOW_END needs special handling since
+	 * it will overflow in kasan_shadow_to_mem()
+	 */
+	if ((unsigned long)addr == KASAN_SHADOW_END)
+		return (void *)KASAN_PSHADOW_END;
+
+	return kasan_mem_to_pshadow(kasan_shadow_to_mem(addr));
+}
+
 /* Enable reporting bugs after kasan_disable_current() */
 extern void kasan_enable_current(void);
 
@@ -44,6 +81,8 @@ extern void kasan_enable_current(void);
 extern void kasan_disable_current(void);
 
 void kasan_unpoison_shadow(const void *address, size_t size);
+void kasan_poison_pshadow(const void *address, size_t size);
+void kasan_unpoison_pshadow(const void *address, size_t size);
 
 void kasan_unpoison_task_stack(struct task_struct *task);
 void kasan_unpoison_stack_above_sp_to(const void *watermark);
@@ -89,6 +128,8 @@ void kasan_restore_multi_shot(bool enabled);
 #else /* CONFIG_KASAN */
 
 static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
+static inline void kasan_poison_pshadow(const void *address, size_t size) {}
+static inline void kasan_unpoison_pshadow(const void *address, size_t size) {}
 
 static inline void kasan_unpoison_task_stack(struct task_struct *task) {}
 static inline void kasan_unpoison_stack_above_sp_to(const void *watermark) {}
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 97d3560..76b7b89 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -116,6 +116,30 @@ void kasan_unpoison_stack_above_sp_to(const void *watermark)
 	kasan_unpoison_shadow(sp, size);
 }
 
+static void kasan_mark_pshadow(const void *address, size_t size, u8 value)
+{
+	void *pshadow_start;
+	void *pshadow_end;
+
+	if (!kasan_pshadow_inited())
+		return;
+
+	pshadow_start = kasan_mem_to_pshadow(address);
+	pshadow_end =  kasan_mem_to_pshadow(address + size);
+
+	memset(pshadow_start, value, pshadow_end - pshadow_start);
+}
+
+void kasan_poison_pshadow(const void *address, size_t size)
+{
+	kasan_mark_pshadow(address, size, KASAN_PER_PAGE_BYPASS);
+}
+
+void kasan_unpoison_pshadow(const void *address, size_t size)
+{
+	kasan_mark_pshadow(address, size, 0);
+}
+
 /*
  * All functions below always inlined so compiler could
  * perform better optimizations in each of __asan_loadX/__assn_storeX
@@ -269,8 +293,82 @@ static __always_inline bool memory_is_poisoned_n(unsigned long addr,
 	return false;
 }
 
+static __always_inline u8 pshadow_val_builtin(unsigned long addr, size_t size)
+{
+	u8 shadow_val = *(u8 *)kasan_mem_to_pshadow((void *)addr);
+
+	if (shadow_val == KASAN_PER_PAGE_FREE)
+		return shadow_val;
+
+	if (likely(((addr + size - 1) & PAGE_MASK) >= (size - 1)))
+		return shadow_val;
+
+	if (shadow_val != *(u8 *)kasan_mem_to_pshadow((void *)addr + size - 1))
+		return KASAN_PER_PAGE_FREE;
+
+	return shadow_val;
+}
+
+static __always_inline u8 pshadow_val_n(unsigned long addr, size_t size)
+{
+	u8 *start, *end;
+	u8 shadow_val;
+
+	start = kasan_mem_to_pshadow((void *)addr);
+	end = kasan_mem_to_pshadow((void *)addr + size - 1);
+	size = end - start + 1;
+
+	shadow_val = *start;
+	if (shadow_val == KASAN_PER_PAGE_FREE)
+		return shadow_val;
+
+	while (size) {
+		/*
+		 * Different shadow value means that access is over
+		 * the boundary. Report the error even if it is
+		 * in the valid area.
+		 */
+		if (shadow_val != *start)
+			return KASAN_PER_PAGE_FREE;
+
+		start++;
+		size--;
+	}
+
+	return shadow_val;
+}
+
+static __always_inline u8 pshadow_val(unsigned long addr, size_t size)
+{
+	if (!kasan_pshadow_inited())
+		return KASAN_PER_PAGE_BYPASS;
+
+	if (__builtin_constant_p(size)) {
+		switch (size) {
+		case 1:
+		case 2:
+		case 4:
+		case 8:
+		case 16:
+			return pshadow_val_builtin(addr, size);
+		default:
+			BUILD_BUG();
+		}
+	}
+
+	return pshadow_val_n(addr, size);
+}
+
 static __always_inline bool memory_is_poisoned(unsigned long addr, size_t size)
 {
+	u8 shadow_val = pshadow_val(addr, size);
+
+	if (!shadow_val)
+		return false;
+
+	if (shadow_val != KASAN_PER_PAGE_BYPASS)
+		return true;
+
 	if (__builtin_constant_p(size)) {
 		switch (size) {
 		case 1:
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 1229298..e9a67ac 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -13,6 +13,9 @@
 #define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
 #define KASAN_GLOBAL_REDZONE    0xFA  /* redzone for global variable */
 
+#define KASAN_PER_PAGE_BYPASS	0xFF  /* page should be checked by per-byte shadow */
+#define KASAN_PER_PAGE_FREE	0xFE  /* page was freed */
+
 /*
  * Stack redzone shadow values
  * (Those are compiler's ABI, don't change them)
@@ -90,10 +93,13 @@ struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
 struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 					const void *object);
 
-static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
+static inline bool kasan_pshadow_inited(void)
 {
-	return (void *)(((unsigned long)shadow_addr - KASAN_SHADOW_OFFSET)
-		<< KASAN_SHADOW_SCALE_SHIFT);
+#ifdef HAVE_KASAN_PER_PAGE_SHADOW
+	return true;
+#else
+	return false;
+#endif
 }
 
 void kasan_report(unsigned long addr, size_t size,
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index cd0a551..da9dcab 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -17,12 +17,15 @@
 #include <linux/memblock.h>
 #include <linux/mm.h>
 #include <linux/pfn.h>
+#include <linux/vmalloc.h>
 
 #include <asm/page.h>
 #include <asm/pgalloc.h>
 
 #include "kasan.h"
 
+unsigned long kasan_pshadow_offset __read_mostly;
+
 /*
  * This page serves two purposes:
  *   - It used as early shadow memory. The entire shadow region populated
@@ -250,3 +253,31 @@ void __init kasan_populate_shadow(const void *shadow_start,
 		kasan_p4d_populate(pgd, addr, next, zero, private);
 	} while (pgd++, addr = next, addr != end);
 }
+
+void __init kasan_early_init_pshadow(void)
+{
+	static struct vm_struct pshadow;
+	unsigned long kernel_offset;
+	int i;
+
+	/*
+	 * Temprorary map per-page shadow to per-byte shadow in order to
+	 * pass the KASAN checks in vm_area_register_early()
+	 */
+	kernel_offset = (unsigned long)kasan_shadow_to_mem(
+					(void *)KASAN_SHADOW_START);
+	kasan_pshadow_offset = KASAN_SHADOW_START -
+				(kernel_offset >> PAGE_SHIFT);
+
+	pshadow.size = KASAN_PSHADOW_SIZE;
+	pshadow.flags = VM_ALLOC | VM_NO_GUARD;
+	vm_area_register_early(&pshadow,
+		(PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT));
+
+	kasan_pshadow_offset = (unsigned long)pshadow.addr -
+					(kernel_offset >> PAGE_SHIFT);
+
+	BUILD_BUG_ON(KASAN_FREE_PAGE != KASAN_PER_PAGE_BYPASS);
+	for (i = 0; i < PAGE_SIZE; i++)
+		kasan_black_page[i] = KASAN_FREE_PAGE;
+}
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index beee0e9..9b47e10 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -39,6 +39,26 @@
 #define SHADOW_BYTES_PER_ROW (SHADOW_BLOCKS_PER_ROW * SHADOW_BYTES_PER_BLOCK)
 #define SHADOW_ROWS_AROUND_ADDR 2
 
+static bool bad_in_pshadow(const void *addr, size_t size)
+{
+	u8 shadow_val;
+	const void *end = addr + size;
+
+	if (!kasan_pshadow_inited())
+		return false;
+
+	shadow_val = *(u8 *)kasan_mem_to_pshadow(addr);
+	if (shadow_val == KASAN_PER_PAGE_FREE)
+		return true;
+
+	for (; addr < end; addr += PAGE_SIZE) {
+		if (shadow_val != *(u8 *)kasan_mem_to_pshadow(addr))
+			return true;
+	}
+
+	return false;
+}
+
 static const void *find_first_bad_addr(const void *addr, size_t size)
 {
 	u8 shadow_val = *(u8 *)kasan_mem_to_shadow(addr);
@@ -62,6 +82,11 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
 	const char *bug_type = "unknown-crash";
 	u8 *shadow_addr;
 
+	if (bad_in_pshadow(info->access_addr, info->access_size)) {
+		info->first_bad_addr = NULL;
+		bug_type = "use-after-free";
+		return bug_type;
+	}
 	info->first_bad_addr = find_first_bad_addr(info->access_addr,
 						info->access_size);
 
@@ -290,6 +315,9 @@ static void print_shadow_for_address(const void *addr)
 	const void *shadow = kasan_mem_to_shadow(addr);
 	const void *shadow_row;
 
+	if (!addr)
+		return;
+
 	shadow_row = (void *)round_down((unsigned long)shadow,
 					SHADOW_BYTES_PER_ROW)
 		- SHADOW_ROWS_AROUND_ADDR * SHADOW_BYTES_PER_ROW;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
