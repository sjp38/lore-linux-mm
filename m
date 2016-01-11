Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3D62C828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 19:25:40 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id e65so36144021pfe.0
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 16:25:40 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id rk9si35268467pab.31.2016.01.10.16.25.39
        for <linux-mm@kvack.org>;
        Sun, 10 Jan 2016 16:25:39 -0800 (PST)
Date: Sun, 10 Jan 2016 16:25:38 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v8 1/3] x86: Expand exception table to allow new handling
 options
Message-ID: <20160111002538.GA23027@agluck-desk.sc.intel.com>
References: <cover.1452297867.git.tony.luck@intel.com>
 <3a259f1cce4a3c309c2f81df715f8c2c9bb80015.1452297867.git.tony.luck@intel.com>
 <CALCETrURssJHn42dXsEJbJbr=VGPnV1U_-UkYEZ48SPUSbUDww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrURssJHn42dXsEJbJbr=VGPnV1U_-UkYEZ48SPUSbUDww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, Brian Gerst <brgerst@gmail.com>

On Fri, Jan 08, 2016 at 05:52:54PM -0800, Andy Lutomirski wrote:
> I think I preferred the relative function pointer approach.
> 
> Also, I think it would be nicer if the machine check code would invoke
> the handler regardless of which handler (or class) is selected.  Then
> the handlers that don't want to handle #MC can just reject them.
> 
> Also, can you make the handlers return bool instead of int?

This patch is currently on top of the 3 patches ... just to check
direction. Obviously it needs to be folded into parts 1 & 2.
[and my Documentation changes updated]

So function pointers and bool returns are here.  Only bit that
I think Andy won't be "happy" with is ex_has_fault_handler().
But perhaps I've worn him down so he can be resigned to this
as a necessary evil until the machine check handler gets a
major overhaul.

Brian: You started to say you wanted the int fields, but then
looked like you took it back at you'd only need a half dozen
or so functions to cover all the possible "mov -FAULT,reg"
cases that you'd like to optimize.

-Tony

diff --git a/arch/x86/include/asm/asm.h b/arch/x86/include/asm/asm.h
index 0280f5c5d160..f5063b6659eb 100644
--- a/arch/x86/include/asm/asm.h
+++ b/arch/x86/include/asm/asm.h
@@ -42,28 +42,24 @@
 #define _ASM_SI		__ASM_REG(si)
 #define _ASM_DI		__ASM_REG(di)
 
-#define EXTABLE_CLASS_DEFAULT	0	/* standard uaccess fixup */
-#define EXTABLE_CLASS_FAULT	1	/* provide trap number in %ax */
-#define EXTABLE_CLASS_EX	2	/* uaccess + set uaccess_err */
-
 /* Exception table entry */
 #ifdef __ASSEMBLY__
-# define _ASM_EXTABLE_CLASS(from, to, class)			\
+# define _ASM_EXTABLE_HANDLE(from, to, handler)			\
 	.pushsection "__ex_table","a" ;				\
 	.balign 4 ;						\
 	.long (from) - . ;					\
 	.long (to) - . ;					\
-	.long (class) ;						\
+	.long (handler) - . ;					\
 	.popsection
 
 # define _ASM_EXTABLE(from, to)					\
-	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_DEFAULT)
+	_ASM_EXTABLE_HANDLE(from, to, ex_handler_default)
 
 # define _ASM_EXTABLE_FAULT(from, to)				\
-	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_FAULT)
+	_ASM_EXTABLE_HANDLE(from, to, ex_handler_fault)
 
 # define _ASM_EXTABLE_EX(from, to)				\
-	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_EX)
+	_ASM_EXTABLE_HANDLE(from, to, ex_handler_ext)
 
 # define _ASM_NOKPROBE(entry)					\
 	.pushsection "_kprobe_blacklist","aw" ;			\
@@ -96,23 +92,23 @@
 	.endm
 
 #else
-# define _EXPAND_EXTABLE_CLASS(x) #x
-# define _ASM_EXTABLE_CLASS(from, to, class)			\
+# define _EXPAND_EXTABLE_HANDLE(x) #x
+# define _ASM_EXTABLE_HANDLE(from, to, handler)			\
 	" .pushsection \"__ex_table\",\"a\"\n"			\
 	" .balign 4\n"						\
 	" .long (" #from ") - .\n"				\
 	" .long (" #to ") - .\n"				\
