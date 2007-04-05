Date: Wed, 4 Apr 2007 21:34:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Free up page->private for compound pages
In-Reply-To: <20070405042502.GI11192@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0704042132170.14005@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704042016490.7885@schroedinger.engr.sgi.com>
 <20070405033648.GG11192@wotan.suse.de> <Pine.LNX.4.64.0704042037550.8745@schroedinger.engr.sgi.com>
 <20070405035741.GH11192@wotan.suse.de> <Pine.LNX.4.64.0704042102570.12297@schroedinger.engr.sgi.com>
 <20070405042502.GI11192@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2007, Nick Piggin wrote:

> Yeah, good suggestion.

Fixed up patch:

[RFC] Free up page->private for compound pages V2

V1->V2
	- Use alias to PG_reclaim

If we add a new flag so that we can distinguish between the
first page and the tail pages then we can avoid to use page->private
in the first page. page->private == page for the first page, so there
is no real information in there.

Freeing up page->private makes the use of compound pages more transparent.
They become more usable like real pages. Right now we have to be careful f.e.
if we are going beyond PAGE_SIZE allocations in the slab on i386 because we
can then no longer use the private field. This is one of the issues that
cause us not to support debugging for page size slabs in SLAB.

Having page->private available for SLUB would allow more meta information
in the page struct. I can probably avoid the 16 bit ints that I have in
there right now.

Also if page->private is available then a compound page may be equipped
with buffer heads. This may free up the way for filesystems to support
larger blocks than page size.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc5-mm4/include/linux/mm.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/linux/mm.h	2007-04-03 23:48:34.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/linux/mm.h	2007-04-04 18:18:33.000000000 -0700
@@ -297,17 +297,21 @@ static inline int get_page_unless_zero(s
 	return atomic_inc_not_zero(&page->_count);
 }
 
+static inline struct page *compound_head(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		return page->first_page;
+	return page;
+}
+
 static inline int page_count(struct page *page)
 {
-	if (unlikely(PageCompound(page)))
-		page = (struct page *)page_private(page);
-	return atomic_read(&page->_count);
+	return atomic_read(&compound_head(page)->_count);
 }
 
 static inline void get_page(struct page *page)
 {
-	if (unlikely(PageCompound(page)))
-		page = (struct page *)page_private(page);
+	page = compound_head(page);
 	VM_BUG_ON(atomic_read(&page->_count) == 0);
 	atomic_inc(&page->_count);
 }
@@ -344,6 +348,18 @@ static inline compound_page_dtor *get_co
 	return (compound_page_dtor *)page[1].lru.next;
 }
 
+static inline int compound_order(struct page *page)
+{
+	if (!PageCompound(page) || PageTail(page))
+		return 0;
+	return (unsigned long)page[1].lru.prev;
+}
+
+static inline void set_compound_order(struct page *page, unsigned long order)
+{
+	page[1].lru.prev = (void *)order;
+}
+
 /*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
Index: linux-2.6.21-rc5-mm4/include/linux/page-flags.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/linux/page-flags.h	2007-04-03 23:48:34.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/linux/page-flags.h	2007-04-04 21:31:54.000000000 -0700
@@ -95,6 +95,12 @@
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
 
+/*
+ * Marks tail portion of a compound page. We currently do not reclaim
+ * compound pages so we can reuse a flag only used for reclaim here.
+ */
+#define PG_tail			PG_reclaim
+
 #if (BITS_PER_LONG > 32)
 /*
  * 64-bit-only flags build down from bit 31
@@ -214,6 +220,10 @@ static inline void SetPageUptodate(struc
 #define __SetPageCompound(page)	__set_bit(PG_compound, &(page)->flags)
 #define __ClearPageCompound(page) __clear_bit(PG_compound, &(page)->flags)
 
+#define PageTail(page)	test_bit(PG_tail, &(page)->flags)
+#define __SetPageTail(page)	__set_bit(PG_tail, &(page)->flags)
+#define __ClearPageTail(page)	__clear_bit(PG_tail, &(page)->flags)
+
 #ifdef CONFIG_SWAP
 #define PageSwapCache(page)	test_bit(PG_swapcache, &(page)->flags)
 #define SetPageSwapCache(page)	set_bit(PG_swapcache, &(page)->flags)
Index: linux-2.6.21-rc5-mm4/mm/internal.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/mm/internal.h	2007-03-25 15:56:23.000000000 -0700
+++ linux-2.6.21-rc5-mm4/mm/internal.h	2007-04-04 17:56:08.000000000 -0700
@@ -24,7 +24,7 @@ static inline void set_page_count(struct
  */
 static inline void set_page_refcounted(struct page *page)
 {
-	VM_BUG_ON(PageCompound(page) && page_private(page) != (unsigned long)page);
+	VM_BUG_ON(PageTail(page));
 	VM_BUG_ON(atomic_read(&page->_count));
 	set_page_count(page, 1);
 }
Index: linux-2.6.21-rc5-mm4/mm/page_alloc.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/mm/page_alloc.c	2007-04-03 23:48:34.000000000 -0700
+++ linux-2.6.21-rc5-mm4/mm/page_alloc.c	2007-04-04 18:25:21.000000000 -0700
@@ -290,7 +290,7 @@ static void bad_page(struct page *page)
 
 static void free_compound_page(struct page *page)
 {
-	__free_pages_ok(page, (unsigned long)page[1].lru.prev);
+	__free_pages_ok(page, compound_order(page));
 }
 
 static void prep_compound_page(struct page *page, unsigned long order)
