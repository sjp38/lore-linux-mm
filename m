Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A0E096B0254
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 12:21:44 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id q3so6683445pav.3
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 09:21:44 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id l65si6391847pfb.100.2015.12.16.09.21.43
        for <linux-mm@kvack.org>;
        Wed, 16 Dec 2015 09:21:43 -0800 (PST)
Message-Id: <2e91c18f23be90b33c2cbfff6cce6b6f50592a96.1450283985.git.tony.luck@intel.com>
In-Reply-To: <cover.1450283985.git.tony.luck@intel.com>
References: <cover.1450283985.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Tue, 15 Dec 2015 17:29:30 -0800
Subject: [PATCHV3 1/3] x86, ras: Add new infrastructure for machine check fixup tables
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Elliott@kvack.org, "Robert (Persistent Memory)" <elliott@hpe.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

Copy the existing page fault fixup mechanisms to create a new table
to be used when fixing machine checks. Note:
1) At this time we only provide a macro to annotate assembly code
2) We assume all fixups will in code builtin to the kernel.
3) Only for x86_64
4) New code under CONFIG_MCE_KERNEL_RECOVERY (default 'n')

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/x86/Kconfig                  | 10 ++++++++++
 arch/x86/include/asm/asm.h        | 10 ++++++++--
 arch/x86/include/asm/mce.h        | 14 ++++++++++++++
 arch/x86/kernel/cpu/mcheck/mce.c  | 16 ++++++++++++++++
 arch/x86/kernel/vmlinux.lds.S     |  6 +++++-
 arch/x86/mm/extable.c             | 19 +++++++++++++++++++
 include/asm-generic/vmlinux.lds.h | 12 +++++++-----
 7 files changed, 79 insertions(+), 8 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 96d058a87100..42d26b4d1ec4 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1001,6 +1001,16 @@ config X86_MCE_INJECT
 	  If you don't know what a machine check is and you don't do kernel
 	  QA it is safe to say n.
 
+config MCE_KERNEL_RECOVERY
+	bool "Recovery from machine checks in special kernel memory copy functions"
+	default n
+	depends on X86_MCE && X86_64
+	---help---
+	  This option provides a new memory copy function mcsafe_memcpy()
+	  that is annotated to allow the machine check handler to return
+	  to an alternate code path to return an error to the caller instead
+	  of crashing the system. Say yes if you have a driver that uses this.
+
 config X86_THERMAL_VECTOR
 	def_bool y
 	depends on X86_MCE_INTEL
diff --git a/arch/x86/include/asm/asm.h b/arch/x86/include/asm/asm.h
index 189679aba703..a5d483ac11fa 100644
--- a/arch/x86/include/asm/asm.h
+++ b/arch/x86/include/asm/asm.h
@@ -44,13 +44,19 @@
 
 /* Exception table entry */
 #ifdef __ASSEMBLY__
-# define _ASM_EXTABLE(from,to)					\
-	.pushsection "__ex_table","a" ;				\
+# define __ASM_EXTABLE(from, to, table)				\
+	.pushsection table, "a" ;				\
 	.balign 8 ;						\
 	.long (from) - . ;					\
 	.long (to) - . ;					\
 	.popsection
 
+# define _ASM_EXTABLE(from, to)					\
+	__ASM_EXTABLE(from, to, "__ex_table")
+
+# define _ASM_MCEXTABLE(from, to)				\
+	__ASM_EXTABLE(from, to, "__mcex_table")
+
 # define _ASM_EXTABLE_EX(from,to)				\
 	.pushsection "__ex_table","a" ;				\
 	.balign 8 ;						\
diff --git a/arch/x86/include/asm/mce.h b/arch/x86/include/asm/mce.h
index 2dbc0bf2b9f3..9dc11d2a9db1 100644
--- a/arch/x86/include/asm/mce.h
+++ b/arch/x86/include/asm/mce.h
@@ -279,4 +279,18 @@ struct cper_sec_mem_err;
 extern void apei_mce_report_mem_error(int corrected,
 				      struct cper_sec_mem_err *mem_err);
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+const struct exception_table_entry *search_mcexception_tables(unsigned long a);
+int fixup_mcexception(struct pt_regs *regs);
+#else
+static inline const struct exception_table_entry *search_mcexception_tables(unsigned long a)
+{
+	return 0;
+}
+static inline int fixup_mcexception(struct pt_regs *regs)
+{
+	return 0;
+}
+#endif
+
 #endif /* _ASM_X86_MCE_H */
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 9d014b82a124..0111cd49ee94 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -31,6 +31,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/init.h>
+#include <linux/module.h>
 #include <linux/kmod.h>
 #include <linux/poll.h>
 #include <linux/nmi.h>
