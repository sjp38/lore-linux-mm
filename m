Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0F6A6B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 09:29:08 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r144so10173892wme.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 06:29:08 -0800 (PST)
Received: from mail-wj0-x244.google.com (mail-wj0-x244.google.com. [2a00:1450:400c:c01::244])
        by mx.google.com with ESMTPS id s22si12532264wme.155.2017.01.11.06.29.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 06:29:07 -0800 (PST)
Received: by mail-wj0-x244.google.com with SMTP id dh1so10738803wjb.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 06:29:07 -0800 (PST)
Date: Wed, 11 Jan 2017 17:29:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Message-ID: <20170111142904.GD4895@node.shutemov.name>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <5a3dcc25-b264-37c7-c090-09981b23940d@intel.com>
 <20170105192910.q26ozg4ci4i3j2ai@black.fi.intel.com>
 <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com>
 <CALCETrUQ2+P424d9MW-Dy2yQ0+EnMfBuY80wd8NkNmc8is0AUw@mail.gmail.com>
 <978d5f1a-ec4d-f747-93fd-27ecfe10cb88@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <978d5f1a-ec4d-f747-93fd-27ecfe10cb88@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 05, 2017 at 12:49:44PM -0800, Dave Hansen wrote:
> On 01/05/2017 12:14 PM, Andy Lutomirski wrote:
> >> I'm not sure I'm comfortable with this.  Do other rlimit changes cause
> >> silent data corruption?  I'm pretty sure doing this to MPX would.
> >>
> > What actually goes wrong in this case?  That is, what combination of
> > MPX setup of subsequent allocations will cause a problem, and is the
> > problem worse than just a segfault?  IMO it would be really nice to
> > keep the messy case confined to MPX.
> 
> The MPX bounds tables are indexed by virtual address.  They need to grow
> if the virtual address space grows.   There's an MSR that controls
> whether we use the 48-bit or 57-bit layout.  It basically decides
> whether we need a 2GB (48-bit) or 1TB (57-bit) bounds directory.
> 
> The question is what we do with legacy MPX applications.  We obviously
> can't let them just allocate a 2GB table and then go let the hardware
> pretend it's 1TB in size.  We also can't hand the hardware using a 2GB
> table an address >48-bits.
> 
> Ideally, I'd like to make sure that legacy MPX can't be enabled if this
> RLIMIT is set over 48-bits (really 47).  I'd also like to make sure that
> legacy MPX is active, that the RLIMIT can't be raised because all hell
> will break loose when the new addresses show up.

I think we can do this. See the patch below.

Basically, we refuse to enable MPX and issue warning in dmesg if there's
anything mapped above 47-bits. Once MPX is enabled, mmap_max_addr() cannot
be higher than 47-bits too.

Function call from mmap_max_addr() is unfortunate, but I don't see a
way around.

As we add support of MAWA it will get somewhat more complex, but general
idea should be the same.

Build-tested only.

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 07cc4f27ca41..f97b149145f8 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1742,7 +1742,6 @@ config X86_SMAP
 config X86_INTEL_MPX
 	prompt "Intel MPX (Memory Protection Extensions)"
 	def_bool n
-	depends on !X86_5LEVEL
 	depends on CPU_SUP_INTEL
 	---help---
 	  MPX provides hardware features that can be used in
diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
index 0b416d4cf73b..ba9005f9bf87 100644
--- a/arch/x86/include/asm/mpx.h
+++ b/arch/x86/include/asm/mpx.h
@@ -56,11 +56,8 @@
 
 #ifdef CONFIG_X86_INTEL_MPX
 siginfo_t *mpx_generate_siginfo(struct pt_regs *regs);
+int kernel_managing_mpx_tables(struct mm_struct *mm);
 int mpx_handle_bd_fault(void);
-static inline int kernel_managing_mpx_tables(struct mm_struct *mm)
-{
-	return (mm->context.bd_addr != MPX_INVALID_BOUNDS_DIR);
-}
 static inline void mpx_mm_init(struct mm_struct *mm)
 {
 	/*
@@ -80,10 +77,6 @@ static inline int mpx_handle_bd_fault(void)
 {
 	return -EINVAL;
 }
-static inline int kernel_managing_mpx_tables(struct mm_struct *mm)
-{
-	return 0;
-}
 static inline void mpx_mm_init(struct mm_struct *mm)
 {
 }
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index e02917126859..589610a4f099 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -869,6 +869,7 @@ extern int set_tsc_mode(unsigned int val);
 #ifdef CONFIG_X86_INTEL_MPX
 extern int mpx_enable_management(void);
 extern int mpx_disable_management(void);
+extern int kernel_managing_mpx_tables(struct mm_struct *mm);
 #else
 static inline int mpx_enable_management(void)
 {
@@ -878,8 +879,22 @@ static inline int mpx_disable_management(void)
 {
 	return -EINVAL;
 }
+static inline int kernel_managing_mpx_tables(struct mm_struct *mm)
+{
+	return 0;
+}
 #endif /* CONFIG_X86_INTEL_MPX */
 
+#define mmap_max_addr() \
+({									\
+	unsigned long max_addr = min(TASK_SIZE, rlimit(RLIMIT_VADDR));	\
+	/* At the moment, MPX cannot handle addresses above 47-bits */	\
+	if (max_addr > USER_VADDR_LIM &&				\
+			kernel_managing_mpx_tables(current->mm))	\
+ 		max_addr = USER_VADDR_LIM;				\
+ 	max_addr;							\
+})
+
 extern u16 amd_get_nb_id(int cpu);
 extern u32 amd_get_nodes_per_socket(void);
 
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 324e5713d386..04fa386a165a 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -354,10 +354,22 @@ int mpx_enable_management(void)
 	 */
 	bd_base = mpx_get_bounds_dir();
 	down_write(&mm->mmap_sem);
+
+	/*
+	 * MPX doesn't support addresses above 47-bits yes.
+	 * Make sure nothing is mapped there before enabling.
+	 */
+	if (find_vma(mm, 1UL << 47)) {
+		pr_warn("%s (%d): MPX cannot handle addresses above 47-bits. "
+				"Disabling.", current->comm, current->pid);
+		ret = -ENXIO;
+		goto out;
+	}
+
 	mm->context.bd_addr = bd_base;
 	if (mm->context.bd_addr == MPX_INVALID_BOUNDS_DIR)
 		ret = -ENXIO;
-
+out:
 	up_write(&mm->mmap_sem);
 	return ret;
 }
@@ -516,6 +528,11 @@ static int do_mpx_bt_fault(void)
 	return allocate_bt(mm, (long __user *)bd_entry);
 }
 
+int kernel_managing_mpx_tables(struct mm_struct *mm)
+{
+	return (mm->context.bd_addr != MPX_INVALID_BOUNDS_DIR);
+}
+
 int mpx_handle_bd_fault(void)
 {
 	/*
diff --git a/include/linux/sched.h b/include/linux/sched.h
index f0f23afe0838..d463b800d8ce 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -3661,9 +3661,12 @@ void cpufreq_add_update_util_hook(int cpu, struct update_util_data *data,
 void cpufreq_remove_update_util_hook(int cpu);
 #endif /* CONFIG_CPU_FREQ */
 
+#ifndef mmap_max_addr
+#define mmap_max_addr mmap_max_addr
 static inline unsigned long mmap_max_addr(void)
 {
 	return min(TASK_SIZE, rlimit(RLIMIT_VADDR));
 }
+#endif
 
 #endif
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
