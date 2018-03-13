Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC2856B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:51:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id h33so772114wrh.10
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:51:41 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id n77si805629wrb.27.2018.03.13.14.51.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 14:51:40 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 6/8] Pmalloc selftest
Date: Tue, 13 Mar 2018 23:45:52 +0200
Message-ID: <20180313214554.28521-7-igor.stoppa@huawei.com>
In-Reply-To: <20180313214554.28521-1-igor.stoppa@huawei.com>
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, willy@infradead.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Add basic self-test functionality for pmalloc.

The testing is introduced as early as possible, right after the main
dependency, genalloc, has passed successfully, so that it can help
diagnosing failures in pmalloc users.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/test_pmalloc.h |  24 +++++
 init/main.c                  |   2 +
 mm/Kconfig                   |  10 ++
 mm/Makefile                  |   1 +
 mm/test_pmalloc.c            | 238 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 275 insertions(+)
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
index 000000000000..598119ffb0ed
--- /dev/null
+++ b/mm/test_pmalloc.c
@@ -0,0 +1,238 @@
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
+static struct gen_pool *pool_unprot;
+static struct gen_pool *pool_prot;
+static struct gen_pool *pool_pre;
+
+static void *var_prot;
+static void *var_unprot;
+static void *var_vmall;
+
+/**
+ * validate_alloc() - wrapper for is_pmalloc_object with messages
+ * @expected: whether if the test is supposed to be ok or not
+ * @addr: base address of the range to test
+ * @size: length of he range to test
+ */
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
+
+#define is_alloc_ok(variable, size)	\
+	validate_alloc(true, variable, size)
+
+
+#define is_alloc_no(variable, size)	\
+	validate_alloc(false, variable, size)
+
+/**
+ * create_pools() - tries to instantiate the pools needed for the test
+ *
+ * Creates the respective instances for each pool used in the test.
+ * In case of error, it rolls back whatever previous step passed
+ * successfully.
+ *
+ * Return:
+ * * true	- success
+ * * false	- something failed
+ */
+static bool create_pools(void)
+{
+	pr_notice("Testing pool creation capability");
+
+	pool_pre = pmalloc_create_pool("preallocated", 0);
+	if (unlikely(!pool_pre))
+		goto err_pre;
+
+	pool_unprot = pmalloc_create_pool("unprotected", 0);
+	if (unlikely(!pool_unprot))
+		goto err_unprot;
+
+	pool_prot = pmalloc_create_pool("protected", 0);
+	if (unlikely(!(pool_prot)))
+		goto err_prot;
+	return true;
+err_prot:
+	pmalloc_destroy_pool(pool_unprot);
+err_unprot:
+	pmalloc_destroy_pool(pool_pre);
+err_pre:
+	WARN(true, "Unable to allocate memory for pmalloc selftest.");
+	return false;
+}
+
+
+/**
+ * destroy_pools() - tears down the instances of the pools in use
+ *
+ * Mostly used on the path for error recovery, when something goes wrong,
+ * the pools allocated are dropped.
+ */
+static void destroy_pools(void)
+{
+	pmalloc_destroy_pool(pool_prot);
+	pmalloc_destroy_pool(pool_unprot);
+	pmalloc_destroy_pool(pool_pre);
+}
+
+
+/**
+ * test_alloc() - verifies that it's possible to allocate from the pools
+ *
+ * Each of the pools declared must be available for allocation, at this
+ * point. There is also a small allocation from generic vmallco memory.
+ */
+static bool test_alloc(void)
+{
+	pr_notice("Testing allocation capability");
+
+	var_vmall = vmalloc(SIZE_2);
+	if (unlikely(!var_vmall))
+		goto err_vmall;
+
+	var_unprot = pmalloc(pool_unprot,  SIZE_1 - 1, GFP_KERNEL);
+	if (unlikely(!var_unprot))
+		goto err_unprot;
+
+	var_prot = pmalloc(pool_prot,  SIZE_1, GFP_KERNEL);
+	if (unlikely(!var_prot))
+		goto err_prot;
+
+	return true;
+err_prot:
+	pfree(pool_unprot, var_unprot);
+err_unprot:
+	vfree(var_vmall);
+err_vmall:
+	WARN(true, "Unable to allocate memory for pmalloc selftest.");
+	return false;
+}
+
+
+/**
+ * test_is_pmalloc_object() - tests the identification of pmalloc ranges
+ *
+ * Positive and negative test of potential pmalloc objects.
+ *
+ * Return:
+ * * true	- success
+ * * false	- error
+ */
+static bool test_is_pmalloc_object(void)
+{
+	pr_notice("Test correctness of is_pmalloc_object()");
+	if (WARN_ON(unlikely(!is_alloc_ok(var_unprot, 10))) ||
+	    WARN_ON(unlikely(!is_alloc_ok(var_unprot, SIZE_1))) ||
+	    WARN_ON(unlikely(!is_alloc_ok(var_unprot, PAGE_SIZE))) ||
+	    WARN_ON(unlikely(!is_alloc_no(var_unprot, SIZE_1 + 1))) ||
+	    WARN_ON(unlikely(!is_alloc_no(var_vmall, 10))))
+		return false;
+	return true;
+}
+
+
+/**
+ * test_protected_allocation() - allocation from protected pool must fail
+ *
+ * Once the pool is protected, the pages associated with it become
+ * read-only and any further attempt to allocate data will be declined.
+ *
+ * Return:
+ * * true	- success
+ * * false	- error
+ */
+static bool test_protected_allocation(void)
+{
+	pmalloc_protect_pool(pool_prot);
+	/*
+	 * This will intentionally trigger a WARN, because the pool being
+	 * allocated from is already protected.
+	 */
+	pr_notice("Test allocation from a protected pool. It will WARN.");
+	return !WARN(unlikely(pmalloc(pool_prot, 10, GFP_KERNEL)),
+		     "no memory from a protected pool");
+}
+
+
+/**
+ * test_destroy_pool() - destroying an unprotected pool must WARN
+ *
+ * Attempting to destroy an unprotected pool will issue a warning, while
+ * destroying a protected pool is considered to be the normal behavior.
+ */
+static void test_destroy_pools(void)
+{
+	/*
+	 * This will intentionally trigger a WARN because the pool being
+	 * destroyed is not protected, which is unusual and should happen
+	 * on error paths only, where probably other warnings are already
+	 * displayed.
+	 */
+	pr_notice("pmalloc-selftest: WARN in pmalloc_pool_set_protection.");
+	pmalloc_destroy_pool(pool_unprot);
+	pr_notice("pmalloc-selftest: point for expected WARN passed.");
+
+	/* This must not cause WARNings */
+	pr_notice("pmalloc-selftest: Expect no WARN below.");
+	pmalloc_destroy_pool(pool_prot);
+	pr_notice("pmalloc-selftest: passed point for unexpected WARN.");
+}
+
+
+/**
+ * test_pmalloc() - main entry point for running the test cases
+ *
+ * Performs various tests, each step subordinate to the successful
+ * execution of the previous.
+ */
+void test_pmalloc(void)
+{
+
+	pr_notice("pmalloc-selftest");
+
+	if (unlikely(!create_pools()))
+		return;
+
+	if (unlikely(!test_alloc()))
+		goto err_alloc;
+
+
+	if (unlikely(!test_is_pmalloc_object()))
+		goto err_is_object;
+
+	*(int *)var_prot = 0;
+	pfree(pool_unprot, var_unprot);
+	vfree(var_vmall);
+
+	if (unlikely(!test_protected_allocation()))
+		goto err_prot_all;
+
+	test_destroy_pools();
+	return;
+err_prot_all:
+err_is_object:
+err_alloc:
+	destroy_pools();
+}
-- 
2.14.1
