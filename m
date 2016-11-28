Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CDC66B02DD
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:44 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r94so259035969ioe.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:44 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id g78si9485658iog.32.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 03/33] radix tree test suite: Allow GFP_ATOMIC allocations to fail
Date: Mon, 28 Nov 2016 13:50:41 -0800
Message-Id: <1480369871-5271-38-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

In order to test the preload code, it is necessary to fail GFP_ATOMIC
allocations, which requires defining GFP_KERNEL and GFP_ATOMIC properly.
Remove the obsolete __GFP_WAIT and copy the definitions of the __GFP
flags which are used from the kernel include files.  We also need the
real definition of gfpflags_allow_blocking() to persuade the radix tree
to actually use its preallocated nodes.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 tools/testing/radix-tree/linux.c      |  7 ++++++-
 tools/testing/radix-tree/linux/gfp.h  | 22 +++++++++++++++++++---
 tools/testing/radix-tree/linux/slab.h |  5 -----
 3 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/tools/testing/radix-tree/linux.c b/tools/testing/radix-tree/linux.c
index 1548237..3cfb04e 100644
--- a/tools/testing/radix-tree/linux.c
+++ b/tools/testing/radix-tree/linux.c
@@ -33,7 +33,12 @@ mempool_t *mempool_create(int min_nr, mempool_alloc_t *alloc_fn,
 
 void *kmem_cache_alloc(struct kmem_cache *cachep, int flags)
 {
-	void *ret = malloc(cachep->size);
+	void *ret;
+
+	if (flags & __GFP_NOWARN)
+		return NULL;
+
+	ret = malloc(cachep->size);
 	if (cachep->ctor)
 		cachep->ctor(ret);
 	uatomic_inc(&nr_allocated);
diff --git a/tools/testing/radix-tree/linux/gfp.h b/tools/testing/radix-tree/linux/gfp.h
index 5201b91..5b09b2c 100644
--- a/tools/testing/radix-tree/linux/gfp.h
+++ b/tools/testing/radix-tree/linux/gfp.h
@@ -3,8 +3,24 @@
 
 #define __GFP_BITS_SHIFT 26
 #define __GFP_BITS_MASK ((gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
-#define __GFP_WAIT 1
-#define __GFP_ACCOUNT 0
-#define __GFP_NOWARN 0
+
+#define __GFP_HIGH		0x20u
+#define __GFP_IO		0x40u
+#define __GFP_FS		0x80u
+#define __GFP_NOWARN		0x200u
+#define __GFP_ATOMIC		0x80000u
+#define __GFP_ACCOUNT		0x100000u
+#define __GFP_DIRECT_RECLAIM	0x400000u
+#define __GFP_KSWAPD_RECLAIM	0x2000000u
+
+#define __GFP_RECLAIM		(__GFP_DIRECT_RECLAIM|__GFP_KSWAPD_RECLAIM)
+
+#define GFP_ATOMIC		(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
+#define GFP_KERNEL		(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
+
+static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
+{
+	return !!(gfp_flags & __GFP_DIRECT_RECLAIM);
+}
 
 #endif
diff --git a/tools/testing/radix-tree/linux/slab.h b/tools/testing/radix-tree/linux/slab.h
index 6d5a347..452e2bf 100644
--- a/tools/testing/radix-tree/linux/slab.h
+++ b/tools/testing/radix-tree/linux/slab.h
@@ -7,11 +7,6 @@
 #define SLAB_PANIC 2
 #define SLAB_RECLAIM_ACCOUNT    0x00020000UL            /* Objects are reclaimable */
 
-static inline int gfpflags_allow_blocking(gfp_t mask)
-{
-	return 1;
-}
-
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
