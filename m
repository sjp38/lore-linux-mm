Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 0D3556B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 21:29:33 -0500 (EST)
Received: by mail-da0-f43.google.com with SMTP id u36so2987804dak.16
        for <linux-mm@kvack.org>; Mon, 21 Jan 2013 18:29:33 -0800 (PST)
Date: Tue, 22 Jan 2013 10:29:19 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 1/3 v2]mm: don't inline page_mapping()
Message-ID: <20130122022919.GA12293@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, minchan@kernel.org


According to akpm, this saves 1/2k text and makes things simple of next patch.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 include/linux/mm.h |   13 +------------
 mm/util.c          |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 12 deletions(-)

Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2013-01-21 15:43:46.978065595 +0800
+++ linux/include/linux/mm.h	2013-01-21 15:44:42.273370813 +0800
@@ -817,18 +817,7 @@ void page_address_init(void);
 #define PAGE_MAPPING_KSM	2
 #define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
 
-extern struct address_space swapper_space;
-static inline struct address_space *page_mapping(struct page *page)
-{
-	struct address_space *mapping = page->mapping;
-
-	VM_BUG_ON(PageSlab(page));
-	if (unlikely(PageSwapCache(page)))
-		mapping = &swapper_space;
-	else if ((unsigned long)mapping & PAGE_MAPPING_ANON)
-		mapping = NULL;
-	return mapping;
-}
+extern struct address_space *page_mapping(struct page *page);
 
 /* Neutral page->mapping pointer to address_space or anon_vma or other */
 static inline void *page_rmapping(struct page *page)
Index: linux/mm/util.c
===================================================================
--- linux.orig/mm/util.c	2013-01-21 15:43:46.962065796 +0800
+++ linux/mm/util.c	2013-01-22 09:50:53.758830807 +0800
@@ -5,6 +5,7 @@
 #include <linux/err.h>
 #include <linux/sched.h>
 #include <linux/security.h>
+#include <linux/swap.h>
 #include <asm/uaccess.h>
 
 #include "internal.h"
@@ -378,6 +379,21 @@ unsigned long vm_mmap(struct file *file,
 }
 EXPORT_SYMBOL(vm_mmap);
 
+struct address_space *page_mapping(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+
+	VM_BUG_ON(PageSlab(page));
+#ifdef CONFIG_SWAP
+	if (unlikely(PageSwapCache(page)))
+		mapping = &swapper_space;
+	else
+#endif
+	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
+		mapping = NULL;
+	return mapping;
+}
+
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
