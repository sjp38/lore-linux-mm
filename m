Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 821066B0028
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 15:58:27 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t10-v6so5995657plr.12
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:58:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m22si4812600pgv.643.2018.03.22.12.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 12:58:26 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 3/4] mm: Add free()
Date: Thu, 22 Mar 2018 12:58:18 -0700
Message-Id: <20180322195819.24271-4-willy@infradead.org>
In-Reply-To: <20180322195819.24271-1-willy@infradead.org>
References: <20180322195819.24271-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

free() can free many different kinds of memory.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/kernel.h |  2 ++
 mm/util.c              | 39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 3fd291503576..8bb578938e65 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -933,6 +933,8 @@ static inline void ftrace_dump(enum ftrace_dump_mode oops_dump_mode) { }
 			 "pointer type mismatch in container_of()");	\
 	((type *)(__mptr - offsetof(type, member))); })
 
+void free(const void *);
+
 /* Rebuild everything on CONFIG_FTRACE_MCOUNT_RECORD */
 #ifdef CONFIG_FTRACE_MCOUNT_RECORD
 # define REBUILD_DUE_TO_FTRACE_MCOUNT_RECORD
diff --git a/mm/util.c b/mm/util.c
index dc4c7b551aaf..8aa2071059b0 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -26,6 +26,45 @@ static inline int is_kernel_rodata(unsigned long addr)
 		addr < (unsigned long)__end_rodata;
 }
 
+/**
+ * free() - Free memory
+ * @ptr: Pointer to memory
+ *
+ * This function can free almost any type of memory.  It can safely be
+ * called on:
+ * * NULL pointers.
+ * * Pointers to read-only data (will do nothing).
+ * * Pointers to memory allocated from kmalloc().
+ * * Pointers to memory allocated from kmem_cache_alloc().
+ * * Pointers to memory allocated from vmalloc().
+ * * Pointers to memory allocated from alloc_percpu().
+ * * Pointers to memory allocated from __get_free_pages().
+ * * Pointers to memory allocated from page_frag_alloc().
+ *
+ * It cannot free memory allocated by dma_pool_alloc() or dma_alloc_coherent().
+ */
+void free(const void *ptr)
+{
+	struct page *page;
+
+	if (unlikely(ZERO_OR_NULL_PTR(ptr)))
+		return;
+	if (is_kernel_rodata((unsigned long)ptr))
+		return;
+
+	page = virt_to_head_page(ptr);
+	if (likely(PageSlab(page)))
+		return kmem_cache_free(page->slab_cache, (void *)ptr);
+
+	if (is_vmalloc_addr(ptr))
+		return vfree(ptr);
+	if (is_kernel_percpu_address((unsigned long)ptr))
+		free_percpu((void __percpu *)ptr);
+	if (put_page_testzero(page))
+		__put_page(page);
+}
+EXPORT_SYMBOL(free);
+
 /**
  * kfree_const - conditionally free memory
  * @x: pointer to the memory
-- 
2.16.2
