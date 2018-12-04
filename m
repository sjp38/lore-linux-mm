Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id BAEBF6B6EA4
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 07:18:45 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id z25so1865813lfi.18
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 04:18:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s74-v6sor9793333lje.7.2018.12.04.04.18.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 04:18:43 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 2/6] __wr_after_init: write rare for static allocation
Date: Tue,  4 Dec 2018 14:18:01 +0200
Message-Id: <20181204121805.4621-3-igor.stoppa@huawei.com>
In-Reply-To: <20181204121805.4621-1-igor.stoppa@huawei.com>
References: <20181204121805.4621-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>
Cc: igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Implementation of write rare for statically allocated data, located in a
specific memory section through the use of the __write_rare label.

The basic functions are:
- wr_memset(): write rare counterpart of memset()
- wr_memcpy(): write rare counterpart of memcpy()
- wr_assign(): write rare counterpart of the assignment ('=') operator
- wr_rcu_assign_pointer(): write rare counterpart of rcu_assign_pointer()

The implementation is based on code from Andy Lutomirski and Nadav Amit
for patching the text on x86 [here goes reference to commits, once merged]

The modification of write protected data is done through an alternate
mapping of the same pages, as writable.
This mapping is local to each core and is active only for the duration
of each write operation.
Local interrupts are disabled, while the alternate mapping is active.

In theory, it could introduce a non-predictable delay, in a preemptible
system, however the amount of data to be altered is likely to be far
smaller than a page.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 include/linux/prmem.h | 133 ++++++++++++++++++++++++++++++++++++++++++
 init/main.c           |   2 +
 mm/Kconfig            |   4 ++
 mm/Makefile           |   1 +
 mm/prmem.c            | 124 +++++++++++++++++++++++++++++++++++++++
 5 files changed, 264 insertions(+)
 create mode 100644 include/linux/prmem.h
 create mode 100644 mm/prmem.c

diff --git a/include/linux/prmem.h b/include/linux/prmem.h
new file mode 100644
index 000000000000..b0131c1f5dc0
--- /dev/null
+++ b/include/linux/prmem.h
@@ -0,0 +1,133 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * prmem.h: Header for memory protection library
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ *
+ * Support for:
+ * - statically allocated write rare data
+ */
+
+#ifndef _LINUX_PRMEM_H
+#define _LINUX_PRMEM_H
+
+#include <linux/set_memory.h>
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <linux/mutex.h>
+#include <linux/compiler.h>
+#include <linux/irqflags.h>
+
+/**
+ * memtst() - test n bytes of the source to match the c value
+ * @p: beginning of the memory to test
+ * @c: byte to compare against
+ * @len: amount of bytes to test
+ *
+ * Returns 0 on success, non-zero otherwise.
+ */
+static inline int memtst(void *p, int c, __kernel_size_t len)
+{
+	__kernel_size_t i;
+
+	for (i = 0; i < len; i++) {
+		u8 d =  *(i + (u8 *)p) - (u8)c;
+
+		if (unlikely(d))
+			return d;
+	}
+	return 0;
+}
+
+
+#ifndef CONFIG_PRMEM
+
+static inline void *wr_memset(void *p, int c, __kernel_size_t len)
+{
+	return memset(p, c, len);
+}
+
+static inline void *wr_memcpy(void *p, const void *q, __kernel_size_t size)
+{
+	return memcpy(p, q, size);
+}
+
+#define wr_assign(var, val)	((var) = (val))
+
+#define wr_rcu_assign_pointer(p, v)	\
+	rcu_assign_pointer(p, v)
+
+#else
+
+enum wr_op_type {
+	WR_MEMCPY,
+	WR_MEMSET,
+	WR_RCU_ASSIGN_PTR,
+	WR_OPS_NUMBER,
+};
+
+void *__wr_op(unsigned long dst, unsigned long src, __kernel_size_t len,
+	      enum wr_op_type op);
+
+/**
+ * wr_memset() - sets n bytes of the destination to the c value
+ * @p: beginning of the memory to write to
+ * @c: byte to replicate
+ * @len: amount of bytes to copy
+ *
+ * Returns true on success, false otherwise.
+ */
+static inline void *wr_memset(void *p, int c, __kernel_size_t len)
+{
+	return __wr_op((unsigned long)p, (unsigned long)c, len, WR_MEMSET);
+}
+
+/**
+ * wr_memcpy() - copyes n bytes from source to destination
+ * @dst: beginning of the memory to write to
+ * @src: beginning of the memory to read from
+ * @n_bytes: amount of bytes to copy
+ *
+ * Returns pointer to the destination
+ */
+static inline void *wr_memcpy(void *p, const void *q, __kernel_size_t size)
+{
+	return __wr_op((unsigned long)p, (unsigned long)q, size, WR_MEMCPY);
+}
+
+/**
+ * wr_assign() - sets a write-rare variable to a specified value
+ * @var: the variable to set
+ * @val: the new value
+ *
+ * Returns: the variable
+ *
+ * Note: it might be possible to optimize this, to use wr_memset in some
+ * cases (maybe with NULL?).
+ */
+
+#define wr_assign(var, val) ({			\
+	typeof(var) tmp = (typeof(var))val;	\
+						\
+	wr_memcpy(&var, &tmp, sizeof(var));	\
+	var;					\
+})
+
+/**
+ * wr_rcu_assign_pointer() - initialize a pointer in rcu mode
+ * @p: the rcu pointer
+ * @v: the new value
+ *
+ * Returns the value assigned to the rcu pointer.
+ *
+ * It is provided as macro, to match rcu_assign_pointer()
+ */
+#define wr_rcu_assign_pointer(p, v) ({					\
+	__wr_op((unsigned long)&p, v, sizeof(p), WR_RCU_ASSIGN_PTR);	\
+	p;								\
+})
+#endif
+#endif
diff --git a/init/main.c b/init/main.c
index a461150adfb1..a36f2e54f937 100644
--- a/init/main.c
+++ b/init/main.c
@@ -498,6 +498,7 @@ void __init __weak thread_stack_cache_init(void)
 void __init __weak mem_encrypt_init(void) { }
 
 void __init __weak poking_init(void) { }
