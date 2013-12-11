Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 202716B003B
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:40:43 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so10855756pbc.39
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:40:42 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id d2si14722965pba.301.2013.12.11.14.40.39
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:40:40 -0800 (PST)
Subject: [RFC][PATCH 2/3] mm: slab: move around slab ->freelist for cmpxchg
From: Dave Hansen <dave@sr71.net>
Date: Wed, 11 Dec 2013 14:40:25 -0800
References: <20131211224022.AA8CF0B9@viggo.jf.intel.com>
In-Reply-To: <20131211224022.AA8CF0B9@viggo.jf.intel.com>
Message-Id: <20131211224025.70B40B9C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cl@gentwo.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@sr71.net>


The write-argument to cmpxchg_double() must be 16-byte aligned.
We used to align 'struct page' itself in order to guarantee this,
but that wastes 8-bytes per page.  Instead, we take 8-bytes
internal to the page before page->counters and move freelist
between there and the existing 8-bytes after counters.  That way,
no matter how 'stuct page' itself is aligned, we can ensure that
we have a 16-byte area with which to to this cmpxchg.



---

 linux.git-davehans/include/linux/mm_types.h |   17 +++++--
 linux.git-davehans/mm/slab.c                |    2 
 linux.git-davehans/mm/slab.h                |    1 
 linux.git-davehans/mm/slob.c                |    2 
 linux.git-davehans/mm/slub.c                |   67 +++++++++++++++++++++++-----
 5 files changed, 74 insertions(+), 15 deletions(-)

