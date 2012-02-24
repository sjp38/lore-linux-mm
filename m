Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 7B6BA6B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 14:34:08 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 24 Feb 2012 14:34:06 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id D5FED6E8066
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 14:34:03 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1OJY3MB322068
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 14:34:03 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1OJY1eO017076
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 12:34:02 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] sparsemem/bootmem: catch greater than section size allocations
Date: Fri, 24 Feb 2012 11:33:58 -0800
Message-Id: <1330112038-18951-1-git-send-email-nacc@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <haveblue@us.ibm.com>, Anton Blanchard <anton@au1.ibm.com>, Paul Mackerras <paulus@samba.org>, Ben Herrenschmidt <benh@kernel.crashing.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

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
sparse_early_usemaps_alloc_pgdat_section -> alloc_bootmem_section calls

	return alloc_bootmem_section(usemap_size() * count, section_nr);

This is on a system with 8TB available via the AMS pool, and as a quirk
of AMS in firmware, all of that memory shows up in node 0. So, we end up
with an allocation that will fail the goal/limit constraints. In theory,
we could "fall-back" to alloc_bootmem_node() in
sparse_early_usemaps_alloc_node(), but since we actually have HOTREMOVE
defined, we'll BUG_ON() instead. A simple solution appears to be to
disable the limit check if the size of the allocation in
alloc_bootmem_secition exceeds the section size.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>
Cc: Anton Blanchard <anton@au1.ibm.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
Cc: Robert Jennings <rcj@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org
---
 include/linux/mmzone.h |    2 ++
 mm/bootmem.c           |    5 ++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 650ba2f..4176834 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -967,6 +967,8 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
  * PA_SECTION_SHIFT		physical address to/from section number
  * PFN_SECTION_SHIFT		pfn to/from section number
  */
+#define BYTES_PER_SECTION	(1UL << SECTION_SIZE_BITS)
+
 #define SECTIONS_SHIFT		(MAX_PHYSMEM_BITS - SECTION_SIZE_BITS)
 
 #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 668e94d..5cbbc76 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -770,7 +770,10 @@ void * __init alloc_bootmem_section(unsigned long size,
 
 	pfn = section_nr_to_pfn(section_nr);
 	goal = pfn << PAGE_SHIFT;
-	limit = section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
+	if (size > BYTES_PER_SECTION)
+		limit = 0;
+	else
+		limit = section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
 	bdata = &bootmem_node_data[early_pfn_to_nid(pfn)];
 
 	return alloc_bootmem_core(bdata, size, SMP_CACHE_BYTES, goal, limit);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
