Message-Id: <20080108021143.004481000@sgi.com>
References: <20080108021142.585467000@sgi.com>
Date: Mon, 07 Jan 2008 18:11:44 -0800
From: travis@sgi.com
Subject: [PATCH 02/10] percpu: Move arch XX_PER_CPU_XX definitions into linux/percpu.h
Content-Disposition: inline; filename=move_percpu_declarations
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

- Special consideration for IA64: Add the ability to specify
  arch specific per cpu flags

V2->V3:
- remove .data.percpu attribute from DEFINE_PER_CPU for non-smp case.

The arch definitions are all the same. So move them into linux/percpu.h.

We cannot move DECLARE_PER_CPU since some include files just include
asm/percpu.h to avoid include recursion problems.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <ak@suse.de>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>

---
 include/asm-generic/percpu.h |   18 ------------------
 include/asm-ia64/percpu.h    |   24 ++----------------------
 include/asm-powerpc/percpu.h |   17 -----------------
 include/asm-s390/percpu.h    |   18 ------------------
 include/asm-sparc64/percpu.h |   16 ----------------
 include/asm-x86/percpu_32.h  |   12 ------------
 include/asm-x86/percpu_64.h  |   17 -----------------
 include/linux/percpu.h       |   24 ++++++++++++++++++++++++
 8 files changed, 26 insertions(+), 120 deletions(-)

--- a/include/asm-generic/percpu.h
+++ b/include/asm-generic/percpu.h
@@ -9,15 +9,6 @@ extern unsigned long __per_cpu_offset[NR
 
 #define per_cpu_offset(x) (__per_cpu_offset[x])
 
-/* Separate out the type, so (int[3], foo) works. */
-#define DEFINE_PER_CPU(type, name) \
-    __attribute__((__section__(".data.percpu"))) __typeof__(type) per_cpu__##name
-
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)		\
-    __attribute__((__section__(".data.percpu.shared_aligned"))) \
-    __typeof__(type) per_cpu__##name				\
-    ____cacheline_aligned_in_smp
-
 /* var is in discarded region: offset to particular copy we want */
 #define per_cpu(var, cpu) (*({				\
 	extern int simple_identifier_##var(void);	\
@@ -35,12 +26,6 @@ do {								\
 } while (0)
 #else /* ! SMP */
 
-#define DEFINE_PER_CPU(type, name) \
-    __typeof__(type) per_cpu__##name
-
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)	\
-    DEFINE_PER_CPU(type, name)
-
 #define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
 #define __get_cpu_var(var)			per_cpu__##var
 #define __raw_get_cpu_var(var)			per_cpu__##var
@@ -49,7 +34,4 @@ do {								\
 
 #define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
 
-#define EXPORT_PER_CPU_SYMBOL(var) EXPORT_SYMBOL(per_cpu__##var)
-#define EXPORT_PER_CPU_SYMBOL_GPL(var) EXPORT_SYMBOL_GPL(per_cpu__##var)
-
 #endif /* _ASM_GENERIC_PERCPU_H_ */
--- a/include/asm-ia64/percpu.h
+++ b/include/asm-ia64/percpu.h
@@ -16,28 +16,11 @@
 #include <linux/threads.h>
 
 #ifdef HAVE_MODEL_SMALL_ATTRIBUTE
-# define __SMALL_ADDR_AREA	__attribute__((__model__ (__small__)))
-#else
-# define __SMALL_ADDR_AREA
+# define PER_CPU_ATTRIBUTES	__attribute__((__model__ (__small__)))
 #endif
 
 #define DECLARE_PER_CPU(type, name)				\
-	extern __SMALL_ADDR_AREA __typeof__(type) per_cpu__##name
-
-/* Separate out the type, so (int[3], foo) works. */
-#define DEFINE_PER_CPU(type, name)				\
-	__attribute__((__section__(".data.percpu")))		\
-	__SMALL_ADDR_AREA __typeof__(type) per_cpu__##name
-
-#ifdef CONFIG_SMP
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)			\
-	__attribute__((__section__(".data.percpu.shared_aligned")))	\
-	__SMALL_ADDR_AREA __typeof__(type) per_cpu__##name		\
-	____cacheline_aligned_in_smp
-#else
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)	\
-	DEFINE_PER_CPU(type, name)
-#endif
+	extern PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
 
 /*
  * Pretty much a literal copy of asm-generic/percpu.h, except that percpu_modcopy() is an
@@ -68,9 +51,6 @@ extern void *per_cpu_init(void);
 
 #endif	/* SMP */
 
