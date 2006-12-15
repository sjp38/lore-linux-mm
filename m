Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBFHG8VM010317
	for <linux-mm@kvack.org>; Fri, 15 Dec 2006 12:16:08 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBFHG8SD226020
	for <linux-mm@kvack.org>; Fri, 15 Dec 2006 12:16:08 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBFHG7HS022083
	for <linux-mm@kvack.org>; Fri, 15 Dec 2006 12:16:08 -0500
Subject: [PATCH] Fix sparsemem on Cell
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 15 Dec 2006 09:14:11 -0800
Message-Id: <20061215171411.E3EE01AD@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cbe-oss-dev@ozlabs.org
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, apw@shadowen.org, mkravetz@us.ibm.com, hch@infradead.org, jk@ozlabs.org, linux-kernel@vger.kernel.org, akpm@osdl.org, paulus@samba.org, benh@kernel.crashing.org, gone@us.ibm.com, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

I think the comments added say it pretty well, but I'll repeat it here.

This fix is pretty similar in concept to the one that Arnd posted
as a temporary workaround, but I've added a few comments explaining
what the actual assumptions are, and improved it a wee little bit.

The end goal here is to simply avoid calling the early_*() functions
when it is _not_ early.  Those functions stop working as soon as
free_initmem() is called.  system_state is set to SYSTEM_RUNNING
just after free_initmem() is called, so it seems appropriate to use
here.

I did think twice about actually using SYSTEM_RUNNING because we
moved away from it in other parts of memory hotplug, but those
were actually for _allocations_ in favor of slab_is_available(),
and we really don't care about the slab here.

The only other assumption is that all memory-hotplug-time pages 
given to memmap_init_zone() are valid and able to be onlined into
any any zone after the system is running.  The "valid" part is
really just a question of whether or not a 'struct page' is there
for the pfn, and *not* whether there is actual memory.  Since
all sparsemem sections have contiguous mem_map[]s within them,
and we only memory hotplug entire sparsemem sections, we can
be confident that this assumption will hold.

As for the memory being in the right node, we'll assume tha
memory hotplug is putting things in the right node.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

---

 lxc-dave/init/main.c     |    4 ++++
 lxc-dave/mm/page_alloc.c |   28 +++++++++++++++++++++++++---
 2 files changed, 29 insertions(+), 3 deletions(-)

diff -puN init/main.c~sparsemem-fix init/main.c
--- lxc/init/main.c~sparsemem-fix	2006-12-15 08:49:53.000000000 -0800
+++ lxc-dave/init/main.c	2006-12-15 08:49:53.000000000 -0800
@@ -770,6 +770,10 @@ static int init(void * unused)
 	free_initmem();
 	unlock_kernel();
 	mark_rodata_ro();
+	/*
+	 * Memory hotplug requires that this system_state transition
+	 * happer after free_initmem().  (see memmap_init_zone())
+	 */
 	system_state = SYSTEM_RUNNING;
 	numa_default_policy();
 
diff -puN mm/page_alloc.c~sparsemem-fix mm/page_alloc.c
--- lxc/mm/page_alloc.c~sparsemem-fix	2006-12-15 08:49:53.000000000 -0800
+++ lxc-dave/mm/page_alloc.c	2006-12-15 08:49:53.000000000 -0800
@@ -2056,6 +2056,30 @@ static inline unsigned long wait_table_b
 
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
 
+static int can_online_pfn_into_nid(unsigned long pfn, int nid)
+{
+	/*
+	 * There are two things that make this work:
+	 * 1. The early_pfn...() functions are __init and
+	 *    use __initdata.  If the system is < SYSTEM_RUNNING,
+	 *    those functions and their data will still exist.
+	 * 2. We also assume that all actual memory hotplug
+	 *    (as opposed to boot-time) calls to this are only
+	 *    for contiguous memory regions.  With sparsemem,
+	 *    this guaranteed is easy because all sections are
+	 *    contiguous and we never online more than one
+	 *    section at a time.  Boot-time memory can have holes
+	 *    anywhere.
+	 */
+	if (system_state >= SYSTEM_RUNNING)
+		return 1;
+	if (!early_pfn_valid(pfn))
+		return 0;
+	if (!early_pfn_in_nid(pfn, nid))
+		return 0;
+	return 1;
+}
+
 /*
  * Initially all pages are reserved - free ones are freed
  * up by free_all_bootmem() once the early boot process is
@@ -2069,9 +2093,7 @@ void __meminit memmap_init_zone(unsigned
 	unsigned long pfn;
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
-		if (!early_pfn_valid(pfn))
-			continue;
-		if (!early_pfn_in_nid(pfn, nid))
+		if (!can_online_pfn_into_nid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
 		set_page_links(page, zone, nid, pfn);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
