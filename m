Message-Id: <20070814153502.000534629@sgi.com>
References: <20070814153021.446917377@sgi.com>
Date: Tue, 14 Aug 2007 08:30:26 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 5/9] Save irqflags on taking the mapping lock
Content-Disposition: inline; filename=vmscan_mapping_irqsave
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

---
 mm/vmscan.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-14 07:34:55.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-14 08:21:58.000000000 -0700
@@ -381,10 +381,12 @@ static pageout_t pageout(struct page *pa
  */
 int remove_mapping(struct address_space *mapping, struct page *page)
 {
+	unsigned long flags;
+
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
-	write_lock_irq(&mapping->tree_lock);
+	write_lock_irqsave(&mapping->tree_lock, flags);
 	/*
 	 * The non racy check for a busy page.
 	 *
@@ -419,19 +421,19 @@ int remove_mapping(struct address_space 
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
 		__delete_from_swap_cache(page);
-		write_unlock_irq(&mapping->tree_lock);
+		write_unlock_irqrestore(&mapping->tree_lock, flags);
 		swap_free(swap);
 		__put_page(page);	/* The pagecache ref */
 		return 1;
 	}
 
 	__remove_from_page_cache(page);
-	write_unlock_irq(&mapping->tree_lock);
+	write_unlock_irqrestore(&mapping->tree_lock, flags);
 	__put_page(page);
 	return 1;
 
 cannot_free:
-	write_unlock_irq(&mapping->tree_lock);
+	write_unlock_irqrestore(&mapping->tree_lock, flags);
 	return 0;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
