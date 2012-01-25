Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 5F0536B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 17:17:03 -0500 (EST)
Date: Wed, 25 Jan 2012 23:16:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2 -mm 1/3] mm: reclaim at order 0 when compaction is
 enabled
Message-ID: <20120125221632.GL30782@redhat.com>
References: <20120124131822.4dc03524@annuminas.surriel.com>
 <20120124132136.3b765f0c@annuminas.surriel.com>
 <20120125150016.GB3901@csn.ul.ie>
 <4F201F60.8080808@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F201F60.8080808@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On Wed, Jan 25, 2012 at 10:27:28AM -0500, Rik van Riel wrote:
> On 01/25/2012 10:00 AM, Mel Gorman wrote:
> > On Tue, Jan 24, 2012 at 01:21:36PM -0500, Rik van Riel wrote:
> >> When built with CONFIG_COMPACTION, kswapd does not try to free
> >> contiguous pages.
> >
> > balance_pgdat() gets its order from wakeup_kswapd(). This does not apply
> > to THP because kswapd does not get woken for THP but it should be woken
> > up for allocations like jumbo frames or order-1.
> 
> In the kernel I run at home, I wake up kswapd for THP
> as well. This is a larger change, which Andrea asked
> me to delay submitting upstream for a bit.
> 
> So far there seem to be no ill effects. I'll continue
> watching for them.

The only problem we had last time when we managed to add compaction in
kswapd upstream, was a problem of that too high kswapd wakeup
frequency that kept kswapd spinning at 100% load and destroying
specsfs performance. It may have been a fundamental problem of
compaction not being worthwhile to run to generate jumbo frames
because the cost of migrating memory, copying, flushing ptes, is
significantly higher than the benefit of doing the network DMA in
larger chunks and saving a few interrupts. This is why the logic need
to be tested with specsfs on nfs and stuff that triggers jumbo frames
heavily and does an huge network traffic.

About THP, it may not give problems for THP because the allocation
rate is much slower.

OTOH THP pages are bigger so that would make life harder for
compaction than for the smaller order requested by the jumbo
frames.

The main reason why THP don't strictly need this, is that all these
allocations can block and so THP can run compaction in direct reclaim.
The jumbo frames can't wait instead so they absolutely need kswapd if
we ever intend them to benefit from compaction.

I think the idea is sound, we just need to know if maybe we need to
enable it selectively and tell jumbo frames to use
__GFP_NO_KSWAPD_COMPACTION or something to only disable compaction but
to still free memory as we'll fallback with a 4k allocation in the nic
driver. (but if we'd need that, that would question if this is
worthwhile as they were the ones intended to benefit, most other
order > 0 allocations don't run in atomic context)

I'm still quite afraid that compaction in kswapd waken by jumbo frames
may not work well, but I'm happy that you try this again to be sure of
what's the best direction to take, there wasn't enough time to
investigate this properly last time, so we quickly backed it out to be
safe. Just running specsfs on nfs with a nic using jumbo frames is
enough to tell if this works or not, so good thing is there's no risk
of regression if that thing works fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
