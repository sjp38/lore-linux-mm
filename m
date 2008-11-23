Date: Sun, 23 Nov 2008 21:56:04 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 2/8] mm: wp lock page before deciding cow
In-Reply-To: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
Message-ID: <Pine.LNX.4.64.0811232155180.4142@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

An application may rely on get_user_pages() to give it pages writable
from userspace and shared with a driver, GUP breaking COW if necessary.
It may mprotect() the pages' writability, off and on, from time to time.

Normally this works fine (so long as the app does not fork); but just
occasionally, under memory pressure, a readonly pte in a newly writable
area is COWed unnecessarily, breaking the link with the driver: because
do_wp_page() does trylock_page, and falls back to COW whenever that fails.

For reliable behaviour in the unshared case, when the trylock_page fails,
now unlock pagetable, lock page and relock pagetable, before deciding
whether Copy-On-Write is really necessary.

Reported-by: Zhou Yingchao
Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
This is not the patch I posted in June: in the end I decided it better just
to relock page as Nick suggested, than impose subtle ordering constraints
elsewhere; and also realized that page migration spoilt my optimizations.

 mm/memory.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

--- swapfree1/mm/memory.c	2008-11-21 18:50:41.000000000 +0000
+++ swapfree2/mm/memory.c	2008-11-21 18:50:43.000000000 +0000
@@ -1819,10 +1819,21 @@ static int do_wp_page(struct mm_struct *
 	 * not dirty accountable.
 	 */
 	if (PageAnon(old_page)) {
-		if (trylock_page(old_page)) {
-			reuse = can_share_swap_page(old_page);
-			unlock_page(old_page);
+		if (!trylock_page(old_page)) {
+			page_cache_get(old_page);
+			pte_unmap_unlock(page_table, ptl);
+			lock_page(old_page);
+			page_table = pte_offset_map_lock(mm, pmd, address,
+							 &ptl);
+			if (!pte_same(*page_table, orig_pte)) {
+				unlock_page(old_page);
+				page_cache_release(old_page);
+				goto unlock;
+			}
+			page_cache_release(old_page);
 		}
+		reuse = can_share_swap_page(old_page);
+		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
