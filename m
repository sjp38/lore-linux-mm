From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070215012525.5343.71985.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 7/7] Opportunistically move mlocked pages off the LRU
Date: Wed, 14 Feb 2007 17:25:26 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Martin J. Bligh" <mbligh@mbligh.org>, Arjan van de Ven <arjan@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Nigel Cunningham <nigel@nigel.suspend2.net>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Opportunistically move mlocked pages off the LRU

Add a new function try_to_mlock() that attempts to
move a page off the LRU and marks it mlocked.

This function can then be used in various code paths to move
pages off the LRU immediately. Early discovery will make NR_MLOCK
track the actual number of mlocked pages in the system more closely.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/mm/memory.c
===================================================================
--- linux-2.6.20.orig/mm/memory.c	2007-02-14 13:10:09.000000000 -0800
+++ linux-2.6.20/mm/memory.c	2007-02-14 13:13:29.000000000 -0800
@@ -59,6 +59,7 @@
 
 #include <linux/swapops.h>
 #include <linux/elf.h>
+#include <linux/mm_inline.h>
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
@@ -920,6 +921,34 @@
 }
 
 /*
+ * Opportunistically move the page off the LRU
+ * if possible. If we do not succeed then the LRU
+ * scans will take the page off.
+ */
+static void try_to_set_mlocked(struct page *page)
+{
+	struct zone *zone;
+	unsigned long flags;
+
+	if (!PageLRU(page) || PageMlocked(page))
+		return;
+
+	zone = page_zone(page);
+	if (spin_trylock_irqsave(&zone->lru_lock, flags)) {
+		if (PageLRU(page) && !PageMlocked(page)) {
+			ClearPageLRU(page);
+			if (PageActive(page))
+				del_page_from_active_list(zone, page);
+			else
+				del_page_from_inactive_list(zone, page);
+			ClearPageActive(page);
+			SetPageMlocked(page);
+			__inc_zone_page_state(page, NR_MLOCK);
+		}
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	}
+}
+/*
  * Do a quick page-table lookup for a single page.
  */
 struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
@@ -979,6 +1008,8 @@
 			set_page_dirty(page);
 		mark_page_accessed(page);
 	}
+	if (vma->vm_flags & VM_LOCKED)
+		try_to_set_mlocked(page);
 unlock:
 	pte_unmap_unlock(ptep, ptl);
 out:
@@ -2317,6 +2348,8 @@
 		else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(new_page);
+			if (vma->vm_flags & VM_LOCKED)
+				try_to_set_mlocked(new_page);
 			if (write_access) {
 				dirty_page = new_page;
 				get_page(dirty_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
