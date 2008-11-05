From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 4/7] cpu ops: Core piece for generic atomic per cpu operations
Date: Wed, 05 Nov 2008 17:16:38 -0600
Message-ID: <20081105231648.462808759@quilx.com>
References: <20081105231634.133252042@quilx.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline; filename=cpu_alloc_ops_base
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-Id: linux-mm.kvack.org

Currently the per cpu subsystem is not able to use the atomic capabilities
that are provided by many of the available processors.

This patch adds new functionality that allows the optimizing of per cpu
variable handling. In particular it provides a simple way to exploit
atomic operations in order to avoid having to disable interrupts or
performing address calculation to access per cpu data.

F.e. Using our current methods we may do

	unsigned long flags;
	struct stat_struct *p;

	local_irq_save(flags);
	/* Calculate address of per processor area */
	p = CPU_PTR(stat, smp_processor_id());
	p->counter++;
	local_irq_restore(flags);

The segment can be replaced by a single atomic CPU operation:

	CPU_INC(stat->counter);

Most processors have instructions to perform the increment using a
a single atomic instruction. Processors may have segment registers,
global registers or per cpu mappings of per cpu areas that can be used
to generate atomic instructions that combine the following in a single
operation:

1. Adding of an offset / register to a base address
2. Read modify write operation on the address calculated by
   the instruction.

If 1+2 are combined in an instruction then the instruction is atomic
vs interrupts. This means that percpu atomic operations do not need
to disable interrupts to increments counters etc.

The existing methods in use in the kernel cannot utilize the power of
these atomic instructions. local_t is not really addressing the issue
since the offset calculation performed before the atomic operation. The
operation is therefor not atomic. Disabling interrupt or preemption is
required in order to use local_t.

local_t is also very specific to the x86 processor. The solution here can
utilize other methods than just those provided by the x86 instruction set.



On x86 the above CPU_INC translated into a single instruction:

	inc %%gs:(&stat->counter)

This instruction is interrupt safe since it can either be completed
or not. Both adding of the offset and the read modify write are combined
in one instruction.

The determination of the correct per cpu area for the current processor
does not require access to smp_processor_id() (expensive...). The gs
register is used to provide a processor specific offset to the respective
per cpu area where the per cpu variable resides.

Note that the counter offset into the struct was added *before* the segment
selector was added. This is necessary to avoid calculations.  In the past
we first determine the address of the stats structure on the respective
processor and then added the field offset. However, the offset may as
well be added earlier. The adding of the per cpu offset (here through the
gs register) must be done by the instruction used for atomic per cpu
access.



If "stat" was declared via DECLARE_PER_CPU then this patchset is capable of
convincing the linker to provide the proper base address. In that case
no calculations are necessary.

Should the stat structure be reachable via a register then the address
calculation capabilities can be leveraged to avoid calculations.

On IA64 we can get the same combination of operations in a single instruction
by using the virtual address that always maps to the local per cpu area:

	fetchadd &stat->counter + (VCPU_BASE - __per_cpu_start)

The access is forced into the per cpu address reachable via the virtualized
address. IA64 allows the embedding of an offset into the instruction. So the
fetchadd can perform both the relocation of the pointer into the per cpu
area as well as the atomic read modify write cycle.



In order to be able to exploit the atomicity of these instructions we
introduce a series of new functions that take either:

1. A per cpu pointer as returned by cpu_alloc() or CPU_ALLOC().

2. A per cpu variable address as returned by per_cpu_var(<percpuvarname>).

CPU_READ()
CPU_WRITE()
CPU_INC
CPU_DEC
CPU_ADD
CPU_SUB
CPU_XCHG
CPU_CMPXCHG

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/percpu.h |  135 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 135 insertions(+)

Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2008-11-03 13:27:57.000000000 -0600
+++ linux-2.6/include/linux/percpu.h	2008-11-03 13:28:00.000000000 -0600
@@ -162,4 +162,139 @@
 #define CPU_FREE(pointer)	cpu_free((pointer), sizeof(*(pointer)))
 
 
