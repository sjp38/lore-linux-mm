Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 40CD96B0099
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:20:28 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o1FMKQSY025617
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:20:26 -0800
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by kpbe20.cbf.corp.google.com with ESMTP id o1FMKNjL026090
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:20:24 -0800
Received: by pzk4 with SMTP id 4so5802435pzk.5
        for <linux-mm@kvack.org>; Mon, 15 Feb 2010 14:20:23 -0800 (PST)
Date: Mon, 15 Feb 2010 14:20:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 8/9 v2] oom: avoid oom killer for lowmem allocations
In-Reply-To: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1002151419260.26927@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If memory has been depleted in lowmem zones even with the protection
afforded to it by /proc/sys/vm/lowmem_reserve_ratio, it is unlikely that
killing current users will help.  The memory is either reclaimable (or
migratable) already, in which case we should not invoke the oom killer at
all, or it is pinned by an application for I/O.  Killing such an
application may leave the hardware in an unspecified state and there is
no guarantee that it will be able to make a timely exit.

Lowmem allocations are now failed in oom conditions so that the task can
perhaps recover or try again later.  Killing current is an unnecessary
result for simply making a GFP_DMA or GFP_DMA32 page allocation and no
lowmem allocations use the now-deprecated __GFP_NOFAIL bit so retrying is
unnecessary.

Previously, the heuristic provided some protection for those tasks with 
CAP_SYS_RAWIO, but this is no longer necessary since we will not be
killing tasks for the purposes of ISA allocations.

high_zoneidx is gfp_zone(gfp_flags), meaning that ZONE_NORMAL will be the
default for all allocations that are not __GFP_DMA, __GFP_DMA32,
__GFP_HIGHMEM, and __GFP_MOVABLE on kernels configured to support those
flags.  Testing for high_zoneidx being less than ZONE_NORMAL will only
return true for allocations that have either __GFP_DMA or __GFP_DMA32.

Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1914,6 +1914,9 @@ rebalance:
 	 * running out of options and have to consider going OOM
 	 */
 	if (!did_some_progress) {
+		/* The oom killer won't necessarily free lowmem */
+		if (high_zoneidx < ZONE_NORMAL)
+			goto nopage;
 		if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
 			if (oom_killer_disabled)
 				goto nopage;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
