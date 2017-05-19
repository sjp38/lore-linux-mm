Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA3A1831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 06:40:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o52so4339177wrb.10
        for <linux-mm@kvack.org>; Fri, 19 May 2017 03:40:39 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id j24si2223220wrd.9.2017.05.19.03.40.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 03:40:38 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 1/1] Sealable memory support
Date: Fri, 19 May 2017 13:38:11 +0300
Message-ID: <20170519103811.2183-2-igor.stoppa@huawei.com>
In-Reply-To: <20170519103811.2183-1-igor.stoppa@huawei.com>
References: <20170519103811.2183-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, dave.hansen@intel.com, labbott@redhat.com
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, Igor Stoppa <igor.stoppa@huawei.com>

Dynamically allocated variables can be made read only,
after they have been initialized, provided that they reside in memory
pages devoid of any RW data.

The implementation supplies means to create independent pools of memory,
which can be individually created, sealed/unsealed and destroyed.

A global pool is made available for those kernel modules that do not
need to manage an independent pool.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 mm/Makefile  |   2 +-
 mm/smalloc.c | 200 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/smalloc.h |  61 ++++++++++++++++++
 3 files changed, 262 insertions(+), 1 deletion(-)
 create mode 100644 mm/smalloc.c
 create mode 100644 mm/smalloc.h

diff --git a/mm/Makefile b/mm/Makefile
index 026f6a8..737c42a 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -39,7 +39,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o vmacache.o swap_slots.o \
 			   interval_tree.o list_lru.o workingset.o \
