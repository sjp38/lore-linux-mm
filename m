Received: from dbl.localdomain (localhost [127.0.0.1])
	by colorfullife.com (8.11.2/8.11.2) with ESMTP id f4RCWFq31696
	for <linux-mm@kvack.org>; Sun, 27 May 2001 08:32:20 -0400
Received: from colorfullife.com (IDENT:manfred@clmsdev.localdomain [172.17.4.1])
	by dbl.localdomain (8.11.2/8.11.2) with ESMTP id f4RCU9V30911
	for <linux-mm@kvack.org>; Sun, 27 May 2001 14:30:14 +0200
Message-ID: <3B10F351.6DDEC59@colorfullife.com>
Date: Sun, 27 May 2001 14:30:09 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: [PATCH] modified memory_pressure calculation
Content-Type: multipart/mixed;
 boundary="------------62A183E9CBFC3FB17E103D1F"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------62A183E9CBFC3FB17E103D1F
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

I think the current memory_pressure calculation is broken - at least
memory_pressure does not contain the number of pages necessary in the
inactive_clean_list to handle 1 second of allocations.

* if reclaim_page() finds a page that is Referenced, Dirty or Locked
then it must increase memory_pressure.
* I don't understand the purpose of the second ++ in alloc_pages().

What about the attached patch [vs. 2.4.5]? It's just an idea, untested.

If the behaviour is worse then we must figure out what memory_pressure
actually is under the various workloads. AFAICS it has nothing to do
with the number of memory allocations per second.

Please cc me, I'm not subscribed to linux-mm.

--
	Manfred
--------------62A183E9CBFC3FB17E103D1F
Content-Type: text/plain; charset=us-ascii;
 name="patch-memory_pressure"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-memory_pressure"

diff -u 2.4/mm/page_alloc.c build-2.4/mm/page_alloc.c
--- 2.4/mm/page_alloc.c	Sat May 26 10:06:29 2001
+++ build-2.4/mm/page_alloc.c	Sun May 27 14:18:35 2001
@@ -141,8 +141,11 @@
 	 * since it's nothing important, but we do want to make sure
 	 * it never gets negative.
 	 */
-	if (memory_pressure > NR_CPUS)
-		memory_pressure--;
+	{
+		int mp = memory_pressure-(1<<order);
+		if (mp > 0)
+			memory_pressure = mp;
+	}
 }
 
 #define MARK_USED(index, order, area) \
@@ -282,7 +285,7 @@
 	/*
 	 * Allocations put pressure on the VM subsystem.
 	 */
-	memory_pressure++;
+	memory_pressure += (1<<order);
 
 	/*
 	 * (If anyone calls gfp from interrupts nonatomically then it
@@ -437,7 +440,6 @@
 		 * 	  the inactive clean list. (done by page_launder)
 		 */
 		if (gfp_mask & __GFP_WAIT) {
-			memory_pressure++;
 			try_to_free_pages(gfp_mask);
 			goto try_again;
 		}
@@ -476,7 +478,7 @@
 
 		/* XXX: is pages_min/4 a good amount to reserve for this? */
 		if (z->free_pages < z->pages_min / 4 &&
-				!(current->flags & PF_MEMALLOC))
+			(in_interrupt() || !(current->flags & PF_MEMALLOC)))
 			continue;
 		page = rmqueue(z, order);
 		if (page)
diff -u 2.4/mm/swap.c build-2.4/mm/swap.c
--- 2.4/mm/swap.c	Mon Jan 22 22:30:21 2001
+++ build-2.4/mm/swap.c	Sun May 27 14:24:29 2001
@@ -46,8 +46,19 @@
  * is doing, averaged over a minute. We use this to determine how
  * many inactive pages we should have.
  *
- * In reclaim_page and __alloc_pages: memory_pressure++
+ * In __alloc_pages: memory_pressure++
+ * 	each allocation uses memory
  * In __free_pages_ok: memory_pressure--
+ * kreclaimd: memory_pressure++ before __free_pages_ok
+ * 	A memory free from outside of the {in,}active_list
+ * 	reduces the necessary number of freeable pages in the
+ * 	inactive_clean_list.
+ * in reclaim_pages: memory_pressure++ for each unfreeable page found
+ *	 	in the inactive_clean_list.
+ *	 Pages in the inactive_clean_list can be reused by the current
+ *	 owner. This "increases" the memory pressure since more pages
+ *	 must be in the inactive_clean_list to have a certain number of
+ *	 freeable pages in the inactive_clean_list.
  * In recalculate_vm_stats the value is decayed (once a second)
  */
 int memory_pressure;
diff -u 2.4/mm/vmscan.c build-2.4/mm/vmscan.c
--- 2.4/mm/vmscan.c	Sat May 26 10:06:29 2001
+++ build-2.4/mm/vmscan.c	Sun May 27 14:27:23 2001
@@ -355,6 +355,7 @@
 			printk("VM: reclaim_page, wrong page on list.\n");
 			list_del(page_lru);
 			page->zone->inactive_clean_pages--;
+			memory_pressure++;
 			continue;
 		}
 
@@ -363,6 +364,7 @@
 				(!page->buffers && page_count(page) > 1)) {
 			del_page_from_inactive_clean_list(page);
 			add_page_to_active_list(page);
+			memory_pressure++;
 			continue;
 		}
 
@@ -370,6 +372,7 @@
 		if (page->buffers || PageDirty(page) || TryLockPage(page)) {
 			del_page_from_inactive_clean_list(page);
 			add_page_to_inactive_dirty_list(page);
+			memory_pressure++;
 			continue;
 		}
 
@@ -389,6 +392,7 @@
 		list_del(page_lru);
 		zone->inactive_clean_pages--;
 		UnlockPage(page);
+		memory_pressure++;
 	}
 	/* Reset page pointer, maybe we encountered an unfreeable page. */
 	page = NULL;
@@ -404,7 +408,6 @@
 out:
 	spin_unlock(&pagemap_lru_lock);
 	spin_unlock(&pagecache_lock);
-	memory_pressure++;
 	return page;
 }
 
@@ -1046,6 +1049,14 @@
 					page = reclaim_page(zone);
 					if (!page)
 						break;
+					/* We move pages from the inactive_clean_list
+					 * into the buddy. This doesn't cause any change
+					 * in the actual memory pressure.
+					 * The 'memory_pressure++' is 
+					 * required to undo the 'memory_pressure--'
+					 * in __free_pages_ok.
+					 */
+					memory_pressure++;
 					__free_page(page);
 				}
 			}

--------------62A183E9CBFC3FB17E103D1F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
