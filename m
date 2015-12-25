From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
Date: Fri, 25 Dec 2015 12:49:38 +0100
Message-ID: <20151225114937.GA862@pd.tnic>
References: <20151224214632.GF4128@pd.tnic>
 <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ce84932301823b991b9b439a4715be93f1912c05.1451002295.git.tony.luck@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org
List-Id: linux-mm.kvack.org

On Tue, Dec 15, 2015 at 05:30:49PM -0800, Tony Luck wrote:
> Using __copy_user_nocache() as inspiration create a memory copy
> routine for use by kernel code with annotations to allow for
> recovery from machine checks.
> 
> Notes:
> 1) We align the source address rather than the destination. This
>    means we never have to deal with a memory read that spans two
>    cache lines ... so we can provide a precise indication of
>    where the error occurred without having to re-execute at
>    a byte-by-byte level to find the exact spot like the original
>    did.
> 2) We 'or' BIT(63) into the return if the copy failed because of
>    a machine check. If we failed during a copy from user space
>    because the user provided a bad address, then we just return
>    then number of bytes not copied like other copy_from_user
>    functions.
> 3) This code doesn't play any cache games. Future functions can
>    use non-temporal loads/stores to meet needs of different callers.
> 4) Provide helpful macros to decode the return value.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
> Boris: This version has all the return options coded.
> 	return 0; /* SUCCESS */
> 	return remain_bytes | (1ul << 63); /* failed because of machine check */
> 	return remain_bytes; /* failed because of invalid source address */

Ok, how about a much simpler approach and finally getting rid of that
bit 63? :-)

Here's what we could do, it is totally untested but at least it builds
here (full patch below).

So first we define __mcsafe_copy to return two u64 values, or two
int values or whatever... Bottomline is, we return 2 values with
remain_bytes in %rdx and the actual error in %rax.

+struct mcsafe_ret {
+       u64 ret;
+       u64 remain;
+};
+
+struct mcsafe_ret __mcsafe_copy(void *dst, const void __user *src, unsigned size);

Then, in fixup_exception()/fixup_mcexception(), we set the *respective*
regs->ax (which is mcsafe_ret.ret) depending on which function is fixing
up the exception. I've made it return -EINVAL and -EFAULT respectively
but those are arbitrary.

We detect that we're in __mcsafe_copy() by using its start and a
previously defined end label. I've done this in order to get rid of the
mce-specific exception tables. Mind you, this is still precise enough
since we're using the _ASM_EXTABLE entries from __mcsafe_copy.

And this approach gets rid of those mce-specific exception tables, bit
63, makes __mcsafe_copy simpler, you name it... :-)

Thoughts?

---
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index adb28a2dab44..efef4d72674c 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1021,6 +1021,16 @@ config X86_MCE_INJECT
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
diff --git a/arch/x86/include/asm/mce.h b/arch/x86/include/asm/mce.h
index 2ea4527e462f..9c5371d1069b 100644
--- a/arch/x86/include/asm/mce.h
+++ b/arch/x86/include/asm/mce.h
@@ -287,4 +287,13 @@ struct cper_sec_mem_err;
 extern void apei_mce_report_mem_error(int corrected,
 				      struct cper_sec_mem_err *mem_err);
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+int fixup_mcexception(struct pt_regs *regs);
+#else
+static inline int fixup_mcexception(struct pt_regs *regs)
+{
+	return 0;
+}
+#endif
+
 #endif /* _ASM_X86_MCE_H */
