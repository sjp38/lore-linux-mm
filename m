Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB1A6B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 17:15:51 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id v15so1597242bkz.14
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 14:15:50 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ls2si860892bkb.166.2013.12.13.14.15.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 14:15:50 -0800 (PST)
Date: Fri, 13 Dec 2013 17:15:41 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 7/7] mm: page_alloc: Default allow file pages to use
 remote nodes for fair allocation policy
Message-ID: <20131213221541.GQ21724@cmpxchg.org>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-8-git-send-email-mgorman@suse.de>
 <20131213170443.GO22729@cmpxchg.org>
 <20131213192014.GL11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131213192014.GL11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 13, 2013 at 07:20:14PM +0000, Mel Gorman wrote:
> On Fri, Dec 13, 2013 at 12:04:43PM -0500, Johannes Weiner wrote:
> > On Fri, Dec 13, 2013 at 02:10:07PM +0000, Mel Gorman wrote:
> > > Indications from Johannes that he wanted this. Needs some data and/or justification why
> > > thrash protection needs it plus docs describing how MPOL_LOCAL is now different before
> > > it should be considered finished. I do not necessarily agree this patch is necessary
> > > but it's worth punting it out there for discussion and testing.
> > 
> > I demonstrated enormous gains in the original submission of the fair
> > allocation patch and
> 
> And the same test missed that it broke MPOL_DEFAULT and regressed any workload
> that does not hit reclaim by incurring remote accesses unnecessarily.

And none of this was nice, agreed, but it does not invalidate the
gains, it only changes what we are comparing them to.

> With this patch applied, MPOL_DEFAULT again does not act as
> documented by Documentation/vm/numa_memory_policy.txt and that file
> has been around a long time. It also does not match the documented
> behaviour of mbind where it says
> 
> 	The  system-wide  default  policy allocates  pages  on	the node of
> 	the CPU that triggers the allocation.  For MPOL_DEFAULT, the nodemask
> 	and maxnode arguments must be specify the empty set of nodes.
> 
> That said, that documentation is also strictly wrong as MPOL_DEFAULT *may*
> allocate on remote nodes.
>
> > your tests haven't really shown downsides to the
> > cache-over-nodes portion of it. 
> > the cache-over-nodes fairness without any supporting data.
> > 
> 
> It breaks MPOL_LOCAL for file-backed mappings in a manner that cannot be
> overridden by policies and it is not even documented.  The same effect
> could have been achieved for the repeatedly reading files by running the
> processes with the MPOL_INTERLEAVE policy.  There was also no convenient
> way for a user to override that behaviour. Hard-binding to a node would
> work but tough luck if the process needs more than one node of memory.

Hardbinding or enabling zone_reclaim_mode, yes.  But agreed, let's fix
these problems.

> What I will admit is that I doubt anyone cares that file-backed pages
> are not node-local as documented as the cost of the IO itself probably
> dominates but just because something does not make sense does not mean
> someone is depending on the behaviour.

And that's why I very much agree that we need a way for people to
revert to the old behavior in case we are wrong about this.

But it's also a very strong argument for what the new default should
be, given that we allow people to revert our decision in the field.

> That alone is pretty heavy justification even in the absense of supporting
> data showing a workload that depends on file pages being node-local that
> is not hidden by the cost of the IO itself.

Even if we anticipate that nobody will care about it and we provide a
way to revert the behavior in the field in case we are wrong?

I disagree.

We should definitely allow the user to override our decision, but the
default should be what we anticipate will benefit most users.

And I'm really not trying to be ignorant of long-standing documented
behavior that users may have come to expect.  The bug reports will
land on my desk just as well.  But it looks like the current behavior
does not make much sense and is unlikely to be missed.

> > Reverting cross-node fairness for anon and slab is a good idea.  It
> > was always about cache and the original patch was too broad stroked,
> > but it doesn't invalidate everything it was about.
> > 
> 
> No it doesn't, but it should at least have been documented.

Yes, no argument there.

> > I can see, however, that we might want to make this configurable, but
> > I'm not eager on exporting user interfaces unless we have to.  As the
> > node-local fairness was never questioned by anybody, is it necessary
> > to make it configurable? 
> 
> It's only there since 3.12 and it takes a long time for people to notice
> NUMA regressions, especially ones that would just be within a few percent
> like this was unless they were specifically looking for it.

No, I meant only the case where we distribute memory fairly among the
zones WITHIN a given node.  This does not affect NUMA placement.  I
wouldn't want to make this configurable unless you think people might
want to disable this.  I can't think of a reason, anyway.

> > Shouldn't we be okay with just a single
> > vm.pagecache_interleave (name by Rik) sysctl that defaults to 1 but
> > allows users to go back to pagecache obeying mempolicy?
> > 
> 
> That can be done. I can put together a patch that defaults it to 0 and
> sets the DISTRIBUTE_REMOTE_FILE  flag if someone writes to it. That's a
> crude hack but many people will be ok with it.
> 
> To make it a default though should require more work though.
> Create an MPOL_DISTRIB_PAGECACHE memory policy (name because it
> is not strictly interleave). Abstract MPOL_DEFAULT to be either
> MPOL_LOCAL or MPOL_DISTRIB_PAGECACHE depending on the value of
> vm.pagecache_interleave. Update manual pages, and Documentation/ then set
> the default of vm.pagecache_interleave to 1.
> 
> That would allow more sane defaults and also allow users to override it
> on a per task and per VMA basis as they can for any other type of memory
> policy.

Not using round-robin placement for cache creates weird artifacts in
our LRU aging decisions.  By not aging all pages in a workingset
equally, we may end up activating barely used pages on a remote node
and creating pressure on its active list for no reason.

This has little to do with the thrash detection patches, either, they
will just potentially trigger a few more non-sensical activations but
for the same reason that the aging is skewed.

Because of that I really don't want to implement round-robin cache
placement as just another possible mempolicy when other parts of the
VM rely on it to be there.

It would make more sense to me to ignore mempolicies for cache per
default and provide a single sysctl to honor them for the sole reason
that we have been honoring them for a very long time.  And document
the whole thing properly of course.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
