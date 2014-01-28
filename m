Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B741E6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 17:24:56 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so906997pdj.16
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 14:24:56 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id i4si113128pad.25.2014.01.28.14.24.51
        for <linux-mm@kvack.org>;
        Tue, 28 Jan 2014 14:24:52 -0800 (PST)
Subject: [RFC][PATCH] mm: sl[uo]b: fix misleading comments
From: Dave Hansen <dave@sr71.net>
Date: Tue, 28 Jan 2014 14:24:50 -0800
Message-Id: <20140128222450.0B32C3FD@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave@sr71.net>, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org


From: Dave Hansen <dave.hansen@linux.intel.com>

On x86, SLUB creates and handles <=8192-byte allocations internally.
It passes larger ones up to the allocator.  Saying "up to order 2" is,
at best, ambiguous.  Is that order-1?  Or (order-2 bytes)?  Make
it more clear.

SLOB commits a similar sin.  It *handles* page-size requests, but the
comment says that it passes up "all page size and larger requests".

SLOB also swaps around the order of the very-similarly-named
KMALLOC_SHIFT_HIGH and KMALLOC_SHIFT_MAX #defines.  Make it
consistent with the order of the other two allocators.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

---

 b/include/linux/slab.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff -puN include/linux/slab.h~mm-slub-off-by-one-comment-on-kmalloc-max include/linux/slab.h
--- a/include/linux/slab.h~mm-slub-off-by-one-comment-on-kmalloc-max	2014-01-28 13:27:50.883108273 -0800
+++ b/include/linux/slab.h	2014-01-28 13:27:50.886108408 -0800
@@ -205,8 +205,8 @@ struct kmem_cache {
 
 #ifdef CONFIG_SLUB
 /*
- * SLUB allocates up to order 2 pages directly and otherwise
- * passes the request to the page allocator.
+ * SLUB directly allocates requests fitting in to an order-1 page
+ * (PAGE_SIZE*2).  Larger requests are passed to the page allocator.
  */
 #define KMALLOC_SHIFT_HIGH	(PAGE_SHIFT + 1)
 #define KMALLOC_SHIFT_MAX	(MAX_ORDER + PAGE_SHIFT)
@@ -217,12 +217,12 @@ struct kmem_cache {
 
 #ifdef CONFIG_SLOB
 /*
- * SLOB passes all page size and larger requests to the page allocator.
+ * SLOB passes all requests larger than one page to the page allocator.
  * No kmalloc array is necessary since objects of different sizes can
  * be allocated from the same page.
  */
-#define KMALLOC_SHIFT_MAX	30
 #define KMALLOC_SHIFT_HIGH	PAGE_SHIFT
+#define KMALLOC_SHIFT_MAX	30
 #ifndef KMALLOC_SHIFT_LOW
 #define KMALLOC_SHIFT_LOW	3
 #endif
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
