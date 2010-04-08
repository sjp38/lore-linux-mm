Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 34AE8600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 13:10:15 -0400 (EDT)
Date: Thu, 8 Apr 2010 19:09:48 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 56 of 67] Memory compaction core
Message-ID: <20100408170948.GQ5749@random.random>
References: <patchbomb.1270691443@v2.random>
 <a86f1d01d86dffb4ab53.1270691499@v2.random>
 <20100408161814.GC28964@cmpxchg.org>
 <20100408164630.GL5749@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100408164630.GL5749@random.random>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

Hi Johannes,

I think this should fix the inefficiency. What you think?

Still it shouldn't be able to fix any instability. And I'm afraid
it'll hide bugs. Nevertheless this is the correct behavior, it's
pointless to migrate hugepages around even if it is supposed to work
fine and needed by move_pages.

I'm going to commit it to my tree after some testing.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -265,10 +265,34 @@ static unsigned long isolate_migratepage
 		if (PageBuddy(page))
 			continue;
 
+		/*
+		 * __split_huge_page_refcount() runs with the
+		 * zone->lru_lock held so PG_head can't go away from
+		 * under us. We use PageTransCompound because
+		 * PageTransHuge would VM_BUG_ON if it runs into some
+		 * random tail page that doesn't belong to transparent
+		 * hugepage subsystem during the pfn scan.
+		 */
+		if (PageTransCompound(page)) {
+			low_pfn += (1 << page_order(page)) - 1;
+			continue;
+		}
+
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
 			continue;
 
+		/*
+		 * khugepaged cannot generate an hugepage queued into
+		 * the LRU before __isolate_lru_page runs, because
+		 * it has to take the zone->lru_lock first in order to
+		 * set PageLRU onto the hugepage. And PageHead is always
+		 * set by the buddy allocator before returning the hugepage
+		 * to khugepaged and in turn before taking the lru_lock
+		 * to set PageLRU.
+		 */
+		BUG_ON(PageTransCompound(page));
+
 		/* Successfully isolated */
 		del_page_from_lru_list(zone, page, page_lru(page));
 		list_add(&page->lru, migratelist);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
