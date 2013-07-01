Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id B9F606B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:57:57 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 01/13] mm: add PRAM API stubs and Kconfig
Date: Mon, 1 Jul 2013 15:57:36 +0400
Message-ID: <fdf9aceddf42b7568efaec2e483374c3526e9776.1372582755.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

Persistent memory subsys or PRAM is intended to be used for saving
memory pages of the currently executing kernel and restoring them after
a kexec in the newly booted one. This can be utilized for speeding up
reboot by leaving process memory and/or FS caches in-place.

The proposed API:

 * Persistent memory is divided into nodes, which can be saved or loaded
   independently of each other. The nodes are identified by unique name
   strings. PRAM node is created (removed) when save (load) is initiated
   by calling pram_prepare_save() (pram_prepare_load()), see below.

 * For saving/loading data from a PRAM node an instance of the
   pram_stream struct is used. The struct is initialized by calling
   pram_prepare_save() for saving data or pram_prepare_load() for
   loading data. After save (load) is complete, pram_finish_save()
   (pram_finish_load()) must be called. If an error occurred during
   save, the saved data and the PRAM node may be freed by calling
   pram_discard_save() instead of pram_finish_save().

 * Each pram_stream has a type, which  determines the set of operations
   that may be used for saving/loading data. The type is defined by the
   pram_stream_type enum. Currently there are two stream types
   available: PRAM_PAGE_STREAM to save/load memory pages, and
   PRAM_BYTE_STREAM to save/load byte strings. For page streams
   pram_save_page() and pram_load_page() may be used, and for byte
   streams pram_write() and pram_read() may be used for saving and
   loading data respectively.

Thus a sequence of operations for saving/loading data from PRAM should
look like:

  * For saving data to PRAM:

    /* create PRAM node and initialize stream for saving data to it */
    pram_prepare_save()

    /* save data to the node */
    pram_save_page()[,...]      /* for page stream, or
    pram_write()[,...]           * ... for byte stream */

    /* commit the save or discard and delete the node */
    pram_finish_save()          /* on success, or
    pram_discard_save()          * ... in case of error */

  * For loading data from PRAM:

    /* remove PRAM node from the list and initialize stream for
     * loading data from it */
    pram_prepare_load()

    /* load data from the node */
    pram_load_page()[,...]      /* for page stream, or
    pram_read()[,...]            * ... for byte stream */

    /* free the node */
    pram_finish_load()
---
 include/linux/pram.h |   38 +++++++++++++++
 mm/Kconfig           |    9 ++++
 mm/Makefile          |    1 +
 mm/pram.c            |  131 ++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 179 insertions(+)
 create mode 100644 include/linux/pram.h
 create mode 100644 mm/pram.c

diff --git a/include/linux/pram.h b/include/linux/pram.h
new file mode 100644
index 0000000..cf04548
--- /dev/null
+++ b/include/linux/pram.h
@@ -0,0 +1,38 @@
+#ifndef _LINUX_PRAM_H
+#define _LINUX_PRAM_H
+
+#include <linux/gfp.h>
+#include <linux/types.h>
+#include <linux/mm_types.h>
+
+struct pram_stream;
+
+#define PRAM_NAME_MAX		256	/* including nul */
+
+enum pram_stream_type {
+	PRAM_PAGE_STREAM,
+	PRAM_BYTE_STREAM,
+};
+
+extern int pram_prepare_save(struct pram_stream *ps,
+		const char *name, enum pram_stream_type type, gfp_t gfp_mask);
+extern void pram_finish_save(struct pram_stream *ps);
+extern void pram_discard_save(struct pram_stream *ps);
+
+extern int pram_prepare_load(struct pram_stream *ps,
+		const char *name, enum pram_stream_type type);
+extern void pram_finish_load(struct pram_stream *ps);
+
+#define PRAM_PAGE_LRU		0x01	/* page is on the LRU */
+
+/* page-stream specific methods */
+extern int pram_save_page(struct pram_stream *ps,
+			  struct page *page, int flags);
+extern struct page *pram_load_page(struct pram_stream *ps, int *flags);
+
+/* byte-stream specific methods */
+extern ssize_t pram_write(struct pram_stream *ps,
+			  const void *buf, size_t count);
+extern size_t pram_read(struct pram_stream *ps, void *buf, size_t count);
+
+#endif /* _LINUX_PRAM_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 3bea74f..46337e8 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -471,3 +471,12 @@ config FRONTSWAP
 	  and swap data is stored as normal on the matching swap device.
 
 	  If unsure, say Y to enable frontswap.
