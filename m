Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8838B6B01C8
	for <linux-mm@kvack.org>; Sun,  6 Jun 2010 18:34:44 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o56MYgqt009441
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:42 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by hpaq3.eem.corp.google.com with ESMTP id o56MYYdu017757
	for <linux-mm@kvack.org>; Sun, 6 Jun 2010 15:34:41 -0700
Received: by pxi7 with SMTP id 7so1265448pxi.41
        for <linux-mm@kvack.org>; Sun, 06 Jun 2010 15:34:40 -0700 (PDT)
Date: Sun, 6 Jun 2010 15:34:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 11/18] oom: avoid oom killer for lowmem allocations
In-Reply-To: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006061525450.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If memory has been depleted in lowmem zones even with the protection
afforded to it by /proc/sys/vm/lowmem_reserve_ratio, it is unlikely that
killing current users will help.  The memory is either reclaimable (or
migratable) already, in which case we should not invoke the oom killer at
all, or it is pinned by an application for I/O.  Killing such an
application may leave the hardware in an unspecified state and there is no
guarantee that it will be able to make a timely exit.

Lowmem allocations are now failed in oom conditions when __GFP_NOFAIL is
not used so that the task can perhaps recover or try again later.

Previously, the heuristic provided some protection for those tasks with
CAP_SYS_RAWIO, but this is no longer necessary since we will not be
killing tasks for the purposes of ISA allocations.

high_zoneidx is gfp_zone(gfp_flags), meaning that ZONE_NORMAL will be the
default for all allocations that are not __GFP_DMA, __GFP_DMA32,
__GFP_HIGHMEM, and __GFP_MOVABLE on kernels configured to support those
flags.  Testing for high_zoneidx being less than ZONE_NORMAL will only
return true for allocations that have either __GFP_DMA or __GFP_DMA32.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |   29 ++++++++++++++++++++---------
 1 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1759,6 +1759,9 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		/* The OOM killer will not help higher order allocs */
 		if (order > PAGE_ALLOC_COSTLY_ORDER)
 			goto out;
+		/* The OOM killer does not needlessly kill tasks for lowmem */
+		if (high_zoneidx < ZONE_NORMAL)
+			goto out;
 		/*
 		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
 		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
@@ -2052,15 +2055,23 @@ rebalance:
 			if (page)
 				goto got_pg;
 
-			/*
-			 * The OOM killer does not trigger for high-order
-			 * ~__GFP_NOFAIL allocations so if no progress is being
-			 * made, there are no other options and retrying is
-			 * unlikely to help.
-			 */
-			if (order > PAGE_ALLOC_COSTLY_ORDER &&
-						!(gfp_mask & __GFP_NOFAIL))
-				goto nopage;
+			if (!(gfp_mask & __GFP_NOFAIL)) {
+				/*
+				 * The oom killer is not called for high-order
+				 * allocations that may fail, so if no progress
+				 * is being made, there are no other options and
+				 * retrying is unlikely to help.
+				 */
+				if (order > PAGE_ALLOC_COSTLY_ORDER)
+					goto nopage;
+				/*
+				 * The oom killer is not called for lowmem
+				 * allocations to prevent needlessly killing
+				 * innocent tasks.
+				 */
+				if (high_zoneidx < ZONE_NORMAL)
+					goto nopage;
+			}
 
 			goto restart;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
