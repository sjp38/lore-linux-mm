From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070215012510.5343.52706.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 4/7] Logic to move mlocked pages
Date: Wed, 14 Feb 2007 17:25:10 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add logic to lazily remove/add mlocked pages from LRU

This is the core of the patchset. It adds the necessary logic to
remove mlocked pages from the LRU and put them back later. The basic idea
by Andrew Morton and others has been around for awhile.

During reclaim we attempt to unmap pages. In order to do so we have
to scan all vmas that a page belongs to to check for VM_LOCKED.

If we find that VM_LOCKED is set for a page then we remove the page from
the LRU and mark it with SetMlocked. We must mark the page with a special
flag bit. Without PageMLocked we have later no way to distinguish pages that
are off the LRU because of mlock from pages that are off the LRU for other
reasons. We should only feed back mlocked pages to the LRU and not the pages
that were removed for other reasons.

We feed pages back to the LRU in two places:

zap_pte_range: 	Here pages are removed from a vma. If a page is mlocked then
	we add it back to the LRU. If other vmas with VM_LOCKED set have
	mapped the page then we will discover that later during reclaim and
	move the page off the LRU again.

munlock/munlockall: We scan all pages in the vma and do the
	same as in zap_pte_range.

We also have to modify the page migration logic to handle PageMlocked
pages. We simply clear the PageMlocked bit and then we can treat
the page as a regular page from the LRU. Page migration feeds all
pages back the LRU and relies on reclaim to move them off again.

Note that this is lazy accounting for mlocked pages. NR_MLOCK may
increase as the system discovers more mlocked pages. If a machine has
a large amount of memory then it may take awhile until reclaim gets through
with all pages. We may only discover the extend of mlocked pages when
memory gets tight.

Some of the later patches opportunistically move pages off the LRU to avoid
delays in accounting. Usually these opportunistic moves do a pretty good job
but there are special situations (such as page migration and munlocking a
memory area mlocked by multiple processes) where NR_MLOCK may become low until
reclaim detects the mlocked pages again.

So, the scheme is fundamentally lazy and one cannot count on NR_MLOCK to
reflect the actual number of mlocked pages. NR_MLOCK represents the number
*discovered* mlocked pages so far which may be less than the actual number
of mlocked pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20/mm/memory.c
===================================================================
--- linux-2.6.20.orig/mm/memory.c	2007-02-14 17:07:44.000000000 -0800
+++ linux-2.6.20/mm/memory.c	2007-02-14 17:08:39.000000000 -0800
@@ -682,6 +682,8 @@
 				file_rss--;
 			}
 			page_remove_rmap(page, vma);
+			if (PageMlocked(page) && vma->vm_flags & VM_LOCKED)
+				lru_cache_add_mlock(page);
 			tlb_remove_page(tlb, page);
 			continue;
 		}
Index: linux-2.6.20/mm/migrate.c
===================================================================
--- linux-2.6.20.orig/mm/migrate.c	2007-02-14 17:07:44.000000000 -0800
+++ linux-2.6.20/mm/migrate.c	2007-02-14 17:08:54.000000000 -0800
@@ -58,6 +58,13 @@
 			else
 				del_page_from_inactive_list(zone, page);
 			list_add_tail(&page->lru, pagelist);
+		} else
+		if (PageMlocked(page)) {
+			ret = 0;
+			get_page(page);
+			ClearPageMlocked(page);
+			list_add_tail(&page->lru, pagelist);
+			__dec_zone_state(zone, NR_MLOCK);
 		}
 		spin_unlock_irq(&zone->lru_lock);
 	}
Index: linux-2.6.20/mm/mlock.c
===================================================================
--- linux-2.6.20.orig/mm/mlock.c	2007-02-14 17:07:44.000000000 -0800
+++ linux-2.6.20/mm/mlock.c	2007-02-14 17:08:39.000000000 -0800
@@ -10,7 +10,7 @@
 #include <linux/mm.h>
 #include <linux/mempolicy.h>
 #include <linux/syscalls.h>
-
+#include <linux/swap.h>
 
 static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	unsigned long start, unsigned long end, unsigned int newflags)
@@ -63,6 +63,23 @@
 		pages = -pages;
 		if (!(newflags & VM_IO))
 			ret = make_pages_present(start, end);
+	} else {
+		unsigned long addr;
+
+		/*
+		 * We are clearing VM_LOCKED. Feed all pages back
+		 * to the LRU via lru_cache_add_mlock()
+		 */
+		for (addr = start; addr < end; addr += PAGE_SIZE) {
+			struct page *page;
+
+			page = follow_page(vma, start, FOLL_GET);
+			if (page && PageMlocked(page)) {
+				lru_cache_add_mlock(page);
+				put_page(page);
+			}
+			cond_resched();
+		}
 	}
 
 	mm->locked_vm -= pages;
Index: linux-2.6.20/mm/vmscan.c
===================================================================
--- linux-2.6.20.orig/mm/vmscan.c	2007-02-14 17:07:44.000000000 -0800
+++ linux-2.6.20/mm/vmscan.c	2007-02-14 17:08:39.000000000 -0800
@@ -509,10 +509,11 @@
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
@@ -587,6 +588,13 @@
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
