Date: Thu, 2 Sep 2004 16:39:53 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20040902233953.28782.83663.95879@tomahawk.engr.sgi.com>
Subject: [RFC 2.6.9-rc1-mm2 1/2] kmempolicy: memory policy for page cache allocation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, Nick Piggin <piggin@cyberone.com.au>, "Martin J. Bligh" <mbligh@aracnet.com>, Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, Brent Casavant <bcasavant@sgi.com>, Jesse Barnes <jbarnes@sgi.com>, Andrew Morton <akpm@osdl.org>, Dan Higgins <djh@sgi.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is really just a proof of concept patch, it works, but it is not a
complete solution.  I wanted to send this out to get some feedback
before putting more work into it.  Hopefully this will be enough to "get
the ball rolling".  (Hence the RFC in the "Subject".)

A few weeks back, Jesse Barnes proposed a patch to do round robin
allocation of page cache pages on NUMA machines.  This got shot down
for a number of reasons (see
  http://marc.theaimsgroup.com/?l=linux-kernel&m=109235420329360&w=2
and the related thread), but it seemed to me that one of the most
significant issues was that this was a workload dependent optimization.
That is, for an Altix running an HPC workload, it was a good thing,
but for web servers or file servers it was not such a good idea.

So the idea of this patch is the following:  it creates a new memory
policy structure (default_pagecache_policy) that is used to control
how storage for page cache pages is allocated.  So, for a large Altix
running HPC workloads, we can specify a policy that does round robin
allocations, and for other workloads you can specify the default policy
(which results in page cache pages being allocated locally).

The default_pagecache_policy is overrideable on a per process basis, so
that if your application prefers to allocate page cache pages locally,
it can.

This patch is in two parts.  The first part is Brent Casavant's patch for
MPOL_ROUNDROBIN.  We need this because there is no handy offset to use
when you get a call to allocate a page cache page in "page_cache_alloc()",
so MPOL_INTERLEAVE doesn't do what we need.

The second part of the patch is the set of changes to create the
default_pagecache_policy and see that it is used in page_cache_alloc().

The caveat list is long (I did say this was a proof of concept thing :-) ):

(1)  Right now, there is no mechanism to set the default_pagecache_policy.
(It's hard compiled into mm/mempolicy.c at the moment).  This can be
added later if we decide this is the way to go.

(2)  page_cache_alloc_local() is defined, but is not currently called.
This was added in SGI ProPack to make sure that mmap'd() files were
allocated locally rather than round-robin'd (i. e. to override the 
round robin allocation in that case.)  This was an SGI MPT
requirement.   It may be this is not needed with the current mempolicy
code if we can associate the default mempolicy with mmap()'d files
for those MPT users.

(3)  alloc_pages_current() should now be inline, but there is no easy
way to do that with the current include file order (that I could figure
out at least...)

(4)  I'm not happy with the "robustness" of the MPOL_ROUNDROBIN code,
but this may also be a comment about the mempolicy code in general.
If you set an invalid node mask in the the default_pagecache_mempolicy
structure (e. g. set more bits there than there are nodes), then you will
get a kernel panic at the BUG_ON() in alloc_page_roundrobin().  Not a
good thing, unless when we let users change this we are very particular
about the allowed values we change it to.  I wonder if MPOL_INTERLEAVE
has similar problems?  Anyway, the compiled in value for the nodemask
for default_pagecache_policy only works for a 4 node system.  It 
would be nice to be able to specify a policy that says "Interleave
over all available nodes" and not have to change it as the number of
nodes change.

(5)  It is possible we will identify other kernel memory allocations
that need to have some type of policy associated with them.  Therefore,
it would probably be better to have an array of default mempolicy
structures, with a defined index that gives what index goes with what
type of storage (interrupt, pagecache, mmap, slab, current, etc....).
This will simplify the implementation of routines and utilities to
set/get the default mempolicy and per process policy, etc.

(6)  One can implement these mempolicy data structures in many ways.
Another alternative would be to have an array inside of the mempolicy
structure itself -- this would only require one pointer in the task
struct instead of an array of pointers, for example.

(7)  I've not thought a bit about locking issues related to changing
the default_pagecache_mempolicy whilst the system is actually running.
It may be better to make the default_pagecache_policy() a pointer,
that we just update with the new policy rather than as it is now.

(8)  It seems there may be a potential conflict between the page cache
mempolicy and a mmap mempolicy (do those exist?).  Here's the concern:
If you mmap() a file, and any pages of that file are in the page cache,
then the location of those pages will (have been) dictated by the page
cache mempolicy, which could differ (will likely differ) from the mmap
mempolicy.  It seems that the only solution to this is to migrate those
pages (when they are touched) after the mmap().

Comments, flames, etc to the undersigned.

Best Regards,

Ray

PS:  Both patches are relative to 2.6.9-rc1-mm2.

PPS: This is hardly a final patch, but lets keep the lawyers happy
anyway:

Signed-off-by: Ray Bryant <raybry@sgi.com>
Signed-off-by: Brent Casavant <bcasavan@sgi.com>

