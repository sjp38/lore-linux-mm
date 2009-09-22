Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0336B00B2
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 11:26:40 -0400 (EDT)
Date: Tue, 22 Sep 2009 16:26:49 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
Message-ID: <20090922152649.GG25965@csn.ul.ie>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <1253577603.7103.174.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1253577603.7103.174.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 22, 2009 at 10:00:03AM +1000, Benjamin Herrenschmidt wrote:
> On Mon, 2009-09-21 at 17:10 +0100, Mel Gorman wrote:
> > 
> > It needs signed-off from the powerpc side because it's now allocating
> > more
> > memory potentially (Ben?). An alternative to this patch is in V1 that
> > statically declares the per-node structures but this is potentially
> > sub-optimal but from a performance and memory utilisation perspective.
> 
> So if I understand correctly, we have a problem with both cpu-less and
> memory-less nodes. Interesting setups :-)
> 

memoryless anyway because of the per-node trick. I'm not aware of
cpuless problems but I suspect cpuless nodes exist for more than ppc64.

> I have no strong objection on the allocating of the per-cpu data for
> the cpu-less nodes. However, I wonder if we should do that a bit more
> nicely, maybe with some kind of "adjusted" cpu_possible_mask() (could be
> something like cpu_node_valid_mask or similar) to be used by percpu.
> 

That would be reasonable if per-node data becomes more popular although
with only SLQB depending on per-node data, it's hard to justify unless
SLQB *really* benefits from per-node.

Lumping the per-cpu allocator to cover per-cpu and per-node feels a bit
confusing. Maybe it would have been easier if there simply were never
memoryless nodes and cpus were always mapped to their closest, instead of
their local, node. There likely would be a few corner cases though and memory
hotplug would add to the mess. I haven't been able to decide on a sensible
way forward that doesn't involve a number of invasive changes.

> Mostly because it would be nice to have built-in debug features in
> per-cpu and in that case, it would need some way to know a valid
> number from an invalid one). Either that or just keep track of the
> mask of cpus that had percpu data allocated to them
> 

The former would be nice, the latter would be a requirement if per-node data
was pursued.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
