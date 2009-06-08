Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7FF4D6B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 01:49:46 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n586rqYj011472
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 8 Jun 2009 15:53:52 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D9C145DD79
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 15:53:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C2A4D45DD6F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 15:53:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BB2D51DB801D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 15:53:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 04E501DB8021
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 15:53:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] vmscan: fix may_swap handling for memcg
In-Reply-To: <20090608153916.3ccaeb9a.nishimura@mxp.nes.nec.co.jp>
References: <20090608121848.4370.A69D9226@jp.fujitsu.com> <20090608153916.3ccaeb9a.nishimura@mxp.nes.nec.co.jp>
Message-Id: <20090608154634.437F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  8 Jun 2009 15:53:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Mon,  8 Jun 2009 12:20:54 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Hi
> > 
> Hi, thank you for your comment.
> 
> > > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > 
> > > Commit 2e2e425989080cc534fc0fca154cae515f971cf5 ("vmscan,memcg: reintroduce
> > > sc->may_swap) add may_swap flag and handle it at get_scan_ratio().
> > > 
> > > But the result of get_scan_ratio() is ignored when priority == 0, and this
> > > means, when memcg hits the mem+swap limit, anon pages can be swapped
> > > just in vain. Especially when memcg causes oom by mem+swap limit,
> > > we can see many and many pages are swapped out.
> > > 
> > > Instead of not scanning anon lru completely when priority == 0, this patch adds
> > > a hook to handle may_swap flag in shrink_page_list() to avoid using useless swaps,
> > > and calls try_to_free_swap() if needed because it can reduce
> > > both mem.usage and memsw.usage if the page(SwapCache) is unused anymore.
> > > 
> > > Such unused-but-managed-under-memcg SwapCache can be made in some paths,
> > > for example trylock_page() failure in free_swap_cache().
> > > 
> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > I think root cause is following branch, right?
> yes.
> 
> > if so, Why can't we handle this issue on shrink_zone()?
> > 
> Just because priority==0 means oom is about to happen and I don't
> want to see oom if possible.
> So I thought it would be better to reclaim as much pages(memsw.usage) as possible
> in this case.

hmmm..

In general, adding new branch to shrink_page_list() is not good idea.
it can cause performance degression.

Plus, it is not big problem at all. it happen only when priority==0.
Definitely, priority==0 don't occur normally.
and, too many recliaming pages is not only memcg issue. I don't think this
patch provide generic solution.


Why your test environment makes oom so frequently?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
