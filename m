From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Date: Wed, 6 Jan 2016 13:33:46 +0100
Message-ID: <20160106123346.GC19507@pd.tnic>
References: <cover.1451952351.git.tony.luck@intel.com>
 <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org
List-Id: linux-mm.kvack.org

On Wed, Dec 30, 2015 at 09:59:29AM -0800, Tony Luck wrote:
> Starting with a patch from Andy Lutomirski <luto@amacapital.net>
> that used linker relocation trickery to free up a couple of bits
> in the "fixup" field of the exception table (and generalized the
> uaccess_err hack to use one of the classes).

So I still think that the other idea Andy gave with putting the handler
in the exception table is much cleaner and straightforward.

Here's a totally untested patch which at least builds here. I think this
approach is much more extensible and simpler for the price of a couple
of KBs of __ex_table size.

---
diff --git a/arch/x86/include/asm/asm.h b/arch/x86/include/asm/asm.h
index 189679aba703..43b509c88b13 100644
--- a/arch/x86/include/asm/asm.h
+++ b/arch/x86/include/asm/asm.h
@@ -44,18 +44,20 @@
 
 /* Exception table entry */
 #ifdef __ASSEMBLY__
-# define _ASM_EXTABLE(from,to)					\
+# define _ASM_EXTABLE(from,to)				\
 	.pushsection "__ex_table","a" ;				\
 	.balign 8 ;						\
 	.long (from) - . ;					\
 	.long (to) - . ;					\
+	.long 0 - .;						\
 	.popsection
 
 # define _ASM_EXTABLE_EX(from,to)				\
 	.pushsection "__ex_table","a" ;				\
 	.balign 8 ;						\
 	.long (from) - . ;					\
-	.long (to) - . + 0x7ffffff0 ;				\
+	.long (to) - . ;					\
+	.long ex_handler_ext - . ;				\
 	.popsection
 
 # define _ASM_NOKPROBE(entry)					\
@@ -94,13 +96,14 @@
 	" .balign 8\n"						\
 	" .long (" #from ") - .\n"				\
 	" .long (" #to ") - .\n"				\
+	" .long 0 - .\n"					\
 	" .popsection\n"
 
 # define _ASM_EXTABLE_EX(from,to)				\
 	" .pushsection \"__ex_table\",\"a\"\n"			\
 	" .balign 8\n"						\
 	" .long (" #from ") - .\n"				\
-	" .long (" #to ") - . + 0x7ffffff0\n"			\
+	" .long ex_handler_ext - .\n"				\
 	" .popsection\n"
 /* For C file, we already have NOKPROBE_SYMBOL macro */
 #endif
diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index 09b1b0ab94b7..22b49c3b311a 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -104,13 +104,13 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
  */
 
 struct exception_table_entry {
-	int insn, fixup;
+	int insn, fixup, handler;
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
index 903ec1e9c326..191f4b7d1d2d 100644
--- a/arch/x86/mm/extable.c
+++ b/arch/x86/mm/extable.c
@@ -3,6 +3,8 @@
 #include <linux/sort.h>
 #include <asm/uaccess.h>
 
+typedef int (*ex_handler_t)(const struct exception_table_entry *, struct pt_regs *, int);
+
 static inline unsigned long
 ex_insn_addr(const struct exception_table_entry *x)
 {
@@ -14,10 +16,39 @@ ex_fixup_addr(const struct exception_table_entry *x)
 	return (unsigned long)&x->fixup + x->fixup;
 }
 
-int fixup_exception(struct pt_regs *regs)
+inline ex_handler_t ex_fixup_handler(const struct exception_table_entry *x)
+{
+	return (ex_handler_t)&x->handler + x->handler;
+}
+
+int ex_handler_default(const struct exception_table_entry *fixup,
+		       struct pt_regs *regs, int trapnr)
+{
+	regs->ip = ex_fixup_addr(fixup);
+	return 1;
+}
+
+int ex_handler_fault(const struct exception_table_entry *fixup,
+		     struct pt_regs *regs, int trapnr)
+{
+	regs->ip = ex_fixup_addr(fixup);
+	regs->ax = trapnr;
+	return 1;
+}
+int ex_handler_ext(const struct exception_table_entry *fixup,
+		   struct pt_regs *regs, int trapnr)
 {
-	const struct exception_table_entry *fixup;
+	/* Special hack for uaccess_err */
+	current_thread_info()->uaccess_err = 1;
+	regs->ip = ex_fixup_addr(fixup);
+	return 1;
+}
+
+int fixup_exception(struct pt_regs *regs, int trapnr)
+{
+	const struct exception_table_entry *e;
 	unsigned long new_ip;
+	ex_handler_t handler;
 
 #ifdef CONFIG_PNPBIOS
 	if (unlikely(SEGMENT_IS_PNP_CODE(regs->cs))) {
@@ -33,42 +64,40 @@ int fixup_exception(struct pt_regs *regs)
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
+
+	new_ip  = ex_fixup_addr(e);
+	handler = ex_fixup_handler(e);
+
+	if (!handler)
+		handler = ex_handler_default;
+
+	return handler(e, regs, trapnr);
 
-	return 0;
 }
 
 /* Restricted version used during very early boot */
 int __init early_fixup_exception(unsigned long *ip)
 {
-	const struct exception_table_entry *fixup;
+	const struct exception_table_entry *e;
 	unsigned long new_ip;
+	ex_handler_t handler;
 
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
+	handler = ex_fixup_handler(e);
 
-		*ip = new_ip;
-		return 1;
-	}
+	/* uaccess handling not supported during early boot */
+	if (handler && handler == ex_handler_ext)
+		return 0;
 
-	return 0;
+	*ip = new_ip;
+	return 1;
 }
 
 /*
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

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
