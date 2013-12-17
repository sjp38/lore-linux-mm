Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 155CA6B003A
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 11:04:08 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e51so2529850eek.34
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:04:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m44si5634130eeo.226.2013.12.17.08.04.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 08:04:08 -0800 (PST)
Date: Tue, 17 Dec 2013 16:04:04 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/7] mm: page_alloc: Default allow file pages to use
 remote nodes for fair allocation policy
Message-ID: <20131217160404.GD11295@suse.de>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-8-git-send-email-mgorman@suse.de>
 <20131213170443.GO22729@cmpxchg.org>
 <20131213192014.GL11295@suse.de>
 <20131213221541.GQ21724@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131213221541.GQ21724@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 13, 2013 at 05:15:41PM -0500, Johannes Weiner wrote:
> On Fri, Dec 13, 2013 at 07:20:14PM +0000, Mel Gorman wrote:
> > On Fri, Dec 13, 2013 at 12:04:43PM -0500, Johannes Weiner wrote:
> > > On Fri, Dec 13, 2013 at 02:10:07PM +0000, Mel Gorman wrote:
> > > > Indications from Johannes that he wanted this. Needs some data and/or justification why
> > > > thrash protection needs it plus docs describing how MPOL_LOCAL is now different before
> > > > it should be considered finished. I do not necessarily agree this patch is necessary
> > > > but it's worth punting it out there for discussion and testing.
> > > 
> > > I demonstrated enormous gains in the original submission of the fair
> > > allocation patch and
> > 
> > And the same test missed that it broke MPOL_DEFAULT and regressed any workload
> > that does not hit reclaim by incurring remote accesses unnecessarily.
> 
> And none of this was nice, agreed, but it does not invalidate the
> gains, it only changes what we are comparing them to.
> 

Notifying that we're changing existing interfaces is important. Again, I
need to be clear that I'm not against the change per-se. I'm annoyed with
myself more than anything that I missed some of the major implications
of the change the first time around and want to get back some of the
performance we lost due to remote memory usage.

> > With this patch applied, MPOL_DEFAULT again does not act as
> > documented by Documentation/vm/numa_memory_policy.txt and that file
> > has been around a long time. It also does not match the documented
> > behaviour of mbind where it says
> > 
> > 	The  system-wide  default  policy allocates  pages  on	the node of
> > 	the CPU that triggers the allocation.  For MPOL_DEFAULT, the nodemask
> > 	and maxnode arguments must be specify the empty set of nodes.
> > 
> > That said, that documentation is also strictly wrong as MPOL_DEFAULT *may*
> > allocate on remote nodes.
> >
> > > your tests haven't really shown downsides to the
> > > cache-over-nodes portion of it. 
> > > the cache-over-nodes fairness without any supporting data.
> > > 
> > 
> > It breaks MPOL_LOCAL for file-backed mappings in a manner that cannot be
> > overridden by policies and it is not even documented.  The same effect
> > could have been achieved for the repeatedly reading files by running the
> > processes with the MPOL_INTERLEAVE policy.  There was also no convenient
> > way for a user to override that behaviour. Hard-binding to a node would
> > work but tough luck if the process needs more than one node of memory.
> 
> Hardbinding or enabling zone_reclaim_mode, yes.  But agreed, let's fix
> these problems.
> 

I would very much hate to recommend zone_reclaim_mode to work around
this. That thing is a disaster for a lot of workloads and can cause massive
allocation latencies in an effort to keep memory local. I've dealt with
a fairly sizable number of bugs over the last three years related to
that setting.

> > What I will admit is that I doubt anyone cares that file-backed pages
> > are not node-local as documented as the cost of the IO itself probably
> > dominates but just because something does not make sense does not mean
> > someone is depending on the behaviour.
> 
> And that's why I very much agree that we need a way for people to
> revert to the old behavior in case we are wrong about this.
> 
> But it's also a very strong argument for what the new default should
> be, given that we allow people to revert our decision in the field.
> 

We still need to update the docs at the same time as the default is changed
or at least have the man pages patch in flight to Michael Kerrisk.

