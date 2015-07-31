Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id AF3646B0256
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 04:41:09 -0400 (EDT)
Received: by wicgj17 with SMTP id gj17so7640633wic.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 01:41:09 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id d7si6819260wjf.36.2015.07.31.01.41.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 01:41:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 2B4D098D0E
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:41:07 +0000 (UTC)
Date: Fri, 31 Jul 2015 09:41:04 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 09/10] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
Message-ID: <20150731084104.GE5840@techsingularity.net>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-10-git-send-email-mgorman@suse.com>
 <20150731055407.GA15912@js1304-P5Q-DELUXE>
 <20150731071113.GA5840@techsingularity.net>
 <20150731082641.GA16553@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150731082641.GA16553@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 31, 2015 at 05:26:41PM +0900, Joonsoo Kim wrote:
> On Fri, Jul 31, 2015 at 08:11:13AM +0100, Mel Gorman wrote:
> > On Fri, Jul 31, 2015 at 02:54:07PM +0900, Joonsoo Kim wrote:
> > > Hello, Mel.
> > > 
> > > On Mon, Jul 20, 2015 at 09:00:18AM +0100, Mel Gorman wrote:
> > > > From: Mel Gorman <mgorman@suse.de>
> > > > 
> > > > High-order watermark checking exists for two reasons --  kswapd high-order
> > > > awareness and protection for high-order atomic requests. Historically we
> > > > depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order free
> > > > pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
> > > > that reserves pageblocks for high-order atomic allocations. This is expected
> > > > to be more reliable than MIGRATE_RESERVE was.
> > > 
> > > I have some concerns on this patch.
> > > 
> > > 1) This patch breaks intention of __GFP_WAIT.
> > > __GFP_WAIT is used when we want to succeed allocation even if we need
> > > to do some reclaim/compaction work. That implies importance of
> > > allocation success. But, reserved pageblock for MIGRATE_HIGHATOMIC makes
> > > atomic allocation (~__GFP_WAIT) more successful than allocation with
> > > __GFP_WAIT in many situation. It breaks basic assumption of gfp flags
> > > and doesn't make any sense.
> > > 
> > 
> > Currently allocation requests that do not specify __GFP_WAIT get the
> > ALLOC_HARDER flag which allows them to dip further into watermark reserves.
> > It already is the case that there are corner cases where a high atomic
> > allocation can succeed when a non-atomic allocation would reclaim.
> 
> I know that. It's matter of magnitute. If your patch is applied,
> GFP_ATOMIC almost succeed and there is no merit to use GFP_WAIT.

Yes there is. If the reserves are too high then it will unnecessarily push
order-0 allocations into reclaim. The use for atomic should be just
that, atomic.

> If user can easily bypass big overhead from reclaim/compaction through
> GFP_ATOMIC allocation, they will decide to use GFP_ATOMIC flag rather than
> adding GFP_WAIT.
> 

They overhead cannot be avoided, they simply hit failure instead. If the
degree of magnitude is a problem then I can drop the reseserves from 10%
to 1% so it's closer to what MIGRATE_RESERVE does today.

> > 
> > > 2) Who care about success of high-order atomic allocation with this
> > > reliability?
> > 
> > Historically network configurations with large MTUs that could not scatter
> > gather. These days network will also attempt atomic order-3 allocations
> > to reduce overhead. SLUB also attempts atomic high-order allocations to
> > reduce overhead. It's why MIGRATE_RESERVE exists at all so the intent of
> > the patch is to preserve what MIGRATE_RESERVE was for but do it better.
> 
> Normally, SLUB doesn't rely on success of high-order allocation. So,
> don't need to such reliability. It can fallback to low-order allocation.
> Moreover, we can get such benefit of high-order allocation by using
> kcompactd as suggested by Vlastimil soon.
> 

Then dropping maximum reserves to 1%. Or replicate what MIGRATE_RESERVE
does and limit it to 2 pageblocks per zone.

> > > In case of allocation without __GFP_WAIT, requestor preare sufficient
> > > fallback method. They just want to success if it is easily successful.
> > > They don't want to succeed allocation with paying great cost that slow
> > > down general workload by this patch that can be accidentally reserve
> > > too much memory.
> > > 
> > 
> > Not necessary true. In the historical case, the network request was atomic
> > because it was from IRQ context and could not sleep.
> 
> If some of atomic high-order allocation requestor rely on success of
> atomic high-order allocation, they should be changed as reserving how
> much they need. Not, here MM. MM can't do anything if allocation is
> requested in IRQ context. Reserving a lot of memory to guarantee
> them doesn't make sense. And, I don't see any recent claim to guarantee such
> allocation more reliable.
> 

Ok, will limit to 2 pageblocks per zone on the next revision.

