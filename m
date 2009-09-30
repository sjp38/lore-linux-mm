Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C38C46B005D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 10:28:48 -0400 (EDT)
Date: Wed, 30 Sep 2009 15:41:17 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/4] slqb: Record what node is local to a kmem_cache_cpu
Message-ID: <20090930144117.GA17906@csn.ul.ie>
References: <1253624054-10882-1-git-send-email-mel@csn.ul.ie> <1253624054-10882-3-git-send-email-mel@csn.ul.ie> <84144f020909220638l79329905sf9a35286130e88d0@mail.gmail.com> <20090922135453.GF25965@csn.ul.ie> <84144f020909221154x820b287r2996480225692fad@mail.gmail.com> <20090922185608.GH25965@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090922185608.GH25965@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 22, 2009 at 07:56:08PM +0100, Mel Gorman wrote:
> On Tue, Sep 22, 2009 at 09:54:33PM +0300, Pekka Enberg wrote:
> > Hi Mel,
> > 
> > On Tue, Sep 22, 2009 at 4:54 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > >> I don't understand how the memory leak happens from the above
> > >> description (or reading the code). page_to_nid() returns some crazy
> > >> value at free time?
> > >
> > > Nope, it isn't a leak as such, the allocator knows where the memory is.
> > > The problem is that is always frees remote but on allocation, it sees
> > > the per-cpu list is empty and calls the page allocator again. The remote
> > > lists just grow.
> > >
> > >> The remote list isn't drained properly?
> > >
> > > That is another way of looking at it. When the remote lists get to a
> > > watermark, they should drain. However, it's worth pointing out if it's
> > > repaired in this fashion, the performance of SLQB will suffer as it'll
> > > never reuse the local list of pages and instead always get cold pages
> > > from the allocator.
> > 
> > I worry about setting c->local_nid to the node of the allocated struct
> > kmem_cache_cpu. It seems like an arbitrary policy decision that's not
> > necessarily the best option and I'm not totally convinced it's correct
> > when cpusets are configured. SLUB seems to do the sane thing here by
> > using page allocator fallback (which respects cpusets AFAICT) and
> > recycling one slab slab at a time.
> > 
> > Can I persuade you into sending me a patch that fixes remote list
> > draining to get things working on PPC? I'd much rather wait for Nick's
> > input on the allocation policy and performance.
> > 
> 
> It'll be at least next week before I can revisit this again. I'm afraid
> I'm going offline from tomorrow until Tuesday.
> 

Ok, so I spent today looking at this again. The problem is not with faulty
drain logic as such. As frees always place an object on a remote list
and the allocation side is often (but not always) allocating a new page,
a significant number of objects in the free list are the only object
in a page. SLQB drains based on the number of objects on the free list,
not the number of pages. With many of the pages having only one object,
the freelists are pinning a lot more memory than expected.  For example,
a watermark to drain of 512 could be pinning 2MB of pages.

The drain logic could be extended to track not only the number of objects on
the free list but also the number of pages but I really don't think that is
desirable behaviour. I'm somewhat running out of sensible ideas for dealing
with this but here is another go anyway that might be more palatable than
tracking what a "local" node is within the slab.

This boots on 2.6.32-rc1 with the latest slqb-core git tree with
Kconfig modified to allow SLQB to be set on ppc64.

==== CUT HERE ====
SLQB: Allocate from the remote lists when the local node is memoryless and has no free objects

When SLQB is freeing an object, it checks if the object belongs to a
page within the local node. If it is not, the object is freed to a
remote list. When the remote list has too many objects, the list is
drained.

On allocation, the remote list is only used if a specific node is specified
and that node is not the local node. On memoryless nodes, there is a problem
in that the specified node will often not be the local node. The impact is
that many objects on the free list are the only object in the page. This
bloats SLQB's memory requirements and causes OOM to trigger.

This patch alters the allocation path. If the allocation from local
lists fails and the local node is memoryless, an attempt will be made to
allocate from the remote lists before going to the page allocator.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/slqb.c |   30 ++++++++++++++++++++++--------
 1 file changed, 22 insertions(+), 8 deletions(-)

diff --git a/mm/slqb.c b/mm/slqb.c
index 4d72be2..b73e7d0 100644
--- a/mm/slqb.c
+++ b/mm/slqb.c
@@ -1513,16 +1513,30 @@ try_remote:
 	l = &c->list;
 	object = __cache_list_get_object(s, l);
 	if (unlikely(!object)) {
-		object = cache_list_get_page(s, l);
-		if (unlikely(!object)) {
-			object = __slab_alloc_page(s, gfpflags, node);
-#ifdef CONFIG_NUMA
+		int thisnode = numa_node_id();
+
+		/*
+		 * If the local node is memoryless, try remote alloc before
+		 * trying the page allocator. Otherwise, what happens is
+		 * objects are always freed to remote lists but the allocation
+		 * side always allocates a new page with only one object
+		 * used in each page
+		 */
+		if (unlikely(!node_state(thisnode, N_HIGH_MEMORY)))
+			object = __remote_slab_alloc(s, gfpflags, thisnode);
+
+		if (!object) {
+			object = cache_list_get_page(s, l);
 			if (unlikely(!object)) {
-				node = numa_node_id();
-				goto try_remote;
-			}
+				object = __slab_alloc_page(s, gfpflags, node);
+#ifdef CONFIG_NUMA
+				if (unlikely(!object)) {
+					node = numa_node_id();
+					goto try_remote;
+				}
 #endif
-			return object;
+				return object;
+			}
 		}
 	}
 	if (likely(object))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
