Date: Thu, 12 Jul 2007 22:32:41 +0100
Subject: Re: -mm merge plans -- anti-fragmentation
Message-ID: <20070712213241.GA7279@skynet.ie>
References: <20070710102043.GA20303@skynet.ie> <20070712122925.192a6601.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070712122925.192a6601.akpm@linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@suse.de, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (12/07/07 12:29), Andrew Morton didst pronounce:
> On Tue, 10 Jul 2007 11:20:43 +0100
> mel@skynet.ie (Mel Gorman) wrote:
> 
> > > create-the-zone_movable-zone.patch
> > > allow-huge-page-allocations-to-use-gfp_high_movable.patch
> > > handle-kernelcore=-generic.patch
> > > 
> > >  Mel's moveable-zone work.  In a similar situation.  We need to stop whatever
> > >  we're doing and get down and work out what we're going to do with all this
> > >  stuff.
> > > 
> > 
> > Whatever about grouping pages by mobility, I would like to see these go
> > through. They have a real application for hugetlb pool resizing where the
> > administrator knows the range of hugepages that will be required but doesn't
> > want to waste memory when the required number of hugepages is small. I've
> > cc'd Kenneth Chen as I believe he has run into this problem recently where
> > I believe partitioning memory would have helped. He'll either confirm or deny.
> 
> Still no decision here, really.
> 
> Should we at least go for
> 
> add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated.patch
> create-the-zone_movable-zone.patch
> allow-huge-page-allocations-to-use-gfp_high_movable.patch
> handle-kernelcore=-generic.patch
> 
> in 2.6.23?

Well, yes please from me obviously :) . There is one additional patch
I would like to send on tomorrow and that is providing the movablecore=
switch as well as kernelcore=. This is based on Nick's feedback where he
felt the configuration item might be not be the ideal in all situations -
Yasunori Goto agreed with him. I've posted a candidate patch and Andy had
a minor problem with it that I will correct.

While I would of course like grouping pages by mobility to go in as well,
I recognise that it probably needs a resubmission to -mm so people can take
another look in the next cycle.

On the positive side with just these patches, they gain us a few things;

1. A zone where the huge page pool can likely grow to at runtime. On
batch systems between jobs, the next job owner could grow the pool to
the size of ZONE_MOVABLE with reasonable reliability. This means an
administrator can set the zone to be a given size and let users decide
for themselves what size the hugepage pool will be. This gives us a
fairly reliable pool without the downside of wasting memory. Talking
to Kenneth Chen at OLS led me to believe that this would be a useful
feature in real world situations. He's been quite at the moment so
hopefully this will nudge him into saying something.

2. It does help the memory unplug case to some extent. The page
isolation code in that patchset does depend on grouping pages by
mobility but I could cut down grouping pages by mobility to *just* the
parts they need as a starting point

3. In contrast to grouping pages by mobility, you know well in advance how
many hugepages are likely to be allocated. The success rates of grouping
pages by mobility on it's own is workload dependant.

4. The zone is lower risk than grouping pages by mobility. It's less
complicated, the complexity is at the side and the code at runtime is the
same as todays.

So it's lower risk than grouping pages by mobility, has predictable behaviour
and helps some cases.  As Nick points out as well, we can see how far we can
get with just this reserve zone without taking the full plunge with grouping
pages by mobility.

Hopefully other people will throw their 2 cents in here too.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
