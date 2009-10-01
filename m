Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 31437600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:58:58 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2B98982C771
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 10:41:49 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MNMIaCLtw+G9 for <linux-mm@kvack.org>;
	Thu,  1 Oct 2009 10:41:49 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5A59682C791
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 10:41:24 -0400 (EDT)
Date: Thu, 1 Oct 2009 10:32:54 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/4] slqb: Record what node is local to a
 kmem_cache_cpu
In-Reply-To: <20091001104046.GA21906@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0910011028380.3911@gentwo.org>
References: <1253624054-10882-1-git-send-email-mel@csn.ul.ie> <1253624054-10882-3-git-send-email-mel@csn.ul.ie> <84144f020909220638l79329905sf9a35286130e88d0@mail.gmail.com> <20090922135453.GF25965@csn.ul.ie> <84144f020909221154x820b287r2996480225692fad@mail.gmail.com>
 <20090922185608.GH25965@csn.ul.ie> <20090930144117.GA17906@csn.ul.ie> <alpine.DEB.1.10.0909301053550.9450@gentwo.org> <20090930220541.GA31530@csn.ul.ie> <alpine.DEB.1.10.0909301941570.11850@gentwo.org> <20091001104046.GA21906@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Oct 2009, Mel Gorman wrote:

> > Frees are done directly to the target slab page if they are not to the
> > current active slab page. No centralized locks. Concurrent frees from
> > processors on the same node to multiple other nodes (or different pages
> > on the same node) can occur.
> >
>
> So as a total aside, SLQB has an advantage in that it always uses object
> in LIFO order and is more likely to be cache hot. SLUB has an advantage
> when one CPU allocates and another one frees because it potentially
> avoids a cache line bounce. Might be something worth bearing in mind
> when/if a comparison happens later.

SLQB may use cache hot objects regardless of their locality. SLUB
always serves objects that have the same locality first (same page).
SLAB returns objects via the alien caches to the remote node.
So object allocations with SLUB will generate less TLB pressure since they
are localized. SLUB objects are immediately returned to the remote node.
SLAB/SLQB keeps them around for reallocation or queue processing.

> > Look at fallback_alloc() in slab. You can likely copy much of it. It
> > considers memory policies and cpuset constraints.
> >
> True, it looks like some of the logic should be taken from there all right. Can
> the treatment of memory policies be dealt with as a separate thread though? I'd
> prefer to get memoryless nodes sorted out before considering the next two
> problems (per-cpu instability on ppc64 and memory policy handling in SLQB).

Separate email thread? Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
