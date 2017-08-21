Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6372803E9
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 11:29:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m15so85459432pgr.7
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 08:29:27 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t76si7342978pgc.539.2017.08.21.08.29.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 08:29:25 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 03/19] x86/kasan: Use the same shadow offset for 4- and 5-level paging
Date: Mon, 21 Aug 2017 18:29:00 +0300
Message-Id: <20170821152916.40124-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
References: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

We are going to support boot-time switching between 4- and 5-level
paging. For KASAN it means we cannot have different KASAN_SHADOW_OFFSET
for different paging modes: the constant is passed to gcc to generate
code and cannot be changed at runtime.

This patch changes KASAN code to use 0xdffffc0000000000 as shadow offset
for both 4- and 5-level paging.

For 5-level paging it means that shadow memory region is not aligned to
PGD boundary anymore and we have to handle unaligned parts of the region
properly.

In addition, we have to exclude paravirt code from KASAN instrumentation
as we now use set_pgd() before KASAN is fully ready.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
[kirill.shutemov@linux.intel.com: clenaup, changelog message]
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig            |  1 -
 arch/x86/kernel/Makefile    |  3 +-
 arch/x86/mm/kasan_init_64.c | 86 ++++++++++++++++++++++++++++++++++-----------
 3 files changed, 67 insertions(+), 23 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index ce3ed304288d..2c9c4899d9ff 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -299,7 +299,6 @@ config ARCH_SUPPORTS_DEBUG_PAGEALLOC
 config KASAN_SHADOW_OFFSET
 	hex
 	depends on KASAN
-	default 0xdff8000000000000 if X86_5LEVEL
 	default 0xdffffc0000000000
 
 config HAVE_INTEL_TXT
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 287eac7d207f..4509140232c3 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -24,7 +24,8 @@ endif
 KASAN_SANITIZE_head$(BITS).o				:= n
 KASAN_SANITIZE_dumpstack.o				:= n
 KASAN_SANITIZE_dumpstack_$(BITS).o			:= n
-KASAN_SANITIZE_stacktrace.o := n
+KASAN_SANITIZE_stacktrace.o				:= n
+KASAN_SANITIZE_paravirt.o				:= n
 
 OBJECT_FILES_NON_STANDARD_head_$(BITS).o		:= y
 OBJECT_FILES_NON_STANDARD_relocate_kernel_$(BITS).o	:= y
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index bc84b73684b7..f6b4db2647b5 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -15,6 +15,8 @@
 
 extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
+static p4d_t tmp_p4d_table[PTRS_PER_P4D] __initdata __aligned(PAGE_SIZE);
+
 static int __init map_range(struct range *range)
 {
 	unsigned long start;
@@ -30,8 +32,9 @@ static void __init clear_pgds(unsigned long start,
 			unsigned long end)
 {
 	pgd_t *pgd;
+	unsigned long pgd_end = end & PGDIR_MASK;
 
-	for (; start < end; start += PGDIR_SIZE) {
+	for (; start < pgd_end; start += PGDIR_SIZE) {
 		pgd = pgd_offset_k(start);
 		/*
 		 * With folded p4d, pgd_clear() is nop, use p4d_clear()
@@ -42,29 +45,60 @@ static void __init clear_pgds(unsigned long start,
 		else
 			pgd_clear(pgd);
 	}
+
+	pgd = pgd_offset_k(start);
+	for (; start < end; start += P4D_SIZE)
+		p4d_clear(p4d_offset(pgd, start));
+}
+
+static inline p4d_t *early_p4d_offset(pgd_t *pgd, unsigned long addr)
+{
+	unsigned long p4d;
+
+	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+		return (p4d_t *)pgd;
+
+	p4d = __pa_nodebug(pgd_val(*pgd)) & PTE_PFN_MASK;
+	p4d += __START_KERNEL_map - phys_base;
+	return (p4d_t *)p4d + p4d_index(addr);
+}
+
+static void __init kasan_early_p4d_populate(pgd_t *pgd,
+		unsigned long addr,
+		unsigned long end)
+{
+	pgd_t pgd_entry;
+	p4d_t *p4d, p4d_entry;
+	unsigned long next;
+
+	if (pgd_none(*pgd)) {
+		pgd_entry = __pgd(_KERNPG_TABLE | __pa_nodebug(kasan_zero_p4d));
+		set_pgd(pgd, pgd_entry);
+	}
+
+	p4d = early_p4d_offset(pgd, addr);
+	do {
+		next = p4d_addr_end(addr, end);
+
+		if (!p4d_none(*p4d))
+			continue;
+
+		p4d_entry = __p4d(_KERNPG_TABLE | __pa_nodebug(kasan_zero_pud));
+		set_p4d(p4d, p4d_entry);
+	} while (p4d++, addr = next, addr != end && p4d_none(*p4d));
 }
 
 static void __init kasan_map_early_shadow(pgd_t *pgd)
 {
-	int i;
-	unsigned long start = KASAN_SHADOW_START;
+	unsigned long addr = KASAN_SHADOW_START & PGDIR_MASK;
 	unsigned long end = KASAN_SHADOW_END;
+	unsigned long next;
 
-	for (i = pgd_index(start); start < end; i++) {
-		switch (CONFIG_PGTABLE_LEVELS) {
-		case 4:
-			pgd[i] = __pgd(__pa_nodebug(kasan_zero_pud) |
-					_KERNPG_TABLE);
-			break;
-		case 5:
-			pgd[i] = __pgd(__pa_nodebug(kasan_zero_p4d) |
-					_KERNPG_TABLE);
-			break;
-		default:
-			BUILD_BUG();
-		}
-		start += PGDIR_SIZE;
-	}
+	pgd += pgd_index(addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		kasan_early_p4d_populate(pgd, addr, next);
+	} while (pgd++, addr = next, addr != end);
 }
 
 #ifdef CONFIG_KASAN_INLINE
@@ -101,7 +135,7 @@ void __init kasan_early_init(void)
 	for (i = 0; i < PTRS_PER_PUD; i++)
 		kasan_zero_pud[i] = __pud(pud_val);
 
-	for (i = 0; CONFIG_PGTABLE_LEVELS >= 5 && i < PTRS_PER_P4D; i++)
+	for (i = 0; IS_ENABLED(CONFIG_X86_5LEVEL) && i < PTRS_PER_P4D; i++)
 		kasan_zero_p4d[i] = __p4d(p4d_val);
 
 	kasan_map_early_shadow(early_top_pgt);
@@ -117,12 +151,22 @@ void __init kasan_init(void)
 #endif
 
 	memcpy(early_top_pgt, init_top_pgt, sizeof(early_top_pgt));
+
+	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		void *ptr;
+
+		ptr = (void *)pgd_page_vaddr(*pgd_offset_k(KASAN_SHADOW_END));
+		memcpy(tmp_p4d_table, (void *)ptr, sizeof(tmp_p4d_table));
+		set_pgd(&early_top_pgt[pgd_index(KASAN_SHADOW_END)],
+				__pgd(__pa(tmp_p4d_table) | _KERNPG_TABLE));
+	}
+
 	load_cr3(early_top_pgt);
 	__flush_tlb_all();
 
-	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
+	clear_pgds(KASAN_SHADOW_START & PGDIR_MASK, KASAN_SHADOW_END);
 
-	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
+	kasan_populate_zero_shadow((void *)(KASAN_SHADOW_START & PGDIR_MASK),
 			kasan_mem_to_shadow((void *)PAGE_OFFSET));
 
 	for (i = 0; i < E820_MAX_ENTRIES; i++) {
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
