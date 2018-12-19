Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 03/12] __wr_after_init: generic header
Date: Wed, 19 Dec 2018 23:33:29 +0200
Message-Id: <20181219213338.26619-4-igor.stoppa@huawei.com>
In-Reply-To: <20181219213338.26619-1-igor.stoppa@huawei.com>
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The header provides:
- the generic part of the write rare functionality for static data
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
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 include/linux/prmem.h | 142 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 142 insertions(+)
 create mode 100644 include/linux/prmem.h

diff --git a/include/linux/prmem.h b/include/linux/prmem.h
new file mode 100644
index 000000000000..7b8f3a054d97
--- /dev/null
+++ b/include/linux/prmem.h
@@ -0,0 +1,142 @@
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
+/*
+ * If CONFIG_PRMEM is enabled, the ARCH code must provide an
+ * implementation for __wr_op()
+ */
+
+enum wr_op_type {
+	WR_MEMCPY,
+	WR_MEMSET,
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
-- 
2.19.1
