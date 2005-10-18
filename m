Date: Tue, 18 Oct 2005 09:38:24 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 1/2] Page migration via Swap V2: Page Eviction
In-Reply-To: <20051017180451.358f9dcc.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0510180937020.7911@schroedinger.engr.sgi.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
 <20051018004937.3191.42181.sendpatchset@schroedinger.engr.sgi.com>
 <20051017180451.358f9dcc.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, ak@suse.de, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, 17 Oct 2005, Andrew Morton wrote:

> This needs the (uncommented (grr)) smp_rmb() copied-and-pasted as well.
> 
> It's a shame about the copy-and-pasting :(   Is it unavoidable?

Well there is a way at least to extract a major section from it that 
includes the smb_rmb().

Index: linux-2.6.14-rc4-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.14-rc4-mm1.orig/mm/vmscan.c	2005-10-18 09:36:36.000000000 -0700
+++ linux-2.6.14-rc4-mm1/mm/vmscan.c	2005-10-18 09:36:42.000000000 -0700
@@ -370,6 +370,42 @@ static pageout_t pageout(struct page *pa
 	return PAGE_CLEAN;
 }
 
+static inline int remove_mapping(struct address_space *mapping,
+				struct page *page)
+{
+	if (!mapping)
+		return 0;		/* truncate got there first */
+
+	write_lock_irq(&mapping->tree_lock);
+
+	/*
+	 * The non-racy check for busy page.  It is critical to check
+	 * PageDirty _after_ making sure that the page is freeable and
+	 * not in use by anybody. 	(pagecache + us == 2)
+	 */
+	if (page_count(page) != 2 || PageDirty(page)) {
+		write_unlock_irq(&mapping->tree_lock);
+		return 0;
+	}
+
+#ifdef CONFIG_SWAP
+	if (PageSwapCache(page)) {
+		swp_entry_t swap = { .val = page->private };
+		add_to_swapped_list(swap.val);
+		__delete_from_swap_cache(page);
+		write_unlock_irq(&mapping->tree_lock);
+		swap_free(swap);
+		__put_page(page);	/* The pagecache ref */
+		return 1;
+	}
+#endif /* CONFIG_SWAP */
+
+	__remove_from_page_cache(page);
+	write_unlock_irq(&mapping->tree_lock);
+	__put_page(page);
+	return 1;
+}
+
 /*
  * shrink_list adds the number of reclaimed pages to sc->nr_reclaimed
  */
@@ -508,36 +544,8 @@ static int shrink_list(struct list_head 
 				goto free_it;
 		}
 
-		if (!mapping)
-			goto keep_locked;	/* truncate got there first */
-
-		write_lock_irq(&mapping->tree_lock);
-
-		/*
-		 * The non-racy check for busy page.  It is critical to check
-		 * PageDirty _after_ making sure that the page is freeable and
-		 * not in use by anybody. 	(pagecache + us == 2)
-		 */
-		if (page_count(page) != 2 || PageDirty(page)) {
-			write_unlock_irq(&mapping->tree_lock);
+		if (!remove_mapping(mapping, page))
 			goto keep_locked;
-		}
-
-#ifdef CONFIG_SWAP
-		if (PageSwapCache(page)) {
-			swp_entry_t swap = { .val = page->private };
-			add_to_swapped_list(swap.val);
-			__delete_from_swap_cache(page);
-			write_unlock_irq(&mapping->tree_lock);
-			swap_free(swap);
-			__put_page(page);	/* The pagecache ref */
-			goto free_it;
-		}
-#endif /* CONFIG_SWAP */
-
-		__remove_from_page_cache(page);
-		write_unlock_irq(&mapping->tree_lock);
-		__put_page(page);
 
 free_it:
 		unlock_page(page);
@@ -646,31 +654,9 @@ redo:
 				goto free_it;
 		}
 
-		if (!mapping)
+		if (!remove_mapping(mapping, page))
 			goto retry_later_locked;       /* truncate got there first */
 
-		write_lock_irq(&mapping->tree_lock);
-
-		if (page_count(page) != 2 || PageDirty(page)) {
-			write_unlock_irq(&mapping->tree_lock);
-			goto retry_later_locked;
-		}
-
-#ifdef CONFIG_SWAP
-		if (PageSwapCache(page)) {
-			swp_entry_t swap = { .val = page->private };
-			__delete_from_swap_cache(page);
-			write_unlock_irq(&mapping->tree_lock);
-			swap_free(swap);
-			__put_page(page);       /* The pagecache ref */
-			goto free_it;
-		}
-#endif /* CONFIG_SWAP */
-
-		__remove_from_page_cache(page);
-		write_unlock_irq(&mapping->tree_lock);
-		__put_page(page);
-
 free_it:
 		/*
 		 * We may free pages that were taken off the active list

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