+void __init __weak wr_poking_init(void) { }
 
 bool initcall_debug;
 core_param(initcall_debug, initcall_debug, bool, 0644);
@@ -734,6 +735,7 @@ asmlinkage __visible void __init start_kernel(void)
 	delayacct_init();
 
 	poking_init();
+	wr_poking_init();
 	check_bugs();
 
 	acpi_subsystem_init();
diff --git a/mm/Kconfig b/mm/Kconfig
index d85e39da47ae..9b09339c027f 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -142,6 +142,10 @@ config ARCH_DISCARD_MEMBLOCK
 config MEMORY_ISOLATION
 	bool
 
+config PRMEM
+	def_bool n
+	depends on STRICT_KERNEL_RWX && X86_64
+
 #
 # Only be set on architectures that have completely implemented memory hotplug
 # feature. If you are not sure, don't touch it.
diff --git a/mm/Makefile b/mm/Makefile
index d210cc9d6f80..ef3867c16ce0 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -58,6 +58,7 @@ obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
+obj-$(CONFIG_PRMEM) += prmem.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
diff --git a/mm/prmem.c b/mm/prmem.c
new file mode 100644
index 000000000000..e8ab76701831
--- /dev/null
+++ b/mm/prmem.c
@@ -0,0 +1,124 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * prmem.c: Memory Protection Library
+ *
+ * (C) Copyright 2017-2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#include <linux/mm.h>
+#include <linux/string.h>
+#include <linux/compiler.h>
+#include <linux/slab.h>
+#include <linux/mmu_context.h>
+#include <linux/rcupdate.h>
+#include <linux/prmem.h>
+
+static __ro_after_init bool wr_ready;
+static __ro_after_init struct mm_struct *wr_poking_mm;
+static __ro_after_init unsigned long wr_poking_base;
+
+/*
+ * The following two variables are statically allocated by the linker
+ * script at the the boundaries of the memory region (rounded up to
+ * multiples of PAGE_SIZE) reserved for __wr_after_init.
+ */
+extern long __start_wr_after_init;
+extern long __end_wr_after_init;
+
+static inline bool is_wr_after_init(unsigned long ptr, __kernel_size_t size)
+{
+	unsigned long start = (unsigned long)&__start_wr_after_init;
+	unsigned long end = (unsigned long)&__end_wr_after_init;
+	unsigned long low = ptr;
+	unsigned long high = ptr + size;
+
+	return likely(start <= low && low <= high && high <= end);
+}
+
+
+void *__wr_op(unsigned long dst, unsigned long src, __kernel_size_t len,
+	      enum wr_op_type op)
+{
+	temporary_mm_state_t prev;
+	unsigned long flags;
+	unsigned long offset;
+	unsigned long wr_poking_addr;
+
+	/* Confirm that the writable mapping exists. */
+	BUG_ON(!wr_ready);
+
+	if (WARN_ONCE(op >= WR_OPS_NUMBER, "Invalid WR operation.") ||
+	    WARN_ONCE(!is_wr_after_init(dst, len), "Invalid WR range."))
+		return (void *)dst;
+
+	offset = dst - (unsigned long)&__start_wr_after_init;
+	wr_poking_addr = wr_poking_base + offset;
+	local_irq_save(flags);
+	prev = use_temporary_mm(wr_poking_mm);
+
+	kasan_disable_current();
+	if (op == WR_MEMCPY)
+		memcpy((void *)wr_poking_addr, (void *)src, len);
+	else if (op == WR_MEMSET)
+		memset((u8 *)wr_poking_addr, (u8)src, len);
+	else if (op == WR_RCU_ASSIGN_PTR)
+		/* generic version of rcu_assign_pointer */
+		smp_store_release((void **)wr_poking_addr,
+				  RCU_INITIALIZER((void **)src));
+	kasan_enable_current();
+
+	barrier(); /* XXX redundant? */
+
+	unuse_temporary_mm(prev);
+	/* XXX make the verification optional? */
+	if (op == WR_MEMCPY)
+		BUG_ON(memcmp((void *)dst, (void *)src, len));
+	else if (op == WR_MEMSET)
+		BUG_ON(memtst((void *)dst, (u8)src, len));
+	else if (op == WR_RCU_ASSIGN_PTR)
+		BUG_ON(*(unsigned long *)dst != src);
+	local_irq_restore(flags);
+	return (void *)dst;
+}
+
+struct mm_struct *copy_init_mm(void);
+void __init wr_poking_init(void)
+{
+	unsigned long start = (unsigned long)&__start_wr_after_init;
+	unsigned long end = (unsigned long)&__end_wr_after_init;
+	unsigned long i;
+	unsigned long wr_range;
+
+	wr_poking_mm = copy_init_mm();
+	BUG_ON(!wr_poking_mm);
+
+	/* XXX What if it's too large to fit in the task unmapped mem? */
+	wr_range = round_up(end - start, PAGE_SIZE);
+
+	/* Randomize the poking address base*/
+	wr_poking_base = TASK_UNMAPPED_BASE +
+		(kaslr_get_random_long("Write Rare Poking") & PAGE_MASK) %
+		(TASK_SIZE - (TASK_UNMAPPED_BASE + wr_range));
+
+	/* Create alternate mapping for the entire wr_after_init range. */
+	for (i = start; i < end; i += PAGE_SIZE) {
+		struct page *page;
+		spinlock_t *ptl;
+		pte_t pte;
+		pte_t *ptep;
+		unsigned long wr_poking_addr;
+
+		BUG_ON(!(page = virt_to_page(i)));
+		wr_poking_addr = i - start + wr_poking_base;
+
+		/* The lock is not needed, but avoids open-coding. */
+		ptep = get_locked_pte(wr_poking_mm, wr_poking_addr, &ptl);
+		VM_BUG_ON(!ptep);
+
+		pte = mk_pte(page, PAGE_KERNEL);
+		set_pte_at(wr_poking_mm, wr_poking_addr, ptep, pte);
+		spin_unlock(ptl);
+	}
+	wr_ready = true;
+}
-- 
2.19.1
