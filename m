Message-Id: <20080121202747.912834000@sgi.com>
References: <20080121202747.593568000@sgi.com>
Date: Mon, 21 Jan 2008 12:27:49 -0800
From: travis@sgi.com
Subject: [PATCH 2/8] percpu: Change Kconfig to HAVE_SETUP_PER_CPU_AREA rc8-mm1-fixup
Content-Disposition: inline; filename=config-to-select
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Sam Ravnborg <sam@ravnborg.org>
List-ID: <linux-mm.kvack.org>

Change "config ARCH_SETS_UP_PER_CPU_AREA" to "select
HAVE_SETUP_PER_CPU_AREA" as suggested by Sam.

Based on: 2.6.24-rc8-mm1

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <ak@suse.de>
Cc: Sam Ravnborg <sam@ravnborg.org>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>

---
rc8-mm1-fixup:
  - rebased from 2.6.24-rc6-mm1 to 2.6.24-rc8-mm1
    (removed changes that are in the git-x86.patch)
---
 arch/Kconfig                 |    3 +++
 arch/ia64/Kconfig            |    4 +---
 arch/powerpc/Kconfig         |    4 +---
 arch/sparc64/Kconfig         |    4 +---
 arch/x86/Kconfig             |    4 +---
 include/asm-generic/percpu.h |    2 +-
 init/main.c                  |    4 ++--
 7 files changed, 10 insertions(+), 15 deletions(-)

--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -1,3 +1,6 @@
 #
 # General architecture dependent options
 #
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
@@ -82,9 +83,6 @@ config GENERIC_TIME_VSYSCALL
 	bool
 	default y
 
-config ARCH_SETS_UP_PER_CPU_AREA
-	def_bool y
-
 config DMI
 	bool
 	default y
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -42,9 +42,6 @@ config GENERIC_HARDIRQS
 	bool
 	default y
 
-config ARCH_SETS_UP_PER_CPU_AREA
-	def_bool PPC64
-
 config IRQ_PER_CPU
 	bool
 	default y
@@ -89,6 +86,7 @@ config PPC
 	default y
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
+	select HAVE_SETUP_PER_CPU_AREA if PPC64
 
 config EARLY_PRINTK
 	bool
--- a/arch/sparc64/Kconfig
+++ b/arch/sparc64/Kconfig
@@ -10,6 +10,7 @@ config SPARC
 	default y
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
+	select HAVE_SETUP_PER_CPU_AREA
 
 config SPARC64
 	bool
@@ -68,9 +69,6 @@ config AUDIT_ARCH
 	bool
 	default y
 
-config ARCH_SETS_UP_PER_CPU_AREA
-	def_bool y
-
 config ARCH_NO_VIRT_TO_BUS
 	def_bool y
 
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -20,6 +20,7 @@ config X86
 	def_bool y
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
+	select HAVE_SETUP_PER_CPU_AREA if X86_64
 
 config GENERIC_LOCKBREAK
 	def_bool n
@@ -106,9 +107,6 @@ config GENERIC_TIME_VSYSCALL
 	bool
 	default X86_64
 
-config ARCH_SETS_UP_PER_CPU_AREA
-	def_bool X86_64
-
 config ARCH_SUPPORTS_OPROFILE
 	bool
 	default y
--- a/include/asm-generic/percpu.h
+++ b/include/asm-generic/percpu.h
@@ -59,7 +59,7 @@ extern unsigned long __per_cpu_offset[NR
 	(*SHIFT_PERCPU_PTR(&per_cpu_var(var), __my_cpu_offset))
 
 
-#ifdef CONFIG_ARCH_SETS_UP_PER_CPU_AREA
+#ifdef CONFIG_HAVE_SETUP_PER_CPU_AREA
 extern void setup_per_cpu_areas(void);
 #endif
 
--- a/init/main.c
+++ b/init/main.c
@@ -363,7 +363,7 @@ static inline void smp_prepare_cpus(unsi
 
 #else
 
-#ifndef CONFIG_ARCH_SETS_UP_PER_CPU_AREA
+#ifndef CONFIG_HAVE_SETUP_PER_CPU_AREA
 unsigned long __per_cpu_offset[NR_CPUS] __read_mostly;
 
 EXPORT_SYMBOL(__per_cpu_offset);
@@ -384,7 +384,7 @@ static void __init setup_per_cpu_areas(v
 		ptr += size;
 	}
 }
-#endif /* CONFIG_ARCH_SETS_UP_CPU_AREA */
+#endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
 
 /* Called by boot processor to activate the rest. */
 static void __init smp_init(void)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
