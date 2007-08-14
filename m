Message-Id: <20070814153502.753854133@sgi.com>
References: <20070814153021.446917377@sgi.com>
Date: Tue, 14 Aug 2007 08:30:29 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 8/9] Reclaim on an atomic allocation if necessary
Content-Disposition: inline; filename=reclaim_on_atomic_alloc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Simply call reclaim if we get to a point where we cannot perform
the desired atomic allocation. If the reclaim is successful then
restart the allocation.

This will allow atomic allocs to not run out of memory. We reclaim clean
pages instead. If we are in an interrupt then the interrupt holdoff
will be long since reclaim processing is intensive. However, we will
no longer OOM.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/page_alloc.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-08-14 07:42:09.000000000 -0700
+++ linux-2.6/mm/page_alloc.c	2007-08-14 07:53:34.000000000 -0700
@@ -1326,8 +1326,12 @@ nofail_alloc:
 	}
 
 	/* Atomic allocations - we can't balance anything */
-	if (!wait)
+	if (!wait) {
+		if (try_to_free_pages(zonelist->zones, order, gfp_mask
+							| __GFP_NOMEMALLOC))
+			goto restart;
 		goto nopage;
+	}
 
 	cond_resched();
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
