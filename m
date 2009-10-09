Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6D52A6B004D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 21:03:52 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9913o27019529
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Oct 2009 10:03:50 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BFF4745DE4E
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:03:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A2E8945DE4C
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:03:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DF511DB803E
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:03:49 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 399811DB8037
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:03:49 +0900 (JST)
Date: Fri, 9 Oct 2009 10:01:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm: add gfp flags for NODEMASK_ALLOC slab allocations
Message-Id: <20091009100123.a18f2a15.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.00.0910081422100.676@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain>
	<20091008162527.23192.68825.sendpatchset@localhost.localdomain>
	<alpine.DEB.1.00.0910081422100.676@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Oct 2009 14:22:21 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> Objects passed to NODEMASK_ALLOC() are relatively small in size and are
> backed by slab caches that are not of large order, traditionally never
> greater than PAGE_ALLOC_COSTLY_ORDER.
> 
> Thus, using GFP_KERNEL for these allocations on large machines when
> CONFIG_NODES_SHIFT > 8 will cause the page allocator to loop endlessly in
> the allocation attempt, each time invoking both direct reclaim or the oom
> killer.
> 
> This is of particular interest when using NODEMASK_ALLOC() from a
> mempolicy context (either directly in mm/mempolicy.c or the mempolicy
> constrained hugetlb allocations) since the oom killer always kills
> current when allocations are constrained by mempolicies.  So for all
> present use cases in the kernel, current would end up being oom killed
> when direct reclaim fails.  That would allow the NODEMASK_ALLOC() to
> succeed but current would have sacrificed itself upon returning.
> 
> This patch adds gfp flags to NODEMASK_ALLOC() to pass to kmalloc() on
> CONFIG_NODES_SHIFT > 8; this parameter is a nop on other configurations.
> All current use cases either directly from hugetlb code or indirectly via
> NODEMASK_SCRATCH() union __GFP_NORETRY to avoid direct reclaim and the
> oom killer when the slab allocator needs to allocate additional pages.
> 
> The side-effect of this change is that all current use cases of either
> NODEMASK_ALLOC() or NODEMASK_SCRATCH() need appropriate -ENOMEM handling
> when the allocation fails (never for CONFIG_NODES_SHIFT <= 8).  All
> current use cases were audited and do have appropriate error handling at
> this time.
> 
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  Andrew, this was written on mmotm-09251435 plus Lee's entire patchset.
> 
>  include/linux/nodemask.h |   21 ++++++++++++---------
>  mm/hugetlb.c             |    5 +++--
>  2 files changed, 15 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -485,15 +485,17 @@ static inline int num_node_state(enum node_states state)
>  #define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
>  
>  /*
> - * For nodemask scrach area.(See CPUMASK_ALLOC() in cpumask.h)
> - * NODEMASK_ALLOC(x, m) allocates an object of type 'x' with the name 'm'.
> + * For nodemask scrach area.
> + * NODEMASK_ALLOC(type, name) allocates an object with a specified type and
> + * name.
>   */
> -#if NODES_SHIFT > 8 /* nodemask_t > 64 bytes */
> -#define NODEMASK_ALLOC(x, m)		x *m = kmalloc(sizeof(*m), GFP_KERNEL)
> -#define NODEMASK_FREE(m)		kfree(m)
> +#if NODES_SHIFT > 8 /* nodemask_t > 256 bytes */
> +#define NODEMASK_ALLOC(type, name, gfp_flags)	\
> +			type *name = kmalloc(sizeof(*name), gfp_flags)
> +#define NODEMASK_FREE(m)			kfree(m)
>  #else
> -#define NODEMASK_ALLOC(x, m)		x _m, *m = &_m
> -#define NODEMASK_FREE(m)		do {} while (0)
> +#define NODEMASK_ALLOC(type, name, gfp_flags)	type _name, *name = &_name
> +#define NODEMASK_FREE(m)			do {} while (0)
>  #endif
>  
>  /* A example struture for using NODEMASK_ALLOC, used in mempolicy. */
> @@ -502,8 +504,9 @@ struct nodemask_scratch {
>  	nodemask_t	mask2;
>  };
>  
> -#define NODEMASK_SCRATCH(x)	\
> -		NODEMASK_ALLOC(struct nodemask_scratch, x)
> +#define NODEMASK_SCRATCH(x)						\
> +			NODEMASK_ALLOC(struct nodemask_scratch, x,	\
> +					GFP_KERNEL | __GFP_NORETRY)
>  #define NODEMASK_SCRATCH_FREE(x)	NODEMASK_FREE(x)
>  
>  
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1361,7 +1361,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>  	int nid;
>  	unsigned long count;
>  	struct hstate *h;
> -	NODEMASK_ALLOC(nodemask_t, nodes_allowed);
> +	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
>  
>  	err = strict_strtoul(buf, 10, &count);
>  	if (err)
> @@ -1857,7 +1857,8 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
>  	proc_doulongvec_minmax(table, write, buffer, length, ppos);
>  
>  	if (write) {
> -		NODEMASK_ALLOC(nodemask_t, nodes_allowed);
> +		NODEMASK_ALLOC(nodemask_t, nodes_allowed,
> +						GFP_KERNEL | __GFP_NORETRY);
>  		if (!(obey_mempolicy &&
>  			       init_nodemask_of_mempolicy(nodes_allowed))) {
>  			NODEMASK_FREE(nodes_allowed);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
