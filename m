Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AE0F06B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 00:54:01 -0400 (EDT)
Subject: Re: [PATCH 1/1] Balance Freeing of Huge Pages across Nodes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.2.00.0906281646110.8440@chino.kir.corp.google.com>
References: <20090626201503.29365.39994.sendpatchset@lts-notebook>
	 <20090626201511.29365.84956.sendpatchset@lts-notebook>
	 <alpine.DEB.2.00.0906281646110.8440@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Mon, 29 Jun 2009 00:55:36 -0400
Message-Id: <1246251336.30751.3.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2009-06-28 at 16:54 -0700, David Rientjes wrote:
> On Fri, 26 Jun 2009, Lee Schermerhorn wrote:
> 
> > [PATCH] 1/1 Balance Freeing of Huge Pages across Nodes
> > 
> > Against:  12jun09 mmotm
> > 
> > [applies to 25jun09 mmotm as well]
> > 
> > Free huges pages from nodes in round robin fashion in an
> > attempt to keep [persistent a.k.a static] hugepages balanced
> > across nodes
> > 
> > New function free_pool_huge_page() is modeled on and
> > performs roughly the inverse of alloc_fresh_huge_page().
> > Replaces dequeue_huge_page() which now has no callers,
> > so this patch removes it.
> > 
> > Helper function hstate_next_node_to_free() uses new hstate
> > member next_to_free_nid to distribute "frees" across all
> > nodes with huge pages.
> > 
> > V2:
> > 
> > At Mel Gorman's suggestion:  renamed hstate_next_node() to
> > hstate_next_node_to_alloc() for symmetry.  Also, renamed
> > hstate member hugetlb_next_node to next_node_to_free.
> > ["hugetlb" is implicit in the hstate struct, I think].
> > 
> > New in this version:
> > 
> > Modified adjust_pool_surplus() to use hstate_next_node_to_alloc()
> > and hstate_next_node_to_free() to advance node id for adjusting
> > surplus huge page count, as this is equivalent to allocating and
> > freeing persistent huge pages.  [Can't blame Mel for this part.]
> > 
> > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Very useful change!

Thanks, David.  

Unfortunately, as I've been working on the next set of changes
[mempolicy-based and per node controls], I noticed that I should
probably fix up return_unused_surplus_pages(), as well.  So, I'll send
out v3 of this patch, maybe with a Documentation update, real soon, I
hope.

Lee

> 
> > @@ -666,14 +648,15 @@ static int alloc_fresh_huge_page(struct 
> >  	int next_nid;
> >  	int ret = 0;
> >  
> > -	start_nid = h->hugetlb_next_nid;
> > +	start_nid = h->next_nid_to_alloc;
> > +	next_nid = start_nid;
> >  
> >  	do {
> > -		page = alloc_fresh_huge_page_node(h, h->hugetlb_next_nid);
> > +		page = alloc_fresh_huge_page_node(h, next_nid);
> >  		if (page)
> >  			ret = 1;
> > -		next_nid = hstate_next_node(h);
> > -	} while (!page && h->hugetlb_next_nid != start_nid);
> > +		next_nid = hstate_next_node_to_alloc(h);
> > +	} while (!page && next_nid != start_nid);
> >  
> >  	if (ret)
> >  		count_vm_event(HTLB_BUDDY_PGALLOC);
> 
> This actually puts the currently unused next_nid to use, nice.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
