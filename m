Message-Id: <20080118183011.917801000@sgi.com>
References: <20080118183011.354965000@sgi.com>
Date: Fri, 18 Jan 2008 10:30:15 -0800
From: travis@sgi.com
Subject: [PATCH 4/5] x86: Add config variables for SMP_MAX
Content-Disposition: inline; filename=config-smp-max
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Adds and increases some config variables to accomodate larger SMP
configurations:

	NR_CPUS:      max limit now 4096
	NODES_SHIFT:  max limit now 9
	THREAD_ORDER: max limit now 3
	X86_SMP_MAX:  say Y to enable possible cpus == NR_CPUS

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/Kconfig             |   17 ++++++++++++++---
 arch/x86/Kconfig.debug       |    9 +++++++++
 arch/x86/kernel/smpboot_64.c |    4 ++++
 include/asm-x86/page_64.h    |    4 ++++
 4 files changed, 31 insertions(+), 3 deletions(-)

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -487,19 +487,29 @@ config ARCH_SUPPORTS_KVM
 
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-255)"
-	range 2 255
+	int "Maximum number of CPUs (2-4096)"
+	range 2 4096
 	depends on SMP
+	default "1024" if X86_SMP_MAX
 	default "32" if X86_NUMAQ || X86_SUMMIT || X86_BIGSMP || X86_ES7000
 	default "8"
 	help
 	  This allows you to specify the maximum number of CPUs which this
-	  kernel will support.  The maximum supported value is 255 and the
+	  kernel will support.  The maximum supported value is 4096 and the
 	  minimum value which makes sense is 2.
 
 	  This is purely to save memory - each supported CPU adds
 	  approximately eight kilobytes to the kernel image.
 
+config THREAD_ORDER
+	int "Kernel stack size (in page order)"
+	range 1 3
+	depends on X86_64_SMP
+	default "3" if X86_SMP_MAX
+	default "1"
+	help
+	  Increases kernel stack size.
+
 config SCHED_SMT
 	bool "SMT (Hyperthreading) scheduler support"
 	depends on (X86_64 && SMP) || (X86_32 && X86_HT)
@@ -882,6 +892,7 @@ config NUMA_EMU
 
 config NODES_SHIFT
 	int
+	default "9" if X86_SMP_MAX
 	default "6" if X86_64
 	default "4" if X86_NUMAQ
 	default "3"
--- a/arch/x86/Kconfig.debug
+++ b/arch/x86/Kconfig.debug
@@ -73,6 +73,15 @@ config X86_FIND_SMP_CONFIG
 	depends on X86_LOCAL_APIC || X86_VOYAGER
 	depends on X86_32
 
+config X86_SMP_MAX
+	bool "Enable Maximum SMP configuration"
+	def_bool n
+	depends on X86_64_SMP
+	help
+	  Say Y here to enable a "large" SMP configuration for testing
+	  purposes.  It does this by increasing the number of possible
+	  cpus to the NR_CPUS count. 
+
 config X86_MPPARSE
 	def_bool y
 	depends on (X86_32 && (X86_LOCAL_APIC && !X86_VISWS)) || X86_64
--- a/arch/x86/kernel/smpboot_64.c
+++ b/arch/x86/kernel/smpboot_64.c
@@ -784,6 +784,10 @@ __init void prefill_possible_map(void)
 	possible = num_processors + additional_cpus;
 	if (possible > NR_CPUS) 
 		possible = NR_CPUS;
+#ifdef	CONFIG_SMP_MAX
+	if (possible < NR_CPUS)
+		possible = NR_CPUS;
+#endif
 
 	printk(KERN_INFO "SMP: Allowing %d CPUs, %d hotplug CPUs\n",
 		possible,
--- a/include/asm-x86/page_64.h
+++ b/include/asm-x86/page_64.h
@@ -3,7 +3,11 @@
 
 #define PAGETABLE_LEVELS	4
 
+#ifdef	CONFIG_THREAD_ORDER
+#define THREAD_ORDER	CONFIG_THREAD_ORDER
+#else
 #define THREAD_ORDER	1
+#endif
 #define THREAD_SIZE  (PAGE_SIZE << THREAD_ORDER)
 #define CURRENT_MASK (~(THREAD_SIZE-1))
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
