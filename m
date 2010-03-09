Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B2EB56B0098
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 14:44:20 -0500 (EST)
Message-Id: <20100309194315.810981904@redhat.com>
Date: Tue, 09 Mar 2010 20:39:27 +0100
From: aarcange@redhat.com
Subject: [patch 26/35] dont alloc harder for gfp nomemalloc even if nowait
References: <20100309193901.207868642@redhat.com>
Content-Disposition: inline; filename=gfp_nomemalloc_wait
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Not worth throwing away the precious reserved free memory pool for allocations
that can fail gracefully (either through mempool or because they're transhuge
allocations later falling back to 4k allocations).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/page_alloc.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1790,7 +1790,11 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
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