-			   debug.o $(mmu-y)
+			   debug.o smalloc.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git a/mm/smalloc.c b/mm/smalloc.c
new file mode 100644
index 0000000..fa04cc5
--- /dev/null
+++ b/mm/smalloc.c
@@ -0,0 +1,200 @@
+/*
+ * smalloc.c: Sealable Memory Allocator
+ *
+ * (C) Copyright 2017 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+
+#include <linux/module.h>
+#include <linux/printk.h>
+#include <linux/kobject.h>
+#include <linux/sysfs.h>
+#include <linux/init.h>
+#include <linux/fs.h>
+#include <linux/string.h>
+
+
+#include <linux/vmalloc.h>
+#include <asm/cacheflush.h>
+#include "smalloc.h"
+
+#define page_roundup(size) (((size) + !(size) - 1 + PAGE_SIZE) & PAGE_MASK)
+
+#define pages_nr(size) (page_roundup(size) / PAGE_SIZE)
+
+static struct smalloc_pool *global_pool;
+
+struct smalloc_node *__smalloc_create_node(unsigned long words)
+{
+	struct smalloc_node *node;
+	unsigned long size;
+
+	/* Calculate the size to ask from vmalloc, page aligned. */
+	size = page_roundup(NODE_HEADER_SIZE + words * sizeof(align_t));
+	node = vmalloc(size);
+	if (!node) {
+		pr_err("No memory for allocating smalloc node.");
+		return NULL;
+	}
+	/* Initialize the node.*/
+	INIT_LIST_HEAD(&node->list);
+	node->free = node->data;
+	node->available_words = (size - NODE_HEADER_SIZE) / sizeof(align_t);
+	return node;
+}
+
+static __always_inline
+void *node_alloc(struct smalloc_node *node, unsigned long words)
+{
+	register align_t *old_free = node->free;
+
+	node->available_words -= words;
+	node->free += words;
+	return old_free;
+}
+
+void *smalloc(unsigned long size, struct smalloc_pool *pool)
+{
+	struct list_head *pos;
+	struct smalloc_node *node;
+	void *ptr;
+	unsigned long words;
+
+	/* If no pool specified, use the global one. */
+	if (!pool)
+		pool = global_pool;
+
+	mutex_lock(&pool->lock);
+
+	/* If the pool is sealed, then return NULL. */
+	if (pool->seal == SMALLOC_SEALED) {
+		mutex_unlock(&pool->lock);
+		return NULL;
+	}
+
+	/* Calculate minimum number of words required. */
+	words = (size + sizeof(align_t) - 1) / sizeof(align_t);
+
+	/* Look for slot that is large enough, in the existing pool.*/
+	list_for_each(pos, &pool->list) {
+		node = list_entry(pos, struct smalloc_node, list);
+		if (node->available_words >= words) {
+			ptr = node_alloc(node, words);
+			mutex_unlock(&pool->lock);
+			return ptr;
+		}
+	}
+
+	/* No slot found, get a new chunk of virtual memory. */
+	node = __smalloc_create_node(words);
+	if (!node) {
+		mutex_unlock(&pool->lock);
+		return NULL;
+	}
+
+	list_add(&node->list, &pool->list);
+	ptr = node_alloc(node, words);
+	mutex_unlock(&pool->lock);
+	return ptr;
+}
+
+static __always_inline
+unsigned long get_node_size(struct smalloc_node *node)
+{
+	if (!node)
+		return 0;
+	return page_roundup((((void *)node->free) - (void *)node) +
+			    node->available_words * sizeof(align_t));
+}
+
+static __always_inline
+unsigned long get_node_pages_nr(struct smalloc_node *node)
+{
+	return pages_nr(get_node_size(node));
+}
+void smalloc_seal_set(enum seal_t seal, struct smalloc_pool *pool)
+{
+	struct list_head *pos;
+	struct smalloc_node *node;
+
+	if (!pool)
+		pool = global_pool;
+	mutex_lock(&pool->lock);
+	if (pool->seal == seal) {
+		mutex_unlock(&pool->lock);
+		return;
+	}
+	list_for_each(pos, &pool->list) {
+		node = list_entry(pos, struct smalloc_node, list);
+		if (seal == SMALLOC_SEALED)
+			set_memory_ro((unsigned long)node,
+				      get_node_pages_nr(node));
+		else if (seal == SMALLOC_UNSEALED)
+			set_memory_rw((unsigned long)node,
+				      get_node_pages_nr(node));
+	}
+	pool->seal = seal;
+	mutex_unlock(&pool->lock);
+}
+
+int smalloc_initialize(struct smalloc_pool *pool)
+{
+	if (!pool)
+		return -EINVAL;
+	INIT_LIST_HEAD(&pool->list);
+	pool->seal = SMALLOC_UNSEALED;
+	mutex_init(&pool->lock);
+	return 0;
+}
+
+struct smalloc_pool *smalloc_create(void)
+{
+	struct smalloc_pool *pool = vmalloc(sizeof(struct smalloc_pool));
+
+	if (!pool) {
+		pr_err("No memory for allocating pool.");
+		return NULL;
+	}
+	smalloc_initialize(pool);
+	return pool;
+}
+
+int smalloc_destroy(struct smalloc_pool *pool)
+{
+	struct list_head *pos, *q;
+	struct smalloc_node *node;
+
+	if (!pool)
+		return -EINVAL;
+	list_for_each_safe(pos, q, &pool->list) {
+		node = list_entry(pos, struct smalloc_node, list);
+		list_del(pos);
+		vfree(node);
+	}
+	return 0;
+}
+
+static int __init smalloc_init(void)
+{
+	global_pool = smalloc_create();
+	if (!global_pool) {
+		pr_err("Module smalloc initialization failed: no memory.\n");
+		return -ENOMEM;
+	}
+	pr_info("Module smalloc initialized successfully.\n");
+	return 0;
+}
+
+static void __exit smalloc_exit(void)
+{
+	pr_info("Module smalloc un initialized successfully.\n");
+}
+
+module_init(smalloc_init);
+module_exit(smalloc_exit);
+MODULE_LICENSE("GPL");
diff --git a/mm/smalloc.h b/mm/smalloc.h
new file mode 100644
index 0000000..344d962
--- /dev/null
+++ b/mm/smalloc.h
@@ -0,0 +1,61 @@
+/*
+ * smalloc.h: Header for Sealable Memory Allocator
+ *
+ * (C) Copyright 2017 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+
+#ifndef _SMALLOC_H
+#define _SMALLOC_H
+
+#include <linux/list.h>
+#include <linux/mutex.h>
+
+typedef uint64_t align_t;
+
+enum seal_t {
+	SMALLOC_UNSEALED,
+	SMALLOC_SEALED,
+};
+
+#define __SMALLOC_ALIGNED__ __aligned(sizeof(align_t))
+
+#define NODE_HEADER					\
+	struct {					\
+		__SMALLOC_ALIGNED__ struct {		\
+			struct list_head list;		\
+			align_t *free;			\
+			unsigned long available_words;	\
+		};					\
+	}
+
+#define NODE_HEADER_SIZE sizeof(NODE_HEADER)
+
+struct smalloc_pool {
+	struct list_head list;
+	struct mutex lock;
+	enum seal_t seal;
+};
+
+struct smalloc_node {
+	NODE_HEADER;
+	__SMALLOC_ALIGNED__ align_t data[];
+};
+
+#define smalloc_seal(pool) \
+	smalloc_seal_set(SMALLOC_SEALED, pool)
+
+#define smalloc_unseal(pool) \
+	smalloc_seal_set(SMALLOC_UNSEALED, pool)
+
+struct smalloc_pool *smalloc_create(void);
+int smalloc_destroy(struct smalloc_pool *pool);
+int smalloc_initialize(struct smalloc_pool *pool);
+void *smalloc(unsigned long size, struct smalloc_pool *pool);
+void smalloc_seal_set(enum seal_t seal, struct smalloc_pool *pool);
+#endif
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
