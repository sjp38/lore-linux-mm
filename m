Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C74C16B01E9
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 13:12:54 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 26 of 41] don't alloc harder for gfp nomemalloc even if nowait
Message-Id: <7d05fb910d35a21ab923.1269622830@v2.random>
In-Reply-To: <patchbomb.1269622804@v2.random>
References: <patchbomb.1269622804@v2.random>
Date: Fri, 26 Mar 2010 18:00:30 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Not worth throwing away the precious reserved free memory pool for allocations
that can fail gracefully (either through mempool or because they're transhuge
allocations later falling back to 4k allocations).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1811,7 +1811,11 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	 */
 	alloc_flags |= (gfp_mask & __GFP_HIGH);
 
-	if (!wait) {
+	/*
+	 * Not worth trying to allocate harder for __GFP_NOMEMALLOC
+	 * even if it can't schedule.
+	 */
+	if (!wait && !(gfp_mask & __GFP_NOMEMALLOC)) {
 		alloc_flags |= ALLOC_HARDER;
 		/*
 		 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
