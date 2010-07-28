Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 395896B02AF
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 07:01:05 -0400 (EDT)
Date: Wed, 28 Jul 2010 07:00:43 -0400
From: Xiaotian Feng <dfeng@redhat.com>
Message-Id: <20100728110043.27677.13908.sendpatchset@dhcp-65-180.nay.redhat.com>
Subject: [PATCH RHEL6 RESEND] kernel performance optimization with CONFIG_DEBUG_RODATA
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc: cl@linux-foundation.org, a.p.zijlstra@chello.nl, Xiaotian Feng <dfeng@redhat.com>, lwang@redhat.com, penberg@cs.helsinki.fi, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

backport of following commits to improve x86_64 kernel performance with
CONFIG_DEBUG_RODATA:

straightforward backport of:
commit b9af7c0d (x86-64: preserve large page mapping for 1st 2MB kernel txt with CONFIG_DEBUG_RODATA)
commit 74e08179 (x86-64: align RODATA kernel section to 2MB with CONFIG_DEBUG_RODATA)
commit d6cc1c3a (x86-64: add comment for RODATA large page retainment)

Resolves bz557364

We still have CONFIG_DEBUG_RODATA set for regular rhel6 kernel, so this fix is still needed.

There's no kabi breakage with latest rhel6 code (don't know why...)
Brew build is available at:
https://brewweb.devel.redhat.com/taskinfo?taskID=2627856

Test has been done for RHTS kernel tier1:
http://rhts.redhat.com/cgi-bin/rhts/jobs.cgi?id=168225

No regressions are introduced by this patch. Reviews and comments are welcome.
---
--- a/arch/x86/include/asm/sections.h
+++ b/arch/x86/include/asm/sections.h
@@ -2,7 +2,13 @@
 #define _ASM_X86_SECTIONS_H
 
 #include <asm-generic/sections.h>
+#include <asm/uaccess.h>
 
 extern char __brk_base[], __brk_limit[];
+extern struct exception_table_entry __stop___ex_table[];
+
+#if defined(CONFIG_X86_64) && defined(CONFIG_DEBUG_RODATA)
+extern char __end_rodata_hpage_align[];
+#endif
 
 #endif	/* _ASM_X86_SECTIONS_H */
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -262,11 +262,11 @@ ENTRY(secondary_startup_64)
 	.quad	x86_64_start_kernel
 	ENTRY(initial_gs)
 	.quad	INIT_PER_CPU_VAR(irq_stack_union)
-	__FINITDATA
 
 	ENTRY(stack_start)
 	.quad  init_thread_union+THREAD_SIZE-8
 	.word  0
+	__FINITDATA
 
 bad_address:
 	jmp bad_address
@@ -340,6 +340,7 @@ ENTRY(name)
 	i = i + 1 ;					\
 	.endr
 