@@ -2022,8 +2023,23 @@ static int __init mcheck_enable(char *str)
 }
 __setup("mce", mcheck_enable);
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+extern struct exception_table_entry __start___mcex_table[];
+extern struct exception_table_entry __stop___mcex_table[];
+
+/* Given an address, look for it in the machine check exception tables. */
+const struct exception_table_entry *search_mcexception_tables(unsigned long addr)
+{
+	return search_extable(__start___mcex_table, __stop___mcex_table-1, addr);
+}
+#endif
+
 int __init mcheck_init(void)
 {
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+	if (__stop___mcex_table > __start___mcex_table)
+		sort_extable(__start___mcex_table, __stop___mcex_table);
+#endif
 	mcheck_intel_therm_init();
 	mce_register_decode_chain(&mce_srao_nb);
 	mcheck_vendor_init_severity();
diff --git a/arch/x86/kernel/vmlinux.lds.S b/arch/x86/kernel/vmlinux.lds.S
index 74e4bf11f562..a65fa0deda06 100644
--- a/arch/x86/kernel/vmlinux.lds.S
+++ b/arch/x86/kernel/vmlinux.lds.S
@@ -110,7 +110,11 @@ SECTIONS
 
 	NOTES :text :note
 
-	EXCEPTION_TABLE(16) :text = 0x9090
+	EXCEPTION_TABLE(16)
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+	NAMED_EXCEPTION_TABLE(16, mcex)
+#endif
+	:text = 0x9090
 
 #if defined(CONFIG_DEBUG_RODATA)
 	/* .text should occupy whole number of pages */
diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
index 903ec1e9c326..f8f8b72e88af 100644
--- a/arch/x86/mm/extable.c
+++ b/arch/x86/mm/extable.c
@@ -2,6 +2,7 @@
 #include <linux/spinlock.h>
 #include <linux/sort.h>
 #include <asm/uaccess.h>
+#include <asm/mce.h>
 
 static inline unsigned long
 ex_insn_addr(const struct exception_table_entry *x)
@@ -49,6 +50,24 @@ int fixup_exception(struct pt_regs *regs)
 	return 0;
 }
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+int fixup_mcexception(struct pt_regs *regs)
+{
+	const struct exception_table_entry *fixup;
+	unsigned long new_ip;
+
+	fixup = search_mcexception_tables(regs->ip);
+	if (fixup) {
+		new_ip = ex_fixup_addr(fixup);
+
+		regs->ip = new_ip;
+		return 1;
+	}
+
+	return 0;
+}
+#endif
+
 /* Restricted version used during very early boot */
 int __init early_fixup_exception(unsigned long *ip)
 {
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 1781e54ea6d3..42ef98de373a 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -467,14 +467,16 @@
 /*
  * Exception table
  */
-#define EXCEPTION_TABLE(align)						\
+#define NAMED_EXCEPTION_TABLE(align, pfx)				\
 	. = ALIGN(align);						\
-	__ex_table : AT(ADDR(__ex_table) - LOAD_OFFSET) {		\
-		VMLINUX_SYMBOL(__start___ex_table) = .;			\
-		*(__ex_table)						\
-		VMLINUX_SYMBOL(__stop___ex_table) = .;			\
+	__##pfx##_table : AT(ADDR(__##pfx##_table) - LOAD_OFFSET) {	\
+		VMLINUX_SYMBOL(__start___##pfx##_table) = .;		\
+		*(__##pfx##_table)					\
+		VMLINUX_SYMBOL(__stop___##pfx##_table) = .;		\
 	}
 
+#define EXCEPTION_TABLE(align) NAMED_EXCEPTION_TABLE(align, ex)
+
 /*
  * Init task
  */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
