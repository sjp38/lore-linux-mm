Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EA8CF6B00D9
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:59:28 -0400 (EDT)
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id n7PLxJaS004906
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 14:59:24 -0700
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by zps18.corp.google.com with ESMTP id n7PLwjkq014881
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 14:59:17 -0700
Received: by pzk3 with SMTP id 3so1888859pzk.31
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 14:59:17 -0700 (PDT)
Date: Tue, 25 Aug 2009 14:59:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] hugetlb:  add nodemask arg to huge page alloc, free
 and surplus adjust fcns
In-Reply-To: <1251233374.16229.2.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.2.00.0908251451100.770@chino.kir.corp.google.com>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain> <20090824192637.10317.31039.sendpatchset@localhost.localdomain> <alpine.DEB.2.00.0908250112510.23660@chino.kir.corp.google.com>
 <1251233374.16229.2.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 25 Aug 2009, Lee Schermerhorn wrote:

> > > @@ -622,19 +622,29 @@ static struct page *alloc_fresh_huge_pag
> > >  }
> > >  
> > >  /*
> > > - * common helper function for hstate_next_node_to_{alloc|free}.
> > > - * return next node in node_online_map, wrapping at end.
> > > + * common helper functions for hstate_next_node_to_{alloc|free}.
> > > + * We may have allocated or freed a huge pages based on a different
> > > + * nodes_allowed, previously, so h->next_node_to_{alloc|free} might
> > > + * be outside of *nodes_allowed.  Ensure that we use the next
> > > + * allowed node for alloc or free.
> > >   */
> > > -static int next_node_allowed(int nid)
> > > +static int next_node_allowed(int nid, nodemask_t *nodes_allowed)
> > >  {
> > > -	nid = next_node(nid, node_online_map);
> > > +	nid = next_node(nid, *nodes_allowed);
> > >  	if (nid == MAX_NUMNODES)
> > > -		nid = first_node(node_online_map);
> > > +		nid = first_node(*nodes_allowed);
> > >  	VM_BUG_ON(nid >= MAX_NUMNODES);
> > >  
> > >  	return nid;
> > >  }
> > >  
> > > +static int this_node_allowed(int nid, nodemask_t *nodes_allowed)
> > > +{
> > > +	if (!node_isset(nid, *nodes_allowed))
> > > +		nid = next_node_allowed(nid, nodes_allowed);
> > > +	return nid;
> > > +}
> > 
> > Awkward name considering this doesn't simply return true or false as 
> > expected, it returns a nid.
> 
> Well, it's not a predicate function so I wouldn't expect true or false
> return, but I can see how the trailing "allowed" can sound like we're
> asking the question "Is this node allowed?".  Maybe,
> "get_this_node_allowed()" or "get_start_node_allowed" [we return the nid
> to "startnid"], ...  Or, do you have a suggestion?  
> 

this_node_allowed() just seemed like a very similar name to 
cpuset_zone_allowed() in the cpuset code, which does return true or false 
depending on whether the zone is allowed by current's cpuset.  As usual 
with the mempolicy discussions, I come from a biased cpuset perspective :)

> > 
> > > +
> > >  /*
> > >   * Use a helper variable to find the next node and then
> > >   * copy it back to next_nid_to_alloc afterwards:
> > > @@ -642,28 +652,34 @@ static int next_node_allowed(int nid)
> > >   * pass invalid nid MAX_NUMNODES to alloc_pages_exact_node.
> > >   * But we don't need to use a spin_lock here: it really
> > >   * doesn't matter if occasionally a racer chooses the
> > > - * same nid as we do.  Move nid forward in the mask even
> > > - * if we just successfully allocated a hugepage so that
> > > - * the next caller gets hugepages on the next node.
> > > + * same nid as we do.  Move nid forward in the mask whether
> > > + * or not we just successfully allocated a hugepage so that
> > > + * the next allocation addresses the next node.
> > >   */
> > > -static int hstate_next_node_to_alloc(struct hstate *h)
> > > +static int hstate_next_node_to_alloc(struct hstate *h,
> > > +					nodemask_t *nodes_allowed)
> > >  {
> > >  	int nid, next_nid;
> > >  
> > > -	nid = h->next_nid_to_alloc;
> > > -	next_nid = next_node_allowed(nid);
> > > +	if (!nodes_allowed)
> > > +		nodes_allowed = &node_online_map;
> > > +
> > > +	nid = this_node_allowed(h->next_nid_to_alloc, nodes_allowed);
> > > +
> > > +	next_nid = next_node_allowed(nid, nodes_allowed);
> > >  	h->next_nid_to_alloc = next_nid;
> > > +
> > >  	return nid;
> > >  }
> > 
> > Don't need next_nid.
> 
> Well, the pre-existing comment block indicated that the use of the
> apparently spurious next_nid variable is necessary to close a race.  Not
> sure whether that comment still applies with this rework.  What do you
> think?  
> 

What race is it closing exactly if gcc is going to optimize it out 
anyways?  I think you can safely fold the following into your patch.
---
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -659,15 +659,14 @@ static int this_node_allowed(int nid, nodemask_t *nodes_allowed)
 static int hstate_next_node_to_alloc(struct hstate *h,
 					nodemask_t *nodes_allowed)
 {
-	int nid, next_nid;
+	int nid;
 
 	if (!nodes_allowed)
 		nodes_allowed = &node_online_map;
 
 	nid = this_node_allowed(h->next_nid_to_alloc, nodes_allowed);
 
-	next_nid = next_node_allowed(nid, nodes_allowed);
-	h->next_nid_to_alloc = next_nid;
+	h->next_nid_to_alloc = next_node_allowed(nid, nodes_allowed);
 
 	return nid;
 }
@@ -707,15 +706,14 @@ static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
  */
 static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 {
-	int nid, next_nid;
+	int nid;
 
 	if (!nodes_allowed)
 		nodes_allowed = &node_online_map;
 
 	nid = this_node_allowed(h->next_nid_to_free, nodes_allowed);
 
-	next_nid = next_node_allowed(nid, nodes_allowed);
-	h->next_nid_to_free = next_nid;
+	h->next_nid_to_free = next_node_allowed(nid, nodes_allowed);
 
 	return nid;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
