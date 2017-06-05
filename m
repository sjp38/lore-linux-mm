Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0417F6B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 15:24:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a3so3628863wma.12
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 12:24:06 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id q184si13074453wmg.165.2017.06.05.12.24.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 12:24:05 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 2/5] Protectable Memory Allocator
Date: Mon, 5 Jun 2017 22:22:13 +0300
Message-ID: <20170605192216.21596-3-igor.stoppa@huawei.com>
In-Reply-To: <20170605192216.21596-1-igor.stoppa@huawei.com>
References: <20170605192216.21596-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

The MMU available in many systems runnign Linux can often provide R/O
protection to the memory pages it handles.

However, this works efficiently only when said pages contain only data
that does not need to be modified.

This can work well for statically allocated variables, however it doe
not fit too well the case of dynamically allocated ones.

Dynamic allocation does not provide, currently, means for grouping
variables in memory pages that would contain exclusively data that can
be made read only.

The allocator here provided (pmalloc - protectable memory allocator)
introduces the concept of pools of protectable memory.

A module can request a pool and then refer any allocation request to the
pool handler it has received.

Once all the memory requested (over various iterations) is initialized,
the pool can be protected.

After this point, the pool can only be destroyed (it is up to the module
to avoid any no further references to the memory from the pool, after
the destruction is invoked).

The latter case is mainly meant for releasing memory when a module is
unloaded.

