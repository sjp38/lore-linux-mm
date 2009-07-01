Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DCB4E6B004D
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 12:18:58 -0400 (EDT)
Subject: Re: [RFC 2/3] hugetlb:  derive huge pages nodes allowed from task
	mempolicy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090701143227.GF16355@csn.ul.ie>
References: <20090630154716.1583.25274.sendpatchset@lts-notebook>
	 <20090630154818.1583.26154.sendpatchset@lts-notebook>
	 <20090701143227.GF16355@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 01 Jul 2009 12:19:24 -0400
Message-Id: <1246465164.23497.150.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-numa@vger.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 2009-07-01 at 15:32 +0100, Mel Gorman wrote:
> On Tue, Jun 30, 2009 at 11:48:18AM -0400, Lee Schermerhorn wrote:
> > [RFC 2/3] hugetlb:  derive huge pages nodes allowed from task mempolicy
> > 
> > Against: 25jun09 mmotm atop the "hugetlb: balance freeing..." series
> > 
> > This patch derives a "nodes_allowed" node mask from the numa
> > mempolicy of the task modifying the number of persistent huge
> > pages to control the allocation, freeing and adjusting of surplus
> > huge pages.  This mask is derived as follows:
> > 
> > * For "default" [NULL] task mempolicy, a NULL nodemask_t pointer
> >   is produced.  This will cause the hugetlb subsystem to use
> >   node_online_map as the "nodes_allowed".  This preserves the
> >   behavior before this patch.
> 
> Sensible.
> 
> > * For "preferred" mempolicy, including explicit local allocation,
> >   a nodemask with the single preferred node will be produced. 
> >   "local" policy will NOT track any internode migrations of the
> >   task adjusting nr_hugepages.
> 
> This excludes fallback and could do with an in-code comment. I whinge
> about this more later.
> 
> > * For "bind" and "interleave" policy, the mempolicy's nodemask
> >   will be used.
> 
> Sensible.
> 
> > * Other than to inform the construction of the nodes_allowed node
> >   mask, the actual mempolicy mode is ignored.  That is, all modes
> >   behave like interleave over the resulting nodes_allowed mask
> >   with no "fallback".
> > 
> 
> Again, seems sensible. Resizing the hugepage pool is not like a normal
> applications behaviour.
> 
> > Because we may have allocated or freed a huge page with a 
> > different policy/nodes_allowed previously, we always need to
> > check that the next_node_to_{alloc|free} exists in the current
> > nodes_allowed mask.  To avoid duplication of code, this is done
> > in the hstate_next_node_to_{alloc|free}() functions. 
> 
> Seems fair. While this means that some nodes could be skipped because there
> was a hugepage pool resize with a restricted policy and then no policy, I
> see little problem with that as such.  I believe you caught all the direct
> users of next_nid_to_[alloc|free] and used the helpers which is good.

Uh, I've been meaning to point out that I haven't modified
"try_to_free_low()" to use free_pool_huge_page().  The non-stub version
of try_to_free_low() is only compiled in when '_HIGHMEM is defined--i.e,
32-bit systems.  So, it will still drain nodes completely in node id
order.  If this is a problem and we want try_to_free_low() to balance
freeing, I can enhance free_pool_huge_page() to take another flag
[perhaps combining it with the "acct_surplus" in a single flags arg] to
free only !highmem pages and pass a node mask of any nodes containing
such pages. 

> 
> > So,
> > these functions have been modified to allow them to be called
> > to obtain the "start_nid".  Then, whereas prior to this patch
> > we unconditionally called hstate_next_node_to_{alloc|free}(),
> > whether or not we successfully allocated/freed a huge page on
> > the node, now we only call these functions on failure to alloc/free.
> > 
> > Notes:
> > 
> > 1) This patch introduces a subtle change in behavior:  huge page
> >    allocation and freeing will be constrained by any mempolicy
> >    that the task adjusting the huge page pool inherits from its
> >    parent.  This policy could come from a distant ancestor.  The
> >    adminstrator adjusting the huge page pool without explicitly
> >    specifying a mempolicy via numactl might be surprised by this.
> 
> I would be trying to encourage administrators to use hugeadm instead of
> manually tuning the pools. One possible course of action is for hugeadm
> to check if a policy is currently set and output that as an INFO message.
> That will show up if they run with hugeadm -v. Alternatively, we could note
> as a WARN when any policy is set and print an INFO message on details of
> the policy.

