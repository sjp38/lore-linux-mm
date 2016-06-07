Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB63C6B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 15:56:39 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w9so146180667oia.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 12:56:39 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 15si36488452pfn.178.2016.06.07.12.56.35
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 12:56:36 -0700 (PDT)
Message-ID: <1465329394.22178.223.camel@linux.intel.com>
Subject: Re: [PATCH 10/10] mm: balance LRU lists based on relative thrashing
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 07 Jun 2016 12:56:34 -0700
In-Reply-To: <20160607162311.GG9978@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
	 <20160606194836.3624-11-hannes@cmpxchg.org>
	 <1465257023.22178.205.camel@linux.intel.com>
	 <20160607162311.GG9978@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, kernel-team@fb.com

On Tue, 2016-06-07 at 12:23 -0400, Johannes Weiner wrote:
> Hi Tim,
> 
> On Mon, Jun 06, 2016 at 04:50:23PM -0700, Tim Chen wrote:
> > 
> > On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> > > 
> > > To tell inactive from active refaults, a page flag is introduced that
> > > marks pages that have been on the active list in their lifetime. This
> > > flag is remembered in the shadow page entry on reclaim, and restored
> > > when the page refaults. It is also set on anonymous pages during
> > > swapin. When a page with that flag set is added to the LRU, the LRU
> > > balance is adjusted for the IO cost of reclaiming the thrashing list.
> > Johannes,
> > 
> > It seems like you are saying that the shadow entry is also present
> > for anonymous pages that are swapped out. A But once a page is swapped
> > out, its entry is removed from the radix tree and we won't be able
> > to store the shadow page entry as for file mapped pageA 
> > in __remove_mapping. A Or are you thinking of modifying
> > the current code to keep the radix tree entry? I may be missing something
> > so will appreciate if you can clarify.
> Sorry if this was ambiguously phrased.
> 
> You are correct, there are no shadow entries for anonymous evictions,
> only page cache evictions. All swap-ins are treated as "eligible"
> refaults and push back against cache, whereas cache only pushes
> against anon if the cache workingset is determined to fit into memory.

Thanks. That makes sense. A I wasn't sure before whether you intend
to have a re-fault distance to determine if a
faulted in anonymous page is in working set. A I see now that
you always consider it to be in working set.

> 
> That implies a fixed hierarchy where the VM always tries to fit the
> anonymous workingset into memory first and the page cache second. If
> the anonymous set is bigger than memory, the algorithm won't stop
> counting IO cost from anonymous refaults and pressuring page cache.
> 
> [ Although you can set the effective cost of these refaults to 0
> A  (swappiness = 200) and reduce effective cache to a minimum -
> A  possibly to a level where LRU rotations consume most of it.
> A  But yeah. ]
> 
> So the current code works well when we assume that cache workingsets
> might exceed memory, but anonymous workingsets don't.
> 
> For SSDs and non-DIMM pmem devices this assumption is fine, because
> nobody wants half their frequent anonymous memory accesses to be major
> faults. Anonymous workingsets will continue to target RAM size there.
> 
> Secondary memory types, which userspace can continue to map directly
> after "swap out", are a different story. That might need workingset
> estimation for anonymous pages. 

The direct mapped swap case is trickier as we need a method to gauge how often
a page was accessed in place in swap, to decide if we need to
bring it back to RAM. A The accessed bit in pte only tells
us if it has been accessed, but not the frequency.

If we simply try to mitigate IO cost, we may just have pages migrated and
accessed within the swap space, but not bring the hot ones back to RAM.

That said, this series is a very nice optimization of the balance between
anonymous and file backed page reclaim.

Thanks.

Tim

> But it would have to build on top of
> this series here. These patches are about eliminating or mitigating IO
> by swapping idle or colder anon pages when the cache is thrashing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
