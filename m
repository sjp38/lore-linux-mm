Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 13F7E6B0069
	for <linux-mm@kvack.org>; Thu,  3 Nov 2011 11:52:35 -0400 (EDT)
Date: Thu, 3 Nov 2011 16:51:27 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [rfc 1/3] mm: vmscan: never swap under low memory pressure
Message-ID: <20111103155127.GM19965@redhat.com>
References: <20110808110658.31053.55013.stgit@localhost6>
 <CAOJsxLF909NRC2r6RL+hm1ARve+3mA6UM_CY9epJaauyqJTG8w@mail.gmail.com>
 <4E3FD403.6000400@parallels.com>
 <20111102163056.GG19965@redhat.com>
 <20111102163141.GH19965@redhat.com>
 <4EB183CF.6050300@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EB183CF.6050300@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: khlebnikov@parallels.com, penberg@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, riel@redhat.com, mel@csn.ul.ie, minchan.kim@gmail.com, gene.heskett@gmail.com

On Wed, Nov 02, 2011 at 10:54:23AM -0700, KOSAKI Motohiro wrote:
> > ---
> >  mm/vmscan.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index a90c603..39d3da3 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -831,6 +831,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  		 * Try to allocate it some swap space here.l
> >  		 */
> >  		if (PageAnon(page) && !PageSwapCache(page)) {
> > +			if (priority >= DEF_PRIORITY - 2)
> > +				goto keep_locked;
> >  			if (!(sc->gfp_mask & __GFP_IO))
> >  				goto keep_locked;
> >  			if (!add_to_swap(page))
> 
> Hehe, i tried very similar way very long time ago. Unfortunately, it doesn't work.
> "DEF_PRIORITY - 2" is really poor indicator for reclaim pressure. example, if the
> machine have 1TB memory, DEF_PRIORITY-2 mean 1TB>>10 = 1GB. It't too big.

Do you remember what kind of tests you ran that demonstrated
misbehaviour?

We can not reclaim anonymous pages without swapping, so the priority
cutoff applies only to inactive file pages.  If you had 1TB of
inactive file pages, the scanner would have to go through

	((1 << (40 - 12)) >> 12) +
	((1 << (40 - 12)) >> 11) +
	((1 << (40 - 12)) >> 10) = 1792MB

without reclaiming SWAP_CLUSTER_MAX before it considers swapping.
That's a lot of scanning but how likely is it that you have a TB of
unreclaimable inactive cache pages?

Put into proportion, with a priority threshold of 10 a reclaimer will
look at 0.17% ((n >> 12) + (n >> 11) + (n >> 10) (excluding the list
balance bias) of inactive file pages without reclaiming
SWAP_CLUSTER_MAX before it considers swapping.

Currently, the list balance biasing with each newly-added file page
has much higher resistance to scan anonymous pages initially.  But
once it shifted toward anon pages, all reclaimers will start swapping,
unlike the priority threshold that each reclaimer has to reach
individually.  Could this have been what was causing problems for you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
