Message-Id: <20070814143303.187548996@sgi.com>
References: <20070814142103.204771292@sgi.com>
Date: Tue, 14 Aug 2007 07:21:05 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 2/3] Use NOMEMALLOC reclaim to allow reclaim if PF_MEMALLOC is set
Content-Disposition: inline; filename=reclaim_nomemalloc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

If we exhaust the reserves in the page allocator when PF_MEMALLOC is set
then no longer give up but call into reclaim with PF_MEMALLOC set.

This is in essence a recursive call back into page reclaim with another
page flag (__GFP_NOMEMALLOC) set. The recursion is bounded since potential
allocations with __PF_NOMEMALLOC set will not enter that branch again.

This means that allocation under PF_MEMALLOC will no longer run out of
memory. Allocations under PF_MEMALLOC will do a limited form of reclaim
instead.

The reclaim is of particular important to stacked filesystems that may
do a lot of allocations in the write path. Reclaim will be working
as long as there are clean file backed pages to reclaim.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/page_alloc.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-08-13 23:50:01.000000000 -0700
+++ linux-2.6/mm/page_alloc.c	2007-08-13 23:58:43.000000000 -0700
@@ -1306,6 +1306,17 @@ nofail_alloc:
 				zonelist, ALLOC_NO_WATERMARKS);
 			if (page)
 				goto got_pg;
+			/*
+			 * If we are already in reclaim then the environment
+			 * is already setup. We can simply call
+			 * try_to_get_free_pages(). Just make sure that
+			 * we do not allocate anything.
+			 */
+			if (p->flags & PF_MEMALLOC && wait &&
+				try_to_free_pages(zonelist->zones, order,
+						gfp_mask | __GFP_NOMEMALLOC))
+				goto restart;
+
 			if (gfp_mask & __GFP_NOFAIL) {
 				congestion_wait(WRITE, HZ/50);
 				goto nofail_alloc;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
