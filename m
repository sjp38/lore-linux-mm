Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 033066B0254
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:51:45 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so108851912wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:51:44 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id y2si16268605wib.45.2015.09.21.03.51.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 03:51:43 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id DB5DD98FF3
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:51:42 +0000 (UTC)
Date: Mon, 21 Sep 2015 11:51:41 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 12/12] mm, page_alloc: Only enforce watermarks for
 order-0 allocations
Message-ID: <20150921105141.GB3068@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <20150824123015.GJ12432@techsingularity.net>
 <CAAmzW4NbjqOpDhNKp7POVLZyaoUJa6YU5-B9Xz2b+crkzD25+g@mail.gmail.com>
 <20150909123901.GA12432@techsingularity.net>
 <20150918065621.GC7769@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150918065621.GC7769@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 18, 2015 at 03:56:21PM +0900, Joonsoo Kim wrote:
> On Wed, Sep 09, 2015 at 01:39:01PM +0100, Mel Gorman wrote:
> > On Tue, Sep 08, 2015 at 05:26:13PM +0900, Joonsoo Kim wrote:
> > > 2015-08-24 21:30 GMT+09:00 Mel Gorman <mgorman@techsingularity.net>:
> > > > The primary purpose of watermarks is to ensure that reclaim can always
> > > > make forward progress in PF_MEMALLOC context (kswapd and direct reclaim).
> > > > These assume that order-0 allocations are all that is necessary for
> > > > forward progress.
> > > >
> > > > High-order watermarks serve a different purpose. Kswapd had no high-order
> > > > awareness before they were introduced (https://lkml.org/lkml/2004/9/5/9).
> > > > This was particularly important when there were high-order atomic requests.
> > > > The watermarks both gave kswapd awareness and made a reserve for those
> > > > atomic requests.
> > > >
> > > > There are two important side-effects of this. The most important is that
> > > > a non-atomic high-order request can fail even though free pages are available
> > > > and the order-0 watermarks are ok. The second is that high-order watermark
> > > > checks are expensive as the free list counts up to the requested order must
> > > > be examined.
> > > >
> > > > With the introduction of MIGRATE_HIGHATOMIC it is no longer necessary to
> > > > have high-order watermarks. Kswapd and compaction still need high-order
> > > > awareness which is handled by checking that at least one suitable high-order
> > > > page is free.
> > > 
> > > I still don't think that this one suitable high-order page is enough.
> > > If fragmentation happens, there would be no order-2 freepage. If kswapd
> > > prepares only 1 order-2 freepage, one of two successive process forks
> > > (AFAIK, fork in x86 and ARM require order 2 page) must go to direct reclaim
> > > to make order-2 freepage. Kswapd cannot make order-2 freepage in that
> > > short time. It causes latency to many high-order freepage requestor
> > > in fragmented situation.
> > > 
> > 
> > So what do you suggest instead? A fixed number, some other heuristic?
> > You have pushed several times now for the series to focus on the latency
> > of standard high-order allocations but again I will say that it is outside
> > the scope of this series. If you want to take steps to reduce the latency
> > of ordinary high-order allocation requests that can sleep then it should
> > be a separate series.
> 
> I don't understand why you think it should be a separate series.

Because atomic high-order allocation success and normal high-order
allocation stall latency are different problems. Atomic high-order
allocation successes are about reserves, normal high-order allocations
are about reclaim.

> I don't know exact reason why high order watermark check is
> introduced, but, based on your description, it is for high-order
> allocation request in atomic context.

Mostly yes, the initial motivation is described in the linked mail --
give kswapd high-order awareness because otherwise (higher-order && !wait)
allocations that fail would wake kswapd but it would go back to sleep.

> And, it would accidently take care
> about latency.

Except all it does is defer the problem. If kswapd frees N high-order
pages then it disrupts the system to satisfy the request, potentially
reclaiming hot pages for an allocation attempt that *may* occur that
will stall if there are N+1 allocation requests.

Kswapd reclaiming additional pages is definite system disruption and
potentially increases thrashing *now* to help an event that *might* occur
in the future.

> It is used for a long time and your patch try to remove it
> and it only takes care about success rate. That means that your patch
> could cause regression. I think that if this happens actually, it is handled
> in this patchset instead of separate series.
> 

Except it doesn't really.

Current situation
o A high-order watermark check might fail for a normal high-order
  allocation request. On failure, stall to reclaim more pages which may
  or may not succeed
o An atomic allocation may use a lower watermark but it can still fail
  even if there are free pages on the list

Patched situation

o A watermark check might fail for a normal high-order allocation
  request and cannot use one of the reserved pages. On failure, stall to
  reclaim more pages which may or may not succeed.
  Functionally, this is very similar to current behaviour
o An atomic allocation may use the reserves so if a free page exists, it
  will be used
  Functionally, this is more reliable than current behaviour as there is
  still potential for disruption

> In review of previous version, I suggested that removing watermark
> check only for higher than PAGE_ALLOC_COSTLY_ORDER.

It increases complexity for reasons that are not quantified.

> You didn't accept
> that and I still don't agree with your approach. You can show me that
> my concern is wrong via some number.
> 
> One candidate test for this is that making system fragmented and
> run hackbench which uses a lot of high-order allocation and measure
> elapsed-time.
> 

o There is no difference in normal allocation high-order success rates
  with this series appied
o With the series applied, such tests complete in approximately the same
  time
o For the tests with parallel high-order allocation requests, there was
  no significant difference in the elapsed times although success rates
  were slightly higher

Each time the full sets of tests take about 4 days to complete on this
series and so far no problems of the type you describe have been found.
If such a test case is found then there would a clear workload to
justify either having kswapd reclaiming multiple pages or apply the old
watermark scheme for lower orders.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
