Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 159866B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 16:35:19 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s7-v6so8018583pgp.3
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 13:35:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2-v6sor7709776plr.1.2018.10.05.13.35.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 13:35:17 -0700 (PDT)
Date: Fri, 5 Oct 2018 13:35:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <20181005073854.GB6931@suse.de>
Message-ID: <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
References: <20180925120326.24392-1-mhocko@kernel.org> <20180925120326.24392-2-mhocko@kernel.org> <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com> <20181005073854.GB6931@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, 5 Oct 2018, Mel Gorman wrote:

> > This causes, on average, a 13.9% access latency regression on Haswell, and 
> > the regression would likely be more severe on Naples and Rome.
> > 
> 
> That assumes that fragmentation prevents easy allocation which may very
> well be the case. While it would be great that compaction or the page
> allocator could be further improved to deal with fragmentation, it's
> outside the scope of this patch.
> 

Hi Mel,

The regression that Andrea is working on, correct me if I'm wrong, is 
heavy reclaim and swapping activity that is trying to desperately allocate 
local hugepages when the local node is fragmented based on advice provided 
by MADV_HUGEPAGE.

Why is it ever appropriate to do heavy reclaim and swap activity to 
allocate a transparent hugepage?  This is exactly what the __GFP_NORETRY 
check for high-order allocations is attempting to avoid, and it explicitly 
states that it is for thp faults.  The fact that we lost __GFP_NORERY for 
thp allocations for all settings, including the default setting, other 
than yours (setting of "always") is what I'm focusing on.  There is no 
guarantee that this activity will free an entire pageblock or that it is 
even worthwhile.

Why is thp memory ever being allocated without __GFP_NORETRY as the page 
allocator expects?

That aside, removing __GFP_THISNODE can make the fault latency much worse 
if remote notes are fragmented and/or reclaim has the inability to free 
contiguous memory, which it likely cannot.  This is where I measured over 
40% fault latency regression from Linus's tree with this patch on a 
fragmnented system where order-9 memory is neither available from node 0 
or node 1 on Haswell.

> > There exist libraries that allow the .text segment of processes to be 
> > remapped to memory backed by transparent hugepages and use MADV_HUGEPAGE 
> > to stress local compaction to defragment node local memory for hugepages 
> > at startup. 
> 
> That is taking advantage of a co-incidence of the implementation.
> MADV_HUGEPAGE is *advice* that huge pages be used, not what the locality
> is. A hint for strong locality preferences should be separate advice
> (madvise) or a separate memory policy. Doing that is outside the context
> of this patch but nothing stops you introducing such a policy or madvise,
> whichever you think would be best for the libraries to consume (I'm only
> aware of libhugetlbfs but there might be others).
> 

The behavior that MADV_HUGEPAGE specifies is certainly not clearly 
defined, unfortunately.  The way that an application writer may read it, 
as we have, is that it will make a stronger attempt at allocating a 
hugepage at fault.  This actually works quite well when the allocation 
correctly has __GFP_NORETRY, as it's supposed to, and compaction is 
MIGRATE_ASYNC.

So rather than focusing on what MADV_HUGEPAGE has meant over the past 2+ 
years of kernels that we have implemented based on, or what it meant prior 
to that, is a fundamental question of the purpose of direct reclaim and 
swap activity that had always been precluded before __GFP_NORETRY was 
removed in a thp allocation.  I don't think anybody in this thread wants 
14% remote access latency regression if we allocate remotely or 40% fault 
latency regression when remote nodes are fragmented as well.

Removing __GFP_THISNODE only helps when remote memory is not fragmented, 
otherwise it multiplies the problem as I've shown.

The numbers that you provide while using the non-default option to mimick 
MADV_HUGEPAGE mappings but also use __GFP_NORETRY makes the actual source 
of the problem quite easy to identify: there is an inconsistency in the 
thp gfp mask and the page allocator implementation.

> > The cost, including the statistics Mel gathered, is 
> > acceptable for these processes: they are not concerned with startup cost, 
> > they are concerned only with optimal access latency while they are 
> > running.
> > 
> 
> Then such applications at startup have the option of setting
> zone_reclaim_mode during initialisation assuming a privileged helper
> can be created. That would be somewhat heavy handed and a longer-term
> solution would still be to create a proper memory policy of madvise flag
> for those libraries.
> 

We *never* want to use zone_reclaim_mode for these allocations, that would 
be even worse, we do not want to reclaim because we have a very unlikely 
chance of making pageblocks free without the involvement of compaction.  
We want to trigger memory compaction with a well-bounded cost that 
MIGRATE_ASYNC provides and then fail.
