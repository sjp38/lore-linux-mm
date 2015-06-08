Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7A06B0072
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:07:15 -0400 (EDT)
Received: by wigg3 with SMTP id g3so49894892wig.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:07:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei5si740105wid.118.2015.06.08.05.07.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:07:03 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [Patch V4 05/16] xen: move static e820 map to global scope
Date: Mon,  8 Jun 2015 14:06:46 +0200
Message-Id: <1433765217-16333-6-git-send-email-jgross@suse.com>
In-Reply-To: <1433765217-16333-1-git-send-email-jgross@suse.com>
References: <1433765217-16333-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>

Instead of using a function local static e820 map in xen_memory_setup()
and calling various functions in the same source with the map as a
parameter use a map directly accessible by all functions in the source.

Signed-off-by: Juergen Gross <jgross@suse.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 arch/x86/xen/setup.c | 96 +++++++++++++++++++++++++++-------------------------
 1 file changed, 49 insertions(+), 47 deletions(-)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index adad417..ab6c36e 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -38,6 +38,10 @@ struct xen_memory_region xen_extra_mem[XEN_EXTRA_MEM_MAX_REGIONS] __initdata;
 /* Number of pages released from the initial allocation. */
 unsigned long xen_released_pages;
 
+/* E820 map used during setting up memory. */
+static struct e820entry xen_e820_map[E820MAX] __initdata;
+static u32 xen_e820_map_entries __initdata;
+
 /*
  * Buffer used to remap identity mapped pages. We only need the virtual space.
  * The physical page behind this address is remapped as needed to different
@@ -164,15 +168,13 @@ void __init xen_inv_extra_mem(void)
  * This function updates min_pfn with the pfn found and returns
  * the size of that range or zero if not found.
  */
