Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 74E4F6B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 16:08:18 -0400 (EDT)
Subject: Re: [PATCH 1/11] hugetlb:  rework hstate_next_node_* functions
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0909221100000.10595@chino.kir.corp.google.com>
References: <20090915204327.4828.4349.sendpatchset@localhost.localdomain>
	 <20090915204333.4828.47722.sendpatchset@localhost.localdomain>
	 <alpine.DEB.1.00.0909221100000.10595@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Tue, 22 Sep 2009 16:08:15 -0400
Message-Id: <1253650095.4973.12.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-09-22 at 11:08 -0700, David Rientjes wrote: 
> On Tue, 15 Sep 2009, Lee Schermerhorn wrote:
> 
> > Index: linux-2.6.31-mmotm-090914-0157/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.31-mmotm-090914-0157.orig/mm/hugetlb.c	2009-09-15 13:23:01.000000000 -0400
> > +++ linux-2.6.31-mmotm-090914-0157/mm/hugetlb.c	2009-09-15 13:42:14.000000000 -0400
> > @@ -622,6 +622,20 @@ static struct page *alloc_fresh_huge_pag
> >  }
> >  
> >  /*
> > + * common helper function for hstate_next_node_to_{alloc|free}.
> > + * return next node in node_online_map, wrapping at end.
> > + */
> > +static int next_node_allowed(int nid)
> > +{
> > +	nid = next_node(nid, node_online_map);
> > +	if (nid == MAX_NUMNODES)
> > +		nid = first_node(node_online_map);
> > +	VM_BUG_ON(nid >= MAX_NUMNODES);
> > +
> > +	return nid;
> > +}
> > +
> > +/*
> >   * Use a helper variable to find the next node and then
> >   * copy it back to next_nid_to_alloc afterwards:
> >   * otherwise there's a window in which a racer might
> > @@ -634,12 +648,12 @@ static struct page *alloc_fresh_huge_pag
> >   */
> >  static int hstate_next_node_to_alloc(struct hstate *h)
> >  {
> > -	int next_nid;
> > -	next_nid = next_node(h->next_nid_to_alloc, node_online_map);
> > -	if (next_nid == MAX_NUMNODES)
> > -		next_nid = first_node(node_online_map);
> > +	int nid, next_nid;
> > +
> > +	nid = h->next_nid_to_alloc;
> > +	next_nid = next_node_allowed(nid);
> >  	h->next_nid_to_alloc = next_nid;
> > -	return next_nid;
> > +	return nid;
> >  }
> >  
> >  static int alloc_fresh_huge_page(struct hstate *h)
> 
> I thought you had refactored this to drop next_nid entirely since gcc 
> optimizes it away?

Looks like I handled that in the subsequent patch.  Probably you had
commented about removing next_nid on that patch.

> >  /*
> > - * helper for free_pool_huge_page() - find next node
> > - * from which to free a huge page
> > + * helper for free_pool_huge_page() - return the next node
> > + * from which to free a huge page.  Advance the next node id
> > + * whether or not we find a free huge page to free so that the
> > + * next attempt to free addresses the next node.
> >   */
> >  static int hstate_next_node_to_free(struct hstate *h)
> >  {
> > -	int next_nid;
> > -	next_nid = next_node(h->next_nid_to_free, node_online_map);
> > -	if (next_nid == MAX_NUMNODES)
> > -		next_nid = first_node(node_online_map);
> > +	int nid, next_nid;
> > +
> > +	nid = h->next_nid_to_free;
> > +	next_nid = next_node_allowed(nid);
> >  	h->next_nid_to_free = next_nid;
> > -	return next_nid;
> > +	return nid;
> >  }
> >  
> >  /*
> 
> Ditto for next_nid.

Same.  

> 
> > @@ -693,7 +711,7 @@ static int free_pool_huge_page(struct hs
> >  	int next_nid;
> >  	int ret = 0;
> >  
> > -	start_nid = h->next_nid_to_free;
> > +	start_nid = hstate_next_node_to_free(h);
> >  	next_nid = start_nid;
> >  
> >  	do {
> > @@ -715,9 +733,10 @@ static int free_pool_huge_page(struct hs
> >  			}
> >  			update_and_free_page(h, page);
> >  			ret = 1;
> > +			break;
> >  		}
> >  		next_nid = hstate_next_node_to_free(h);
> > -	} while (!ret && next_nid != start_nid);
> > +	} while (next_nid != start_nid);
> >  
> >  	return ret;
> >  }
> > @@ -1028,10 +1047,9 @@ int __weak alloc_bootmem_huge_page(struc
> >  		void *addr;
> >  
> >  		addr = __alloc_bootmem_node_nopanic(
> > -				NODE_DATA(h->next_nid_to_alloc),
> > +				NODE_DATA(hstate_next_node_to_alloc(h)),
> >  				huge_page_size(h), huge_page_size(h), 0);
> >  
> > -		hstate_next_node_to_alloc(h);
> >  		if (addr) {
> >  			/*
> >  			 * Use the beginning of the huge page to store the
> 
> Shouldn't that panic if hstate_next_node_to_alloc() returns a memoryless 
> node since it uses node_online_map?

Well, the code has always been like this.  And, these allocs shouldn't
panic given a memoryless node.  The run time ones don't anyway.  If
'_THISNODE' is specified, it'll just fail with a NULL addr, else it's
walk the generic zonelist to find the first node that can provide the
requested page size.  Of course, we don't want that fallback when
populating the pools with persistent huge pages, so we always use the
THISNODE flag.

Having said that, I've only recently started to [try to] create the
gigabyte pages on my x86_64 [Shanghai] test system, but haven't been
able to allocate any GB pages.  2.6.31 seems to hang early in boot with
the command line options:  "hugepagesz=1GB, hugepages=16".  I've got
256GB of memory on this system, so 16GB shouldn't be a problem to find
at boot time.  Just started looking at this.

Meanwhile, with the full series, that online_node_map should be replaced
with node_states[N_HIGH_MEMORY] in a later patch.  I wanted to keep the
replacement of online_node_map with node_states[N_HIGH_MEMORY] to a
separate patch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
