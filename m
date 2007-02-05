Date: Mon, 5 Feb 2007 12:52:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070205205240.4500.86694.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070205205235.4500.54958.sendpatchset@schroedinger.engr.sgi.com>
References: <20070205205235.4500.54958.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 1/7] Make try_to_unmap return a special exit code
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Martin J. Bligh" <mbligh@mbligh.org>, Arjan van de Ven <arjan@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Nigel Cunningham <nigel@nigel.suspend2.net>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[PATCH] Make try_to_unmap() return SWAP_MLOCK for mlocked pages

Modify try_to_unmap() so that we can distinguish failing to
unmap due to a mlocked page from other causes.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: current/include/linux/rmap.h
===================================================================
--- current.orig/include/linux/rmap.h	2007-02-03 10:24:47.000000000 -0800
+++ current/include/linux/rmap.h	2007-02-03 10:25:08.000000000 -0800
@@ -134,5 +134,6 @@ static inline int page_mkclean(struct pa
 #define SWAP_SUCCESS	0
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
+#define SWAP_MLOCK	3
 
 #endif	/* _LINUX_RMAP_H */
Index: current/mm/rmap.c
===================================================================
--- current.orig/mm/rmap.c	2007-02-03 10:24:47.000000000 -0800
+++ current/mm/rmap.c	2007-02-03 10:25:08.000000000 -0800
@@ -631,10 +631,16 @@ static int try_to_unmap_one(struct page 
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young(vma, address, pte)))) {
-		ret = SWAP_FAIL;
-		goto out_unmap;
+	if (!migration) {
+		if (vma->vm_flags & VM_LOCKED) {
+			ret = SWAP_MLOCK;
+			goto out_unmap;
+		}
+
+		if (ptep_clear_flush_young(vma, address, pte)) {
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
 	}
 
 	/* Nuke the page table entry. */
@@ -799,7 +805,8 @@ static int try_to_unmap_anon(struct page
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
 		ret = try_to_unmap_one(page, vma, migration);
-		if (ret == SWAP_FAIL || !page_mapped(page))
+		if (ret == SWAP_FAIL || ret == SWAP_MLOCK ||
+				!page_mapped(page))
 			break;
 	}
 	spin_unlock(&anon_vma->lock);
@@ -830,7 +837,8 @@ static int try_to_unmap_file(struct page
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		ret = try_to_unmap_one(page, vma, migration);
-		if (ret == SWAP_FAIL || !page_mapped(page))
+		if (ret == SWAP_FAIL || ret == SWAP_MLOCK ||
+				!page_mapped(page))
 			goto out;
 	}
 
@@ -913,6 +921,7 @@ out:
  * SWAP_SUCCESS	- we succeeded in removing all mappings
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
+ * SWAP_MLOCK	- the page is under mlock()
  */
 int try_to_unmap(struct page *page, int migration)
 {
Index: current/mm/vmscan.c
===================================================================
--- current.orig/mm/vmscan.c	2007-02-03 10:25:00.000000000 -0800
+++ current/mm/vmscan.c	2007-02-03 10:25:12.000000000 -0800
@@ -516,6 +516,7 @@ static unsigned long shrink_page_list(st
 		if (page_mapped(page) && mapping) {
 			switch (try_to_unmap(page, 0)) {
 			case SWAP_FAIL:
+			case SWAP_MLOCK:
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
