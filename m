Date: Fri, 15 Oct 2004 07:45:02 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] use find_trylock_page in free_swap_and_cache instead of hand coding
Message-ID: <20041015104502.GA1989@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org
Cc: hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi,

This small cleanup to free_swap_and_cache() substitues a 
"lock - radix lookup - TestSetPageLocked - unlock" sequence
of instructions with "find_trylock_page()" (which does 
exactly that).

Please apply

--- rc4-mm1.orig/mm/swapfile.c	2004-10-15 01:03:11.000000000 -0300
+++ rc4-mm1/mm/swapfile.c	2004-10-15 09:24:05.696640488 -0300
@@ -391,14 +391,8 @@ void free_swap_and_cache(swp_entry_t ent
 
 	p = swap_info_get(entry);
 	if (p) {
-		if (swap_entry_free(p, swp_offset(entry)) == 1) {
-			read_lock_irq(&swapper_space.tree_lock);
-			page = radix_tree_lookup(&swapper_space.page_tree,
-				entry.val);
-			if (page && TestSetPageLocked(page))
-				page = NULL;
-			read_unlock_irq(&swapper_space.tree_lock);
-		}
+		if (swap_entry_free(p, swp_offset(entry)) == 1) 
+			page = find_trylock_page(&swapper_space, entry.val);
 		swap_info_put(p);
 	}
 	if (page) {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
