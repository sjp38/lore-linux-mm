Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 14B326B006E
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:36:54 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so9128111pab.3
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:36:53 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id gh5si45775670pbc.245.2014.07.09.04.36.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:36:52 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8G00B4I08YKQ60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:36:34 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH RESEND -next 21/21] lib: add kmalloc_bug_test module
Date: Wed, 09 Jul 2014 15:30:15 +0400
Message-id: <1404905415-9046-22-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

This is a test module doing varios nasty things like
out of bounds accesses, use after free. It is usefull for testing
kernel debugging features like kernel address sanitizer.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 lib/Kconfig.debug       |   8 ++
 lib/Makefile            |   1 +
 lib/test_kmalloc_bugs.c | 254 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 263 insertions(+)
 create mode 100644 lib/test_kmalloc_bugs.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 67a4dfc..64fd9e6 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -609,6 +609,14 @@ config DEBUG_STACKOVERFLOW
 
 	  If in doubt, say "N".
 
+config KMALLOC_BUG_TEST
+	tristate "Module for testing bugs detection in sl[auo]b"
+	default n
+	help
+	  This is a test module doing varios nasty things like
+	  out of bounds accesses, use after free. It is usefull for testing
+	  kernel debugging features like kernel address sanitizer.
+
 source "lib/Kconfig.kmemcheck"
 
 source "lib/Kconfig.kasan"
diff --git a/lib/Makefile b/lib/Makefile
index e48067c..af68259 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_TEST_KSTRTOX) += test-kstrtox.o
 obj-$(CONFIG_TEST_MODULE) += test_module.o
 obj-$(CONFIG_TEST_USER_COPY) += test_user_copy.o
 obj-$(CONFIG_TEST_BPF) += test_bpf.o
+obj-$(CONFIG_KMALLOC_BUG_TEST) += test_kmalloc_bugs.o
 
 ifeq ($(CONFIG_DEBUG_KOBJECT),y)
 CFLAGS_kobject.o += -DDEBUG
