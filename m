Message-Id: <20080331154154.727092000@polaris-admin.engr.sgi.com>
References: <20080331154154.549122000@polaris-admin.engr.sgi.com>
Date: Mon, 31 Mar 2008 08:41:55 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 1/1] asm-generic: add node_to_cpumask_ptr macro
Content-Disposition: inline; filename=node_to_cpumask_ptr-base
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, "David S. Miller" <davem@davemloft.net>, "William L. Irwin" <wli@holomorphy.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Create a simple macro to always return a pointer to the node_to_cpumask(node)
value.  This relies on compiler optimization to remove the extra indirection:

    #define node_to_cpumask_ptr(v, node) 		\
	    cpumask_t _##v = node_to_cpumask(node), *v = &_##v

For those systems with a large cpumask size, then a true pointer
to the array element can be used:

    #define node_to_cpumask_ptr(v, node)		\
	    cpumask_t *v = &(node_to_cpumask_map[node])

A node_to_cpumask_ptr_next() macro is provided to access another
node_to_cpumask value.

The other change is to always include asm-generic/topology.h moving the
ifdef CONFIG_NUMA to this same file.


Note: there are no references to either of these new macros in this patch,
only the definition.

Based on 2.6.25-rc5-mm1

# alpha
Cc: Richard Henderson <rth@twiddle.net>

# fujitsu
Cc: David Howells <dhowells@redhat.com>

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


Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/asm-alpha/topology.h   |    3 +--
 include/asm-frv/topology.h     |    4 +---
 include/asm-generic/topology.h |   14 ++++++++++++++
 include/asm-ia64/topology.h    |    5 +++++
 include/asm-powerpc/topology.h |    3 +--
 include/asm-x86/topology.h     |   15 +++++++++++++--
 6 files changed, 35 insertions(+), 9 deletions(-)

--- linux-2.6.25-rc5.orig/include/asm-alpha/topology.h
+++ linux-2.6.25-rc5/include/asm-alpha/topology.h
@@ -41,8 +41,7 @@ static inline cpumask_t node_to_cpumask(
 
 #define pcibus_to_cpumask(bus)	(cpu_online_map)
 
-#else /* CONFIG_NUMA */
-# include <asm-generic/topology.h>
 #endif /* !CONFIG_NUMA */
+# include <asm-generic/topology.h>
 
 #endif /* _ASM_ALPHA_TOPOLOGY_H */
--- linux-2.6.25-rc5.orig/include/asm-frv/topology.h
+++ linux-2.6.25-rc5/include/asm-frv/topology.h
@@ -5,10 +5,8 @@
 
 #error NUMA not supported yet
 
-#else /* !CONFIG_NUMA */
+#endif /* CONFIG_NUMA */
 
 #include <asm-generic/topology.h>
 
-#endif /* CONFIG_NUMA */
-
 #endif /* _ASM_TOPOLOGY_H */
--- linux-2.6.25-rc5.orig/include/asm-generic/topology.h
+++ linux-2.6.25-rc5/include/asm-generic/topology.h
@@ -27,6 +27,8 @@
 #ifndef _ASM_GENERIC_TOPOLOGY_H
 #define _ASM_GENERIC_TOPOLOGY_H
 
+#ifndef	CONFIG_NUMA
+
 /* Other architectures wishing to use this simple topology API should fill
    in the below functions as appropriate in their own <asm/topology.h> file. */
 #ifndef cpu_to_node
@@ -52,4 +54,16 @@
 				)
 #endif
 
+#endif	/* CONFIG_NUMA */
+
+/* returns pointer to cpumask for specified node */
+#ifndef node_to_cpumask_ptr
+
+#define	node_to_cpumask_ptr(v, node) 					\
+		cpumask_t _##v = node_to_cpumask(node), *v = &_##v
+
+#define node_to_cpumask_ptr_next(v, node)				\
+			  _##v = node_to_cpumask(node)
+#endif
+
 #endif /* _ASM_GENERIC_TOPOLOGY_H */
--- linux-2.6.25-rc5.orig/include/asm-ia64/topology.h
+++ linux-2.6.25-rc5/include/asm-ia64/topology.h
@@ -116,6 +116,11 @@ void build_cpu_to_node_map(void);
 #define smt_capable() 				(smp_num_siblings > 1)
 #endif
 
+#define pcibus_to_cpumask(bus)	(pcibus_to_node(bus) == -1 ? \
+					CPU_MASK_ALL : \
+					node_to_cpumask(pcibus_to_node(bus)) \
+				)
+
 #include <asm-generic/topology.h>
 
 #endif /* _ASM_IA64_TOPOLOGY_H */
--- linux-2.6.25-rc5.orig/include/asm-powerpc/topology.h
+++ linux-2.6.25-rc5/include/asm-powerpc/topology.h
@@ -96,11 +96,10 @@ static inline void sysfs_remove_device_f
 {
 }
 
+#endif /* CONFIG_NUMA */
 
 #include <asm-generic/topology.h>
 
-#endif /* CONFIG_NUMA */
-
 #ifdef CONFIG_SMP
 #include <asm/cputable.h>
 #define smt_capable()		(cpu_has_feature(CPU_FTR_SMT))
--- linux-2.6.25-rc5.orig/include/asm-x86/topology.h
+++ linux-2.6.25-rc5/include/asm-x86/topology.h
@@ -81,6 +81,17 @@ static inline int cpu_to_node(int cpu)
 	else
 		return NUMA_NO_NODE;
 }
+
+#ifdef	CONFIG_NUMA
+
+/* Returns a pointer to the cpumask of CPUs on Node 'node'. */
+#define node_to_cpumask_ptr(v, node)		\
+		cpumask_t *v = &(node_to_cpumask_map[node])
+
+#define node_to_cpumask_ptr_next(v, node)	\
+			   v = &(node_to_cpumask_map[node])
+#endif
+
 #endif /* CONFIG_X86_64 */
 
 /*
@@ -167,10 +178,10 @@ extern int __node_distance(int, int);
 
 #else /* CONFIG_NUMA */
 
-#include <asm-generic/topology.h>
-
 #endif
 
+#include <asm-generic/topology.h>
+
 extern cpumask_t cpu_coregroup_map(int cpu);
 
 #ifdef ENABLE_TOPO_DEFINES

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
