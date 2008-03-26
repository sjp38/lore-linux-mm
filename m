Message-Id: <20080326014138.292294000@polaris-admin.engr.sgi.com>
References: <20080326014137.934171000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:41:39 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 2/2] x86: Modify Kconfig to allow up to 4096 cpus
Content-Disposition: inline; filename=Kconfig
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Increase the limit of NR_CPUS to 4096 and introduce a boolean
called "MAXSMP" which when set (e.g. "allyesconfig"), will set
NR_CPUS = 4096 and NODES_SHIFT = 9 (512).

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/Kconfig |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

--- linux.trees.git.orig/arch/x86/Kconfig
+++ linux.trees.git/arch/x86/Kconfig
@@ -522,16 +522,24 @@ config SWIOTLB
 	  access 32-bits of memory can be used on systems with more than
 	  3 GB of memory. If unsure, say Y.
 
+config MAXSMP
+	bool "Configure Maximum number of SMP Processors"
+	depends on X86_64 && SMP
+	default n
+	help
+	  Configure maximum number of CPUS for this architecture.
+	  If unsure, say N.
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-255)"
-	range 2 255
+	int "Maximum number of CPUs (2-4096)"
+	range 2 4096
 	depends on SMP
+	default "4096" if MAXSMP
 	default "32" if X86_NUMAQ || X86_SUMMIT || X86_BIGSMP || X86_ES7000
 	default "8"
 	help
 	  This allows you to specify the maximum number of CPUs which this
-	  kernel will support.  The maximum supported value is 255 and the
+	  kernel will support.  The maximum supported value is 4096 and the
 	  minimum value which makes sense is 2.
 
 	  This is purely to save memory - each supported CPU adds
@@ -918,12 +926,16 @@ config NUMA_EMU
 	  number of nodes. This is only useful for debugging.
 
 config NODES_SHIFT
-	int "Max num nodes shift(1-15)"
+	int "Maximum NUMA Nodes (as a power of 2)"
 	range 1 15  if X86_64
+	default "9" if MAXSMP
 	default "6" if X86_64
 	default "4" if X86_NUMAQ
 	default "3"
 	depends on NEED_MULTIPLE_NODES
+	help
+	  Specify the maximum number of NUMA Nodes available on the target
+	  system.  Increases memory reserved to accomodate various tables.
 
 config HAVE_ARCH_BOOTMEM_NODE
 	def_bool y

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
