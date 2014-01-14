Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8846B003D
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 13:02:04 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so5100297pdi.7
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:02:04 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id yy4si1157854pbc.339.2014.01.14.10.01.35
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 10:01:36 -0800 (PST)
Subject: [RFC][PATCH 9/9] mm: fix alignment checks on 32-bit
From: Dave Hansen <dave@sr71.net>
Date: Tue, 14 Jan 2014 10:01:08 -0800
References: <20140114180042.C1C33F78@viggo.jf.intel.com>
In-Reply-To: <20140114180042.C1C33F78@viggo.jf.intel.com>
Message-Id: <20140114180108.F51A8DF5@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org, Dave Hansen <dave@sr71.net>


The checks fail on 32-bit.  This needs to get folded back in to
the original patches.  Please ignore this for now.

---

 b/include/linux/mm_types.h |   14 ++++++++------
 b/mm/slab_common.c         |   16 ++++++----------
 2 files changed, 14 insertions(+), 16 deletions(-)

diff -puN include/linux/mm_types.h~fix-slub-size-32-bit include/linux/mm_types.h
--- a/include/linux/mm_types.h~fix-slub-size-32-bit	2014-01-14 09:57:58.738740304 -0800
+++ b/include/linux/mm_types.h	2014-01-14 09:57:58.743740528 -0800
@@ -37,19 +37,21 @@ struct slub_data {
 		 * slab_lock but _count is not.
 		 */
 		struct {
-			/* counters is just a helperfor the above bitfield */
+ 			/* counters is just a helper for the above bitfield */
 			unsigned long counters;
-			atomic_t padding;
+			atomic_t mapcount_padding;
 			atomic_t separate_count;
 		};
 		/*
-		 * the double-cmpxchg case:
-		 * counters and _count overlap
+		 * the double-cmpxchg case (never used on 32-bit):
+		 * counters overlaps _count, and we are careful
+		 * to only use 32-bits of 'counters' so that we
+		 * do not interfere with _count.
 		 */
 		union {
 			unsigned long counters2;
 			struct {
-				atomic_t padding2;
+				atomic_t _unused_mapcount;
 				atomic_t _count;
 			};
 		};
@@ -73,7 +75,6 @@ struct page {
 					 * updated asynchronously */
 	union {
 		struct /* the normal uses */ {
-			pgoff_t index;		/* Our offset within mapping. */
 			/*
 			 * mapping: If low bit clear, points to
 			 * inode address_space, or NULL.  If page
@@ -82,6 +83,7 @@ struct page {
 			 * see PAGE_MAPPING_ANON below.
 			 */
 			struct address_space *mapping;
+			pgoff_t index;		/* Our offset within mapping. */
 			/*
 			 * Count of ptes mapped in mms, to show when page
 			 * is mapped & limit reverse map searches.
diff -puN mm/slab_common.c~fix-slub-size-32-bit mm/slab_common.c
--- a/mm/slab_common.c~fix-slub-size-32-bit	2014-01-14 09:57:58.739740349 -0800
+++ b/mm/slab_common.c	2014-01-14 09:57:58.743740528 -0800
@@ -695,15 +695,11 @@ void slab_build_checks(void)
 	SLAB_PAGE_CHECK(_count, dontuse_slob_count);
 
 	/*
-	 * When doing a double-cmpxchg, the slub code sucks in
-	 * _count.  But, this is harmless since if _count is
-	 * modified, the cmpxchg will fail.  When not using a
-	 * real cmpxchg, the slub code uses a lock.  But, _count
-	 * is not modified under that lock and updates can be
-	 * lost if they race with one of the "faked" cmpxchg
-	 * under that lock.  This makes sure that the space we
-	 * carve out for _count in that case actually lines up
-	 * with the real _count.
+	 * The slub code uses page->_mapcount's space for some
+	 * internal counters.  But, since ->_count and
+	 * ->_mapcount are 32-bit everywhere and the slub
+	 * counters are an unsigned long which changes size,
+	 * we need to change the checks on 32 vs. 64-bit.
 	 */
 	SLAB_PAGE_CHECK(_count, slub_data.separate_count);
 
@@ -711,6 +707,6 @@ void slab_build_checks(void)
 	 * We need at least three double-words worth of space to
 	 * ensure that we can align to a double-wordk internally.
 	 */
-	BUILD_BUG_ON(sizeof(struct slub_data) != sizeof(unsigned long) * 3);
+	BUILD_BUG_ON(sizeof(struct slub_data) < sizeof(unsigned long) * 3);
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
