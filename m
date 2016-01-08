Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 07BF1828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 19:18:35 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id cy9so289973245pac.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 16:18:35 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id dw8si68695378pab.16.2016.01.08.16.18.33
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 16:18:33 -0800 (PST)
Message-Id: <3a259f1cce4a3c309c2f81df715f8c2c9bb80015.1452297867.git.tony.luck@intel.com>
In-Reply-To: <cover.1452297867.git.tony.luck@intel.com>
References: <cover.1452297867.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Fri, 8 Jan 2016 12:49:38 -0800
Subject: [PATCH v8 1/3] x86: Expand exception table to allow new handling
 options
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

Huge amounts of help from  Andy Lutomirski and Borislav Petkov to
produce this. Andy provided the inspiration to add classes to the
exception table with a clever bit-squeezing trick, Boris pointed
out how much cleaner it would all be if we just had a new field.

Linus Torvalds blessed the expansion with:
  I'd rather not be clever in order to save just a tiny amount of space
  in the exception table, which isn't really criticial for anybody.

The third field is a simple integer indexing into an array of handler
functions (I thought it couldn't be a relative pointer like the other
fields because a module may have its ex_table loaded more than 2GB away
from the handler function - but that may not be actually true. But the
integer is pretty flexible, we are only really using low two bits now).

We start out with three handlers:

0: Legacy - just jumps the to fixup IP
1: Fault - provide the trap number in %ax to the fixup code
2: Cleaned up legacy for the uaccess error hack

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 Documentation/x86/exception-tables.txt | 34 ++++++++++++++
 arch/x86/include/asm/asm.h             | 44 +++++++++++-------
 arch/x86/include/asm/uaccess.h         | 13 +++---
 arch/x86/kernel/kprobes/core.c         |  2 +-
 arch/x86/kernel/traps.c                |  6 +--
 arch/x86/mm/extable.c                  | 84 ++++++++++++++++++++++------------
 arch/x86/mm/fault.c                    |  2 +-
 scripts/sortextable.c                  | 30 ++++++++++++
 8 files changed, 160 insertions(+), 55 deletions(-)

diff --git a/Documentation/x86/exception-tables.txt b/Documentation/x86/exception-tables.txt
index 32901aa36f0a..340a6f5dc99b 100644
--- a/Documentation/x86/exception-tables.txt
+++ b/Documentation/x86/exception-tables.txt
@@ -290,3 +290,37 @@ Due to the way that the exception table is built and needs to be ordered,
 only use exceptions for code in the .text section.  Any other section
 will cause the exception table to not be sorted correctly, and the
 exceptions will fail.
