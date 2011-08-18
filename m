Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9274C900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:58:36 -0400 (EDT)
Date: Thu, 18 Aug 2011 15:58:21 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3] memcg: add nr_pages argument for hierarchical reclaim
Message-ID: <20110818135821.GA16958@cmpxchg.org>
References: <20110810141425.GC15007@tiehlicka.suse.cz>
 <20110811085252.b29081f1.kamezawa.hiroyu@jp.fujitsu.com>
 <20110811145055.GN8023@tiehlicka.suse.cz>
 <20110817095405.ee3dcd74.kamezawa.hiroyu@jp.fujitsu.com>
 <20110817113550.GA7482@tiehlicka.suse.cz>
 <20110818085233.69dbf23b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110818062722.GB23056@tiehlicka.suse.cz>
 <20110818154259.6b4adf09.kamezawa.hiroyu@jp.fujitsu.com>
 <20110818074602.GD23056@tiehlicka.suse.cz>
 <20110818125754.GA14015@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110818125754.GA14015@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu, Aug 18, 2011 at 02:57:54PM +0200, Michal Hocko wrote:
> I have just realized that num_online_nodes should be much better than
> MAX_NUMNODES. 
> Just for reference, the patch is based on top of
> https://lkml.org/lkml/2011/8/9/82 (it doesn't depend on it but it also
> doesn't make much sense without it)
> 
> Changes since v2:
> - use num_online_nodes rather than MAX_NUMNODES
> Changes since v1:
> - reclaim nr_nodes * SWAP_CLUSTER_MAX in mem_cgroup_force_empty
> ---
> From: Michal Hocko <mhocko@suse.cz>
> Subject: memcg: add nr_pages argument for hierarchical reclaim
> 
> Now that we are doing memcg direct reclaim limited to nr_to_reclaim
> pages (introduced by "memcg: stop vmscan when enough done.") we have to
> be more careful. Currently we are using SWAP_CLUSTER_MAX which is OK for
> most callers but it might cause failures for limit resize or force_empty
> code paths on big NUMA machines.

The limit resizing path retries as long as reclaim makes progress, so
this is just handwaving.

After Kame's patch, the force-empty path has an increased risk of
failing to move huge pages to the parent, because it tries reclaim
only once.  This could need further evaluation, and possibly a fix.
But instead:

> @@ -2331,8 +2331,14 @@ static int mem_cgroup_do_charge(struct m
>  	if (!(gfp_mask & __GFP_WAIT))
>  		return CHARGE_WOULDBLOCK;
>  
> +	/*
> +	 * We are lying about nr_pages because we do not want to
> +	 * reclaim too much for THP pages which should rather fallback
> +	 * to small pages.
> +	 */
>  	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> -					      gfp_mask, flags, NULL);
> +					      gfp_mask, flags, NULL,
> +					      1);
>  	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
>  		return CHARGE_RETRY;
>  	/*

You tell it to reclaim _less_ than before, further increasing the risk
of failure...

> @@ -2350,7 +2351,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  		.may_writepage = !laptop_mode,
>  		.may_unmap = 1,
>  		.may_swap = !noswap,
> -		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> +		.nr_to_reclaim = max_t(unsigned long, nr_pages, SWAP_CLUSTER_MAX),

...but wait, this transparently fixes it up and ignores the caller's
request.

Sorry, but this is just horrible!

For the past weeks I have been chasing memcg bugs that came in with
sloppy and untested code, that was merged for handwavy reasons.

Changes to algorithms need to be tested and optimizations need to be
quantified in other parts of the VM and the kernel, too.  I have no
idea why this doesn't seem to apply to the memory cgroup subsystem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
