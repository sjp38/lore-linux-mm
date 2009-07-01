Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DFC316B005A
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 15:44:29 -0400 (EDT)
Subject: Re: [RFC 2/3] hugetlb:  derive huge pages nodes allowed from task
	mempolicy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090701182953.GJ16355@csn.ul.ie>
References: <20090630154716.1583.25274.sendpatchset@lts-notebook>
	 <20090630154818.1583.26154.sendpatchset@lts-notebook>
	 <20090701143227.GF16355@csn.ul.ie>
	 <1246465164.23497.150.camel@lts-notebook>
	 <20090701182953.GJ16355@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 01 Jul 2009 15:45:45 -0400
Message-Id: <1246477545.23497.263.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-numa@vger.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 2009-07-01 at 19:29 +0100, Mel Gorman wrote:
> On Wed, Jul 01, 2009 at 12:19:24PM -0400, Lee Schermerhorn wrote:
> > On Wed, 2009-07-01 at 15:32 +0100, Mel Gorman wrote:
> > > On Tue, Jun 30, 2009 at 11:48:18AM -0400, Lee Schermerhorn wrote:
> > > > [RFC 2/3] hugetlb:  derive huge pages nodes allowed from task mempolicy
> > > > 
> > > > Against: 25jun09 mmotm atop the "hugetlb: balance freeing..." series
> > > > 
> > > > This patch derives a "nodes_allowed" node mask from the numa
> > > > mempolicy of the task modifying the number of persistent huge
> > > > pages to control the allocation, freeing and adjusting of surplus
> > > > huge pages.  
<snip>
> > > > Notes:
> > > > 
> > > > 1) This patch introduces a subtle change in behavior:  huge page
> > > >    allocation and freeing will be constrained by any mempolicy
> > > >    that the task adjusting the huge page pool inherits from its
> > > >    parent.  This policy could come from a distant ancestor.  The
> > > >    adminstrator adjusting the huge page pool without explicitly
> > > >    specifying a mempolicy via numactl might be surprised by this.
> > > 
> > > I would be trying to encourage administrators to use hugeadm instead of
> > > manually tuning the pools. One possible course of action is for hugeadm
> > > to check if a policy is currently set and output that as an INFO message.
> > > That will show up if they run with hugeadm -v. Alternatively, we could note
> > > as a WARN when any policy is set and print an INFO message on details of
> > > the policy.
> > 
> > Yes.  I saw mention of direct access to the sysctls being deprecated.
> > I'm not sure how that will go over with users, but if go with changes
> > like this, it makes sense to handle them in hugeadm.
> > 
> 
> In this case, we're only worried about notifying the user if they are
> under a policy. If they are accessing the sysctl's directly, there is
> not much that can be done to warn them.

Agree.  Using the tool allows us to warn the user.  Actually, we could
add a mempolicy argument to hugeadm and have it set the policy
explicitly and warn when it inherits a non-default one w/o an explicit
argument.  For users that still want to poke at the sysctls and
attributes directly, numactl will still work.  But, as you say, they're
on their own.