Yes.  I saw mention of direct access to the sysctls being deprecated.
I'm not sure how that will go over with users, but if go with changes
like this, it makes sense to handle them in hugeadm.

> 
> >    Additionaly, any mempolicy specified by numactl will be
> >    constrained by the cpuset in which numactl is invoked.
> > 
> > 2) Hugepages allocated at boot time use the node_online_map.
> >    An additional patch could implement a temporary boot time
> >    huge pages nodes_allowed command line parameter.
> > 
> 
> I'd want for someone to complain before implementing such a patch. Even
> on systems where hugepages must be allocated very early on, an init script
> should be more than sufficient without implementing parsing for mempolicies
> and hugepages.

I agree in principle.  I expect that if one can't allocate the required
number of huge pages in an early init script, either one really needs
more memory, or something is wrong with earlier scripts that is
fragmenting memory.  However, I'll point out that by the time one gets
such a complaint, there is a really long lead time before a change gets
into customer hands.  This is the downside of waiting for a complaint or
definitive use case before providing tunable parameters and such :(.

> 
> > See the updated documentation [next patch] for more information
> > about the implications of this patch.
> > 
> 
> Ideally the change log should show a before and after of using numactl +
> hugeadm to resize pools on a subset of available nodes.

I'll do that. 

> 
> > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> >  include/linux/mempolicy.h |    3 +
> >  mm/hugetlb.c              |   99 +++++++++++++++++++++++++++++++---------------
> >  mm/mempolicy.c            |   54 +++++++++++++++++++++++++
> >  3 files changed, 124 insertions(+), 32 deletions(-)
> > 
> > Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/hugetlb.c	2009-06-29 23:01:01.000000000 -0400
> > +++ linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c	2009-06-30 11:29:49.000000000 -0400
> > @@ -621,29 +621,52 @@ static struct page *alloc_fresh_huge_pag
> >  }
> >  
> >  /*
> > + * common helper functions for hstate_next_node_to_{alloc|free}.
> > + * We may have allocated or freed a huge pages based on a different
> > + * nodes_allowed, previously, so h->next_node_to_{alloc|free} might
> > + * be outside of *nodes_allowed.  Ensure that we use the next
> > + * allowed node for alloc or free.
> > + */
> > +static int next_node_allowed(int nid, nodemask_t *nodes_allowed)
> > +{
> > +	nid = next_node(nid, *nodes_allowed);
> > +	if (nid == MAX_NUMNODES)
> > +		nid = first_node(*nodes_allowed); /* handle "wrap" */
> > +	return nid;
> > +}
> 
> The handle warp comment is unnecessary there. This is such a common pattern,
> it should be self-evident without placing comments that cause the
> CodingStyle Police to issue tickets.

Thanks for the warning.  I'll remove it.

> 
> > +
> > +static int this_node_allowed(int nid, nodemask_t *nodes_allowed)
> > +{
> > +	if (!node_isset(nid, *nodes_allowed))
> > +		nid = next_node_allowed(nid, nodes_allowed);
> > +	return nid;
> > +}
> > +
> 
> What happens if node hot-remove occured and there is now no node that we
> are allowed to allocate from?

If we return a valid node id [see below] of an off-line node, the
allocation or free will fail and we'll advance to the next node.  If all
the nodes in the nodes_allowed are off-line, we'll end up with next_nid
== start_nid and bail out.

> 
> This thing will end up returning MAX_NUMNODES right? That potentially then
> gets passed to alloc_pages_exact_node() triggering a VM_BUG_ON() there.

No.  That's "next_node_allowed()"--the function above with the spurious
"handle wrap" comment--not the bare "next_node()".  So, we will "handle
wrap" appropriately.  

