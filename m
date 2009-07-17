Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D24506B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 20:04:48 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6H04mqh020454
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Jul 2009 09:04:48 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F01345DE51
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:04:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA6F345DE4E
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:04:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B8A6C1DB8040
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:04:47 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 664391DB803C
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 09:04:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
In-Reply-To: <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com>
References: <1247679064.4089.26.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com>
Message-Id: <20090717090003.A903.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Jul 2009 09:04:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 15 Jul 2009, Lee Schermerhorn wrote:
> 
> > Interestingly, on ia64, the top cpuset mems_allowed gets set to all
> > possible nodes, while on x86_64, it gets set to on-line nodes [or nodes
> > with memory].  Maybe this is a to support hot-plug?
> > 
> 
> numactl --interleave=all simply passes a nodemask with all bits set, so if 
> cpuset_current_mems_allowed includes offline nodes from node_possible_map, 
> then mpol_set_nodemask() doesn't mask them off.
> 
> Seems like we could handle this strictly in mempolicies without worrying 
> about top_cpuset like in the following?

This patch seems band-aid patch. it will change memory-hotplug behavior.
Please imazine following scenario:

1. numactl interleave=all process-A
2. memory hot-add

before 2.6.30:
		-> process-A can use hot-added memory

your proposal patch:
		-> process-A can't use hot-added memory




> ---
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -194,6 +194,7 @@ static int mpol_new_bind(struct mempolicy *pol, const nodemask_t *nodes)
>  static int mpol_set_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
>  {
>  	nodemask_t cpuset_context_nmask;
> +	nodemask_t mems_allowed;
>  	int ret;
>  
>  	/* if mode is MPOL_DEFAULT, pol is NULL. This is right. */
> @@ -201,20 +202,21 @@ static int mpol_set_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
>  		return 0;
>  
>  	VM_BUG_ON(!nodes);
> +	nodes_and(mems_allowed, cpuset_current_mems_allowed,
> +				node_states[N_HIGH_MEMORY]);
>  	if (pol->mode == MPOL_PREFERRED && nodes_empty(*nodes))
>  		nodes = NULL;	/* explicit local allocation */
>  	else {
>  		if (pol->flags & MPOL_F_RELATIVE_NODES)
>  			mpol_relative_nodemask(&cpuset_context_nmask, nodes,
> -					       &cpuset_current_mems_allowed);
> +					       &mems_allowed);
>  		else
>  			nodes_and(cpuset_context_nmask, *nodes,
> -				  cpuset_current_mems_allowed);
> +				  mems_allowed);
>  		if (mpol_store_user_nodemask(pol))
>  			pol->w.user_nodemask = *nodes;
>  		else
> -			pol->w.cpuset_mems_allowed =
> -						cpuset_current_mems_allowed;
> +			pol->w.cpuset_mems_allowed = mems_allowed;
>  	}
>  
>  	ret = mpol_ops[pol->mode].create(pol,



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
