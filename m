Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BJas5U029449
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 15:36:54 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BJapgo551210
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 15:36:53 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BJapPC023020
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 15:36:51 -0400
Date: Mon, 11 Jun 2007 12:36:46 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v2] gfp.h: GFP_THISNODE can go to other nodes if some are unpopulated
Message-ID: <20070611193646.GB9920@us.ibm.com>
References: <20070607150425.GA15776@us.ibm.com> <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com> <20070607220149.GC15776@us.ibm.com> <466D44C6.6080105@shadowen.org> <Pine.LNX.4.64.0706110911080.15326@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0706110926110.15868@schroedinger.engr.sgi.com> <20070611171201.GB3798@us.ibm.com> <Pine.LNX.4.64.0706111122010.18327@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111122010.18327@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Lee.Schermerhorn@hp.com, ak@suse.de, anton@samba.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [11:29:14 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > These are the exact semantics, I expected. so I'll be happy to test/work
> > on these fixes.
> > 
> > This would also make it unnecessary to add the populated checks in
> > various places, I think, as THISNODE will mean ONLYTHISNODE (and perhaps
> > should be renamed in the series).
> 
> Here is a draft on how this could work:

<snip>

> Index: linux-2.6/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.orig/mm/mempolicy.c	2007-06-11 11:13:09.000000000 -0700
> +++ linux-2.6/mm/mempolicy.c	2007-06-11 11:19:03.000000000 -0700
> @@ -1125,9 +1125,11 @@ static unsigned interleave_nodes(struct 
>  	struct task_struct *me = current;
> 
>  	nid = me->il_next;
> -	next = next_node(nid, policy->v.nodes);
> -	if (next >= MAX_NUMNODES)
> -		next = first_node(policy->v.nodes);
> +	do {
> +		next = next_node(nid, policy->v.nodes);
> +		if (next >= MAX_NUMNODES)
> +			next = first_node(policy->v.nodes);
> +	} while (!NODE_DATA(node)->present_pages);
>  	me->il_next = next;
>  	return nid;
>  }

So, I'm splitting up the populated_map patch in two, so that these bits
or the hugetlbfs bits could be put on top of having that nodemask.

*but*, if this change occurs in mempolicy.c, I think we still have a
problem, where me->il_next could be initialized in do_set_mempolicy() to
a memoryless node:

	if (new && new->policy == MPOL_INTERLEAVE)
		current->il_next = first_node(new->v.nodes);

Since we return nid in mm/mempolicy.c, we've fix the problem for
subsequent intereaves, but not the first one. So should it be:

	unsigned nid;

	if (new && new->policy == MPOL_INTERLEAVE) {
		nid = first_node(new->v.nodes);
		while (!node_populated(nid)) {
			nid = next_node(nid, new->v.nodes);
			if (nid >= MAX_NUMNODES) {
				mpol_free(current->mempolicy);
				current->mempolicy = NULL;
				mpol_set_task_struct_flag();
				return -EINVAL;
			}
		}
	}

??

Sorry if I'm way off here, just trying to get it right.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
