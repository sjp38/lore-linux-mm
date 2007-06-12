Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5CK0kA9026355
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 16:00:46 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5CK0kuf516360
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 16:00:46 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5CK0kmp014846
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 16:00:46 -0400
Date: Tue, 12 Jun 2007 13:00:44 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v2] Add populated_map to account for memoryless nodes
Message-ID: <20070612200044.GF3798@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <1181657940.5592.19.camel@localhost> <Pine.LNX.4.64.0706121143530.30754@schroedinger.engr.sgi.com> <1181675840.5592.123.camel@localhost> <Pine.LNX.4.64.0706121220580.3240@schroedinger.engr.sgi.com> <20070612194951.GC3798@us.ibm.com> <Pine.LNX.4.64.0706121252010.7983@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706121252010.7983@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 12.06.2007 [12:52:38 -0700], Christoph Lameter wrote:
> Interleave fix patch:
> 
> Fix MPOL_INTERLEAVE behavior for memoryless nodes
> 
> MPOL_INTERLEAVE currently simply loops over all nodes. Allocations on
> memoryless nodes will be redirected to nodes with memory. This results in
> an imbalance because the neighboring nodes to memoryless nodes will get significantly
> more interleave hits that the rest of the nodes on the system.
> 
> We can avoid this imbalance by clearing the nodes in the interleave node
> set that have no memory.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> Index: linux-2.6.22-rc4-mm2/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.22-rc4-mm2.orig/mm/mempolicy.c	2007-06-12 12:37:23.000000000 -0700
> +++ linux-2.6.22-rc4-mm2/mm/mempolicy.c	2007-06-12 12:39:16.000000000 -0700
> @@ -185,6 +185,7 @@ static struct mempolicy *mpol_new(int mo
>  	switch (mode) {
>  	case MPOL_INTERLEAVE:
>  		policy->v.nodes = *nodes;
> +		nodemask_and(policy->v.nodes, policy->v.nodes, node_memory_map);
>  		if (nodes_weight(*nodes) == 0) {

Shouldn't this be changed to

		if (nodes_weight(policy->v.nodes) == 0) {

??

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