> > That alone is pretty heavy justification even in the absense of supporting
> > data showing a workload that depends on file pages being node-local that
> > is not hidden by the cost of the IO itself.
> 
> Even if we anticipate that nobody will care about it and we provide a
> way to revert the behavior in the field in case we are wrong?
> 
> I disagree.
> 

There will be people that care, they just haven't shown up yet. We missed
one important example. After the fair allocation policy we are interleaving
sysv shared memory between nodes. I bet you a shiny penny that heavy users
of sysv shared memory (databases) are depending on the local allocation
policy for those areas and we broke that. They'd be hit even if they were
using direct IO. It could be a long time before some user of those databases
notices a performnace regression of a few percent and finds this change.

We may have missed other examples which is why I would prefer that a
change in the default would be accompanied by an update of Documentation/
and of the manual pages. At least that way we can claim it's behaving as
designed and users will have a chance of discovering the change without
having to post to linux-mm.

> We should definitely allow the user to override our decision, but the
> default should be what we anticipate will benefit most users.
> 
> And I'm really not trying to be ignorant of long-standing documented
> behavior that users may have come to expect.  The bug reports will
> land on my desk just as well.  But it looks like the current behavior
> does not make much sense and is unlikely to be missed.
> 

I think the treatment of sysv shared memory is an important exception.
However, I should cover that in the next series although the hack used may
cause people to throw rocks at me. That's assuming the hack even works,
I have not booted it yet.

> > > Reverting cross-node fairness for anon and slab is a good idea.  It
> > > was always about cache and the original patch was too broad stroked,
> > > but it doesn't invalidate everything it was about.
> > > 
> > 
> > No it doesn't, but it should at least have been documented.
> 
> Yes, no argument there.
> 
> > > I can see, however, that we might want to make this configurable, but
> > > I'm not eager on exporting user interfaces unless we have to.  As the
> > > node-local fairness was never questioned by anybody, is it necessary
> > > to make it configurable? 
> > 
> > It's only there since 3.12 and it takes a long time for people to notice
> > NUMA regressions, especially ones that would just be within a few percent
> > like this was unless they were specifically looking for it.
> 
> No, I meant only the case where we distribute memory fairly among the
> zones WITHIN a given node.  This does not affect NUMA placement.  I
> wouldn't want to make this configurable unless you think people might
> want to disable this.  I can't think of a reason, anyway.
> 

Oh right. That thing was just about API symmetry and for experimentation. I
could not think of a good reason why someone would use it other than to
demonstrate the impact of the fair allocation policy on UMA machines with
a small highest zone. It's the type of thing that Zlatko Calusic's
testing would be sensitive to.

In my current series I replaced it with the knob suggested by Rik and
yourself. The internal details are still the same but the user-visible
knob controls just page cache with special casing of MAP_SHARED anonmous
and sysv memory

> > > Shouldn't we be okay with just a single
> > > vm.pagecache_interleave (name by Rik) sysctl that defaults to 1 but
> > > allows users to go back to pagecache obeying mempolicy?
> > > 
> > 
> > That can be done. I can put together a patch that defaults it to 0 and
> > sets the DISTRIBUTE_REMOTE_FILE  flag if someone writes to it. That's a
> > crude hack but many people will be ok with it.
> > 
> > To make it a default though should require more work though.
> > Create an MPOL_DISTRIB_PAGECACHE memory policy (name because it
> > is not strictly interleave). Abstract MPOL_DEFAULT to be either
> > MPOL_LOCAL or MPOL_DISTRIB_PAGECACHE depending on the value of
> > vm.pagecache_interleave. Update manual pages, and Documentation/ then set
> > the default of vm.pagecache_interleave to 1.
> > 
> > That would allow more sane defaults and also allow users to override it
> > on a per task and per VMA basis as they can for any other type of memory
> > policy.
> 
> Not using round-robin placement for cache creates weird artifacts in
> our LRU aging decisions.  By not aging all pages in a workingset
> equally, we may end up activating barely used pages on a remote node
> and creating pressure on its active list for no reason.
> 

I fully appreciate the positive aspects of the patch and want to see it
happen. If I didn't, I would be trying to revert the patch and ignoring
any arguments to the contrary. I would just prefer we did it in a way
that generated less paperwork in the future.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