A module can have as many pools as needed, for example to support the
protection of data that is initialized in sufficiently distinct phases.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/page-flags.h     |   2 +
 include/linux/pmalloc.h        |  20 ++++
 include/trace/events/mmflags.h |   1 +
 mm/Makefile                    |   2 +-
 mm/pmalloc.c                   | 227 +++++++++++++++++++++++++++++++++++++++++
 mm/usercopy.c                  |  24 +++--
 6 files changed, 266 insertions(+), 10 deletions(-)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6b5818d..acc0723 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -81,6 +81,7 @@ enum pageflags {
 	PG_active,
 	PG_waiters,		/* Page has waiters, check its waitqueue. Must be bit #7 and in the same byte as "PG_locked" */
 	PG_slab,
+	PG_pmalloc,
 	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
 	PG_arch_1,
 	PG_reserved,
@@ -274,6 +275,7 @@ PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
 	TESTCLEARFLAG(Active, active, PF_HEAD)
 __PAGEFLAG(Slab, slab, PF_NO_TAIL)
 __PAGEFLAG(SlobFree, slob_free, PF_NO_TAIL)
+__PAGEFLAG(Pmalloc, pmalloc, PF_NO_TAIL)
 PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
 
 /* Xen */
diff --git a/include/linux/pmalloc.h b/include/linux/pmalloc.h
new file mode 100644
index 0000000..83d3557
--- /dev/null
+++ b/include/linux/pmalloc.h
@@ -0,0 +1,20 @@
+/*
+ * pmalloc.h: Header for Protectable Memory Allocator
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
+#ifndef _PMALLOC_H
+#define _PMALLOC_H
+
+struct pmalloc_pool *pmalloc_create_pool(const char *name);
+void *pmalloc(unsigned long size, struct pmalloc_pool *pool);
+int pmalloc_protect_pool(struct pmalloc_pool *pool);
+int pmalloc_destroy_pool(struct pmalloc_pool *pool);
+#endif
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 304ff94..41d1587 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -91,6 +91,7 @@
 	{1UL << PG_lru,			"lru"		},		\
 	{1UL << PG_active,		"active"	},		\
 	{1UL << PG_slab,		"slab"		},		\
+	{1UL << PG_pmalloc,		"pmalloc"	},		\
 	{1UL << PG_owner_priv_1,	"owner_priv_1"	},		\
 	{1UL << PG_arch_1,		"arch_1"	},		\
 	{1UL << PG_reserved,		"reserved"	},		\
diff --git a/mm/Makefile b/mm/Makefile
index 026f6a8..79dd99c 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -25,7 +25,7 @@ mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= gup.o highmem.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o \
 			   page_vma_mapped.o pagewalk.o pgtable-generic.o \
-			   rmap.o vmalloc.o
+			   rmap.o vmalloc.o pmalloc.o
 
 
 ifdef CONFIG_CROSS_MEMORY_ATTACH
diff --git a/mm/pmalloc.c b/mm/pmalloc.c
new file mode 100644
index 0000000..c73d60c
--- /dev/null
+++ b/mm/pmalloc.c
@@ -0,0 +1,227 @@
+/*
+ * pmalloc.c: Protectable Memory Allocator
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
+#include <linux/printk.h>
+#include <linux/init.h>
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+#include <linux/list.h>
+#include <linux/rculist.h>
+#include <linux/mutex.h>
+#include <linux/atomic.h>
+#include <asm/set_memory.h>
+#include <asm/page.h>
+
+typedef uint64_t align_t;
+#define WORD_SIZE sizeof(align_t)
+
+#define __PMALLOC_ALIGNED __aligned(WORD_SIZE)
+
+#define MAX_POOL_NAME_LEN 40
+
+#define PMALLOC_HASH_SIZE (PAGE_SIZE / 2)
+
+#define PMALLOC_HASH_ENTRIES ilog2(PMALLOC_HASH_SIZE)
+
+
+struct pmalloc_data {
+	struct hlist_head pools_list_head;
+	struct mutex pools_list_mutex;
+	atomic_t pools_count;
+};
+
+struct pmalloc_pool {
+	struct hlist_node pools_list;
+	struct hlist_head nodes_list_head;
+	struct mutex nodes_list_mutex;
+	atomic_t nodes_count;
+	bool protected;
+	char name[MAX_POOL_NAME_LEN];
+};
+
+struct pmalloc_node {
+	struct hlist_node nodes_list;
+	atomic_t used_words;
+	unsigned int total_words;
+	__PMALLOC_ALIGNED align_t data[];
+};
+
+#define HEADER_SIZE sizeof(struct pmalloc_node)
+
+static struct pmalloc_data *pmalloc_data;
+
+struct pmalloc_node *__pmalloc_create_node(int words)
+{
+	struct pmalloc_node *node;
+	unsigned long size, i, pages;
+	struct page *p;
+
+	size = ((HEADER_SIZE - 1 + PAGE_SIZE) +
+		WORD_SIZE * (unsigned long) words) & PAGE_MASK;
+	node = vmalloc(size);
+	if (!node)
+		return NULL;
+	atomic_set(&node->used_words, 0);
+	node->total_words = (size - HEADER_SIZE) / WORD_SIZE;
+	pages = size / PAGE_SIZE;
+	for (i = 0; i < pages; i++) {
+		p = vmalloc_to_page((void *)(i * PAGE_SIZE +
+					     (unsigned long)node));
+		__SetPagePmalloc(p);
+	}
+	return node;
+}
+
+void *pmalloc(unsigned long size, struct pmalloc_pool *pool)
+{
+	struct pmalloc_node *node;
+	int req_words;
+	int starting_word;
+
+	if (size > INT_MAX || size == 0)
+		return NULL;
+	req_words = (((int)size) + WORD_SIZE - 1) / WORD_SIZE;
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(node, &pool->nodes_list_head, nodes_list) {
+		starting_word = atomic_fetch_add(req_words, &node->used_words);
+		if (starting_word + req_words > node->total_words)
+			atomic_sub(req_words, &node->used_words);
+		else
+			goto found_node;
+	}
+	rcu_read_unlock();
+	node = __pmalloc_create_node(req_words);
+	starting_word = atomic_fetch_add(req_words, &node->used_words);
+	mutex_lock(&pool->nodes_list_mutex);
+	hlist_add_head_rcu(&node->nodes_list, &pool->nodes_list_head);
+	mutex_unlock(&pool->nodes_list_mutex);
+	atomic_inc(&pool->nodes_count);
+found_node:
+	return node->data + starting_word;
+}
+
+const char msg[] = "Not a valid Pmalloc object.";
+const char *__pmalloc_check_object(const void *ptr, unsigned long n)
+{
+	unsigned long p;
+
+	p = (unsigned long)ptr;
+	n += (unsigned long)ptr;
+	for (; (PAGE_MASK & p) <= (PAGE_MASK & n); p += PAGE_SIZE) {
+		if (is_vmalloc_addr((void *)p)) {
+			struct page *page;
+
+			page = vmalloc_to_page((void *)p);
+			if (!(page && PagePmalloc(page)))
+				return msg;
+		}
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(__pmalloc_check_object);
+
+
+struct pmalloc_pool *pmalloc_create_pool(const char *name)
+{
+	struct pmalloc_pool *pool;
+	unsigned int name_len;
+
+	name_len = strnlen(name, MAX_POOL_NAME_LEN);
+	if (unlikely(name_len == MAX_POOL_NAME_LEN))
+		return NULL;
+	pool = vmalloc(sizeof(struct pmalloc_pool));
+	if (unlikely(!pool))
+		return NULL;
+	INIT_HLIST_NODE(&pool->pools_list);
+	INIT_HLIST_HEAD(&pool->nodes_list_head);
+	mutex_init(&pool->nodes_list_mutex);
+	atomic_set(&pool->nodes_count, 0);
+	pool->protected = false;
+	strcpy(pool->name, name);
+	mutex_lock(&pmalloc_data->pools_list_mutex);
+	hlist_add_head_rcu(&pool->pools_list, &pmalloc_data->pools_list_head);
+	mutex_unlock(&pmalloc_data->pools_list_mutex);
+	atomic_inc(&pmalloc_data->pools_count);
+	return pool;
+}
+
+int pmalloc_protect_pool(struct pmalloc_pool *pool)
+{
+	struct pmalloc_node *node;
+
+	if (!pool)
+		return -EINVAL;
+	mutex_lock(&pool->nodes_list_mutex);
+	hlist_for_each_entry(node, &pool->nodes_list_head, nodes_list) {
+		unsigned long size, pages;
+
+		size = WORD_SIZE * node->total_words + HEADER_SIZE;
+		pages = size / PAGE_SIZE;
+		set_memory_ro((unsigned long)node, pages);
+	}
+	pool->protected = true;
+	mutex_unlock(&pool->nodes_list_mutex);
+	return 0;
+}
+
+static __always_inline
+void __pmalloc_destroy_node(struct pmalloc_node *node)
+{
+	int pages, i;
+
+	pages = (node->total_words * WORD_SIZE + HEADER_SIZE) /	PAGE_SIZE;
+	for (i = 0; i < pages; i++)
+		__ClearPagePmalloc(vmalloc_to_page(node + i * PAGE_SIZE));
+	vfree(node);
+}
+
+int pmalloc_destroy_pool(struct pmalloc_pool *pool)
+{
+	struct pmalloc_node *node;
+
+	if (!pool)
+		return -EINVAL;
+	mutex_lock(&pool->nodes_list_mutex);
+	mutex_lock(&pmalloc_data->pools_list_mutex);
+	hlist_del_rcu(&pool->pools_list);
+	mutex_unlock(&pmalloc_data->pools_list_mutex);
+	hlist_for_each_entry_rcu(node, &pool->nodes_list_head, nodes_list) {
+		int pages;
+
+		pages = (node->total_words * WORD_SIZE + HEADER_SIZE) /
+			PAGE_SIZE;
+		set_memory_rw((unsigned long)node, pages);
+	}
+
+	while (likely(!hlist_empty(&pool->nodes_list_head))) {
+		node = hlist_entry(pool->nodes_list_head.first,
+				   struct pmalloc_node, nodes_list);
+		hlist_del(&node->nodes_list);
+		__pmalloc_destroy_node(node);
+	}
+	mutex_unlock(&pool->nodes_list_mutex);
+	atomic_dec(&pmalloc_data->pools_count);
+	vfree(pool);
+	return 0;
+}
+
+int __init pmalloc_init(void)
+{
+	pmalloc_data = vmalloc(sizeof(struct pmalloc_data));
+	if (!pmalloc_data)
+		return -ENOMEM;
+	INIT_HLIST_HEAD(&pmalloc_data->pools_list_head);
+	mutex_init(&pmalloc_data->pools_list_mutex);
+	atomic_set(&pmalloc_data->pools_count, 0);
+	return 0;
+}
+EXPORT_SYMBOL(pmalloc_init);
diff --git a/mm/usercopy.c b/mm/usercopy.c
index a9852b2..29bb691 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -195,22 +195,28 @@ static inline const char *check_page_span(const void *ptr, unsigned long n,
 	return NULL;
 }
 
+extern const char *__pmalloc_check_object(const void *ptr, unsigned long n);
+
 static inline const char *check_heap_object(const void *ptr, unsigned long n,
 					    bool to_user)
 {
 	struct page *page;
 
-	if (!virt_addr_valid(ptr))
-		return NULL;
-
-	page = virt_to_head_page(ptr);
-
-	/* Check slab allocator for flags and size. */
-	if (PageSlab(page))
-		return __check_heap_object(ptr, n, page);
+	if (virt_addr_valid(ptr)) {
+		page = virt_to_head_page(ptr);
 
+		/* Check slab allocator for flags and size. */
+		if (PageSlab(page))
+			return __check_heap_object(ptr, n, page);
 	/* Verify object does not incorrectly span multiple pages. */
-	return check_page_span(ptr, n, page, to_user);
+		return check_page_span(ptr, n, page, to_user);
+	}
+	if (likely(is_vmalloc_addr(ptr))) {
+		page = vmalloc_to_page(ptr);
+		if (unlikely(page && PagePmalloc(page)))
+			return __pmalloc_check_object(ptr, n);
+	}
+	return NULL;
 }
 
 /*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
