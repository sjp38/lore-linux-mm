Date: Wed, 23 Jan 2008 13:55:14 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] Fix boot problem in situations where the boot CPU is running on a memoryless node
Message-ID: <20080123135513.GA14175@csn.ul.ie>
References: <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com> <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie> <20080122214505.GA15674@aepfle.de> <Pine.LNX.4.64.0801221417480.1912@schroedinger.engr.sgi.com> <20080123075821.GA17713@aepfle.de> <20080123105044.GD21455@csn.ul.ie> <20080123121459.GA18631@aepfle.de> <20080123125236.GA18876@aepfle.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080123125236.GA18876@aepfle.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, Olaf Hering <olaf@aepfle.de>
List-ID: <linux-mm.kvack.org>

This patch in combination with a partial revert of commit
04231b3002ac53f8a64a7bd142fde3fa4b6808c6 fixes a regression between 2.6.23
and 2.6.24-rc8 where a PPC64 machine with all CPUS on a memoryless node fails
to boot. If approved by the SLAB maintainers, it should be merged for 2.6.24.

With memoryless-node configurations, it is possible that all the CPUs are
associated with a node with no memory. Early in the boot process, nodelists
are not setup that allow fallback_alloc to work, an Oops occurs and the
machine fails to boot.

This patch adds the necessary checks to make sure a kmem_list3 exists for
the preferred node used when growing the cache. If the preferred node has
no nodelist then the currently running node is used instead. This
problem only affects the SLAB allocator, SLUB appears to work fine.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---
 mm/slab.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc8-005-revert-memoryless-slab/mm/slab.c linux-2.6.24-rc8-010_handle_missing_l3/mm/slab.c
--- linux-2.6.24-rc8-005-revert-memoryless-slab/mm/slab.c	2008-01-22 17:46:32.000000000 +0000
+++ linux-2.6.24-rc8-010_handle_missing_l3/mm/slab.c	2008-01-22 18:42:53.000000000 +0000
@@ -2775,6 +2775,11 @@ static int cache_grow(struct kmem_cache 
 	/* Take the l3 list lock to change the colour_next on this node */
 	check_irq_off();
 	l3 = cachep->nodelists[nodeid];
+	if (!l3) {
+		nodeid = numa_node_id();
+		l3 = cachep->nodelists[nodeid];
+	}
+	BUG_ON(!l3);
 	spin_lock(&l3->list_lock);
 
 	/* Get colour for the slab, and cal the next value. */
@@ -3317,6 +3322,10 @@ static void *____cache_alloc_node(struct
 	int x;
 
 	l3 = cachep->nodelists[nodeid];
+	if (!l3) {
+		nodeid = numa_node_id();
+		l3 = cachep->nodelists[nodeid];
+	}
 	BUG_ON(!l3);
 
 retry:

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