-#define EXPORT_PER_CPU_SYMBOL(var)		EXPORT_SYMBOL(per_cpu__##var)
-#define EXPORT_PER_CPU_SYMBOL_GPL(var)		EXPORT_SYMBOL_GPL(per_cpu__##var)
-
 /*
  * Be extremely careful when taking the address of this variable!  Due to virtual
  * remapping, it is different from the canonical address returned by __get_cpu_var(var)!
--- a/include/asm-powerpc/percpu.h
+++ b/include/asm-powerpc/percpu.h
@@ -16,15 +16,6 @@
 #define __my_cpu_offset() get_paca()->data_offset
 #define per_cpu_offset(x) (__per_cpu_offset(x))
 
-/* Separate out the type, so (int[3], foo) works. */
-#define DEFINE_PER_CPU(type, name) \
-    __attribute__((__section__(".data.percpu"))) __typeof__(type) per_cpu__##name
-
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)		\
-    __attribute__((__section__(".data.percpu.shared_aligned"))) \
-    __typeof__(type) per_cpu__##name				\
-    ____cacheline_aligned_in_smp
-
 /* var is in discarded region: offset to particular copy we want */
 #define per_cpu(var, cpu) (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset(cpu)))
 #define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __my_cpu_offset()))
@@ -43,11 +34,6 @@ extern void setup_per_cpu_areas(void);
 
 #else /* ! SMP */
 
-#define DEFINE_PER_CPU(type, name) \
-    __typeof__(type) per_cpu__##name
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)	\
-    DEFINE_PER_CPU(type, name)
-
 #define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
 #define __get_cpu_var(var)			per_cpu__##var
 #define __raw_get_cpu_var(var)			per_cpu__##var
@@ -56,9 +42,6 @@ extern void setup_per_cpu_areas(void);
 
 #define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
 
-#define EXPORT_PER_CPU_SYMBOL(var) EXPORT_SYMBOL(per_cpu__##var)
-#define EXPORT_PER_CPU_SYMBOL_GPL(var) EXPORT_SYMBOL_GPL(per_cpu__##var)
-
 #else
 #include <asm-generic/percpu.h>
 #endif
--- a/include/asm-s390/percpu.h
+++ b/include/asm-s390/percpu.h
@@ -34,16 +34,6 @@
 
 extern unsigned long __per_cpu_offset[NR_CPUS];
 
-/* Separate out the type, so (int[3], foo) works. */
-#define DEFINE_PER_CPU(type, name) \
-    __attribute__((__section__(".data.percpu"))) \
-    __typeof__(type) per_cpu__##name
-
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)		\
-    __attribute__((__section__(".data.percpu.shared_aligned"))) \
-    __typeof__(type) per_cpu__##name				\
-    ____cacheline_aligned_in_smp
-
 #define __get_cpu_var(var) __reloc_hide(var,S390_lowcore.percpu_offset)
 #define __raw_get_cpu_var(var) __reloc_hide(var,S390_lowcore.percpu_offset)
 #define per_cpu(var,cpu) __reloc_hide(var,__per_cpu_offset[cpu])
@@ -60,11 +50,6 @@ do {								\
 
 #else /* ! SMP */
 
-#define DEFINE_PER_CPU(type, name) \
-    __typeof__(type) per_cpu__##name
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)	\
-    DEFINE_PER_CPU(type, name)
-
 #define __get_cpu_var(var) __reloc_hide(var,0)
 #define __raw_get_cpu_var(var) __reloc_hide(var,0)
 #define per_cpu(var,cpu) __reloc_hide(var,0)
@@ -73,7 +58,4 @@ do {								\
 
 #define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
 
-#define EXPORT_PER_CPU_SYMBOL(var) EXPORT_SYMBOL(per_cpu__##var)
-#define EXPORT_PER_CPU_SYMBOL_GPL(var) EXPORT_SYMBOL_GPL(per_cpu__##var)
-
 #endif /* __ARCH_S390_PERCPU__ */
--- a/include/asm-sparc64/percpu.h
+++ b/include/asm-sparc64/percpu.h
@@ -16,15 +16,6 @@ extern unsigned long __per_cpu_shift;
 	(__per_cpu_base + ((unsigned long)(__cpu) << __per_cpu_shift))
 #define per_cpu_offset(x) (__per_cpu_offset(x))
 
-/* Separate out the type, so (int[3], foo) works. */
-#define DEFINE_PER_CPU(type, name) \
-    __attribute__((__section__(".data.percpu"))) __typeof__(type) per_cpu__##name
-
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)		\
-    __attribute__((__section__(".data.percpu.shared_aligned"))) \
-    __typeof__(type) per_cpu__##name				\
-    ____cacheline_aligned_in_smp
-
 /* var is in discarded region: offset to particular copy we want */
 #define per_cpu(var, cpu) (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset(cpu)))
 #define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __local_per_cpu_offset))
@@ -41,10 +32,6 @@ do {								\
 #else /* ! SMP */
 
 #define real_setup_per_cpu_areas()		do { } while (0)
-#define DEFINE_PER_CPU(type, name) \
-    __typeof__(type) per_cpu__##name
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)	\
-    DEFINE_PER_CPU(type, name)
 
 #define per_cpu(var, cpu)			(*((void)cpu, &per_cpu__##var))
 #define __get_cpu_var(var)			per_cpu__##var
