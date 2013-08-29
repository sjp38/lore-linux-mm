Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id E94B56B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 07:14:27 -0400 (EDT)
Date: Thu, 29 Aug 2013 13:14:19 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v3
Message-ID: <20130829111419.GA10002@twins.programming.kicks-ass.net>
References: <20120307180852.GE17697@suse.de>
 <20130823130332.GY31370@twins.programming.kicks-ass.net>
 <20130823181546.GA31370@twins.programming.kicks-ass.net>
 <20130829092828.GB22421@suse.de>
 <20130829094342.GX10002@twins.programming.kicks-ass.net>
 <20130829105656.GD22421@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130829105656.GD22421@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On Thu, Aug 29, 2013 at 11:56:57AM +0100, Mel Gorman wrote:
> > I thought it was, we crashed somewhere suspiciously close, but no. You
> > need shared mpols for this to actually trigger and the NUMA stuff
> > doesn't use that.
> > 
> 
> Ah, so this is a red herring?

Yeah, but I still think its an actual bug. It seems the easiest way to
trigger this would be to:

 create a task that constantly allocates pages
 have said task have an MPOL_INTERLEAVE task policy
 put said task into a cpuset
 using a different task (your shell for example) flip the cpuset's
   mems_allowed back and forth.

This would have the shell task constantly rebind (in two steps) our
allocating task's INTERLEAVE policy.

> > I used whatever nodemask.h did to detect end-of-bitmap and they use
> > MAX_NUMNODES. See __next_node() and for_each_node() like.
> > 
> 
> The check does prevent us going off the end of the bitmap but does not
> necessarily return an online node.

Right, but its guaranteed to return a 'valid' node. I don't think it
returning an offline node is a problem, we'll find it empty and fail the
page allocation.

> > MAX_NUMNODES doesn't assume contiguous numbers since its the actual size
> > of the bitmap, nr_online_nodes would hoever.
> > 
> 
> I intended to say nr_node_ids, the same size as buffers such as the
> task_numa_buffers. If we ever return a nid > nr_node_ids here then
> task_numa_fault would corrupt memory. However, it should be possible for
> node_weight to exceed nr_node_ids except maybe during node hot-remove so
> it's not the problem.

The nodemask situation seems somewhat more confused than the cpumask
case; how would we ever return a nid > nr_node_ids? Corrupt nodemask?

In the cpumask case we use the runtime limit nr_cpu_ids for all bitmap
operations, arguably we should make the nodemask stuff do the same.

Less bits to iterate is always good; a MAX_NUMNODES=64
(x86_64-defconfig) will still iterate all 64 bits, even though its
unlikely to have more than 1 let alone more than 8 nodes.

> > So I explicitly didn't use the node_isset() test because that's more
> > likely to trigger than the nid >= MAX_NUMNODES test. Its fine to return
> > a node that isn't actually part of the mask anymore -- a race is a race
> > anyway.
> 
> Yeah and as long as it's < nr_node_ids it should be ok within the task
> numa fault handling as well.

Right, I'm just a tad confused on how we could ever get a nid >=
nr_node_ids except from a prior bug (corrupted nodemask).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
