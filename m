Message-Id: <20080123044924.926408000@sgi.com>
References: <20080123044924.508382000@sgi.com>
Date: Tue, 22 Jan 2008 20:49:26 -0800
From: travis@sgi.com
Subject: [PATCH 2/3] x86_64: Fold pda into per cpu area
Content-Disposition: inline; filename=x86_64_fold_pda
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, jeremy@goop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

	%gs:[&per_cpu_xxxx - __per_cpu_start]

  * The boot_pdas are only needed in head64.c so move the declaration
    over there and make it static.

  * Remove the code that allocates special pda data structures.

Based on 2.6.24-rc8-mm1

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>

---
 arch/x86/kernel/head64.c          |    6 ++++++
 arch/x86/kernel/setup64.c         |   12 ++++++++++--
 arch/x86/kernel/smpboot_64.c      |   16 ----------------
 include/asm-generic/vmlinux.lds.h |    1 +
 include/asm-x86/pda.h             |    1 -
 include/asm-x86/percpu.h          |   30 +++++++++++++++++++-----------
 include/linux/percpu.h            |   13 ++++++++++++-
 7 files changed, 48 insertions(+), 31 deletions(-)

--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -22,6 +22,12 @@
 #include <asm/sections.h>
 #include <asm/kdebug.h>
 
+/*
+ * Only used before the per cpu areas are setup. The use for the non possible
+ * cpus continues after boot
+ */
+static struct x8664_pda boot_cpu_pda[NR_CPUS] __cacheline_aligned;
+
 static void __init zap_identity_mappings(void)
 {
 	pgd_t *pgd = pgd_offset_k(0UL);
--- a/arch/x86/kernel/setup64.c
+++ b/arch/x86/kernel/setup64.c
@@ -34,7 +34,9 @@ cpumask_t cpu_initialized __cpuinitdata 
 
 struct x8664_pda *_cpu_pda[NR_CPUS] __read_mostly;
 EXPORT_SYMBOL(_cpu_pda);
-struct x8664_pda boot_cpu_pda[NR_CPUS] __cacheline_aligned;
+
+DEFINE_PER_CPU_FIRST(struct x8664_pda, pda);
+EXPORT_PER_CPU_SYMBOL(pda);
 
 struct desc_ptr idt_descr = { 256 * 16 - 1, (unsigned long) idt_table };
 
@@ -150,10 +152,16 @@ void __init setup_per_cpu_areas(void)
 		}
 		if (!ptr)
 			panic("Cannot allocate cpu data for CPU %d\n", i);
-		cpu_pda(i)->data_offset = ptr - __per_cpu_start;
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
+		/* Relocate the pda */
+		memcpy(ptr, cpu_pda(i), sizeof(struct x8664_pda));
+		cpu_pda(i) = (struct x8664_pda *)ptr;
+		cpu_pda(i)->data_offset = ptr - __per_cpu_start;
 	}
 
+	/* Fix up pda for this processor .... */
+	pda_init(0);
+
 	/* setup percpu data maps early */
 	setup_per_cpu_maps();
 } 
--- a/arch/x86/kernel/smpboot_64.c
+++ b/arch/x86/kernel/smpboot_64.c
@@ -566,22 +566,6 @@ static int __cpuinit do_boot_cpu(int cpu
 		return -1;
 	}
 
-	/* Allocate node local memory for AP pdas */
-	if (cpu_pda(cpu) == &boot_cpu_pda[cpu]) {
-		struct x8664_pda *newpda, *pda;
-		int node = cpu_to_node(cpu);
-		pda = cpu_pda(cpu);
-		newpda = kmalloc_node(sizeof (struct x8664_pda), GFP_ATOMIC,
-				      node);
-		if (newpda) {
-			memcpy(newpda, pda, sizeof (struct x8664_pda));
-			cpu_pda(cpu) = newpda;
-		} else
-			printk(KERN_ERR
-		"Could not allocate node local PDA for CPU %d on node %d\n",
-				cpu, node);
-	}
-
 	alternatives_smp_switch(1);
 
 	c_idle.idle = get_idle_for_cpu(cpu);
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -273,6 +273,7 @@
 	. = ALIGN(align);						\
 	__per_cpu_start = .;						\
 	.data.percpu  : AT(ADDR(.data.percpu) - LOAD_OFFSET) {		\
+		*(.data.percpu.first)					\
 		*(.data.percpu)						\
 		*(.data.percpu.shared_aligned)				\
 	}								\
