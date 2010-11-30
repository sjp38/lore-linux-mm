Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B644B6B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 04:00:29 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU90QvK018851
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Nov 2010 18:00:26 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D74245DE70
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 18:00:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A6D545DE6E
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 18:00:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 33C92E38003
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 18:00:26 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D913B1DB8037
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 18:00:25 +0900 (JST)
Date: Tue, 30 Nov 2010 17:54:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-Id: <20101130175443.f01f4d09.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101130172710.38de418b.kamezawa.hiroyu@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101130160838.4c66febf.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikXzSx3Sjqb1NYZB-EJ76N-UbmiwTo=eOtSOnaP@mail.gmail.com>
	<20101130172710.38de418b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Ying Han <yinghan@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010 17:27:10 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 30 Nov 2010 17:15:37 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > Ideally, I hope we unify global and memcg of kswapd for easy
> > maintainance if it's not a big problem.
> > When we make patches about lru pages, we always have to consider what
> > I should do for memcg.
> > And when we review patches, we also should consider what the patch is
> > missing for memcg.
> > It makes maintainance cost big. Of course, if memcg maintainers is
> > involved with all patches, it's no problem as it is.
> > 
> I know it's not. But thread control of kswapd will not have much merging point.
> And balance_pgdat() is fully replaced in patch/3. The effort for merging seems
> not big.
> 

kswapd's balance_pgdat() is for following
  - reclaim pages within a node.
  - balancing zones in a pgdat.

memcg's background reclaim needs followings.
  - reclaim pages within a memcg
  - reclaim pages from arbitrary zones, if it's fair, it's good.
    But it's not important from which zone the pages are reclaimed from. 
    (I'm not sure we can select "the oldest" pages from divided LRU.)

Then, merging will put 2 _very_ different functionalities into 1 function.

So, I thought it's simpler to implement

 1. a victim node selector (This algorithm will never be in kswapd.)
 2. call _existing_ try_to_free_pages_mem_cgroup() with node local zonelist.
 Sharing is enough.

kswapd stop/go routine may be able to be shared. But this patch itself seems not
very good to me.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
