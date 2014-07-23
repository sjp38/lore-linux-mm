Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 918F36B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 18:57:10 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so2615383pac.17
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 15:57:10 -0700 (PDT)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id o15si1989326pdl.182.2014.07.23.15.57.09
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 15:57:09 -0700 (PDT)
Date: Wed, 23 Jul 2014 17:57:42 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [BUG] THP allocations escape cpuset when defrag is off
Message-ID: <20140723225742.GU8578@sgi.com>
References: <20140723220538.GT8578@sgi.com>
 <alpine.DEB.2.02.1407231516570.23495@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407231516570.23495@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, kirill.shutemov@linux.intel.com, mingo@kernel.org, hughd@google.com, lliubbo@gmail.com, hannes@cmpxchg.org, srivatsa.bhat@linux.vnet.ibm.com, dave.hansen@linux.intel.com, dfults@sgi.com, hedi@sgi.com

On Wed, Jul 23, 2014 at 03:28:09PM -0700, David Rientjes wrote:
> > My debug code shows that certain code paths are still allowing
> > ALLOC_CPUSET to get pulled off the alloc_flags with the patch, but
> > monitoring the memory usage shows that we're staying on node, aside from
> > some very small allocations, which may be other types of allocations that
> > are not necessarly confined to a cpuset.  Need a bit more research to
> > confirm that.
> > 
> 
> ALLOC_CPUSET should get stripped for the cases outlined in 
> __cpuset_node_allowed_softwall(), specifically for GFP_ATOMIC which does 
> not have __GFP_WAIT set.

Makes sense.  I knew my patch was probably the wrong way to fix this,
but it did serve my purpose :)

> > So, my question ends up being, why do we wipe out ___GFP_WAIT when
> > defrag is off?  I'll trust that there is good reason to do that, but, if
> > so, is the behavior that I'm seeing expected?
> > 
> 
> The intention is to avoid memory compaction (and direct reclaim), 
> obviously, which does not run when __GFP_WAIT is not set.  But you're 
> exactly right that this abuses the allocflags conversion that allows 
> ALLOC_CPUSET to get cleared because it is using the aforementioned 
> GFP_ATOMIC exception for cpuset allocation.
>
> We can't use PF_MEMALLOC or TIF_MEMDIE for hugepage allocation because it 
> affects the allowed watermarks and nothing else prevents memory compaction 
> or direct reclaim from running in the page allocator slowpath.
> 
> So it looks like a modification to the page allocator is needed, see 
> below.

Looks good to me.  Fixes the problem without affecting any of the other
intended functionality.

> It's also been a long-standing issue that cpusets and mempolicies are 
> ignored by khugepaged that allows memory to be migrated remotely to nodes 
> that are not allowed by a cpuset's mems or a mempolicy's nodemask.  Even 
> with this issue fixed, you may find that some memory is migrated remotely, 
> although it may be negligible, by khugepaged.

A bit here and there is manageable.  There is, of course, some work to
be done there, but for now we're mainly concerned with a job that's
supposed to be confined to a cpuset spilling out and soaking up all the
memory on a machine.

Thanks for the help, David.  Much appreciated!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
