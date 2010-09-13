Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF626B0100
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 06:08:15 -0400 (EDT)
Date: Mon, 13 Sep 2010 11:07:59 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/10] writeback: Do not congestion sleep if there are
	no congested BDIs or significant writeback
Message-ID: <20100913100759.GE23508@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie> <1283770053-18833-4-git-send-email-mel@csn.ul.ie> <20100907152533.GB4620@barrios-desktop> <20100908110403.GB29263@csn.ul.ie> <20100908145245.GG4620@barrios-desktop> <20100909085436.GJ29263@csn.ul.ie> <20100912153744.GA3563@barrios-desktop> <20100913085549.GA23508@csn.ul.ie> <AANLkTimkSU5G1qO0JDp8An5ofM2BPoPY0SGUOuTvSuOL@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <AANLkTimkSU5G1qO0JDp8An5ofM2BPoPY0SGUOuTvSuOL@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 06:48:10PM +0900, Minchan Kim wrote:
> >> > > > <SNIP>
> >> > > > I'm not saying it is. The objective is to identify a situation where
> >> > > > sleeping until the next write or congestion clears is pointless. We have
> >> > > > already identified that we are not congested so the question is "are we
> >> > > > writing a lot at the moment?". The assumption is that if there is a lot
> >> > > > of writing going on, we might as well sleep until one completes rather
> >> > > > than reclaiming more.
> >> > > >
> >> > > > This is the first effort at identifying pointless sleeps. Better ones
> >> > > > might be identified in the future but that shouldn't stop us making a
> >> > > > semi-sensible decision now.
> >> > >
> >> > > nr_bdi_congested is no problem since we have used it for a long time.
> >> > > But you added new rule about writeback.
> >> > >
> >> >
> >> > Yes, I'm trying to add a new rule about throttling in the page allocator
> >> > and from vmscan. As you can see from the results in the leader, we are
> >> > currently sleeping more than we need to.
> >>
> >> I can see the about avoiding congestion_wait but can't find about
> >> (writeback < incative / 2) hueristic result.
> >>
> >
> > See the leader and each of the report sections entitled
> > "FTrace Reclaim Statistics: congestion_wait". It provides a measure of
> > how sleep times are affected.
> >
> > "congest waited" are waits due to calling congestion_wait. "conditional waited"
> > are those related to wait_iff_congested(). As you will see from the reports,
> > sleep times are reduced overall while callers of wait_iff_congested() still
> > go to sleep. The reports entitled "FTrace Reclaim Statistics: vmscan" show
> > how reclaim is behaving and indicators so far are that reclaim is not hurt
> > by introducing wait_iff_congested().
> 
> I saw  the result.
> It was a result about effectiveness _both_ nr_bdi_congested and
> (writeback < inactive/2).
> What I mean is just effectiveness (writeback < inactive/2) _alone_.

I didn't measured it because such a change means that wait_iff_congested()
ignored BDI congestion. If we were reclaiming on a NUMA machine for example,
it could mean that a BDI gets flooded with requests if we only checked the
ratios of one zone if little writeback was happening in that zone at the
time. It did not seem like a good idea to ignore congestion.

> If we remove (writeback < inactive / 2) check and unconditionally
> return, how does the behavior changed?
> 

Based on just the workload Johannes sent, scanning and completion times both
increased without any improvement in the scanning/reclaim ratio (a bad result)
hence why this logic was introduced to back off where there is some
writeback taking place even if the BDI is not congested.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
