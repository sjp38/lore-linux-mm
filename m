Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7F0246B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 18:52:31 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAUNqSus031466
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Dec 2010 08:52:28 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D54A45DE59
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 08:52:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7791445DE56
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 08:52:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A39C1DB8037
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 08:52:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 27C551DB803B
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 08:52:28 +0900 (JST)
Date: Wed, 1 Dec 2010 08:46:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-Id: <20101201084641.5ecc6259.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTina1A0jFuSZhP8bkOMgHOvo1Fa-0VyoW2zjaoPM@mail.gmail.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101130160838.4c66febf.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikXzSx3Sjqb1NYZB-EJ76N-UbmiwTo=eOtSOnaP@mail.gmail.com>
	<20101130172710.38de418b.kamezawa.hiroyu@jp.fujitsu.com>
	<20101130175443.f01f4d09.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTina1A0jFuSZhP8bkOMgHOvo1Fa-0VyoW2zjaoPM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010 12:40:16 -0800
Ying Han <yinghan@google.com> wrote:

> On Tue, Nov 30, 2010 at 12:54 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 30 Nov 2010 17:27:10 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> >> On Tue, 30 Nov 2010 17:15:37 +0900
> >> Minchan Kim <minchan.kim@gmail.com> wrote:
> >>
> >> > Ideally, I hope we unify global and memcg of kswapd for easy
> >> > maintainance if it's not a big problem.
> >> > When we make patches about lru pages, we always have to consider what
> >> > I should do for memcg.
> >> > And when we review patches, we also should consider what the patch is
> >> > missing for memcg.
> >> > It makes maintainance cost big. Of course, if memcg maintainers is
> >> > involved with all patches, it's no problem as it is.
> >> >
> >> I know it's not. But thread control of kswapd will not have much merging point.
> >> And balance_pgdat() is fully replaced in patch/3. The effort for merging seems
> >> not big.
> 
> I intended to separate out the logic of per-memcg kswapd logics and
> not having it
> interfere with existing code. This should help for merging.
> 

yes.


> >>
> >
> > kswapd's balance_pgdat() is for following
> > A - reclaim pages within a node.
> > A - balancing zones in a pgdat.
> >
> > memcg's background reclaim needs followings.
> > A - reclaim pages within a memcg
> > A - reclaim pages from arbitrary zones, if it's fair, it's good.
> > A  A But it's not important from which zone the pages are reclaimed from.
> > A  A (I'm not sure we can select "the oldest" pages from divided LRU.)
> 
> The current implementation is simple, which it iterates all the nodes
> and reclaims pages from the per-memcg-per-zone LRU. As long as the
> wmarks is ok, the kswapd is done. Meanwhile, in order to not wasting
> cputime on "unreclaimable: nodes ( a node is unreclaimable if all the
> zones are unreclaimable), I used the nodemask to record that from the
> last scan, and the bit is reset as long as a page is returned back.
> This is a similar logic used in the global kswapd.
> 
> A potential improvement is to remember the last node we reclaimed
> from, and starting from the next node for the next kswapd wake_up.
> This avoids the case all the memcg kswapds are reclaiming from the
> small node ids on large numa machines.
> 
Yes, that's helpful.

> >
> > Then, merging will put 2 _very_ different functionalities into 1 function.
> 
> Agree.
> 
> >
> > So, I thought it's simpler to implement
> >
> > A 1. a victim node selector (This algorithm will never be in kswapd.)
> 
> Yeah, or round robin as I replied above ?
> 
I think it's good to have.

> > A 2. call _existing_ try_to_free_pages_mem_cgroup() with node local zonelist.
> > A Sharing is enough.
> 
> That will in turn use direct reclaim logic which has no notion of wmarks.
> 

 do {
	node = select_victim_node();
	do_try_to_free_pages_mem_cgroup(node);
	check watermark
 }

or If we need to check priority at el, your new balance_pgdat_mem_cgroup()
will be good.

> > kswapd stop/go routine may be able to be shared. But this patch itself seems not
> > very good to me.
> This looks feasible change, I will double check with it.

Thanks.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
