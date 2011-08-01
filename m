Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A729790014E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 10:00:22 -0400 (EDT)
Date: Mon, 1 Aug 2011 15:59:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 2/5] memcg : pass scan nodemask
Message-ID: <20110801135953.GE25251@tiehlicka.suse.cz>
References: <20110727144438.a9fdfd5b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110727144742.420cf69c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110727144742.420cf69c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Wed 27-07-11 14:47:42, KAMEZAWA Hiroyuki wrote:
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
> ---
>  include/linux/memcontrol.h |    2 +-
>  mm/memcontrol.c            |    8 ++++++--
>  mm/vmscan.c                |    3 ++-
>  3 files changed, 9 insertions(+), 4 deletions(-)
> 
[...]
> Index: mmotm-0710/mm/vmscan.c
> ===================================================================
> --- mmotm-0710.orig/mm/vmscan.c
> +++ mmotm-0710/mm/vmscan.c
> @@ -2280,6 +2280,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  	unsigned long nr_reclaimed;
>  	unsigned long start, end;
>  	int nid;
> +	nodemask_t *mask;
>  	struct scan_control sc = {
>  		.may_writepage = !laptop_mode,
>  		.may_unmap = 1,
> @@ -2302,7 +2303,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  	 * take care of from where we get pages. So the node where we start the
>  	 * scan does not need to be the current node.
>  	 */
> -	nid = mem_cgroup_select_victim_node(mem_cont);
> +	nid = mem_cgroup_select_victim_node(mem_cont, &mask);

The mask is not used anywhere AFAICS and using it is a point of the
patch AFAIU. I guess you wanted to use &sc.nodemask, right?

Other than that, looks good to me.

Reviewed-by: Michal Hocko <mhocko@suse.cz>
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