> > > > A MIGRATE_HIGHORDER pageblock is created when an allocation request steals
> > > > a pageblock but limits the total number to 10% of the zone.
> > > 
> > > When steals happens, pageblock already can be fragmented and we can't
> > > fully utilize this pageblock without allowing order-0 allocation. This
> > > is very waste.
> > > 
> > 
> > If the pageblock was stolen, it implies there was at least 1 usable page
> > of the correct order. As the pageblock is then reserved, any pages that
> > free in that block stay free for use by high-order atomic allocations.
> > Else, the number of pageblocks will increase again until the 10% limit
> > is hit.
> 
> It really depends on luck.
> 

Success of high-order allocations *always* depended on the allocation/free
request stream. The series does not change that.

> > > > The pageblocks are unreserved if an allocation fails after a direct
> > > > reclaim attempt.
> > > > 
> > > > The watermark checks account for the reserved pageblocks when the allocation
> > > > request is not a high-order atomic allocation.
> > > > 
> > > > The stutter benchmark was used to evaluate this but while it was running
> > > > there was a systemtap script that randomly allocated between 1 and 1G worth
> > > > of order-3 pages using GFP_ATOMIC. In kernel 4.2-rc1 running this workload
> > > > on a single-node machine there were 339574 allocation failures. With this
> > > > patch applied there were 28798 failures -- a 92% reduction. On a 4-node
> > > > machine, allocation failures went from 76917 to 0 failures.
> > > 
> > > There is some missing information to justify benchmark result.
> > > Especially, I'd like to know:
> > > 
> > > 1) Detailed system setup (CPU, MEMORY, etc...)
> > 
> > CPUs were 8 core Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz with 8G of RAM.
> > 
> > > 2) Total number of attempt of GFP_ATOMIC allocation request
> > > 
> > 
> > Each attempt was between 1 and 1G randomly as described already.
> 
> So, number of attempt was randomly choosen, but, number of failure is static.
> Please describe same level of statistics. Am I missing something?
> 

I reported the number of failures relative to the number of successful
attempts. Reporting in greater detail would not help in any way because
it'd be for one specific case. The experiences for other workloads will
always be different. I'll put it another way -- what would you consider
to be a meaningful test? Obviously you have something in mind.

The intent of what I did was to create a workload that is known to cause
fragmentation and combine it with an unreasonable stream of atomic
high-order allocations to stress the worst-case. The average case is
unknowable because it depends on the workload and the requirements of
the hardware.

> > > I don't know how you modify stutter benchmark in mmtests but it
> > > looks like there is no delay when continually requesting GFP_ATOMIC
> > > allocation.
> > > 1G of order-3 allocation request without delay seems insane
> > > to me. Could you tell me how you modify that benchmark for this patch?
> > > 
> > 
> > The stutter benchmark was not modified. The watch-stress-highorder-atomic
> > monitor was run in parallel and that's what is doing the allocation. It's
> > true that up to 1G of order-3 allocations without delay would be insane
> > in a normal situation. The point was to show an extreme case where atomic
> > allocations were used and to test whether the reserves held up or not.
> 
> You may change MAX_BURST in stap script to certain value that 1G
> successive attemtps is possible. 1G of order-3 atomic allocation
> without delay isn't really helpful benchmark, because it really doesn't
> reflect any real world situation. Even if extreme case, it should
> reflect real world situation at some point.
> 

I did not claim it was a real world situation. It was the exteme case.

> If number of successive attemtps is back to the realistic value, such
> large failure happens?
> 

It entirely depends on what you mean by realistic. The requirements of
embedded are entirely different to a standard server. This is why I
evaluated a potential worse-case scenario -- massive storms of atomic
high-order allocations.

> > > > There are minor theoritical side-effects. If the system is intensively
> > > > making large numbers of long-lived high-order atomic allocations then
> > > > there will be a lot of reserved pageblocks. This may push some workloads
> > > > into reclaim until the number of reserved pageblocks is reduced again. This
> > > > problem was not observed in reclaim intensive workloads but such workloads
> > > > are also not atomic high-order intensive.
> > > 
> > > I don't think this is theoritical side-effects. It can happen easily.
> > > Recently, network subsystem makes some of their high-order allocation
> > > request ~_GFP_WAIT (fb05e7a89f50: net: don't wait for order-3 page
> > > allocation). And, I've submitted similar patch for slub today
> > > (mm/slub: don't wait for high-order page allocation). That
> > > makes system atomic high-order allocation request more and this side-effect
> > > can be possible in many situation.
> > > 
> > 
> > The key is long-lived allocations. The network subsystem frees theirs. I
> > was not able to trigger a situation in a variety of workloads where these
> > happened which is why I classified it as theoritical.
> 
> SLUB allocation would be long-lived.
> 

Will drop reserves to 2 pageblocks per zone so.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
