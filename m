Message-Id: <20080122230409.514557000@sgi.com>
References: <20080122230409.198261000@sgi.com>
Date: Tue, 22 Jan 2008 15:04:11 -0800
From: travis@sgi.com
Subject: [PATCH 2/3] x86: add percpu, cpu_to_node debug options
Content-Disposition: inline; filename=02-fix-x86.git-debug-maxsmp
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

[ patches for x86.git ]

    02-fix-x86.git-debug-maxsmp
	- adds debug options [do not include, except for DEBUG]

    These are debug options only.  Should not be applied but are very
    helpful when the system panics early or when testing of large count
    NR_CPUS is desired.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/Kconfig          |   22 ++++++++++++++++------
 include/asm-x86/page_64.h |    4 ++++
 lib/Kconfig.debug         |   12 ++++++++++++
 3 files changed, 32 insertions(+), 6 deletions(-)

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -467,19 +467,28 @@ config SWIOTLB
 
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-255)"
-	range 2 255
+	int "Maximum number of CPUs (2-4096)"
+	range 2 4096
 	depends on SMP
 	default "32" if X86_NUMAQ || X86_SUMMIT || X86_BIGSMP || X86_ES7000
-	default "8"
+	default "1024" if X86_64
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
+	depends on X86_64
+	default "3" if X86_SMP
+	default "1"
+	help
+	  Increases kernel stack size.
+
 config SCHED_SMT
 	bool "SMT (Hyperthreading) scheduler support"
 	depends on (X86_64 && SMP) || (X86_32 && X86_HT)
@@ -862,8 +871,9 @@ config NUMA_EMU
 	  number of nodes. This is only useful for debugging.
 
 config NODES_SHIFT
-	int
-	default "6" if X86_64
+	int "NODES_SHIFT"
+	range 1 15  if X86_64
+	default "9" if X86_64
 	default "4" if X86_NUMAQ
 	default "3"
 	depends on NEED_MULTIPLE_NODES
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
 
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -570,6 +570,18 @@ config PROVIDE_OHCI1394_DMA_INIT
 
 	  See Documentation/debugging-via-ohci1394.txt for more information.
 
+config DEBUG_PER_CPU
+	bool "Debug per_cpu usage"
+	depends on DEBUG_KERNEL
+	depends on SMP
+	default n
+	help
+	  Say Y here to add code that verifies the per_cpu area is
+	  setup before accessing a per_cpu variable.  It does add a
+	  significant amount of code to kernel memory.
+
+	  If unsure, say N.
+
 source "samples/Kconfig"
 
 source "lib/Kconfig.kgdb"

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
