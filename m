Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EAB856B0007
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 10:18:32 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id q8so8294817wrd.17
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 07:18:32 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id c6si9278525wra.21.2018.01.30.07.18.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 07:18:31 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 6/6] Pmalloc: self-test
Date: Tue, 30 Jan 2018 17:14:46 +0200
Message-ID: <20180130151446.24698-7-igor.stoppa@huawei.com>
In-Reply-To: <20180130151446.24698-1-igor.stoppa@huawei.com>
References: <20180130151446.24698-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Add basic self-test functionality for pmalloc.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 lib/genalloc.c        |  2 +-
 mm/Kconfig            |  7 ++++++
 mm/Makefile           |  1 +
 mm/pmalloc-selftest.c | 65 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/pmalloc-selftest.h | 30 ++++++++++++++++++++++++
 mm/pmalloc.c          |  9 ++++---
 6 files changed, 110 insertions(+), 4 deletions(-)
 create mode 100644 mm/pmalloc-selftest.c
 create mode 100644 mm/pmalloc-selftest.h

diff --git a/lib/genalloc.c b/lib/genalloc.c
index 62f69b3..7ba2ec9 100644
--- a/lib/genalloc.c
+++ b/lib/genalloc.c
@@ -542,7 +542,7 @@ void gen_pool_flush_chunk(struct gen_pool *pool,
 	memset(chunk->entries, 0,
 	       DIV_ROUND_UP(size >> pool->min_alloc_order * BITS_PER_ENTRY,
 			    BITS_PER_BYTE));
-	atomic_set(&chunk->avail, size);
+	atomic_long_set(&chunk->avail, size);
 }
 
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 03ff770..f0c960e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -765,3 +765,10 @@ config GUP_BENCHMARK
 	  performance of get_user_pages_fast().
 
 	  See tools/testing/selftests/vm/gup_benchmark.c
+
+config PROTECTABLE_MEMORY_SELFTEST
+	bool "Run self test for pmalloc memory allocator"
+	default n
+	help
+	  Tries to verify that pmalloc works correctly and that the memory
+	  is effectively protected.
diff --git a/mm/Makefile b/mm/Makefile
index a6a47e1..1e76a9b 100644
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
index 0000000..1c025f3
--- /dev/null
+++ b/mm/pmalloc-selftest.c
@@ -0,0 +1,65 @@
+/*
+ * pmalloc-selftest.c
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
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
index 0000000..3673d23
--- /dev/null
+++ b/mm/pmalloc-selftest.h
@@ -0,0 +1,30 @@
+/*
+ * pmalloc-selftest.h
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
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
diff --git a/mm/pmalloc.c b/mm/pmalloc.c
index a64ac49..73387d7 100644
--- a/mm/pmalloc.c
+++ b/mm/pmalloc.c
@@ -25,6 +25,8 @@
 #include <asm/cacheflush.h>
 #include <asm/page.h>
 
+#include "pmalloc-selftest.h"
+
 /**
  * pmalloc_data contains the data specific to a pmalloc pool,
  * in a format compatible with the design of gen_alloc.
@@ -152,7 +154,7 @@ static void pmalloc_disconnect(struct pmalloc_data *data,
 do { \
 	sysfs_attr_init(&data->attr_##attr_name.attr); \
 	data->attr_##attr_name.attr.name = #attr_name; \
-	data->attr_##attr_name.attr.mode = VERIFY_OCTAL_PERMISSIONS(0444); \
+	data->attr_##attr_name.attr.mode = VERIFY_OCTAL_PERMISSIONS(0400); \
 	data->attr_##attr_name.show = pmalloc_pool_show_##attr_name; \
 } while (0)
 
@@ -335,7 +337,7 @@ bool pmalloc_prealloc(struct gen_pool *pool, size_t size)
 
 	return true;
 abort:
-	vfree(chunk);
+	vfree_atomic(chunk);
 	return false;
 
 }
@@ -401,7 +403,7 @@ void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp)
 abort:
 	untag_chunk(chunk);
 free:
-	vfree(chunk);
+	vfree_atomic(chunk);
 	return NULL;
 }
 
@@ -508,6 +510,7 @@ static int __init pmalloc_late_init(void)
 		}
 	}
 	mutex_unlock(&pmalloc_mutex);
+	pmalloc_selftest();
 	return 0;
 }
 late_initcall(pmalloc_late_init);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
