Message-Id: <20080117223505.380465000@sgi.com>
References: <20080117223505.203884000@sgi.com>
Date: Thu, 17 Jan 2008 14:35:06 -0800
From: travis@sgi.com
Subject: [PATCH 1/6] Modules: Fold percpu_modcopy into module.c
Content-Disposition: inline; filename=fold-percpu_modcopy
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

percpu_modcopy() is defined multiple times in arch files. However, the only
user is module.c. Put a static definition into module.c and remove
the definitions from the arch files.


Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <ak@suse.de>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>

---
 arch/ia64/kernel/module.c    |   11 -----------
 include/asm-generic/percpu.h |    8 --------
 include/asm-ia64/percpu.h    |    5 -----
 include/asm-powerpc/percpu.h |    9 ---------
 include/asm-s390/percpu.h    |    9 ---------
 kernel/module.c              |    8 ++++++++
 6 files changed, 8 insertions(+), 42 deletions(-)

--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -940,14 +940,3 @@ module_arch_cleanup (struct module *mod)
 	if (mod->arch.core_unw_table)
 		unw_remove_unwind_table(mod->arch.core_unw_table);
 }
-
-#ifdef CONFIG_SMP
-void
-percpu_modcopy (void *pcpudst, const void *src, unsigned long size)
-{
-	unsigned int i;
-	for_each_possible_cpu(i) {
-		memcpy(pcpudst + per_cpu_offset(i), src, size);
-	}
-}
-#endif /* CONFIG_SMP */
--- a/include/asm-generic/percpu.h
+++ b/include/asm-generic/percpu.h
@@ -63,14 +63,6 @@ extern unsigned long __per_cpu_offset[NR
 extern void setup_per_cpu_areas(void);
 #endif
 
-/* A macro to avoid #include hell... */
-#define percpu_modcopy(pcpudst, src, size)			\
-do {								\
-	unsigned int __i;					\
-	for_each_possible_cpu(__i)				\
-		memcpy((pcpudst)+per_cpu_offset(__i),		\
-		       (src), (size));				\
-} while (0)
 #else /* ! SMP */
 
 #define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu_var(var)))
--- a/include/asm-ia64/percpu.h
+++ b/include/asm-ia64/percpu.h
@@ -22,10 +22,6 @@
 #define DECLARE_PER_CPU(type, name)				\
 	extern PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
 
-/*
- * Pretty much a literal copy of asm-generic/percpu.h, except that percpu_modcopy() is an
- * external routine, to avoid include-hell.
- */
 #ifdef CONFIG_SMP
 
 extern unsigned long __per_cpu_offset[NR_CPUS];
@@ -38,7 +34,6 @@ DECLARE_PER_CPU(unsigned long, local_per
 #define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
 #define __raw_get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
 
-extern void percpu_modcopy(void *pcpudst, const void *src, unsigned long size);
 extern void setup_per_cpu_areas (void);
 extern void *per_cpu_init(void);
 
--- a/include/asm-powerpc/percpu.h
+++ b/include/asm-powerpc/percpu.h
@@ -21,15 +21,6 @@
 #define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __my_cpu_offset()))
 #define __raw_get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, local_paca->data_offset))
 
-/* A macro to avoid #include hell... */
-#define percpu_modcopy(pcpudst, src, size)			\
-do {								\
-	unsigned int __i;					\
-	for_each_possible_cpu(__i)				\
-		memcpy((pcpudst)+__per_cpu_offset(__i),		\
-		       (src), (size));				\
-} while (0)
-
 extern void setup_per_cpu_areas(void);
 
 #else /* ! SMP */
--- a/include/asm-s390/percpu.h
+++ b/include/asm-s390/percpu.h
@@ -39,15 +39,6 @@ extern unsigned long __per_cpu_offset[NR
 #define per_cpu(var,cpu) __reloc_hide(var,__per_cpu_offset[cpu])
 #define per_cpu_offset(x) (__per_cpu_offset[x])
 
-/* A macro to avoid #include hell... */
-#define percpu_modcopy(pcpudst, src, size)			\
-do {								\
-	unsigned int __i;					\
-	for_each_possible_cpu(__i)				\
-		memcpy((pcpudst)+__per_cpu_offset[__i],		\
-		       (src), (size));				\
-} while (0)
-
 #else /* ! SMP */
 
 #define __get_cpu_var(var) __reloc_hide(var,0)
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -422,6 +422,14 @@ static unsigned int find_pcpusec(Elf_Ehd
 	return find_sec(hdr, sechdrs, secstrings, ".data.percpu");
 }
 
+static void percpu_modcopy(void *pcpudest, const void *from, unsigned long size)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		memcpy(pcpudest + per_cpu_offset(cpu), from, size);
+}
+
 static int percpu_modinit(void)
 {
 	pcpu_num_used = 2;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
