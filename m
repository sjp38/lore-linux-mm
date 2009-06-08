Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A8C5C6B004D
	for <linux-mm@kvack.org>; Sun,  7 Jun 2009 22:23:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n583Kui1014832
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 8 Jun 2009 12:20:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F3D4845DE79
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 12:20:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC93C45DE6E
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 12:20:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 935101DB8042
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 12:20:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 382B31DB803E
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 12:20:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] vmscan: fix may_swap handling for memcg
In-Reply-To: <20090608120228.cb70e569.nishimura@mxp.nes.nec.co.jp>
References: <20090608120228.cb70e569.nishimura@mxp.nes.nec.co.jp>
Message-Id: <20090608121848.4370.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  8 Jun 2009 12:20:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Commit 2e2e425989080cc534fc0fca154cae515f971cf5 ("vmscan,memcg: reintroduce
> sc->may_swap) add may_swap flag and handle it at get_scan_ratio().
> 
> But the result of get_scan_ratio() is ignored when priority == 0, and this
> means, when memcg hits the mem+swap limit, anon pages can be swapped
> just in vain. Especially when memcg causes oom by mem+swap limit,
> we can see many and many pages are swapped out.
> 
> Instead of not scanning anon lru completely when priority == 0, this patch adds
> a hook to handle may_swap flag in shrink_page_list() to avoid using useless swaps,
> and calls try_to_free_swap() if needed because it can reduce
> both mem.usage and memsw.usage if the page(SwapCache) is unused anymore.
> 
> Such unused-but-managed-under-memcg SwapCache can be made in some paths,
> for example trylock_page() failure in free_swap_cache().
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

I think root cause is following branch, right?
if so, Why can't we handle this issue on shrink_zone()?


---------------------------------------------------------------
static void shrink_zone(int priority, struct zone *zone,
                                struct scan_control *sc)
{
        get_scan_ratio(zone, sc, percent);

        for_each_evictable_lru(l) {
                int file = is_file_lru(l);
                unsigned long scan;

                scan = zone_nr_pages(zone, sc, l);
                if (priority) {				// !!here!!
                        scan >>= priority;
                        scan = (scan * percent[file]) / 100;
                }




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
