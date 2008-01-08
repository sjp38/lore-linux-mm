Message-Id: <20080108211024.096539000@sgi.com>
References: <20080108211023.923047000@sgi.com>
Date: Tue, 08 Jan 2008 13:10:24 -0800
From: travis@sgi.com
Subject: [PATCH 01/10] percpu: Use a kconfig variable to signal arch specific percpu setup
Content-Disposition: inline; filename=arch_sets_up_per_cpu_areas
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Sam Ravnborg <sam@ravnborg.org>
List-ID: <linux-mm.kvack.org>

The use of the __GENERIC_PERCPU is a bit problematic since arches
may want to run their own percpu setup while using the generic
percpu definitions. Replace it through a kconfig variable.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <ak@suse.de>
Cc: Sam Ravnborg <sam@ravnborg.org>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>

---
V1->V2:
- Use def_bool as suggested by Randy.

V3->v4:
  - change config ARCH_SETS_UP_PER_CPU_AREA to a global var
    and use select HAVE_SETUP_PER_CPU_AREA to specify.
---
 arch/Kconfig                 |    3 +++
 arch/ia64/Kconfig            |    1 +
 arch/powerpc/Kconfig         |    4 ++++
 arch/sparc64/Kconfig         |    1 +
 arch/x86/Kconfig             |    1 +
 include/asm-generic/percpu.h |    1 -
 include/asm-s390/percpu.h    |    2 --
 include/asm-x86/percpu_32.h  |    2 --
 init/main.c                  |    4 ++--
 9 files changed, 12 insertions(+), 7 deletions(-)

--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -29,3 +29,6 @@ config KPROBES
 
 config HAVE_KPROBES
 	def_bool n
+
+config HAVE_SETUP_PER_CPU_AREA
+	def_bool n
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -17,6 +17,7 @@ config IA64
 	select ARCH_SUPPORTS_MSI
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
+	select HAVE_SETUP_PER_CPU_AREA
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -42,6 +42,10 @@ config GENERIC_HARDIRQS
 	bool
 	default y
 
+config PPC64
+	select HAVE_SETUP_PER_CPU_AREA
+	default y
+
 config IRQ_PER_CPU
 	bool
 	default y
--- a/arch/sparc64/Kconfig
+++ b/arch/sparc64/Kconfig
@@ -10,6 +10,7 @@ config SPARC
 	default y
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
+	select HAVE_SETUP_PER_CPU_AREA
 
 config SPARC64
 	bool
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -20,6 +20,7 @@ config X86
 	def_bool y
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
+	select HAVE_SETUP_PER_CPU_AREA if ARCH = "x86_64"
 
 config GENERIC_LOCKBREAK
 	def_bool n
--- a/include/asm-generic/percpu.h
+++ b/include/asm-generic/percpu.h
@@ -3,7 +3,6 @@
 #include <linux/compiler.h>
 #include <linux/threads.h>
 
-#define __GENERIC_PER_CPU
 #ifdef CONFIG_SMP
 
 extern unsigned long __per_cpu_offset[NR_CPUS];
--- a/include/asm-s390/percpu.h
+++ b/include/asm-s390/percpu.h
@@ -4,8 +4,6 @@
 #include <linux/compiler.h>
 #include <asm/lowcore.h>
 
-#define __GENERIC_PER_CPU
-
 /*
  * s390 uses its own implementation for per cpu data, the offset of
  * the cpu local data area is cached in the cpu's lowcore memory.
--- a/include/asm-x86/percpu_32.h
+++ b/include/asm-x86/percpu_32.h
@@ -41,8 +41,6 @@
  *    PER_CPU(cpu_gdt_descr, %ebx)
  */
 #ifdef CONFIG_SMP
-/* Same as generic implementation except for optimized local access. */
-#define __GENERIC_PER_CPU
 
 /* This is used for other cpus to find our section. */
 extern unsigned long __per_cpu_offset[];
--- a/init/main.c
+++ b/init/main.c
@@ -363,7 +363,7 @@ static inline void smp_prepare_cpus(unsi
 
 #else
 
-#ifdef __GENERIC_PER_CPU
+#ifndef CONFIG_HAVE_SETUP_PER_CPU_AREA
 unsigned long __per_cpu_offset[NR_CPUS] __read_mostly;
 
 EXPORT_SYMBOL(__per_cpu_offset);
@@ -384,7 +384,7 @@ static void __init setup_per_cpu_areas(v
 		ptr += size;
 	}
 }
-#endif /* !__GENERIC_PER_CPU */
+#endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
 
 /* Called by boot processor to activate the rest. */
 static void __init smp_init(void)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
