Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 47BF46B0055
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 15:48:06 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id n7QJm1qq017688
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:48:01 -0700
Received: from pxi8 (pxi8.prod.google.com [10.243.27.8])
	by wpaz5.hot.corp.google.com with ESMTP id n7QJkNm6023889
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:47:59 -0700
Received: by pxi8 with SMTP id 8so463564pxi.9
        for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:47:58 -0700 (PDT)
Date: Wed, 26 Aug 2009 12:47:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] hugetlb:  add per node hstate attributes
In-Reply-To: <1251309747.4409.45.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.2.00.0908261239440.4511@chino.kir.corp.google.com>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain> <20090824192902.10317.94512.sendpatchset@localhost.localdomain> <20090825101906.GB4427@csn.ul.ie> <1251233369.16229.1.camel@useless.americas.hpqcorp.net> <20090826101122.GD10955@csn.ul.ie>
 <1251309747.4409.45.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 26 Aug 2009, Lee Schermerhorn wrote:

> Against: 2.6.31-rc6-mmotm-090820-1918
> 
> Introduce nodemask macro to allocate a nodemask and 
> initialize it to contain a single node, using existing
> nodemask_of_node() macro.  Coded as a macro to avoid header
> dependency hell.
> 
> This will be used to construct the huge pages "nodes_allowed"
> nodemask for a single node when a persistent huge page
> pool page count is modified via a per node sysfs attribute.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  include/linux/nodemask.h |   10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/nodemask.h
> ===================================================================
> --- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/nodemask.h	2009-08-24 10:16:56.000000000 -0400
> +++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/nodemask.h	2009-08-26 12:38:31.000000000 -0400
> @@ -257,6 +257,16 @@ static inline int __next_node(int n, con
>  	m;								\
>  })
>  
> +#define alloc_nodemask_of_node(node)					\
> +({									\
> +	typeof(_unused_nodemask_arg_) *nmp;				\
> +	nmp = kmalloc(sizeof(*nmp), GFP_KERNEL);			\
> +	if (nmp)							\
> +		*nmp = nodemask_of_node(node);				\
> +	nmp;								\
> +})
> +
> +
>  #define first_unset_node(mask) __first_unset_node(&(mask))
>  static inline int __first_unset_node(const nodemask_t *maskp)
>  {

I think it would probably be better to use the generic NODEMASK_ALLOC() 
interface by requiring it to pass the entire type (including "struct") as 
part of the first parameter.  Then it automatically takes care of 
dynamically allocating large nodemasks vs. allocating them on the stack.

Would it work by redefining NODEMASK_ALLOC() in the NODES_SHIFT > 8 case 
to be this:

	#define NODEMASK_ALLOC(x, m) x *m = kmalloc(sizeof(*m), GFP_KERNEL);

and converting NODEMASK_SCRATCH(x) to NODEMASK_ALLOC(struct 
nodemask_scratch, x), and then doing this in your code:

	NODEMASK_ALLOC(nodemask_t, nodes_allowed);
	if (nodes_allowed)
		*nodes_allowed = nodemask_of_node(node);

The NODEMASK_{ALLOC,SCRATCH}() interface is in its infancy so it can 
probably be made more general to handle cases like this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
