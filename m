Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9E0D66B0089
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 14:04:09 -0400 (EDT)
Date: Wed, 27 Oct 2010 20:03:33 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/7] vmscan: narrowing synchrounous lumply reclaim
 condition
Message-ID: <20101027180333.GE29304@random.random>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
 <20100805151341.31C3.A69D9226@jp.fujitsu.com>
 <20101027164138.GD29304@random.random>
 <20101027171643.GA4896@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101027171643.GA4896@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Wed, Oct 27, 2010 at 06:16:43PM +0100, Mel Gorman wrote:
> The series drastically limits the level of hammering lumpy does to the
> system. I'm currently keeping it alive because lumpy reclaim has received a lot
> more testing than compaction has. While I ultimately see it going away, I am
> resisting it being deleted until compaction has been around for a few releases.

I admit I didn't yet test this modification yet to verify how
"drastical" is the drastical change. But "less unusable lumpy" I doubt
will translate to "as usable as without lumpy". And I doubt lumpy will
ever lead to something "usable" when order 9 allocations are the norm
and more frequent than order 0 allocations.

> Simply because it has been tested and even with compaction there were cases
> envisoned where it would be used - low memory or when compaction is not
> configured in for example. The ideal is that compaction is used until lumpy

Compaction should always be configured in. All archs supports
migration. Only reason to disable compaction is for debugging
purposes, and should go in kernel hacking section. Or alternatively if
it's not important that order >0 allocation succeeds (some embedded
may be in that lucky situation and they can save some bytecode).

Keeping lumpy in and activated for all high order allocations like
this, can only _hide_ bugs and inefficiencies in compaction in my view
so in addition to damaging the runtime, it fragment userbase and
debuggability and I see zero good out of lumpy for all normal
allocations.

> is necessary although this applies more to the static resizing of the huge
> page pool than THP which I'd expect to backoff without using lumpy reclaim
> i.e. fail the allocation rather than using lumpy reclaim.

I agree lumpy is more drastic and aggressive than reclaim and it may
be quicker to generate hugepages by throwing its blind hammer, in turn
destroying everything else running and hanging the system for a long
while. I wouldn't be so against lumpy if it was only activated by a
special __GFP_LUMPY flag that only hugetlbfs pool resizing uses.
hugetlbfs is the very special case, not all other normal
allocations.

> Uhhh, I have one more modification in mind when lumpy is involved and
> it's to relax the zone watermark slightly to only obey up to
> PAGE_ALLOC_COSTLY_ORDER. At the moment, it is freeing more pages than
> are necessary to satisfy an allocation request and hits the system
> harder than it should. Similar logic should apply to compaction.

On a side note I want to remove the PAGE_ALLOC_COSTLY_ORDER too, that
is a flawed concept in the first place. A VM that behaves radically
(radically as in grinding system to an halt and being unusable and
creating swap storms) different when the order of allocation raises
from 3 to 4 is hackish and fundamentally incompatible with logics that
uses frequent order 9 allocations and makes them the default.

Basically anybody asking an order 9 during the normal runtime (not
some magic sysfs control) has to be ok if it fails and only relay on
compaction, or it's in some corner case and as such shall be threated
instead of mandating the default VM behavior for >=4 order allocation
for everything else.

The PAGE_ALLOC_COSTLY_ORDER was in practice a not stack-local
per-process equivalent of what I recommended as the way to trigger
lumpy (i.e. __GFP_LUMPY), but it's not a good enough approximation
anymore. So the "activation" for
blindfolded-hammer-algorithm-creating-swap-storms has to be in
function of the caller stack, and not in function of the allocation
order. If that change is done, I won't be forced to drop lumpy
anymore! But even then I find it hard to justify to keep lumpy alive
unless it is proven to be more efficient than compaction. But I could
avoid touching the lumpy code at least.

My tree uses compaction in a fine way inside kswapd too and tons of
systems are running without lumpy and floods of order 9 allocations
with only compaction (in direct reclaim and kswapd) without the
slighest problem. Furthermore I extended compaction for all
allocations not just that PAGE_ALLOC_COSTLY_ORDER (maybe I already
removed all PAGE_ALLOC_COSTLY_ORDER checks?). There's no good reason
not to use compaction for every allocation including 1,2,3, and things
works fine this way.

For now, to fixup the reject I think I'll go ahead remove these new
lumpy changes, which also guarantees me the most tested configuration
that I'm sure works fine without having to test how "less unusable"
lumpy has become. If later I'll be asked to retain lumpy in order to
merge THP I'll simply add the __GFP_LUMPY and I'll restrict lumpy in
the sysfs tweaking corner case.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
