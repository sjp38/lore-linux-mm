Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4182E6B005C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 02:54:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n597Kj4t025892
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Jun 2009 16:20:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ACD245DD74
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:20:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DEE7945DD75
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:20:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B83EFE08008
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:20:44 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B211E08002
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 16:20:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] vmscan: handle may_swap more strictly (Re: [PATCH mmotm] vmscan: fix may_swap handling for memcg)
In-Reply-To: <20090609161330.fcd5facb.nishimura@mxp.nes.nec.co.jp>
References: <20090608165457.fa8d17e6.nishimura@mxp.nes.nec.co.jp> <20090609161330.fcd5facb.nishimura@mxp.nes.nec.co.jp>
Message-Id: <20090609161925.DD70.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Jun 2009 16:20:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > > and, too many recliaming pages is not only memcg issue. I don't think this
> > > patch provide generic solution.
> > > 
> > Ah, you're right. It's not only memcg issue.
> > 
> How about this one ?
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Commit 2e2e425989080cc534fc0fca154cae515f971cf5 ("vmscan,memcg: reintroduce
> sc->may_swap) add may_swap flag and handle it at get_scan_ratio().
> 
> But the result of get_scan_ratio() is ignored when priority == 0,
> so anon lru is scanned even if may_swap == 0 or nr_swap_pages == 0.
> IMHO, this is not an expected behavior.
> 
> As for memcg especially, because of this behavior many and many pages are
> swapped-out just in vain when oom is invoked by mem+swap limit.
> 
> This patch is for handling may_swap flag more strictly.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Looks great.
your patch doesn't only improve memcg, bug also improve noswap system.

Thanks.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



> ---
>  mm/vmscan.c |   18 +++++++++---------
>  1 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2ddcfc8..bacb092 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1407,13 +1407,6 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
>  	unsigned long ap, fp;
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  
> -	/* If we have no swap space, do not bother scanning anon pages. */
> -	if (!sc->may_swap || (nr_swap_pages <= 0)) {
> -		percent[0] = 0;
> -		percent[1] = 100;
> -		return;
> -	}
> -
>  	anon  = zone_nr_pages(zone, sc, LRU_ACTIVE_ANON) +
>  		zone_nr_pages(zone, sc, LRU_INACTIVE_ANON);
>  	file  = zone_nr_pages(zone, sc, LRU_ACTIVE_FILE) +
> @@ -1511,15 +1504,22 @@ static void shrink_zone(int priority, struct zone *zone,
>  	enum lru_list l;
>  	unsigned long nr_reclaimed = sc->nr_reclaimed;
>  	unsigned long swap_cluster_max = sc->swap_cluster_max;
> +	int noswap = 0;
>  
> -	get_scan_ratio(zone, sc, percent);
> +	/* If we have no swap space, do not bother scanning anon pages. */
> +	if (!sc->may_swap || (nr_swap_pages <= 0)) {
> +		noswap = 1;
> +		percent[0] = 0;
> +		percent[1] = 100;
> +	} else
> +		get_scan_ratio(zone, sc, percent);
>  
>  	for_each_evictable_lru(l) {
>  		int file = is_file_lru(l);
>  		unsigned long scan;
>  
>  		scan = zone_nr_pages(zone, sc, l);
> -		if (priority) {
> +		if (priority || noswap) {
>  			scan >>= priority;
>  			scan = (scan * percent[file]) / 100;
>  		}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
