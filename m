Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6BD936B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 15:34:32 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 847C382CE33
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 15:40:29 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 52DVlmBex-P9 for <linux-mm@kvack.org>;
	Thu, 29 Oct 2009 15:40:23 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E07DD82CE35
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 15:39:56 -0400 (EDT)
Date: Thu, 29 Oct 2009 19:33:20 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH/RFC] slab:  handle memoryless nodes efficiently
In-Reply-To: <1256843939.16599.71.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.10.0910291924100.32581@V090114053VZO-1>
References: <1256836094.16599.67.camel@useless.americas.hpqcorp.net>  <alpine.DEB.1.10.0910291728200.30007@V090114053VZO-1> <1256843939.16599.71.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Oct 2009, Lee Schermerhorn wrote:

> > We can then use that in various subsystems and could use it consistently
> > also in slab.c
>
> Where should we put it?  In page_alloc.c that manages the zonelists.

Thats the obvious place.

> > One problem with such a scheme (and also this patch) is that multiple
> > memory nodes may be at the same distance to a processor on a memoryless
> > node. Should the allocation not take memory from any of these nodes?
>
> Well, this is the case for normal page allocations as well, but we
> choose one, in build_zonelists(), that we'll use whenever a page
> allocation overflows the target node selected by the mempolicy.  So,
> that seemed a reasonable node to use for slab allocations.
>
> Thoughts?

Not exactly. For a memoryless node the per cpu array is always empty
and there are no pages that can be allocated from the node. Therefore
we always call fallback_alloc. fallback_alloc is expensive. The speed
increase you see is from not using fallback_alloc anymore.

Look at slab.c:fallback_alloc. First we determine the node that is
determined by the policy. That is memoryless in our case. Then we walk
down the zonelist (obeying cpuset restriction) of that node trying to see
if we have slab object on any of the nodes of the zones listed.

If that fails then we call the page allocator and specify the
("memoryless") node. The page allocator will fallback according to policy
and then we will get a page from the node that the page allocator
determines.

So the concept of a numa_mem_node_id() currently does not exist. If you
add it then memory policies and/or cpusets will only be partially obeyed.

With fallback_alloc the page allocator may fall back to other nodes if
nearer ones are overallocated. With the regular alloc function of slab.c
that sets GFP_THISNODE this is not allowed to occur. So the introduction
of a numa_mem_node_id() will cause an imbalance. Fallback to other nodes
will no longer occur.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
