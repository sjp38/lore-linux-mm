Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1236B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 05:36:58 -0400 (EDT)
Date: Fri, 2 Oct 2009 10:48:17 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/10] hugetlb:  factor init_nodemask_of_node
Message-ID: <20091002094817.GL21906@csn.ul.ie>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain> <20091001165825.32248.75849.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091001165825.32248.75849.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, clameter@sgi.com, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 01, 2009 at 12:58:25PM -0400, Lee Schermerhorn wrote:
> [PATCH 3/10] - hugetlb:  factor init_nodemask_of_node()
> 
> Against:  2.6.31-mmotm-090925-1435
> 
> New in V5 of series
> 
> V6: + rename 'init_nodemask_of_nodes()' to 'init_nodemask_of_node()'
>     + redefine init_nodemask_of_node() as static inline fcn
>     + move this patch back 1 in series
> 
> V8: + factor 'init_nodemask_of_node()' from nodemask_of_node()
>     + drop alloc_nodemask_of_node() -- not used any more
> 
> Factor init_nodemask_of_node() out of the nodemask_of_node()
> macro.
> 
> This will be used to populate the huge pages "nodes_allowed"
> nodemask for a single node when basing nodes_allowed on a
> preferred/local mempolicy or when a persistent huge page
> pool page count is modified via a per node sysfs attribute.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Very minor comment but otherwise

Acked-by: Mel Gorman <mel@csn.ul.ie>

> 
>  include/linux/nodemask.h |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.31-mmotm-090925-1435/include/linux/nodemask.h
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/include/linux/nodemask.h	2009-09-30 11:19:52.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/include/linux/nodemask.h	2009-09-30 11:22:01.000000000 -0400
> @@ -245,14 +245,19 @@ static inline int __next_node(int n, con
>  	return min_t(int,MAX_NUMNODES,find_next_bit(srcp->bits, MAX_NUMNODES, n+1));
>  }
>  
> +static inline void init_nodemask_of_node(nodemask_t *mask, int node)
> +{
> +	nodes_clear(*(mask));

() around mask there is unnecessary, you're not in a macro.

> +	node_set((node), *(mask));
> +}

Same for mask and node here. Not world ending by any measure.

> +
>  #define nodemask_of_node(node)						\
>  ({									\
>  	typeof(_unused_nodemask_arg_) m;				\
>  	if (sizeof(m) == sizeof(unsigned long)) {			\
>  		m.bits[0] = 1UL<<(node);				\
>  	} else {							\
> -		nodes_clear(m);						\
> -		node_set((node), m);					\
> +		init_nodemask_of_node(&m, (node));			\
>  	}								\
>  	m;								\
>  })
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