+
+config PRAM
+	bool "Persistent over-kexec memory storage"
+	default n
+	help
+	  This option adds the kernel API that enables saving memory pages of
+	  the currently executing kernel and restoring them after a kexec in
+	  the newly booted one. This can be utilized for speeding up reboot by
+	  leaving process memory and/or FS caches in-place.
diff --git a/mm/Makefile b/mm/Makefile
index 3a46287..33ad952 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -58,3 +58,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
+obj-$(CONFIG_PRAM) += pram.o
diff --git a/mm/pram.c b/mm/pram.c
new file mode 100644
index 0000000..cea0e87
--- /dev/null
+++ b/mm/pram.c
@@ -0,0 +1,131 @@
+#include <linux/err.h>
+#include <linux/gfp.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/pram.h>
+#include <linux/types.h>
+
+/**
+ * Create a persistent memory node with name @name and initialize stream @ps
+ * for saving data to it.
+ *
+ * @type determines the content type of the newly created node and, as a
+ * result, the set of operations that may be used on the stream as follows:
+ *    %PRAM_PAGE_STREAM: page stream, use pram_save_page()
+ *    %PRAM_BYTE_STREAM: byte stream, use pram_write()
+ *
+ * @gfp_mask specifies the memory allocation mask to be used when saving data.
+ *
+ * Returns 0 on success, -errno on failure.
+ *
+ * After the save has finished, pram_finish_save() (or pram_discard_save() in
+ * case of failure) is to be called.
+ */
+int pram_prepare_save(struct pram_stream *ps,
+		const char *name, enum pram_stream_type type, gfp_t gfp_mask)
+{
+	return -ENOSYS;
+}
+
+/**
+ * Commit the save to persistent memory started with pram_prepare_save().
+ * After the call, the stream may not be used any more.
+ */
+void pram_finish_save(struct pram_stream *ps)
+{
+	BUG();
+}
+
+/**
+ * Cancel the save to persistent memory started with pram_prepare_save() and
+ * destroy the corresponding persistent memory node freeing all data that have
+ * been saved to it.
+ */
+void pram_discard_save(struct pram_stream *ps)
+{
+	BUG();
+}
+
+/**
+ * Remove the peristent memory node with name @name and initialize stream @ps
+ * for loading data from it.
+ *
+ * @type determines the content type of the node to be loaded and, as a result,
+ * the set of operations that may be used on the stream as follows:
+ *    %PRAM_PAGE_STREAM: page stream, use pram_load_page()
+ *    %PRAM_BYTE_STREAM: byte stream, use pram_read()
+ *
+ * Returns 0 on success, -errno on failure.
+ *
+ * After the load has finished, pram_finish_load() is to be called.
+ */
+int pram_prepare_load(struct pram_stream *ps,
+		const char *name, enum pram_stream_type type)
+{
+	return -ENOSYS;
+}
+
+/**
+ * Finish the load from persistent memory started with pram_prepare_load()
+ * freeing the corresponding persistent memory node and all data that have not
+ * been loaded from it.
+ */
+void pram_finish_load(struct pram_stream *ps)
+{
+	BUG();
+}
+
+/**
+ * Save page @page to the persistent memory node associated with stream @ps.
+ * The stream must be initialized with pram_prepare_save().
+ *
+ * @flags determines the page state. If the page is on the lru, @flags should
+ * have the PRAM_PAGE_LRU bit set.
+ *
+ * Returns 0 on success, -errno on failure.
+ */
+int pram_save_page(struct pram_stream *ps, struct page *page, int flags)
+{
+	return -ENOSYS;
+}
+
+/**
+ * Load the next page from the persistent memory node associated with stream
+ * @ps. The stream must be initialized with pram_prepare_load().
+ *
+ * If not NULL, @flags is initialized with the state of the page loaded. If the
+ * page is on the lru, it will have the PRAM_PAGE_LRU bit set.
+ *
+ * Returns the page loaded or NULL if the node is empty.
+ *
+ * Pages are loaded from persistent memory in the same order they were saved.
+ * The page loaded has its refcounter incremeneted.
+ */
+struct page *pram_load_page(struct pram_stream *ps, int *flags)
+{
+	return NULL;
+}
+
+/**
+ * Copy @count bytes from @buf to the persistent memory node assiciated with
+ * stream @ps. The stream must be initialized with pram_prepare_save().
+ *
+ * On success, returns the number of bytes written, which is always equal to
+ * @count. On failure, -errno is returned.
+ */
+ssize_t pram_write(struct pram_stream *ps, const void *buf, size_t count)
+{
+	return -ENOSYS;
+}
+
+/**
+ * Copy up to @count bytes from the persistent memory node assiciated with
+ * stream @ps to @buf. The stream must be initialized with pram_prepare_load().
+ *
+ * Returns the number of bytes read, which may be less than @count if the node
+ * has fewer bytes available.
+ */
+size_t pram_read(struct pram_stream *ps, void *buf, size_t count)
+{
+	return 0;
+}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
