Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 80D706B005C
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 16:49:14 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id n83KnGEX015425
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 21:49:16 +0100
Received: from pzk42 (pzk42.prod.google.com [10.243.19.170])
	by wpaz24.hot.corp.google.com with ESMTP id n83KkX54003753
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 13:49:13 -0700
Received: by pzk42 with SMTP id 42so181402pzk.19
        for <linux-mm@kvack.org>; Thu, 03 Sep 2009 13:49:13 -0700 (PDT)
Date: Thu, 3 Sep 2009 13:49:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/6] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
In-Reply-To: <1252008940.6029.131.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0909031342520.30662@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160332.11080.74896.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0909031212110.22173@chino.kir.corp.google.com>
 <1252008940.6029.131.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 3 Sep 2009, Lee Schermerhorn wrote:

> > This isn't limited to only hugepage code, so a more appropriate name would 
> > probably be better.
> 
> Currently, this function is very much limited only to hugepage code.
> Most [all?] other users of mempolicy just use the alloc_vma_pages() and
> company, w/o cracking open the mempolicy.   I suppose something might
> come along that wants to open code interleaving over this mask, the way
> hugepage code does.  We could generalize it, then.  However, I'm not
> opposed to changing it to something like
> "alloc_nodemask_of_mempolicy()".   I still want to keep it in
> mempolicy.c, tho'.
> 
> Would this work for you?
>   

Yeah, it's not hugepage specific at all so mm/mempolicy.c is the only 
place for it anyway.  I just didn't think it needed `huge' in its name 
since it may get additional callers later.  alloc_nodemask_of_mempolicy() 
certainly sounds like a good generic function with a well defined purpose.

> > It'd probably be better to check for a NULL nodes_allowed either in 
> > set_max_huge_pages() than in hstate_next_node_to_{alloc,free} just for the 
> > cleanliness of the code OR simply return node_online_map from this 
> > function for default policies.
> 
> Yeah, I could pull the test up there to right after we check for a node
> id or task policy, and assign a pointer to node_online_map to
> nodes_allowed.  Then, I'll have to test for that condition before
> calling kfree().  I have no strong feelings about this.   I'll try to
> get this done for V6.  I'd like to get that out this week.
> 

&node_states[N_HIGH_MEMORY] as opposed to &node_online_map.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
