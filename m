Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7208D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 21:29:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7164E3EE0C3
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:29:01 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 565DC45DE4D
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:29:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B55E45DD74
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:29:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F3E31DB803A
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:29:01 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D760A1DB8038
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:29:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V2 1/2] count the soft_limit reclaim in global background reclaim
In-Reply-To: <1301356270-26859-2-git-send-email-yinghan@google.com>
References: <1301356270-26859-1-git-send-email-yinghan@google.com> <1301356270-26859-2-git-send-email-yinghan@google.com>
Message-Id: <20110329102926.C084.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 29 Mar 2011 10:29:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

> @@ -2320,6 +2324,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
>  	unsigned long total_scanned;
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
> +	unsigned long nr_soft_reclaimed;
> +	unsigned long nr_soft_scanned;
>  	struct scan_control sc = {
>  		.gfp_mask = GFP_KERNEL,
>  		.may_unmap = 1,
> @@ -2409,11 +2415,15 @@ loop_again:
>  
>  			sc.nr_scanned = 0;
>  
> +			nr_soft_scanned = 0;
>  			/*
>  			 * Call soft limit reclaim before calling shrink_zone.
> -			 * For now we ignore the return value
>  			 */
> -			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
> +			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
> +							order, sc.gfp_mask,
> +							&nr_soft_scanned);
> +			sc.nr_reclaimed += nr_soft_reclaimed;
> +			total_scanned += nr_soft_scanned;
>  
>  			/*
>  			 * We put equal pressure on every zone, unless

Thank you.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