diff --git a/arch/x86/include/asm/string_64.h b/arch/x86/include/asm/string_64.h
index ff8b9a17dc4b..6b6431797749 100644
--- a/arch/x86/include/asm/string_64.h
+++ b/arch/x86/include/asm/string_64.h
@@ -78,6 +78,16 @@ int strcmp(const char *cs, const char *ct);
 #define memset(s, c, n) __memset(s, c, n)
 #endif
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+struct mcsafe_ret {
+	u64 ret;
+	u64 remain;
+};
+
+struct mcsafe_ret __mcsafe_copy(void *dst, const void __user *src, unsigned size);
+extern void __mcsafe_copy_end(void);
+#endif
+
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_X86_STRING_64_H */
diff --git a/arch/x86/kernel/cpu/mcheck/mce-internal.h b/arch/x86/kernel/cpu/mcheck/mce-internal.h
index 547720efd923..e8a2c8067fcb 100644
--- a/arch/x86/kernel/cpu/mcheck/mce-internal.h
+++ b/arch/x86/kernel/cpu/mcheck/mce-internal.h
@@ -80,4 +80,12 @@ static inline int apei_clear_mce(u64 record_id)
 }
 #endif
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+static inline bool mce_in_kernel_recov(unsigned long addr)
+{
+	return (addr >= (unsigned long)__mcsafe_copy &&
+		addr <= (unsigned long)__mcsafe_copy_end);
+}
+#endif
+
 void mce_inject_log(struct mce *m);
diff --git a/arch/x86/kernel/cpu/mcheck/mce-severity.c b/arch/x86/kernel/cpu/mcheck/mce-severity.c
index 9c682c222071..a51f0d28cc06 100644
--- a/arch/x86/kernel/cpu/mcheck/mce-severity.c
+++ b/arch/x86/kernel/cpu/mcheck/mce-severity.c
@@ -29,7 +29,7 @@
  * panic situations)
  */
 
-enum context { IN_KERNEL = 1, IN_USER = 2 };
+enum context { IN_KERNEL = 1, IN_USER = 2, IN_KERNEL_RECOV = 3 };
 enum ser { SER_REQUIRED = 1, NO_SER = 2 };
 enum exception { EXCP_CONTEXT = 1, NO_EXCP = 2 };
 
@@ -48,6 +48,7 @@ static struct severity {
 #define MCESEV(s, m, c...) { .sev = MCE_ ## s ## _SEVERITY, .msg = m, ## c }
 #define  KERNEL		.context = IN_KERNEL
 #define  USER		.context = IN_USER
+#define  KERNEL_RECOV	.context = IN_KERNEL_RECOV
 #define  SER		.ser = SER_REQUIRED
 #define  NOSER		.ser = NO_SER
 #define  EXCP		.excp = EXCP_CONTEXT
@@ -87,6 +88,10 @@ static struct severity {
 		EXCP, KERNEL, MCGMASK(MCG_STATUS_RIPV, 0)
 		),
 	MCESEV(
+		PANIC, "In kernel and no restart IP",
+		EXCP, KERNEL_RECOV, MCGMASK(MCG_STATUS_RIPV, 0)
+		),
+	MCESEV(
 		DEFERRED, "Deferred error",
 		NOSER, MASK(MCI_STATUS_UC|MCI_STATUS_DEFERRED|MCI_STATUS_POISON, MCI_STATUS_DEFERRED)
 		),
@@ -123,6 +128,11 @@ static struct severity {
 		MCGMASK(MCG_STATUS_RIPV|MCG_STATUS_EIPV, MCG_STATUS_RIPV)
 		),
 	MCESEV(
+		AR, "Action required: data load in error recoverable area of kernel",
+		SER, MASK(MCI_STATUS_OVER|MCI_UC_SAR|MCI_ADDR|MCACOD, MCI_UC_SAR|MCI_ADDR|MCACOD_DATA),
+		KERNEL_RECOV
+		),
+	MCESEV(
 		AR, "Action required: data load error in a user process",
 		SER, MASK(MCI_STATUS_OVER|MCI_UC_SAR|MCI_ADDR|MCACOD, MCI_UC_SAR|MCI_ADDR|MCACOD_DATA),
 		USER
@@ -170,6 +180,9 @@ static struct severity {
 		)	/* always matches. keep at end */
 };
 
+#define mc_recoverable(mcg) (((mcg) & (MCG_STATUS_RIPV|MCG_STATUS_EIPV)) == \
+				(MCG_STATUS_RIPV|MCG_STATUS_EIPV))
+
 /*
  * If mcgstatus indicated that ip/cs on the stack were
  * no good, then "m->cs" will be zero and we will have
@@ -183,7 +196,11 @@ static struct severity {
  */
 static int error_context(struct mce *m)
 {
-	return ((m->cs & 3) == 3) ? IN_USER : IN_KERNEL;
+	if ((m->cs & 3) == 3)
+		return IN_USER;
+	if (mc_recoverable(m->mcgstatus) && mce_in_kernel_recov(m->ip))
+		return IN_KERNEL_RECOV;
+	return IN_KERNEL;
 }
 
 /*
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index a006f4cd792b..3dc2cbc3f62d 100644
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
@@ -961,6 +962,20 @@ static void mce_clear_state(unsigned long *toclear)
 	}
 }
 
+static int do_memory_failure(struct mce *m)
+{
+	int flags = MF_ACTION_REQUIRED;
+	int ret;
+
+	pr_err("Uncorrected hardware memory error in user-access at %llx", m->addr);
+	if (!(m->mcgstatus & MCG_STATUS_RIPV))
+		flags |= MF_MUST_KILL;
+	ret = memory_failure(m->addr >> PAGE_SHIFT, MCE_VECTOR, flags);
+	if (ret)
+		pr_err("Memory error not recovered");
+	return ret;
+}
+
 /*
  * The actual machine check handler. This only handles real
  * exceptions when something got corrupted coming in through int 18.
@@ -998,8 +1013,6 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 	DECLARE_BITMAP(toclear, MAX_NR_BANKS);
 	DECLARE_BITMAP(valid_banks, MAX_NR_BANKS);
 	char *msg = "Unknown";
-	u64 recover_paddr = ~0ull;
-	int flags = MF_ACTION_REQUIRED;
 	int lmce = 0;
 
 	/* If this CPU is offline, just bail out. */
