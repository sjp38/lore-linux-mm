Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 946D36B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 01:42:08 -0400 (EDT)
Date: Mon, 8 Jun 2009 15:39:16 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH mmotm] vmscan: fix may_swap handling for memcg
Message-Id: <20090608153916.3ccaeb9a.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090608121848.4370.A69D9226@jp.fujitsu.com>
References: <20090608120228.cb70e569.nishimura@mxp.nes.nec.co.jp>
	<20090608121848.4370.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon,  8 Jun 2009 12:20:54 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
> 
Hi, thank you for your comment.

> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > Commit 2e2e425989080cc534fc0fca154cae515f971cf5 ("vmscan,memcg: reintroduce
> > sc->may_swap) add may_swap flag and handle it at get_scan_ratio().
> > 
> > But the result of get_scan_ratio() is ignored when priority == 0, and this
> > means, when memcg hits the mem+swap limit, anon pages can be swapped
> > just in vain. Especially when memcg causes oom by mem+swap limit,
> > we can see many and many pages are swapped out.
> > 
> > Instead of not scanning anon lru completely when priority == 0, this patch adds
> > a hook to handle may_swap flag in shrink_page_list() to avoid using useless swaps,
> > and calls try_to_free_swap() if needed because it can reduce
> > both mem.usage and memsw.usage if the page(SwapCache) is unused anymore.
> > 
> > Such unused-but-managed-under-memcg SwapCache can be made in some paths,
> > for example trylock_page() failure in free_swap_cache().
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> I think root cause is following branch, right?
yes.

> if so, Why can't we handle this issue on shrink_zone()?
> 
Just because priority==0 means oom is about to happen and I don't
want to see oom if possible.
So I thought it would be better to reclaim as much pages(memsw.usage) as possible
in this case.

> 
> ---------------------------------------------------------------
> static void shrink_zone(int priority, struct zone *zone,
>                                 struct scan_control *sc)
> {
>         get_scan_ratio(zone, sc, percent);
> 
>         for_each_evictable_lru(l) {
>                 int file = is_file_lru(l);
>                 unsigned long scan;
> 
>                 scan = zone_nr_pages(zone, sc, l);
>                 if (priority) {				// !!here!!
>                         scan >>= priority;
>                         scan = (scan * percent[file]) / 100;
>                 }
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
