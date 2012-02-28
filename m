Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id D12BC6B00EA
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 08:54:06 -0500 (EST)
Date: Tue, 28 Feb 2012 14:53:26 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] sparsemem/bootmem: catch greater than section size
 allocations
Message-ID: <20120228135326.GE1702@cmpxchg.org>
References: <1330112038-18951-1-git-send-email-nacc@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1330112038-18951-1-git-send-email-nacc@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <haveblue@us.ibm.com>, Anton Blanchard <anton@au1.ibm.com>, Paul Mackerras <paulus@samba.org>, Ben Herrenschmidt <benh@kernel.crashing.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Fri, Feb 24, 2012 at 11:33:58AM -0800, Nishanth Aravamudan wrote:
> While testing AMS (Active Memory Sharing) / CMO (Cooperative Memory
> Overcommit) on powerpc, we tripped the following:
> 
> kernel BUG at mm/bootmem.c:483!
> cpu 0x0: Vector: 700 (Program Check) at [c000000000c03940]
>     pc: c000000000a62bd8: .alloc_bootmem_core+0x90/0x39c
>     lr: c000000000a64bcc: .sparse_early_usemaps_alloc_node+0x84/0x29c
>     sp: c000000000c03bc0
>    msr: 8000000000021032
>   current = 0xc000000000b0cce0
>   paca    = 0xc000000001d80000
>     pid   = 0, comm = swapper
> kernel BUG at mm/bootmem.c:483!
> enter ? for help
> [c000000000c03c80] c000000000a64bcc
> .sparse_early_usemaps_alloc_node+0x84/0x29c
> [c000000000c03d50] c000000000a64f10 .sparse_init+0x12c/0x28c
> [c000000000c03e20] c000000000a474f4 .setup_arch+0x20c/0x294
> [c000000000c03ee0] c000000000a4079c .start_kernel+0xb4/0x460
> [c000000000c03f90] c000000000009670 .start_here_common+0x1c/0x2c
> 
> This is
> 
>         BUG_ON(limit && goal + size > limit);
> 
> and after some debugging, it seems that
> 
> 	goal = 0x7ffff000000
> 	limit = 0x80000000000
> 
> and sparse_early_usemaps_alloc_node ->
> sparse_early_usemaps_alloc_pgdat_section -> alloc_bootmem_section calls
> 
> 	return alloc_bootmem_section(usemap_size() * count, section_nr);
> 
> This is on a system with 8TB available via the AMS pool, and as a quirk
> of AMS in firmware, all of that memory shows up in node 0. So, we end up
> with an allocation that will fail the goal/limit constraints. In theory,
> we could "fall-back" to alloc_bootmem_node() in
> sparse_early_usemaps_alloc_node(), but since we actually have HOTREMOVE
> defined, we'll BUG_ON() instead. A simple solution appears to be to
> disable the limit check if the size of the allocation in
> alloc_bootmem_secition exceeds the section size.

It makes sense to allow the usemaps to spill over to subsequent
sections instead of panicking, so FWIW:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

That being said, it would be good if check_usemap_section_nr() printed
the cross-dependencies between pgdats and sections when the usemaps of
a node spilled over to other sections than the ones holding the pgdat.

How about this?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: sparsemem/bootmem: catch greater than section size allocations fix

If alloc_bootmem_section() no longer guarantees section-locality, we
need check_usemap_section_nr() to print possible cross-dependencies
between node descriptors and the usemaps allocated through it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/sparse.c b/mm/sparse.c
index 61d7cde..9e032dc 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -359,6 +359,7 @@ static void __init sparse_early_usemaps_alloc_node(unsigned long**usemap_map,
 				continue;
 			usemap_map[pnum] = usemap;
 			usemap += size;
+			check_usemap_section_nr(nodeid, usemap_map[pnum]);
 		}
 		return;
 	}

---

Furthermore, I wonder if we can remove the sparse-specific stuff from
bootmem.c as well, as now even more so than before, calculating the
desired area is really none of bootmem's business.