@@ -1136,22 +1149,13 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 	}
 
 	/*
-	 * At insane "tolerant" levels we take no action. Otherwise
-	 * we only die if we have no other choice. For less serious
-	 * issues we try to recover, or limit damage to the current
-	 * process.
+	 * If tolerant is at an insane level we drop requests to kill
+	 * processes and continue even when there is no way out.
 	 */
-	if (cfg->tolerant < 3) {
-		if (no_way_out)
-			mce_panic("Fatal machine check on current CPU", &m, msg);
-		if (worst == MCE_AR_SEVERITY) {
-			recover_paddr = m.addr;
-			if (!(m.mcgstatus & MCG_STATUS_RIPV))
-				flags |= MF_MUST_KILL;
-		} else if (kill_it) {
-			force_sig(SIGBUS, current);
-		}
-	}
+	if (cfg->tolerant == 3)
+		kill_it = 0;
+	else if (no_way_out)
+		mce_panic("Fatal machine check on current CPU", &m, msg);
 
 	if (worst > 0)
 		mce_report_event(regs);
@@ -1159,25 +1163,24 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 out:
 	sync_core();
 
-	if (recover_paddr == ~0ull)
-		goto done;
+	if (worst != MCE_AR_SEVERITY && !kill_it)
+		goto out_ist;
 
-	pr_err("Uncorrected hardware memory error in user-access at %llx",
-		 recover_paddr);
-	/*
-	 * We must call memory_failure() here even if the current process is
-	 * doomed. We still need to mark the page as poisoned and alert any
-	 * other users of the page.
-	 */
-	ist_begin_non_atomic(regs);
-	local_irq_enable();
-	if (memory_failure(recover_paddr >> PAGE_SHIFT, MCE_VECTOR, flags) < 0) {
-		pr_err("Memory error not recovered");
-		force_sig(SIGBUS, current);
+	/* Fault was in user mode and we need to take some action */
+	if ((m.cs & 3) == 3) {
+		ist_begin_non_atomic(regs);
+		local_irq_enable();
+
+		if (kill_it || do_memory_failure(&m))
+			force_sig(SIGBUS, current);
+		local_irq_disable();
+		ist_end_non_atomic();
+	} else {
+		if (!fixup_mcexception(regs))
+			mce_panic("Failed kernel mode recovery", &m, NULL);
 	}
-	local_irq_disable();
-	ist_end_non_atomic();
-done:
+
+out_ist:
 	ist_exit(regs);
 }
 EXPORT_SYMBOL_GPL(do_machine_check);
