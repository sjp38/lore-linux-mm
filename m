From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070215012515.5343.28018.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 5/7] Consolidate new anonymous page code paths
Date: Wed, 14 Feb 2007 17:25:15 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Martin J. Bligh" <mbligh@mbligh.org>, Arjan van de Ven <arjan@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Nigel Cunningham <nigel@nigel.suspend2.net>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Consolidate code to add an anonymous page in memory.c

There are two location in which we add anonymous pages. Both
implement the same logic. Create a new function add_anon_page()
to have a common code path.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/mm/memory.c
===================================================================
--- linux-2.6.20.orig/mm/memory.c	2007-02-14 12:03:09.000000000 -0800
+++ linux-2.6.20/mm/memory.c	2007-02-14 12:03:12.000000000 -0800
@@ -900,6 +900,17 @@
 }
 
 /*
+ * Add a new anonymous page
+ */
+static void add_anon_page(struct vm_area_struct *vma, struct page *page,
+				unsigned long address)
+{
+	inc_mm_counter(vma->vm_mm, anon_rss);
+	lru_cache_add_active(page);
+	page_add_new_anon_rmap(page, vma, address);
+}
+
+/*
  * Do a quick page-table lookup for a single page.
  */
 struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
@@ -2148,9 +2159,7 @@
 		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table))
 			goto release;
-		inc_mm_counter(mm, anon_rss);
-		lru_cache_add_active(page);
-		page_add_new_anon_rmap(page, vma, address);
+		add_anon_page(vma, page, address);
 	} else {
 		/* Map the ZERO_PAGE - vm_page_prot is readonly */
 		page = ZERO_PAGE(address);
@@ -2294,11 +2303,9 @@
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
-		if (anon) {
-			inc_mm_counter(mm, anon_rss);
-			lru_cache_add_active(new_page);
-			page_add_new_anon_rmap(new_page, vma, address);
-		} else {
+		if (anon)
+			add_anon_page(vma, new_page, address);
+		else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(new_page);
 			if (write_access) {

----- End forwarded message -----

-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
