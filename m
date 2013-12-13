Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
	by kanga.kvack.org (Postfix) with ESMTP id 077F56B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 14:20:18 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id l9so917707eaj.28
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 11:20:18 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h45si3064331eeo.235.2013.12.13.11.20.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 11:20:18 -0800 (PST)
Date: Fri, 13 Dec 2013 19:20:14 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/7] mm: page_alloc: Default allow file pages to use
 remote nodes for fair allocation policy
Message-ID: <20131213192014.GL11295@suse.de>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-8-git-send-email-mgorman@suse.de>
 <20131213170443.GO22729@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131213170443.GO22729@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 13, 2013 at 12:04:43PM -0500, Johannes Weiner wrote:
> On Fri, Dec 13, 2013 at 02:10:07PM +0000, Mel Gorman wrote:
> > Indications from Johannes that he wanted this. Needs some data and/or justification why
> > thrash protection needs it plus docs describing how MPOL_LOCAL is now different before
> > it should be considered finished. I do not necessarily agree this patch is necessary
> > but it's worth punting it out there for discussion and testing.
> 
> I demonstrated enormous gains in the original submission of the fair
> allocation patch and

And the same test missed that it broke MPOL_DEFAULT and regressed any workload
that does not hit reclaim by incurring remote accesses unnecessarily. With
this patch applied, MPOL_DEFAULT again does not act as documented by
Documentation/vm/numa_memory_policy.txt and that file has been around a
long time. It also does not match the documented behaviour of mbind
where it says

	The  system-wide  default  policy allocates  pages  on	the node of
	the CPU that triggers the allocation.  For MPOL_DEFAULT, the nodemask
	and maxnode arguments must be specify the empty set of nodes.

That said, that documentation is also strictly wrong as MPOL_DEFAULT *may*
allocate on remote nodes.

> your tests haven't really shown downsides to the
> cache-over-nodes portion of it. 
> the cache-over-nodes fairness without any supporting data.
> 

It breaks MPOL_LOCAL for file-backed mappings in a manner that cannot be
overridden by policies and it is not even documented.  The same effect
could have been achieved for the repeatedly reading files by running the
processes with the MPOL_INTERLEAVE policy.  There was also no convenient
way for a user to override that behaviour. Hard-binding to a node would
work but tough luck if the process needs more than one node of memory.

What I will admit is that I doubt anyone cares that file-backed pages
are not node-local as documented as the cost of the IO itself probably
dominates but just because something does not make sense does not mean
someone is depending on the behaviour.

That alone is pretty heavy justification even in the absense of supporting
data showing a workload that depends on file pages being node-local that
is not hidden by the cost of the IO itself.

> Reverting cross-node fairness for anon and slab is a good idea.  It
> was always about cache and the original patch was too broad stroked,
> but it doesn't invalidate everything it was about.
> 

No it doesn't, but it should at least have been documented.

> I can see, however, that we might want to make this configurable, but
> I'm not eager on exporting user interfaces unless we have to.  As the
> node-local fairness was never questioned by anybody, is it necessary
> to make it configurable? 

It's only there since 3.12 and it takes a long time for people to notice
NUMA regressions, especially ones that would just be within a few percent
like this was unless they were specifically looking for it.

> Shouldn't we be okay with just a single
> vm.pagecache_interleave (name by Rik) sysctl that defaults to 1 but
> allows users to go back to pagecache obeying mempolicy?
> 

That can be done. I can put together a patch that defaults it to 0 and
sets the DISTRIBUTE_REMOTE_FILE  flag if someone writes to it. That's a
crude hack but many people will be ok with it.

To make it a default though should require more work though.
Create an MPOL_DISTRIB_PAGECACHE memory policy (name because it
is not strictly interleave). Abstract MPOL_DEFAULT to be either
MPOL_LOCAL or MPOL_DISTRIB_PAGECACHE depending on the value of
vm.pagecache_interleave. Update manual pages, and Documentation/ then set
the default of vm.pagecache_interleave to 1.

That would allow more sane defaults and also allow users to override it
on a per task and per VMA basis as they can for any other type of memory
policy.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
