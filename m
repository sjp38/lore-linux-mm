From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16407.59031.17836.961587@laputa.namesys.com>
Date: Wed, 28 Jan 2004 19:43:03 +0300
Subject: [PATCH] mm/vmscan.c:shrink_list(): check PageSwapCache() after add_to_swap()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

shrink_list() checks PageSwapCache() before calling add_to_swap(), this
means that anonymous page that is going to be added to the swap right
now these checks return false and:

 (*) it will be unaccounted for in nr_mapped, and

 (*) it won't be written to the swap if gfp_flags include __GFP_IO but
     not __GFP_FS.

(Both will happen only on the next round of scanning.)

Patch below just moves may_enter_fs initialization down. I am not sure
about (*nr_mapped) increase though.

Comments?

Nikita.
diff -puN -b mm/vmscan.c~check-PageSwapCache-after-add-to-swap mm/vmscan.c
--- i386/mm/vmscan.c~check-PageSwapCache-after-add-to-swap	Wed Jan 28 19:22:14 2004
+++ i386-nikita/mm/vmscan.c	Wed Jan 28 19:36:16 2004
@@ -380,8 +380,6 @@ shrink_list(struct list_head *page_list,
 			(*nr_mapped)++;
 
 		BUG_ON(PageActive(page));
-		may_enter_fs = (gfp_mask & __GFP_FS) ||
-				(PageSwapCache(page) && (gfp_mask & __GFP_IO));
 
 		if (PageWriteback(page))
 			goto keep_locked;
@@ -412,6 +410,9 @@ shrink_list(struct list_head *page_list,
 		}
 #endif /* CONFIG_SWAP */
 
+		may_enter_fs = (gfp_mask & __GFP_FS) ||
+				(PageSwapCache(page) && (gfp_mask & __GFP_IO));
+
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