===========================================================================
Index: linux-2.6.9-rc1-mm2-kdb/include/linux/sched.h
===================================================================
--- linux-2.6.9-rc1-mm2-kdb.orig/include/linux/sched.h	2004-08-31 13:32:20.000000000 -0700
+++ linux-2.6.9-rc1-mm2-kdb/include/linux/sched.h	2004-09-02 13:17:45.000000000 -0700
@@ -596,6 +596,7 @@
 #ifdef CONFIG_NUMA
   	struct mempolicy *mempolicy;
   	short il_next;		/* could be shared with used_math */
+	short rr_next;
 #endif
 #ifdef CONFIG_CPUSETS
 	struct cpuset *cpuset;
===================================================================
Index: linux-2.6.9-rc1-mm2-kdb/mm/mempolicy.c
===================================================================
--- linux-2.6.9-rc1-mm2-kdb.orig/mm/mempolicy.c	2004-08-31 13:32:20.000000000 -0700
+++ linux-2.6.9-rc1-mm2-kdb/mm/mempolicy.c	2004-09-02 13:17:45.000000000 -0700
@@ -7,10 +7,17 @@
  * NUMA policy allows the user to give hints in which node(s) memory should
  * be allocated.
  *
- * Support four policies per VMA and per process:
+ * Support five policies per VMA and per process:
  *
  * The VMA policy has priority over the process policy for a page fault.
  *
+ * roundrobin     Allocate memory round-robined over a set of nodes,
+ *                with normal fallback if it fails.  The round-robin is
+ *                based on a per-thread rotor both to provide predictability
+ *                of allocation locations and to avoid cacheline contention
+ *                compared to a global rotor.  This policy is distinct from
+ *                interleave in that it seeks to distribute allocations evenly
+ *                across nodes, whereas interleave seeks to maximize bandwidth.
  * interleave     Allocate memory interleaved over a set of nodes,
  *                with normal fallback if it fails.
  *                For VMA based allocations this interleaves based on the
@@ -117,6 +124,7 @@
 		break;
 	case MPOL_BIND:
 	case MPOL_INTERLEAVE:
+	case MPOL_ROUNDROBIN:
 		/* Preferred will only use the first bit, but allow
 		   more for now. */
 		if (empty)
@@ -215,6 +223,7 @@
 	atomic_set(&policy->refcnt, 1);
 	switch (mode) {
 	case MPOL_INTERLEAVE:
+	case MPOL_ROUNDROBIN:
 		bitmap_copy(policy->v.nodes, nodes, MAX_NUMNODES);
 		break;
 	case MPOL_PREFERRED:
@@ -406,6 +415,8 @@
 	current->mempolicy = new;
 	if (new && new->policy == MPOL_INTERLEAVE)
 		current->il_next = find_first_bit(new->v.nodes, MAX_NUMNODES);
+	if (new && new->policy == MPOL_ROUNDROBIN)
+		current->rr_next = find_first_bit(new->v.nodes, MAX_NUMNODES);
 	return 0;
 }
 
@@ -423,6 +434,7 @@
 	case MPOL_DEFAULT:
 		break;
 	case MPOL_INTERLEAVE:
+	case MPOL_ROUNDROBIN:
 		bitmap_copy(nodes, p->v.nodes, MAX_NUMNODES);
 		break;
 	case MPOL_PREFERRED:
@@ -507,6 +519,9 @@
 		} else if (pol == current->mempolicy &&
 				pol->policy == MPOL_INTERLEAVE) {
 			pval = current->il_next;
+		} else if (pol == current->mempolicy &&
+				pol->policy == MPOL_ROUNDROBIN) {
+			pval = current->rr_next;
 		} else {
 			err = -EINVAL;
 			goto out;
@@ -585,6 +600,7 @@
 				return policy->v.zonelist;
 		/*FALL THROUGH*/
 	case MPOL_INTERLEAVE: /* should not happen */
+	case MPOL_ROUNDROBIN: /* should not happen */
 	case MPOL_DEFAULT:
 		nd = numa_node_id();
 		break;
@@ -595,6 +611,21 @@
 	return NODE_DATA(nd)->node_zonelists + (gfp & GFP_ZONEMASK);
 }
 
+/* Do dynamic round-robin for a process */
+static unsigned roundrobin_nodes(struct mempolicy *policy)
+{
+	unsigned nid, next;
+	struct task_struct *me = current;
+
+	nid = me->rr_next;
+	BUG_ON(nid >= MAX_NUMNODES);
+	next = find_next_bit(policy->v.nodes, MAX_NUMNODES, 1+nid);
+	if (next >= MAX_NUMNODES)
+		next = find_first_bit(policy->v.nodes, MAX_NUMNODES);
+	me->rr_next = next;
+	return nid;
+}
+
 /* Do dynamic interleaving for a process */
 static unsigned interleave_nodes(struct mempolicy *policy)
 {
@@ -646,6 +677,27 @@
 	return page;
 }
 
