Date: Thu, 15 Feb 2007 13:05:47 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] Remove unswappable anonymous pages off the LRU
Message-ID: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

If we do not have any swap or we have run out of swap then anonymous pages
can no longer be removed from memory. In that case we simply treat them
like mlocked pages. For a kernel compiled CONFIG_SWAP off this means
that all anonymous pages are marked mlocked when they are allocated.

If there is no swap available then anonymous pages will be removed when we 
attempt to reclaim and find that there is no swap space available.

I think it is best to account unreclaimable anonymous pages under NR_MLOCK 
because mlock is a way of treating pages that is defined by POSIX. It is 
clear then that these pages are not reclaimed. NONLRU would not 
communicate clearly what is happening to the pages and it would also 
include mlocked pages. The possible confusion that may arise here is that 
pages are mlocked without an mlock() syscall but I think that the sudden 
increase in NR_MLOCK will help people to reconsider what they are doing if 
they switch off swap.

Pages may also be marked as mlocked() if we are running out of swap.

One unresolved issue is how to get anonymous pages back to an unmlocked
state if more swap is added to the system. Pages are checked for the mlocked
state whenever a process terminates. However, anonymous pages of processes
that do not terminate may stay mlocked. The only way to get rid of
those would be to scan all mlocked pages on the system since we have
no list of mlocked pages. That may be too expensive. Maybe the best
is to leave the pages mlocked?

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-git11/include/linux/swap.h
===================================================================
--- linux-2.6.20-git11.orig/include/linux/swap.h	2007-02-15 11:03:27.000000000 -0800
+++ linux-2.6.20-git11/include/linux/swap.h	2007-02-15 11:04:27.000000000 -0800
@@ -362,6 +362,11 @@ static inline swp_entry_t get_swap_page(
 	return entry;
 }
 
+static inline int add_to_swap(struct page *page, gfp_t flags)
+{
+	return -ENOSPC;
+}
+
 /* linux/mm/thrash.c */
 #define put_swap_token(x) do { } while(0)
 #define grab_swap_token()  do { } while(0)
Index: linux-2.6.20-git11/mm/memory.c
===================================================================
--- linux-2.6.20-git11.orig/mm/memory.c	2007-02-15 10:56:49.000000000 -0800
+++ linux-2.6.20-git11/mm/memory.c	2007-02-15 11:09:30.000000000 -0800
@@ -683,7 +683,7 @@ static unsigned long zap_pte_range(struc
 				file_rss--;
 			}
 			page_remove_rmap(page, vma);
-			if (PageMlocked(page) && vma->vm_flags & VM_LOCKED)
+			if (PageMlocked(page))
 				lru_cache_add_mlock(page);
 			tlb_remove_page(tlb, page);
 			continue;
@@ -907,17 +907,27 @@ static void add_anon_page(struct vm_area
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
+	 * If there is no swap then there is no
+	 * point in adding an anon page to the LRU
+	 * because we can never reclaim the page.
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
Index: linux-2.6.20-git11/mm/swap_state.c
===================================================================
--- linux-2.6.20-git11.orig/mm/swap_state.c	2007-02-15 10:57:47.000000000 -0800
+++ linux-2.6.20-git11/mm/swap_state.c	2007-02-15 10:59:52.000000000 -0800
@@ -153,7 +153,7 @@ int add_to_swap(struct page * page, gfp_
 	for (;;) {
 		entry = get_swap_page();
 		if (!entry.val)
-			return 0;
+			return -ENOSPC;
 
 		/*
 		 * Radix-tree node allocations from PF_MEMALLOC contexts could
@@ -174,7 +174,7 @@ int add_to_swap(struct page * page, gfp_
 			SetPageUptodate(page);
 			SetPageDirty(page);
 			INC_CACHE_INFO(add_total);
-			return 1;
+			return 0;
 		case -EEXIST:
 			/* Raced with "speculative" read_swap_cache_async */
 			INC_CACHE_INFO(exist_race);
@@ -183,7 +183,7 @@ int add_to_swap(struct page * page, gfp_
 		default:
 			/* -ENOMEM radix-tree allocation failure */
 			swap_free(entry);
-			return 0;
+			return -ENOMEM;
 		}
 	}
 }
Index: linux-2.6.20-git11/mm/vmscan.c
===================================================================
--- linux-2.6.20-git11.orig/mm/vmscan.c	2007-02-15 10:59:57.000000000 -0800
+++ linux-2.6.20-git11/mm/vmscan.c	2007-02-15 11:07:57.000000000 -0800
@@ -488,15 +488,24 @@ static unsigned long shrink_page_list(st
 		if (referenced && page_mapping_inuse(page))
 			goto activate_locked;
 
-#ifdef CONFIG_SWAP
-		/*
-		 * Anonymous process memory has backing store?
-		 * Try to allocate it some swap space here.
-		 */
-		if (PageAnon(page) && !PageSwapCache(page))
-			if (!add_to_swap(page, GFP_ATOMIC))
+		if (PageAnon(page) && !PageSwapCache(page)) {
+			/*
+			 * Anonymous process memory has backing store?
+			 * Try to allocate it some swap space here.
+			 */
+			int rc = add_to_swap(page, GFP_ATOMIC);
+
+			if (rc == -ENOMEM)
 				goto activate_locked;
-#endif /* CONFIG_SWAP */
+
+			/*
+			 *  If we are unable to allocate a swap
+			 *  page then the anonymous page can never
+			 *  be reclaimed. In effect it is mlocked.
+			 */
+			if (rc == -ENOSPC)
+				goto mlocked;
+		}
 
 		mapping = page_mapping(page);
 		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
