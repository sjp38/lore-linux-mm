Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EFFDC6B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 17:20:31 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o3MLKR9d021555
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:20:28 +0200
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by kpbe13.cbf.corp.google.com with ESMTP id o3MLK3LU025851
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 16:20:26 -0500
Received: by pxi19 with SMTP id 19so857542pxi.26
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 14:20:26 -0700 (PDT)
Date: Thu, 22 Apr 2010 14:20:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: fix bugs of mpol_rebind_nodemask()
In-Reply-To: <4BD05929.8040900@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1004221415090.25350@chino.kir.corp.google.com>
References: <4BD05929.8040900@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010, Miao Xie wrote:

> - local variable might be an empty nodemask, so must be checked before setting
>   pol->v.nodes to it.
> 
> - nodes_remap() may cause the weight of pol->v.nodes being monotonic decreasing.
>   and never become large even we pass a nodemask with large weight after
>   ->v.nodes become little.
> 

That's always been the intention of rebinding a mempolicy nodemask: we 
remap the current mempolicy nodes over the new nodemask given the set of 
allowed nodes.  The nodes_remap() shouldn't be removed.

> this patch fixes these two problem.
> 
> Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
> ---
>  mm/mempolicy.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 08f40a2..03ba9fc 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -291,12 +291,15 @@ static void mpol_rebind_nodemask(struct mempolicy *pol,
>  	else if (pol->flags & MPOL_F_RELATIVE_NODES)
>  		mpol_relative_nodemask(&tmp, &pol->w.user_nodemask, nodes);
>  	else {
> -		nodes_remap(tmp, pol->v.nodes, pol->w.cpuset_mems_allowed,
> -			    *nodes);
> +		tmp = *nodes;
>  		pol->w.cpuset_mems_allowed = *nodes;
>  	}
>  
> -	pol->v.nodes = tmp;
> +	if (nodes_empty(tmp))
> +		pol->v.nodes = *nodes;
> +	else
> +		pol->v.nodes = tmp;
> +
>  	if (!node_isset(current->il_next, tmp)) {
>  		current->il_next = next_node(current->il_next, tmp);
>  		if (current->il_next >= MAX_NUMNODES)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