> 
> > > 
> > > >    Additionaly, any mempolicy specified by numactl will be
> > > >    constrained by the cpuset in which numactl is invoked.
> > > > 
> > > > 2) Hugepages allocated at boot time use the node_online_map.
> > > >    An additional patch could implement a temporary boot time
> > > >    huge pages nodes_allowed command line parameter.
> > > > 
> > > 
> > > I'd want for someone to complain before implementing such a patch. Even
> > > on systems where hugepages must be allocated very early on, an init script
> > > should be more than sufficient without implementing parsing for mempolicies
> > > and hugepages.
> > 
> > I agree in principle.  I expect that if one can't allocate the required
> > number of huge pages in an early init script, either one really needs
> > more memory, or something is wrong with earlier scripts that is
> > fragmenting memory. 
> 
> Agreed.
> 
> > However, I'll point out that by the time one gets
> > such a complaint, there is a really long lead time before a change gets
> > into customer hands.  This is the downside of waiting for a complaint or
> > definitive use case before providing tunable parameters and such :(.
> > 
> 
> There is that, but as the workaround here is basically "install more
> memory", it feels less critical. I just can't see the lack of node
> specification being a show-stopper for anyone. Famous last words of
> course :/

Understood.  I was just grousing.

> 
> > > 
> > > > See the updated documentation [next patch] for more information
> > > > about the implications of this patch.
> > > > 
> > > 
> > > Ideally the change log should show a before and after of using numactl +
> > > hugeadm to resize pools on a subset of available nodes.
> > 
> > I'll do that. 
> > 
> > > 
> > > > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > > > 
> > > >  include/linux/mempolicy.h |    3 +
> > > >  mm/hugetlb.c              |   99 +++++++++++++++++++++++++++++++---------------
> > > >  mm/mempolicy.c            |   54 +++++++++++++++++++++++++
> > > >  3 files changed, 124 insertions(+), 32 deletions(-)
> > > > 
> > > > Index: linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c
> > > > ===================================================================
> > > > --- linux-2.6.31-rc1-mmotm-090625-1549.orig/mm/hugetlb.c	2009-06-29 23:01:01.000000000 -0400
> > > > +++ linux-2.6.31-rc1-mmotm-090625-1549/mm/hugetlb.c	2009-06-30 11:29:49.000000000 -0400
> > > > @@ -621,29 +621,52 @@ static struct page *alloc_fresh_huge_pag
> > > >  }
> > > >  
> > > >  /*
> > > > + * common helper functions for hstate_next_node_to_{alloc|free}.
> > > > + * We may have allocated or freed a huge pages based on a different
> > > > + * nodes_allowed, previously, so h->next_node_to_{alloc|free} might
> > > > + * be outside of *nodes_allowed.  Ensure that we use the next
> > > > + * allowed node for alloc or free.
> > > > + */
> > > > +static int next_node_allowed(int nid, nodemask_t *nodes_allowed)
> > > > +{
> > > > +	nid = next_node(nid, *nodes_allowed);
> > > > +	if (nid == MAX_NUMNODES)
> > > > +		nid = first_node(*nodes_allowed); /* handle "wrap" */
> > > > +	return nid;
> > > > +}
> > > 
> > > The handle warp comment is unnecessary there. This is such a common pattern,
> > > it should be self-evident without placing comments that cause the
> > > CodingStyle Police to issue tickets.
> > 
> > Thanks for the warning.  I'll remove it.
> > 
> > > 
> > > > +
> > > > +static int this_node_allowed(int nid, nodemask_t *nodes_allowed)
> > > > +{
> > > > +	if (!node_isset(nid, *nodes_allowed))
> > > > +		nid = next_node_allowed(nid, nodes_allowed);
> > > > +	return nid;
> > > > +}
> > > > +
> > > 
> > > What happens if node hot-remove occured and there is now no node that we
> > > are allowed to allocate from?
> > 
> > If we return a valid node id [see below] of an off-line node, the
> > allocation or free will fail and we'll advance to the next node.  If all
> > the nodes in the nodes_allowed are off-line, we'll end up with next_nid
> > == start_nid and bail out.
> > 
> 
> Ok, there is a possibilily we'll OOM when returning NULL like this but a
> sensible way of dealing with that situation doesn't spring to mind. Mind
> you, maybe a user shouldn't be too suprised if they off-line a node that
> has active processes still bound to it :/. I guess ordinarily the pages
> would be migrated but hugetlbfs does not have such capabilities right
> now.

Remember that the alloc_fresh... and free_pool... functions loop over
all nodes [in the node mask] or until they succeed.  If they fail, its
because they didn't find a huge page to alloc/free on any node in the
nodemask.  And, for the alloc case, this is for populating the
persistent huge page pool.  We shouldn't OOM there, right?  

> 
> > > 
> > > This thing will end up returning MAX_NUMNODES right? That potentially then
> > > gets passed to alloc_pages_exact_node() triggering a VM_BUG_ON() there.
> > 
> > No.  That's "next_node_allowed()"--the function above with the spurious
> > "handle wrap" comment--not the bare "next_node()".  So, we will "handle
> > wrap" appropriately.  
> > 
> 
> But first_node() itself can return MAX_NUMNODES, right?

If I read the bit map code correctly, this can occur only if the
nodemask is empty [in the first MAX_NUMNODES bits].  node_online_map
can't be empty if we're here, I think.  And huge_mpol_nodes_allowed()
can't [shouldn't!] return an empty mask.  NULL pointer, yes, meaning
"use node_online_map".

