Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 387596B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:13:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 128so133705796pfz.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:13:52 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id ef5si14940563pac.293.2016.10.24.17.13.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:13:51 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 02/43] radix tree test suite: Allow GFP_ATOMIC allocations to fail
Date: Tue, 25 Oct 2016 03:13:01 +0300
Message-Id: <20161025001342.76126-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

In order to test the preload code, it is necessary to fail GFP_ATOMIC
allocations, which requires defining GFP_KERNEL and GFP_ATOMIC properly.
Remove the obsolete __GFP_WAIT and copy the definitions of the __GFP
flags which are used from the kernel include files.  We also need the
real definition of gfpflags_allow_blocking() to persuade the radix tree
to actually use its preallocated nodes.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 tools/testing/radix-tree/linux.c      |  7 ++++++-
 tools/testing/radix-tree/linux/gfp.h  | 22 +++++++++++++++++++---
 tools/testing/radix-tree/linux/slab.h |  5 -----
 3 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/tools/testing/radix-tree/linux.c b/tools/testing/radix-tree/linux.c
index 154823737b20..3cfb04e98e2f 100644
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
index 5201b915f631..5b09b2ce6c33 100644
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
index 6d5a34770fd4..452e2bf502e3 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
