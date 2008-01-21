Message-Id: <20080121202822.801158000@sgi.com>
References: <20080121202821.815918000@sgi.com>
Date: Mon, 21 Jan 2008 12:28:28 -0800
From: travis@sgi.com
Subject: [PATCH 7/7] percpu: Add debug of invalid per_cpu usage rc8-mm1-fixup with git-x86
Content-Disposition: inline; filename=debug-percpu
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Provide a means to trap usages of per_cpu variables before
the per_cpu_areas are setup.  Define CONFIG_DEBUG_PER_CPU to activate.

Based on 2.6.24-rc8-mm1 + latest (08/1/21) git-x86

Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/asm-generic/percpu.h |   11 ++++++++++-
 lib/Kconfig.debug            |   12 ++++++++++++
 2 files changed, 22 insertions(+), 1 deletion(-)

--- a/include/asm-generic/percpu.h
+++ b/include/asm-generic/percpu.h
@@ -47,12 +47,21 @@ extern unsigned long __per_cpu_offset[NR
 #endif
 
 /*
- * A percpu variable may point to a discarded reghions. The following are
+ * A percpu variable may point to a discarded regions. The following are
  * established ways to produce a usable pointer from the percpu variable
  * offset.
  */
+#ifdef	CONFIG_DEBUG_PER_CPU
+#define per_cpu(var, cpu) (*({		\
+	if (!per_cpu_offset(cpu)) {	\
+		printk("KERN_NOTICE per_cpu(%s,%d): not available!\n", #var, (int)cpu); \
+		dump_stack();		\
+	}				\
+	SHIFT_PERCPU_PTR(&per_cpu_var(var), per_cpu_offset(cpu));}))
+#else
 #define per_cpu(var, cpu) \
 	(*SHIFT_PERCPU_PTR(&per_cpu_var(var), per_cpu_offset(cpu)))
+#endif
 #define __get_cpu_var(var) \
 	(*SHIFT_PERCPU_PTR(&per_cpu_var(var), my_cpu_offset))
 #define __raw_get_cpu_var(var) \
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
