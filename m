Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 845ED6004AB
	for <linux-mm@kvack.org>; Sun, 21 Feb 2010 09:18:49 -0500 (EST)
Message-Id: <20100221141756.929160492@redhat.com>
Date: Sun, 21 Feb 2010 15:10:35 +0100
From: aarcange@redhat.com
Subject: [patch 26/36] dont alloc harder for gfp nomemalloc even if nowait
References: <20100221141009.581909647@redhat.com>
Content-Disposition: inline; filename=gfp_nomemalloc_wait
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Not worth throwing away the precious reserved free memory pool for allocations
that can fail gracefully (either through mempool or because they're transhuge
allocations later falling back to 4k allocations).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1773,7 +1773,11 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
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