-static unsigned long __init xen_find_pfn_range(
-	const struct e820entry *list, size_t map_size,
-	unsigned long *min_pfn)
+static unsigned long __init xen_find_pfn_range(unsigned long *min_pfn)
 {
-	const struct e820entry *entry;
+	const struct e820entry *entry = xen_e820_map;
 	unsigned int i;
 	unsigned long done = 0;
 
-	for (i = 0, entry = list; i < map_size; i++, entry++) {
+	for (i = 0; i < xen_e820_map_entries; i++, entry++) {
 		unsigned long s_pfn;
 		unsigned long e_pfn;
 
@@ -356,9 +358,9 @@ static void __init xen_do_set_identity_and_remap_chunk(
  * to Xen and not remapped.
  */
 static unsigned long __init xen_set_identity_and_remap_chunk(
-        const struct e820entry *list, size_t map_size, unsigned long start_pfn,
-	unsigned long end_pfn, unsigned long nr_pages, unsigned long remap_pfn,
-	unsigned long *released, unsigned long *remapped)
+	unsigned long start_pfn, unsigned long end_pfn, unsigned long nr_pages,
+	unsigned long remap_pfn, unsigned long *released,
+	unsigned long *remapped)
 {
 	unsigned long pfn;
 	unsigned long i = 0;
@@ -379,8 +381,7 @@ static unsigned long __init xen_set_identity_and_remap_chunk(
 		if (cur_pfn + size > nr_pages)
 			size = nr_pages - cur_pfn;
 
-		remap_range_size = xen_find_pfn_range(list, map_size,
-						      &remap_pfn);
+		remap_range_size = xen_find_pfn_range(&remap_pfn);
 		if (!remap_range_size) {
 			pr_warning("Unable to find available pfn range, not remapping identity pages\n");
 			xen_set_identity_and_release_chunk(cur_pfn,
@@ -411,13 +412,12 @@ static unsigned long __init xen_set_identity_and_remap_chunk(
 	return remap_pfn;
 }
 
-static void __init xen_set_identity_and_remap(
-	const struct e820entry *list, size_t map_size, unsigned long nr_pages,
-	unsigned long *released, unsigned long *remapped)
+static void __init xen_set_identity_and_remap(unsigned long nr_pages,
+			unsigned long *released, unsigned long *remapped)
 {
 	phys_addr_t start = 0;
 	unsigned long last_pfn = nr_pages;
-	const struct e820entry *entry;
+	const struct e820entry *entry = xen_e820_map;
 	unsigned long num_released = 0;
 	unsigned long num_remapped = 0;
 	int i;
@@ -433,9 +433,9 @@ static void __init xen_set_identity_and_remap(
 	 * example) the DMI tables in a reserved region that begins on
 	 * a non-page boundary.
 	 */
-	for (i = 0, entry = list; i < map_size; i++, entry++) {
+	for (i = 0; i < xen_e820_map_entries; i++, entry++) {
 		phys_addr_t end = entry->addr + entry->size;
-		if (entry->type == E820_RAM || i == map_size - 1) {
+		if (entry->type == E820_RAM || i == xen_e820_map_entries - 1) {
 			unsigned long start_pfn = PFN_DOWN(start);
 			unsigned long end_pfn = PFN_UP(end);
 
@@ -444,9 +444,9 @@ static void __init xen_set_identity_and_remap(
 
 			if (start_pfn < end_pfn)
 				last_pfn = xen_set_identity_and_remap_chunk(
-						list, map_size, start_pfn,
-						end_pfn, nr_pages, last_pfn,
-						&num_released, &num_remapped);
+						start_pfn, end_pfn, nr_pages,
+						last_pfn, &num_released,
+						&num_remapped);
 			start = end;
 		}
 	}
@@ -549,12 +549,12 @@ static void __init xen_align_and_add_e820_region(phys_addr_t start,
 	e820_add_region(start, end - start, type);
 }
 
-static void __init xen_ignore_unusable(struct e820entry *list, size_t map_size)
+static void __init xen_ignore_unusable(void)
 {
-	struct e820entry *entry;
+	struct e820entry *entry = xen_e820_map;
 	unsigned int i;
 
-	for (i = 0, entry = list; i < map_size; i++, entry++) {
+	for (i = 0; i < xen_e820_map_entries; i++, entry++) {
 		if (entry->type == E820_UNUSABLE)
 			entry->type = E820_RAM;
 	}
@@ -600,8 +600,6 @@ static void __init xen_reserve_xen_mfnlist(void)
  **/
 char * __init xen_memory_setup(void)
 {
-	static struct e820entry map[E820MAX] __initdata;
-
 	unsigned long max_pfn = xen_start_info->nr_pages;
 	phys_addr_t mem_end;
 	int rc;
@@ -616,7 +614,7 @@ char * __init xen_memory_setup(void)
 	mem_end = PFN_PHYS(max_pfn);
 
 	memmap.nr_entries = E820MAX;
-	set_xen_guest_handle(memmap.buffer, map);
+	set_xen_guest_handle(memmap.buffer, xen_e820_map);
 
 	op = xen_initial_domain() ?
 		XENMEM_machine_memory_map :
@@ -625,15 +623,16 @@ char * __init xen_memory_setup(void)
 	if (rc == -ENOSYS) {
 		BUG_ON(xen_initial_domain());
 		memmap.nr_entries = 1;
-		map[0].addr = 0ULL;
-		map[0].size = mem_end;
+		xen_e820_map[0].addr = 0ULL;
+		xen_e820_map[0].size = mem_end;
 		/* 8MB slack (to balance backend allocations). */
-		map[0].size += 8ULL << 20;
-		map[0].type = E820_RAM;
+		xen_e820_map[0].size += 8ULL << 20;
+		xen_e820_map[0].type = E820_RAM;
 		rc = 0;
 	}
 	BUG_ON(rc);
 	BUG_ON(memmap.nr_entries == 0);
+	xen_e820_map_entries = memmap.nr_entries;
 
 	/*
 	 * Xen won't allow a 1:1 mapping to be created to UNUSABLE
@@ -644,10 +643,11 @@ char * __init xen_memory_setup(void)
 	 * a patch in the future.
 	 */
 	if (xen_initial_domain())
-		xen_ignore_unusable(map, memmap.nr_entries);
+		xen_ignore_unusable();
 
 	/* Make sure the Xen-supplied memory map is well-ordered. */
-	sanitize_e820_map(map, memmap.nr_entries, &memmap.nr_entries);
+	sanitize_e820_map(xen_e820_map, xen_e820_map_entries,
+			  &xen_e820_map_entries);
 
 	max_pages = xen_get_max_pages();
 	if (max_pages > max_pfn)
@@ -657,8 +657,8 @@ char * __init xen_memory_setup(void)
 	 * Set identity map on non-RAM pages and prepare remapping the
 	 * underlying RAM.
 	 */
-	xen_set_identity_and_remap(map, memmap.nr_entries, max_pfn,
-				   &xen_released_pages, &remapped_pages);
+	xen_set_identity_and_remap(max_pfn, &xen_released_pages,
+				   &remapped_pages);
 
 	extra_pages += xen_released_pages;
 	extra_pages += remapped_pages;
@@ -677,10 +677,10 @@ char * __init xen_memory_setup(void)
 	extra_pages = min(EXTRA_MEM_RATIO * min(max_pfn, PFN_DOWN(MAXMEM)),
 			  extra_pages);
 	i = 0;
-	while (i < memmap.nr_entries) {
-		phys_addr_t addr = map[i].addr;
-		phys_addr_t size = map[i].size;
-		u32 type = map[i].type;
+	while (i < xen_e820_map_entries) {
+		phys_addr_t addr = xen_e820_map[i].addr;
+		phys_addr_t size = xen_e820_map[i].size;
+		u32 type = xen_e820_map[i].type;
 
 		if (type == E820_RAM) {
 			if (addr < mem_end) {
@@ -696,9 +696,9 @@ char * __init xen_memory_setup(void)
 
 		xen_align_and_add_e820_region(addr, size, type);
 
-		map[i].addr += size;
-		map[i].size -= size;
-		if (map[i].size == 0)
+		xen_e820_map[i].addr += size;
+		xen_e820_map[i].size -= size;
+		if (xen_e820_map[i].size == 0)
 			i++;
 	}
 
@@ -709,7 +709,7 @@ char * __init xen_memory_setup(void)
 	 * PFNs above MAX_P2M_PFN are considered identity mapped as
 	 * well.
 	 */
-	set_phys_range_identity(map[i-1].addr / PAGE_SIZE, ~0ul);
+	set_phys_range_identity(xen_e820_map[i - 1].addr / PAGE_SIZE, ~0ul);
 
 	/*
 	 * In domU, the ISA region is normal, usable memory, but we
@@ -731,23 +731,25 @@ char * __init xen_memory_setup(void)
  */
 char * __init xen_auto_xlated_memory_setup(void)
 {
-	static struct e820entry map[E820MAX] __initdata;
-
 	struct xen_memory_map memmap;
 	int i;
 	int rc;
 
 	memmap.nr_entries = E820MAX;
-	set_xen_guest_handle(memmap.buffer, map);
+	set_xen_guest_handle(memmap.buffer, xen_e820_map);
 
 	rc = HYPERVISOR_memory_op(XENMEM_memory_map, &memmap);
 	if (rc < 0)
 		panic("No memory map (%d)\n", rc);
 
-	sanitize_e820_map(map, ARRAY_SIZE(map), &memmap.nr_entries);
+	xen_e820_map_entries = memmap.nr_entries;
+
+	sanitize_e820_map(xen_e820_map, ARRAY_SIZE(xen_e820_map),
+			  &xen_e820_map_entries);
 
-	for (i = 0; i < memmap.nr_entries; i++)
-		e820_add_region(map[i].addr, map[i].size, map[i].type);
+	for (i = 0; i < xen_e820_map_entries; i++)
+		e820_add_region(xen_e820_map[i].addr, xen_e820_map[i].size,
+				xen_e820_map[i].type);
 
 	xen_reserve_xen_mfnlist();
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
