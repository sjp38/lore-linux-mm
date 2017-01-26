Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52B566B0260
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:40:12 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d123so75999770pfd.0
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 14:40:12 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x1si2577624pfa.171.2017.01.26.14.40.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 14:40:11 -0800 (PST)
Subject: [RFC][PATCH 4/4] x86, mpx: context-switch new MPX address size MSR
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 26 Jan 2017 14:40:10 -0800
References: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
In-Reply-To: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
Message-Id: <20170126224010.3534C154@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>


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

 b/arch/x86/include/asm/msr-index.h |    1 
 b/arch/x86/mm/tlb.c                |   42 +++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff -puN arch/x86/include/asm/msr-index.h~mawa-050-context-switch-msr arch/x86/include/asm/msr-index.h
--- a/arch/x86/include/asm/msr-index.h~mawa-050-context-switch-msr	2017-01-26 14:31:37.747902524 -0800
+++ b/arch/x86/include/asm/msr-index.h	2017-01-26 14:31:37.752902749 -0800
@@ -410,6 +410,7 @@
 #define MSR_IA32_BNDCFGS		0x00000d90
 
 #define MSR_IA32_XSS			0x00000da0
+#define MSR_IA32_MPX_LAX		0x00001000
 
 #define FEATURE_CONTROL_LOCKED				(1<<0)
 #define FEATURE_CONTROL_VMXON_ENABLED_INSIDE_SMX	(1<<1)
diff -puN arch/x86/mm/tlb.c~mawa-050-context-switch-msr arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~mawa-050-context-switch-msr	2017-01-26 14:31:37.749902614 -0800
+++ b/arch/x86/mm/tlb.c	2017-01-26 14:31:37.753902794 -0800
@@ -71,6 +71,47 @@ void switch_mm(struct mm_struct *prev, s
 	local_irq_restore(flags);
 }
 
+/*
+ * The MPX tables change sizes based on the size of the virtual
+ * (aka. linear) address space.  There is an MSR to tell the CPU
+ * whether we want the legacy-style ones or the larger ones when
+ * we are running with an eXtended virtual address space.
+ */
+static void switch_mawa(struct mm_struct *prev, struct mm_struct *next)
+{
+	/*
+	 * Note: there is one and only one bit in use in the MSR
+	 * at this time, so we do not have to be concerned with
+	 * preseving any of the other bits.  Just write 0 or 1.
+	 */
+	unsigned IA32_MPX_LAX_ENABLE_MASK = 0x00000001;
+
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
+	if (mpx_mawa_shift(prev) == mpx_mawa_shift(next))
+		return;
+
+	if (mpx_mawa_shift(next)) {
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
@@ -136,6 +177,7 @@ void switch_mm_irqs_off(struct mm_struct
 		/* Load per-mm CR4 state */
 		load_mm_cr4(next);
 
+		switch_mawa(prev, next);
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 		/*
 		 * Load the LDT, if the LDT is different.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
