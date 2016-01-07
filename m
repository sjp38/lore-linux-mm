From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Date: Thu, 7 Jan 2016 13:11:31 +0100
Message-ID: <20160107121131.GB23768@pd.tnic>
References: <cover.1451952351.git.tony.luck@intel.com>
 <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
 <20160106123346.GC19507@pd.tnic>
 <CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
 <20160106175948.GA16647@pd.tnic>
 <CALCETrXsC9eiQ8yF555-8G88pYEms4bDsS060e24FoadAOK+kw@mail.gmail.com>
 <20160106194222.GC16647@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160106194222.GC16647@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Cc: Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>
List-Id: linux-mm.kvack.org

On Wed, Jan 06, 2016 at 08:42:22PM +0100, Borislav Petkov wrote:
> On Wed, Jan 06, 2016 at 10:07:19AM -0800, Andy Lutomirski wrote:
> > Agreed.  I just think that your current fixup_ex_handler
> > implementation needs adjustment if you do it that way.
> 
> Right, and as you just mentioned on IRC, there's also sortextable.c
> which needs adjusting. So I'll go stare at that code first to try to
> figure out what exactly is being done there...

Sorry, it took me a while to figure out all that normalization and
denormalization of the offsets sortextable.c does. And with the bigger
table of 3 ints, we need to do the sorting a bit differently. Also, the
alignment of 8 makes gas turn ".long 0" into 8 bytes worth of zeroes so
I had to do ".balign 4". Is that going to be a problem...?

With it, the exception table looks ok to me:

8e9984          35 ae 91 ff 73 d5 ff ff 00 00 00 00
8e9990          3e af 91 ff 71 d5 ff ff 00 00 00 00
8e999c          4e af 91 ff 6c d5 ff ff 00 00 00 00
8e99a8          49 af 91 ff 67 d5 ff ff 00 00 00 00
8e99b4          ab b3 91 ff 62 d5 ff ff 00 00 00 00
8e99c0          b0 b3 91 ff 5d d5 ff ff 00 00 00 00
8e99cc          e7 b3 91 ff 5b d5 ff ff 00 00 00 00
8e99d8          82 b4 91 ff 59 d5 ff ff 00 00 00 00
8e99e4          8e b9 91 ff 8e b9 91 ff d8 41 96 ff
8e99f0          8a b9 91 ff 8a b9 91 ff cc 41 96 ff
8e99fc          86 b9 91 ff 86 b9 91 ff c0 41 96 ff
8e9a08          82 b9 91 ff 82 b9 91 ff b4 41 96 ff
8e9a14          81 b9 91 ff 81 b9 91 ff a8 41 96 ff
8e9a20          7d b9 91 ff 7d b9 91 ff 9c 41 96 ff
...

the last int not 00 is the offset to ex_handler_ext(). Regarding that, I
probably should change _ASM_EXTABLE_EX() to take a @handler argument so
that Tony can pass in the ex_handler_fault() too.

Anyway, here's what I have, it boots fine in a guest.

Btw, it seems I'm coming down with the cold and all that above could be
hallucinations so please double-check me.

Thanks.

---
diff --git a/arch/x86/include/asm/asm.h b/arch/x86/include/asm/asm.h
index 189679aba703..20b638d49f24 100644
--- a/arch/x86/include/asm/asm.h
+++ b/arch/x86/include/asm/asm.h
@@ -46,16 +46,18 @@
 #ifdef __ASSEMBLY__
 # define _ASM_EXTABLE(from,to)					\
 	.pushsection "__ex_table","a" ;				\
-	.balign 8 ;						\
+	.balign 4 ;						\
 	.long (from) - . ;					\
 	.long (to) - . ;					\
+	.long 0;						\
 	.popsection
 
 # define _ASM_EXTABLE_EX(from,to)				\
 	.pushsection "__ex_table","a" ;				\
-	.balign 8 ;						\
+	.balign 4 ;						\
 	.long (from) - . ;					\
-	.long (to) - . + 0x7ffffff0 ;				\
+	.long (to) - . ;					\
+	.long ex_handler_ext - . ;				\
 	.popsection
 
 # define _ASM_NOKPROBE(entry)					\
@@ -91,16 +93,18 @@
 #else
 # define _ASM_EXTABLE(from,to)					\
 	" .pushsection \"__ex_table\",\"a\"\n"			\
-	" .balign 8\n"						\
+	" .balign 4\n"						\
 	" .long (" #from ") - .\n"				\
 	" .long (" #to ") - .\n"				\
+	" .long 0\n"						\
 	" .popsection\n"
 
 # define _ASM_EXTABLE_EX(from,to)				\
 	" .pushsection \"__ex_table\",\"a\"\n"			\
-	" .balign 8\n"						\
+	" .balign 4\n"						\
 	" .long (" #from ") - .\n"				\
-	" .long (" #to ") - . + 0x7ffffff0\n"			\
+	" .long (" #to ") - .\n"				\
+	" .long ex_handler_ext - .\n"				\
 	" .popsection\n"
 /* For C file, we already have NOKPROBE_SYMBOL macro */
 #endif
diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index 660458af425d..35d67026bfa5 100644
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
index 903ec1e9c326..e11d3b32efd4 100644
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
@@ -14,10 +16,42 @@ ex_fixup_addr(const struct exception_table_entry *x)
 	return (unsigned long)&x->fixup + x->fixup;
 }
 
-int fixup_exception(struct pt_regs *regs)
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
+{
+	/* Special hack for uaccess_err */
+	current_thread_info()->uaccess_err = 1;
+	regs->ip = ex_fixup_addr(fixup);
+	return 1;
+}
+
+inline ex_handler_t ex_fixup_handler(const struct exception_table_entry *x)
+{
+	if (!x->handler)
+		return ex_handler_default;
+
+	return (ex_handler_t)&x->handler + x->handler;
+}
+
+int fixup_exception(struct pt_regs *regs, int trapnr)
 {
-	const struct exception_table_entry *fixup;
+	const struct exception_table_entry *e;
 	unsigned long new_ip;
+	ex_handler_t handler;
 
 #ifdef CONFIG_PNPBIOS
 	if (unlikely(SEGMENT_IS_PNP_CODE(regs->cs))) {
@@ -33,42 +67,36 @@ int fixup_exception(struct pt_regs *regs)
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
+	new_ip  = ex_fixup_addr(e);
+	handler = ex_fixup_handler(e);
+
+	return handler(e, regs, trapnr);
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
+	if (handler == ex_handler_ext)
+		return 0;
 
-	return 0;
+	*ip = new_ip;
+	return 1;
 }
 
 /*
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 546fbca9621d..def6af7aef89 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -670,7 +670,7 @@ no_context(struct pt_regs *regs, unsigned long error_code,
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
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