+
+Things changed when 64-bit support was added to x86 Linux. Rather than
+double the size of the exception table by expanding the two entries
+from 32-bits to 64 bits, a clever trick was used to store addreesses
+as relative offsets from the table itself. The assembly code changed
+from:
+	.long 1b,3b
+to:
+        .long (from) - .
+        .long (to) - .
+and the C-code that uses these values converts back to absolute addresses
+like this:
+	ex_insn_addr(const struct exception_table_entry *x)
+	{
+		return (unsigned long)&x->insn + x->insn;
+	}
+
+In v4.5 the exception table entry was given a new field "handler".
+This is also 32-bits wide and contains an index into an array of
+handler functions that can perform specific operations in addition
+to re-writing the instruction pointer to jump to the fixup location.
+Initially there are three such functions:
+
+0) int ex_handler_default(const struct exception_table_entry *fixup,
+   This is legacy case that just jumps to the fixup code
+1) int ex_handler_fault(const struct exception_table_entry *fixup,
+   This case provides the fault number of the trap that occurred at
+   entry->insn. It is used to distinguish page faults from machine
+   check.
+2) int ex_handler_ext(const struct exception_table_entry *fixup,
+   This case is used to for uaccess_err ... we need to set a flag
+   in the task structure. Before the handler functions existed this
+   case was handled by adding a large offset to the fixup to tag
+   it as special.
diff --git a/arch/x86/include/asm/asm.h b/arch/x86/include/asm/asm.h
index 189679aba703..0280f5c5d160 100644
--- a/arch/x86/include/asm/asm.h
+++ b/arch/x86/include/asm/asm.h
@@ -42,21 +42,28 @@
 #define _ASM_SI		__ASM_REG(si)
 #define _ASM_DI		__ASM_REG(di)
 
+#define EXTABLE_CLASS_DEFAULT	0	/* standard uaccess fixup */
+#define EXTABLE_CLASS_FAULT	1	/* provide trap number in %ax */
+#define EXTABLE_CLASS_EX	2	/* uaccess + set uaccess_err */
+
 /* Exception table entry */
 #ifdef __ASSEMBLY__
-# define _ASM_EXTABLE(from,to)					\
+# define _ASM_EXTABLE_CLASS(from, to, class)			\
 	.pushsection "__ex_table","a" ;				\
-	.balign 8 ;						\
+	.balign 4 ;						\
 	.long (from) - . ;					\
 	.long (to) - . ;					\
+	.long (class) ;						\
 	.popsection
 
-# define _ASM_EXTABLE_EX(from,to)				\
-	.pushsection "__ex_table","a" ;				\
-	.balign 8 ;						\
-	.long (from) - . ;					\
-	.long (to) - . + 0x7ffffff0 ;				\
-	.popsection
+# define _ASM_EXTABLE(from, to)					\
+	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_DEFAULT)
+
+# define _ASM_EXTABLE_FAULT(from, to)				\
+	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_FAULT)
+
+# define _ASM_EXTABLE_EX(from, to)				\
+	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_EX)
 
 # define _ASM_NOKPROBE(entry)					\
 	.pushsection "_kprobe_blacklist","aw" ;			\
@@ -89,19 +96,24 @@
 	.endm
 
 #else
-# define _ASM_EXTABLE(from,to)					\
+# define _EXPAND_EXTABLE_CLASS(x) #x
+# define _ASM_EXTABLE_CLASS(from, to, class)			\
 	" .pushsection \"__ex_table\",\"a\"\n"			\
-	" .balign 8\n"						\
+	" .balign 4\n"						\
 	" .long (" #from ") - .\n"				\
 	" .long (" #to ") - .\n"				\
+	" .long (" _EXPAND_EXTABLE_CLASS(class) ")\n"		\
 	" .popsection\n"
 
-# define _ASM_EXTABLE_EX(from,to)				\
-	" .pushsection \"__ex_table\",\"a\"\n"			\
-	" .balign 8\n"						\
-	" .long (" #from ") - .\n"				\
-	" .long (" #to ") - . + 0x7ffffff0\n"			\
-	" .popsection\n"
+# define _ASM_EXTABLE(from, to)					\
+	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_DEFAULT)
+
+# define _ASM_EXTABLE_FAULT(from, to)				\
+	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_FAULT)
+
+# define _ASM_EXTABLE_EX(from, to)				\
+	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_EX)
+
 /* For C file, we already have NOKPROBE_SYMBOL macro */
 #endif
 
diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index 09b1b0ab94b7..315d1423377c 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -91,11 +91,11 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
 
 /*
  * The exception table consists of pairs of addresses relative to the
- * exception table enty itself: the first is the address of an
- * instruction that is allowed to fault, and the second is the address
- * at which the program should continue.  No registers are modified,
- * so it is entirely up to the continuation code to figure out what to
- * do.
+ * exception table enty itself followed by an integer. The first address
+ * is of an instruction that is allowed to fault, the second is the target
+ * at which the program should continue. The integer is an index into an
+ * array of handler functions to deal with the fault referenced by the
+ * instruction in the first field.
  *
  * All the routines below use bits of fixup code that are out of line
  * with the main instruction path.  This means when everything is well,
@@ -105,12 +105,13 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
 
 struct exception_table_entry {
 	int insn, fixup;
+	u32 handler;
 };
 /* This is not the generic standard exception_table_entry format */
 #define ARCH_HAS_SORT_EXTABLE
 #define ARCH_HAS_SEARCH_EXTABLE
 
