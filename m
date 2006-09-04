Date: Mon, 4 Sep 2006 10:06:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Hugepages: Use page_to_nid rather than traversing zone pointers
Message-ID: <Pine.LNX.4.64.0609041000270.29018@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I found two location in hugetlb.c where we chase pointer instead of
using page_to_nid(). Page_to_nid is more effective and can get the node
directly from page flags.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc5-mm1/mm/hugetlb.c
===================================================================
--- linux-2.6.18-rc5-mm1.orig/mm/hugetlb.c	2006-09-03 20:42:28.000000000 -0700
+++ linux-2.6.18-rc5-mm1/mm/hugetlb.c	2006-09-03 20:48:39.000000000 -0700
@@ -177,7 +177,7 @@
 {
 	int i;
 	nr_huge_pages--;
-	nr_huge_pages_node[page_zone(page)->zone_pgdat->node_id]--;
+	nr_huge_pages_node[page_to_nid(page)]--;
 	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
 				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
@@ -191,7 +191,8 @@
 #ifdef CONFIG_HIGHMEM
 static void try_to_free_low(unsigned long count)
 {
-	int i, nid;
+	int i;
+
 	for (i = 0; i < MAX_NUMNODES; ++i) {
 		struct page *page, *next;
 		list_for_each_entry_safe(page, next, &hugepage_freelists[i], lru) {
@@ -199,9 +200,8 @@
 				continue;
 			list_del(&page->lru);
 			update_and_free_page(page);
-			nid = page_zone(page)->zone_pgdat->node_id;
 			free_huge_pages--;
-			free_huge_pages_node[nid]--;
+			free_huge_pages_node[page_to_nid(page)]--;
 			if (count >= nr_huge_pages)
 				return;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