--- a/include/asm-x86/pda.h
+++ b/include/asm-x86/pda.h
@@ -39,7 +39,6 @@ struct x8664_pda {
 } ____cacheline_aligned_in_smp;
 
 extern struct x8664_pda *_cpu_pda[];
-extern struct x8664_pda boot_cpu_pda[];
 extern void pda_init(int);
 
 #define cpu_pda(i) (_cpu_pda[i])
--- a/include/asm-x86/percpu.h
+++ b/include/asm-x86/percpu.h
@@ -16,7 +16,14 @@
 #define __my_cpu_offset read_pda(data_offset)
 
 #define per_cpu_offset(x) (__per_cpu_offset(x))
+#define __percpu_seg "%%gs:"
+/* Calculate the offset to use with the segment register */
+#define seg_offset(name)   (*SHIFT_PERCPU_PTR(&per_cpu_var(name), \
+				- (unsigned long)__per_cpu_start))
 
+#else
+#define __percpu_seg ""
+#define seg_offset(name)   per_cpu_var(name)
 #endif
 #include <asm-generic/percpu.h>
 
@@ -64,16 +71,11 @@ DECLARE_PER_CPU(struct x8664_pda, pda);
  *    PER_CPU(cpu_gdt_descr, %ebx)
  */
 #ifdef CONFIG_SMP
-
 #define __my_cpu_offset x86_read_percpu(this_cpu_off)
-
 /* fs segment starts at (positive) offset == __per_cpu_offset[cpu] */
 #define __percpu_seg "%%fs:"
-
 #else  /* !SMP */
-
 #define __percpu_seg ""
-
 #endif	/* SMP */
 
 #include <asm-generic/percpu.h>
@@ -81,6 +83,13 @@ DECLARE_PER_CPU(struct x8664_pda, pda);
 /* We can use this directly for local CPU (faster). */
 DECLARE_PER_CPU(unsigned long, this_cpu_off);
 
+#define seg_offset(name)	per_cpu_var(name)
+
+#endif /* __ASSEMBLY__ */
+#endif /* !CONFIG_X86_64 */
+
+#ifndef __ASSEMBLY__
+
 /* For arch-specific code, we can use direct single-insn ops (they
  * don't give an lvalue though). */
 extern void __bad_percpu_size(void);
@@ -132,11 +141,10 @@ extern void __bad_percpu_size(void);
 		}						\
 		ret__; })
 
-#define x86_read_percpu(var) percpu_from_op("mov", per_cpu__##var)
-#define x86_write_percpu(var,val) percpu_to_op("mov", per_cpu__##var, val)
-#define x86_add_percpu(var,val) percpu_to_op("add", per_cpu__##var, val)
-#define x86_sub_percpu(var,val) percpu_to_op("sub", per_cpu__##var, val)
-#define x86_or_percpu(var,val) percpu_to_op("or", per_cpu__##var, val)
+#define x86_read_percpu(var) percpu_from_op("mov", seg_offset(var))
+#define x86_write_percpu(var,val) percpu_to_op("mov", seg_offset(var), val)
+#define x86_add_percpu(var,val) percpu_to_op("add", seg_offset(var), val)
+#define x86_sub_percpu(var,val) percpu_to_op("sub", seg_offset(var), val)
+#define x86_or_percpu(var,val) percpu_to_op("or", seg_offset(var), val)
 #endif /* !__ASSEMBLY__ */
-#endif /* !CONFIG_X86_64 */
 #endif /* _ASM_X86_PERCPU_H_ */
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -9,6 +9,10 @@
 
 #include <asm/percpu.h>
 
+#ifndef PER_CPU_ATTRIBUTES
+#define PER_CPU_ATTRIBUTES
+#endif
+
 #ifdef CONFIG_SMP
 #define DEFINE_PER_CPU(type, name)					\
 	__attribute__((__section__(".data.percpu")))			\
@@ -18,11 +22,18 @@
 	__attribute__((__section__(".data.percpu.shared_aligned")))	\
 	PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name		\
 	____cacheline_aligned_in_smp
+
+#define DEFINE_PER_CPU_FIRST(type, name)				\
+	__attribute__((__section__(".data.percpu.first")))		\
+	PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
 #else
 #define DEFINE_PER_CPU(type, name)					\
 	PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
 
-#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)		      \
+#define DEFINE_PER_CPU_SHARED_ALIGNED(type, name)			\
+	DEFINE_PER_CPU(type, name)
+
+#define DEFINE_PER_CPU_FIRST(type, name)				\
 	DEFINE_PER_CPU(type, name)
 #endif
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