-extern int fixup_exception(struct pt_regs *regs);
+extern int fixup_exception(struct pt_regs *regs, int trapnr);
 extern int early_fixup_exception(unsigned long *ip);
 
 /*
diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index 1deffe6cc873..0f05deeff5ce 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -988,7 +988,7 @@ int kprobe_fault_handler(struct pt_regs *regs, int trapnr)
 		 * In case the user-specified fault handler returned
 		 * zero, try to fix up.
 		 */
-		if (fixup_exception(regs))
+		if (fixup_exception(regs, trapnr))
 			return 1;
 
 		/*
diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
index ade185a46b1d..211c11c7bba4 100644
--- a/arch/x86/kernel/traps.c
+++ b/arch/x86/kernel/traps.c
@@ -199,7 +199,7 @@ do_trap_no_signal(struct task_struct *tsk, int trapnr, char *str,
 	}
 
 	if (!user_mode(regs)) {
-		if (!fixup_exception(regs)) {
+		if (!fixup_exception(regs, trapnr)) {
 			tsk->thread.error_code = error_code;
 			tsk->thread.trap_nr = trapnr;
 			die(str, regs, error_code);
@@ -453,7 +453,7 @@ do_general_protection(struct pt_regs *regs, long error_code)
 
 	tsk = current;
 	if (!user_mode(regs)) {
-		if (fixup_exception(regs))
+		if (fixup_exception(regs, X86_TRAP_GP))
 			return;
 
 		tsk->thread.error_code = error_code;
@@ -699,7 +699,7 @@ static void math_error(struct pt_regs *regs, int error_code, int trapnr)
 	conditional_sti(regs);
 
 	if (!user_mode(regs)) {
-		if (!fixup_exception(regs)) {
+		if (!fixup_exception(regs, trapnr)) {
 			task->thread.error_code = error_code;
 			task->thread.trap_nr = trapnr;
 			die(str, regs, error_code);
diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
index 903ec1e9c326..cfaf5feace36 100644
--- a/arch/x86/mm/extable.c
+++ b/arch/x86/mm/extable.c
@@ -3,6 +3,9 @@
 #include <linux/sort.h>
 #include <asm/uaccess.h>
 
+typedef int (*ex_handler_t)(const struct exception_table_entry *,
+			    struct pt_regs *, int);
+
 static inline unsigned long
 ex_insn_addr(const struct exception_table_entry *x)
 {
@@ -14,10 +17,39 @@ ex_fixup_addr(const struct exception_table_entry *x)
 	return (unsigned long)&x->fixup + x->fixup;
 }
 
-int fixup_exception(struct pt_regs *regs)
+static int ex_handler_default(const struct exception_table_entry *fixup,
+		       struct pt_regs *regs, int trapnr)
 {
-	const struct exception_table_entry *fixup;
-	unsigned long new_ip;
+	regs->ip = ex_fixup_addr(fixup);
+	return 1;
+}
+
+static int ex_handler_fault(const struct exception_table_entry *fixup,
+		     struct pt_regs *regs, int trapnr)
+{
+	regs->ip = ex_fixup_addr(fixup);
+	regs->ax = trapnr;
+	return 1;
+}
+
+static int ex_handler_ext(const struct exception_table_entry *fixup,
+		   struct pt_regs *regs, int trapnr)
+{
+	/* Special hack for uaccess_err */
+	current_thread_info()->uaccess_err = 1;
+	regs->ip = ex_fixup_addr(fixup);
+	return 1;
+}
+
+static ex_handler_t allhandlers[] = {
+	[EXTABLE_CLASS_DEFAULT] = ex_handler_default,
+	[EXTABLE_CLASS_FAULT] = ex_handler_fault,
+	[EXTABLE_CLASS_EX] = ex_handler_ext,
+};
+
+int fixup_exception(struct pt_regs *regs, int trapnr)
+{
+	const struct exception_table_entry *e;
 
 #ifdef CONFIG_PNPBIOS
 	if (unlikely(SEGMENT_IS_PNP_CODE(regs->cs))) {
@@ -33,42 +65,34 @@ int fixup_exception(struct pt_regs *regs)
 	}
 #endif
 
-	fixup = search_exception_tables(regs->ip);
-	if (fixup) {
-		new_ip = ex_fixup_addr(fixup);
-
-		if (fixup->fixup - fixup->insn >= 0x7ffffff0 - 4) {
-			/* Special hack for uaccess_err */
-			current_thread_info()->uaccess_err = 1;
-			new_ip -= 0x7ffffff0;
-		}
-		regs->ip = new_ip;
-		return 1;
-	}
+	e = search_exception_tables(regs->ip);
+	if (!e)
+		return 0;
 
-	return 0;
+	/* if exception table corrupted die here rather than jump into space */
+	BUG_ON(e->handler >= ARRAY_SIZE(allhandlers));
+
+	return allhandlers[e->handler](e, regs, trapnr);
 }
 
 /* Restricted version used during very early boot */
 int __init early_fixup_exception(unsigned long *ip)
 {
-	const struct exception_table_entry *fixup;
+	const struct exception_table_entry *e;
 	unsigned long new_ip;
 
-	fixup = search_exception_tables(*ip);
-	if (fixup) {
-		new_ip = ex_fixup_addr(fixup);
+	e = search_exception_tables(*ip);
+	if (!e)
+		return 0;
 
-		if (fixup->fixup - fixup->insn >= 0x7ffffff0 - 4) {
-			/* uaccess handling not supported during early boot */
-			return 0;
-		}
+	new_ip  = ex_fixup_addr(e);
 
-		*ip = new_ip;
-		return 1;
-	}
+	/* special handling not supported during early boot */
+	if (e->handler != EXTABLE_CLASS_DEFAULT)
+		return 0;
 
-	return 0;
+	*ip = new_ip;
+	return 1;
 }
 
 /*
@@ -133,6 +157,8 @@ void sort_extable(struct exception_table_entry *start,
 		i += 4;
 		p->fixup += i;
 		i += 4;
+		/* p->handler doesn't need noodling */
+		i += 4;
 	}
 
 	sort(start, finish - start, sizeof(struct exception_table_entry),
@@ -145,6 +171,8 @@ void sort_extable(struct exception_table_entry *start,
 		i += 4;
 		p->fixup -= i;
 		i += 4;
+		/* p->handler doesn't need unnoodling */
+		i += 4;
 	}
 }
 
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index eef44d9a3f77..495946c3f9dd 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -656,7 +656,7 @@ no_context(struct pt_regs *regs, unsigned long error_code,
 	int sig;
 
 	/* Are we prepared to handle this kernel fault? */
-	if (fixup_exception(regs)) {
+	if (fixup_exception(regs, X86_TRAP_PF)) {
 		/*
 		 * Any interrupt that takes a fault gets the fixup. This makes
 		 * the below recursive fault logic only apply to a faults from
diff --git a/scripts/sortextable.c b/scripts/sortextable.c
index c2423d913b46..b17b716959a4 100644
--- a/scripts/sortextable.c
+++ b/scripts/sortextable.c
@@ -209,6 +209,33 @@ static int compare_relative_table(const void *a, const void *b)
 	return 0;
 }
 
+static void x86_sort_relative_table(char *extab_image, int image_size)
+{
+	int i;
+
+	i = 0;
+	while (i < image_size) {
+		uint32_t *loc = (uint32_t *)(extab_image + i);
+
+		w(r(loc) + i, loc);
+		w(r(loc + 1) + i + 4, loc + 1);
+
+		i += sizeof(uint32_t) * 3;
+	}
+
+	qsort(extab_image, image_size / 12, 12, compare_relative_table);
+
+	i = 0;
+	while (i < image_size) {
+		uint32_t *loc = (uint32_t *)(extab_image + i);
+
+		w(r(loc) - i, loc);
+		w(r(loc + 1) - (i + 4), loc + 1);
+
+		i += sizeof(uint32_t) * 3;
+	}
+}
+
 static void sort_relative_table(char *extab_image, int image_size)
 {
 	int i;
@@ -281,6 +308,9 @@ do_file(char const *const fname)
 		break;
 	case EM_386:
 	case EM_X86_64:
+		custom_sort = x86_sort_relative_table;
+		break;
+
 	case EM_S390:
 		custom_sort = sort_relative_table;
 		break;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