> 
> > +/*
> >   * Use a helper variable to find the next node and then
> >   * copy it back to next_nid_to_alloc afterwards:
> >   * otherwise there's a window in which a racer might
> >   * pass invalid nid MAX_NUMNODES to alloc_pages_exact_node.
> >   * But we don't need to use a spin_lock here: it really
> >   * doesn't matter if occasionally a racer chooses the
> > - * same nid as we do.  Move nid forward in the mask even
> > - * if we just successfully allocated a hugepage so that
> > - * the next caller gets hugepages on the next node.
> > + * same nid as we do.  Move nid forward in the mask whether
> > + * or not we just successfully allocated a hugepage so that
> > + * the next allocation addresses the next node.
> >   */
> >  static int hstate_next_node_to_alloc(struct hstate *h,
> >  					nodemask_t *nodes_allowed)
> >  {
> > -	int next_nid;
> > +	int nid, next_nid;
> >  
> >  	if (!nodes_allowed)
> >  		nodes_allowed = &node_online_map;
> >  
> > -	next_nid = next_node(h->next_nid_to_alloc, *nodes_allowed);
> > -	if (next_nid == MAX_NUMNODES)
> > -		next_nid = first_node(*nodes_allowed);
> > +	nid = this_node_allowed(h->next_nid_to_alloc, nodes_allowed);
> > +
> > +	next_nid = next_node_allowed(nid, nodes_allowed);
> >  	h->next_nid_to_alloc = next_nid;
> > -	return next_nid;
> > +
> > +	return nid;
> >  }
> >  
> 
> Seems reasonable. I see now what you mean about next_nid_to_alloc being more
> like its name in patch series than the last.
> 
> >  static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
> > @@ -653,15 +676,17 @@ static int alloc_fresh_huge_page(struct 
> >  	int next_nid;
> >  	int ret = 0;
> >  
> > -	start_nid = h->next_nid_to_alloc;
> > +	start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
> >  	next_nid = start_nid;
> >  
> 
> So, here for example, I think we need to make sure start_nid is not
> MAX_NUMNODES and bail out if it is.

See response above, re: this_node_allowed().  Do you still think it's a
problem?

> 
> >  	do {
> >  		page = alloc_fresh_huge_page_node(h, next_nid);
> > -		if (page)
> > +		if (page) {
> >  			ret = 1;
> > +			break;
> > +		}
> 
> Ok, so this break is necessary on allocation success because
> hstate_next_node_to_alloc() has already bumped next_nid_to_alloc. Right?

Right.  I don't want to fall thru and skip a node.  so, I break and
remove the !page from the loop condition.

However, since you mention it:  I noticed, since I sent this, that with
this arrangement we will skip a node id in the case that we visit all
nodes w/o successfully allocating a huge page or finding a huge page to
free.  When we hit the loop termination condition "next_nid ==
start_nid", we've already advanced hstate_next_node_to_{alloc|free}
beyond next_nid.   So, on next call, start_nid will become that value
and not the same start_nid we used before.

Example:  suppose we try to start a huge page [on, say, a 4 node] system
with no huge pages available anywhere; and the next_node_to_alloc == 0
when we first call alloc_fresh_huge_page().  start_nid will get '0' and
we'll examine nodes 0, 1, 2 and 3.  When hstate_next_node_to_alloc()
returns '0', we'll give up and return NULL page, but next_node_to_alloc
is now 1.  If we try again, maybe after we think some memory has been
freed up and we have a chance of succeeding, we'll visit 1, 2, 3 and 0
[if there are still no huge pages available].  And so forth.  I don't
think this is a problem because if we actually succeed in allocating or
freeing a page, we'll break w/o advancing next_node... and pick up there
on next call.

I have an idea for fixing this behavior, if anyone thinks it's a
problem, by "pushing back" the next_nid to the hstate with something
like:

	} while (next_nid != start_nid || push_back_alloc_node(next_nid))

where the push_back function always returns 0.  Kind of ugly, but I
think it would work.  I don't think it's needed, tho'.

> 
> >  		next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
> > -	} while (!page && next_nid != start_nid);
> > +	} while (next_nid != start_nid);
> >  
> >  	if (ret)
> >  		count_vm_event(HTLB_BUDDY_PGALLOC);
> > @@ -672,21 +697,23 @@ static int alloc_fresh_huge_page(struct 
> >  }
> >  
> >  /*
> > - * helper for free_pool_huge_page() - find next node
> > - * from which to free a huge page
> > + * helper for free_pool_huge_page() - return the next node
> > + * from which to free a huge page.  Advance the next node id
> > + * whether or not we find a free huge page to free so that the
> > + * next attempt to free addresses the next node.
> >   */
> >  static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
> >  {
> > -	int next_nid;
> > +	int nid, next_nid;
> >  
> >  	if (!nodes_allowed)
> >  		nodes_allowed = &node_online_map;
> >  
> > -	next_nid = next_node(h->next_nid_to_free, *nodes_allowed);
> > -	if (next_nid == MAX_NUMNODES)
> > -		next_nid = first_node(*nodes_allowed);
> > +	nid = this_node_allowed(h->next_nid_to_free, nodes_allowed);
> > +	next_nid = next_node_allowed(nid, nodes_allowed);
> >  	h->next_nid_to_free = next_nid;
> > -	return next_nid;
> > +
> > +	return nid;
> >  }
> >  
> >  /*
> > @@ -702,7 +729,7 @@ static int free_pool_huge_page(struct hs
> >  	int next_nid;
> >  	int ret = 0;
> >  
> > -	start_nid = h->next_nid_to_free;
> > +	start_nid = hstate_next_node_to_free(h, nodes_allowed);
> >  	next_nid = start_nid;
> >  
> 
> I guess if start_nid is MAX_NUMNODES here as well, we should bail out
> early. It means that a pool shrink by the requested number of pages may
> fail if there are not enough hugepages allocated on the allowed node but
> maybe that's not such a big problem.

Again, I don't that can happen.  ???

> 
> hugeadm will actually notice when this situation occurs and gives a
> warning about it.
> 
> >  	do {
> > @@ -726,9 +753,10 @@ static int free_pool_huge_page(struct hs
> >  			}
> >  			update_and_free_page(h, page);
> >  			ret = 1;
> > +			break;
> >  		}
> >   		next_nid = hstate_next_node_to_free(h, nodes_allowed);
> > -	} while (!ret && next_nid != start_nid);
> > +	} while (next_nid != start_nid);
> >  
> >  	return ret;
> >  }
> > @@ -1039,10 +1067,9 @@ int __weak alloc_bootmem_huge_page(struc
> >  		void *addr;
> >  
> >  		addr = __alloc_bootmem_node_nopanic(
> > -				NODE_DATA(h->next_nid_to_alloc),
> > +				NODE_DATA(hstate_next_node_to_alloc(h, NULL)),
> >  				huge_page_size(h), huge_page_size(h), 0);
> >  
> > -		hstate_next_node_to_alloc(h, NULL); /* always advance nid */
> >  		if (addr) {
> >  			/*
> >  			 * Use the beginning of the huge page to store the
> > @@ -1179,29 +1206,33 @@ static int adjust_pool_surplus(struct hs
> >  	VM_BUG_ON(delta != -1 && delta != 1);
> >  
> >  	if (delta < 0)
> > -		start_nid = h->next_nid_to_alloc;
> > +		start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
> >  	else
> > -		start_nid = h->next_nid_to_free;
> > +		start_nid = hstate_next_node_to_free(h, nodes_allowed);
> >  	next_nid = start_nid;
> >  
> >  	do {
> >  		int nid = next_nid;
> >  		if (delta < 0)  {
> > -			next_nid = hstate_next_node_to_alloc(h, nodes_allowed);
> >  			/*
> >  			 * To shrink on this node, there must be a surplus page
> >  			 */
> > -			if (!h->surplus_huge_pages_node[nid])
> > +			if (!h->surplus_huge_pages_node[nid]) {
> > +				next_nid = hstate_next_node_to_alloc(h,
> > +								nodes_allowed);
> >  				continue;
> > +			}
> >  		}
> >  		if (delta > 0) {
> > -			next_nid = hstate_next_node_to_free(h, nodes_allowed);
> >  			/*
> >  			 * Surplus cannot exceed the total number of pages
> >  			 */
> >  			if (h->surplus_huge_pages_node[nid] >=
> > -						h->nr_huge_pages_node[nid])
> > +						h->nr_huge_pages_node[nid]) {
> > +				next_nid = hstate_next_node_to_free(h,
> > +								nodes_allowed);
> >  				continue;
> > +			}
> >  		}
> >  
> >  		h->surplus_huge_pages += delta;
> > @@ -1217,10 +1248,13 @@ static int adjust_pool_surplus(struct hs
> >  static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
> >  {
> >  	unsigned long min_count, ret;
> > +	nodemask_t *nodes_allowed;
> >  
> >  	if (h->order >= MAX_ORDER)
> >  		return h->max_huge_pages;
> >  
> > +	nodes_allowed = huge_mpol_nodes_allowed();
> > +
> >  	/*
> >  	 * Increase the pool size
> >  	 * First take pages out of surplus state.  Then make up the
> > @@ -1234,7 +1268,7 @@ static unsigned long set_max_huge_pages(
> >  	 */
> >  	spin_lock(&hugetlb_lock);
> >  	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
> > -		if (!adjust_pool_surplus(h, NULL, -1))
> > +		if (!adjust_pool_surplus(h, nodes_allowed, -1))
> >  			break;
> >  	}
> >  
> > @@ -1245,7 +1279,7 @@ static unsigned long set_max_huge_pages(
> >  		 * and reducing the surplus.
> >  		 */
> >  		spin_unlock(&hugetlb_lock);
> > -		ret = alloc_fresh_huge_page(h, NULL);
> > +		ret = alloc_fresh_huge_page(h, nodes_allowed);
> >  		spin_lock(&hugetlb_lock);
> >  		if (!ret)
> >  			goto out;
> > @@ -1271,16 +1305,17 @@ static unsigned long set_max_huge_pages(
> >  	min_count = max(count, min_count);
> >  	try_to_free_low(h, min_count);
> >  	while (min_count < persistent_huge_pages(h)) {
> > -		if (!free_pool_huge_page(h, NULL, 0))
> > +		if (!free_pool_huge_page(h, nodes_allowed, 0))
> >  			break;
> >  	}
> >  	while (count < persistent_huge_pages(h)) {
> > -		if (!adjust_pool_surplus(h, NULL, 1))
> > +		if (!adjust_pool_surplus(h, nodes_allowed, 1))
> >  			break;
> >  	}
> >  out:
> >  	ret = persistent_huge_pages(h);
> >  	spin_unlock(&hugetlb_lock);
> > +	kfree(nodes_allowed);
> >  	return ret;
> >  }
> >  
> > Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/mempolicy.c
> > ===================================================================
> > --- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/mempolicy.c	2009-06-29 12:18:11.000000000 -0400
> > +++ linux-2.6.31-rc1-mmotm-090625-1549/mm/mempolicy.c	2009-06-29 23:11:35.000000000 -0400
> > @@ -1544,6 +1544,60 @@ struct zonelist *huge_zonelist(struct vm
> >  	}
> >  	return zl;
> >  }
> > +
> > +/**
> > + * huge_mpol_nodes_allowed()
> > + *
> > + * Return a [pointer to a] nodelist for persistent huge page allocation
> > + * based on the current task's mempolicy:
> > + *
> > + * If the task's mempolicy is "default" [NULL], just return NULL for
> > + * default behavior.  Otherwise, extract the policy nodemask for 'bind'
> > + * or 'interleave' policy or construct a nodemask for 'preferred' or
> > + * 'local' policy and return a pointer to a kmalloc()ed nodemask_t.
> > + * It is the caller's responsibility to free this nodemask.
> > + */
> > +nodemask_t *huge_mpol_nodes_allowed(void)
> > +{
> > +	nodemask_t *nodes_allowed = NULL;
> > +	struct mempolicy *mempolicy;
> > +	int nid;
> > +
> > +	if (!current || !current->mempolicy)
> > +		return NULL;
> > +
> 
> Is it really possible for current to be NULL here?

Not sure.  I've hit NULL current in mempolicy functions called at init
time before.  Maybe a [VM_]BUG_ON() would be preferable?

> 
> > +	mpol_get(current->mempolicy);
> > +	nodes_allowed = kzalloc(sizeof(*nodes_allowed), GFP_KERNEL);
> > +	if (!nodes_allowed) {
> > +		printk(KERN_WARNING "Unable to allocate nodes allowed mask "
> > +			"for huge page allocation\nFalling back to default\n");
> > +		goto out;
> > +	}
> 
> In terms of memory policies, the huge_mpol_nodes_allowed() would appear
> to be unique in allocating a nodemask and expecting the caller to free it
> without leaking. Would it be possible to move the kzalloc() to the caller
> of huge_mpol_nodes_allowed()? It'd be less surprising to me.

I thought doing that.  Then, I'd have to return an indication of whether
to use the allocated mask, or free it and use NULL.  This seemed
cleaner, as set_max_huge_pages() is the only caller of
huge_mpol_nodes_allowed(), which I thought really should go in
mempolicy.c [like huge_zonelist()].  And I did note the caller's
responsibility here...

> 
> I take it you are not allocating nodemask_t on the stack of the caller because
> potentially nodemask_t is very large if MAX_NUMNODES is a big number. Is
> that accurate?

Well, that and the fact that I need to pass NULL to the alloc/free
functions when we have default policy.  I'd still need a nodes_allowed
pointer and you know how you hate having both the nodemask_t and the
pointer :).

> 
> nodemasks are meant to be cleared with nodes_clear() but you depend on
> kzalloc() zeroing the bitmap for you. While the end result is the same,
> is using kzalloc instead of kmalloc+nodes_clear() considered ok?

That did cross my mind.  And, it's not exactly a fast path.  Shall I
change it to kmalloc+nodes_clear()?  Or maybe add a nodemask_alloc() or
nodemask_new() function?  We don't have one of those, as nodemasks have
mostly been passed around by value rather than reference.

> 
> > +
> > +	mempolicy = current->mempolicy;
> > +	switch(mempolicy->mode) {
> > +	case MPOL_PREFERRED:
> > +		if (mempolicy->flags & MPOL_F_LOCAL)
> > +			nid = numa_node_id();
> > +		else
> > +			nid = mempolicy->v.preferred_node;
> > +		node_set(nid, *nodes_allowed);
> > +		break;
> > +
> 
> I think a comment is needed here saying that MPOL_PREFERRED when
> resizing the pool acts more like MPOL_BIND to the preferred node with no
> fallback.

Yeah, I can add such a comment.  I did document this in the hugetlbfs
doc, but I guess it's good to have it here, as well.

> 
> I see your problem though. You can't use set the next_nid to allocate from
> to be the preferred node because the second allocation will interleave away
> from it though. How messy would it be to check if the MPOL_PREFERRED policy
> was in use and avoid updating next_nid_to_alloc while the preferred node is
> being allocated from?
> 
> It's not a big issue and I'd be ok with your current behaviour to start with.

Yeah, and I don't think we want the hugetlb.c code directly looking at
mempolicy internals.  I'd have to add another one user helper function,
probably in mempolicy.h.  Not a biggy, but I didn't think it was
necessary.  It doesn't hurt to reiterate that allocations for populating
the huge page pool do not fallback.

> 
> > +	case MPOL_BIND:
> > +		/* Fall through */
> > +	case MPOL_INTERLEAVE:
> > +			*nodes_allowed =  mempolicy->v.nodes;
> > +		break;
> > +
> > +	default:
> > +		BUG();
> > +	}
> > +
> > +out:
> > +	mpol_put(current->mempolicy);
> > +	return nodes_allowed;
> > +}
> >  #endif
> >  
> >  /* Allocate a page in interleaved policy.
> > Index: linux-2.6.31-rc1-mmotm-090625-1549/include/linux/mempolicy.h
> > ===================================================================
> > --- linux-2.6.31-rc1-mmotm-090625-1549.orig/include/linux/mempolicy.h	2009-06-29 12:18:11.000000000 -0400
> > +++ linux-2.6.31-rc1-mmotm-090625-1549/include/linux/mempolicy.h	2009-06-29 23:06:34.000000000 -0400
> > @@ -201,6 +201,7 @@ extern void mpol_fix_fork_child_flag(str
> >  extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
> >  				unsigned long addr, gfp_t gfp_flags,
> >  				struct mempolicy **mpol, nodemask_t **nodemask);
> > +extern nodemask_t *huge_mpol_nodes_allowed(void);
> >  extern unsigned slab_node(struct mempolicy *policy);
> >  
> >  extern enum zone_type policy_zone;
> > @@ -328,6 +329,8 @@ static inline struct zonelist *huge_zone
> >  	return node_zonelist(0, gfp_flags);
> >  }
> >  
> > +static inline nodemask_t *huge_mpol_nodes_allowed(void) { return NULL; }
> > +
> >  static inline int do_migrate_pages(struct mm_struct *mm,
> >  			const nodemask_t *from_nodes,
> >  			const nodemask_t *to_nodes, int flags)
> > 
> 
> By and large, this patch would appear to result in reasonable behaviour
> for administrators that want to limit the hugepage pool to specific
> nodes. Predictably, I prefer this approach to the nodemask-sysctl
> approach :/ . With a few crinkles ironed out, I reckon I'd be happy with
> this. Certainly, it appears to work as advertised in that I was able to
> accurate grow/shrink the pool on specific nodes.
> 

Having written the patch, I'm beginning to warm up to this approach
myself :).  We need to understand and advertise any apparently change in
behavior to be sure others agree.

Thanks for the review,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