> 
> > > 
> > > > +/*
> > > >   * Use a helper variable to find the next node and then
> > > >   * copy it back to next_nid_to_alloc afterwards:
> > > >   * otherwise there's a window in which a racer might
> > > >   * pass invalid nid MAX_NUMNODES to alloc_pages_exact_node.
> > > >   * But we don't need to use a spin_lock here: it really
> > > >   * doesn't matter if occasionally a racer chooses the
> > > > - * same nid as we do.  Move nid forward in the mask even
> > > > - * if we just successfully allocated a hugepage so that
> > > > - * the next caller gets hugepages on the next node.
> > > > + * same nid as we do.  Move nid forward in the mask whether
> > > > + * or not we just successfully allocated a hugepage so that
> > > > + * the next allocation addresses the next node.
> > > >   */
> > > >  static int hstate_next_node_to_alloc(struct hstate *h,
> > > >  					nodemask_t *nodes_allowed)
> > > >  {
> > > > -	int next_nid;
> > > > +	int nid, next_nid;
> > > >  
> > > >  	if (!nodes_allowed)
> > > >  		nodes_allowed = &node_online_map;
> > > >  
> > > > -	next_nid = next_node(h->next_nid_to_alloc, *nodes_allowed);
> > > > -	if (next_nid == MAX_NUMNODES)
> > > > -		next_nid = first_node(*nodes_allowed);
> > > > +	nid = this_node_allowed(h->next_nid_to_alloc, nodes_allowed);
> > > > +
> > > > +	next_nid = next_node_allowed(nid, nodes_allowed);
> > > >  	h->next_nid_to_alloc = next_nid;
> > > > -	return next_nid;
> > > > +
> > > > +	return nid;
> > > >  }
> > > >  
> > > 
> > > Seems reasonable. I see now what you mean about next_nid_to_alloc being more
> > > like its name in patch series than the last.
> > > 
> > > >  static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
> > > > @@ -653,15 +676,17 @@ static int alloc_fresh_huge_page(struct 
> > > >  	int next_nid;
> > > >  	int ret = 0;
> > > >  
> > > > -	start_nid = h->next_nid_to_alloc;
> > > > +	start_nid = hstate_next_node_to_alloc(h, nodes_allowed);
> > > >  	next_nid = start_nid;
> > > >  
> > > 
> > > So, here for example, I think we need to make sure start_nid is not
> > > MAX_NUMNODES and bail out if it is.
> > 
> > See response above, re: this_node_allowed().  Do you still think it's a
> > problem?
> > 
> 
> I'm not fully convinced. As first_node() can return MAX_NUMNODES, it
> looks like hstate_next_node_to_alloc() can return MAX_NUMNODES and that
> can get passed to alloc_pages_exact_node().

Well, we can add a VM_BUG_ON.

> 
> > > 
> > > >  	do {
> > > >  		page = alloc_fresh_huge_page_node(h, next_nid);
> > > > -		if (page)
> > > > +		if (page) {
> > > >  			ret = 1;
> > > > +			break;
> > > > +		}
> > > 
> > > Ok, so this break is necessary on allocation success because
> > > hstate_next_node_to_alloc() has already bumped next_nid_to_alloc. Right?
> > 
> > Right.  I don't want to fall thru and skip a node.  so, I break and
> > remove the !page from the loop condition.
> > 
> > However, since you mention it:  I noticed, since I sent this, that with
> > this arrangement we will skip a node id in the case that we visit all
> > nodes w/o successfully allocating a huge page or finding a huge page to
> > free.  When we hit the loop termination condition "next_nid ==
> > start_nid", we've already advanced hstate_next_node_to_{alloc|free}
> > beyond next_nid.   So, on next call, start_nid will become that value
> > and not the same start_nid we used before.
> > 
> > Example:  suppose we try to start a huge page [on, say, a 4 node] system
> > with no huge pages available anywhere; and the next_node_to_alloc == 0
> > when we first call alloc_fresh_huge_page().  start_nid will get '0' and
> > we'll examine nodes 0, 1, 2 and 3.  When hstate_next_node_to_alloc()
> > returns '0', we'll give up and return NULL page, but next_node_to_alloc
> > is now 1.  If we try again, maybe after we think some memory has been
> > freed up and we have a chance of succeeding, we'll visit 1, 2, 3 and 0
> > [if there are still no huge pages available].  And so forth.  I don't
> > think this is a problem because if we actually succeed in allocating or
> > freeing a page, we'll break w/o advancing next_node... and pick up there
> > on next call.
> > 
> > I have an idea for fixing this behavior, if anyone thinks it's a
> > problem, by "pushing back" the next_nid to the hstate with something
> > like:
> > 
> > 	} while (next_nid != start_nid || push_back_alloc_node(next_nid))
> > 
> > where the push_back function always returns 0.  Kind of ugly, but I
> > think it would work.  I don't think it's needed, tho'.
> > 
> 
> I don't think it's a problem that is worth worrying about. If the
> administrator is interleaving between multiple nodes, I don't see why
> they would care which one the first node used.

I agree.  It would take a 'series of unfortunate events" for this occur
such that one would notice it in the first place.  And with this
capability, one can add or remove huge pages on specific nodes.
[hugeadm arguments to do that explicitly might be nice.]

> 
<snip>

> > > > +/**
> > > > + * huge_mpol_nodes_allowed()
> > > > + *
> > > > + * Return a [pointer to a] nodelist for persistent huge page allocation
> > > > + * based on the current task's mempolicy:
> > > > + *
> > > > + * If the task's mempolicy is "default" [NULL], just return NULL for
> > > > + * default behavior.  Otherwise, extract the policy nodemask for 'bind'
> > > > + * or 'interleave' policy or construct a nodemask for 'preferred' or
> > > > + * 'local' policy and return a pointer to a kmalloc()ed nodemask_t.
> > > > + * It is the caller's responsibility to free this nodemask.
> > > > + */
> > > > +nodemask_t *huge_mpol_nodes_allowed(void)
> > > > +{
> > > > +	nodemask_t *nodes_allowed = NULL;
> > > > +	struct mempolicy *mempolicy;
> > > > +	int nid;
> > > > +
> > > > +	if (!current || !current->mempolicy)
> > > > +		return NULL;
> > > > +
> > > 
> > > Is it really possible for current to be NULL here?
> > 
> > Not sure.  I've hit NULL current in mempolicy functions called at init
> > time before.  Maybe a [VM_]BUG_ON() would be preferable?
> > 
> 
> VM_BUG_ON() I'd say would be enough. Even if support is added later to
> allocateo with a nodemask at boot-time when current == NULL, they'll need
> to know to use the default policy instead of current->mempolicy.

Will do.

<snip>
> > > 
> > > nodemasks are meant to be cleared with nodes_clear() but you depend on
> > > kzalloc() zeroing the bitmap for you. While the end result is the same,
> > > is using kzalloc instead of kmalloc+nodes_clear() considered ok?
> > 
> > That did cross my mind.  And, it's not exactly a fast path.  Shall I
> > change it to kmalloc+nodes_clear()?  Or maybe add a nodemask_alloc() or
> > nodemask_new() function?  We don't have one of those, as nodemasks have
> > mostly been passed around by value rather than reference.
> > 
> 
> I think kmalloc+nodes_clear() might be more future proof in the event
> does something like use poison byte pattern to detect when a nodemask is
> improperly initialised or something similar. I don't think it needs a
> nodemask_alloc() or nodemask_new() helper.

OK.  Will do.

> > > 
> > > > +
> > > > +	mempolicy = current->mempolicy;
> > > > +	switch(mempolicy->mode) {
> > > > +	case MPOL_PREFERRED:
> > > > +		if (mempolicy->flags & MPOL_F_LOCAL)
> > > > +			nid = numa_node_id();
> > > > +		else
> > > > +			nid = mempolicy->v.preferred_node;
> > > > +		node_set(nid, *nodes_allowed);
> > > > +		break;
> > > > +
> > > 
> > > I think a comment is needed here saying that MPOL_PREFERRED when
> > > resizing the pool acts more like MPOL_BIND to the preferred node with no
> > > fallback.
> > 
> > Yeah, I can add such a comment.  I did document this in the hugetlbfs
> > doc, but I guess it's good to have it here, as well.
> > 
> 
> It doesn't hurt.

OK.

> 
> > > 
> > > I see your problem though. You can't use set the next_nid to allocate from
> > > to be the preferred node because the second allocation will interleave away
> > > from it though. How messy would it be to check if the MPOL_PREFERRED policy
> > > was in use and avoid updating next_nid_to_alloc while the preferred node is
> > > being allocated from?
> > > 
> > > It's not a big issue and I'd be ok with your current behaviour to start with.
> > 
> > Yeah, and I don't think we want the hugetlb.c code directly looking at
> > mempolicy internals.  I'd have to add another one user helper function,
> > probably in mempolicy.h.  Not a biggy, but I didn't think it was
> > necessary.  It doesn't hurt to reiterate that allocations for populating
> > the huge page pool do not fallback.
> > 
> 
> Lets go with your suggested behaviour for now. Double checking the
> policy will just over-complicate things in the first iteration.


works for me.

<snip>
> > > 
> > > By and large, this patch would appear to result in reasonable behaviour
> > > for administrators that want to limit the hugepage pool to specific
> > > nodes. Predictably, I prefer this approach to the nodemask-sysctl
> > > approach :/ . With a few crinkles ironed out, I reckon I'd be happy with
> > > this. Certainly, it appears to work as advertised in that I was able to
> > > accurate grow/shrink the pool on specific nodes.
> > > 
> > 
> > Having written the patch, I'm beginning to warm up to this approach
> > myself :).  We need to understand and advertise any apparently change in
> > behavior to be sure others agree.
> > 
> > Thanks for the review,
> > Lee
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
