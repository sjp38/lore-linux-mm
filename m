Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A703E6B016D
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 07:20:06 -0400 (EDT)
Date: Wed, 10 Aug 2011 13:19:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5 3/6]  memg: vmscan pass nodemask
Message-ID: <20110810111958.GB15007@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
 <20110809191018.af81c55d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809191018.af81c55d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Tue 09-08-11 19:10:18, KAMEZAWA Hiroyuki wrote:
> 
> pass memcg's nodemask to try_to_free_pages().
> 
> try_to_free_pages can take nodemask as its argument but memcg
> doesn't pass it. Considering memcg can be used with cpuset on
> big NUMA, memcg should pass nodemask if available.
> 
> Now, memcg maintain nodemask with periodic updates. pass it.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Changelog:
>  - fixed bugs to pass nodemask.

Yes, looks good now.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> Index: mmotm-Aug3/mm/vmscan.c
> ===================================================================
> --- mmotm-Aug3.orig/mm/vmscan.c
> +++ mmotm-Aug3/mm/vmscan.c
> @@ -2354,7 +2354,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  		.order = 0,
>  		.mem_cgroup = mem_cont,
>  		.memcg_record = rec,
> -		.nodemask = NULL, /* we don't care the placement */
> +		.nodemask = NULL,
>  		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>  				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
>  	};

We can remove the whole nodemask initialization.

> @@ -2368,7 +2368,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  	 * take care of from where we get pages. So the node where we start the
>  	 * scan does not need to be the current node.
>  	 */
> -	nid = mem_cgroup_select_victim_node(mem_cont);
> +	nid = mem_cgroup_select_victim_node(mem_cont, &sc.nodemask);
>  
>  	zonelist = NODE_DATA(nid)->node_zonelists;

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