diff --git a/lib/test_kmalloc_bugs.c b/lib/test_kmalloc_bugs.c
new file mode 100644
index 0000000..04cd11b
--- /dev/null
+++ b/lib/test_kmalloc_bugs.c
@@ -0,0 +1,254 @@
+/*
+ *
+ * Copyright (c) 2014 Samsung Electronics Co., Ltd.
+ * Author: Andrey Ryabinin <a.ryabinin@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#define pr_fmt(fmt) "kmalloc bug test: " fmt
+
+#include <linux/kernel.h>
+#include <linux/printk.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/module.h>
+
+void __init kmalloc_oob_rigth(void)
+{
+	char *ptr;
+	size_t size = 123;
+
+	pr_info("out-of-bounds to right\n");
+	ptr = kmalloc(size , GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	ptr[size] = 'x';
+	kfree(ptr);
+}
+
+void __init kmalloc_oob_left(void)
+{
+	char *ptr;
+	size_t size = 15;
+
+	pr_info("out-of-bounds to left\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	*ptr = *(ptr - 1);
+	kfree(ptr);
+}
+
+void __init kmalloc_node_oob_right(void)
+{
+	char *ptr;
+	size_t size = 4096;
+
+	pr_info("kmalloc_node(): out-of-bounds to right\n");
+	ptr = kmalloc_node(size , GFP_KERNEL, 0);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	ptr[size] = 0;
+	kfree(ptr);
+}
+
+void __init kmalloc_large_oob_rigth(void)
+{
+	char *ptr;
+	size_t size = PAGE_SIZE*3 - 10;
+
+	pr_info("kmalloc large allocation: out-of-bounds to right\n");
+	ptr = kmalloc(size , GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	ptr[size] = 0;
+	kfree(ptr);
+}
+
+void __init kmalloc_oob_krealloc_more(void)
+{
+	char *ptr1, *ptr2;
+	size_t size1 = 17;
+	size_t size2 = 19;
+
+	pr_info("out-of-bounds after krealloc more\n");
+	ptr1 = kmalloc(size1, GFP_KERNEL);
+	ptr2 = krealloc(ptr1, size2, GFP_KERNEL);
+	if (!ptr1 || !ptr2) {
+		pr_err("Allocation failed\n");
+		kfree(ptr1);
+		return;
+	}
+
+	ptr2[size2] = 'x';
+	kfree(ptr2);
+}
+
+void __init kmalloc_oob_krealloc_less(void)
+{
+	char *ptr1, *ptr2;
+	size_t size1 = 17;
+	size_t size2 = 15;
+
+	pr_info("out-of-bounds after krealloc less\n");
+	ptr1 = kmalloc(size1, GFP_KERNEL);
+	ptr2 = krealloc(ptr1, size2, GFP_KERNEL);
+	if (!ptr1 || !ptr2) {
+		pr_err("Allocation failed\n");
+		kfree(ptr1);
+		return;
+	}
+	ptr2[size1] = 'x';
+	kfree(ptr2);
+}
+
+void __init kmalloc_oob_16(void)
+{
+	struct {
+		u64 words[2];
+	} *ptr1, *ptr2;
+
+	pr_info("kmalloc out-of-bounds for 16-bytes access\n");
+	ptr1 = kmalloc(sizeof(*ptr1) - 3, GFP_KERNEL);
+	ptr2 = kmalloc(sizeof(*ptr2), GFP_KERNEL);
+	if (!ptr1 || !ptr2) {
+		pr_err("Allocation failed\n");
+		kfree(ptr1);
+		kfree(ptr2);
+		return;
+	}
+	*ptr1 = *ptr2;
+	kfree(ptr1);
+	kfree(ptr2);
+}
+
+void __init kmalloc_oob_in_memset(void)
+{
+	char *ptr;
+	size_t size = 666;
+
+	pr_info("out-of-bounds in memset\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	memset(ptr, 0, size+5);
+	kfree(ptr);
+}
+
+void __init kmalloc_uaf(void)
+{
+	char *ptr;
+	size_t size = 10;
+
+	pr_info("use-after-free\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	kfree(ptr);
+	*ptr = 'x';
+}
+
+void __init kmalloc_uaf_memset(void)
+{
+	char *ptr;
+	size_t size = 33;
+
+	pr_info("use-after-free in memset\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	kfree(ptr);
+	memset(ptr, 0, size);
+}
+
+void __init kmalloc_uaf2(void)
+{
+	char *ptr1, *ptr2;
+	size_t size = 43;
+
+	pr_info("use-after-free after another kmalloc\n");
+	ptr1 = kmalloc(size, GFP_KERNEL);
+	if (!ptr1) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	kfree(ptr1);
+	ptr2 = kmalloc(size, GFP_KERNEL);
+	if (!ptr2) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	ptr1[0] = 'x';
+	kfree(ptr2);
+}
+
+void __init kmem_cache_oob(void)
+{
+	char *p;
+	size_t size = 200;
+	struct kmem_cache *cache = kmem_cache_create("test_cache",
+						size, 0,
+						0, NULL);
+	if (!cache) {
+		pr_err("Cache allocation failed\n");
+		return;
+	}
+	pr_info("out-of-bounds in kmem_cache_alloc\n");
+	p = kmem_cache_alloc(cache, GFP_KERNEL);
+	if (!p) {
+		pr_err("Allocation failed\n");
+		kmem_cache_destroy(cache);
+		return;
+	}
+
+	*p = p[size];
+	kmem_cache_free(cache, p);
+	kmem_cache_destroy(cache);
+}
+
+int __init kmalloc_tests_init(void)
+{
+	kmalloc_oob_rigth();
+	kmalloc_oob_left();
+	kmalloc_node_oob_right();
+	kmalloc_large_oob_rigth();
+	kmalloc_oob_krealloc_more();
+	kmalloc_oob_krealloc_less();
+	kmalloc_oob_16();
+	kmalloc_oob_in_memset();
+	kmalloc_uaf();
+	kmalloc_uaf_memset();
+	kmalloc_uaf2();
+	kmem_cache_oob();
+	return 0;
+}
+
+module_init(kmalloc_tests_init);
+MODULE_LICENSE("GPL");
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
