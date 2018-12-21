Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9BC8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:14:52 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id l12-v6so1870840ljb.11
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:14:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a12-v6sor15952723lji.34.2018.12.21.10.14.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 10:14:50 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 03/12] __wr_after_init: generic functionality
Date: Fri, 21 Dec 2018 20:14:14 +0200
Message-Id: <20181221181423.20455-4-igor.stoppa@huawei.com>
In-Reply-To: <20181221181423.20455-1-igor.stoppa@huawei.com>
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>
Cc: igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The patch provides:
- the generic part of the write rare functionality for static data,
  based on code from Matthew Wilcox
- the dummy functionality, in case an arch doesn't support write rare or
  the functionality is disabled

The basic functions are:
- wr_memset(): write rare counterpart of memset()
- wr_memcpy(): write rare counterpart of memcpy()
- wr_assign(): write rare counterpart of the assignment ('=') operator
- wr_rcu_assign_pointer(): write rare counterpart of rcu_assign_pointer()

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 include/linux/prmem.h | 106 ++++++++++++++++++++++++++++++++++++++++++
 mm/Makefile           |   1 +
 mm/prmem.c            |  97 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 204 insertions(+)
 create mode 100644 include/linux/prmem.h
 create mode 100644 mm/prmem.c

diff --git a/include/linux/prmem.h b/include/linux/prmem.h
new file mode 100644
index 000000000000..12c1d0d1cb78
--- /dev/null
+++ b/include/linux/prmem.h
@@ -0,0 +1,106 @@
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
+#include <linux/mutex.h>
+#include <linux/compiler.h>
+
+
+/**
+ * memtst() - test len bytes starting at p to match the c value
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
+#define wr_rcu_assign_pointer(p, v)	rcu_assign_pointer(p, v)
+
+#else
+
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+
+#include <asm/prmem.h>
+
+void *wr_memset(void *p, int c, __kernel_size_t len);
+void *wr_memcpy(void *p, const void *q, __kernel_size_t size);
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
+ * @p: the rcu pointer - it MUST be aligned to a machine word
+ * @v: the new value
+ *
+ * Returns the value assigned to the rcu pointer.
+ *
+ * It is provided as macro, to match rcu_assign_pointer()
+ * The rcu_assign_pointer() is implemented as equivalent of:
+ *
+ * smp_mb();
+ * WRITE_ONCE();
+ */
+#define wr_rcu_assign_pointer(p, v) ({	\
+	smp_mb();			\
+	wr_assign(p, v);		\
+	p;				\
+})
+#endif
+#endif
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
index 000000000000..e1c1be3a1171
--- /dev/null
+++ b/mm/prmem.c
@@ -0,0 +1,97 @@
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
+__ro_after_init bool wr_ready;
+
+/*
+ * The following two variables are statically allocated by the linker
+ * script at the the boundaries of the memory region (rounded up to
+ * multiples of PAGE_SIZE) reserved for __wr_after_init.
+ */
+extern long __start_wr_after_init;
+extern long __end_wr_after_init;
+static unsigned long start = (unsigned long)&__start_wr_after_init;
+static unsigned long end = (unsigned long)&__end_wr_after_init;
+
+static inline bool is_wr_after_init(void *p, __kernel_size_t size)
+{
+	unsigned long low = (unsigned long)p;
+	unsigned long high = low + size;
+
+	return likely(start <= low && high <= end);
+}
+
+/**
+ * wr_memcpy() - copyes size bytes from q to p
+ * @p: beginning of the memory to write to
+ * @q: beginning of the memory to read from
+ * @size: amount of bytes to copy
+ *
+ * Returns pointer to the destination
+ *
+ * The architecture code must provide:
+ *   void __wr_enable(wr_state_t *state)
+ *   void *__wr_addr(void *addr)
+ *   void *__wr_memcpy(void *p, const void *q, __kernel_size_t size)
+ *   void __wr_disable(wr_state_t *state)
+ */
+void *wr_memcpy(void *p, const void *q, __kernel_size_t size)
+{
+	wr_state_t wr_state;
+	void *wr_poking_addr = __wr_addr(p);
+
+	if (WARN_ONCE(!wr_ready, "No writable mapping available") ||
+	    WARN_ONCE(!is_wr_after_init(p, size), "Invalid WR range."))
+		return p;
+
+	local_irq_disable();
+	__wr_enable(&wr_state);
+	__wr_memcpy(wr_poking_addr, q, size);
+	__wr_disable(&wr_state);
+	local_irq_enable();
+	return p;
+}
+
+/**
+ * wr_memset() - sets len bytes of the destination p to the c value
+ * @p: beginning of the memory to write to
+ * @c: byte to replicate
+ * @len: amount of bytes to copy
+ *
+ * Returns pointer to the destination
+ *
+ * The architecture code must provide:
+ *   void __wr_enable(wr_state_t *state)
+ *   void *__wr_addr(void *addr)
+ *   void *__wr_memset(void *p, int c, __kernel_size_t len)
+ *   void __wr_disable(wr_state_t *state)
+ */
+void *wr_memset(void *p, int c, __kernel_size_t len)
+{
+	wr_state_t wr_state;
+	void *wr_poking_addr = __wr_addr(p);
+
+	if (WARN_ONCE(!wr_ready, "No writable mapping available") ||
+	    WARN_ONCE(!is_wr_after_init(p, len), "Invalid WR range."))
+		return p;
+
+	local_irq_disable();
+	__wr_enable(&wr_state);
+	__wr_memset(wr_poking_addr, c, len);
+	__wr_disable(&wr_state);
+	local_irq_enable();
+	return p;
+}
-- 
2.19.1
