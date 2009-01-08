Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A070E6B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 05:59:04 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n08Ax2lc018858
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 19:59:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B527E45DE4F
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 19:59:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 86ADD45DD72
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 19:59:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FE9F1DB8037
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 19:59:01 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C54FE18001
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 19:59:01 +0900 (JST)
Message-ID: <36699.10.75.179.62.1231412340.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090108191430.af89e037.nishimura@mxp.nes.nec.co.jp>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
    <20090108191430.af89e037.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 8 Jan 2009 19:59:00 +0900 (JST)
Subject: Re: [RFC][PATCH 1/4] memcg: fix
     formem_cgroup_get_reclaim_stat_from_page
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura said:

>     Call Trace:
>      [<ffffffff8028ea17>] ? ____pagevec_lru_add+0xc1/0x13c
>      [<ffffffff8028ec34>] ? drain_cpu_pagevecs+0x36/0x89
>      [<ffffffff802a4f8c>] ? swapin_readahead+0x78/0x98
>      [<ffffffff8029a37a>] ? handle_mm_fault+0x3d9/0x741
>      [<ffffffff804da654>] ? do_page_fault+0x3ce/0x78c
>      [<ffffffff804d7a42>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>      [<ffffffff804d860f>] ? page_fault+0x1f/0x30
>     Code: cc 55 48 8d af b8 0d 00 00 48 89 f7 53 89 d3 e8 39 85 02 00 48
> 63 d3 48 ff 44 d5 10 45 85 e4 74 05 48 ff 44 d5 00 48 85 c0 74 0e <48>
> ff 44 d0 10 45 85 e4 74 04 48 ff 04 d0 5b 5d 41 5c c3 41 54
>     RIP  [<ffffffff8028e710>] update_page_reclaim_stat+0x2f/0x42
>      RSP <ffff8801ee457da8>
>
>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
yes. PageCgroupUsed() should be cheked.
or
list_empty(&pc->lru) should be checked under zone->lock.
Your fix seems reasonable.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/memcontrol.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e2996b8..62e69d8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -559,6 +559,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page
> *page)
>  		return NULL;
>
>  	pc = lookup_page_cgroup(page);
> +	smp_rmb();
> +	if (!PageCgroupUsed(pc))
> +		return NULL;
> +
>  	mz = page_cgroup_zoneinfo(pc);
>  	if (!mz)
>  		return NULL;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
