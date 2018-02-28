Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 258046B0008
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 15:10:50 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id j3so2384518wrb.18
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 12:10:50 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id i1si847359edi.384.2018.02.28.12.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 12:10:48 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 5/7] Pmalloc selftest
Date: Wed, 28 Feb 2018 22:06:18 +0200
Message-ID: <20180228200620.30026-6-igor.stoppa@huawei.com>
In-Reply-To: <20180228200620.30026-1-igor.stoppa@huawei.com>
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Add basic self-test functionality for pmalloc.

The testing is introduced as early as possible, right after the main
dependency, genalloc, has passed successfully, so that it can help
diagnosing failures in pmalloc users.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/test_pmalloc.h |  24 +++++++++++
 init/main.c                  |   2 +
 mm/Kconfig                   |  10 +++++
 mm/Makefile                  |   1 +
 mm/test_pmalloc.c            | 100 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 137 insertions(+)
 create mode 100644 include/linux/test_pmalloc.h
 create mode 100644 mm/test_pmalloc.c

diff --git a/include/linux/test_pmalloc.h b/include/linux/test_pmalloc.h
new file mode 100644
index 000000000000..c7e2e451c17c
--- /dev/null
+++ b/include/linux/test_pmalloc.h
@@ -0,0 +1,24 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * test_pmalloc.h
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+
+#ifndef __LINUX_TEST_PMALLOC_H
+#define __LINUX_TEST_PMALLOC_H
+
+
+#ifdef CONFIG_TEST_PROTECTABLE_MEMORY
+
+void test_pmalloc(void);
+
+#else
+
+static inline void test_pmalloc(void){};
+
+#endif
+
+#endif
diff --git a/init/main.c b/init/main.c
index 2bf1312fd2fe..ea44c940070a 100644
--- a/init/main.c
+++ b/init/main.c
@@ -91,6 +91,7 @@
 #include <linux/rodata_test.h>
 #include <linux/jump_label.h>
 #include <linux/test_genalloc.h>
+#include <linux/test_pmalloc.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -663,6 +664,7 @@ asmlinkage __visible void __init start_kernel(void)
 	mem_encrypt_init();
 
 	test_genalloc();
+	test_pmalloc();
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (initrd_start && !initrd_below_start_ok &&
 	    page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
diff --git a/mm/Kconfig b/mm/Kconfig
index 016d29b9400b..47b0843b02d2 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -767,3 +767,13 @@ config PROTECTABLE_MEMORY
     depends on ARCH_HAS_SET_MEMORY
     select GENERIC_ALLOCATOR
     default y
+
+config TEST_PROTECTABLE_MEMORY
+	bool "Run self test for pmalloc memory allocator"
+        depends on MMU
+	depends on ARCH_HAS_SET_MEMORY
+	select PROTECTABLE_MEMORY
+	default n
+	help
+	  Tries to verify that pmalloc works correctly and that the memory
+	  is effectively protected.
diff --git a/mm/Makefile b/mm/Makefile
index 959fdbdac118..1de4be5fd0bc 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -66,6 +66,7 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_PROTECTABLE_MEMORY) += pmalloc.o
+obj-$(CONFIG_TEST_PROTECTABLE_MEMORY) += test_pmalloc.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
diff --git a/mm/test_pmalloc.c b/mm/test_pmalloc.c
new file mode 100644
index 000000000000..df7ecc91c6a4
--- /dev/null
+++ b/mm/test_pmalloc.c
@@ -0,0 +1,100 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * test_pmalloc.c
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#include <linux/pmalloc.h>
+#include <linux/mm.h>
+#include <linux/test_pmalloc.h>
+#include <linux/bug.h>
+
+#define SIZE_1 (PAGE_SIZE * 3)
+#define SIZE_2 1000
+
+static inline bool validate_alloc(bool expected, void *addr,
+				  unsigned long size)
+{
+	bool test;
+
+	test = is_pmalloc_object(addr, size) > 0;
+	pr_notice("must be %s: %s",
+		  expected ? "ok" : "no", test ? "ok" : "no");
+	return test == expected;
+}
+
+#define is_alloc_ok(variable, size)	\
+	validate_alloc(true, variable, size)
+
+#define is_alloc_no(variable, size)	\
+	validate_alloc(false, variable, size)
+
+void test_pmalloc(void)
+{
+	struct gen_pool *pool_unprot;
+	struct gen_pool *pool_prot;
+	void *var_prot, *var_unprot, *var_vmall;
+
+	pr_notice("pmalloc-selftest");
+	pool_unprot = pmalloc_create_pool("unprotected", 0);
+	if (unlikely(!pool_unprot))
+		goto error;
+	pool_prot = pmalloc_create_pool("protected", 0);
+	if (unlikely(!(pool_prot)))
+		goto error_release;
+
+	pr_notice("Testing allocation capability");
+	var_unprot = pmalloc(pool_unprot,  SIZE_1 - 1, GFP_KERNEL);
+	var_prot = pmalloc(pool_prot,  SIZE_1, GFP_KERNEL);
+	*(int *)var_prot = 0;
+	var_vmall = vmalloc(SIZE_2);
+
+
+	pr_notice("Test correctness of is_pmalloc_object()");
+	WARN_ON(unlikely(!is_alloc_ok(var_unprot, 10)));
+	WARN_ON(unlikely(!is_alloc_ok(var_unprot, SIZE_1)));
+	WARN_ON(unlikely(!is_alloc_ok(var_unprot, PAGE_SIZE)));
+	WARN_ON(unlikely(!is_alloc_no(var_unprot, SIZE_1 + 1)));
+	WARN_ON(unlikely(!is_alloc_no(var_vmall, 10)));
+
+
+	pfree(pool_unprot, var_unprot);
+	vfree(var_vmall);
+
+	pmalloc_protect_pool(pool_prot);
+
+	/*
+	 * This will intentionally trigger a WARN, because the pool being
+	 * allocated from is already protected.
+	 */
+	pr_notice("Test allocation from a protected pool."
+		  "Expect WARN in pmalloc");
+	if (unlikely(pmalloc(pool_prot, 10, GFP_KERNEL)))
+		WARN(true, "no memory from a protected pool");
+
+	/*
+	 * This will intentionally trigger a WARN because the pool being
+	 * destroyed is not protected, which is unusual and should happen
+	 * on error paths only, where probably other warnings are already
+	 * displayed.
+	 */
+	pr_notice("pmalloc-selftest:"
+		  " Expect WARN in pmalloc_pool_set_protection below.");
+	pmalloc_destroy_pool(pool_unprot);
+	pr_notice("pmalloc-selftest:"
+		  "Critical point for expected WARN passed.");
+
+	/* This must not cause WARNings */
+	pr_notice("pmalloc-selftest:"
+		  "Expect no WARN below.");
+	pmalloc_destroy_pool(pool_prot);
+	pr_notice("pmalloc-selftest:"
+		  "Critical point for unexpected WARN passed.");
+	return;
+error_release:
+	pmalloc_destroy_pool(pool_unprot);
+error:
+	WARN(true, "Unable to allocate memory for pmalloc selftest.");
+}
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
