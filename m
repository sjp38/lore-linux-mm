Date: Tue, 9 Oct 2007 16:40:53 +0100
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
Message-ID: <20071009154052.GC12632@skynet.ie>
References: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie> <20070928142526.16783.97067.sendpatchset@skynet.skynet.ie> <20071009011143.GC14670@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20071009011143.GC14670@us.ibm.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

First, sorry for being so slow to respond. I was getting ill towards the end
of last week and am worse now. Brain is in total mush as a result. Thanks
Lee for finding this problem and thanks to Nish for investigating it properly.

Comments and candidate fix to one zonelist are below.

On (08/10/07 18:11), Nishanth Aravamudan didst pronounce:
> On 28.09.2007 [15:25:27 +0100], Mel Gorman wrote:
> > 
> > Two zonelists exist so that GFP_THISNODE allocations will be guaranteed
> > to use memory only from a node local to the CPU. As we can now filter the
> > zonelist based on a nodemask, we filter the standard node zonelist for zones
> > on the local node when GFP_THISNODE is specified.
> > 
> > When GFP_THISNODE is used, a temporary nodemask is created with only the
> > node local to the CPU set. This allows us to eliminate the second zonelist.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Acked-by: Christoph Lameter <clameter@sgi.com>
> 
> <snip>
> 
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/gfp.h linux-2.6.23-rc8-mm2-040_use_one_zonelist/include/linux/gfp.h
> > --- linux-2.6.23-rc8-mm2-030_filter_nodemask/include/linux/gfp.h	2007-09-28 15:49:57.000000000 +0100
> > +++ linux-2.6.23-rc8-mm2-040_use_one_zonelist/include/linux/gfp.h	2007-09-28 15:55:03.000000000 +0100
> 
> [Reordering the chunks to make my comments a little more logical]
> 
> <snip>
> 
> > -static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> > +static inline struct zonelist *node_zonelist(int nid)
> >  {
> > -	return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
> > +	return &NODE_DATA(nid)->node_zonelist;
> >  }
> > 
> >  #ifndef HAVE_ARCH_FREE_PAGE
> > @@ -198,7 +186,7 @@ static inline struct page *alloc_pages_n
> >  	if (nid < 0)
> >  		nid = numa_node_id();
> > 
> > -	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
> > +	return __alloc_pages(gfp_mask, order, node_zonelist(nid));
> >  }
> 
> This is alloc_pages_node(), and converting the nid to a zonelist means
> that lower levels (specifically __alloc_pages() here) are not aware of
> nids, as far as I can tell.

Yep, this is correct.

> This isn't a change, I just want to make
> sure I understand...
> 
> <snip>
> 
> >  struct page * fastcall
> >  __alloc_pages(gfp_t gfp_mask, unsigned int order,
> >  		struct zonelist *zonelist)
> >  {
> > +	/*
> > +	 * Use a temporary nodemask for __GFP_THISNODE allocations. If the
> > +	 * cost of allocating on the stack or the stack usage becomes
> > +	 * noticable, allocate the nodemasks per node at boot or compile time
> > +	 */
> > +	if (unlikely(gfp_mask & __GFP_THISNODE)) {
> > +		nodemask_t nodemask;
> > +
> > +		return __alloc_pages_internal(gfp_mask, order,
> > +				zonelist, nodemask_thisnode(&nodemask));
> > +	}
> > +
> >  	return __alloc_pages_internal(gfp_mask, order, zonelist, NULL);
> >  }
> 
> <snip>
> 
> So alloc_pages_node() calls here and for THISNODE allocations, we go ask
> nodemask_thisnode() for a nodemask...
> 

Also correct.

> > +static nodemask_t *nodemask_thisnode(nodemask_t *nodemask)
> > +{
> > +	/* Build a nodemask for just this node */
> > +	int nid = numa_node_id();
> > +
> > +	nodes_clear(*nodemask);
> > +	node_set(nid, *nodemask);
> > +
> > +	return nodemask;
> > +}
> 
> <snip>
> 
> And nodemask_thisnode() always gives us a nodemask with only the node
> the current process is running on set, I think?
> 

