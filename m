Date: Mon, 18 Aug 2008 14:28:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: page lock use lock bitops
Message-ID: <20080818122818.GC9062@wotan.suse.de>
References: <20080818122428.GA9062@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080818122428.GA9062@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

mm: use lock bitops for page lock

trylock_page, unlock_page open and close a critical section. Hence,
we can use the lock bitops to get the desired memory ordering.

Also, mark trylock as likely to succeed (and remove the annotation from
callers).

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 include/linux/pagemap.h |    2 +-
 mm/filemap.c            |   13 +++++--------
 mm/swapfile.c           |    2 +-
 3 files changed, 7 insertions(+), 10 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -557,17 +557,14 @@ EXPORT_SYMBOL(wait_on_page_bit);
  * mechananism between PageLocked pages and PageWriteback pages is shared.
  * But that's OK - sleepers in wait_on_page_writeback() just go back to sleep.
  *
- * The first mb is necessary to safely close the critical section opened by the
- * test_and_set_bit() to lock the page; the second mb is necessary to enforce
- * ordering between the clear_bit and the read of the waitqueue (to avoid SMP
- * races with a parallel wait_on_page_locked()).
+ * The mb is necessary to enforce ordering between the clear_bit and the read
+ * of the waitqueue (to avoid SMP races with a parallel wait_on_page_locked()).
  */
 void unlock_page(struct page *page)
 {
-	smp_mb__before_clear_bit();
-	if (!test_and_clear_bit(PG_locked, &page->flags))
-		BUG();
-	smp_mb__after_clear_bit(); 
+	VM_BUG_ON(!PageLocked(page));
+	clear_bit_unlock(PG_locked, &page->flags);
+	smp_mb__after_clear_bit();
 	wake_up_page(page, PG_locked);
 }
 EXPORT_SYMBOL(unlock_page);
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -283,7 +283,7 @@ static inline void __clear_page_locked(s
 
 static inline int trylock_page(struct page *page)
 {
-	return !test_and_set_bit(PG_locked, &page->flags);
+	return (likely(!test_and_set_bit_lock(PG_locked, &page->flags)));
 }
 
 /*
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -403,7 +403,7 @@ void free_swap_and_cache(swp_entry_t ent
 	if (p) {
 		if (swap_entry_free(p, swp_offset(entry)) == 1) {
 			page = find_get_page(&swapper_space, entry.val);
-			if (page && unlikely(!trylock_page(page))) {
+			if (page && !trylock_page(page)) {
 				page_cache_release(page);
 				page = NULL;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