+/* Allocate a page in round-robin policy.
+   Own path because first fallback needs to round-robin. */
+static struct page *alloc_page_roundrobin(unsigned gfp, unsigned order, struct mempolicy* policy)
+{
+	struct zonelist *zl;
+	struct page *page;
+	unsigned nid;
+	int i, numnodes = bitmap_weight(policy->v.nodes, MAX_NUMNODES);
+
+	for (i = 0; i < numnodes; i++) {
+		nid = roundrobin_nodes(policy);
+		BUG_ON(!test_bit(nid, (const volatile void *) &node_online_map));
+		zl = NODE_DATA(nid)->node_zonelists + (gfp & GFP_ZONEMASK);
+		page = __alloc_pages(gfp, order, zl);
+		if (page)
+			return page;
+	}
+
+	return NULL;
+}
+
 /**
  * 	alloc_page_vma	- Allocate a page for a VMA.
  *
@@ -671,26 +723,30 @@
 struct page *
 alloc_page_vma(unsigned gfp, struct vm_area_struct *vma, unsigned long addr)
 {
+	unsigned nid;
 	struct mempolicy *pol = get_vma_policy(vma, addr);
 
 	cpuset_update_current_mems_allowed();
 
-	if (unlikely(pol->policy == MPOL_INTERLEAVE)) {
-		unsigned nid;
-		if (vma) {
-			unsigned long off;
-			BUG_ON(addr >= vma->vm_end);
-			BUG_ON(addr < vma->vm_start);
-			off = vma->vm_pgoff;
-			off += (addr - vma->vm_start) >> PAGE_SHIFT;
-			nid = offset_il_node(pol, vma, off);
-		} else {
-			/* fall back to process interleaving */
-			nid = interleave_nodes(pol);
-		}
-		return alloc_page_interleave(gfp, 0, nid);
+	switch (pol->policy) {
+		case MPOL_INTERLEAVE:
+			if (vma) {
+				unsigned long off;
+				BUG_ON(addr >= vma->vm_end);
+				BUG_ON(addr < vma->vm_start);
+				off = vma->vm_pgoff;
+				off += (addr - vma->vm_start) >> PAGE_SHIFT;
+				nid = offset_il_node(pol, vma, off);
+			} else {
+				/* fall back to process interleaving */
+				nid = interleave_nodes(pol);
+			}
+			return alloc_page_interleave(gfp, 0, nid);
+		case MPOL_ROUNDROBIN:
+			return alloc_page_roundrobin(gfp, 0, pol);
+		default:
+			return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
 	}
-	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
 }
 
 /**
@@ -716,8 +772,11 @@
 		cpuset_update_current_mems_allowed();
 	if (!pol || in_interrupt())
 		pol = &default_policy;
-	if (pol->policy == MPOL_INTERLEAVE)
+	if (pol->policy == MPOL_INTERLEAVE) {
 		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
+	} else if (pol->policy == MPOL_ROUNDROBIN) {
+		return alloc_page_roundrobin(gfp, order, pol);
+	}
 	return __alloc_pages(gfp, order, zonelist_policy(gfp, pol));
 }
 EXPORT_SYMBOL(alloc_pages_current);
@@ -754,6 +813,7 @@
 	case MPOL_DEFAULT:
 		return 1;
 	case MPOL_INTERLEAVE:
+	case MPOL_ROUNDROBIN:
 		return bitmap_equal(a->v.nodes, b->v.nodes, MAX_NUMNODES);
 	case MPOL_PREFERRED:
 		return a->v.preferred_node == b->v.preferred_node;
@@ -798,6 +858,8 @@
 		return pol->v.zonelist->zones[0]->zone_pgdat->node_id;
 	case MPOL_INTERLEAVE:
 		return interleave_nodes(pol);
+	case MPOL_ROUNDROBIN:
+		return roundrobin_nodes(pol);
 	case MPOL_PREFERRED:
 		return pol->v.preferred_node >= 0 ?
 				pol->v.preferred_node : numa_node_id();
@@ -815,6 +877,7 @@
 	case MPOL_PREFERRED:
 	case MPOL_DEFAULT:
 	case MPOL_INTERLEAVE:
+	case MPOL_ROUNDROBIN:
 		return 1;
 	case MPOL_BIND: {
 		struct zone **z;
===================================================================
Index: linux-2.6.9-rc1-mm2-kdb/include/linux/mempolicy.h
===================================================================
--- linux-2.6.9-rc1-mm2-kdb.orig/include/linux/mempolicy.h	2004-08-27 10:06:15.000000000 -0700
+++ linux-2.6.9-rc1-mm2-kdb/include/linux/mempolicy.h	2004-09-02 13:19:38.000000000 -0700
@@ -13,6 +13,7 @@
 #define MPOL_PREFERRED	1
 #define MPOL_BIND	2
 #define MPOL_INTERLEAVE	3
+#define MPOL_ROUNDROBIN 4
 
 #define MPOL_MAX MPOL_INTERLEAVE
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
