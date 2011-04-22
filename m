Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F3C598D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 01:27:06 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 02A613EE0BC
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:27:03 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D532D45DF07
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:27:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B8A7A45DF05
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:27:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC6721DB8038
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:27:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 783AF1DB803E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:27:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V7 5/9] Infrastructure to support per-memcg reclaim.
In-Reply-To: <1303446260-21333-6-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com> <1303446260-21333-6-git-send-email-yinghan@google.com>
Message-Id: <20110422142734.FA69.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Apr 2011 14:27:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> +static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont, int order)
> +{
> +	return 0;
> +}

this one and

> @@ -2672,36 +2686,48 @@ int kswapd(void *p)
(snip)
>  		/*
>  		 * We can speed up thawing tasks if we don't call balance_pgdat
>  		 * after returning from the refrigerator
>  		 */
> -		if (!ret) {
> +		if (is_global_kswapd(kswapd_p)) {
>  			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
>  			order = balance_pgdat(pgdat, order, &classzone_idx);
> +		} else {
> +			mem = mem_cgroup_get_shrink_target();
> +			if (mem)
> +				shrink_mem_cgroup(mem, order);
> +			mem_cgroup_put_shrink_target(mem);
>  		}
>  	}

this one shold be placed in "[7/9] Per-memcg background reclaim". isn't it?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
