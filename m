Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 669FE6B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 21:14:42 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id i13so1056040qae.17
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 18:14:42 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id f4si959164qai.100.2013.11.22.18.14.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Nov 2013 18:14:41 -0800 (PST)
Message-ID: <52900F8E.5000004@infradead.org>
Date: Fri, 22 Nov 2013 18:14:38 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH resend] slab.h: remove duplicate kmalloc declaration and fix
 kernel-doc warnings
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Qiang Huang <h.huangqiang@huawei.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

From: Randy Dunlap <rdunlap@infradead.org>

Fix kernel-doc warning for duplicate definition of 'kmalloc':

Documentation/DocBook/kernel-api.xml:9483: element refentry: validity error : ID API-kmalloc already defined
<refentry id="API-kmalloc">

Also combine the kernel-doc info from the 2 kmalloc definitions into one
block and remove the "see kcalloc" comment since kmalloc now contains the
@flags info.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Acked-by: Christoph Lameter <cl@linux.com>
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
