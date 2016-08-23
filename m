Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id BED756B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 03:23:00 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p85so90543520lfg.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 00:23:00 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id cz2si1791684wjb.250.2016.08.23.00.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 00:22:59 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id o80so16781831wme.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 00:22:59 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH] io-mapping.h: s/PAGE_KERNEL_IO/PAGE_KERNEL/
Date: Tue, 23 Aug 2016 08:22:53 +0100
Message-Id: <20160823072253.26977-1-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Daniel Vetter <daniel.vetter@ffwll.ch>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, linux-mm@kvack.org

PAGE_KERNEL_IO is an x86-ism. Though it is used to define the pgprot_t
used for the iomapped region, it itself is just PAGE_KERNEL. On all
other arches, PAGE_KERNEL_IO is undefined so in a general header we must
refrain from using it.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Fixes: cafaf14a5d8f ("io-mapping: Always create a struct to hold metadata about the io-mapping")
Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: linux-mm@kvack.org
---
 include/linux/io-mapping.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/io-mapping.h b/include/linux/io-mapping.h
index b4c4b5c4216d..ab690801eb59 100644
--- a/include/linux/io-mapping.h
+++ b/include/linux/io-mapping.h
@@ -112,7 +112,6 @@ io_mapping_unmap(void __iomem *vaddr)
 #else
 
 #include <linux/uaccess.h>
-#include <asm/pgtable_types.h>
 
 /* Create the io_mapping object*/
 static inline struct io_mapping *
@@ -123,7 +122,7 @@ io_mapping_init_wc(struct io_mapping *iomap,
 	iomap->base = base;
 	iomap->size = size;
 	iomap->iomem = ioremap_wc(base, size);
-	iomap->prot = pgprot_writecombine(PAGE_KERNEL_IO);
+	iomap->prot = pgprot_writecombine(PAGE_KERNEL);
 
 	return iomap;
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
