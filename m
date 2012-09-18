Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 741C76B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 17:44:13 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so995367pbb.14
        for <linux-mm@kvack.org>; Tue, 18 Sep 2012 14:44:12 -0700 (PDT)
Date: Tue, 18 Sep 2012 14:44:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, numa: reclaim from all nodes within reclaim
 distance
In-Reply-To: <20120918140313.236f7a66.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1209181423400.26078@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1209180003340.16777@chino.kir.corp.google.com> <20120918140313.236f7a66.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Sep 2012, Andrew Morton wrote:

> > RECLAIM_DISTANCE represents the distance between nodes at which it is
> > deemed too costly to allocate from; it's preferred to try to reclaim from
> > a local zone before falling back to allocating on a remote node with such
> > a distance.
> > 
> > To do this, zone_reclaim_mode is set if the distance between any two
> > nodes on the system is greather than this distance.  This, however, ends
> > up causing the page allocator to reclaim from every zone regardless of
> > its affinity.
> > 
> > What we really want is to reclaim only from zones that are closer than 
> > RECLAIM_DISTANCE.  This patch adds a nodemask to each node that
> > represents the set of nodes that are within this distance.  During the
> > zone iteration, if the bit for a zone's node is set for the local node,
> > then reclaim is attempted; otherwise, the zone is skipped.
> 
> Is this a theoretical thing, or does the patch have real observable
> effects?
> 

In its current state, this is for correctness and it could have an 
observable effect on a system where node_distance(a, b) doesn't accurately 
represent the access latency between the two nodes relative to a local 
access.  On x86, this would mean a SLIT that isn't representative of the 
physical topology, which tends to be fairly common, and because 
RECLAIM_DISTANCE > REMOTE_DISTANCE.

> This change makes it more important that the arch code implements
> node_distance() accurately (wrt RECLAIM_DISTANCE), yes?  I wonder how
> much code screwed that up, and what the effects of such a screwup would
> be, and how arch maintainers would go about detecting then fixing such
> an error?
> 

My solution is to get rid of RECLAIM_DISTANCE entirely based on two 
assertions:

 - we don't want to encode any arch-dependent zone reclaiming behavior 
   into the VM, i.e. we don't want mips to hack a node_distance() 
   implementation or RECLAIM_DISTANCE value to change the behavior of the 
   page allocator as a workaround for a bigger problem, and

 - there's no unifying unit and scale to measure when we should reclaim 
   locally or allocate remotely across all architectures and, even if 
   there was, we probably shouldn't trust it to be correct.

So we declare generically that RECLAIM_DISTANCE is 30 and that is what is 
used on x86 where this information is determined by a SLIT and the ACPI 
specification states the values in the SLIT are relative to LOCAL_DISTANCE 
of 10.  Thus, on x86, the VM policy (after this patch) is to prefer to 
skip reclaim from remote zones where the memory latency is three times 
greater or more than accessing locally.

Given that, I eventually want to remove RECLAIM_DISTANCE entirely and 
measure the actual latency of a memory access to remote zones after the 
zonelists are initially built as the criteria to set bits in the new 
reclaim_nodes nodemask.

That's the long-term goal.

We do currently have memory hotplug issues, though, for zone_reclaim_mode 
independent of this patch.  If it was set at boot and we unplug the last 
node on the system with a distance > RECLAIM_DISTANCE, then it remains set 
so we're still always reclaiming when we could just allocate remotely.  
We can't just clear the bit before rebuilding the zonelists after a 
hotplug event, though, because it may never have been set at boot and was 
rather set by the user via the tunable.

Once I've removed RECLAIM_DISTANCE entirely, I think we can leave 
zone_reclaim_mode entirely to the user and just use the new reclaim_nodes 
mask to determine when to reclaim locally vs. allocate remotely, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
