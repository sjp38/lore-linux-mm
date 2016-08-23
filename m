Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C59176B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 11:50:31 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so88182724wme.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 08:50:31 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id gf6si3677350wjb.72.2016.08.23.08.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 08:50:30 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id o80so18724447wme.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 08:50:30 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v2] io-mapping.h: s/PAGE_KERNEL_IO/PAGE_KERNEL/
Date: Tue, 23 Aug 2016 16:50:24 +0100
Message-Id: <20160823155024.22379-1-chris@chris-wilson.co.uk>
In-Reply-To: <CAKMK7uFjtbsareLBGjCWvypybNRVROpkrD-oCDxvnj8B+EkDgQ@mail.gmail.com>
References: <CAKMK7uFjtbsareLBGjCWvypybNRVROpkrD-oCDxvnj8B+EkDgQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Daniel Vetter <daniel.vetter@ffwll.ch>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, linux-mm@kvack.org

PAGE_KERNEL_IO is an x86-ism. Though it is used to define the pgprot_t
used for the iomapped region, it itself is just PAGE_KERNEL. On all
other arches, PAGE_KERNEL_IO is undefined so in a general header we must
refrain from using it.

v2: include pgtable for pgprot_combine()

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Fixes: cafaf14a5d8f ("io-mapping: Always create a struct to hold metadata about the io-mapping")
Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: linux-mm@kvack.org
---
 include/linux/io-mapping.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/io-mapping.h b/include/linux/io-mapping.h
index b4c4b5c4216d..a87dd7fffc0a 100644
--- a/include/linux/io-mapping.h
+++ b/include/linux/io-mapping.h
@@ -112,7 +112,7 @@ io_mapping_unmap(void __iomem *vaddr)
 #else
 
 #include <linux/uaccess.h>
-#include <asm/pgtable_types.h>
+#include <asm/pgtable.h>
 
 /* Create the io_mapping object*/
 static inline struct io_mapping *
@@ -123,7 +123,7 @@ io_mapping_init_wc(struct io_mapping *iomap,
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