@@ -299,10 +299,12 @@ static void prep_compound_page(struct pa
 	int nr_pages = 1 << order;
 
 	set_compound_page_dtor(page, free_compound_page);
-	page[1].lru.prev = (void *)order;
-	for (i = 0; i < nr_pages; i++) {
+	__SetPageCompound(page);
+	set_compound_order(page, order);
+	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
 
+		__SetPageTail(p);
 		__SetPageCompound(p);
 		set_page_private(p, (unsigned long)page);
 	}
@@ -313,15 +315,19 @@ static void destroy_compound_page(struct
 	int i;
 	int nr_pages = 1 << order;
 
-	if (unlikely((unsigned long)page[1].lru.prev != order))
+	if (unlikely(compound_order(page) != order))
 		bad_page(page);
 
-	for (i = 0; i < nr_pages; i++) {
+	if (unlikely(!PageCompound(page)))
+			bad_page(page);
+	__ClearPageCompound(page);
+	for (i = 1; i < nr_pages; i++) {
 		struct page *p = page + i;
 
-		if (unlikely(!PageCompound(p) |
+		if (unlikely(!PageTail(p) | !PageCompound(p) |
 				(page_private(p) != (unsigned long)page)))
 			bad_page(page);
+		__ClearPageTail(p);
 		__ClearPageCompound(p);
 	}
 }
Index: linux-2.6.21-rc5-mm4/mm/slab.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/mm/slab.c	2007-04-03 23:48:34.000000000 -0700
+++ linux-2.6.21-rc5-mm4/mm/slab.c	2007-04-04 18:05:52.000000000 -0700
@@ -602,8 +602,7 @@ static inline void page_set_cache(struct
 
 static inline struct kmem_cache *page_get_cache(struct page *page)
 {
-	if (unlikely(PageCompound(page)))
-		page = (struct page *)page_private(page);
+	page = compound_head(page);
 	BUG_ON(!PageSlab(page));
 	return (struct kmem_cache *)page->lru.next;
 }
@@ -615,8 +614,7 @@ static inline void page_set_slab(struct 
 
 static inline struct slab *page_get_slab(struct page *page)
 {
-	if (unlikely(PageCompound(page)))
-		page = (struct page *)page_private(page);
+	page = compound_head(page);
 	BUG_ON(!PageSlab(page));
 	return (struct slab *)page->lru.prev;
 }
Index: linux-2.6.21-rc5-mm4/mm/slub.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/mm/slub.c	2007-04-04 17:59:30.000000000 -0700
+++ linux-2.6.21-rc5-mm4/mm/slub.c	2007-04-04 21:27:04.000000000 -0700
@@ -1273,9 +1273,7 @@ void kmem_cache_free(struct kmem_cache *
 
 	page = virt_to_page(x);
 
-	if (unlikely(PageCompound(page)))
-		page = page->first_page;
-
+	page = compound_head(page);
 
 	if (unlikely(PageError(page) && (s->flags & SLAB_STORE_USER)))
 		set_tracking(s, x, 1);
@@ -1286,10 +1284,7 @@ EXPORT_SYMBOL(kmem_cache_free);
 /* Figure out on which slab object the object resides */
 static struct page *get_object_page(const void *x)
 {
-	struct page *page = virt_to_page(x);
-
-	if (unlikely(PageCompound(page)))
-		page = page->first_page;
+	struct page *page = compound_head(virt_to_page(x));
 
 	if (!PageSlab(page))
 		return NULL;
@@ -1896,10 +1891,7 @@ void kfree(const void *x)
 	if (!x)
 		return;
 
-	page = virt_to_page(x);
-
-	if (unlikely(PageCompound(page)))
-		page = page->first_page;
+	page = compound_head(virt_to_page(x));
 
 	s = page->slab;
 
@@ -1935,10 +1927,7 @@ void *krealloc(const void *p, size_t new
 		return NULL;
 	}
 
-	page = virt_to_page(p);
-
-	if (unlikely(PageCompound(page)))
-		page = page->first_page;
+	page = compound_head(virt_to_page(p));
 
 	new_cache = get_slab(new_size, flags);
 
Index: linux-2.6.21-rc5-mm4/mm/swap.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/mm/swap.c	2007-04-04 18:01:08.000000000 -0700
+++ linux-2.6.21-rc5-mm4/mm/swap.c	2007-04-04 18:01:40.000000000 -0700
@@ -56,7 +56,7 @@ static void fastcall __page_cache_releas
 
 static void put_compound_page(struct page *page)
 {
-	page = (struct page *)page_private(page);
+	page = compound_head(page);
 	if (put_page_testzero(page)) {
 		compound_page_dtor *dtor;
 
Index: linux-2.6.21-rc5-mm4/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/ia64/mm/init.c	2007-04-04 18:09:44.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/ia64/mm/init.c	2007-04-04 18:15:48.000000000 -0700
@@ -121,7 +121,7 @@ lazy_mmu_prot_update (pte_t pte)
 		return;				/* i-cache is already coherent with d-cache */
 
 	if (PageCompound(page)) {
-		order = (unsigned long) (page[1].lru.prev);
+		order = compound_order(page);
 		flush_icache_range(addr, addr + (1UL << order << PAGE_SHIFT));
 	}
 	else
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