+	.data
 	/*
 	 * This default setting generates an ident mapping at address 0x100000
 	 * and a mapping for the kernel that precisely maps virtual address
--- a/arch/x86/kernel/vmlinux.lds.S
+++ b/arch/x86/kernel/vmlinux.lds.S
@@ -41,6 +41,32 @@ ENTRY(phys_startup_64)
 jiffies_64 = jiffies;
 #endif
 
+#if defined(CONFIG_X86_64) && defined(CONFIG_DEBUG_RODATA)
+/*
+ * On 64-bit, align RODATA to 2MB so that even with CONFIG_DEBUG_RODATA
+ * we retain large page mappings for boundaries spanning kernel text, rodata
+ * and data sections.
+ *
+ * However, kernel identity mappings will have different RWX permissions
+ * to the pages mapping to text and to the pages padding (which are freed) the
+ * text section. Hence kernel identity mappings will be broken to smaller
+ * pages. For 64-bit, kernel text and kernel identity mappings are different,
+ * so we can enable protection checks that come with CONFIG_DEBUG_RODATA,
+ * as well as retain 2MB large page mappings for kernel text.
+ */
+#define X64_ALIGN_DEBUG_RODATA_BEGIN   . = ALIGN(HPAGE_SIZE);
+
+#define X64_ALIGN_DEBUG_RODATA_END				\
+		. = ALIGN(HPAGE_SIZE);				\
+		__end_rodata_hpage_align = .;
+
+#else
+
+#define X64_ALIGN_DEBUG_RODATA_BEGIN
+#define X64_ALIGN_DEBUG_RODATA_END
+
+#endif
+
 PHDRS {
 	text PT_LOAD FLAGS(5);          /* R_E */
 	data PT_LOAD FLAGS(7);          /* RWE */
@@ -90,7 +116,9 @@ SECTIONS
 
 	EXCEPTION_TABLE(16) :text = 0x9090
 
+	X64_ALIGN_DEBUG_RODATA_BEGIN
 	RO_DATA(PAGE_SIZE)
+	X64_ALIGN_DEBUG_RODATA_END
 
 	/* Data */
 	.data : AT(ADDR(.data) - LOAD_OFFSET) {
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -761,7 +761,7 @@ static int kernel_set_to_readonly;
 
 void set_kernel_text_rw(void)
 {
-	unsigned long start = PFN_ALIGN(_stext);
+	unsigned long start = PFN_ALIGN(_text);
 	unsigned long end = PFN_ALIGN(__start_rodata);
 
 	if (!kernel_set_to_readonly)
@@ -775,7 +775,7 @@ void set_kernel_text_rw(void)
 
 void set_kernel_text_ro(void)
 {
-	unsigned long start = PFN_ALIGN(_stext);
+	unsigned long start = PFN_ALIGN(_text);
 	unsigned long end = PFN_ALIGN(__start_rodata);
 
 	if (!kernel_set_to_readonly)
@@ -789,9 +789,13 @@ void set_kernel_text_ro(void)
 
 void mark_rodata_ro(void)
 {
-	unsigned long start = PFN_ALIGN(_stext), end = PFN_ALIGN(__end_rodata);
+	unsigned long start = PFN_ALIGN(_text);
 	unsigned long rodata_start =
 		((unsigned long)__start_rodata + PAGE_SIZE - 1) & PAGE_MASK;
+	unsigned long end = (unsigned long) &__end_rodata_hpage_align;
+	unsigned long text_end = PAGE_ALIGN((unsigned long) &__stop___ex_table);
+	unsigned long rodata_end = PAGE_ALIGN((unsigned long) &__end_rodata);
+	unsigned long data_start = (unsigned long) &_sdata;
 
 	printk(KERN_INFO "Write protecting the kernel read-only data: %luk\n",
 	       (end - start) >> 10);
@@ -814,6 +818,14 @@ void mark_rodata_ro(void)
 	printk(KERN_INFO "Testing CPA: again\n");
 	set_memory_ro(start, (end-start) >> PAGE_SHIFT);
 #endif
+
+	free_init_pages("unused kernel memory",
+			(unsigned long) page_address(virt_to_page(text_end)),
+			(unsigned long)
+				 page_address(virt_to_page(rodata_start)));
+	free_init_pages("unused kernel memory",
+			(unsigned long) page_address(virt_to_page(rodata_end)),
+			(unsigned long) page_address(virt_to_page(data_start)));
 }
 
 #endif
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -279,6 +279,20 @@ static inline pgprot_t static_protections(pgprot_t prot, unsigned long address,
 		   __pa((unsigned long)__end_rodata) >> PAGE_SHIFT))
 		pgprot_val(forbidden) |= _PAGE_RW;
 
+#if defined(CONFIG_X86_64) && defined(CONFIG_DEBUG_RODATA)
+	/*
+	 * Kernel text mappings for the large page aligned .rodata section
+	 * will be read-only. For the kernel identity mappings covering
+	 * the holes caused by this alignment can be anything.
+	 *
+	 * This will preserve the large page mappings for kernel text/data
+	 * at no extra cost.
+	 */
+	if (within(address, (unsigned long)_text,
+		   (unsigned long)__end_rodata_hpage_align))
+		pgprot_val(forbidden) |= _PAGE_RW;
+#endif
+
 	prot = __pgprot(pgprot_val(prot) & ~pgprot_val(forbidden));
 
 	return prot;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
