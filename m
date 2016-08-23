Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 94C636B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 16:22:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so92295782wml.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 13:22:43 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id i6si22626523wma.135.2016.08.23.13.22.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 13:22:42 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id o80so19617247wme.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 13:22:41 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH] io-mapping: Fixup for different names of writecombine
Date: Tue, 23 Aug 2016 22:22:33 +0200
Message-Id: <20160823202233.4681-1-daniel.vetter@ffwll.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Intel Graphics Development <intel-gfx@lists.freedesktop.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>

Somehow architectures can't agree on this. And for good measure make
sure we have a fallback which should work everywhere (fingers
crossed).

This is to fix a compile fail on microblaze in gpiolib-of.c, which
misguidedly includes io-mapping.h (instead of screaming at whichever
achitecture doesn't correctly pull in asm/io.h from linux/io.h).

Not tested since there's no reasonable way to get at microblaze
toolchains :(

Fixes: ac96b5566926 ("io-mapping.h: s/PAGE_KERNEL_IO/PAGE_KERNEL/")
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: linux-mm@kvack.org
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/io-mapping.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/io-mapping.h b/include/linux/io-mapping.h
index a87dd7fffc0a..f4e33756c09c 100644
--- a/include/linux/io-mapping.h
+++ b/include/linux/io-mapping.h
@@ -123,7 +123,13 @@ io_mapping_init_wc(struct io_mapping *iomap,
 	iomap->base = base;
 	iomap->size = size;
 	iomap->iomem = ioremap_wc(base, size);
+#ifdef pgprot_noncached_wc /* archs can't agree on a name ... */
+	iomap->prot = pgprot_noncached_wc(PAGE_KERNEL);
+#elif pgprot_writecombine
 	iomap->prot = pgprot_writecombine(PAGE_KERNEL);
+#else
+	iomap->prot = pgprot_noncached(PAGE_KERNEL);
+#endif
 
 	return iomap;
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
