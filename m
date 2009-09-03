Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CB7AD6B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 15:22:15 -0400 (EDT)
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id n83JMJph032324
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 20:22:20 +0100
Received: from pzk39 (pzk39.prod.google.com [10.243.19.167])
	by zps75.corp.google.com with ESMTP id n83JMGLO017250
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 12:22:17 -0700
Received: by pzk39 with SMTP id 39so147825pzk.15
        for <linux-mm@kvack.org>; Thu, 03 Sep 2009 12:22:16 -0700 (PDT)
Date: Thu, 3 Sep 2009 12:22:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/6] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
In-Reply-To: <20090828160332.11080.74896.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0909031212110.22173@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160332.11080.74896.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Aug 2009, Lee Schermerhorn wrote:

> Index: linux-2.6.31-rc7-mmotm-090827-0057/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.31-rc7-mmotm-090827-0057.orig/mm/mempolicy.c	2009-08-28 09:21:20.000000000 -0400
> +++ linux-2.6.31-rc7-mmotm-090827-0057/mm/mempolicy.c	2009-08-28 09:21:28.000000000 -0400
> @@ -1564,6 +1564,67 @@ struct zonelist *huge_zonelist(struct vm
>  	}
>  	return zl;
>  }
> +
> +/*
> + * huge_mpol_nodes_allowed -- mempolicy extension for huge pages.
> + *
> + * Returns a [pointer to a] nodelist based on the current task's mempolicy
> + * to constraing the allocation and freeing of persistent huge pages
> + * 'Preferred', 'local' and 'interleave' mempolicy will behave more like
> + * 'bind' policy in this context.  An attempt to allocate a persistent huge
> + * page will never "fallback" to another node inside the buddy system
> + * allocator.
> + *
> + * If the task's mempolicy is "default" [NULL], just return NULL for
> + * default behavior.  Otherwise, extract the policy nodemask for 'bind'
> + * or 'interleave' policy or construct a nodemask for 'preferred' or
> + * 'local' policy and return a pointer to a kmalloc()ed nodemask_t.
> + *
> + * N.B., it is the caller's responsibility to free a returned nodemask.
> + */

This isn't limited to only hugepage code, so a more appropriate name would 
probably be better.

It'd probably be better to check for a NULL nodes_allowed either in 
set_max_huge_pages() than in hstate_next_node_to_{alloc,free} just for the 
cleanliness of the code OR simply return node_online_map from this 
function for default policies.

Otherwise

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
