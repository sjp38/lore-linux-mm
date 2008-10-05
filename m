Date: Sun, 5 Oct 2008 03:25:28 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH next 1/3] slub defrag: unpin writeback pages
Message-ID: <Pine.LNX.4.64.0810050319001.22004@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

A repetitive swapping load on powerpc G5 went progressively slower after
nine hours: Inactive(file) was rising, as if inactive file pages pinned.
Yes, slub defrag's kick_buffers() was forgetting to put_page() whenever
it met a page already under writeback.

That PageWriteback test should be made while PageLocked in trigger_write(),
just as it is in try_to_free_buffers() - if there are complex reasons why
that's not actually necessary, I'd rather not have to think through them.
A preliminary check before taking the lock?  No, it's not that important.

And trigger_write() must remember to unlock_page() in each of the cases
where it doesn't reach the writepage().

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
Andrew, I mentioned at KS that I'd just completed a slow -mm bisection,
which had mysteriously converged on one of your patches: that was your
vm-dont-run-touch_buffer-during-buffercache-lookups.patch
In fact that turned out just to speed up the rate at which writebacks
were pinning these pages: I've nothing against (nor for!) your patch.

I'm wondering whether kick_buffers() ought to check PageLRU: I've no
evidence it's needed, but coming to writepage() or try_to_free_buffers()
from this direction (by virtue of having a buffer_head in a partial slab
page) is new, and I worry it might cause some ordering problem; whereas
if the page is PageLRU, then it is already fair game for such reclaim.

 fs/buffer.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

--- 2.6.27-rc7-mmotm/fs/buffer.c	2008-09-26 13:18:50.000000000 +0100
+++ linux/fs/buffer.c	2008-10-03 19:43:44.000000000 +0100
@@ -3354,13 +3354,16 @@ static void trigger_write(struct page *p
 		.for_reclaim = 0
 	};
 
+	if (PageWriteback(page))
+		goto unlock;
+
 	if (!mapping->a_ops->writepage)
 		/* No write method for the address space */
-		return;
+		goto unlock;
 
 	if (!clear_page_dirty_for_io(page))
 		/* Someone else already triggered a write */
-		return;
+		goto unlock;
 
 	rc = mapping->a_ops->writepage(page, &wbc);
 	if (rc < 0)
@@ -3368,7 +3371,7 @@ static void trigger_write(struct page *p
 		return;
 
 	if (rc == AOP_WRITEPAGE_ACTIVATE)
-		unlock_page(page);
+unlock:		unlock_page(page);
 }
 
 /*
@@ -3420,7 +3423,7 @@ static void kick_buffers(struct kmem_cac
 	for (i = 0; i < nr; i++) {
 		page = v[i];
 
-		if (!page || PageWriteback(page))
+		if (!page)
 			continue;
 
 		if (trylock_page(page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
