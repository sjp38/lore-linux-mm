Message-Id: <20080326013811.869519000@polaris-admin.engr.sgi.com>
References: <20080326013811.569646000@polaris-admin.engr.sgi.com>
Date: Tue, 25 Mar 2008 18:38:12 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 01/12] cpumask: Convert cpumask_of_cpu to allocated array v2
Content-Disposition: inline; filename=cpumask_of_cpu
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, "David S. Miller" <davem@davemloft.net>, "William L. Irwin" <wli@holomorphy.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Here is a simple patch to use an allocated array of cpumasks to
represent cpumask_of_cpu() instead of constructing one on the
stack, when the size of cpumask_t is significant.

Conditioned by NR_CPUS > BITS_PER_LONG, as if less than or equal,
cpumask_of_cpu() generates a simple unsigned long.  But the macro is
changed to generate an lvalue so a pointer to cpumask_of_cpu can be
provided.

This removes 26168 bytes of stack usage, as well as reduces the code
generated for each usage.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

# ia64
Cc: Tony Luck <tony.luck@intel.com>

# powerpc
Cc: Paul Mackerras <paulus@samba.org>
Cc: Anton Blanchard <anton@samba.org>

# sparc
Cc: David S. Miller <davem@davemloft.net>
Cc: William L. Irwin <wli@holomorphy.com>

# x86
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: H. Peter Anvin <hpa@zytor.com>


Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>
---
v2: rebased on linux-2.6.git + linux-2.6-x86.git
    ... and changed to use an allocated array of cpumask_t's instead
        of a percpu variable.
---
 arch/ia64/kernel/setup.c       |    3 +++
 arch/powerpc/kernel/setup_64.c |    3 +++
 arch/sparc64/mm/init.c         |    3 +++
 arch/x86/kernel/setup.c        |    3 +++
 include/linux/cpumask.h        |   30 ++++++++++++++++++------------
 init/main.c                    |   18 ++++++++++++++++++
 6 files changed, 48 insertions(+), 12 deletions(-)

--- linux.trees.git.orig/arch/ia64/kernel/setup.c
+++ linux.trees.git/arch/ia64/kernel/setup.c
@@ -772,6 +772,9 @@ setup_per_cpu_areas (void)
 		highest_cpu = cpu;
 
 	nr_cpu_ids = highest_cpu + 1;
+
+	/* Setup cpumask_of_cpu() map */
+	setup_cpumask_of_cpu(nr_cpu_ids);
 #endif
 }
 
--- linux.trees.git.orig/arch/powerpc/kernel/setup_64.c
+++ linux.trees.git/arch/powerpc/kernel/setup_64.c
@@ -601,6 +601,9 @@ void __init setup_per_cpu_areas(void)
 
 	/* Now that per_cpu is setup, initialize cpu_sibling_map */
 	smp_setup_cpu_sibling_map();
+
+	/* Setup cpumask_of_cpu() map */
+	setup_cpumask_of_cpu(nr_cpu_ids);
 }
 #endif
 
--- linux.trees.git.orig/arch/sparc64/mm/init.c
+++ linux.trees.git/arch/sparc64/mm/init.c
@@ -1302,6 +1302,9 @@ void __init setup_per_cpu_areas(void)
 		highest_cpu = cpu;
 
 	nr_cpu_ids = highest_cpu + 1;
+
+	/* Setup cpumask_of_cpu() map */
+	setup_cpumask_of_cpu(nr_cpu_ids);
 }
 #endif
 
--- linux.trees.git.orig/arch/x86/kernel/setup.c
+++ linux.trees.git/arch/x86/kernel/setup.c
@@ -96,6 +96,9 @@ void __init setup_per_cpu_areas(void)
 
 	/* Setup percpu data maps */
 	setup_per_cpu_maps();
+
+	/* Setup cpumask_of_cpu() map */
+	setup_cpumask_of_cpu(nr_cpu_ids);
 }
 
 #endif
--- linux.trees.git.orig/include/linux/cpumask.h
+++ linux.trees.git/include/linux/cpumask.h
@@ -222,18 +222,6 @@ int __next_cpu(int n, const cpumask_t *s
 #define next_cpu(n, src)	({ (void)(src); 1; })
 #endif
 
-#define cpumask_of_cpu(cpu)						\
-({									\
-	typeof(_unused_cpumask_arg_) m;					\
-	if (sizeof(m) == sizeof(unsigned long)) {			\
-		m.bits[0] = 1UL<<(cpu);					\
-	} else {							\
-		cpus_clear(m);						\
-		cpu_set((cpu), m);					\
-	}								\
-	m;								\
-})
-
 #define CPU_MASK_LAST_WORD BITMAP_LAST_WORD_MASK(NR_CPUS)
 
 #if NR_CPUS <= BITS_PER_LONG
@@ -243,6 +231,19 @@ int __next_cpu(int n, const cpumask_t *s
 	[BITS_TO_LONGS(NR_CPUS)-1] = CPU_MASK_LAST_WORD			\
 } }
 
+#define cpumask_of_cpu(cpu)						\
+(*({									\
+	typeof(_unused_cpumask_arg_) m;					\
+	if (sizeof(m) == sizeof(unsigned long)) {			\
+		m.bits[0] = 1UL<<(cpu);					\
+	} else {							\
+		cpus_clear(m);						\
+		cpu_set((cpu), m);					\
+	}								\
+	&m;								\
+}))
+static inline void setup_cpumask_of_cpu(int num) {}
+
 #else
 
 #define CPU_MASK_ALL							\
@@ -251,6 +252,11 @@ int __next_cpu(int n, const cpumask_t *s
 	[BITS_TO_LONGS(NR_CPUS)-1] = CPU_MASK_LAST_WORD			\
 } }
 
+/* cpumask_of_cpu_map is in init/main.c */
+#define cpumask_of_cpu(cpu)    (cpumask_of_cpu_map[cpu])
+extern cpumask_t *cpumask_of_cpu_map;
+void setup_cpumask_of_cpu(int num);
+
 #endif
 
 #define CPU_MASK_NONE							\
--- linux.trees.git.orig/init/main.c
+++ linux.trees.git/init/main.c
@@ -367,6 +367,21 @@ static inline void smp_prepare_cpus(unsi
 int nr_cpu_ids __read_mostly = NR_CPUS;
 EXPORT_SYMBOL(nr_cpu_ids);
 
+#if NR_CPUS > BITS_PER_LONG
+cpumask_t *cpumask_of_cpu_map __read_mostly;
+EXPORT_SYMBOL(cpumask_of_cpu_map);
+
+void __init setup_cpumask_of_cpu(int num)
+{
+	int i;
+
+	/* alloc_bootmem zeroes memory */
+	cpumask_of_cpu_map = alloc_bootmem_low(sizeof(cpumask_t) * num);
+	for (i = 0; i < num; i++)
+		cpu_set(i, cpumask_of_cpu_map[i]);
+}
+#endif
+
 #ifndef CONFIG_HAVE_SETUP_PER_CPU_AREA
 unsigned long __per_cpu_offset[NR_CPUS] __read_mostly;
 EXPORT_SYMBOL(__per_cpu_offset);
@@ -393,6 +408,9 @@ static void __init setup_per_cpu_areas(v
 
 	nr_cpu_ids = highest_cpu + 1;
 	printk(KERN_DEBUG "NR_CPUS:%d (nr_cpu_ids:%d)\n", NR_CPUS, nr_cpu_ids);
+
+	/* Setup cpumask_of_cpu() map */
+	setup_cpumask_of_cpu(nr_cpu_ids);
 }
 #endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