Would something like this be okay?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: remove sparsemem allocation details from the bootmem allocator

alloc_bootmem_section() derives allocation area constraints from the
specified sparsemem section.  This is a bit specific for a generic
memory allocator like bootmem, though, so move it over to sparsemem.

Since __alloc_bootmem_node() already retries failed allocations with
relaxed area constraints, the fallback code in sparsemem.c can be
removed and the code becomes a bit more compact overall.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/bootmem.h |    3 ---
 mm/bootmem.c            |   26 --------------------------
 mm/sparse.c             |   29 +++++++++--------------------
 3 files changed, 9 insertions(+), 49 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index ab344a5..001c248 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -135,9 +135,6 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 extern int reserve_bootmem_generic(unsigned long addr, unsigned long size,
 				   int flags);
 
-extern void *alloc_bootmem_section(unsigned long size,
-				   unsigned long section_nr);
-
 #ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
 extern void *alloc_remap(int nid, unsigned long size);
 #else
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 7bc0557..d34026c 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -756,32 +756,6 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 
 }
 
-#ifdef CONFIG_SPARSEMEM
-/**
- * alloc_bootmem_section - allocate boot memory from a specific section
- * @size: size of the request in bytes
- * @section_nr: sparse map section to allocate from
- *
- * Return NULL on failure.
- */
-void * __init alloc_bootmem_section(unsigned long size,
-				    unsigned long section_nr)
-{
-	bootmem_data_t *bdata;
-	unsigned long pfn, goal, limit;
-
-	pfn = section_nr_to_pfn(section_nr);
-	goal = pfn << PAGE_SHIFT;
-	if (size > BYTES_PER_SECTION)
-		limit = 0;
-	else
-		limit = section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
-	bdata = &bootmem_node_data[early_pfn_to_nid(pfn)];
-
-	return alloc_bootmem_core(bdata, size, SMP_CACHE_BYTES, goal, limit);
-}
-#endif
-
 void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
 {
diff --git a/mm/sparse.c b/mm/sparse.c
index 9e032dc..ac0d5a3 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -273,10 +273,10 @@ static unsigned long *__kmalloc_section_usemap(void)
 #ifdef CONFIG_MEMORY_HOTREMOVE
 static unsigned long * __init
 sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
-					 unsigned long count)
+					 unsigned long size)
 {
-	unsigned long section_nr;
-
+	pg_data_t *host_pgdat;
+	unsigned long goal;
 	/*
 	 * A page may contain usemaps for other sections preventing the
 	 * page being freed and making a section unremovable while
@@ -287,8 +287,9 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 	 * from the same section as the pgdat where possible to avoid
 	 * this problem.
 	 */
-	section_nr = pfn_to_section_nr(__pa(pgdat) >> PAGE_SHIFT);
-	return alloc_bootmem_section(usemap_size() * count, section_nr);
+	goal = __pa(pgdat) & PAGE_SECTION_MASK;
+	host_pgdat = NODE_DATA(early_pfn_to_nid(goal));
+	return __alloc_bootmem_node(host_pgdat, size, SMP_CACHE_BYTES, goal);
 }
 
 static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
@@ -332,9 +333,9 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 #else
 static unsigned long * __init
 sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
-					 unsigned long count)
+					 unsigned long size)
 {
-	return NULL;
+	return alloc_bootmem_node(pgdat, size);
 }
 
 static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
@@ -352,19 +353,7 @@ static void __init sparse_early_usemaps_alloc_node(unsigned long**usemap_map,
 	int size = usemap_size();
 
 	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
-								 usemap_count);
-	if (usemap) {
-		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-			if (!present_section_nr(pnum))
-				continue;
-			usemap_map[pnum] = usemap;
-			usemap += size;
-			check_usemap_section_nr(nodeid, usemap_map[pnum]);
-		}
-		return;
-	}
-
-	usemap = alloc_bootmem_node(NODE_DATA(nodeid), size * usemap_count);
+							  size * usemap_count);
 	if (usemap) {
 		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
 			if (!present_section_nr(pnum))
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
