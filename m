Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87E746B0069
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:59:09 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id a45so16264034wra.14
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 00:59:09 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h94si17980146wrh.59.2017.12.22.00.59.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 00:59:08 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 024/159] x86/kasan: Use the same shadow offset for 4- and 5-level paging
Date: Fri, 22 Dec 2017 09:45:09 +0100
Message-Id: <20171222084625.074436096@linuxfoundation.org>
In-Reply-To: <20171222084623.668990192@linuxfoundation.org>
References: <20171222084623.668990192@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Andrey Ryabinin <aryabinin@virtuozzo.com>

commit 12a8cc7fcf54a8575f094be1e99032ec38aa045c upstream.

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

[kirill.shutemov@linux.intel.com: clenaup, changelog message]
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@suse.de>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20170929140821.37654-4-kirill.shutemov@linux.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 Documentation/x86/x86_64/mm.txt |    2 
 arch/x86/Kconfig                |    1 
 arch/x86/kernel/Makefile        |    3 -
 arch/x86/mm/kasan_init_64.c     |  101 +++++++++++++++++++++++++++++++---------
 4 files changed, 83 insertions(+), 24 deletions(-)

--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -34,7 +34,7 @@ ff92000000000000 - ffd1ffffffffffff (=54
 ffd2000000000000 - ffd3ffffffffffff (=49 bits) hole
 ffd4000000000000 - ffd5ffffffffffff (=49 bits) virtual memory map (512TB)
 ... unused hole ...
-ffd8000000000000 - fff7ffffffffffff (=53 bits) kasan shadow memory (8PB)
+ffdf000000000000 - fffffc0000000000 (=53 bits) kasan shadow memory (8PB)
 ... unused hole ...
 ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
 ... unused hole ...
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -303,7 +303,6 @@ config ARCH_SUPPORTS_DEBUG_PAGEALLOC
 config KASAN_SHADOW_OFFSET
 	hex
 	depends on KASAN
-	default 0xdff8000000000000 if X86_5LEVEL
 	default 0xdffffc0000000000
 
 config HAVE_INTEL_TXT
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -25,7 +25,8 @@ endif
 KASAN_SANITIZE_head$(BITS).o				:= n
 KASAN_SANITIZE_dumpstack.o				:= n
 KASAN_SANITIZE_dumpstack_$(BITS).o			:= n
-KASAN_SANITIZE_stacktrace.o := n
+KASAN_SANITIZE_stacktrace.o				:= n
+KASAN_SANITIZE_paravirt.o				:= n
 
 OBJECT_FILES_NON_STANDARD_relocate_kernel_$(BITS).o	:= y
 OBJECT_FILES_NON_STANDARD_ftrace_$(BITS).o		:= y
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -16,6 +16,8 @@
 
 extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
+static p4d_t tmp_p4d_table[PTRS_PER_P4D] __initdata __aligned(PAGE_SIZE);
+
 static int __init map_range(struct range *range)
 {
 	unsigned long start;
@@ -31,8 +33,10 @@ static void __init clear_pgds(unsigned l
 			unsigned long end)
 {
 	pgd_t *pgd;
+	/* See comment in kasan_init() */
+	unsigned long pgd_end = end & PGDIR_MASK;
 
-	for (; start < end; start += PGDIR_SIZE) {
+	for (; start < pgd_end; start += PGDIR_SIZE) {
 		pgd = pgd_offset_k(start);
 		/*
 		 * With folded p4d, pgd_clear() is nop, use p4d_clear()
@@ -43,29 +47,61 @@ static void __init clear_pgds(unsigned l
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
+	/* See comment in kasan_init() */
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
@@ -102,7 +138,7 @@ void __init kasan_early_init(void)
 	for (i = 0; i < PTRS_PER_PUD; i++)
 		kasan_zero_pud[i] = __pud(pud_val);
 
-	for (i = 0; CONFIG_PGTABLE_LEVELS >= 5 && i < PTRS_PER_P4D; i++)
+	for (i = 0; IS_ENABLED(CONFIG_X86_5LEVEL) && i < PTRS_PER_P4D; i++)
 		kasan_zero_p4d[i] = __p4d(p4d_val);
 
 	kasan_map_early_shadow(early_top_pgt);
@@ -118,12 +154,35 @@ void __init kasan_init(void)
 #endif
 
 	memcpy(early_top_pgt, init_top_pgt, sizeof(early_top_pgt));
+
+	/*
+	 * We use the same shadow offset for 4- and 5-level paging to
+	 * facilitate boot-time switching between paging modes.
+	 * As result in 5-level paging mode KASAN_SHADOW_START and
+	 * KASAN_SHADOW_END are not aligned to PGD boundary.
+	 *
+	 * KASAN_SHADOW_START doesn't share PGD with anything else.
+	 * We claim whole PGD entry to make things easier.
+	 *
+	 * KASAN_SHADOW_END lands in the last PGD entry and it collides with
+	 * bunch of things like kernel code, modules, EFI mapping, etc.
+	 * We need to take extra steps to not overwrite them.
+	 */
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
