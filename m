Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D02F45F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 19:58:57 -0400 (EDT)
Date: Fri, 22 Oct 2010 10:58:54 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
Message-ID: <20101021235854.GD3270@amd>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
 <alpine.DEB.2.00.1010211259360.24115@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010211259360.24115@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 01:00:37PM -0500, Christoph Lameter wrote:
> Add a field node to struct shrinker that can be used to indicate on which
> node the reclaim should occur. The node field also can be set to NUMA_NO_NODE
> in which case a reclaim pass over all nodes is desired.
> 
> NUMA_NO_NODE will be used for direct reclaim since reclaim is not specific
> there (Some issues are still left since we are not respecting boundaries of
> memory policies and cpusets).
> 
> A node will be supplied for kswap and zone reclaim invocations of zone reclaim.
> It is also possible then for the shrinker invocation from mm/memory-failure.c
> to indicate the node for which caches need to be shrunk.
> 
> After this patch it is possible to make shrinkers node aware by checking
> the node field of struct shrinker. If a shrinker does not support per node
> reclaim then it can still do global reclaim.

Again, I really think it needs to be per zone. Something like inode
cache could still have lots of allocations in ZONE_NORMAL with plenty
of memory free there, but a DMA zone shortage could cause it to trash
the caches.

Did you dislike my proposed API?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
