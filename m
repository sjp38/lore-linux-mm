Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6700F6B0037
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 18:59:15 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so3212669pbc.35
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 15:59:15 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id vb7si2656929pbc.32.2013.12.13.15.59.12
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 15:59:13 -0800 (PST)
Subject: [RFC][PATCH 6/7] mm: slub: remove 'struct page' alignment restrictions
From: Dave Hansen <dave@sr71.net>
Date: Fri, 13 Dec 2013 15:59:11 -0800
References: <20131213235903.8236C539@viggo.jf.intel.com>
In-Reply-To: <20131213235903.8236C539@viggo.jf.intel.com>
Message-Id: <20131213235911.79AA177D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, Christoph Lameter <cl@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@sr71.net>


SLUB depends on a 16-byte cmpxchg for an optimization.  In order
to get guaranteed 16-byte alignment (required by the hardware on
x86), 'struct page' is padded out from 56 to 64 bytes.

Those 8-bytes matter.  We've gone to great lengths to keep
'struct page' small in the past.  It's a shame that we bloat it
now just for alignment reasons when we have *extra* space.  Also,
increasing the size of 'struct page' by 14% makes it 14% more
likely that we will miss a cacheline when fetching it.

This patch takes an unused 8-byte area of slub's 'struct page'
and reuses it to internally align to the 16-bytes that we need.

Note that this also gets rid of the ugly slub #ifdef that we use
to segregate ->counters and ->_count for cases where we need to
manipulate ->counters without the benefit of a hardware cmpxchg.

This patch takes me from 16909584K of reserved memory at boot
down to 14814472K, so almost *exactly* 2GB of savings!  It also
helps performance, presumably because of that 14% fewer
cacheline effect.  A 30GB dd to a ramfs file:

	dd if=/dev/zero of=bigfile bs=$((1<<30)) count=30

is sped up by about 4.4% in my testing.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/include/linux/mm_types.h |   56 +++++++---------------------
 linux.git-davehans/mm/slab_common.c         |   10 +++--
 linux.git-davehans/mm/slub.c                |    5 ++
 3 files changed, 26 insertions(+), 45 deletions(-)

diff -puN include/linux/mm_types.h~remove-struct-page-alignment-restrictions include/linux/mm_types.h
--- linux.git/include/linux/mm_types.h~remove-struct-page-alignment-restrictions	2013-12-13 15:51:48.591268396 -0800
+++ linux.git-davehans/include/linux/mm_types.h	2013-12-13 15:51:48.595268572 -0800
@@ -24,39 +24,30 @@
 struct address_space;
 
 struct slub_data {
-	void *unused;
 	void *freelist;
 	union {
 		struct {
 			unsigned inuse:16;
 			unsigned objects:15;
 			unsigned frozen:1;
-			atomic_t dontuse_slub_count;
 		};
-		/*
-		 * ->counters is used to make it easier to copy
-		 * all of the above counters in one chunk.
-		 * The actual counts are never accessed via this.
-		 */
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-		unsigned long counters;
-#else
-		/*
-		 * Keep _count separate from slub cmpxchg_double data.
-		 * As the rest of the double word is protected by
-		 * slab_lock but _count is not.
-		 */
 		struct {
-			unsigned counters;
-			/*
-			 * This isn't used directly, but declare it here
-			 * for clarity since it must line up with _count
-			 * from 'struct page'
-			 */
+			/* Note: counters is just a helper for the above bitfield */
+			unsigned long counters;
+			atomic_t padding;
 			atomic_t separate_count;
 		};
-#endif
+		/*
+		 * the double-cmpxchg case:
+		 * counters and _count overlap:
+		 */
+		union {
+			unsigned long counters2;
+			struct {
+				atomic_t padding2;
+				atomic_t _count;
+			};
+		};
 	};
 };
 
@@ -70,15 +61,8 @@ struct slub_data {
  * moment. Note that we have no way to track which tasks are using
  * a page, though if it is a pagecache page, rmap structures can tell us
  * who is mapping it.
- *
- * The objects in struct page are organized in double word blocks in
- * order to allows us to use atomic double word operations on portions
- * of struct page. That is currently only used by slub but the arrangement
- * allows the use of atomic double word operations on the flags/mapping
- * and lru list pointers also.
  */
 struct page {
-	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	union {
@@ -121,7 +105,6 @@ struct page {
 		};
 	};
 
-	/* Third double word block */
 	union {
 		struct list_head lru;	/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
@@ -147,7 +130,6 @@ struct page {
 #endif
 	};
 
-	/* Remainder is not double word aligned */
 	union {
 		unsigned long private;		/* Mapping-private opaque data:
 					 	 * usually used for buffer_heads
@@ -196,15 +178,7 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
-}
-/*
- * The struct page can be forced to be double word aligned so that atomic ops
- * on double words work. The SLUB allocator can make use of such a feature.
- */
-#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
-	__aligned(2 * sizeof(unsigned long))
-#endif
-;
+};
 
 struct page_frag {
 	struct page *page;
diff -puN mm/slab_common.c~remove-struct-page-alignment-restrictions mm/slab_common.c
--- linux.git/mm/slab_common.c~remove-struct-page-alignment-restrictions	2013-12-13 15:51:48.592268440 -0800
+++ linux.git-davehans/mm/slab_common.c	2013-12-13 15:51:48.596268616 -0800
@@ -674,7 +674,6 @@ module_init(slab_proc_init);
 void slab_build_checks(void)
 {
 	SLAB_PAGE_CHECK(_count, dontuse_slab_count);
-	SLAB_PAGE_CHECK(_count, slub_data.dontuse_slub_count);
 	SLAB_PAGE_CHECK(_count, dontuse_slob_count);
 
 	/*
@@ -688,9 +687,12 @@ void slab_build_checks(void)
 	 * carve out for _count in that case actually lines up
 	 * with the real _count.
 	 */
-#if ! (defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-	    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE))
 	SLAB_PAGE_CHECK(_count, slub_data.separate_count);
-#endif
+
+	/*
+	 * We need at least three double-words worth of space to
+	 * ensure that we can align to a double-wordk internally.
+	 */
+	BUILD_BUG_ON(sizeof(struct slub_data) != sizeof(unsigned long) * 3);
 }
 
diff -puN mm/slub.c~remove-struct-page-alignment-restrictions mm/slub.c
--- linux.git/mm/slub.c~remove-struct-page-alignment-restrictions	2013-12-13 15:51:48.593268484 -0800
+++ linux.git-davehans/mm/slub.c	2013-12-13 15:51:48.596268616 -0800
@@ -239,7 +239,12 @@ static inline struct kmem_cache_node *ge
 
 static inline struct slub_data *slub_data(struct page *page)
 {
+	int doubleword_bytes = BITS_PER_LONG * 2 / 8;
 	void *ptr = &page->slub_data;
+#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
+	    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
+	ptr = PTR_ALIGN(ptr, doubleword_bytes);
+#endif
 	return ptr;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
