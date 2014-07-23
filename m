Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC3F6B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 18:50:13 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so1615170iec.19
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 15:50:13 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id b7si9744954ict.55.2014.07.23.15.50.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 15:50:12 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so1575758iec.37
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 15:50:11 -0700 (PDT)
Date: Wed, 23 Jul 2014 15:50:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: do not allow thp faults to avoid cpuset
 restrictions
In-Reply-To: <alpine.DEB.2.02.1407231516570.23495@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1407231545520.1389@chino.kir.corp.google.com>
References: <20140723220538.GT8578@sgi.com> <alpine.DEB.2.02.1407231516570.23495@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, lliubbo@gmail.com, Johannes Weiner <hannes@cmpxchg.org>, srivatsa.bhat@linux.vnet.ibm.com, Dave Hansen <dave.hansen@linux.intel.com>, dfults@sgi.com, hedi@sgi.com

The page allocator relies on __GFP_WAIT to determine if ALLOC_CPUSET 
should be set in allocflags.  ALLOC_CPUSET controls if a page allocation 
should be restricted only to the set of allowed cpuset mems.

Transparent hugepages clears __GFP_WAIT when defrag is disabled to prevent 
the fault path from using memory compaction or direct reclaim.  Thus, it 
is unfairly able to allocate outside of its cpuset mems restriction as a 
side-effect.

This patch ensures that ALLOC_CPUSET is only cleared when the gfp mask is 
truly GFP_ATOMIC by verifying it is also not a thp allocation.

Reported-by: Alex Thorlton <athorlton@sgi.com>
Cc: stable@vger.kernel.org
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2447,7 +2447,7 @@ static inline int
 gfp_to_alloc_flags(gfp_t gfp_mask)
 {
 	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
-	const gfp_t wait = gfp_mask & __GFP_WAIT;
+	const bool atomic = !(gfp_mask & (__GFP_WAIT | __GFP_NO_KSWAPD));
 
 	/* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch. */
 	BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t) ALLOC_HIGH);
@@ -2456,20 +2456,20 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	 * The caller may dip into page reserves a bit more if the caller
 	 * cannot run direct reclaim, or if the caller has realtime scheduling
 	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
-	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
+	 * set both ALLOC_HARDER (atomic == true) and ALLOC_HIGH (__GFP_HIGH).
 	 */
 	alloc_flags |= (__force int) (gfp_mask & __GFP_HIGH);
 
-	if (!wait) {
+	if (atomic) {
 		/*
-		 * Not worth trying to allocate harder for
-		 * __GFP_NOMEMALLOC even if it can't schedule.
+		 * Not worth trying to allocate harder for __GFP_NOMEMALLOC even
+		 * if it can't schedule.
 		 */
-		if  (!(gfp_mask & __GFP_NOMEMALLOC))
+		if (!(gfp_mask & __GFP_NOMEMALLOC))
 			alloc_flags |= ALLOC_HARDER;
 		/*
-		 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
-		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
+		 * Ignore cpuset mems for GFP_ATOMIC rather than fail, see the
+		 * comment for __cpuset_node_allowed_softwall().
 		 */
 		alloc_flags &= ~ALLOC_CPUSET;
 	} else if (unlikely(rt_task(current)) && !in_interrupt())

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
