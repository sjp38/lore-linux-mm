Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 328BD6B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 10:49:27 -0400 (EDT)
Date: Tue, 1 Sep 2009 15:49:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/6] hugetlb:  introduce alloc_nodemask_of_node
Message-ID: <20090901144932.GB7548@csn.ul.ie>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160338.11080.51282.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090828160338.11080.51282.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, Aug 28, 2009 at 12:03:38PM -0400, Lee Schermerhorn wrote:
> [PATCH 4/6] - hugetlb:  introduce alloc_nodemask_of_node()
> 
> Against:  2.6.31-rc7-mmotm-090827-0057
> 
> New in V5 of series
> 
> Introduce nodemask macro to allocate a nodemask and 
> initialize it to contain a single node, using the macro
> init_nodemask_of_node() factored out of the nodemask_of_node()
> macro.
> 
> alloc_nodemask_of_node() coded as a macro to avoid header
> dependency hell.
> 
> This will be used to construct the huge pages "nodes_allowed"
> nodemask for a single node when a persistent huge page
> pool page count is modified via a per node sysfs attribute.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  include/linux/nodemask.h |   20 ++++++++++++++++++--
>  1 file changed, 18 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.31-rc7-mmotm-090827-0057/include/linux/nodemask.h
> ===================================================================
> --- linux-2.6.31-rc7-mmotm-090827-0057.orig/include/linux/nodemask.h	2009-08-28 09:21:19.000000000 -0400
> +++ linux-2.6.31-rc7-mmotm-090827-0057/include/linux/nodemask.h	2009-08-28 09:21:29.000000000 -0400
> @@ -245,18 +245,34 @@ static inline int __next_node(int n, con
>  	return min_t(int,MAX_NUMNODES,find_next_bit(srcp->bits, MAX_NUMNODES, n+1));
>  }
>  
> +#define init_nodemask_of_nodes(mask, node)				\
> +	nodes_clear(*(mask));						\
> +	node_set((node), *(mask));
> +

Is the done thing to either make this a static inline or else wrap it in
a do { } while(0) ? The reasoning being that if this is used as part of an
another statement (e.g. a for loop) that it'll actually compile instead of
throw up weird error messages.

>  #define nodemask_of_node(node)						\
>  ({									\
>  	typeof(_unused_nodemask_arg_) m;				\
>  	if (sizeof(m) == sizeof(unsigned long)) {			\
>  		m.bits[0] = 1UL<<(node);				\
>  	} else {							\
> -		nodes_clear(m);						\
> -		node_set((node), m);					\
> +		init_nodemask_of_nodes(&m, (node));			\
>  	}								\
>  	m;								\
>  })
>  
> +/*
> + * returns pointer to kmalloc()'d nodemask initialized to contain the
> + * specified node.  Caller must free with kfree().
> + */
> +#define alloc_nodemask_of_node(node)					\
> +({									\
> +	typeof(_unused_nodemask_arg_) *nmp;				\
> +	nmp = kmalloc(sizeof(*nmp), GFP_KERNEL);			\
> +	if (nmp)							\
> +		init_nodemask_of_nodes(nmp, (node));			\
> +	nmp;								\
> +})
> +

Otherwise, it looks ok.

>  #define first_unset_node(mask) __first_unset_node(&(mask))
>  static inline int __first_unset_node(const nodemask_t *maskp)
>  {
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
