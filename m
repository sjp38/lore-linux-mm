Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79F4F6B0006
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 12:01:36 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id i12so14239208wra.22
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 09:01:36 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 64si4127066edo.500.2018.02.04.09.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Feb 2018 09:01:34 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 5/6] Pmalloc: self-test
Date: Sun, 4 Feb 2018 19:00:55 +0200
Message-ID: <20180204170056.28772-1-igor.stoppa@huawei.com>
In-Reply-To: <20180204164732.28241-1-igor.stoppa@huawei.com>
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Add basic self-test functionality for pmalloc.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 mm/Kconfig            |  9 ++++++++
 mm/Makefile           |  1 +
 mm/pmalloc-selftest.c | 61 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/pmalloc-selftest.h | 26 ++++++++++++++++++++++
 4 files changed, 97 insertions(+)
 create mode 100644 mm/pmalloc-selftest.c
 create mode 100644 mm/pmalloc-selftest.h

diff --git a/mm/Kconfig b/mm/Kconfig
index 03ff7703d322..f5edfadd036a 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -765,3 +765,12 @@ config GUP_BENCHMARK
 	  performance of get_user_pages_fast().
 
 	  See tools/testing/selftests/vm/gup_benchmark.c
+
+config PROTECTABLE_MEMORY_SELFTEST
+	bool "Run self test for pmalloc memory allocator"
+	depends on ARCH_HAS_SET_MEMORY
+	select GENERIC_ALLOCATOR
+	default n
+	help
+	  Tries to verify that pmalloc works correctly and that the memory
+	  is effectively protected.
diff --git a/mm/Makefile b/mm/Makefile
index a6a47e1b6e66..1e76a9b96180 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -66,6 +66,7 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_ARCH_HAS_SET_MEMORY) += pmalloc.o
+obj-$(CONFIG_PROTECTABLE_MEMORY_SELFTEST) += pmalloc-selftest.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
diff --git a/mm/pmalloc-selftest.c b/mm/pmalloc-selftest.c
new file mode 100644
index 000000000000..9f6401ebd8d1
--- /dev/null
+++ b/mm/pmalloc-selftest.c
@@ -0,0 +1,61 @@
+/* SPDX-License-Identifier: GPL-2.0
+ *
+ * pmalloc-selftest.c
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#include <linux/pmalloc.h>
+#include <linux/mm.h>
+
+
+#define SIZE_1 (PAGE_SIZE * 3)
+#define SIZE_2 1000
+
+#define validate_alloc(expected, variable, size)	\
+	pr_notice("must be " expected ": %s",		\
+		  is_pmalloc_object(variable, size) > 0 ? "ok" : "no")
+
+#define is_alloc_ok(variable, size)	\
+	validate_alloc("ok", variable, size)
+
+#define is_alloc_no(variable, size)	\
+	validate_alloc("no", variable, size)
+
+void pmalloc_selftest(void)
+{
+	struct gen_pool *pool_unprot;
+	struct gen_pool *pool_prot;
+	void *var_prot, *var_unprot, *var_vmall;
+
+	pr_notice("pmalloc self-test");
+	pool_unprot = pmalloc_create_pool("unprotected", 0);
+	pool_prot = pmalloc_create_pool("protected", 0);
+	BUG_ON(!(pool_unprot && pool_prot));
+
+	var_unprot = pmalloc(pool_unprot,  SIZE_1 - 1, GFP_KERNEL);
+	var_prot = pmalloc(pool_prot,  SIZE_1, GFP_KERNEL);
+	var_vmall = vmalloc(SIZE_2);
+	is_alloc_ok(var_unprot, 10);
+	is_alloc_ok(var_unprot, SIZE_1);
+	is_alloc_ok(var_unprot, PAGE_SIZE);
+	is_alloc_no(var_unprot, SIZE_1 + 1);
+	is_alloc_no(var_vmall, 10);
+
+
+	pfree(pool_unprot, var_unprot);
+	vfree(var_vmall);
+
+	pmalloc_protect_pool(pool_prot);
+
+	/* This will intentionally trigger a WARN because the pool being
+	 * destroyed is not protected, which is unusual and should happen
+	 * on error paths only, where probably other warnings are already
+	 * displayed.
+	 */
+	pmalloc_destroy_pool(pool_unprot);
+
+	/* This must not cause WARNings */
+	pmalloc_destroy_pool(pool_prot);
+}
diff --git a/mm/pmalloc-selftest.h b/mm/pmalloc-selftest.h
new file mode 100644
index 000000000000..b34ac86e14a8
--- /dev/null
+++ b/mm/pmalloc-selftest.h
@@ -0,0 +1,26 @@
+/* SPDX-License-Identifier: GPL-2.0
+ *
+ * pmalloc-selftest.h
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+
+#ifndef __PMALLOC_SELFTEST_H__
+#define __PMALLOC_SELFTEST_H__
+
+
+#ifdef CONFIG_PROTECTABLE_MEMORY_SELFTEST
+
+#include <linux/pmalloc.h>
+
+void pmalloc_selftest(void);
+
+#else
+
+static inline void pmalloc_selftest(void){};
+
+#endif
+
+#endif
-- 
2.16.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
