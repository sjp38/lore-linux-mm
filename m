Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D5E8F6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 02:24:29 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAA7OQWq018239
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Nov 2009 16:24:27 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B30D345DE52
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:24:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BF8945DE4F
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:24:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C7181DB803E
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:24:26 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 051961DB803C
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:24:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask v2
In-Reply-To: <20091106090202.dc2472b3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091104170944.cef988c7.kamezawa.hiroyu@jp.fujitsu.com> <20091106090202.dc2472b3.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20091110162121.361B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Nov 2009 16:24:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Hi

> ===================================================================
> --- mmotm-2.6.32-Nov2.orig/mm/oom_kill.c
> +++ mmotm-2.6.32-Nov2/mm/oom_kill.c
> @@ -196,27 +196,40 @@ unsigned long badness(struct task_struct
>  /*
>   * Determine the type of allocation constraint.
>   */
> +#ifdef CONFIG_NUMA
>  static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> -						    gfp_t gfp_mask)
> +				    gfp_t gfp_mask, nodemask_t *nodemask)
>  {
> -#ifdef CONFIG_NUMA
>  	struct zone *zone;
>  	struct zoneref *z;
>  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> -	nodemask_t nodes = node_states[N_HIGH_MEMORY];
> +	int ret = CONSTRAINT_NONE;
>  
> -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> -		if (cpuset_zone_allowed_softwall(zone, gfp_mask))
> -			node_clear(zone_to_nid(zone), nodes);
> -		else
> +	/*
> + 	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
> + 	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
> + 	 * feature. Then, only mempolicy use this nodemask.
> + 	 */
> +	if (nodemask && nodes_equal(*nodemask, node_states[N_HIGH_MEMORY]))
> +		ret = CONSTRAINT_MEMORY_POLICY;

!nodes_equal() ?


> +
> +	/* Check this allocation failure is caused by cpuset's wall function */
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> +			high_zoneidx, nodemask)
> +		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
>  			return CONSTRAINT_CPUSET;

If cpuset and MPOL_BIND are both used, Probably CONSTRAINT_MEMORY_POLICY is
better choice.



>  
> -	if (!nodes_empty(nodes))
> -		return CONSTRAINT_MEMORY_POLICY;
> -#endif
> +	/* __GFP_THISNODE never calls OOM.*/
>  
> +	return ret;
> +}
> +#else
> +static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> +				gfp_t gfp_mask, nodemask_t *nodemask)
> +{
>  	return CONSTRAINT_NONE;
>  }
> +#endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
