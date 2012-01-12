Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id BC5676B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 10:07:20 -0500 (EST)
Message-ID: <1326380820.2442.186.camel@twins>
Subject: [RFC][PATCH] mm: Remove NUMA_INTERLEAVE_HIT
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 12 Jan 2012 16:07:00 +0100
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Andi Kleen <andi@firstfloor.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Since the NUMA_INTERLEAVE_HIT statistic is useless on its own; it wants
to be compared to either a total of interleave allocations or to a miss
count, remove it.

Fixing it would be possible, but since we've gone years without these
statistics I figure we can continue that way.

This cleans up some of the weird MPOL_INTERLEAVE allocation exceptions.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 drivers/base/node.c    |    2 +-
 include/linux/mmzone.h |    1 -
 mm/mempolicy.c         |   66 +++++++++++++++-----------------------------=
---
 3 files changed, 22 insertions(+), 47 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5693ece..942cdbc 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -172,7 +172,7 @@ static ssize_t node_read_numastat(struct sys_device * d=
ev,
 		       node_page_state(dev->id, NUMA_HIT),
 		       node_page_state(dev->id, NUMA_MISS),
 		       node_page_state(dev->id, NUMA_FOREIGN),
-		       node_page_state(dev->id, NUMA_INTERLEAVE_HIT),
+		       0,
 		       node_page_state(dev->id, NUMA_LOCAL),
 		       node_page_state(dev->id, NUMA_OTHER));
 }
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3ac040f..3a3be81 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -111,7 +111,6 @@ enum zone_stat_item {
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
 	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
-	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index c3fdbcb..2c48c45 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1530,11 +1530,29 @@ static nodemask_t *policy_nodemask(gfp_t gfp, struc=
t mempolicy *policy)
 	return NULL;
 }
=20
+/* Do dynamic interleaving for a process */
+static unsigned interleave_nodes(struct mempolicy *policy)
+{
+	unsigned nid, next;
+	struct task_struct *me =3D current;
+
+	nid =3D me->il_next;
+	next =3D next_node(nid, policy->v.nodes);
+	if (next >=3D MAX_NUMNODES)
+		next =3D first_node(policy->v.nodes);
+	if (next < MAX_NUMNODES)
+		me->il_next =3D next;
+	return nid;
+}
+
 /* Return a zonelist indicated by gfp for node representing a mempolicy */
 static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *polic=
y,
 	int nd)
 {
 	switch (policy->mode) {
+	case MPOL_INTERLEAVE:
+		nd =3D interleave_nodes(policy);
+		break;
 	case MPOL_PREFERRED:
 		if (!(policy->flags & MPOL_F_LOCAL))
 			nd =3D policy->v.preferred_node;
@@ -1556,21 +1574,6 @@ static struct zonelist *policy_zonelist(gfp_t gfp, s=
truct mempolicy *policy,
 	return node_zonelist(nd, gfp);
 }
=20
-/* Do dynamic interleaving for a process */
-static unsigned interleave_nodes(struct mempolicy *policy)
-{
-	unsigned nid, next;
-	struct task_struct *me =3D current;
-
-	nid =3D me->il_next;
-	next =3D next_node(nid, policy->v.nodes);
-	if (next >=3D MAX_NUMNODES)
-		next =3D first_node(policy->v.nodes);
-	if (next < MAX_NUMNODES)
-		me->il_next =3D next;
-	return nid;
-}
-
 /*
  * Depending on the memory policy provide a node from which to allocate th=
e
  * next slab entry.
@@ -1801,21 +1804,6 @@ out:
 	return ret;
 }
=20
-/* Allocate a page in interleaved policy.
-   Own path because it needs to do special accounting. */
-static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
-					unsigned nid)
-{
-	struct zonelist *zl;
-	struct page *page;
-
-	zl =3D node_zonelist(nid, gfp);
-	page =3D __alloc_pages(gfp, order, zl);
-	if (page && page_zone(page) =3D=3D zonelist_zone(&zl->_zonerefs[0]))
-		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
-	return page;
-}
-
 /**
  * 	alloc_pages_vma	- Allocate a page for a VMA.
  *
@@ -1848,15 +1836,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area=
_struct *vma,
 	struct page *page;
=20
 	get_mems_allowed();
-	if (unlikely(pol->mode =3D=3D MPOL_INTERLEAVE)) {
-		unsigned nid;
-
-		nid =3D interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
-		mpol_cond_put(pol);
-		page =3D alloc_page_interleave(gfp, order, nid);
-		put_mems_allowed();
-		return page;
-	}
 	zl =3D policy_zonelist(gfp, pol, node);
 	if (unlikely(mpol_needs_cond_ref(pol))) {
 		/*
@@ -1909,12 +1888,9 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned=
 order)
 	 * No reference counting needed for current->mempolicy
 	 * nor system default_policy
 	 */
-	if (pol->mode =3D=3D MPOL_INTERLEAVE)
-		page =3D alloc_page_interleave(gfp, order, interleave_nodes(pol));
-	else
-		page =3D __alloc_pages_nodemask(gfp, order,
-				policy_zonelist(gfp, pol, numa_node_id()),
-				policy_nodemask(gfp, pol));
+	page =3D __alloc_pages_nodemask(gfp, order,
+			policy_zonelist(gfp, pol, numa_node_id()),
+			policy_nodemask(gfp, pol));
 	put_mems_allowed();
 	return page;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
