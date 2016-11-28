Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3485E6B02D1
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:35 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j92so262124359ioi.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:35 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id i193si20010562itf.102.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 32/33] radix tree test suite: Add some more functionality
Date: Mon, 28 Nov 2016 13:50:36 -0800
Message-Id: <1480369871-5271-33-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

IDR needs more functionality from the kernel: kmalloc()/kfree(), and xchg().

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 tools/testing/radix-tree/linux.c        | 15 +++++++++++++++
 tools/testing/radix-tree/linux/kernel.h |  3 +++
 tools/testing/radix-tree/linux/slab.h   |  3 +++
 3 files changed, 21 insertions(+)

diff --git a/tools/testing/radix-tree/linux.c b/tools/testing/radix-tree/linux.c
index 1f32a16..ff0452e 100644
--- a/tools/testing/radix-tree/linux.c
+++ b/tools/testing/radix-tree/linux.c
@@ -54,6 +54,21 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 	free(objp);
 }
 
+void *kmalloc(size_t size, gfp_t gfp)
+{
+	void *ret = malloc(size);
+	uatomic_inc(&nr_allocated);
+	return ret;
+}
+
+void kfree(void *p)
+{
+	if (!p)
+		return;
+	uatomic_dec(&nr_allocated);
+	free(p);
+}
+
 struct kmem_cache *
 kmem_cache_create(const char *name, size_t size, size_t offset,
 	unsigned long flags, void (*ctor)(void *))
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index 23e77f5..9b43b49 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -8,6 +8,7 @@
 #include <limits.h>
 
 #include "../../include/linux/compiler.h"
+#include "../../include/linux/err.h"
 #include "../../../include/linux/kconfig.h"
 
 #ifdef BENCHMARK
@@ -58,4 +59,6 @@ static inline int in_interrupt(void)
 #define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
 #define round_down(x, y) ((x) & ~__round_mask(x, y))
 
+#define xchg(ptr, x)	uatomic_xchg(ptr, x)
+
 #endif /* _KERNEL_H */
diff --git a/tools/testing/radix-tree/linux/slab.h b/tools/testing/radix-tree/linux/slab.h
index 452e2bf..446639f 100644
--- a/tools/testing/radix-tree/linux/slab.h
+++ b/tools/testing/radix-tree/linux/slab.h
@@ -7,6 +7,9 @@
 #define SLAB_PANIC 2
 #define SLAB_RECLAIM_ACCOUNT    0x00020000UL            /* Objects are reclaimable */
 
+void *kmalloc(size_t size, gfp_t);
+void kfree(void *);
+
 struct kmem_cache {
 	int size;
 	void (*ctor)(void *);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
