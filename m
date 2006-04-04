Date: Mon, 3 Apr 2006 22:33:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Page Migration: Make do_swap_page redo the fault
Message-ID: <Pine.LNX.4.64.0604032228150.24182@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It is better to redo the complete fault if do_swap_page() finds
that the page is not in PageSwapCache() because the page migration
code may have replaced the swap pte already with a pte pointing
to valid memory.

do_swap_page may interpret an invalid swap entry without this patch 
because we do not reload the pte if we are looping back. The page 
migration code may already have reused the swap entry referenced by our
local swp_entry.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc1/mm/memory.c
===================================================================
--- linux-2.6.17-rc1.orig/mm/memory.c	2006-04-02 20:22:10.000000000 -0700
+++ linux-2.6.17-rc1/mm/memory.c	2006-04-03 22:22:56.000000000 -0700
@@ -1879,7 +1879,6 @@ static int do_swap_page(struct mm_struct
 		goto out;
 
 	entry = pte_to_swp_entry(orig_pte);
-again:
 	page = lookup_swap_cache(entry);
 	if (!page) {
  		swapin_readahead(entry, address, vma);
@@ -1907,7 +1906,7 @@ again:
 		/* Page migration has occured */
 		unlock_page(page);
 		page_cache_release(page);
-		goto again;
+		goto out;
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
