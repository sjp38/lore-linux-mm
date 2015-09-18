Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB8E6B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 01:01:25 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so10545726igb.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 22:01:25 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id v15si5190490igd.78.2015.09.17.22.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 22:01:25 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so40073675pac.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 22:01:24 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] mm/slab: fix unexpected index mapping result of kmalloc_size(INDEX_NODE+1)
Date: Fri, 18 Sep 2015 14:01:15 +0900
Message-Id: <1442552475-21015-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Commit description is copied from original post of this bug.

http://comments.gmane.org/gmane.linux.kernel.mm/135349

Kernels after v3.9 use kmalloc_size(INDEX_NODE + 1) to get the next larger
cache size than the size index INDEX_NODE mapping.  In kernels 3.9 and
earlier we used malloc_sizes[INDEX_L3 + 1].cs_size.

However, sometimes we can't get the right output we expected via
kmalloc_size(INDEX_NODE + 1), causing a BUG().

The mapping table in the latest kernel is like:
    index = {0,   1,  2 ,  3,  4,   5,   6,   n}
     size = {0,   96, 192, 8, 16,  32,  64,   2^n}
The mapping table before 3.10 is like this:
    index = {0 , 1 , 2,   3,  4 ,  5 ,  6,   n}
    size  = {32, 64, 96, 128, 192, 256, 512, 2^(n+3)}

The problem on my mips64 machine is as follows:

(1) When configured DEBUG_SLAB && DEBUG_PAGEALLOC && DEBUG_LOCK_ALLOC
    && DEBUG_SPINLOCK, the sizeof(struct kmem_cache_node) will be "150",
    and the macro INDEX_NODE turns out to be "2": #define INDEX_NODE
    kmalloc_index(sizeof(struct kmem_cache_node))

(2) Then the result of kmalloc_size(INDEX_NODE + 1) is 8.

(3) Then "if(size >= kmalloc_size(INDEX_NODE + 1)" will lead to "size
    = PAGE_SIZE".

(4) Then "if ((size >= (PAGE_SIZE >> 3))" test will be satisfied and
    "flags |= CFLGS_OFF_SLAB" will be covered.

(5) if (flags & CFLGS_OFF_SLAB)" test will be satisfied and will go to
    "cachep->slabp_cache = kmalloc_slab(slab_size, 0u)", and the result
    here may be NULL while kernel bootup.

(6) Finally,"BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));" causes the
    BUG info as the following shows (may be only mips64 has this problem):

This patch fixes the problem of kmalloc_size(INDEX_NODE + 1) and removes
the BUG by adding 'size >= 256' check to guarantee that all necessary
small sized slabs are initialized regardless sequence of slab size in
mapping table.

Fixes: e33660165c90 ("slab: Use common kmalloc_index/kmalloc_size...")
Reported-by: Liuhailong <liu.hailong6@zte.com.cn>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d890750..4fcc5dd 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2190,9 +2190,16 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 			size += BYTES_PER_WORD;
 	}
 #if FORCED_DEBUG && defined(CONFIG_DEBUG_PAGEALLOC)
-	if (size >= kmalloc_size(INDEX_NODE) * 2
-	    && cachep->object_size > cache_line_size()
-	    && ALIGN(size, cachep->align) < PAGE_SIZE) {
+	/*
+	 * To activate debug pagealloc, off-slab management is necessary
+	 * requirement. In early phase of initialization, small sized slab
+	 * doesn't get initialized so it would not be possible. So, we need
+	 * to check size >= 256. It guarantees that all necessary small
+	 * sized slab is initialized in current slab initialization sequence.
+	 */
+	if (!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
+		size >= 256 && cachep->object_size > cache_line_size() &&
+		ALIGN(size, cachep->align) < PAGE_SIZE) {
 		cachep->obj_offset += PAGE_SIZE - ALIGN(size, cachep->align);
 		size = PAGE_SIZE;
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
