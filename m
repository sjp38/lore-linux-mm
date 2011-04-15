Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 734B390008E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:13:03 -0400 (EDT)
Message-Id: <20110415201300.792352989@linux.com>
Date: Fri, 15 Apr 2011 15:12:56 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv333num@/21] mm: Rearrange struct page
References: <20110415201246.096634892@linux.com>
Content-Disposition: inline; filename=resort_struct_page
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

We need to be able to use cmpxchg_double on the freelist and object count
field in struct page. Rearrange the fields in struct page according to
doubleword entities so that the freelist pointer comes before the counters.
Do the rearranging with a future in mind where we use more doubleword
atomics to avoid locking of updates to flags/mapping or lru pointers.

Create another union to allow access to counters in struct page as a
single unsigned long value.

The doublewords must be properly aligned for cmpxchg_double to work.
Sadly this increases the size of page struct by one word but as a result
page structs are now cacheline aligned on x86_64.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/mm_types.h |   85 ++++++++++++++++++++++++++++++-----------------
 1 file changed, 55 insertions(+), 30 deletions(-)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2011-04-15 13:14:36.000000000 -0500
+++ linux-2.6/include/linux/mm_types.h	2011-04-15 13:14:48.000000000 -0500
@@ -30,52 +30,68 @@ struct address_space;
  * moment. Note that we have no way to track which tasks are using
  * a page, though if it is a pagecache page, rmap structures can tell us
  * who is mapping it.
+ *
+ * The objects in struct page are organized in double word blocks in
+ * order to allows us to use atomic double word operations on portions
+ * of struct page. That is currently only used by slub but the arrangement
+ * allows the use of atomic double word operations on the flags/mapping
+ * and lru list pointers also.
  */
 struct page {
+	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
-	atomic_t _count;		/* Usage count, see below. */
-	union {
-		atomic_t _mapcount;	/* Count of ptes mapped in mms,
-					 * to show when page is mapped
-					 * & limit reverse map searches.
+	struct address_space *mapping;	/* If low bit clear, points to
+					 * inode address_space, or NULL.
+					 * If page mapped as anonymous
+					 * memory, low bit is set, and
+					 * it points to anon_vma object:
+					 * see PAGE_MAPPING_ANON below.
 					 */
-		struct {		/* SLUB */
-			unsigned inuse:16;
-			unsigned objects:15;
-			unsigned frozen:1;
+	/* Second double word block used by SLUB */
+	union {
+		pgoff_t index;		/* Our offset within mapping. */
+		void *freelist;		/* SLUB: freelist req. slab lock */
+	};
+	union {
+		unsigned long counters;
+		struct {
+			union {
+				struct {		/* SLUB */
+					unsigned inuse:16;
+					unsigned objects:15;
+					unsigned frozen:1;
+				};
+				atomic_t _mapcount;	/* Count of ptes mapped in mms,
+							 * to show when page is mapped
+							 * & limit reverse map searches.
+							 */
+			};
+			atomic_t _count;		/* Usage count, see below. */
 		};
 	};
+
+	/* Third double word block */
+	struct list_head lru;		/* Pageout list, eg. active_list
+					 * protected by zone->lru_lock !
+					 */
+
+	/* Remainder is not double word aligned */
 	union {
-	    struct {
-		unsigned long private;		/* Mapping-private opaque data:
+	 	unsigned long private;		/* Mapping-private opaque data:
 					 	 * usually used for buffer_heads
 						 * if PagePrivate set; used for
 						 * swp_entry_t if PageSwapCache;
 						 * indicates order in the buddy
 						 * system if PG_buddy is set.
 						 */
-		struct address_space *mapping;	/* If low bit clear, points to
-						 * inode address_space, or NULL.
-						 * If page mapped as anonymous
-						 * memory, low bit is set, and
-						 * it points to anon_vma object:
-						 * see PAGE_MAPPING_ANON below.
-						 */
-	    };
 #if USE_SPLIT_PTLOCKS
-	    spinlock_t ptl;
+		spinlock_t ptl;
 #endif
-	    struct kmem_cache *slab;	/* SLUB: Pointer to slab */
-	    struct page *first_page;	/* Compound tail pages */
+		struct kmem_cache *slab;	/* SLUB: Pointer to slab */
+		struct page *first_page;	/* Compound tail pages */
 	};
-	union {
-		pgoff_t index;		/* Our offset within mapping. */
-		void *freelist;		/* SLUB: freelist req. slab lock */
-	};
-	struct list_head lru;		/* Pageout list, eg. active_list
-					 * protected by zone->lru_lock !
-					 */
+
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
 	 * we can simply calculate the virtual address. On machines with
@@ -101,7 +117,16 @@ struct page {
 	 */
 	void *shadow;
 #endif
-};
+}
+/*
+ * If another subsystem starts using the double word pairing for atomic
+ * operations on struct page then it must change the #if to ensure
+ * proper alignment of the page struct.
+ */
+#if defined(CONFIG_SLUB) && defined(CONFIG_CMPXCHG_LOCAL)
+	__attribute__((__aligned__(2*sizeof(unsigned long))))
+#endif
+;
 
 /*
  * A region containing a mapping of a non-memory backed file under NOMMU

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
