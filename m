Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 2045A6B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 05:55:42 -0400 (EDT)
Date: Fri, 26 Jul 2013 11:55:28 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm, sched, numa: Create a per-task MPOL_INTERLEAVE policy
Message-ID: <20130726095528.GB20909@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130725104633.GQ27075@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130725104633.GQ27075@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 25, 2013 at 12:46:33PM +0200, Peter Zijlstra wrote:
> @@ -2234,12 +2236,13 @@ static void sp_free(struct sp_node *n)
>   * Policy determination "mimics" alloc_page_vma().
>   * Called from fault path where we know the vma and faulting address.
>   */
> -int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long addr)
> +int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long addr, int *account_node)
>  {
>  	struct mempolicy *pol;
>  	struct zone *zone;
>  	int curnid = page_to_nid(page);
>  	unsigned long pgoff;
> +	int thisnid = numa_node_id();
>  	int polnid = -1;
>  	int ret = -1;
>  
> @@ -2261,7 +2264,7 @@ int mpol_misplaced(struct page *page, st
>  
>  	case MPOL_PREFERRED:
>  		if (pol->flags & MPOL_F_LOCAL)
> -			polnid = numa_node_id();
> +			polnid = thisnid;
>  		else
>  			polnid = pol->v.preferred_node;
>  		break;
> @@ -2276,7 +2279,7 @@ int mpol_misplaced(struct page *page, st
>  		if (node_isset(curnid, pol->v.nodes))
>  			goto out;
>  		(void)first_zones_zonelist(
> -				node_zonelist(numa_node_id(), GFP_HIGHUSER),
> +				node_zonelist(thisnid, GFP_HIGHUSER),
>  				gfp_zone(GFP_HIGHUSER),
>  				&pol->v.nodes, &zone);
>  		polnid = zone->node;
> @@ -2291,8 +2294,7 @@ int mpol_misplaced(struct page *page, st
>  		int last_nidpid;
>  		int this_nidpid;
>  
> -		polnid = numa_node_id();
> -		this_nidpid = nid_pid_to_nidpid(polnid, current->pid);;
> +		this_nidpid = nid_pid_to_nidpid(thisnid, current->pid);;
>  
>  		/*
>  		 * Multi-stage node selection is used in conjunction
> @@ -2318,6 +2320,39 @@ int mpol_misplaced(struct page *page, st
>  		last_nidpid = page_nidpid_xchg_last(page, this_nidpid);
>  		if (!nidpid_pid_unset(last_nidpid) && nidpid_to_nid(last_nidpid) != polnid)

That should've become:

		if (!nidpid_pid_unset(last_nidpid) && nidpid_to_nid(last_nidpid) != thisnid)

>  			goto out;
> +
> +		/*
> +		 * Preserve interleave pages while allowing useful
> +		 * ->numa_faults[] statistics.
> +		 *
> +		 * When migrating into an interleave set, migrate to
> +		 * the correct interleaved node but account against the
> +		 * current node (where the task is running).
> +		 *
> +		 * Not doing this would result in ->numa_faults[] being
> +		 * flat across the interleaved nodes, making it
> +		 * impossible to shrink the node list even when all
> +		 * tasks are running on a single node.
> +		 *
> +		 * src dst    migrate      account
> +		 *  0   0  -- this_node    $page_node
> +		 *  0   1  -- policy_node  this_node
> +		 *  1   0  -- this_node    $page_node
> +		 *  1   1  -- policy_node  this_node
> +		 *
> +		 */
> +		switch (pol->mode) {
> +		case MPOL_INTERLEAVE:
> +			if (node_isset(thisnid, pol->v.nodes)) {
> +				if (account_node)
> +					*account_node = thisnid;
> +			}
> +			break;
> +
> +		default:
> +			polnid = thisnid;
> +			break;
> +		}
>  	}
>  
>  	if (curnid != polnid)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
