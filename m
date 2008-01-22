Date: Tue, 22 Jan 2008 19:54:49 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: crash in kmem_cache_init
Message-ID: <20080122195448.GA15567@csn.ul.ie>
References: <20080115150949.GA14089@aepfle.de> <84144f020801170414q7d408a74uf47a84b777c36a4a@mail.gmail.com> <Pine.LNX.4.64.0801170628580.19208@schroedinger.engr.sgi.com> <20080117181222.GA24411@aepfle.de> <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com> <20080117211511.GA25320@aepfle.de> <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com> <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com> <20080118225713.GA31128@aepfle.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080118225713.GA31128@aepfle.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olaf Hering <olaf@aepfle.de>
Cc: Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On (18/01/08 23:57), Olaf Hering didst pronounce:
> On Fri, Jan 18, Christoph Lameter wrote:
> 
> > Could you try this patch?
> 
> Does not help, same crash.
> 

Hi Olaf,

It was suggested this problem was the same as another slab-related boot problem
that was fixed for 2.6.24 by reverting a change. This fix can be found at
http://www.csn.ul.ie/~mel/postings/slab-20080122/partial-revert-slab-changes.patch
. Can you please check on your machine if it fixes your problem?

I am 99.9999% it will *not* fix your problem because there was two bugs, not
one as previously believed. On two test machines here, this kmem_cache_init
problem still happens even with the revert which fixed a third machine. I
was delayed in testing because these boxen unavailable from Friday until
yesterday evening (a stellar display of timing). It was missed on TKO because
it was SLAB-specific and those machines were testing SLUB. I found that the
patch below was necessary to fix the problem.

Olaf, please confirm whether you need the patch below as well as the
revert to make your machine boot.

Christoph/Pekka, this patch is papering over the problem and something
more fundamental may be going wrong. The crash occurs because l3 is NULL
and the cache is kmem_cache so this is early in the boot process. It is
selecting l3 based on node 2 which is correct in terms of available memory
but it initialises the lists on node 0 because that is the node the CPUs are
located. Hence later it uses an uninitialised nodelists and BLAM. Relevant
parts of the log for seeing the memoryless nodes in relation to CPUs is;

early_node_map[1] active PFN ranges
    2:        0 ->  1048576
Processor 1 found.
clockevent: decrementer mult[3cf1] shift[16] cpu[2]
Processor 2 found.
clockevent: decrementer mult[3cf1] shift[16] cpu[3]
Processor 3 found.
Brought up 4 CPUs
Node 0 CPUs: 0-3
Node 2 CPUs:

Can you see a better solution than this?

====
Recent changes to how slab operates mean a situation can occur on systems
with memoryless nodes whereby the nodeid used when growing the slab does
not map to the correct kmem_list3. The following patch adds the necessary
check to the indicated preferred nodeid and if it is bogus, use numa_node_id() instead.

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
