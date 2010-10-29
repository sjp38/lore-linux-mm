Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C8BB78D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 10:58:29 -0400 (EDT)
Date: Fri, 29 Oct 2010 09:58:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
 threshold when memory is low
In-Reply-To: <20101028150433.fe4f2d77.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1010290955510.20370@router.home>
References: <1288278816-32667-1-git-send-email-mel@csn.ul.ie> <1288278816-32667-2-git-send-email-mel@csn.ul.ie> <20101028150433.fe4f2d77.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Oct 2010, Andrew Morton wrote:

> > To ensure that kswapd wakes up, a safe version of zone_watermark_ok()
> > is introduced that takes a more accurate reading of NR_FREE_PAGES when
> > called from wakeup_kswapd, when deciding whether it is really safe to go
> > back to sleep in sleeping_prematurely() and when deciding if a zone is
> > really balanced or not in balance_pgdat(). We are still using an expensive
> > function but limiting how often it is called.
>
> Here I go again.  I have a feeling that I already said this, but I
> can't find versions 2 or 3 in the archives..
>
> Did you evaluate using plain on percpu_counters for this?  They won't
> solve the performance problem as they're basically the same thing as
> these open-coded counters.  But they'd reduce the amount of noise and
> custom-coded boilerplate in mm/.

The zone counters are done using the ZVCs in vmstat.c to save space and to
be in the same cacheline as other hot data necessary for allocation and
free.
 >
> > +	threshold = max(1, (int)(watermark_distance / num_online_cpus()));
> > +
> > +	/*
> > +	 * Maximum threshold is 125
>
> Reasoning?

Differentials are stored in 8 bit signed ints.

> > +	put_online_cpus();
> > +}
>
> Given that ->stat_threshold is the same for each CPU, why store it for
> each CPU at all?  Why not put it in the zone and eliminate the inner
> loop?

Doing that caused cache misses in the past and reduced the performance of
the ZVCs. This way the threshold is in the same cacheline as the
differentials.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
