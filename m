Date: Sun, 23 Nov 2008 22:07:31 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 8/8] mm: add add_to_swap stub
In-Reply-To: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
Message-ID: <Pine.LNX.4.64.0811232205180.4142@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If we add a failing stub for add_to_swap(),
then we can remove the #ifdef CONFIG_SWAP from mm/vmscan.c.

This was intended as a source cleanup, but looking more closely, it turns
out that the !CONFIG_SWAP case was going to keep_locked for an anonymous
page, whereas now it goes to the more suitable activate_locked, like the
CONFIG_SWAP nr_swap_pages 0 case.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
Shouldn't PageSwapBacked pages be made PageUnevictable
when CONFIG_UNEVICTABLE_LRU but !CONFIG_SWAP?

 include/linux/swap.h |    5 +++++
 mm/vmscan.c          |    2 --
 2 files changed, 5 insertions(+), 2 deletions(-)

--- swapfree7/include/linux/swap.h	2008-11-21 18:51:05.000000000 +0000
+++ swapfree8/include/linux/swap.h	2008-11-21 18:51:08.000000000 +0000
@@ -374,6 +374,11 @@ static inline struct page *lookup_swap_c
 	return NULL;
 }
 
+static inline int add_to_swap(struct page *page)
+{
+	return 0;
+}
+
 static inline int add_to_swap_cache(struct page *page, swp_entry_t entry,
 							gfp_t gfp_mask)
 {
--- swapfree7/mm/vmscan.c	2008-11-21 18:51:05.000000000 +0000
+++ swapfree8/mm/vmscan.c	2008-11-21 18:51:08.000000000 +0000
@@ -665,7 +665,6 @@ static unsigned long shrink_page_list(st
 					referenced && page_mapping_inuse(page))
 			goto activate_locked;
 
-#ifdef CONFIG_SWAP
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
@@ -677,7 +676,6 @@ static unsigned long shrink_page_list(st
 				goto activate_locked;
 			may_enter_fs = 1;
 		}
-#endif /* CONFIG_SWAP */
 
 		mapping = page_mapping(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
