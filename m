Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id E6B526B006C
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 19:09:12 -0400 (EDT)
Received: by igcau2 with SMTP id au2so86323899igc.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:09:12 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id bd10si948811icc.42.2015.03.24.16.09.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 16:09:12 -0700 (PDT)
Received: by iedfl3 with SMTP id fl3so11133572ied.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:09:12 -0700 (PDT)
Date: Tue, 24 Mar 2015 16:09:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/4] mm, mempool: disallow mempools based on slab caches with
 constructors
In-Reply-To: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1503241608540.21805@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net

All occurrences of mempools based on slab caches with object constructors
have been removed from the tree, so disallow creating them.

We can only dereference mem->ctor in mm/mempool.c without including
mm/slab.h in include/linux/mempool.h.  So simply note the restriction,
just like the comment restrictig usage of __GFP_ZERO, and warn on
kernels with CONFIG_DEBUG_VM() if such a mempool is allocated from.

We don't want to incur this check on every element allocation, so use
VM_BUG_ON().

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mempool.h | 3 ++-
 mm/mempool.c            | 2 ++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/mempool.h b/include/linux/mempool.h
--- a/include/linux/mempool.h
+++ b/include/linux/mempool.h
@@ -36,7 +36,8 @@ extern void mempool_free(void *element, mempool_t *pool);
 
 /*
  * A mempool_alloc_t and mempool_free_t that get the memory from
- * a slab that is passed in through pool_data.
+ * a slab cache that is passed in through pool_data.
+ * Note: the slab cache may not have a ctor function.
  */
 void *mempool_alloc_slab(gfp_t gfp_mask, void *pool_data);
 void mempool_free_slab(void *element, void *pool_data);
diff --git a/mm/mempool.c b/mm/mempool.c
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -15,6 +15,7 @@
 #include <linux/mempool.h>
 #include <linux/blkdev.h>
 #include <linux/writeback.h>
+#include "slab.h"
 
 static void add_element(mempool_t *pool, void *element)
 {
@@ -332,6 +333,7 @@ EXPORT_SYMBOL(mempool_free);
 void *mempool_alloc_slab(gfp_t gfp_mask, void *pool_data)
 {
 	struct kmem_cache *mem = pool_data;
+	VM_BUG_ON(mem->ctor);
 	return kmem_cache_alloc(mem, gfp_mask);
 }
 EXPORT_SYMBOL(mempool_alloc_slab);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