+/*
+ * Fast atomic per cpu operations.
+ *
+ * The following operations can be overridden by arches to implement fast
+ * and efficient operations. The operations are atomic meaning that the
+ * determination of the processor, the calculation of the address and the
+ * operation on the data is an atomic operation.
+ *
+ * The parameter passed to the atomic per cpu operations is an lvalue not a
+ * pointer to the object.
+ */
+#ifndef CONFIG_HAVE_CPU_OPS
+
+/*
+ * Fallback in case the arch does not provide for atomic per cpu operations.
+ *
+ * The first group of macros is used when it is safe to update the per
+ * cpu variable because preemption is off (per cpu variables that are not
+ * updated from interrupt context) or because interrupts are already off.
+ */
+#define __CPU_READ(var)				\
+({						\
+	(*THIS_CPU(&(var)));			\
+})
+
+#define __CPU_WRITE(var, value)			\
+({						\
+	*THIS_CPU(&(var)) = (value);		\
+})
+
+#define __CPU_ADD(var, value)			\
+({						\
+	*THIS_CPU(&(var)) += (value);		\
+})
+
+#define __CPU_INC(var) __CPU_ADD((var), 1)
+#define __CPU_DEC(var) __CPU_ADD((var), -1)
+#define __CPU_SUB(var, value) __CPU_ADD((var), -(value))
+
+#define __CPU_CMPXCHG(var, old, new)		\
+({						\
+	typeof(obj) x;				\
+	typeof(obj) *p = THIS_CPU(&(obj));	\
+	x = *p;					\
+	if (x == (old))				\
+		*p = (new);			\
+	(x);					\
+})
+
+#define __CPU_XCHG(obj, new)			\
+({						\
+	typeof(obj) x;				\
+	typeof(obj) *p = THIS_CPU(&(obj));	\
+	x = *p;					\
+	*p = (new);				\
+	(x);					\
+})
+
+/*
+ * Second group used for per cpu variables that are not updated from an
+ * interrupt context. In that case we can simply disable preemption which
+ * may be free if the kernel is compiled without support for preemption.
+ */
+#define _CPU_READ __CPU_READ
+#define _CPU_WRITE __CPU_WRITE
+
+#define _CPU_ADD(var, value)			\
+({						\
+	preempt_disable();			\
+	__CPU_ADD((var), (value));		\
+	preempt_enable();			\
+})
+
+#define _CPU_INC(var) _CPU_ADD((var), 1)
+#define _CPU_DEC(var) _CPU_ADD((var), -1)
+#define _CPU_SUB(var, value) _CPU_ADD((var), -(value))
+
+#define _CPU_CMPXCHG(var, old, new)		\
+({						\
+	typeof(addr) x;				\
+	preempt_disable();			\
+	x = __CPU_CMPXCHG((var), (old), (new));	\
+	preempt_enable();			\
+	(x);					\
+})
+
+#define _CPU_XCHG(var, new)			\
+({						\
+	typeof(var) x;				\
+	preempt_disable();			\
+	x = __CPU_XCHG((var), (new));		\
+	preempt_enable();			\
+	(x);					\
+})
+
+/*
+ * Third group: Interrupt safe CPU functions
+ */
+#define CPU_READ __CPU_READ
+#define CPU_WRITE __CPU_WRITE
+
+#define CPU_ADD(var, value)			\
+({						\
+	unsigned long flags;			\
+	local_irq_save(flags);			\
+	__CPU_ADD((var), (value));		\
+	local_irq_restore(flags);		\
+})
+
+#define CPU_INC(var) CPU_ADD((var), 1)
+#define CPU_DEC(var) CPU_ADD((var), -1)
+#define CPU_SUB(var, value) CPU_ADD((var), -(value))
+
+#define CPU_CMPXCHG(var, old, new)		\
+({						\
+	unsigned long flags;			\
+	typeof(var) x;				\
+	local_irq_save(flags);			\
+	x = __CPU_CMPXCHG((var), (old), (new));	\
+	local_irq_restore(flags);		\
+	(x);					\
+})
+
+#define CPU_XCHG(var, new)			\
+({						\
+	unsigned long flags;			\
+	typeof(var) x;				\
+	local_irq_save(flags);			\
+	x = __CPU_XCHG((var), (new));		\
+	local_irq_restore(flags);		\
+	(x);					\
+})
+
+#endif /* CONFIG_HAVE_CPU_OPS */
+
 #endif /* __LINUX_PERCPU_H */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
