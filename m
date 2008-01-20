Date: Sun, 20 Jan 2008 00:58:06 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUG] at mm/slab.c:3320
Message-ID: <20080120005806.GA25669@csn.ul.ie>
References: <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com> <20080109065015.GG7602@us.ibm.com> <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com> <20080109185859.GD11852@skywalker> <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com> <20080109214707.GA26941@us.ibm.com> <Pine.LNX.4.64.0801091349430.12505@schroedinger.engr.sgi.com> <20080109221315.GB26941@us.ibm.com> <Pine.LNX.4.64.0801091601080.14723@schroedinger.engr.sgi.com> <84144f020801170431l2d6d0d63i1fb7ebc5145539f4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <84144f020801170431l2d6d0d63i1fb7ebc5145539f4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On (17/01/08 14:31), Pekka Enberg didst pronounce:
> Hi Christoph,
> 
> On Jan 10, 2008 2:02 AM, Christoph Lameter <clameter@sgi.com> wrote:
> > New patch that also checks in alternate_node_alloc if the node has normal
> > memory because we cannot call ____cache_alloc_node with an invalid node.
> 
> [snip]
> 
> > @@ -3439,8 +3442,14 @@ __do_cache_alloc(struct kmem_cache *cach
> >          * We may just have run out of memory on the local node.
> >          * ____cache_alloc_node() knows how to locate memory on other nodes
> >          */
> > -       if (!objp)
> > -               objp = ____cache_alloc_node(cache, flags, numa_node_id());
> > +       if (!objp) {
> > +               int node_id = numa_node_id();
> > +               if (likely(cache->nodelists[node_id])) /* fast path */
> > +                       objp = ____cache_alloc_node(cache, flags, node_id);
> > +               else /* this function can do good fallback */
> > +                       objp = __cache_alloc_node(cache, flags, node_id,
> > +                                       __builtin_return_address(0));
> > +       }
> 
> But __cache_alloc_node() will call fallback_alloc() that does
> cache_grow() for the node that doesn't have N_NORMAL_MEMORY, no?
> 
> Shouldn't we just revert 04231b3002ac53f8a64a7bd142fde3fa4b6808c6 for
> 2.6.24 as this is a clear regression from 2.6.23?
> 

I tried this patch and it didn't work out. Oops occured all in relation to
l3. I did see the obvious flaw and getting this close to 2.6.24 and the
other boot-problem on PPC64, I don't think we have the luxury of messing
around and maybe this should be tried again later? The minimum revert is
the following patch. I have verified it boots the machine in question.

===

Partial revert the changes made by 04231b3002ac53f8a64a7bd142fde3fa4b6808c6
to the kmem_list3 management. On a machine with a memoryless node, this
BUG_ON was triggering

static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t
flags,
                                int nodeid)
{
        struct list_head *entry;
        struct slab *slabp;
        struct kmem_list3 *l3;
        void *obj;
        int x;

        l3 = cachep->nodelists[nodeid];
        BUG_ON(!l3);

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

--- 
 mm/slab.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc8-015_remap_discontigmem/mm/slab.c linux-2.6.24-rc8-020_init_kmem3lists_nodes/mm/slab.c
--- linux-2.6.24-rc8-015_remap_discontigmem/mm/slab.c	2008-01-16 04:22:48.000000000 +0000
+++ linux-2.6.24-rc8-020_init_kmem3lists_nodes/mm/slab.c	2008-01-20 00:06:35.000000000 +0000
@@ -1590,7 +1590,7 @@ void __init kmem_cache_init(void)
 		/* Replace the static kmem_list3 structures for the boot cpu */
 		init_list(&cache_cache, &initkmem_list3[CACHE_CACHE], node);
 
-		for_each_node_state(nid, N_NORMAL_MEMORY) {
+		for_each_online_node(nid) {
 			init_list(malloc_sizes[INDEX_AC].cs_cachep,
 				  &initkmem_list3[SIZE_AC + nid], nid);
 
@@ -1968,7 +1968,7 @@ static void __init set_up_list3s(struct 
 {
 	int node;
 
-	for_each_node_state(node, N_NORMAL_MEMORY) {
+	for_each_online_node(node) {
 		cachep->nodelists[node] = &initkmem_list3[index + node];
 		cachep->nodelists[node]->next_reap = jiffies +
 		    REAPTIMEOUT_LIST3 +
@@ -3815,7 +3815,7 @@ static int alloc_kmemlist(struct kmem_ca
 	struct array_cache *new_shared;
 	struct array_cache **new_alien = NULL;
 
-	for_each_node_state(node, N_NORMAL_MEMORY) {
+	for_each_online_node(node) {
 
                 if (use_alien_caches) {
                         new_alien = alloc_alien_cache(node, cachep->limit);

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
