Received: from edge02.upc.biz ([192.168.13.237]) by viefep16-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080320202140.KXUT8097.viefep16-int.chello.at@edge02.upc.biz>
          for <linux-mm@kvack.org>; Thu, 20 Mar 2008 21:21:40 +0100
Message-Id: <20080320202120.601334000@chello.nl>
References: <20080320201042.675090000@chello.nl>
Date: Thu, 20 Mar 2008 21:10:45 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 03/30] mm: tag reseve pages
Content-Disposition: inline; filename=page_alloc-reserve.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, neilb@suse.de, miklos@szeredi.hu, penberg@cs.helsinki.fi, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Tag pages allocated from the reserves with a non-zero page->reserve.
This allows us to distinguish and account reserve pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm_types.h |    1 +
 mm/page_alloc.c          |    4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -70,6 +70,7 @@ struct page {
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
+		int reserve;		/* page_alloc: page is a reserve page */
 	};
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -1433,8 +1433,10 @@ zonelist_scan:
 		}
 
 		page = buffered_rmqueue(preferred_zone, zone, order, gfp_mask);
-		if (page)
+		if (page) {
+			page->reserve = !!(alloc_flags & ALLOC_NO_WATERMARKS);
 			break;
+		}
 this_zone_full:
 		if (NUMA_BUILD)
 			zlc_mark_zone_full(zonelist, z);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
