Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC5D6B025F
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 13:10:16 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j6so14907352wre.16
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 10:10:16 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 6si10400127wmk.223.2017.11.26.10.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 26 Nov 2017 10:10:14 -0800 (PST)
Message-Id: <20171126180232.168606826@linutronix.de>
Date: Sun, 26 Nov 2017 18:55:42 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 4/4] x86/kaiser: Add boottime disable switch
References: <20171126175538.841453476@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-kaiser--Add-boottime-disable-switch.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

KAISER comes with overhead. The most expensive part is the CR3 switching in
the entry code.

Add a command line parameter which allows to disable KAISER at boot time.

Most code pathes simply check a variable, but the entry code uses a static
branch. The other code pathes cannot use a static branch because they are
used before jump label patching is possible. Not an issue as the code
pathes are not so performance sensitive as the entry/exit code.

This makes KAISER depend on JUMP_LABEL and on a GCC which supports
it, but that's a resonable requirement.

This does not yet take care of the 8k PGD allocations, but that can be
done on top.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/entry/calling.h          |    7 +++++++
 arch/x86/include/asm/kaiser.h     |    8 ++++++++
 arch/x86/include/asm/pgtable_64.h |    6 ++++++
 arch/x86/mm/init.c                |    7 ++++---
 arch/x86/mm/kaiser.c              |   30 ++++++++++++++++++++++++++++++
 security/Kconfig                  |    2 +-
 6 files changed, 56 insertions(+), 4 deletions(-)

--- a/arch/x86/entry/calling.h
+++ b/arch/x86/entry/calling.h
@@ -210,18 +210,23 @@ For 32-bit we have the following convent
 .endm
 
 .macro SWITCH_TO_KERNEL_CR3 scratch_reg:req
+	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
 	mov	%cr3, \scratch_reg
 	ADJUST_KERNEL_CR3 \scratch_reg
 	mov	\scratch_reg, %cr3
+.Lend_\@:
 .endm
 
 .macro SWITCH_TO_USER_CR3 scratch_reg:req
+	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
 	mov	%cr3, \scratch_reg
 	ADJUST_USER_CR3 \scratch_reg
 	mov	\scratch_reg, %cr3
+.Lend_\@:
 .endm
 
 .macro SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg:req save_reg:req
+	STATIC_JUMP_IF_FALSE .Ldone_\@, kaiser_enabled_key, def=1
 	movq	%cr3, %r\scratch_reg
 	movq	%r\scratch_reg, \save_reg
 	/*
@@ -244,11 +249,13 @@ For 32-bit we have the following convent
 .endm
 
 .macro RESTORE_CR3 save_reg:req
+	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
 	/*
 	 * The CR3 write could be avoided when not changing its value,
 	 * but would require a CR3 read *and* a scratch register.
 	 */
 	movq	\save_reg, %cr3
+.Lend_\@:
 .endm
 
 #else /* CONFIG_KAISER=n: */
