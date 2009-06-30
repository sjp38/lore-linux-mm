Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BEEA26B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 09:56:46 -0400 (EDT)
Date: Tue, 30 Jun 2009 14:58:30 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] Balance Freeing of Huge Pages across Nodes
Message-ID: <20090630135830.GE17561@csn.ul.ie>
References: <20090629215226.20038.42028.sendpatchset@lts-notebook> <20090629215234.20038.62303.sendpatchset@lts-notebook> <20090630130515.GD17561@csn.ul.ie> <1246369691.25302.20.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1246369691.25302.20.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 09:48:11AM -0400, Lee Schermerhorn wrote:
> On Tue, 2009-06-30 at 14:05 +0100, Mel Gorman wrote:
> > On Mon, Jun 29, 2009 at 05:52:34PM -0400, Lee Schermerhorn wrote:
> > > [PATCH] 1/3 Balance Freeing of Huge Pages across Nodes
> > > 
> > > Against:  25jun09 mmotm
> > > 
> > > Free huges pages from nodes in round robin fashion in an
> > > attempt to keep [persistent a.k.a static] hugepages balanced
> > > across nodes
> > > 
> > > New function free_pool_huge_page() is modeled on and
> > > performs roughly the inverse of alloc_fresh_huge_page().
> > > Replaces dequeue_huge_page() which now has no callers,
> > > so this patch removes it.
> > > 
> > > Helper function hstate_next_node_to_free() uses new hstate
> > > member next_to_free_nid to distribute "frees" across all
> > > nodes with huge pages.
> > > 
> > > V2:
> > > 
> > > At Mel Gorman's suggestion:  renamed hstate_next_node() to
> > > hstate_next_node_to_alloc() for symmetry.  Also, renamed
> > > hstate member hugetlb_next_node to next_node_to_free.
> > > ["hugetlb" is implicit in the hstate struct, I think].
> > > 
> > > New in this version:
> > > 
> > > Modified adjust_pool_surplus() to use hstate_next_node_to_alloc()
> > > and hstate_next_node_to_free() to advance node id for adjusting
> > > surplus huge page count, as this is equivalent to allocating and
> > > freeing persistent huge pages.  [Can't blame Mel for this part.]
> > > 
> > > V3:
> > > 
> > > Minor cleanup: rename 'nid' to 'next_nid' in free_pool_huge_page() to
> > > better match alloc_fresh_huge_page() conventions.
> > > 
> > > Acked-by: David Rientjes <rientjes@google.com>
> > > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > > 
> > >  include/linux/hugetlb.h |    3 -
> > >  mm/hugetlb.c            |  132 +++++++++++++++++++++++++++++++-----------------
> > >  2 files changed, 88 insertions(+), 47 deletions(-)
> > > 
> > > Index: linux-2.6.31-rc1-mmotm-090625-1549/include/linux/hugetlb.h
> > > ===================================================================
> > > --- linux-2.6.31-rc1-mmotm-090625-1549.orig/include/linux/hugetlb.h	2009-06-29 10:21:12.000000000 -0400
> > > +++ linux-2.6.31-rc1-mmotm-090625-1549/include/linux/hugetlb.h	2009-06-29 10:27:18.000000000 -0400
> > > @@ -183,7 +183,8 @@ unsigned long hugetlb_get_unmapped_area(
> > >  #define HSTATE_NAME_LEN 32
> > >  /* Defines one hugetlb page size */
> > >  struct hstate {
> > > -	int hugetlb_next_nid;
> > > +	int next_nid_to_alloc;
> > > +	int next_nid_to_free;
> > >  	unsigned int order;
> > >  	unsigned long mask;
> > >  	unsigned long max_huge_pages;
> > > Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c
> > > ===================================================================
> > > --- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/hugetlb.c	2009-06-29 10:21:12.000000000 -0400
> > > +++ linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c	2009-06-29 15:53:55.000000000 -0400
> > > @@ -455,24 +455,6 @@ static void enqueue_huge_page(struct hst
> > >  	h->free_huge_pages_node[nid]++;
> > >  }
> > >  
> > > -static struct page *dequeue_huge_page(struct hstate *h)
> > > -{
> > > -	int nid;
> > > -	struct page *page = NULL;
> > > -
> > > -	for (nid = 0; nid < MAX_NUMNODES; ++nid) {
> > > -		if (!list_empty(&h->hugepage_freelists[nid])) {
> > > -			page = list_entry(h->hugepage_freelists[nid].next,
> > > -					  struct page, lru);
> > > -			list_del(&page->lru);
> > > -			h->free_huge_pages--;
> > > -			h->free_huge_pages_node[nid]--;
> > > -			break;
> > > -		}
> > > -	}
> > > -	return page;
> > > -}
> > > -
> > >  static struct page *dequeue_huge_page_vma(struct hstate *h,
> > >  				struct vm_area_struct *vma,
> > >  				unsigned long address, int avoid_reserve)
> > > @@ -640,7 +622,7 @@ static struct page *alloc_fresh_huge_pag
> > >  
> > >  /*
> > >   * Use a helper variable to find the next node and then
> > > - * copy it back to hugetlb_next_nid afterwards:
> > > + * copy it back to next_nid_to_alloc afterwards:
> > >   * otherwise there's a window in which a racer might
> > >   * pass invalid nid MAX_NUMNODES to alloc_pages_exact_node.
> > >   * But we don't need to use a spin_lock here: it really
> > > @@ -649,13 +631,13 @@ static struct page *alloc_fresh_huge_pag
> > >   * if we just successfully allocated a hugepage so that
> > >   * the next caller gets hugepages on the next node.
> > >   */
> > > -static int hstate_next_node(struct hstate *h)
> > > +static int hstate_next_node_to_alloc(struct hstate *h)
> > >  {
> > >  	int next_nid;
> > > -	next_nid = next_node(h->hugetlb_next_nid, node_online_map);
> > > +	next_nid = next_node(h->next_nid_to_alloc, node_online_map);
> > >  	if (next_nid == MAX_NUMNODES)
> > >  		next_nid = first_node(node_online_map);
> > > -	h->hugetlb_next_nid = next_nid;
> > > +	h->next_nid_to_alloc = next_nid;
> > >  	return next_nid;
> > >  }
> > >  
> > 
> > Strictly speaking, next_nid_to_alloc looks more like last_nid_alloced but I
> > don't think it makes an important difference. Implementing it this way is
> > shorter and automatically ensures next_nid is an online node. 
> > 
> > If you wanted to be pedantic, I think the following untested code would
> > make it really next_nid_to_alloc but I don't think it's terribly
> > important.
> > 
> > static int hstate_next_node_to_alloc(struct hstate *h)
> > {
> > 	int this_nid = h->next_nid_to_alloc;
> > 
> > 	/* Check the node didn't get off-lined since */
> > 	if (unlikely(!node_online(next_nid))) {
> > 		this_nid = next_node(h->next_nid_to_alloc, node_online_map);
> > 		h->next_nid_to_alloc = this_nid;
> > 	}
> > 
> > 	h->next_nid_to_alloc = next_node(h->next_nid_to_alloc, node_online_map);
> > 	if (h->next_nid_to_alloc == MAX_NUMNODES)
> > 		h->next_nid_to_alloc = first_node(node_online_map);
> > 
> > 	return this_nid;
> > }
> 
> Mel:  
> 
> I'm about to send out a series that constrains [persistent] huge page
> alloc and free using task mempolicy, per your suggestion.  The functions
> 'next_node_to_{alloc|free} and how they're used get reworked in that
> series quite a bit, and the name becomes more accurate, I think.  And, I
> think it does handle the node going offline along with handling changing
> to a new policy nodemask that doesn't include the value saved in the
> hstate.  We can revisit this, then.
> 

Sounds good.

> However, the way we currently use these functions, they do update the
> 'next_node_*' field in the hstate, and where the return value is tested
> [against start_nid], it really is the "next" node. 

Good point.

> If the alloc/free
> succeeds, then the return value does turn out to be the [last] node we
> just alloc'd/freed on.  But, again, we've advanced the next node to
> alloc/free in the hstate.  A nit, I think :).
> 

It's enough of a concern to go with your current version.

> > 
> > > @@ -666,14 +648,15 @@ static int alloc_fresh_huge_page(struct 
> > >  	int next_nid;
> > >  	int ret = 0;
> > >  
> > > -	start_nid = h->hugetlb_next_nid;
> > > +	start_nid = h->next_nid_to_alloc;
> > > +	next_nid = start_nid;
> > >  
> > >  	do {
> > > -		page = alloc_fresh_huge_page_node(h, h->hugetlb_next_nid);
> > > +		page = alloc_fresh_huge_page_node(h, next_nid);
> > >  		if (page)
> > >  			ret = 1;
> > > -		next_nid = hstate_next_node(h);
> > > -	} while (!page && h->hugetlb_next_nid != start_nid);
> > > +		next_nid = hstate_next_node_to_alloc(h);
> > > +	} while (!page && next_nid != start_nid);
> > >  
> > >  	if (ret)
> > >  		count_vm_event(HTLB_BUDDY_PGALLOC);
> > > @@ -683,6 +666,52 @@ static int alloc_fresh_huge_page(struct 
> > >  	return ret;
> > >  }
> > >  
> > > +/*
> > > + * helper for free_pool_huge_page() - find next node
> > > + * from which to free a huge page
> > > + */
> > > +static int hstate_next_node_to_free(struct hstate *h)
> > > +{
> > > +	int next_nid;
> > > +	next_nid = next_node(h->next_nid_to_free, node_online_map);
> > > +	if (next_nid == MAX_NUMNODES)
> > > +		next_nid = first_node(node_online_map);
> > > +	h->next_nid_to_free = next_nid;
> > > +	return next_nid;
> > > +}
> > > +
> > > +/*
> > > + * Free huge page from pool from next node to free.
> > > + * Attempt to keep persistent huge pages more or less
> > > + * balanced over allowed nodes.
> > > + * Called with hugetlb_lock locked.
> > > + */
> > > +static int free_pool_huge_page(struct hstate *h)
> > > +{
> > > +	int start_nid;
> > > +	int next_nid;
> > > +	int ret = 0;
> > > +
> > > +	start_nid = h->next_nid_to_free;
> > > +	next_nid = start_nid;
> > > +
> > > +	do {
> > > +		if (!list_empty(&h->hugepage_freelists[next_nid])) {
> > > +			struct page *page =
> > > +				list_entry(h->hugepage_freelists[next_nid].next,
> > > +					  struct page, lru);
> > > +			list_del(&page->lru);
> > > +			h->free_huge_pages--;
> > > +			h->free_huge_pages_node[next_nid]--;
> > > +			update_and_free_page(h, page);
> > > +			ret = 1;
> > > +		}
> > > +		next_nid = hstate_next_node_to_free(h);
> > > +	} while (!ret && next_nid != start_nid);
> > > +
> > > +	return ret;
> > > +}
> > > +
> > >  static struct page *alloc_buddy_huge_page(struct hstate *h,
> > >  			struct vm_area_struct *vma, unsigned long address)
> > >  {
> > > @@ -1007,7 +1036,7 @@ int __weak alloc_bootmem_huge_page(struc
> > >  		void *addr;
> > >  
> > >  		addr = __alloc_bootmem_node_nopanic(
> > > -				NODE_DATA(h->hugetlb_next_nid),
> > > +				NODE_DATA(h->next_nid_to_alloc),
> > >  				huge_page_size(h), huge_page_size(h), 0);
> > >  
> > >  		if (addr) {
> > > @@ -1019,7 +1048,7 @@ int __weak alloc_bootmem_huge_page(struc
> > >  			m = addr;
> > >  			goto found;
> > >  		}
> > > -		hstate_next_node(h);
> > > +		hstate_next_node_to_alloc(h);
> > >  		nr_nodes--;
> > >  	}
> > >  	return 0;
> > > @@ -1140,31 +1169,43 @@ static inline void try_to_free_low(struc
> > >   */
> > >  static int adjust_pool_surplus(struct hstate *h, int delta)
> > >  {
> > > -	static int prev_nid;
> > > -	int nid = prev_nid;
> > > +	int start_nid, next_nid;
> > >  	int ret = 0;
> > >  
> > >  	VM_BUG_ON(delta != -1 && delta != 1);
> > > -	do {
> > > -		nid = next_node(nid, node_online_map);
> > > -		if (nid == MAX_NUMNODES)
> > > -			nid = first_node(node_online_map);
> > >  
> > > -		/* To shrink on this node, there must be a surplus page */
> > > -		if (delta < 0 && !h->surplus_huge_pages_node[nid])
> > > -			continue;
> > > -		/* Surplus cannot exceed the total number of pages */
> > > -		if (delta > 0 && h->surplus_huge_pages_node[nid] >=
> > > +	if (delta < 0)
> > > +		start_nid = h->next_nid_to_alloc;
> > > +	else
> > > +		start_nid = h->next_nid_to_free;
> > > +	next_nid = start_nid;
> > > +
> > > +	do {
> > > +		int nid = next_nid;
> > > +		if (delta < 0)  {
> > > +			next_nid = hstate_next_node_to_alloc(h);
> > > +			/*
> > > +			 * To shrink on this node, there must be a surplus page
> > > +			 */
> > > +			if (!h->surplus_huge_pages_node[nid])
> > > +				continue;
> > > +		}
> > > +		if (delta > 0) {
> > > +			next_nid = hstate_next_node_to_free(h);
> > > +			/*
> > > +			 * Surplus cannot exceed the total number of pages
> > > +			 */
> > > +			if (h->surplus_huge_pages_node[nid] >=
> > >  						h->nr_huge_pages_node[nid])
> > > -			continue;
> > > +				continue;
> > > +		}
> > >  
> > >  		h->surplus_huge_pages += delta;
> > >  		h->surplus_huge_pages_node[nid] += delta;
> > >  		ret = 1;
> > >  		break;
> > > -	} while (nid != prev_nid);
> > > +	} while (next_nid != start_nid);
> > >  
> > > -	prev_nid = nid;
> > >  	return ret;
> > >  }
> > >  
> > > @@ -1226,10 +1267,8 @@ static unsigned long set_max_huge_pages(
> > >  	min_count = max(count, min_count);
> > >  	try_to_free_low(h, min_count);
> > >  	while (min_count < persistent_huge_pages(h)) {
> > > -		struct page *page = dequeue_huge_page(h);
> > > -		if (!page)
> > > +		if (!free_pool_huge_page(h))
> > >  			break;
> > > -		update_and_free_page(h, page);
> > >  	}
> > >  	while (count < persistent_huge_pages(h)) {
> > >  		if (!adjust_pool_surplus(h, 1))
> > > @@ -1441,7 +1480,8 @@ void __init hugetlb_add_hstate(unsigned 
> > >  	h->free_huge_pages = 0;
> > >  	for (i = 0; i < MAX_NUMNODES; ++i)
> > >  		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
> > > -	h->hugetlb_next_nid = first_node(node_online_map);
> > > +	h->next_nid_to_alloc = first_node(node_online_map);
> > > +	h->next_nid_to_free = first_node(node_online_map);
> > >  	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
> > >  					huge_page_size(h)/1024);
> > >  
> > 
> > Nothing problematic jumps out at me. Even with hstate_next_node_to_alloc()
> > as it is;
> > 
> > Acked-by: Mel Gorman <mel@csn.ul.ie>
> > 
> 
> Thanks.  It did seem to test out OK on ia64 [12jun mmotm; 25jun mmotm
> has a problem there--TBI] and x86_64.  Could use more testing, tho'.
> Especially with various combinations of persistent and surplus huge
> pages. 

No harm in that. I've tested the patches a bit and spotted nothing problematic
to do specifically with your patches. I am able to trigger the OOM killer
with disturbing lines such as

heap-overflow invoked oom-killer: gfp_mask=0x0, order=0, oom_adj=0

but I haven't determined if this is something new in mainline or on mmotm yet.

> I saw you mention that you have a hugetlb regression test suite.
> Is that available "out there, somewhere"?  I just grabbed a libhugetlbfs
> source rpm, but haven't cracked it yet.  Maybe it's there?
> 

It probably is, but I'm not certain. You're better off downloading from
http://sourceforge.net/projects/libhugetlbfs and doing something like

make
./obj/hugeadm --pool-pages-min 2M:64
./obj/hugeadm --create-global-mounts
make func

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
