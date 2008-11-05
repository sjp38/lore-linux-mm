From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 5/7] x86_64: Support for cpu ops
Date: Wed, 05 Nov 2008 17:16:39 -0600
Message-ID: <20081105231649.108433550@quilx.com>
References: <20081105231634.133252042@quilx.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline; filename=cpu_alloc_ops_x86
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-Id: linux-mm.kvack.org

Support fast cpu ops in x86_64 by providing a series of functions that
generate the proper instructions.

Define CONFIG_HAVE_CPU_OPS so that core code
can exploit the availability of fast per cpu operations.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 arch/x86/Kconfig         |    9 +++++++++
 include/asm-x86/percpu.h |   40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

Index: linux-2.6/arch/x86/Kconfig
===================================================================
--- linux-2.6.orig/arch/x86/Kconfig	2008-10-23 15:21:50.000000000 -0500
+++ linux-2.6/arch/x86/Kconfig	2008-10-23 15:32:18.000000000 -0500
@@ -164,6 +164,15 @@
 	depends on GENERIC_HARDIRQS && SMP
 	default y
 
+#
+# X86_64's spare segment register points to the PDA instead of the per
+# cpu area. Therefore x86_64 is not able to generate atomic vs. interrupt
+# per cpu instructions.
+#
+config HAVE_CPU_OPS
+	def_bool y
+	depends on X86_32
+
 config X86_SMP
 	bool
 	depends on SMP && ((X86_32 && !X86_VOYAGER) || X86_64)
Index: linux-2.6/arch/x86/include/asm/percpu.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/percpu.h	2008-10-23 15:21:50.000000000 -0500
+++ linux-2.6/arch/x86/include/asm/percpu.h	2008-10-23 15:33:55.000000000 -0500
@@ -162,6 +162,53 @@
 	ret__;						\
 })
 
+#define percpu_addr_op(op, var)				\
+({							\
+	switch (sizeof(var)) {				\
+	case 1:						\
+		asm(op "b "__percpu_seg"%0"		\
+				: : "m"(var));		\
+		break;					\
+	case 2:						\
+		asm(op "w "__percpu_seg"%0"		\
+				: : "m"(var));		\
+		break;					\
+	case 4:						\
+		asm(op "l "__percpu_seg"%0"		\
+				: : "m"(var));		\
+	break;					\
+		default: __bad_percpu_size();			\
+	}						\
+})
+
+#define percpu_cmpxchg_op(var, old, new)				\
+({									\
+	typeof(var) prev;						\
+	switch (sizeof(var)) {						\
+	case 1:								\
+		asm("cmpxchgb %b1, "__percpu_seg"%2"			\
+				     : "=a"(prev)			\
+				     : "q"(new), "m"(var), "0"(old)	\
+				     : "memory");			\
+		break;							\
+	case 2:								\
+		asm("cmpxchgw %w1, "__percpu_seg"%2"			\
+				     : "=a"(prev)			\
+				     : "r"(new), "m"(var), "0"(old)	\
+				     : "memory");			\
+		break;							\
+	case 4:								\
+		asm("cmpxchgl %k1, "__percpu_seg"%2"			\
+				     : "=a"(prev)			\
+				     : "r"(new), "m"(var), "0"(old)	\
+				     : "memory");			\
+		break;							\
+	default:							\
+		__bad_percpu_size();					\
+	}								\
+	return prev;							\
+})
+
 #define x86_read_percpu(var) percpu_from_op("mov", per_cpu__##var)
 #define x86_write_percpu(var, val) percpu_to_op("mov", per_cpu__##var, val)
 #define x86_add_percpu(var, val) percpu_to_op("add", per_cpu__##var, val)
@@ -215,4 +262,44 @@
 
 #endif	/* !CONFIG_SMP */
 
+/*
+ * x86_64 uses available segment register for pda instead of per cpu access.
+ * Therefore we cannot generate these atomic vs. interrupt instructions
+ * on x86_64.
+ */
+#ifdef CONFIG_X86_32
+
+#define CPU_READ(obj)		percpu_from_op("mov", obj)
+#define CPU_WRITE(obj,val)	percpu_to_op("mov", obj, val)
+#define CPU_ADD(obj,val)	percpu_to_op("add", obj, val)
+#define CPU_SUB(obj,val)	percpu_to_op("sub", obj, val)
+#define CPU_INC(obj)		percpu_addr_op("inc", obj)
+#define CPU_DEC(obj)		percpu_addr_op("dec", obj)
+#define CPU_XCHG(obj,val)	percpu_to_op("xchg", var, val)
+#define CPU_CMPXCHG(obj, old, new) percpu_cmpxchg_op(var, old, new)
+
+/*
+ * All cpu operations are interrupt safe and do not need to disable
+ * preempt. So the other variants all reduce to the same instruction.
+ */
+#define _CPU_READ CPU_READ
+#define _CPU_WRITE CPU_WRITE
+#define _CPU_ADD CPU_ADD
+#define _CPU_SUB CPU_SUB
+#define _CPU_INC CPU_INC
+#define _CPU_DEC CPU_DEC
+#define _CPU_XCHG CPU_XCHG
+#define _CPU_CMPXCHG CPU_CMPXCHG
+
+#define __CPU_READ CPU_READ
+#define __CPU_WRITE CPU_WRITE
+#define __CPU_ADD CPU_ADD
+#define __CPU_SUB CPU_SUB
+#define __CPU_INC CPU_INC
+#define __CPU_DEC CPU_DEC
+#define __CPU_XCHG CPU_XCHG
+#define __CPU_CMPXCHG CPU_CMPXCHG
+
+#endif /* CONFIG_X86_32 */
+
 #endif /* _ASM_X86_PERCPU_H */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