-	" .long (" _EXPAND_EXTABLE_CLASS(class) ")\n"		\
+	" .long (" _EXPAND_EXTABLE_HANDLE(handler) ") - .\n"	\
 	" .popsection\n"
 
 # define _ASM_EXTABLE(from, to)					\
-	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_DEFAULT)
+	_ASM_EXTABLE_HANDLE(from, to, ex_handler_default)
 
 # define _ASM_EXTABLE_FAULT(from, to)				\
-	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_FAULT)
+	_ASM_EXTABLE_HANDLE(from, to, ex_handler_fault)
 
 # define _ASM_EXTABLE_EX(from, to)				\
-	_ASM_EXTABLE_CLASS(from, to, EXTABLE_CLASS_EX)
+	_ASM_EXTABLE_HANDLE(from, to, ex_handler_ext)
 
 /* For C file, we already have NOKPROBE_SYMBOL macro */
 #endif
diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index 315d1423377c..565b382b2f35 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -104,14 +104,14 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
  */
 
 struct exception_table_entry {
-	int insn, fixup;
-	u32 handler;
+	int insn, fixup, handler;
 };
 /* This is not the generic standard exception_table_entry format */
 #define ARCH_HAS_SORT_EXTABLE
 #define ARCH_HAS_SEARCH_EXTABLE
 
 extern int fixup_exception(struct pt_regs *regs, int trapnr);
+extern bool ex_has_fault_handler(unsigned long ip);
 extern int early_fixup_exception(unsigned long *ip);
 
 /*
diff --git a/arch/x86/kernel/cpu/mcheck/mce-severity.c b/arch/x86/kernel/cpu/mcheck/mce-severity.c
index e87aa060977c..bca8b3936740 100644
--- a/arch/x86/kernel/cpu/mcheck/mce-severity.c
+++ b/arch/x86/kernel/cpu/mcheck/mce-severity.c
@@ -185,15 +185,6 @@ static struct severity {
 #define mc_recoverable(mcg) (((mcg) & (MCG_STATUS_RIPV|MCG_STATUS_EIPV)) == \
 				(MCG_STATUS_RIPV|MCG_STATUS_EIPV))
 
-static inline bool mce_in_kernel_recov(unsigned long addr)
-{
-	const struct exception_table_entry *fixup;
-
-	fixup = search_exception_tables(addr);
-
-	return fixup && fixup->handler == EXTABLE_CLASS_FAULT;
-}
-
 /*
  * If mcgstatus indicated that ip/cs on the stack were
  * no good, then "m->cs" will be zero and we will have
@@ -209,7 +200,7 @@ static int error_context(struct mce *m)
 {
 	if ((m->cs & 3) == 3)
 		return IN_USER;
-	if (mc_recoverable(m->mcgstatus) && mce_in_kernel_recov(m->ip))
+	if (mc_recoverable(m->mcgstatus) && ex_has_fault_handler(m->ip))
 		return IN_KERNEL_RECOV;
 	return IN_KERNEL;
 }
diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
index cfaf5feace36..e1a996bc84e3 100644
--- a/arch/x86/mm/extable.c
+++ b/arch/x86/mm/extable.c
@@ -3,7 +3,7 @@
 #include <linux/sort.h>
 #include <asm/uaccess.h>
 
-typedef int (*ex_handler_t)(const struct exception_table_entry *,
+typedef bool (*ex_handler_t)(const struct exception_table_entry *,
 			    struct pt_regs *, int);
 
 static inline unsigned long
@@ -16,23 +16,30 @@ ex_fixup_addr(const struct exception_table_entry *x)
 {
 	return (unsigned long)&x->fixup + x->fixup;
 }
+static inline ex_handler_t
+ex_fixup_handler(const struct exception_table_entry *x)
+{
+	return (ex_handler_t)((unsigned long)&x->handler + x->handler);
+}
 
-static int ex_handler_default(const struct exception_table_entry *fixup,
+bool ex_handler_default(const struct exception_table_entry *fixup,
 		       struct pt_regs *regs, int trapnr)
 {
 	regs->ip = ex_fixup_addr(fixup);
 	return 1;
 }
+EXPORT_SYMBOL(ex_handler_default);
 
-static int ex_handler_fault(const struct exception_table_entry *fixup,
+bool ex_handler_fault(const struct exception_table_entry *fixup,
 		     struct pt_regs *regs, int trapnr)
 {
 	regs->ip = ex_fixup_addr(fixup);
 	regs->ax = trapnr;
 	return 1;
 }
+EXPORT_SYMBOL_GPL(ex_handler_fault);
 
-static int ex_handler_ext(const struct exception_table_entry *fixup,
+bool ex_handler_ext(const struct exception_table_entry *fixup,
 		   struct pt_regs *regs, int trapnr)
 {
 	/* Special hack for uaccess_err */
