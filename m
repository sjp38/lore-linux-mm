Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id C54E238CF2
	for <linux-mm@kvack.org>; Mon, 24 Sep 2001 17:39:51 -0300 (EST)
Date: Mon, 24 Sep 2001 17:39:47 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] minor page aging update
In-Reply-To: <Pine.LNX.4.33L.0109241734490.1864-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33L.0109241738510.1864-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Sep 2001, Rik van Riel wrote:

> here is the promised minor page aging update to 2.4.9-ac15:

*sigh*

Well, _here_ it is ;)

(and also at http://www.surriel.com/patches/2.4/2.4.9-ac15-aging)

cheers,

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/


--- linux-2.4.9-ac15/mm/vmscan.c.orig	Mon Sep 24 17:30:48 2001
+++ linux-2.4.9-ac15/mm/vmscan.c	Mon Sep 24 17:31:40 2001
@@ -28,19 +28,12 @@

 static inline void age_page_up(struct page *page)
 {
-	unsigned long age = page->age;
-	age += PAGE_AGE_ADV;
-	if (age > PAGE_AGE_MAX)
-		age = PAGE_AGE_MAX;
-	page->age = age;
+	page->age = min((int) (page->age + PAGE_AGE_ADV), PAGE_AGE_MAX);
 }

 static inline void age_page_down(struct page *page)
 {
-	unsigned long age = page->age;
-	if (age > 0)
-		age -= PAGE_AGE_DECL;
-	page->age = age;
+	page->age -= min(PAGE_AGE_DECL, (int)page->age);
 }

 /*
@@ -108,6 +101,23 @@
 	pte_t pte;
 	swp_entry_t entry;

+	/* Don't look at this pte if it's been accessed recently. */
+	if (ptep_test_and_clear_young(page_table)) {
+		age_page_up(page);
+		return;
+	}
+
+	/*
+	 * If the page is on the active list, page aging is done in
+	 * refill_inactive_scan(), anonymous pages are aged here.
+	 * This is done so heavily shared pages (think libc.so)
+	 * don't get punished heavily while they are still in use.
+	 * The alternative would be to put anonymous pages on the
+	 * active list too, but that increases complexity (for now).
+	 */
+	if (!PageActive(page))
+		age_page_down(page);
+
 	/*
 	 * If we have plenty inactive pages on this
 	 * zone, skip it.
@@ -133,23 +143,6 @@
 	pte = ptep_get_and_clear(page_table);
 	flush_tlb_page(vma, address);

-	/* Don't look at this pte if it's been accessed recently. */
-	if (ptep_test_and_clear_young(page_table)) {
-		age_page_up(page);
-		return;
-	}
-
-	/*
-	 * If the page is on the active list, page aging is done in
-	 * refill_inactive_scan(), anonymous pages are aged here.
-	 * This is done so heavily shared pages (think libc.so)
-	 * don't get punished heavily while they are still in use.
-	 * The alternative would be to put anonymous pages on the
-	 * active list too, but that increases complexity (for now).
-	 */
-	if (!PageActive(page))
-		age_page_down(page);
-
 	/*
 	 * Is the page already in the swap cache? If so, then
 	 * we can just drop our reference to it without doing
@@ -998,27 +991,26 @@
 	return progress;
 }

-
-
+/*
+ * Worker function for kswapd and try_to_free_pages, we get
+ * called whenever there is a shortage of free/inactive_clean
+ * pages.
+ *
+ * This function will also move pages to the inactive list,
+ * if needed.
+ */
 static int do_try_to_free_pages(unsigned int gfp_mask, int user)
 {
 	int ret = 0;

 	/*
-	 * If we're low on free pages, move pages from the
-	 * inactive_dirty list to the inactive_clean list.
-	 *
-	 * Usually bdflush will have pre-cleaned the pages
-	 * before we get around to moving them to the other
-	 * list, so this is a relatively cheap operation.
+	 * Eat memory from filesystem page cache, buffer cache,
+	 * dentry, inode and filesystem quota caches.
 	 */
-
-	if (free_shortage()) {
-		ret += page_launder(gfp_mask, user);
-		shrink_dcache_memory(0, gfp_mask);
-		shrink_icache_memory(0, gfp_mask);
-		shrink_dqcache_memory(DEF_PRIORITY, gfp_mask);
-	}
+	ret += page_launder(gfp_mask, user);
+	shrink_dcache_memory(0, gfp_mask);
+	shrink_icache_memory(0, gfp_mask);
+	shrink_dqcache_memory(DEF_PRIORITY, gfp_mask);

 	/*
 	 * If needed, we move pages from the active list
@@ -1028,7 +1020,7 @@
 		ret += refill_inactive(gfp_mask);

 	/*
-	 * Reclaim unused slab cache if memory is low.
+	 * Reclaim unused slab cache memory.
 	 */
 	kmem_cache_reap(gfp_mask);

@@ -1080,7 +1072,7 @@
 		static long recalc = 0;

 		/* If needed, try to free some memory. */
-		if (inactive_shortage() || free_shortage())
+		if (free_shortage())
 			do_try_to_free_pages(GFP_KSWAPD, 0);

 		/* Once a second ... */
@@ -1090,8 +1082,6 @@
 			/* Do background page aging. */
 			refill_inactive_scan(DEF_PRIORITY);
 		}
-
-		run_task_queue(&tq_disk);

 		/*
 		 * We go to sleep if either the free page shortage

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