diff --git a/arch/x86/kernel/x8664_ksyms_64.c b/arch/x86/kernel/x8664_ksyms_64.c
index a0695be19864..3d42d0ef3333 100644
--- a/arch/x86/kernel/x8664_ksyms_64.c
+++ b/arch/x86/kernel/x8664_ksyms_64.c
@@ -37,6 +37,10 @@ EXPORT_SYMBOL(__copy_user_nocache);
 EXPORT_SYMBOL(_copy_from_user);
 EXPORT_SYMBOL(_copy_to_user);
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+EXPORT_SYMBOL(__mcsafe_copy);
+#endif
+
 EXPORT_SYMBOL(copy_page);
 EXPORT_SYMBOL(clear_page);
 
diff --git a/arch/x86/lib/memcpy_64.S b/arch/x86/lib/memcpy_64.S
index 16698bba87de..2fad83c314cc 100644
--- a/arch/x86/lib/memcpy_64.S
+++ b/arch/x86/lib/memcpy_64.S
@@ -177,3 +177,140 @@ ENTRY(memcpy_orig)
 .Lend:
 	retq
 ENDPROC(memcpy_orig)
+
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+/*
+ * __mcsafe_copy - memory copy with machine check exception handling
+ * Note that we only catch machine checks when reading the source addresses.
+ * Writes to target are posted and don't generate machine checks.
+ */
+ENTRY(__mcsafe_copy)
+	cmpl $8,%edx
+	jb 20f		/* less then 8 bytes, go to byte copy loop */
+
+	/* check for bad alignment of source */
+	movl %esi,%ecx
+	andl $7,%ecx
+	jz 102f				/* already aligned */
+	subl $8,%ecx
+	negl %ecx
+	subl %ecx,%edx
+0:	movb (%rsi),%al
+	movb %al,(%rdi)
+	incq %rsi
+	incq %rdi
+	decl %ecx
+	jnz 0b
+102:
+	movl %edx,%ecx
+	andl $63,%edx
+	shrl $6,%ecx
+	jz 17f
+1:	movq (%rsi),%r8
+2:	movq 1*8(%rsi),%r9
+3:	movq 2*8(%rsi),%r10
+4:	movq 3*8(%rsi),%r11
+	mov %r8,(%rdi)
+	mov %r9,1*8(%rdi)
+	mov %r10,2*8(%rdi)
+	mov %r11,3*8(%rdi)
+9:	movq 4*8(%rsi),%r8
+10:	movq 5*8(%rsi),%r9
+11:	movq 6*8(%rsi),%r10
+12:	movq 7*8(%rsi),%r11
+	mov %r8,4*8(%rdi)
+	mov %r9,5*8(%rdi)
+	mov %r10,6*8(%rdi)
+	mov %r11,7*8(%rdi)
+	leaq 64(%rsi),%rsi
+	leaq 64(%rdi),%rdi
+	decl %ecx
+	jnz 1b
+17:	movl %edx,%ecx
+	andl $7,%edx
+	shrl $3,%ecx
+	jz 20f
+18:	movq (%rsi),%r8
+	mov %r8,(%rdi)
+	leaq 8(%rsi),%rsi
+	leaq 8(%rdi),%rdi
+	decl %ecx
+	jnz 18b
+20:	andl %edx,%edx
+	jz 23f
+	movl %edx,%ecx
+21:	movb (%rsi),%al
+	movb %al,(%rdi)
+	incq %rsi
+	incq %rdi
+	decl %ecx
+	jnz 21b
+23:	xorq %rax, %rax
+	xorq %rdx, %rdx
+	sfence
+	/* copy successful. return 0 */
+	ret
+
+	.section .fixup,"ax"
+	/* fixups for machine check */
+30:
+	add %ecx,%edx
+	jmp 100f
+31:
+	shl $6,%ecx
+	add %ecx,%edx
+	jmp 100f
+32:
+	shl $6,%ecx
+	lea -8(%ecx,%edx),%edx
+	jmp 100f
+33:
+	shl $6,%ecx
+	lea -16(%ecx,%edx),%edx
+	jmp 100f
+34:
+	shl $6,%ecx
+	lea -24(%ecx,%edx),%edx
+	jmp 100f
+35:
+	shl $6,%ecx
+	lea -32(%ecx,%edx),%edx
+	jmp 100f
+36:
+	shl $6,%ecx
+	lea -40(%ecx,%edx),%edx
+	jmp 100f
+37:
+	shl $6,%ecx
+	lea -48(%ecx,%edx),%edx
+	jmp 100f
+38:
+	shl $6,%ecx
+	lea -56(%ecx,%edx),%edx
+	jmp 100f
+39:
+	lea (%rdx,%rcx,8),%rdx
+	jmp 100f
+40:
+	mov %ecx,%edx
+100:
+	sfence
+
+	/* %rax prepared in fixup_exception()/fixup_mcexception() */
+	ret
+GLOBAL(__mcsafe_copy_end)
+	.previous
+
+	_ASM_EXTABLE(0b,30b)
+	_ASM_EXTABLE(1b,31b)
+	_ASM_EXTABLE(2b,32b)
+	_ASM_EXTABLE(3b,33b)
+	_ASM_EXTABLE(4b,34b)
+	_ASM_EXTABLE(9b,35b)
+	_ASM_EXTABLE(10b,36b)
+	_ASM_EXTABLE(11b,37b)
+	_ASM_EXTABLE(12b,38b)
+	_ASM_EXTABLE(18b,39b)
+	_ASM_EXTABLE(21b,40b)
+ENDPROC(__mcsafe_copy)
+#endif
diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
index 903ec1e9c326..d0f5600df5e5 100644
--- a/arch/x86/mm/extable.c
+++ b/arch/x86/mm/extable.c
@@ -2,6 +2,7 @@
 #include <linux/spinlock.h>
 #include <linux/sort.h>
 #include <asm/uaccess.h>