Yes, I interpreted THISNODE to mean "this node I am running on". Callers
seemed to expect this but the memoryless needs it to be "this node I am
running on unless I specify a node in which case I mean that node.".

> That seems really wrong -- and would explain what Lee was seeing while
> using my patches for the hugetlb pool allocator to use THISNODE
> allocations. All the allocations would end up coming from whatever node
> the process happened to be running on. This obviously messes up hugetlb
> accounting, as I rely on THISNODE requests returning NULL if they go
> off-node.
> 
> I'm not sure how this would be fixed, as __alloc_pages() no longer has
> the nid to set in the mask.
> 
> Am I wrong in my analysis?
> 

No, you seem to be right on the ball. Can you review the following patch
please and determine if it fixes the problem in a satisfactory manner? I
think it does and your tests seemed to give proper values with this patch
applied but brain no worky work and a second opinion is needed.

====
Subject: Use specified node ID with GFP_THISNODE if available

It had been assumed that __GFP_THISNODE meant allocating from the local
node and only the local node. However, users of alloc_pages_node() may also
specify GFP_THISNODE. In this case, only the specified node should be used.
This patch will allocate pages only from the requested node when GFP_THISNODE
is used with alloc_pages_node().

[nacc@us.ibm.com: Detailed analysis of problem]
Found-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>

--- 
 include/linux/gfp.h |   10 ++++++++++
 mm/page_alloc.c     |    8 +++-----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-040_use_one_zonelist/include/linux/gfp.h linux-2.6.23-rc8-mm2-050_memoryless_fix/include/linux/gfp.h
--- linux-2.6.23-rc8-mm2-040_use_one_zonelist/include/linux/gfp.h	2007-10-09 13:52:39.000000000 +0100
+++ linux-2.6.23-rc8-mm2-050_memoryless_fix/include/linux/gfp.h	2007-10-09 14:17:06.000000000 +0100
@@ -175,6 +175,7 @@ FASTCALL(__alloc_pages(gfp_t, unsigned i
 extern struct page *
 FASTCALL(__alloc_pages_nodemask(gfp_t, unsigned int,
 				struct zonelist *, nodemask_t *nodemask));
+extern nodemask_t *nodemask_thisnode(int nid, nodemask_t *nodemask);
 
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
@@ -186,6 +187,15 @@ static inline struct page *alloc_pages_n
 	if (nid < 0)
 		nid = numa_node_id();
 
+	/* Use a temporary nodemask for __GFP_THISNODE allocations */
+	if (unlikely(gfp_mask & __GFP_THISNODE)) {
+		nodemask_t nodemask;
+
+		return __alloc_pages_nodemask(gfp_mask, order,
+				node_zonelist(nid),
+				nodemask_thisnode(nid, &nodemask));
+	}
+
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid));
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/page_alloc.c linux-2.6.23-rc8-mm2-050_memoryless_fix/mm/page_alloc.c
--- linux-2.6.23-rc8-mm2-040_use_one_zonelist/mm/page_alloc.c	2007-10-09 13:52:39.000000000 +0100
+++ linux-2.6.23-rc8-mm2-050_memoryless_fix/mm/page_alloc.c	2007-10-09 14:15:18.000000000 +0100
@@ -1741,11 +1741,9 @@ got_pg:
 	return page;
 }
 
-static nodemask_t *nodemask_thisnode(nodemask_t *nodemask)
+/* Creates a nodemask suitable for GFP_THISNODE allocations */
+nodemask_t *nodemask_thisnode(int nid, nodemask_t *nodemask)
 {
-	/* Build a nodemask for just this node */
-	int nid = numa_node_id();
-
 	nodes_clear(*nodemask);
 	node_set(nid, *nodemask);
 
@@ -1765,7 +1763,7 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 		nodemask_t nodemask;
 
 		return __alloc_pages_internal(gfp_mask, order,
-				zonelist, nodemask_thisnode(&nodemask));
+			zonelist, nodemask_thisnode(numa_node_id(), &nodemask));
 	}
 
 	return __alloc_pages_internal(gfp_mask, order, zonelist, NULL);

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
