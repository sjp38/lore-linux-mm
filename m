Date: Wed, 2 Jan 2008 12:02:25 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] i386: avoid expensive ppro ordering workaround for default 686 kernels
Message-ID: <20080102110225.GA16154@wotan.suse.de>
References: <20071218012632.GA23110@wotan.suse.de> <20071222005737.2675c33b.akpm@linux-foundation.org> <20071223055730.GA29288@wotan.suse.de> <20071222223234.7f0fbd8a.akpm@linux-foundation.org> <20071223071529.GC29288@wotan.suse.de> <alpine.LFD.0.9999.0712230900310.21557@woody.linux-foundation.org> <20080101234133.4a744329@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080101234133.4a744329@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 01, 2008 at 11:41:33PM +0000, Alan Cox wrote:
> On Sun, 23 Dec 2007 09:22:17 -0800 (PST)
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > 
> > 
> > On Sun, 23 Dec 2007, Nick Piggin wrote:
> > > 
> > > It's not actually increasing size by that much here... hmm, do you have
> > > CONFIG_X86_PPRO_FENCE defined, by any chance?
> > > 
> > > It looks like this gets defined by default for i386, and also probably for
> > > distro configs. Linus? This is a fairly heavy hammer for such an unlikely bug on
> > > such a small number of systems (that admittedly doesn't even fix the bug in all
> > > cases anyway). It's not only heavy for my proposed patch, but it also halves the
> > > speed of spinlocks. Can we have some special config option for this instead? 
> > 
> > A special config option isn't great, since vendors would probably then 
> > enable it for those old P6's.
> > 
> > But maybe an "alternative()" thing that depends on a CPU capability?
> > Of course, it definitely *is* true that the number of CPU's that have that 
> > bug _and_ are actually used in SMP environments is probably vanishingly 
> > small. So maybe even vendors don't really care any more, and we could make 
> > the PPRO_FENCE thing a thing of the past.
> 
> If the PPro fencing isn't built for SMP kernels for set for CPU of
> Pentium II or greater then nobody is going to care. The only reasons to
> build distro support for older processors is

SLES10 seems to build for M586 by default, and I think it would be very
reasonable to expect M686 builds to be common in future. Even for SMP
kernels -- maybe we'd see fewer special case UP kernels with better kernel
support and more common multicore chips.
 
What's more, it might give me a chance of getting this uninitialised-data
-leaking, data-corrupting bugfix past Andrew's allyesconfig "sanity" check ;)


> 	-	VIA C3/C5 to work around the gcc 686 cmov bug
> 	-	Geode (embedded and OLPC)
> 
> neither of which are exactly multiprocessor, and the VIA stuff can be
> handled by beating up the gcc options. I also doubt PPro will be terribly
> high on anyones enterprise product line list for the next generation of
> enterprise distributions.

And that's also exactly why this patch is also pretty reasonable. Ingo, please
apply? (have changed the info message to a warning).

--
The selection of many CPU architecture families causes pentium pro memory ordering
errata workarounds to be enabled. This causes memory barriers and spinlocks to become
much more expensive, just to provide a few hacks for a very rare (nowadays)
class of system.

Take a different approach: after this patch, we just disable all but one CPU on those
systems, and print a warning. Also printed is a suggestion for a new CONFIG option that
can be enabled for the previous behaviour.

This is a big hammer for those few smp ppro systems, but it removes the big hammer that
was there for everyone else. It is also arguably the most correct way to work around the
problems -- from the description of at least one errata, loss of cache coherency, could
cause problems when particular classes of lockless data accesses are used (even with the
existing workarounds in place).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/arch/x86/Kconfig.cpu
===================================================================
--- linux-2.6.orig/arch/x86/Kconfig.cpu
+++ linux-2.6/arch/x86/Kconfig.cpu
@@ -321,7 +321,7 @@ config X86_XADD
 	depends on X86_32 && !M386
 	default y
 
-config X86_PPRO_FENCE
+config X86_BROKEN_PPRO
 	bool
 	depends on M686 || M586MMX || M586TSC || M586 || M486 || M386 || MGEODEGX1
 	default y
