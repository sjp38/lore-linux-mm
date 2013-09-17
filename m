Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id A106F6B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 14:35:13 -0400 (EDT)
Message-ID: <5238A0D6.4090802@infradead.org>
Date: Tue, 17 Sep 2013 11:35:02 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH 1/2] mm: fix slab.h kmalloc comments
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix kernel-doc warning for duplicate definition of 'kmalloc':

Documentation/DocBook/kernel-api.xml:9483: element refentry: validity error : ID API-kmalloc already defined
<refentry id="API-kmalloc">

Also combine the kernel-doc info from the 2 kmalloc definitions into one
block and remove the "see kcalloc" comment since kmalloc now contains the
@flags info.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 include/linux/slab.h |  102 ++++++++++++++++++-----------------------
 1 file changed, 46 insertions(+), 56 deletions(-)

--- lnx-312-rc1.orig/include/linux/slab.h
+++ lnx-312-rc1/include/linux/slab.h
@@ -381,10 +381,55 @@ static __always_inline void *kmalloc_lar
 /**
  * kmalloc - allocate memory
  * @size: how many bytes of memory are required.
- * @flags: the type of memory to allocate (see kcalloc).
+ * @flags: the type of memory to allocate.
  *
  * kmalloc is the normal method of allocating memory
  * for objects smaller than page size in the kernel.
+ *
+ * The @flags argument may be one of:
+ *
+ * %GFP_USER - Allocate memory on behalf of user.  May sleep.
+ *
+ * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
+ *
+ * %GFP_ATOMIC - Allocation will not sleep.  May use emergency pools.
+ *   For example, use this inside interrupt handlers.
+ *
+ * %GFP_HIGHUSER - Allocate pages from high memory.
+ *
+ * %GFP_NOIO - Do not do any I/O at all while trying to get memory.
+ *
+ * %GFP_NOFS - Do not make any fs calls while trying to get memory.
+ *
+ * %GFP_NOWAIT - Allocation will not sleep.
+ *
+ * %GFP_THISNODE - Allocate node-local memory only.
+ *
+ * %GFP_DMA - Allocation suitable for DMA.
+ *   Should only be used for kmalloc() caches. Otherwise, use a
+ *   slab created with SLAB_DMA.
+ *
+ * Also it is possible to set different flags by OR'ing
+ * in one or more of the following additional @flags:
+ *
+ * %__GFP_COLD - Request cache-cold pages instead of
+ *   trying to return cache-warm pages.
+ *
+ * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
+ *
+ * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
+ *   (think twice before using).
+ *
+ * %__GFP_NORETRY - If memory is not immediately available,
+ *   then give up at once.
+ *
+ * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
+ *
+ * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
+ *
+ * There are other flags available as well, but these are not intended
+ * for general use, and so are not documented here. For a full list of
+ * potential flags, always refer to linux/gfp.h.
  */
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
@@ -495,61 +540,6 @@ int cache_show(struct kmem_cache *s, str
 void print_slabinfo_header(struct seq_file *m);
 
 /**
- * kmalloc - allocate memory
- * @size: how many bytes of memory are required.
- * @flags: the type of memory to allocate.
- *
- * The @flags argument may be one of:
- *
- * %GFP_USER - Allocate memory on behalf of user.  May sleep.
- *
- * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
- *
- * %GFP_ATOMIC - Allocation will not sleep.  May use emergency pools.
- *   For example, use this inside interrupt handlers.
- *
- * %GFP_HIGHUSER - Allocate pages from high memory.
- *
- * %GFP_NOIO - Do not do any I/O at all while trying to get memory.
- *
- * %GFP_NOFS - Do not make any fs calls while trying to get memory.
- *
- * %GFP_NOWAIT - Allocation will not sleep.
- *
- * %GFP_THISNODE - Allocate node-local memory only.
- *
- * %GFP_DMA - Allocation suitable for DMA.
- *   Should only be used for kmalloc() caches. Otherwise, use a
- *   slab created with SLAB_DMA.
- *
- * Also it is possible to set different flags by OR'ing
- * in one or more of the following additional @flags:
- *
- * %__GFP_COLD - Request cache-cold pages instead of
- *   trying to return cache-warm pages.
- *
- * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
- *
- * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
- *   (think twice before using).
- *
- * %__GFP_NORETRY - If memory is not immediately available,
- *   then give up at once.
- *
- * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
- *
- * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
- *
- * There are other flags available as well, but these are not intended
- * for general use, and so are not documented here. For a full list of
- * potential flags, always refer to linux/gfp.h.
- *
- * kmalloc is the normal method of allocating memory
- * in the kernel.
- */
-static __always_inline void *kmalloc(size_t size, gfp_t flags);
-
-/**
  * kmalloc_array - allocate memory for an array.
  * @n: number of elements.
  * @size: element size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
