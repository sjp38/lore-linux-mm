Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E03536B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 00:58:41 -0500 (EST)
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id nAB5wbii029432
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 21:58:37 -0800
Received: from pwj15 (pwj15.prod.google.com [10.241.219.79])
	by zps76.corp.google.com with ESMTP id nAB5wU4d007709
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 21:58:35 -0800
Received: by pwj15 with SMTP id 15so548583pwj.3
        for <linux-mm@kvack.org>; Tue, 10 Nov 2009 21:58:34 -0800 (PST)
Date: Tue, 10 Nov 2009 21:58:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v4.1
In-Reply-To: <20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com> <20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com> <20091110163419.361E.A69D9226@jp.fujitsu.com> <20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com> <20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
 <20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com> <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com> <20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com> <20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009, KAMEZAWA Hiroyuki wrote:

> Index: mm-test-kernel/drivers/char/sysrq.c
> ===================================================================
> --- mm-test-kernel.orig/drivers/char/sysrq.c
> +++ mm-test-kernel/drivers/char/sysrq.c
> @@ -339,7 +339,7 @@ static struct sysrq_key_op sysrq_term_op
>  
>  static void moom_callback(struct work_struct *ignored)
>  {
> -	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0);
> +	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL);
>  }
>  
>  static DECLARE_WORK(moom_work, moom_callback);
> Index: mm-test-kernel/mm/oom_kill.c
> ===================================================================
> --- mm-test-kernel.orig/mm/oom_kill.c
> +++ mm-test-kernel/mm/oom_kill.c
> @@ -196,27 +196,47 @@ unsigned long badness(struct task_struct
>  /*
>   * Determine the type of allocation constraint.
>   */
> -static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> -						    gfp_t gfp_mask)
> -{
>  #ifdef CONFIG_NUMA
> +static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> +				    gfp_t gfp_mask, nodemask_t *nodemask)
> +{
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
> -			return CONSTRAINT_CPUSET;
> +	/*
> +	 * Reach here only when __GFP_NOFAIL is used. So, we should avoid
> + 	 * to kill current.We have to random task kill in this case.
> + 	 * Hopefully, CONSTRAINT_THISNODE...but no way to handle it, now.
> + 	 */
> +	if (gfp_mask & __GPF_THISNODE)
> +		return ret;
>  

That shouldn't compile.

> -	if (!nodes_empty(nodes))
> +	/*
> + 	 * The nodemask here is a nodemask passed to alloc_pages(). Now,
> + 	 * cpuset doesn't use this nodemask for its hardwall/softwall/hierarchy
> + 	 * feature. mempolicy is an only user of nodemask here.
> +	 * check mempolicy's nodemask contains all N_HIGH_MEMORY
> + 	 */
> +	if (nodemask && !nodes_subset(node_states[N_HIGH_MEMORY], *nodemask))
>  		return CONSTRAINT_MEMORY_POLICY;
> -#endif
>  
> +	/* Check this allocation failure is caused by cpuset's wall function */
> +	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> +			high_zoneidx, nodemask)
> +		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
> +			return CONSTRAINT_CPUSET;
> +
> +	return CONSTRAINT_NONE;
> +}
> +#else
> +static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
> +				gfp_t gfp_mask, nodemask_t *nodemask)

inline seems appropriate in this case, gcc will optimize it anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
