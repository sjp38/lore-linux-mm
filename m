Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBGM4b50021522
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 17:04:37 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBGM4bXa226796
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 17:04:37 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBGM4RTJ007455
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 17:04:27 -0500
Subject: [patch] [RFC] move 'struct page' into its own header
From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 16 Dec 2004 14:04:15 -0800
Message-Id: <E1Cf3jM-00034h-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

There are currently 24 places in the tree where struct page is
predeclared.  However, a good number of these places also have to
do some kind of arithmetic on it, and end up using macros because
static inlines wouldn't have the type fully definied at
compile-time.

But, in reality, struct page has very few dependencies on outside
macros or functions, and doesn't really need to be a part of the
header include mess which surrounds many of the VM headers.

So, put 'struct page' into structpage.h, along with a nasty comment
telling everyone to keep their grubby mitts out of the file.

Now, we can use static inlines for almost any 'struct page'
operations with no problems, and get rid of many of the 
predeclarations.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 apw2-dave/include/linux/mm.h         |   55 --------------------------
 apw2-dave/include/linux/structpage.h |   73 +++++++++++++++++++++++++++++++++++
 2 files changed, 74 insertions(+), 54 deletions(-)

diff -puN include/linux/mm.h~003-move-structpage include/linux/mm.h
--- apw2/include/linux/mm.h~003-move-structpage	2004-12-16 14:02:11.000000000 -0800
+++ apw2-dave/include/linux/mm.h	2004-12-16 14:02:11.000000000 -0800
@@ -13,6 +13,7 @@
 #include <linux/rbtree.h>
 #include <linux/prio_tree.h>
 #include <linux/fs.h>
+#include <linux/structpage.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -216,60 +217,6 @@ struct vm_operations_struct {
 struct mmu_gather;
 struct inode;
 
-#ifdef ARCH_HAS_ATOMIC_UNSIGNED
-typedef unsigned page_flags_t;
-#else
-typedef unsigned long page_flags_t;
-#endif
-
-/*
- * Each physical page in the system has a struct page associated with
- * it to keep track of whatever it is we are using the page for at the
- * moment. Note that we have no way to track which tasks are using
- * a page.
- */
-struct page {
-	page_flags_t flags;		/* Atomic flags, some possibly
-					 * updated asynchronously */
-	atomic_t _count;		/* Usage count, see below. */
-	atomic_t _mapcount;		/* Count of ptes mapped in mms,
-					 * to show when page is mapped
-					 * & limit reverse map searches.
-					 */
-	unsigned long private;		/* Mapping-private opaque data:
-					 * usually used for buffer_heads
-					 * if PagePrivate set; used for
-					 * swp_entry_t if PageSwapCache
-					 * When page is free, this indicates
-					 * order in the buddy system.
-					 */
-	struct address_space *mapping;	/* If low bit clear, points to
-					 * inode address_space, or NULL.
-					 * If page mapped as anonymous
-					 * memory, low bit is set, and
-					 * it points to anon_vma object:
-					 * see PAGE_MAPPING_ANON below.
-					 */
-	pgoff_t index;			/* Our offset within mapping. */
-	struct list_head lru;		/* Pageout list, eg. active_list
-					 * protected by zone->lru_lock !
-					 */
-	/*
-	 * On machines where all RAM is mapped into kernel address space,
-	 * we can simply calculate the virtual address. On machines with
-	 * highmem some memory is mapped into kernel virtual memory
-	 * dynamically, so we need a place to store that address.
-	 * Note that this field could be 16 bits on x86 ... ;)
-	 *
-	 * Architectures with slow multiplication can define
-	 * WANT_PAGE_VIRTUAL in their architecture's Kconfig
-	 */
-#if defined(CONFIG_WANT_PAGE_VIRTUAL)
-	void *virtual;			/* Kernel virtual address (NULL if
-					   not kmapped, ie. highmem) */
-#endif /* CONFIG_WANT_PAGE_VIRTUAL */
-};
-
 /*
  * FIXME: take this include out, include page-flags.h in
  * files which need it (119 of them)
diff -puN /dev/null include/linux/structpage.h
--- /dev/null	2004-11-08 15:18:04.000000000 -0800
+++ apw2-dave/include/linux/structpage.h	2004-12-16 14:02:11.000000000 -0800
@@ -0,0 +1,73 @@
+#ifndef _LINUX_STRUCTPAGE_H
+#define _LINUX_STRUCTPAGE_H
+
+/*
+ * ATTENTION!!!!
+ *
+ * Do NOT add any more include headers here, especially ones
+ * that have anything to do with other memory management
+ * structures.  It is safe to include this header almost
+ * anywhere, let's keep it that way. - Dave Hansen
+ */
+#include <linux/config.h>
+#include <linux/list.h>
+#include <linux/types.h>
+#include <asm/atomic.h>
+
+struct address_space;
+
+#ifdef ARCH_HAS_ATOMIC_UNSIGNED
+typedef unsigned page_flags_t;
+#else
+typedef unsigned long page_flags_t;
+#endif
+
+/*
+ * Each physical page in the system has a struct page associated with
+ * it to keep track of whatever it is we are using the page for at the
+ * moment. Note that we have no way to track which tasks are using
+ * a page.
+ */
+struct page {
+	page_flags_t flags;		/* Atomic flags, some possibly
+					 * updated asynchronously */
+	atomic_t _count;		/* Usage count, see below. */
+	atomic_t _mapcount;		/* Count of ptes mapped in mms,
+					 * to show when page is mapped
+					 * & limit reverse map searches.
+					 */
+	unsigned long private;		/* Mapping-private opaque data:
+					 * usually used for buffer_heads
+					 * if PagePrivate set; used for
+					 * swp_entry_t if PageSwapCache
+					 * When page is free, this indicates
+					 * order in the buddy system.
+					 */
+	struct address_space *mapping;	/* If low bit clear, points to
+					 * inode address_space, or NULL.
+					 * If page mapped as anonymous
+					 * memory, low bit is set, and
+					 * it points to anon_vma object:
+					 * see PAGE_MAPPING_ANON below.
+					 */
+	pgoff_t index;			/* Our offset within mapping. */
+	struct list_head lru;		/* Pageout list, eg. active_list
+					 * protected by zone->lru_lock !
+					 */
+	/*
+	 * On machines where all RAM is mapped into kernel address space,
+	 * we can simply calculate the virtual address. On machines with
+	 * highmem some memory is mapped into kernel virtual memory
+	 * dynamically, so we need a place to store that address.
+	 * Note that this field could be 16 bits on x86 ... ;)
+	 *
+	 * Architectures with slow multiplication can define
+	 * WANT_PAGE_VIRTUAL in their architecture's Kconfig
+	 */
+#ifdef CONFIG_WANT_PAGE_VIRTUAL
+	void *virtual;			/* Kernel virtual address (NULL if
+					   not kmapped, ie. highmem) */
+#endif /* CONFIG_WANT_PAGE_VIRTUAL */
+};
+
+#endif /* _LINUX_STRUCTPAGE_H */
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