+#include <asm/mce.h>
 
 static inline unsigned long
 ex_insn_addr(const struct exception_table_entry *x)
@@ -37,11 +38,18 @@ int fixup_exception(struct pt_regs *regs)
 	if (fixup) {
 		new_ip = ex_fixup_addr(fixup);
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+		if (regs->ip >= (unsigned long)__mcsafe_copy &&
+		    regs->ip <= (unsigned long)__mcsafe_copy_end)
+			regs->ax = -EFAULT;
+#endif
+
 		if (fixup->fixup - fixup->insn >= 0x7ffffff0 - 4) {
 			/* Special hack for uaccess_err */
 			current_thread_info()->uaccess_err = 1;
 			new_ip -= 0x7ffffff0;
 		}
+
 		regs->ip = new_ip;
 		return 1;
 	}
@@ -49,6 +57,29 @@ int fixup_exception(struct pt_regs *regs)
 	return 0;
 }
 
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+int fixup_mcexception(struct pt_regs *regs)
+{
+	const struct exception_table_entry *fixup;
+	unsigned long new_ip;
+
+	fixup = search_exception_tables(regs->ip);
+	if (fixup) {
+		new_ip = ex_fixup_addr(fixup);
+
+		if (regs->ip >= (unsigned long)__mcsafe_copy &&
+		    regs->ip <= (unsigned long)__mcsafe_copy_end)
+			regs->ax = -EINVAL;
+
+		regs->ip = new_ip;
+
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

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