Index: linux-2.6/include/asm-x86/io_32.h
===================================================================
--- linux-2.6.orig/include/asm-x86/io_32.h
+++ linux-2.6/include/asm-x86/io_32.h
@@ -235,7 +235,7 @@ memcpy_toio(volatile void __iomem *dst, 
  *	2. Accidentally out of order processors (PPro errata #51)
  */
  
-#if defined(CONFIG_X86_OOSTORE) || defined(CONFIG_X86_PPRO_FENCE)
+#if defined(CONFIG_X86_OOSTORE) || defined(CONFIG_X86_BROKEN_PPRO)
 
 static inline void flush_write_buffers(void)
 {
Index: linux-2.6/include/asm-x86/spinlock_32.h
===================================================================
--- linux-2.6.orig/include/asm-x86/spinlock_32.h
+++ linux-2.6/include/asm-x86/spinlock_32.h
@@ -101,7 +101,7 @@ static inline int __raw_spin_trylock(raw
  * (PPro errata 66, 92)
  */
 
-#if !defined(CONFIG_X86_OOSTORE) && !defined(CONFIG_X86_PPRO_FENCE)
+#if !defined(CONFIG_X86_OOSTORE) && !defined(CONFIG_X86_BROKEN_PPRO_SMP)
 
 static inline void __raw_spin_unlock(raw_spinlock_t *lock)
 {
Index: linux-2.6/arch/x86/kernel/cpu/intel.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/cpu/intel.c
+++ linux-2.6/arch/x86/kernel/cpu/intel.c
@@ -108,6 +108,23 @@ static void __cpuinit trap_init_f00f_bug
 }
 #endif
 
+/*
+ * Errata #66, #92
+ */
+static void __cpuinit ppro_smp_fence_bug(void)
+{
+#if defined(CONFIG_SMP) && defined(CONFIG_X86_BROKEN_PPRO) && !defined(CONFIG_X86_BROKEN_PPRO_SMP)
+	extern unsigned int maxcpus;
+
+	if (boot_cpu_data.x86_vendor == X86_VENDOR_INTEL &&
+	    boot_cpu_data.x86 == 6 &&
+	    boot_cpu_data.x86_model == 1) {
+		printk(KERN_WARNING "WARNING: Pentium Pro with Errata#66, #92 detected. Limiting maxcpus to 1. Enable CONFIG_X86_BROKEN_PPRO_SMP to run with multiple CPUs\n");
+		maxcpus = 1;
+	}
+#endif
+}
+
 static void __cpuinit init_intel(struct cpuinfo_x86 *c)
 {
 	unsigned int l2 = 0;
@@ -132,6 +149,8 @@ static void __cpuinit init_intel(struct 
 	}
 #endif
 
+	ppro_smp_fence_bug();
+
 	select_idle_routine(c);
 	l2 = init_intel_cacheinfo(c);
 	if (c->cpuid_level > 9 ) {
Index: linux-2.6/include/asm-x86/system_32.h
===================================================================
--- linux-2.6.orig/include/asm-x86/system_32.h
+++ linux-2.6/include/asm-x86/system_32.h
@@ -279,7 +279,7 @@ static inline unsigned long get_limit(un
 
 #ifdef CONFIG_SMP
 #define smp_mb()	mb()
-#ifdef CONFIG_X86_PPRO_FENCE
+#ifdef CONFIG_X86_BROKEN_PPRO_SMP
 # define smp_rmb()	rmb()
 #else
 # define smp_rmb()	barrier()
Index: linux-2.6/arch/x86/Kconfig
===================================================================
--- linux-2.6.orig/arch/x86/Kconfig
+++ linux-2.6/arch/x86/Kconfig
@@ -378,6 +378,22 @@ config ES7000_CLUSTERED_APIC
 
 source "arch/x86/Kconfig.cpu"
 
+config X86_BROKEN_PPRO_SMP
+	bool "PentiumPro memory ordering errata workaround"
+	depends on X86_BROKEN_PPRO && SMP
+	default n
+	help
+	  Old PentiumPro multiprocessor systems had errata that could cause memory
+	  operations to violate the x86 ordering standard in rare cases. Enabling this
+	  option will attempt to work around some (but not all) occurances of these
+	  problems, at the cost of much heavier spinlock and memory barrier operations.
+
+	  If you say N here, these systems will be detected and limited to a single CPU
+	  at boot time.
+
+	  If unsure, say N here. Even distro kernels should think twice before enabling
+	  this: there are few systems, and an unlikely bug.
+
 config HPET_TIMER
 	bool
 	prompt "HPET Timer Support" if X86_32


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
