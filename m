Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA05860
	for <linux-mm@kvack.org>; Fri, 31 Jan 2003 15:15:40 -0800 (PST)
Date: Fri, 31 Jan 2003 15:18:04 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030131151804.68b9c1ce.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

3/4



We currently have a problem when things like ptrace, futexes and direct-io
try to pin user pages.  If the user's address is in a huge page we're
elevting the refcount of a constituent 4k page, not the head page of the
high-order allocation unit.

To solve this, a generic way of handling higher-order pages has been
implemented:

- A higher-order page is called a "compound page".  Chose this because
  "huge page", "large page", "super page", etc all seem to mean different
  things to different people.

- The first (controlling) 4k page of a compound page is referred to as the
  "head" page.

- The remaining pages are tail pages.

All pages have PG_compound set.  All pages have their lru.next pointing at
the head page (even the head page has this).

The head page's lru.prev, if non-zero, holds the address of the compound
page's put_page() function.

The order of the allocation is stored in the first tail page's lru.prev.
This is only for debug at present.  This usage means that zero-order pages
may not be compound.

The above relationships are established for _all_ higher-order pages in the
page allocator.  Which has some cost, but not much - another atomic op during
fork(), mainly.

This functionality is only enabled if CONFIG_HUGETLB_PAGE, although it could
be turned on permanently.  There's a little extra cost in get_page/put_page.




 linux/mm.h         |   35 ++++++++++++++++++++++++++--
 linux/page-flags.h |    7 ++++-
 page_alloc.c       |   66 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 105 insertions(+), 3 deletions(-)

diff -puN include/linux/page-flags.h~compound-pages include/linux/page-flags.h
--- 25/include/linux/page-flags.h~compound-pages	2003-01-30 23:43:18.000000000 -0800
+++ 25-akpm/include/linux/page-flags.h	2003-01-30 23:43:18.000000000 -0800
@@ -72,7 +72,8 @@
 
 #define PG_direct		16	/* ->pte_chain points directly at pte */
 #define PG_mappedtodisk		17	/* Has blocks allocated on-disk */
