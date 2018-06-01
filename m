Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6421F6B0010
	for <linux-mm@kvack.org>; Thu, 31 May 2018 20:43:47 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k13-v6so5720580pgr.11
        for <linux-mm@kvack.org>; Thu, 31 May 2018 17:43:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z16-v6sor7158799pge.189.2018.05.31.17.43.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 17:43:46 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 05/16] lib: overflow: Add memory allocation overflow tests
Date: Thu, 31 May 2018 17:42:22 -0700
Message-Id: <20180601004233.37822-6-keescook@chromium.org>
In-Reply-To: <20180601004233.37822-1-keescook@chromium.org>
References: <20180601004233.37822-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

Make sure that the memory allocators are behaving as expected in the face
of overflows.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 lib/test_overflow.c | 109 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 109 insertions(+)

diff --git a/lib/test_overflow.c b/lib/test_overflow.c
index 482d71c880fa..3f4457ea7d7c 100644
--- a/lib/test_overflow.c
+++ b/lib/test_overflow.c
@@ -9,6 +9,9 @@
 #include <linux/module.h>
 #include <linux/overflow.h>
 #include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/device.h>
+#include <linux/mm.h>
 
 #define DEFINE_TEST_ARRAY(t)			\
 	static const struct test_ ## t {	\
@@ -294,11 +297,117 @@ static int __init test_overflow_calculation(void)
 	return err;
 }
 
+/*
+ * Deal with the various forms of allocator arguments. See comments above
+ * the DEFINE_TEST_ALLOC() instances for mapping of the "bits".
+ */
+#define alloc010(alloc, arg, sz) alloc(sz, GFP_KERNEL)
+#define alloc011(alloc, arg, sz) alloc(sz, GFP_KERNEL, NUMA_NO_NODE)
+#define alloc000(alloc, arg, sz) alloc(sz)
+#define alloc001(alloc, arg, sz) alloc(sz, NUMA_NO_NODE)
+#define alloc110(alloc, arg, sz) alloc(arg, sz, GFP_KERNEL)
+#define free0(free, arg, ptr)	 free(ptr)
+#define free1(free, arg, ptr)	 free(arg, ptr)
+
+/* Wrap around to 8K */
+#define TEST_SIZE		(9 << PAGE_SHIFT)
+
+#define DEFINE_TEST_ALLOC(func, free_func, want_arg, want_gfp, want_node)\
+static int __init test_ ## func (void *arg)				\
+{									\
+	volatile size_t a = TEST_SIZE;					\
+	volatile size_t b = (SIZE_MAX / TEST_SIZE) + 1;			\
+	void *ptr;							\
+									\
+	/* Tiny allocation test. */					\
+	ptr = alloc ## want_arg ## want_gfp ## want_node (func, arg, 1);\
+	if (!ptr) {							\
+		pr_warn(#func " failed regular allocation?!\n");	\
+		return 1;						\
+	}								\
+	free ## want_arg (free_func, arg, ptr);				\
+									\
+	/* Wrapped allocation test. */					\
+	ptr = alloc ## want_arg ## want_gfp ## want_node (func, arg,	\
+							  a * b);	\
+	if (!ptr) {							\
+		pr_warn(#func " unexpectedly failed bad wrapping?!\n");	\
+		return 1;						\
+	}								\
+	free ## want_arg (free_func, arg, ptr);				\
+									\
+	/* Saturated allocation test. */				\
+	ptr = alloc ## want_arg ## want_gfp ## want_node (func, arg,	\
+						   array_size(a, b));	\
+	if (ptr) {							\
+		pr_warn(#func " missed saturation!\n");			\
+		free ## want_arg (free_func, arg, ptr);			\
+		return 1;						\
+	}								\
+	pr_info(#func " detected saturation\n");			\
+	return 0;							\
+}
+
+/*
+ * Allocator uses a trailing node argument --------+  (e.g. kmalloc_node())
+ * Allocator uses the gfp_t argument -----------+  |  (e.g. kmalloc())
+ * Allocator uses a special leading argument +  |  |  (e.g. devm_kmalloc())
+ *                                           |  |  |
+ */
+DEFINE_TEST_ALLOC(kmalloc,	 kfree,	     0, 1, 0);
+DEFINE_TEST_ALLOC(kmalloc_node,	 kfree,	     0, 1, 1);
+DEFINE_TEST_ALLOC(kzalloc,	 kfree,	     0, 1, 0);
+DEFINE_TEST_ALLOC(kzalloc_node,  kfree,	     0, 1, 1);
+DEFINE_TEST_ALLOC(vmalloc,	 vfree,	     0, 0, 0);
+DEFINE_TEST_ALLOC(vmalloc_node,  vfree,	     0, 0, 1);
+DEFINE_TEST_ALLOC(vzalloc,	 vfree,	     0, 0, 0);
+DEFINE_TEST_ALLOC(vzalloc_node,  vfree,	     0, 0, 1);
+DEFINE_TEST_ALLOC(kvmalloc,	 kvfree,     0, 1, 0);
+DEFINE_TEST_ALLOC(kvmalloc_node, kvfree,     0, 1, 1);
+DEFINE_TEST_ALLOC(kvzalloc,	 kvfree,     0, 1, 0);
+DEFINE_TEST_ALLOC(kvzalloc_node, kvfree,     0, 1, 1);
+DEFINE_TEST_ALLOC(devm_kmalloc,  devm_kfree, 1, 1, 0);
+DEFINE_TEST_ALLOC(devm_kzalloc,  devm_kfree, 1, 1, 0);
+
+static int __init test_overflow_allocation(void)
+{
+	const char device_name[] = "overflow-test";
+	struct device *dev;
+	int err = 0;
+
+	/* Create dummy device for devm_kmalloc()-family tests. */
+	dev = root_device_register(device_name);
+	if (!dev) {
+		pr_warn("Cannot register test device\n");
+		return 1;
+	}
+
+	err |= test_kmalloc(NULL);
+	err |= test_kmalloc_node(NULL);
+	err |= test_kzalloc(NULL);
+	err |= test_kzalloc_node(NULL);
+	err |= test_kvmalloc(NULL);
+	err |= test_kvmalloc_node(NULL);
+	err |= test_kvzalloc(NULL);
+	err |= test_kvzalloc_node(NULL);
+	err |= test_vmalloc(NULL);
+	err |= test_vmalloc_node(NULL);
+	err |= test_vzalloc(NULL);
+	err |= test_vzalloc_node(NULL);
+	err |= test_devm_kmalloc(dev);
+	err |= test_devm_kzalloc(dev);
+
+	device_unregister(dev);
+
+	return err;
+}
+
 static int __init test_module_init(void)
 {
 	int err = 0;
 
 	err |= test_overflow_calculation();
+	err |= test_overflow_allocation();
 
 	if (err) {
 		pr_warn("FAIL!\n");
-- 
2.17.0
