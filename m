Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F0C2D6B0089
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 01:59:50 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id oB76xiDg017528
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 12:29:44 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB76xVU43186840
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 12:29:31 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB76xUJW004550
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 17:59:31 +1100
Date: Tue, 7 Dec 2010 12:29:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-ID: <20101207065929.GJ3158@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
 <1291099785-5433-2-git-send-email-yinghan@google.com>
 <20101130160838.4c66febf.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTikXzSx3Sjqb1NYZB-EJ76N-UbmiwTo=eOtSOnaP@mail.gmail.com>
 <20101130172710.38de418b.kamezawa.hiroyu@jp.fujitsu.com>
 <20101130175443.f01f4d09.kamezawa.hiroyu@jp.fujitsu.com>
 <20101207061503.GH3158@balbir.in.ibm.com>
 <20101207152423.1ba94270.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101207152423.1ba94270.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Ying Han <yinghan@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-12-07 15:24:23]:

> On Tue, 7 Dec 2010 11:45:03 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-11-30 17:54:43]:
> > 
> > > On Tue, 30 Nov 2010 17:27:10 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > On Tue, 30 Nov 2010 17:15:37 +0900
> > > > Minchan Kim <minchan.kim@gmail.com> wrote:
> > > > 
> > > > > Ideally, I hope we unify global and memcg of kswapd for easy
> > > > > maintainance if it's not a big problem.
> > > > > When we make patches about lru pages, we always have to consider what
> > > > > I should do for memcg.
> > > > > And when we review patches, we also should consider what the patch is
> > > > > missing for memcg.
> > > > > It makes maintainance cost big. Of course, if memcg maintainers is
> > > > > involved with all patches, it's no problem as it is.
> > > > > 
> > > > I know it's not. But thread control of kswapd will not have much merging point.
> > > > And balance_pgdat() is fully replaced in patch/3. The effort for merging seems
> > > > not big.
> > > > 
> > > 
> > > kswapd's balance_pgdat() is for following
> > >   - reclaim pages within a node.
> > >   - balancing zones in a pgdat.
> > > 
> > > memcg's background reclaim needs followings.
> > >   - reclaim pages within a memcg
> > >   - reclaim pages from arbitrary zones, if it's fair, it's good.
> > >     But it's not important from which zone the pages are reclaimed from. 
> > >     (I'm not sure we can select "the oldest" pages from divided LRU.)
> > >
> > 
> > Yes, if it is fair, then we don't break what kswapd tries to do, so
> > fairness is quite important, in that we don't leaves zones unbalanced
> > (at least by very much) as we try to do background reclaim. But
> > sometimes it cannot be helped, specially if there are policies that
> > bias the allocation.
> >  
> > > Then, merging will put 2 _very_ different functionalities into 1 function.
> > > 
> > > So, I thought it's simpler to implement
> > > 
> > >  1. a victim node selector (This algorithm will never be in kswapd.)
> > 
> > A victim node selector per memcg? Could you clarify the context of
> > node here?
> > 
> An argument to balance_pgdat_for_memcg() or a start point of zonelist[].
> i.e.
> 	zone_list = NODE_DATA(victim)->zonelist[0 or 1]
> 
> 	for_each_zone_zonelist(z, zone_list)....
> 
> But, this is just an example, we just need to determine where we reclaim
> page from before start walking.
>

OK, I understand. BTW, I am not against integration with kswapd for
watermark based reclaim, the advantage I see is that as we balance
zone/node watermarks, we also balance per memcg watermark. The cost
would be proportional to the size of memcg's that have allocated from
that zone/node. kswapd is not fast path and already optimized in terms
of when to wake up, so it makes sense to reuse all of that. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
