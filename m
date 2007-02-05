Date: Mon, 5 Feb 2007 12:52:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070205205256.4500.22851.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070205205235.4500.54958.sendpatchset@schroedinger.engr.sgi.com>
References: <20070205205235.4500.54958.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 4/7] Logic to move mlocked pages
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add logic to lazily remove/add mlocked pages from LRU

This is the core of the patchset. It adds the necessary logic to
remove mlocked pages from the LRU and put them back later. Basic idea
by Andrew Morton and others.

During reclaim we attempt to unmap pages. In order to do so we have
to scan all vmas that a page belongs to to check if VM_LOCKED is set.

If we find that this is the case for a page then we remove the page from
the LRU and mark it with SetMlocked so that we know that we need to put
the page back to the LRU later should the mlocked state be cleared.

We put the pages back in two places:

zap_pte_range: 	Pages are removed from a vma. If a page is mlocked then we
	add it back to the LRU. If other vmas with VM_LOCKED set have mapped
	the page then we will discover that later during reclaim and move
	the page off the LRU again.

munlock/munlockall: We scan all pages in the vma and do the
	same as in zap_pte_range.

We also have to modify the page migration logic to handle PageMlocked
pages. We simply clear the PageMlocked bit and then we can treat
the page as a regular page from the LRU.

Note that this is a lazy accounting for mlocked pages. NR_MLOCK may
increase as the system discovers more mlocked pages. Some of the later
patches opportunistically move pages off the LRU earlier avoiding
some of the delayed accounting. However, the scheme is fundamentally
lazy and one cannot count on NR_MLOCK to reflect the actual number of
mlocked pages. It is the number of so far *discovered* mlocked pages
which may be less than the actual number of mlocked pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: current/mm/memory.c
===================================================================
--- current.orig/mm/memory.c	2007-02-05 11:38:35.000000000 -0800
+++ current/mm/memory.c	2007-02-05 11:57:28.000000000 -0800
@@ -682,6 +682,8 @@ static unsigned long zap_pte_range(struc
 				file_rss--;
 			}
 			page_remove_rmap(page, vma);
+			if (PageMlocked(page) && vma->vm_flags & VM_LOCKED)
+				lru_cache_add_mlock(page);
 			tlb_remove_page(tlb, page);
 			continue;
 		}
Index: current/mm/migrate.c
===================================================================
--- current.orig/mm/migrate.c	2007-02-05 11:30:47.000000000 -0800
+++ current/mm/migrate.c	2007-02-05 11:47:23.000000000 -0800
@@ -58,6 +58,11 @@ int isolate_lru_page(struct page *page, 
 			else
 				del_page_from_inactive_list(zone, page);
 			list_add_tail(&page->lru, pagelist);
+		} else
+		if (PageMlocked(page)) {
+			get_page(page);
+			ClearPageMlocked(page);
+			list_add_tail(&page->lru, pagelist);
 		}
 		spin_unlock_irq(&zone->lru_lock);
 	}
Index: current/mm/mlock.c
===================================================================
--- current.orig/mm/mlock.c	2007-02-05 11:30:47.000000000 -0800
+++ current/mm/mlock.c	2007-02-05 11:47:23.000000000 -0800
@@ -10,7 +10,7 @@
 #include <linux/mm.h>
 #include <linux/mempolicy.h>
 #include <linux/syscalls.h>
-
+#include <linux/swap.h>
 
 static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	unsigned long start, unsigned long end, unsigned int newflags)
@@ -63,6 +63,24 @@ success:
 		pages = -pages;
 		if (!(newflags & VM_IO))
 			ret = make_pages_present(start, end);
+	} else {
+		unsigned long addr;
+
+		/*
+		 * We are clearing VM_LOCKED. Feed all pages back via
+		 * to the LRU via lru_cache_add_mlock()
+		 */
+		for (addr = start; addr < end; addr += PAGE_SIZE) {
+			/*
+			 * No need to get a page reference. mmap_sem
+			 * writelock is held.
+			 */
+			struct page *page = follow_page(vma, start, 0);
+
+			if (PageMlocked(page))
+				lru_cache_add_mlock(page);
+			cond_resched();
+		}
 	}
 
 	mm->locked_vm -= pages;
Index: current/mm/vmscan.c
===================================================================
--- current.orig/mm/vmscan.c	2007-02-05 11:30:47.000000000 -0800
+++ current/mm/vmscan.c	2007-02-05 11:57:40.000000000 -0800
@@ -516,10 +516,11 @@ static unsigned long shrink_page_list(st
 		if (page_mapped(page) && mapping) {
 			switch (try_to_unmap(page, 0)) {
 			case SWAP_FAIL:
-			case SWAP_MLOCK:
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
+			case SWAP_MLOCK:
+				goto mlocked;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -594,6 +595,13 @@ free_it:
 			__pagevec_release_nonlru(&freed_pvec);
 		continue;
 
+mlocked:
+		ClearPageActive(page);
+		unlock_page(page);
+		__inc_zone_page_state(page, NR_MLOCK);
+		SetPageMlocked(page);
+		continue;
+
 activate_locked:
 		SetPageActive(page);
 		pgactivate++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
