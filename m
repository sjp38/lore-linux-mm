Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 629946B0260
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:24:15 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 75so505809387pgf.3
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:24:15 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c2si14888608pgf.100.2017.02.01.15.24.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:24:14 -0800 (PST)
Subject: [RFC][PATCH 4/7] x86, mpx: context-switch new MPX address size MSR
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 01 Feb 2017 15:24:13 -0800
References: <20170201232408.FA486473@viggo.jf.intel.com>
In-Reply-To: <20170201232408.FA486473@viggo.jf.intel.com>
Message-Id: <20170201232413.15540F7E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave.hansen@linux.intel.com>


As mentioned in previous patches, larger address spaces mean
larger MPX tables.  But, the entire system is either entirely
using 5-level paging, or not.  We do not mix pagetable formats.

If the size of the MPX tables depended soley on the paging mode,
old binaries would break because the format of the tables changed
underneath them.  So, since CR4 never changes, but we need some
way to change the MPX table format, a new MSR is introduced:
MSR_IA32_MPX_LAX.

If we are in 5-level paging mode *and* the enable bit in this MSR
is set, the CPU will use the new, larger MPX bounds table format.
If 5-level paging is disabled, or the enable bit is clear, then
the legacy-style smaller tables will be used.

But, we might mix legacy and non-legacy binaries on the same
system, so this MSR needs to be context-switched.  Add code to
do this, along with some simple optimizations to skip the MSR
writes if the MSR does not need to be updated.

---

 b/arch/x86/include/asm/mpx.h       |   11 ++++++++
 b/arch/x86/include/asm/msr-index.h |    1 
 b/arch/x86/mm/mpx.c                |    5 ----
 b/arch/x86/mm/tlb.c                |   46 +++++++++++++++++++++++++++++++++++++
 4 files changed, 58 insertions(+), 5 deletions(-)

diff -puN arch/x86/include/asm/mpx.h~mawa-050-context-switch-msr arch/x86/include/asm/mpx.h
--- a/arch/x86/include/asm/mpx.h~mawa-050-context-switch-msr	2017-02-01 15:12:17.087186579 -0800
+++ b/arch/x86/include/asm/mpx.h	2017-02-01 15:12:17.095186939 -0800
@@ -99,6 +99,11 @@ static inline void mpx_mm_init(struct mm
 }
 void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
 		      unsigned long start, unsigned long end);
+
+static inline int mpx_bd_size_shift(struct mm_struct *mm)
+{
+	return mm->context.mpx_bd_shift;
+}
 #else
 static inline siginfo_t *mpx_generate_siginfo(struct pt_regs *regs)
 {
@@ -120,6 +125,12 @@ static inline void mpx_notify_unmap(stru
 				    unsigned long start, unsigned long end)
 {
 }
+/* Should never be called, but need stub to avoid an #ifdef */
+static inline int mpx_bd_size_shift(struct mm_struct *mm)
+{
+	WARN_ON(1);
+	return 0;
+}
 #endif /* CONFIG_X86_INTEL_MPX */
 
 #endif /* _ASM_X86_MPX_H */
diff -puN arch/x86/include/asm/msr-index.h~mawa-050-context-switch-msr arch/x86/include/asm/msr-index.h
--- a/arch/x86/include/asm/msr-index.h~mawa-050-context-switch-msr	2017-02-01 15:12:17.088186624 -0800
+++ b/arch/x86/include/asm/msr-index.h	2017-02-01 15:12:17.096186984 -0800
@@ -410,6 +410,7 @@
 #define MSR_IA32_BNDCFGS		0x00000d90
 
 #define MSR_IA32_XSS			0x00000da0
+#define MSR_IA32_MPX_LAX		0x00001000
 
 #define FEATURE_CONTROL_LOCKED				(1<<0)
 #define FEATURE_CONTROL_VMXON_ENABLED_INSIDE_SMX	(1<<1)
diff -puN arch/x86/mm/mpx.c~mawa-050-context-switch-msr arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~mawa-050-context-switch-msr	2017-02-01 15:12:17.090186714 -0800
+++ b/arch/x86/mm/mpx.c	2017-02-01 15:12:17.096186984 -0800
@@ -20,11 +20,6 @@
 #define CREATE_TRACE_POINTS
 #include <asm/trace/mpx.h>
 
-static inline int mpx_bd_size_shift(struct mm_struct *mm)
-{
-	return mm->context.mpx_bd_shift;
-}
-
 static inline unsigned long mpx_bd_size_bytes(struct mm_struct *mm)
 {
 	if (!is_64bit_mm(mm))
diff -puN arch/x86/mm/tlb.c~mawa-050-context-switch-msr arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~mawa-050-context-switch-msr	2017-02-01 15:12:17.092186804 -0800
+++ b/arch/x86/mm/tlb.c	2017-02-01 15:12:17.097187029 -0800
@@ -9,6 +9,7 @@
 
 #include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
+#include <asm/mpx.h>
 #include <asm/cache.h>
 #include <asm/apic.h>
 #include <asm/uv/uv.h>
@@ -71,6 +72,50 @@ void switch_mm(struct mm_struct *prev, s
 	local_irq_restore(flags);
 }
 
+/*
+ * The MPX tables change sizes based on the size of the virtual
+ * (aka. linear) address space.  There is an MSR to tell the CPU
+ * whether we want the legacy-style ones or the larger ones when
+ * we are running with an eXtended virtual address space.
+ */
+static inline void switch_mpx_bd(struct mm_struct *prev, struct mm_struct *next)
+{
+	/*
+	 * Note: there is one and only one bit in use in the MSR
+	 * at this time, so we do not have to be concerned with
+	 * preserving any of the other bits.  Just write 0 or 1.
+	 */
+	u32 IA32_MPX_LAX_ENABLE_MASK = 0x00000001;
+
+	/*
+	 * Avoid the MSR on CPUs without MPX, obviously:
+	 */
+	if (!cpu_feature_enabled(X86_FEATURE_MPX))
+		return;
+	/*
+	 * FIXME: do we want a check here for the 5-level paging
+	 * CR4 bit or CPUID bit, or is the mawa check below OK?
+	 * It's not obvious what would be the fastest or if it
+	 * matters.
+	 */
+
+	/*
+	 * Avoid the relatively costly MSR if we are not changing
+	 * MAWA state.  All processes not using MPX will have a
+	 * mpx_mawa_shift()=0, so we do not need to check
+	 * separately for whether MPX management is enabled.
+	 */
+	if (likely(mpx_bd_size_shift(prev) == mpx_bd_size_shift(next)))
+		return;
+
+	if (mpx_bd_size_shift(next)) {
+		wrmsr(MSR_IA32_MPX_LAX, IA32_MPX_LAX_ENABLE_MASK, 0x0);
+	} else {
+		/* clear the enable bit: */
+		wrmsr(MSR_IA32_MPX_LAX, 0x0, 0x0);
+	}
+}
+
 void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 			struct task_struct *tsk)
 {
@@ -136,6 +181,7 @@ void switch_mm_irqs_off(struct mm_struct
 		/* Load per-mm CR4 state */
 		load_mm_cr4(next);
 
+		switch_mpx_bd(prev, next);
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 		/*
 		 * Load the LDT, if the LDT is different.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
