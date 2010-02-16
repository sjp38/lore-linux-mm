Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA9686B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 03:25:35 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o1G8PSgO024860
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 08:25:29 GMT
Received: from pzk41 (pzk41.prod.google.com [10.243.19.169])
	by wpaz9.hot.corp.google.com with ESMTP id o1G8PQbX009494
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:25:27 -0800
Received: by pzk41 with SMTP id 41so10430288pzk.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:25:26 -0800 (PST)
Date: Tue, 16 Feb 2010 00:25:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 8/9 v2] oom: avoid oom killer for lowmem
 allocations
In-Reply-To: <20100216075330.GJ5723@laptop>
Message-ID: <alpine.DEB.2.00.1002160024370.15201@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151419260.26927@chino.kir.corp.google.com> <20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
 <20100216064402.GC5723@laptop> <alpine.DEB.2.00.1002152334260.7470@chino.kir.corp.google.com> <20100216075330.GJ5723@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, Nick Piggin wrote:

> > I'll add this check to __alloc_pages_may_oom() for the !(gfp_mask & 
> > __GFP_NOFAIL) path since we're all content with endlessly looping.
> 
> Thanks. Yes endlessly looping is far preferable to randomly oopsing
> or corrupting memory.
> 

Here's the new patch for your consideration.


oom: avoid oom killer for lowmem allocations

If memory has been depleted in lowmem zones even with the protection
afforded to it by /proc/sys/vm/lowmem_reserve_ratio, it is unlikely that
killing current users will help.  The memory is either reclaimable (or
migratable) already, in which case we should not invoke the oom killer at
all, or it is pinned by an application for I/O.  Killing such an
application may leave the hardware in an unspecified state and there is
no guarantee that it will be able to make a timely exit.

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

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1705,6 +1705,9 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		 */
 		if (gfp_mask & __GFP_THISNODE)
 			goto out;
+		/* The oom killer won't necessarily free lowmem */
+		if (high_zoneidx < ZONE_NORMAL)
+			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
 	out_of_memory(zonelist, gfp_mask, order, nodemask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