@@ -40,16 +47,25 @@ static int ex_handler_ext(const struct exception_table_entry *fixup,
 	regs->ip = ex_fixup_addr(fixup);
 	return 1;
 }
+EXPORT_SYMBOL(ex_handler_ext);
+
+bool ex_has_fault_handler(unsigned long ip)
+{
+	const struct exception_table_entry *e;
+	ex_handler_t handler;
 
-static ex_handler_t allhandlers[] = {
-	[EXTABLE_CLASS_DEFAULT] = ex_handler_default,
-	[EXTABLE_CLASS_FAULT] = ex_handler_fault,
-	[EXTABLE_CLASS_EX] = ex_handler_ext,
-};
+	e = search_exception_tables(ip);
+	if (!e)
+		return 0;
+	handler = ex_fixup_handler(e);
+
+	return handler == ex_handler_fault;
+}
 
 int fixup_exception(struct pt_regs *regs, int trapnr)
 {
 	const struct exception_table_entry *e;
+	ex_handler_t handler;
 
 #ifdef CONFIG_PNPBIOS
 	if (unlikely(SEGMENT_IS_PNP_CODE(regs->cs))) {
@@ -69,10 +85,8 @@ int fixup_exception(struct pt_regs *regs, int trapnr)
 	if (!e)
 		return 0;
 
-	/* if exception table corrupted die here rather than jump into space */
-	BUG_ON(e->handler >= ARRAY_SIZE(allhandlers));
-
-	return allhandlers[e->handler](e, regs, trapnr);
+	handler = ex_fixup_handler(e);
+	return handler(e, regs, trapnr);
 }
 
 /* Restricted version used during very early boot */
@@ -80,15 +94,17 @@ int __init early_fixup_exception(unsigned long *ip)
 {
 	const struct exception_table_entry *e;
 	unsigned long new_ip;
+	ex_handler_t handler;
 
 	e = search_exception_tables(*ip);
 	if (!e)
 		return 0;
 
 	new_ip  = ex_fixup_addr(e);
+	handler = ex_fixup_handler(e);
 
 	/* special handling not supported during early boot */
-	if (e->handler != EXTABLE_CLASS_DEFAULT)
+	if (handler != ex_handler_default)
 		return 0;
 
 	*ip = new_ip;
@@ -157,7 +173,7 @@ void sort_extable(struct exception_table_entry *start,
 		i += 4;
 		p->fixup += i;
 		i += 4;
-		/* p->handler doesn't need noodling */
+		p->handler += i;
 		i += 4;
 	}
 
@@ -171,7 +187,7 @@ void sort_extable(struct exception_table_entry *start,
 		i += 4;
 		p->fixup -= i;
 		i += 4;
-		/* p->handler doesn't need unnoodling */
+		p->handler -= i;
 		i += 4;
 	}
 }
diff --git a/scripts/sortextable.c b/scripts/sortextable.c
index b17b716959a4..7b29fb14f870 100644
--- a/scripts/sortextable.c
+++ b/scripts/sortextable.c
@@ -219,6 +219,7 @@ static void x86_sort_relative_table(char *extab_image, int image_size)
 
 		w(r(loc) + i, loc);
 		w(r(loc + 1) + i + 4, loc + 1);
+		w(r(loc + 2) + i + 8, loc + 2);
 
 		i += sizeof(uint32_t) * 3;
 	}
@@ -231,6 +232,7 @@ static void x86_sort_relative_table(char *extab_image, int image_size)
 
 		w(r(loc) - i, loc);
 		w(r(loc + 1) - (i + 4), loc + 1);
+		w(r(loc + 2) - (i + 8), loc + 2);
 
 		i += sizeof(uint32_t) * 3;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
