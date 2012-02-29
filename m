Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 2E73E6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 13:13:15 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 29 Feb 2012 11:13:12 -0700
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 22D0EC90067
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 13:12:39 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1TICdgZ282028
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 13:12:39 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1TICZO3018624
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:12:35 -0300
Date: Wed, 29 Feb 2012 10:12:33 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH v2] bootmem/sparsemem: remove limit constraint in
 alloc_bootmem_section
Message-ID: <20120229181233.GF5136@linux.vnet.ibm.com>
References: <1330112038-18951-1-git-send-email-nacc@us.ibm.com>
 <20120228154732.GE1199@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120228154732.GE1199@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <haveblue@us.ibm.com>, Anton Blanchard <anton@au1.ibm.com>, Paul Mackerras <paulus@samba.org>, Ben Herrenschmidt <benh@kernel.crashing.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On 28.02.2012 [15:47:32 +0000], Mel Gorman wrote:
> On Fri, Feb 24, 2012 at 11:33:58AM -0800, Nishanth Aravamudan wrote:
> > While testing AMS (Active Memory Sharing) / CMO (Cooperative Memory
> > Overcommit) on powerpc, we tripped the following:
> > 
> > kernel BUG at mm/bootmem.c:483!
> > cpu 0x0: Vector: 700 (Program Check) at [c000000000c03940]
> >     pc: c000000000a62bd8: .alloc_bootmem_core+0x90/0x39c
> >     lr: c000000000a64bcc: .sparse_early_usemaps_alloc_node+0x84/0x29c
> >     sp: c000000000c03bc0
> >    msr: 8000000000021032
> >   current = 0xc000000000b0cce0
> >   paca    = 0xc000000001d80000
> >     pid   = 0, comm = swapper
> > kernel BUG at mm/bootmem.c:483!
> > enter ? for help
> > [c000000000c03c80] c000000000a64bcc
> > .sparse_early_usemaps_alloc_node+0x84/0x29c
> > [c000000000c03d50] c000000000a64f10 .sparse_init+0x12c/0x28c
> > [c000000000c03e20] c000000000a474f4 .setup_arch+0x20c/0x294
> > [c000000000c03ee0] c000000000a4079c .start_kernel+0xb4/0x460
> > [c000000000c03f90] c000000000009670 .start_here_common+0x1c/0x2c
> > 
> > This is
> > 
> >         BUG_ON(limit && goal + size > limit);
> > 
> > and after some debugging, it seems that
> > 
> > 	goal = 0x7ffff000000
> > 	limit = 0x80000000000
> > 
> > and sparse_early_usemaps_alloc_node ->
> > sparse_early_usemaps_alloc_pgdat_section -> alloc_bootmem_section calls
> > 
> > 	return alloc_bootmem_section(usemap_size() * count, section_nr);
> > 
> > This is on a system with 8TB available via the AMS pool, and as a quirk
> > of AMS in firmware, all of that memory shows up in node 0. So, we end up
> > with an allocation that will fail the goal/limit constraints. In theory,
> > we could "fall-back" to alloc_bootmem_node() in
> > sparse_early_usemaps_alloc_node(), but since we actually have HOTREMOVE
> > defined, we'll BUG_ON() instead. A simple solution appears to be to
> > disable the limit check if the size of the allocation in
> > alloc_bootmem_secition exceeds the section size.
> > 
> > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > Cc: Dave Hansen <haveblue@us.ibm.com>
> > Cc: Anton Blanchard <anton@au1.ibm.com>
> > Cc: Paul Mackerras <paulus@samba.org>
> > Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
> > Cc: Robert Jennings <rcj@linux.vnet.ibm.com>
> > Cc: linux-mm@kvack.org
> > Cc: linuxppc-dev@lists.ozlabs.org
> > ---
> >  include/linux/mmzone.h |    2 ++
> >  mm/bootmem.c           |    5 ++++-
> >  2 files changed, 6 insertions(+), 1 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 650ba2f..4176834 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -967,6 +967,8 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
> >   * PA_SECTION_SHIFT		physical address to/from section number
> >   * PFN_SECTION_SHIFT		pfn to/from section number
> >   */
> > +#define BYTES_PER_SECTION	(1UL << SECTION_SIZE_BITS)
> > +
> >  #define SECTIONS_SHIFT		(MAX_PHYSMEM_BITS - SECTION_SIZE_BITS)
> >  
> >  #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
> > diff --git a/mm/bootmem.c b/mm/bootmem.c
> > index 668e94d..5cbbc76 100644
> > --- a/mm/bootmem.c
> > +++ b/mm/bootmem.c
> > @@ -770,7 +770,10 @@ void * __init alloc_bootmem_section(unsigned long size,
> >  
> >  	pfn = section_nr_to_pfn(section_nr);
> >  	goal = pfn << PAGE_SHIFT;
> > -	limit = section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
> > +	if (size > BYTES_PER_SECTION)
> > +		limit = 0;
> > +	else
> > +		limit = section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
> 
> As it's ok to spill the allocation over to an adjacent section, why not
> just make limit==0 unconditionally. That would avoid defining
> BYTES_PER_SECTION.

Something like this?

Andrew, presuming Mel & Johannes give their, ack this should presumably
supersede the patch you pulled into -mm.

Thanks,
Nish

-------

While testing AMS (Active Memory Sharing) / CMO (Cooperative Memory
Overcommit) on powerpc, we tripped the following:

kernel BUG at mm/bootmem.c:483!
cpu 0x0: Vector: 700 (Program Check) at [c000000000c03940]
    pc: c000000000a62bd8: .alloc_bootmem_core+0x90/0x39c
    lr: c000000000a64bcc: .sparse_early_usemaps_alloc_node+0x84/0x29c
    sp: c000000000c03bc0
   msr: 8000000000021032
  current = 0xc000000000b0cce0
  paca    = 0xc000000001d80000
    pid   = 0, comm = swapper
kernel BUG at mm/bootmem.c:483!
enter ? for help
[c000000000c03c80] c000000000a64bcc
.sparse_early_usemaps_alloc_node+0x84/0x29c
[c000000000c03d50] c000000000a64f10 .sparse_init+0x12c/0x28c
[c000000000c03e20] c000000000a474f4 .setup_arch+0x20c/0x294
[c000000000c03ee0] c000000000a4079c .start_kernel+0xb4/0x460
[c000000000c03f90] c000000000009670 .start_here_common+0x1c/0x2c

This is

        BUG_ON(limit && goal + size > limit);

and after some debugging, it seems that

	goal = 0x7ffff000000
	limit = 0x80000000000

and sparse_early_usemaps_alloc_node ->
sparse_early_usemaps_alloc_pgdat_section calls

	return alloc_bootmem_section(usemap_size() * count, section_nr);

This is on a system with 8TB available via the AMS pool, and as a quirk
of AMS in firmware, all of that memory shows up in node 0. So, we end up
with an allocation that will fail the goal/limit constraints. In theory,
we could "fall-back" to alloc_bootmem_node() in
sparse_early_usemaps_alloc_node(), but since we actually have HOTREMOVE
defined, we'll BUG_ON() instead. A simple solution appears to be to
unconditionally remove the limit condition in alloc_bootmem_section,
meaning allocations are allowed to cross section boundaries (necessary
for systems of this size).

Johannes Weiner pointed out that if alloc_bootmem_section() no longer
guarantees section-locality, we need check_usemap_section_nr() to print
possible cross-dependencies between node descriptors and the usemaps
allocated through it. That makes the two loops in
sparse_early_usemaps_alloc_node() identical, so re-factor the code a
bit.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---
v2: Unconditionally set limit to 0. Fold in Johannes' changes to
sparse_early_usemaps_alloc_node.

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 668e94d..9c9ae09 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -770,7 +770,7 @@ void * __init alloc_bootmem_section(unsigned long size,
 
 	pfn = section_nr_to_pfn(section_nr);
 	goal = pfn << PAGE_SHIFT;
-	limit = section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
+	limit = 0;
 	bdata = &bootmem_node_data[early_pfn_to_nid(pfn)];
 
 	return alloc_bootmem_core(bdata, size, SMP_CACHE_BYTES, goal, limit);
diff --git a/mm/sparse.c b/mm/sparse.c
index 61d7cde..a8bc7d3 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -353,29 +353,21 @@ static void __init sparse_early_usemaps_alloc_node(unsigned long**usemap_map,
 
 	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
 								 usemap_count);
-	if (usemap) {
-		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-			if (!present_section_nr(pnum))
-				continue;
-			usemap_map[pnum] = usemap;
-			usemap += size;
+	if (!usemap) {
+		usemap = alloc_bootmem_node(NODE_DATA(nodeid), size * usemap_count);
+		if (!usemap) {
+			printk(KERN_WARNING "%s: allocation failed\n", __func__);
+			return;
 		}
-		return;
 	}
 
-	usemap = alloc_bootmem_node(NODE_DATA(nodeid), size * usemap_count);
-	if (usemap) {
-		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-			if (!present_section_nr(pnum))
-				continue;
-			usemap_map[pnum] = usemap;
-			usemap += size;
-			check_usemap_section_nr(nodeid, usemap_map[pnum]);
-		}
-		return;
+	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
+		if (!present_section_nr(pnum))
+			continue;
+		usemap_map[pnum] = usemap;
+		usemap += size;
+		check_usemap_section_nr(nodeid, usemap_map[pnum]);
 	}
-
-	printk(KERN_WARNING "%s: allocation failed\n", __func__);
 }
 
 #ifndef CONFIG_SPARSEMEM_VMEMMAP

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
