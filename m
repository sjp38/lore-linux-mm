Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E6D5A6B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 16:15:37 -0400 (EDT)
Subject: Re: [PATCH 3/6] hugetlb:  derive huge pages nodes allowed from
 task mempolicy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0909031212110.22173@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain>
	 <20090828160332.11080.74896.sendpatchset@localhost.localdomain>
	 <alpine.DEB.1.00.0909031212110.22173@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Thu, 03 Sep 2009 16:15:40 -0400
Message-Id: <1252008940.6029.131.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-09-03 at 12:22 -0700, David Rientjes wrote:
> On Fri, 28 Aug 2009, Lee Schermerhorn wrote:
> 
> > Index: linux-2.6.31-rc7-mmotm-090827-0057/mm/mempolicy.c
> > ===================================================================
> > --- linux-2.6.31-rc7-mmotm-090827-0057.orig/mm/mempolicy.c	2009-08-28 09:21:20.000000000 -0400
> > +++ linux-2.6.31-rc7-mmotm-090827-0057/mm/mempolicy.c	2009-08-28 09:21:28.000000000 -0400
> > @@ -1564,6 +1564,67 @@ struct zonelist *huge_zonelist(struct vm
> >  	}
> >  	return zl;
> >  }
> > +
> > +/*
> > + * huge_mpol_nodes_allowed -- mempolicy extension for huge pages.
> > + *
> > + * Returns a [pointer to a] nodelist based on the current task's mempolicy
> > + * to constraing the allocation and freeing of persistent huge pages
> > + * 'Preferred', 'local' and 'interleave' mempolicy will behave more like
> > + * 'bind' policy in this context.  An attempt to allocate a persistent huge
> > + * page will never "fallback" to another node inside the buddy system
> > + * allocator.
> > + *
> > + * If the task's mempolicy is "default" [NULL], just return NULL for
> > + * default behavior.  Otherwise, extract the policy nodemask for 'bind'
> > + * or 'interleave' policy or construct a nodemask for 'preferred' or
> > + * 'local' policy and return a pointer to a kmalloc()ed nodemask_t.
> > + *
> > + * N.B., it is the caller's responsibility to free a returned nodemask.
> > + */
> 
> This isn't limited to only hugepage code, so a more appropriate name would 
> probably be better.

Currently, this function is very much limited only to hugepage code.
Most [all?] other users of mempolicy just use the alloc_vma_pages() and
company, w/o cracking open the mempolicy.   I suppose something might
come along that wants to open code interleaving over this mask, the way
hugepage code does.  We could generalize it, then.  However, I'm not
opposed to changing it to something like
"alloc_nodemask_of_mempolicy()".   I still want to keep it in
mempolicy.c, tho'.

Would this work for you?
  
> 
> It'd probably be better to check for a NULL nodes_allowed either in 
> set_max_huge_pages() than in hstate_next_node_to_{alloc,free} just for the 
> cleanliness of the code OR simply return node_online_map from this 
> function for default policies.

Yeah, I could pull the test up there to right after we check for a node
id or task policy, and assign a pointer to node_online_map to
nodes_allowed.  Then, I'll have to test for that condition before
calling kfree().  I have no strong feelings about this.   I'll try to
get this done for V6.  I'd like to get that out this week.

> 
> Otherwise
> 
> Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
