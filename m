Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070830185053.22619.96398.sendpatchset@localhost>
References: <20070830185053.22619.96398.sendpatchset@localhost>
Content-Type: text/plain
Date: Tue, 11 Sep 2007 12:20:56 -0400
Message-Id: <1189527657.5036.35.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, solo@google.com, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Andi, Christoph, Mel [added to cc]:

Any comments on these patches, posted 30aug?  I've rebased to
23-rc4-mm1, but before reposting, I wanted to give you a chance to
comment.

I'm going to add Mel's "one zonelist" series to my mempolicy tree with
these patches and see how that goes.  I'll slide Mel's patches in below
these, as it looks like they're closer to acceptance into -mm.

Ethan:  I believe that patch #4 provides the cpuset independent
interleave capability that you were looking for.  Does this meet your
requirements?

Regards,
Lee



On Thu, 2007-08-30 at 14:50 -0400, Lee Schermerhorn wrote:
> Some of these patches have been previously posted for comment
> individually.  The patches also update the numa_memory_policy
> document where applicable.  Needed man page updates are flagged.
> I will provide the needed updates for any of the patches that
> are accepted.
> 
> Cleanups:
> 
> 1) Fix reference counting for shared, vma and other task's
>    mempolicies.  This was discussed back in late June'07, but
>    never went anywhere.  Closes possible races and fixes potential
>    memory leak for shared policies.  Adds code to allocation paths.
> 
>    Patch does NOT update numa_memory_policy doc--the doc doesn't
>    go into that much detail regarding design.  Perhaps it should.
> 
> 2) use MPOL_PREFERRED with preferred_node = -1 for system default
>    local allocation.  This removes all usage of MPOL_DEFAULT in
>    in-kernel struct mempolicy 'policy' members.  MPOL_DEFAULT is
>    now an API-only value that requests fall back to the default
>    policy for the target context [task or vma/shared policy].  This
>    simplifies the description of policies and removes some runtime
>    tests in the page allocation paths.
> 
>    Needs man page update to clarify meaning of MPOL_DEFAULT with 
>    this patch.  Should simplify things a bit.
> 
> 2) cleanup MPOL_PREFERRED "local allocation" handling -- i.e., when
>    preferred_node == -1.
> 
>    Needs man page update to clarify returned nodemask when
>    MPOL_PERFERRED policy specifies local allocation.
> 
> Enhancements:
> 
> 4) cpuset-independent [a.k.a. "contextual"] interleave policy:  NULL
>    or empty nodemask to mempolicy API [set_mempolicy() and mbind()]
>    now means "interleave over all permitted nodes in allocation 
>    context".
> 
>    Needs man page update to describe contextual interleave--how to
>    specify, behavior, ...
> 
> 5) add MPOL_F_MEMS_ALLOWED flag for get_mempolicy().  Allows an
>    application to query the valid nodes to avoid EINVAL errors when
>    attempting to install memory policies from within a memory
>    constrained cpuset.
> 
>    Needs man page update to describe flag, behavior.
>    Could also use libnuma update -- e.g., new numa_mems_allowed()
> 
> Testing:
> 
> I've run with these patches for the past few weeks.  Some moderate
> stress testing and functional testing on an ia64 NUMA platform, shows
> no issues nor regression.  memtoy >= 0.13 supports MPOL_F_MEMS_ALLOWED
> flag [mems command].
> 
> Some of the patches [ref count fix, contextual interneavel] do add
> code in some of the allocation paths.  I hope to get some time in
> the next month on a terabyte system [~64 million 16KB pages] to
> measure the overhead of these patches allocating and migrating a few
> million pages to expose any increased overhead.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