--- a/arch/x86/include/asm/kaiser.h
+++ b/arch/x86/include/asm/kaiser.h
@@ -56,6 +56,14 @@ extern void kaiser_remove_mapping(unsign
  */
 extern void kaiser_init(void);
 
+/* True if kaiser is enabled at boot time */
+extern struct static_key_true kaiser_enabled_key;
+extern bool kaiser_enabled;
+extern void kaiser_check_cmdline(void);
+
+#else /* CONFIG_KAISER */
+# define kaiser_enabled		(false)
+static inline void kaiser_check_cmdline(void) { }
 #endif
 
 #endif /* __ASSEMBLY__ */
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -175,6 +175,9 @@ static inline p4d_t *shadow_to_kernel_p4
 {
 	return ptr_clear_bit(p4dp, KAISER_PGTABLE_SWITCH_BIT);
 }
+
+extern bool kaiser_enabled;
+
 #endif /* CONFIG_KAISER */
 
 /*
@@ -208,6 +211,9 @@ static inline bool pgd_userspace_access(
 static inline pgd_t kaiser_set_shadow_pgd(pgd_t *pgdp, pgd_t pgd)
 {
 #ifdef CONFIG_KAISER
+	if (!kaiser_enabled)
+		return pgd;
+
 	if (pgd_userspace_access(pgd)) {
 		if (pgdp_maps_userspace(pgdp)) {
 			/*
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -20,6 +20,7 @@
 #include <asm/kaslr.h>
 #include <asm/hypervisor.h>
 #include <asm/cpufeature.h>
+#include <asm/kaiser.h>
 
 /*
  * We need to define the tracepoints somewhere, and tlb.c
@@ -163,9 +164,8 @@ static int page_size_mask;
 
 static void enable_global_pages(void)
 {
-#ifndef CONFIG_KAISER
-	__supported_pte_mask |= _PAGE_GLOBAL;
-#endif
+	if (!kaiser_enabled)
+		__supported_pte_mask |= _PAGE_GLOBAL;
 }
 
 static void __init probe_page_size_mask(void)
@@ -656,6 +656,7 @@ void __init init_mem_mapping(void)
 {
 	unsigned long end;
 
+	kaiser_check_cmdline();
 	probe_page_size_mask();
 	setup_pcid();
 
--- a/arch/x86/mm/kaiser.c
+++ b/arch/x86/mm/kaiser.c
@@ -34,12 +34,23 @@
 #include <linux/mm.h>
 #include <linux/uaccess.h>
 
+#include <asm/cmdline.h>
 #include <asm/kaiser.h>
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 #include <asm/desc.h>
 
+/* Global flag for boot time kaiser enable/disable */
+bool kaiser_enabled __ro_after_init = true;
+DEFINE_STATIC_KEY_TRUE(kaiser_enabled_key);
+
+void __init kaiser_check_cmdline(void)
+{
+	if (cmdline_find_option_bool(boot_command_line, "nokaiser"))
+		kaiser_enabled = false;
+}
+
 #define KAISER_WALK_ATOMIC  0x1
 
 /*
@@ -250,6 +261,9 @@ int kaiser_add_user_map(const void *__st
 	unsigned long end_addr = PAGE_ALIGN(start_addr + size);
 	unsigned long target_address;
 
+	if (!kaiser_enabled)
+		return 0;
+
 	for (; address < end_addr; address += PAGE_SIZE) {
 		target_address = get_pa_from_kernel_map(address);
 		if (target_address == -1)
@@ -392,6 +406,9 @@ void __init kaiser_init(void)
 {
 	int cpu;
 
+	if (!kaiser_enabled)
+		return;
+
 	kaiser_init_all_pgds();
 
 	for_each_possible_cpu(cpu) {
@@ -426,6 +443,16 @@ void __init kaiser_init(void)
 	kaiser_add_mapping_cpu_entry(0);
 }
 
+static int __init kaiser_boottime_control(void)
+{
+	if (!kaiser_enabled) {
+		static_branch_disable(&kaiser_enabled_key);
+		pr_info("kaiser: Disabled on command line\n");
+	}
+	return 0;
+}
+subsys_initcall(kaiser_boottime_control);
+
 int kaiser_add_mapping(unsigned long addr, unsigned long size,
 		       unsigned long flags)
 {
@@ -436,6 +463,9 @@ void kaiser_remove_mapping(unsigned long
 {
 	unsigned long addr;
 
+	if (!kaiser_enabled)
+		return;
+
 	/* The shadow page tables always use small pages: */
 	for (addr = start; addr < start + size; addr += PAGE_SIZE) {
 		/*
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -56,7 +56,7 @@ config SECURITY_NETWORK
 
 config KAISER
 	bool "Remove the kernel mapping in user mode"
-	depends on X86_64 && SMP && !PARAVIRT
+	depends on X86_64 && SMP && !PARAVIRT && JUMP_LABEL
 	help
 	  This feature reduces the number of hardware side channels by
 	  ensuring that the majority of kernel addresses are not mapped


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