@@ -54,7 +41,4 @@ do {								\
 
 #define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
 
-#define EXPORT_PER_CPU_SYMBOL(var) EXPORT_SYMBOL(per_cpu__##var)
-#define EXPORT_PER_CPU_SYMBOL_GPL(var) EXPORT_SYMBOL_GPL(per_cpu__##var)
-
 #endif /* __ARCH_SPARC64_PERCPU__ */
--- a/include/asm-x86/percpu_32.h
+++ b/include/asm-x86/percpu_32.h
@@ -47,16 +47,7 @@ extern unsigned long __per_cpu_offset[];
 
 #define per_cpu_offset(x) (__per_cpu_offset[x])
 
-/* Separate out the type, so (int[3], foo) works. */
 #define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
-#define DEFINE_PER_CPU(type, name) \
-    __attribute__((__section__(".data.percpu"))) __typeof__(type) per_cpu__##name
-
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)		\
-    __attribute__((__section__(".data.percpu.shared_aligned"))) \
-    __typeof__(type) per_cpu__##name				\
-    ____cacheline_aligned_in_smp
-
 /* We can use this directly for local CPU (faster). */
 DECLARE_PER_CPU(unsigned long, this_cpu_off);
 
@@ -81,9 +72,6 @@ do {								\
 		       (src), (size));				\
 } while (0)
 
-#define EXPORT_PER_CPU_SYMBOL(var) EXPORT_SYMBOL(per_cpu__##var)
-#define EXPORT_PER_CPU_SYMBOL_GPL(var) EXPORT_SYMBOL_GPL(per_cpu__##var)
-
 /* fs segment starts at (positive) offset == __per_cpu_offset[cpu] */
 #define __percpu_seg "%%fs:"
 #else  /* !SMP */
--- a/include/asm-x86/percpu_64.h
+++ b/include/asm-x86/percpu_64.h
@@ -16,15 +16,6 @@
 
 #define per_cpu_offset(x) (__per_cpu_offset(x))
 
-/* Separate out the type, so (int[3], foo) works. */
-#define DEFINE_PER_CPU(type, name) \
-    __attribute__((__section__(".data.percpu"))) __typeof__(type) per_cpu__##name
-
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)		\
-    __attribute__((__section__(".data.percpu.shared_aligned"))) \
-    __typeof__(type) per_cpu__##name				\
-    ____cacheline_internodealigned_in_smp
-
 /* var is in discarded region: offset to particular copy we want */
 #define per_cpu(var, cpu) (*({				\
 	extern int simple_identifier_##var(void);	\
@@ -49,11 +40,6 @@ extern void setup_per_cpu_areas(void);
 
 #else /* ! SMP */
 
-#define DEFINE_PER_CPU(type, name) \
-    __typeof__(type) per_cpu__##name
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)	\
-    DEFINE_PER_CPU(type, name)
-
 #define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
 #define __get_cpu_var(var)			per_cpu__##var
 #define __raw_get_cpu_var(var)			per_cpu__##var
@@ -62,7 +48,4 @@ extern void setup_per_cpu_areas(void);
 
 #define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
 
-#define EXPORT_PER_CPU_SYMBOL(var) EXPORT_SYMBOL(per_cpu__##var)
-#define EXPORT_PER_CPU_SYMBOL_GPL(var) EXPORT_SYMBOL_GPL(per_cpu__##var)
-
 #endif /* _ASM_X8664_PERCPU_H_ */
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -9,6 +9,30 @@
 
 #include <asm/percpu.h>
 
+#ifndef PER_CPU_ATTRIBUTES
+#define PER_CPU_ATTRIBUTES
+#endif
+
+#ifdef CONFIG_SMP
+#define DEFINE_PER_CPU(type, name)					\
+	__attribute__((__section__(".data.percpu")))			\
+	PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
+
+#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)			\
+	__attribute__((__section__(".data.percpu.shared_aligned")))	\
+	PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name		\
+	____cacheline_aligned_in_smp
+#else
+#define DEFINE_PER_CPU(type, name)					\
+	PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
+
+#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)		      \
+	DEFINE_PER_CPU(type, name)
+#endif
+
+#define EXPORT_PER_CPU_SYMBOL(var) EXPORT_SYMBOL(per_cpu__##var)
+#define EXPORT_PER_CPU_SYMBOL_GPL(var) EXPORT_SYMBOL_GPL(per_cpu__##var)
+
 /* Enough to cover all DEFINE_PER_CPUs in kernel, including modules. */
 #ifndef PERCPU_ENOUGH_ROOM
 #ifdef CONFIG_MODULES

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
