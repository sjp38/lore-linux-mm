Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81BDE6B6EA7
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 07:18:49 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id e8-v6so4511590ljg.22
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 04:18:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o22-v6sor9778807lji.38.2018.12.04.04.18.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 04:18:47 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 5/6] __wr_after_init: test write rare functionality
Date: Tue,  4 Dec 2018 14:18:04 +0200
Message-Id: <20181204121805.4621-6-igor.stoppa@huawei.com>
In-Reply-To: <20181204121805.4621-1-igor.stoppa@huawei.com>
References: <20181204121805.4621-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>
Cc: igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Set of test cases meant to confirm that the write rare functionality
works as expected.

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
 include/linux/prmem.h |   7 ++-
 mm/Kconfig.debug      |   9 +++
 mm/Makefile           |   1 +
 mm/test_write_rare.c  | 135 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 149 insertions(+), 3 deletions(-)
 create mode 100644 mm/test_write_rare.c

diff --git a/include/linux/prmem.h b/include/linux/prmem.h
index b0131c1f5dc0..d2492ec24c8c 100644
--- a/include/linux/prmem.h
+++ b/include/linux/prmem.h
@@ -125,9 +125,10 @@ static inline void *wr_memcpy(void *p, const void *q, __kernel_size_t size)
  *
  * It is provided as macro, to match rcu_assign_pointer()
  */
-#define wr_rcu_assign_pointer(p, v) ({					\
-	__wr_op((unsigned long)&p, v, sizeof(p), WR_RCU_ASSIGN_PTR);	\
-	p;								\
+#define wr_rcu_assign_pointer(p, v) ({				\
+	__wr_op((unsigned long)&p, (unsigned long)v, sizeof(p),	\
+		WR_RCU_ASSIGN_PTR);				\
+	p;							\
 })
 #endif
 #endif
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 9a7b8b049d04..a26ecbd27aea 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -94,3 +94,12 @@ config DEBUG_RODATA_TEST
     depends on STRICT_KERNEL_RWX
     ---help---
       This option enables a testcase for the setting rodata read-only.
+
+config DEBUG_PRMEM_TEST
+    tristate "Run self test for statically allocated protected memory"
+    depends on STRICT_KERNEL_RWX
+    select PRMEM
+    default n
+    help
+      Tries to verify that the protection for statically allocated memory
+      works correctly and that the memory is effectively protected.
diff --git a/mm/Makefile b/mm/Makefile
index ef3867c16ce0..8de1d468f4e7 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_PRMEM) += prmem.o
+obj-$(CONFIG_DEBUG_PRMEM_TEST) += test_write_rare.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
diff --git a/mm/test_write_rare.c b/mm/test_write_rare.c
new file mode 100644
index 000000000000..240cc43793d1
--- /dev/null
+++ b/mm/test_write_rare.c
@@ -0,0 +1,135 @@
+// SPDX-License-Identifier: GPL-2.0
+
+/*
+ * test_write_rare.c
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/bug.h>
+#include <linux/prmem.h>
+
+#ifdef pr_fmt
+#undef pr_fmt
+#endif
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+extern long __start_wr_after_init;
+extern long __end_wr_after_init;
+
+static __wr_after_init int scalar = '0';
+static __wr_after_init u8 array[PAGE_SIZE * 3] __aligned(PAGE_SIZE);
+
+/* The section must occupy a non-zero number of whole pages */
+static bool test_alignment(void)
+{
+	unsigned long pstart = (unsigned long)&__start_wr_after_init;
+	unsigned long pend = (unsigned long)&__end_wr_after_init;
+
+	if (WARN((pstart & ~PAGE_MASK) || (pend & ~PAGE_MASK) ||
+		 (pstart >= pend), "Boundaries test failed."))
+		return false;
+	pr_info("Boundaries test passed.");
+	return true;
+}
+
+static inline bool test_pattern(void)
+{
+	return (memtst(array, '0', PAGE_SIZE / 2) ||
+		memtst(array + PAGE_SIZE / 2, '1', PAGE_SIZE * 3 / 4) ||
+		memtst(array + PAGE_SIZE * 5 / 4, '0', PAGE_SIZE / 2) ||
+		memtst(array + PAGE_SIZE * 7 / 4, '1', PAGE_SIZE * 3 / 4) ||
+		memtst(array + PAGE_SIZE * 5 / 2, '0', PAGE_SIZE / 2));
+}
+
+static bool test_wr_memset(void)
+{
+	int new_val = '1';
+
+	wr_memset(&scalar, new_val, sizeof(scalar));
+	if (WARN(memtst(&scalar, new_val, sizeof(scalar)),
+		 "Scalar write rare memset test failed."))
+		return false;
+
+	pr_info("Scalar write rare memset test passed.");
+
+	wr_memset(array, '0', PAGE_SIZE * 3);
+	if (WARN(memtst(array, '0', PAGE_SIZE * 3),
+		 "Array write rare memset test failed."))
+		return false;
+
+	wr_memset(array + PAGE_SIZE / 2, '1', PAGE_SIZE * 2);
+	if (WARN(memtst(array + PAGE_SIZE / 2, '1', PAGE_SIZE * 2),
+		 "Array write rare memset test failed."))
+		return false;
+
+	wr_memset(array + PAGE_SIZE * 5 / 4, '0', PAGE_SIZE / 2);
+	if (WARN(memtst(array + PAGE_SIZE * 5 / 4, '0', PAGE_SIZE / 2),
+		 "Array write rare memset test failed."))
+		return false;
+
+	if (WARN(test_pattern(), "Array write rare memset test failed."))
+		return false;
+
+	pr_info("Array write rare memset test passed.");
+	return true;
+}
+
+static u8 array_1[PAGE_SIZE * 2];
+static u8 array_2[PAGE_SIZE * 2];
+
+static bool test_wr_memcpy(void)
+{
+	int new_val = 0x12345678;
+
+	wr_assign(scalar, new_val);
+	if (WARN(memcmp(&scalar, &new_val, sizeof(scalar)),
+		 "Scalar write rare memcpy test failed."))
+		return false;
+	pr_info("Scalar write rare memcpy test passed.");
+
+	wr_memset(array, '0', PAGE_SIZE * 3);
+	memset(array_1, '1', PAGE_SIZE * 2);
+	memset(array_2, '0', PAGE_SIZE * 2);
+	wr_memcpy(array + PAGE_SIZE / 2, array_1, PAGE_SIZE * 2);
+	wr_memcpy(array + PAGE_SIZE * 5 / 4, array_2, PAGE_SIZE / 2);
+
+	if (WARN(test_pattern(), "Array write rare memcpy test failed."))
+		return false;
+
+	pr_info("Array write rare memcpy test passed.");
+	return true;
+}
+
+static __wr_after_init int *dst;
+static int reference = 0x54;
+
+static bool test_wr_rcu_assign_pointer(void)
+{
+	wr_rcu_assign_pointer(dst, &reference);
+	return dst == &reference;
+}
+
+static int __init test_static_wr_init_module(void)
+{
+	pr_info("static write_rare test");
+	if (WARN(!(test_alignment() &&
+		   test_wr_memset() &&
+		   test_wr_memcpy() &&
+		   test_wr_rcu_assign_pointer()),
+		 "static rare-write test failed"))
+		return -EFAULT;
+	pr_info("static write_rare test passed");
+	return 0;
+}
+
+module_init(test_static_wr_init_module);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Igor Stoppa <igor.stoppa@huawei.com>");
+MODULE_DESCRIPTION("Test module for static write rare.");
-- 
2.19.1
