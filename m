Subject: PATCH: Cleanup of the page_cache (take 2)
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 15 May 2000 03:14:12 +0200
Message-ID: <ytt66sg1uor.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus
   here is a patch with some lacking substitutions of __free_page for
   page_cache_release.

Later, Juan.


diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude work/mm/highmem.c testing/mm/highmem.c
--- work/mm/highmem.c	Fri May 12 23:46:46 2000
+++ testing/mm/highmem.c	Mon May 15 02:59:52 2000
@@ -60,7 +60,7 @@
 	 * ok, we can just forget about our highmem page since 
 	 * we stored its data into the new regular_page.
 	 */
-	__free_page(page);
+	page_cache_release(page);
 	new_page = mem_map + MAP_NR(regular_page);
 	LockPage(new_page);
 	return new_page;
@@ -78,7 +78,7 @@
 	if (!highpage)
 		return page;
 	if (!PageHighMem(highpage)) {
-		__free_page(highpage);
+		page_cache_release(highpage);
 		return page;
 	}
 
@@ -94,7 +94,7 @@
 	 * We can just forget the old page since 
 	 * we stored its data into the new highmem-page.
 	 */
-	__free_page(page);
+	page_cache_release(page);
 
 	return highpage;
 }
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude work/mm/memory.c testing/mm/memory.c
--- work/mm/memory.c	Fri May 12 23:46:46 2000
+++ testing/mm/memory.c	Mon May 15 03:00:36 2000
@@ -878,7 +878,7 @@
 		new_page = old_page;
 	}
 	spin_unlock(&mm->page_table_lock);
-	__free_page(new_page);
+	page_cache_release(new_page);
 	return 1;	/* Minor fault */
 
 bad_wp_page:
@@ -1022,7 +1022,7 @@
 		/* Ok, do the async read-ahead now */
 		new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset), 0);
 		if (new_page != NULL)
-			__free_page(new_page);
+			page_cache_release(new_page);
 		swap_free(SWP_ENTRY(SWP_TYPE(entry), offset));
 	}
 	return;
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude work/mm/swapfile.c testing/mm/swapfile.c
--- work/mm/swapfile.c	Fri May 12 23:46:46 2000
+++ testing/mm/swapfile.c	Mon May 15 03:00:58 2000
@@ -377,7 +377,7 @@
                    page we've been using. */
 		if (PageSwapCache(page))
 			delete_from_swap_cache(page);
-		__free_page(page);
+		page_cache_release(page);
 		/*
 		 * Check for and clear any overflowed swap map counts.
 		 */
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude work/mm/vmscan.c testing/mm/vmscan.c
--- work/mm/vmscan.c	Sun May 14 22:28:43 2000
+++ testing/mm/vmscan.c	Mon May 15 03:03:19 2000
@@ -79,7 +79,7 @@
 		mm->swap_cnt--;
 		vma->vm_mm->rss--;
 		flush_tlb_page(vma, address);
-		__free_page(page);
+		page_cache_release(page);
 		goto out_failed;
 	}
 
@@ -151,7 +151,7 @@
 		if (file) fput(file);
 		if (!error)
 			goto out_free_success;
-		__free_page(page);
+		page_cache_release(page);
 		return error;
 	}
 
@@ -184,7 +184,7 @@
 	rw_swap_page(WRITE, page, 0);
 
 out_free_success:
-	__free_page(page);
+	page_cache_release(page);
 	return 1;
 out_swap_free:
 	swap_free(entry);


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
