Message-Id: <20071228001618.025451000@sgi.com>
References: <20071228001617.597161000@sgi.com>
Date: Thu, 27 Dec 2007 16:16:20 -0800
From: travis@sgi.com
Subject: [PATCH 03/10] percpu: Make the asm-generic/percpu.h more "generic"
Content-Disposition: inline; filename=genericize-percpu.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

- add support for PER_CPU_ATTRIBUTES

Add the ability to use generic/percpu even if the arch needs to override
several aspects of its operations. This will enable the use of generic
percpu.h for all arches.

An arch may define:

__per_cpu_offset	Do not use the generic pointer array. Arch must
			define per_cpu_offset(cpu) (used by x86_64, s390).

__my_cpu_offset		Can be defined to provide an optimized way to determine
			the offset for variables of the currently executing
			processor. Used by ia64, x86_64, x86_32, sparc64, s/390.

SHIFT_PTR(ptr, offset)	If an arch defines it then special handling
			of pointer arithmentic may be implemented. Used
			by s/390.


(Some of these special percpu arch implementations may be later consolidated
so that there are less cases to deal with.)

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <ak@suse.de>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>

---
 include/asm-generic/percpu.h |   69 ++++++++++++++++++++++++++++++++++++-------
 1 file changed, 58 insertions(+), 11 deletions(-)

--- a/include/asm-generic/percpu.h
+++ b/include/asm-generic/percpu.h
@@ -3,27 +3,74 @@
 #include <linux/compiler.h>
 #include <linux/threads.h>
 
+/*
+ * Determine the real variable name from the name visible in the
+ * kernel sources.
+ */
+#define per_cpu_var(var) per_cpu__##var
+
 #ifdef CONFIG_SMP
 
+/*
+ * per_cpu_offset() is the offset that has to be added to a
+ * percpu variable to get to the instance for a certain processor.
+ *
+ * Most arches use the __per_cpu_offset array for those offsets but
+ * some arches have their own ways of determining the offset (x86_64, s390).
+ */
+#ifndef __per_cpu_offset
 extern unsigned long __per_cpu_offset[NR_CPUS];
-
 #define per_cpu_offset(x) (__per_cpu_offset[x])
+#endif
 
-/* var is in discarded region: offset to particular copy we want */
-#define per_cpu(var, cpu) (*({				\
-	extern int simple_identifier_##var(void);	\
-	RELOC_HIDE(&per_cpu__##var, __per_cpu_offset[cpu]); }))
-#define __get_cpu_var(var) per_cpu(var, smp_processor_id())
-#define __raw_get_cpu_var(var) per_cpu(var, raw_smp_processor_id())
+/*
+ * Determine the offset for the currently active processor.
+ * An arch may define __my_cpu_offset to provide a more effective
+ * means of obtaining the offset to the per cpu variables of the
+ * current processor.
+ */
+#ifndef __my_cpu_offset
+#define __my_cpu_offset per_cpu_offset(raw_smp_processor_id())
+#define my_cpu_offset per_cpu_offset(smp_processor_id())
+#else
+#define my_cpu_offset __my_cpu_offset
+#endif
+
+/*
+ * Add a offset to a pointer but keep the pointer as is.
+ *
+ * Only S390 provides its own means of moving the pointer.
+ */
+#ifndef SHIFT_PTR
+#define SHIFT_PTR(__p, __offset)	RELOC_HIDE((__p), (__offset))
+#endif
+
+/*
+ * A percpu variable may point to a discarded reghions. The following are
+ * established ways to produce a usable pointer from the percpu variable
+ * offset.
+ */
+#define per_cpu(var, cpu) (*SHIFT_PTR(&per_cpu_var(var), per_cpu_offset(cpu)))
+#define __get_cpu_var(var) (*SHIFT_PTR(&per_cpu_var(var), my_cpu_offset))
+#define __raw_get_cpu_var(var) (*SHIFT_PTR(&per_cpu_var(var), __my_cpu_offset))
+
+#ifdef CONFIG_ARCH_SETS_UP_PER_CPU_AREA
+extern void setup_per_cpu_areas(void);
+#endif
 
 #else /* ! SMP */
 
-#define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
-#define __get_cpu_var(var)			per_cpu__##var
-#define __raw_get_cpu_var(var)			per_cpu__##var
+#define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu_var(var)))
+#define __get_cpu_var(var)			per_cpu_var(var)
+#define __raw_get_cpu_var(var)			per_cpu_var(var)
 
 #endif	/* SMP */
 
-#define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
+#ifndef PER_CPU_ATTRIBUTES
+#define PER_CPU_ATTRIBUTES
+#endif
+
+#define DECLARE_PER_CPU(type, name) extern PER_CPU_ATTRIBUTES \
+					__typeof__(type) per_cpu_var(name)
 
 #endif /* _ASM_GENERIC_PERCPU_H_ */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