diff -puN include/linux/mm_types.h~move-around-freelist-to-align include/linux/mm_types.h
--- linux.git/include/linux/mm_types.h~move-around-freelist-to-align	2013-12-11 13:19:54.334963497 -0800
+++ linux.git-davehans/include/linux/mm_types.h	2013-12-11 13:19:54.344963939 -0800
@@ -140,11 +140,20 @@ struct slab_page {
 	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
-	void *s_mem;			/* slab first object */
+	union {
+		void *s_mem;			/* slab first object */
+		/*
+		 * The combination of ->counters and ->freelist
+		 * need to be doubleword-aligned in order for
+		 * slub's cmpxchg_double() to work properly.
+		 * slub does not use 's_mem', so we reuse it here
+		 * so we can always have alignment no matter how
+		 * struct page is aligned.
+		 */
+		void *_freelist_first;		/* sl[aou]b first free object */
+	};
 
 	/* Second double word */
-	void *_freelist;		/* sl[aou]b first free object */
-
 	union {
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
 	defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
@@ -173,6 +182,8 @@ struct slab_page {
 		unsigned int active;	/* SLAB */
 	};
 
+	void *_freelist_second;		/* sl[aou]b first free object */
+
 	/* Third double word block */
 	union {
 		struct {		/* slub per cpu partial pages */
diff -puN mm/slab.c~move-around-freelist-to-align mm/slab.c
--- linux.git/mm/slab.c~move-around-freelist-to-align	2013-12-11 13:19:54.335963541 -0800
+++ linux.git-davehans/mm/slab.c	2013-12-11 13:19:54.345963983 -0800
@@ -1952,7 +1952,7 @@ static void slab_destroy_debugcheck(stru
 
 static inline unsigned int **slab_freelist_ptr(struct slab_page *page)
 {
-	return (unsigned int **)&page->_freelist;
+	return (unsigned int **)&page->_freelist_first;
 }
 
 static inline unsigned int *slab_freelist(struct slab_page *page)
diff -puN mm/slab.h~move-around-freelist-to-align mm/slab.h
--- linux.git/mm/slab.h~move-around-freelist-to-align	2013-12-11 13:19:54.337963630 -0800
+++ linux.git-davehans/mm/slab.h	2013-12-11 13:19:54.346964027 -0800
@@ -278,3 +278,4 @@ struct kmem_cache_node {
 
 void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
+
diff -puN mm/slob.c~move-around-freelist-to-align mm/slob.c
--- linux.git/mm/slob.c~move-around-freelist-to-align	2013-12-11 13:19:54.339963718 -0800
+++ linux.git-davehans/mm/slob.c	2013-12-11 13:19:54.346964027 -0800
@@ -213,7 +213,7 @@ static void slob_free_pages(void *b, int
 
 static inline void **slab_freelist_ptr(struct slab_page *sp)
 {
-	return &sp->_freelist;
+	return &sp->_freelist_first;
 }
 
 static inline void *slab_freelist(struct slab_page *sp)
diff -puN mm/slub.c~move-around-freelist-to-align mm/slub.c
--- linux.git/mm/slub.c~move-around-freelist-to-align	2013-12-11 13:19:54.340963762 -0800
+++ linux.git-davehans/mm/slub.c	2013-12-11 13:19:54.348964116 -0800
@@ -228,9 +228,23 @@ static inline void stat(const struct kme
 #endif
 }
 
-static inline void **slab_freelist_ptr(struct slab_page *spage)
+static inline bool ptr_doubleword_aligned(void *ptr)
 {
-	return &spage->_freelist;
+	int doubleword_bytes = BITS_PER_LONG * 2 / 8;
+	if (PTR_ALIGN(ptr, doubleword_bytes) == ptr)
+		return 1;
+	return 0;
+}
+
+void **slab_freelist_ptr(struct slab_page *spage)
+{
+	/*
+	 * If counters is aligned, then we use the ->freelist
+	 * slot _after_ it.
+	 */
+	if (ptr_doubleword_aligned(&spage->counters))
+		return &spage->_freelist_second;
+	return &spage->_freelist_first;
 }
 
 static inline void *slab_freelist(struct slab_page *spage)
@@ -380,6 +394,39 @@ static __always_inline void slab_unlock(
 	__bit_spin_unlock(PG_locked, &page->flags);
 }
 
+/*
+ * Take two adjecent 8b-aligned, but non-doubleword-aligned
+ * arguments and swap them around to guarantee that the
+ * first arg is doubleword-aligned.
+ *
+ * The write-argument to cmpxchg_double() must be 16-byte
+ * aligned.  We used to align 'struct page' itself in order
+ * to guarantee this, but that wastes 8-bytes per page.
+ * Instead, we take 8-bytes internal to the page before
+ * page->counters and move freelist between there and the
+ * existing 8-bytes after counters.  That way, no matter
+ * how 'stuct page' itself is aligned, we can ensure that
+ * we have a 16-byte area with which to to this cmpxchg.
+ */
+static inline bool __cmpxchg_double_slab_unaligned(struct slab_page *page,
+		void *freelist_old, unsigned long counters_old,
+		void *freelist_new, unsigned long counters_new)
+{
+	void **freelist = slab_freelist_ptr(page);
+	if (ptr_doubleword_aligned(&page->counters)) {
+		if (cmpxchg_double(&page->counters, freelist,
+			counters_old, freelist_old,
+			counters_new, freelist_new))
+			return 1;
+	} else {
+		if (cmpxchg_double(freelist, &page->counters,
+			freelist_old, counters_old,
+			freelist_new, counters_new))
+			return 1;
+	}
+	return 0;
+}
+
 /* Interrupts must be disabled (for the fallback code to work right) */
 static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct slab_page *page,
 		void *freelist_old, unsigned long counters_old,
@@ -390,10 +437,10 @@ static inline bool __cmpxchg_double_slab
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(slab_freelist_ptr(page), &page->counters,
-			freelist_old, counters_old,
-			freelist_new, counters_new))
-		return 1;
+		if (__cmpxchg_double_slab_unaligned(page,
+				freelist_old, counters_old,
+				freelist_new, counters_new))
+			return 1;
 	} else
 #endif
 	{
@@ -426,10 +473,10 @@ static inline bool cmpxchg_double_slab(s
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(slab_freelist_ptr(page), &page->counters,
-			freelist_old, counters_old,
-			freelist_new, counters_new))
-		return 1;
+		if (__cmpxchg_double_slab_unaligned(page,
+				freelist_old, counters_old,
+				freelist_new, counters_new))
+			return 1;
 	} else
 #endif
 	{
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
