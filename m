Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f51.google.com (mail-vn0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 31E0F6B006E
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 17:05:39 -0400 (EDT)
Received: by vnbg62 with SMTP id g62so10767374vnb.6
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 14:05:38 -0700 (PDT)
Received: from relay.fireflyinternet.com (hostedrelay.fireflyinternet.com. [109.228.30.76])
        by mx.google.com with ESMTP id wc6si13669910wjc.103.2015.04.07.09.31.45
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 09:31:45 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 3/5] io-mapping: Always create a struct to hold metadata about the io-mapping
Date: Tue,  7 Apr 2015 17:31:37 +0100
Message-Id: <1428424299-13721-4-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <1428424299-13721-1-git-send-email-chris@chris-wilson.co.uk>
References: <1428424299-13721-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org

Currently, we only allocate a structure to hold metadata if we need to
allocate an ioremap for every access, such as on x86-32. However, it
would be useful to store basic information about the io-mapping, such as
its page protection, on all platforms.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-mm@kvack.org
---
 include/linux/io-mapping.h | 52 ++++++++++++++++++++++++++++------------------
 1 file changed, 32 insertions(+), 20 deletions(-)

diff --git a/include/linux/io-mapping.h b/include/linux/io-mapping.h
index 657fab4efab3..e053011f50bb 100644
--- a/include/linux/io-mapping.h
+++ b/include/linux/io-mapping.h
@@ -31,16 +31,17 @@
  * See Documentation/io-mapping.txt
  */
 
-#ifdef CONFIG_HAVE_ATOMIC_IOMAP
-
-#include <asm/iomap.h>
-
 struct io_mapping {
 	resource_size_t base;
 	unsigned long size;
 	pgprot_t prot;
+	void __iomem *iomem;
 };
 
+
+#ifdef CONFIG_HAVE_ATOMIC_IOMAP
+
+#include <asm/iomap.h>
 /*
  * For small address space machines, mapping large objects
  * into the kernel virtual space isn't practical. Where
@@ -119,48 +120,59 @@ io_mapping_unmap(void __iomem *vaddr)
 #else
 
 #include <linux/uaccess.h>
-
-/* this struct isn't actually defined anywhere */
-struct io_mapping;
+#include <asm/pgtable_types.h>
 
 /* Create the io_mapping object*/
 static inline struct io_mapping *
 io_mapping_create_wc(resource_size_t base, unsigned long size)
 {
-	return (struct io_mapping __force *) ioremap_wc(base, size);
+	struct io_mapping *iomap;
+
+	iomap = kmalloc(sizeof(*iomap), GFP_KERNEL);
+	if (!iomap)
+		return NULL;
+
+	iomap->base = base;
+	iomap->size = size;
+	iomap->iomem = ioremap_wc(base, size);
+	iomap->prot = pgprot_writecombine(PAGE_KERNEL_IO);
+
+	return iomap;
 }
 
 static inline void
 io_mapping_free(struct io_mapping *mapping)
 {
-	iounmap((void __force __iomem *) mapping);
+	iounmap(mapping->iomem);
+	kfree(mapping);
 }
 
-/* Atomic map/unmap */
+/* Non-atomic map/unmap */
 static inline void __iomem *
-io_mapping_map_atomic_wc(struct io_mapping *mapping,
-			 unsigned long offset)
+io_mapping_map_wc(struct io_mapping *mapping, unsigned long offset)
 {
-	pagefault_disable();
-	return ((char __force __iomem *) mapping) + offset;
+	return mapping->iomem + offset;
 }
 
 static inline void
-io_mapping_unmap_atomic(void __iomem *vaddr)
+io_mapping_unmap(void __iomem *vaddr)
 {
-	pagefault_enable();
 }
 
-/* Non-atomic map/unmap */
+/* Atomic map/unmap */
 static inline void __iomem *
-io_mapping_map_wc(struct io_mapping *mapping, unsigned long offset)
+io_mapping_map_atomic_wc(struct io_mapping *mapping,
+			 unsigned long offset)
 {
-	return ((char __force __iomem *) mapping) + offset;
+	pagefault_disable();
+	return io_mapping_map_wc(mapping, offset);
 }
 
 static inline void
-io_mapping_unmap(void __iomem *vaddr)
+io_mapping_unmap_atomic(void __iomem *vaddr)
 {
+	io_mapping_unmap(vaddr);
+	pagefault_enable();
 }
 
 #endif /* HAVE_ATOMIC_IOMAP */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
