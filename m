Date: Wed, 21 Feb 2007 14:12:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Take anonymous pages off the LRU if we have no swap
Message-ID: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If the kernel was compiled without support for swapping then we have no means
of evicting anonymous pages and they become like mlocked pages.

Do not add new anonymous pages to the LRU and if we find one on the LRU 
then take it off. This is also going to reduce the overhead of allocating 
anonymous pages since the LRU lock must no longer be taken to put pages 
onto the active list. Probably mostly of interest to embedded systems 
since normal kernels support swap.

On linux-mm we also discussed taking anonymous pages off the LRU if there 
is no swap defined or not enough swap. However, there is no easy way of 
putting the pages back to the LRU since we have no list of mlocked pages. 
We could set up such a list but then list manipulation would complicate 
the mlocked page treatment and require taking the lru lock. I'd rather 
leave the mlocked handling as simple as it is right now.

Anonymous pages will be accounted as mlocked pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-mm2/mm/memory.c
===================================================================
--- linux-2.6.20-mm2.orig/mm/memory.c	2007-02-21 13:53:15.000000000 -0800
+++ linux-2.6.20-mm2/mm/memory.c	2007-02-21 13:53:33.000000000 -0800
@@ -907,17 +907,26 @@
 				unsigned long address)
 {
 	inc_mm_counter(vma->vm_mm, anon_rss);
-	if (vma->vm_flags & VM_LOCKED) {
-		/*
-		 * Page is new and therefore not on the LRU
-		 * so we can directly mark it as mlocked
-		 */
-		SetPageMlocked(page);
-		ClearPageActive(page);
-		inc_zone_page_state(page, NR_MLOCK);
-	} else
-		lru_cache_add_active(page);
 	page_add_new_anon_rmap(page, vma, address);
+
+#ifdef CONFIG_SWAP
+	/*
+	 * It only makes sense to put anonymous pages on the
+	 * LRU if we have a way of evicting anonymous pages.
+	 */
+	if (!(vma->vm_flags & VM_LOCKED)) {
+		lru_cache_add_active(page);
+		return;
+	}
+#endif
+
+	/*
+	 * Page is new and therefore not on the LRU
+	 * so we can directly mark it as mlocked
+	 */
+	SetPageMlocked(page);
+	ClearPageActive(page);
+	inc_zone_page_state(page, NR_MLOCK);
 }
 
 /*
Index: linux-2.6.20-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.20-mm2.orig/mm/vmscan.c	2007-02-21 13:53:15.000000000 -0800
+++ linux-2.6.20-mm2/mm/vmscan.c	2007-02-21 13:53:33.000000000 -0800
@@ -495,14 +495,16 @@
 		if (referenced && page_mapping_inuse(page))
 			goto activate_locked;
 
-#ifdef CONFIG_SWAP
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
 		if (PageAnon(page) && !PageSwapCache(page))
+#ifdef CONFIG_SWAP
 			if (!add_to_swap(page, GFP_ATOMIC))
 				goto activate_locked;
+#else
+			goto mlocked;
 #endif /* CONFIG_SWAP */
 
 		mapping = page_mapping(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
