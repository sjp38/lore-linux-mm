Date: Thu, 30 Nov 2006 17:56:03 +0000
Subject: [PATCH] make compound page destructor handling explicit
Message-ID: <d72f9ec8b9ba005fd9116037673cf461@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

make compound page destructor handling explicit

Currently we we use the lru head link of the second page of a
compound page to hold its destructor.  This was ok when it was purely
an internal implmentation detail.  However, hugetlbfs overrides this
destructor violating the layering.  Abstract this out as explicit
calls, also introduce a type for the callback function allowing them
to be type checked.  For each callback we pre-declare the function,
causing a type error on definition rather than on use elsewhere.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
diff --git a/include/linux/mm.h b/include/linux/mm.h
index cd0528d..667a72e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -298,6 +298,24 @@ void put_pages_list(struct list_head *pa
 void split_page(struct page *page, unsigned int order);
 
 /*
+ * Compound pages have a destructor function.  Provide a 
+ * prototype for that function and accessor functions.
+ * These are _only_ valid on the head of a PG_compound page.
+ */
+typedef void compound_page_dtor(struct page *);
+
+static inline void set_compound_page_dtor(struct page *page,
+						compound_page_dtor *dtor)
+{
+	page[1].lru.next = (void *)dtor;
+}
+
+static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
+{
+	return (compound_page_dtor *)page[1].lru.next;
+}
+
+/*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
  * zeroes, and text pages of executables and shared libraries have
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2911a36..2032fb2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -88,6 +88,8 @@ static struct page *dequeue_huge_page(st
 	return page;
 }
 
+/* declare the destructor to catch a missmatch on definition. */
+static compound_page_dtor free_huge_page;
 static void free_huge_page(struct page *page)
 {
 	BUG_ON(page_count(page));
@@ -109,7 +111,7 @@ static int alloc_fresh_huge_page(void)
 	if (nid == MAX_NUMNODES)
 		nid = first_node(node_online_map);
 	if (page) {
-		page[1].lru.next = (void *)free_huge_page;	/* dtor */
+		set_compound_page_dtor(page, free_huge_page);
 		spin_lock(&hugetlb_lock);
 		nr_huge_pages++;
 		nr_huge_pages_node[page_to_nid(page)]++;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7938e46..113d9bc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -240,6 +240,8 @@ static void bad_page(struct page *page)
  * This usage means that zero-order pages may not be compound.
  */
 
+/* declare the destructor to catch a missmatch on definition. */
+static compound_page_dtor free_compound_page;
 static void free_compound_page(struct page *page)
 {
 	__free_pages_ok(page, (unsigned long)page[1].lru.prev);
@@ -250,7 +252,7 @@ static void prep_compound_page(struct pa
 	int i;
 	int nr_pages = 1 << order;
 
-	page[1].lru.next = (void *)free_compound_page;	/* set dtor */
+	set_compound_page_dtor(page, free_compound_page);
 	page[1].lru.prev = (void *)order;
 	for (i = 0; i < nr_pages; i++) {
 		struct page *p = page + i;
diff --git a/mm/swap.c b/mm/swap.c
index 6cc9cb0..87456b2 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -58,9 +58,9 @@ static void put_compound_page(struct pag
 {
 	page = (struct page *)page_private(page);
 	if (put_page_testzero(page)) {
-		void (*dtor)(struct page *page);
+		compound_page_dtor *dtor;
 
-		dtor = (void (*)(struct page *))page[1].lru.next;
+		dtor = get_compound_page_dtor(page);
 		(*dtor)(page);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
