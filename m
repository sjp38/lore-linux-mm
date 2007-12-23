Date: Sun, 23 Dec 2007 23:41:05 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-ID: <20071223224105.GB1285@wotan.suse.de>
References: <20071218012632.GA23110@wotan.suse.de> <20071222005737.2675c33b.akpm@linux-foundation.org> <20071223055730.GA29288@wotan.suse.de> <20071222223234.7f0fbd8a.akpm@linux-foundation.org> <20071223071529.GC29288@wotan.suse.de> <alpine.LFD.0.9999.0712230900310.21557@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.9999.0712230900310.21557@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Sun, Dec 23, 2007 at 09:22:17AM -0800, Linus Torvalds wrote:
> 
> There's actually a few different PPro errata. There's #51, which is an IO 
> ordering thing, and can happen on UP too. There's #66, which breaks CPU 
> ordering, and is SMP-only (and which is probably at least *mostly* fixed 
> by PPRO_FENCE), and there is #92 which can cause cache incoherency and 
> where PPRO_FENCE *may* indirectly help.

BTW. #66 seems to be an issue where a CPU may see the wrong results from a
RAW, if another CPU has written to the cacheline in the meantime. #92 is a
data loss bug (although it said they couldn't reproduce it on real hardware).

It says they're actually not a problem if semaphore operations are used to
protect the data. However a) it is becoming increasingly common that we don't
do that (eg. with lockless operations), and b) I don't know how the case of
false sharing in a cacheline can be safe.

Anyway, I think it is very rare, even on those two systems (one being in
Alan's basement) that run Linux... The number of cycles everybody else loses
in spin_unlock combined far outweighs the number of cycles these additional
CPUs are going to sit idle :)


> We could decide to just ignore all of them, or perhaps ignore all but #51. 
> I think Alan still has an old four-way PPro hidden away somewhere, but 
> he's probably one of the few people who could even *test* this thing.

This patch uses both your and Andi's ideas... Untested though.

X86_PPRO_FENCE means we might encounter these systems, so workaround #51, and
disable multiple cpus... unless X86_PPRO_FENCE_SMP, which includes the workarounds
for #66 and #92.

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
+		printk(KERN_INFO "Pentium Pro with Errata#66, #92 detected. Limiting maxcpus to 1. Enable CONFIG_X86_BROKEN_PPRO_SMP to run with multiple CPUs\n");
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
