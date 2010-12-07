Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9211C6B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 01:30:13 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB76UAdJ018283
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Dec 2010 15:30:10 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE13545DE76
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 15:30:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 97E5645DE80
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 15:30:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 83D90E38002
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 15:30:10 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3988BE38007
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 15:30:10 +0900 (JST)
Date: Tue, 7 Dec 2010 15:24:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-Id: <20101207152423.1ba94270.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101207061503.GH3158@balbir.in.ibm.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101130160838.4c66febf.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikXzSx3Sjqb1NYZB-EJ76N-UbmiwTo=eOtSOnaP@mail.gmail.com>
	<20101130172710.38de418b.kamezawa.hiroyu@jp.fujitsu.com>
	<20101130175443.f01f4d09.kamezawa.hiroyu@jp.fujitsu.com>
	<20101207061503.GH3158@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Minchan Kim <minchan.kim@gmail.com>, Ying Han <yinghan@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Dec 2010 11:45:03 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-11-30 17:54:43]:
> 
> > On Tue, 30 Nov 2010 17:27:10 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Tue, 30 Nov 2010 17:15:37 +0900
> > > Minchan Kim <minchan.kim@gmail.com> wrote:
> > > 
> > > > Ideally, I hope we unify global and memcg of kswapd for easy
> > > > maintainance if it's not a big problem.
> > > > When we make patches about lru pages, we always have to consider what
> > > > I should do for memcg.
> > > > And when we review patches, we also should consider what the patch is
> > > > missing for memcg.
> > > > It makes maintainance cost big. Of course, if memcg maintainers is
> > > > involved with all patches, it's no problem as it is.
> > > > 
> > > I know it's not. But thread control of kswapd will not have much merging point.
> > > And balance_pgdat() is fully replaced in patch/3. The effort for merging seems
> > > not big.
> > > 
> > 
> > kswapd's balance_pgdat() is for following
> >   - reclaim pages within a node.
> >   - balancing zones in a pgdat.
> > 
> > memcg's background reclaim needs followings.
> >   - reclaim pages within a memcg
> >   - reclaim pages from arbitrary zones, if it's fair, it's good.
> >     But it's not important from which zone the pages are reclaimed from. 
> >     (I'm not sure we can select "the oldest" pages from divided LRU.)
> >
> 
> Yes, if it is fair, then we don't break what kswapd tries to do, so
> fairness is quite important, in that we don't leaves zones unbalanced
> (at least by very much) as we try to do background reclaim. But
> sometimes it cannot be helped, specially if there are policies that
> bias the allocation.
>  
> > Then, merging will put 2 _very_ different functionalities into 1 function.
> > 
> > So, I thought it's simpler to implement
> > 
> >  1. a victim node selector (This algorithm will never be in kswapd.)
> 
> A victim node selector per memcg? Could you clarify the context of
> node here?
> 
An argument to balance_pgdat_for_memcg() or a start point of zonelist[].
i.e.
	zone_list = NODE_DATA(victim)->zonelist[0 or 1]

	for_each_zone_zonelist(z, zone_list)....

But, this is just an example, we just need to determine where we reclaim
page from before start walking.



Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