-#define PG_reclaim		18	/* To be recalimed asap */
+#define PG_reclaim		18	/* To be reclaimed asap */
+#define PG_compound		19	/* Part of a compound page */
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -251,6 +252,10 @@ extern void get_full_page_state(struct p
 #define ClearPageReclaim(page)	clear_bit(PG_reclaim, &(page)->flags)
 #define TestClearPageReclaim(page) test_and_clear_bit(PG_reclaim, &(page)->flags)
 
+#define PageCompound(page)	test_bit(PG_compound, &(page)->flags)
+#define SetPageCompound(page)	set_bit(PG_compound, &(page)->flags)
+#define ClearPageCompound(page)	clear_bit(PG_compound, &(page)->flags)
+
 /*
  * The PageSwapCache predicate doesn't use a PG_flag at this time,
  * but it may again do so one day.
diff -puN mm/page_alloc.c~compound-pages mm/page_alloc.c
--- 25/mm/page_alloc.c~compound-pages	2003-01-30 23:43:18.000000000 -0800
+++ 25-akpm/mm/page_alloc.c	2003-01-31 01:47:02.000000000 -0800
@@ -85,6 +85,62 @@ static void bad_page(const char *functio
 	page->mapping = NULL;
 }
 
+#ifndef CONFIG_HUGETLB_PAGE
+#define prep_compound_page(page, order) do { } while (0)
+#define destroy_compound_page(page, order) do { } while (0)
+#else
+/*
+ * Higher-order pages are called "compound pages".  They are structured thusly:
+ *
+ * The first PAGE_SIZE page is called the "head page".
+ *
+ * The remaining PAGE_SIZE pages are called "tail pages".
+ *
+ * All pages have PG_compound set.  All pages have their lru.next pointing at
+ * the head page (even the head page has this).
+ *
+ * The head page's lru.prev, if non-zero, holds the address of the compound
+ * page's put_page() function.
+ *
+ * The order of the allocation is stored in the first tail page's lru.prev.
+ * This is only for debug at present.  This usage means that zero-order pages
+ * may not be compound.
+ */
+static void prep_compound_page(struct page *page, int order)
+{
+	int i;
+	int nr_pages = 1 << order;
+
+	page->lru.prev = NULL;
+	page[1].lru.prev = (void *)order;
+	for (i = 0; i < nr_pages; i++) {
+		struct page *p = page + i;
+
+		SetPageCompound(p);
+		p->lru.next = (void *)page;
+	}
+}
+
+static void destroy_compound_page(struct page *page, int order)
+{
+	int i;
+	int nr_pages = 1 << order;
+
+	if (page[1].lru.prev != (void *)order)
+		bad_page(__FUNCTION__, page);
+
+	for (i = 0; i < nr_pages; i++) {
+		struct page *p = page + i;
+
+		if (!PageCompound(p))
+			bad_page(__FUNCTION__, page);
+		if (p->lru.next != (void *)page)
+			bad_page(__FUNCTION__, page);
+		ClearPageCompound(p);
+	}
+}
+#endif		/* CONFIG_HUGETLB_PAGE */
+
 /*
  * Freeing function for a buddy system allocator.
  *
@@ -114,6 +170,8 @@ static inline void __free_pages_bulk (st
 {
 	unsigned long page_idx, index;
 
+	if (order)
+		destroy_compound_page(page, order);
 	page_idx = page - base;
 	if (page_idx & ~mask)
 		BUG();
@@ -409,6 +467,12 @@ void free_cold_page(struct page *page)
 	free_hot_cold_page(page, 1);
 }
 
+/*
+ * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
+ * we cheat by calling it from here, in the order > 0 path.  Saves a branch
+ * or two.
+ */
+
 static struct page *buffered_rmqueue(struct zone *zone, int order, int cold)
 {
 	unsigned long flags;
@@ -435,6 +499,8 @@ static struct page *buffered_rmqueue(str
 		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order);
 		spin_unlock_irqrestore(&zone->lock, flags);
+		if (order && page)
+			prep_compound_page(page, order);
 	}
 
 	if (page != NULL) {
diff -puN include/linux/mm.h~compound-pages include/linux/mm.h
--- 25/include/linux/mm.h~compound-pages	2003-01-30 23:43:18.000000000 -0800
+++ 25-akpm/include/linux/mm.h	2003-01-30 23:43:18.000000000 -0800
@@ -208,24 +208,55 @@ struct page {
  * Also, many kernel routines increase the page count before a critical
  * routine so they can be sure the page doesn't go away from under them.
  */
-#define get_page(p)		atomic_inc(&(p)->count)
-#define __put_page(p)		atomic_dec(&(p)->count)
 #define put_page_testzero(p)				\
 	({						\
 		BUG_ON(page_count(page) == 0);		\
 		atomic_dec_and_test(&(p)->count);	\
 	})
+
 #define page_count(p)		atomic_read(&(p)->count)
 #define set_page_count(p,v) 	atomic_set(&(p)->count, v)
+#define __put_page(p)		atomic_dec(&(p)->count)
 
 extern void FASTCALL(__page_cache_release(struct page *));
 
+#ifdef CONFIG_HUGETLB_PAGE
+
+static inline void get_page(struct page *page)
+{
+	if (PageCompound(page))
+		page = (struct page *)page->lru.next;
+	atomic_inc(&page->count);
+}
+
 static inline void put_page(struct page *page)
 {
+	if (PageCompound(page)) {
+		page = (struct page *)page->lru.next;
+		if (page->lru.prev) {	/* destructor? */
+			(*(void (*)(struct page *))page->lru.prev)(page);
+			return;
+		}
+	}
 	if (!PageReserved(page) && put_page_testzero(page))
 		__page_cache_release(page);
 }
 
+#else		/* CONFIG_HUGETLB_PAGE */
+
+static inline void get_page(struct page *page)
+{
+	atomic_inc(&page->count);
+}
+
+static inline void put_page(struct page *page)
+{
+	if (!PageReserved(page) && put_page_testzero(page))
+		__page_cache_release(page);
+}
+
+#endif		/* CONFIG_HUGETLB_PAGE */
+
 /*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
