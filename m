Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id CC8976B0071
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 05:41:14 -0400 (EDT)
Received: by pdea3 with SMTP id a3so122946502pde.3
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 02:41:14 -0700 (PDT)
Received: from mail.sfc.wide.ad.jp (shonan.sfc.wide.ad.jp. [203.178.142.130])
        by mx.google.com with ESMTPS id gm2si15991785pbc.22.2015.04.17.02.41.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 02:41:13 -0700 (PDT)
From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Subject: [RFC PATCH v2 02/11] slab: add private memory allocator header for arch/lib
Date: Fri, 17 Apr 2015 18:36:05 +0900
Message-Id: <1429263374-57517-3-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
 <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Jhristoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

add header includion for CONFIG_LIB to wrap kmalloc and co. This will
bring malloc(3) based allocator used by arch/lib.

Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
---
 include/linux/slab.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9a139b6..6914e1f 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -205,6 +205,14 @@ size_t ksize(const void *);
 #endif
 #endif
 
+#ifdef CONFIG_LIB
+#define KMALLOC_SHIFT_MAX	30
+#define KMALLOC_SHIFT_HIGH	PAGE_SHIFT
+#ifndef KMALLOC_SHIFT_LOW
+#define KMALLOC_SHIFT_LOW	3
+#endif
+#endif
+
 /* Maximum allocatable size */
 #define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_MAX)
 /* Maximum size for which we actually use a slab cache */
@@ -350,6 +358,9 @@ kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
 }
 #endif
 
+#ifdef CONFIG_LIB
+#include <asm/slab.h>
+#else
 static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 {
 	unsigned int order = get_order(size);
@@ -428,6 +439,7 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 	}
 	return __kmalloc(size, flags);
 }
+#endif
 
 /*
  * Determine size used for the nth kmalloc cache.
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
