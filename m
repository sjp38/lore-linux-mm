Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id D86616B0073
	for <linux-mm@kvack.org>; Mon,  4 May 2015 02:19:26 -0400 (EDT)
Received: by widdi4 with SMTP id di4so99154297wid.0
        for <linux-mm@kvack.org>; Sun, 03 May 2015 23:19:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ck4si9967149wib.31.2015.05.03.23.19.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 03 May 2015 23:19:13 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [RESEND Patch V3 06/15] xen: split counting of extra memory pages from remapping
Date: Mon,  4 May 2015 08:18:57 +0200
Message-Id: <1430720346-21063-7-git-send-email-jgross@suse.com>
In-Reply-To: <1430720346-21063-1-git-send-email-jgross@suse.com>
References: <1430720346-21063-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org
Cc: Juergen Gross <jgross@suse.com>

Memory pages in the initial memory setup done by the Xen hypervisor
conflicting with the target E820 map are remapped. In order to do this
those pages are counted and remapped in xen_set_identity_and_remap().

Split the counting from the remapping operation to be able to setup
the needed memory sizes in time but doing the remap operation at a
later time. This enables us to simplify the interface to
xen_set_identity_and_remap() as the number of remapped and released
pages is no longer needed here.

Finally move the remapping further down to prepare relocating
conflicting memory contents before the memory might be clobbered by
xen_set_identity_and_remap(). This requires to not destroy the Xen
E820 map when the one for the system is being constructed.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/xen/setup.c | 98 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 58 insertions(+), 40 deletions(-)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index ab6c36e..87251b4 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -223,7 +223,7 @@ static int __init xen_free_mfn(unsigned long mfn)
  * as a fallback if the remapping fails.
  */
 static void __init xen_set_identity_and_release_chunk(unsigned long start_pfn,
-	unsigned long end_pfn, unsigned long nr_pages, unsigned long *released)
+			unsigned long end_pfn, unsigned long nr_pages)
 {
 	unsigned long pfn, end;
 	int ret;
@@ -243,7 +243,7 @@ static void __init xen_set_identity_and_release_chunk(unsigned long start_pfn,
 		WARN(ret != 1, "Failed to release pfn %lx err=%d\n", pfn, ret);
 
 		if (ret == 1) {
-			(*released)++;
+			xen_released_pages++;
 			if (!__set_phys_to_machine(pfn, INVALID_P2M_ENTRY))
 				break;
 		} else
@@ -359,8 +359,7 @@ static void __init xen_do_set_identity_and_remap_chunk(
  */
 static unsigned long __init xen_set_identity_and_remap_chunk(
 	unsigned long start_pfn, unsigned long end_pfn, unsigned long nr_pages,
-	unsigned long remap_pfn, unsigned long *released,
-	unsigned long *remapped)
+	unsigned long remap_pfn)
 {
 	unsigned long pfn;
 	unsigned long i = 0;
@@ -385,7 +384,7 @@ static unsigned long __init xen_set_identity_and_remap_chunk(
 		if (!remap_range_size) {
 			pr_warning("Unable to find available pfn range, not remapping identity pages\n");
 			xen_set_identity_and_release_chunk(cur_pfn,
-				cur_pfn + left, nr_pages, released);
+						cur_pfn + left, nr_pages);
 			break;
 		}
 		/* Adjust size to fit in current e820 RAM region */
@@ -397,7 +396,6 @@ static unsigned long __init xen_set_identity_and_remap_chunk(
 		/* Update variables to reflect new mappings. */
 		i += size;
 		remap_pfn += size;
-		*remapped += size;
 	}
 
 	/*
@@ -412,14 +410,11 @@ static unsigned long __init xen_set_identity_and_remap_chunk(
 	return remap_pfn;
 }
 
-static void __init xen_set_identity_and_remap(unsigned long nr_pages,
-			unsigned long *released, unsigned long *remapped)
+static void __init xen_set_identity_and_remap(unsigned long nr_pages)
 {
 	phys_addr_t start = 0;
 	unsigned long last_pfn = nr_pages;
 	const struct e820entry *entry = xen_e820_map;
-	unsigned long num_released = 0;
-	unsigned long num_remapped = 0;
 	int i;
 
 	/*
@@ -445,16 +440,12 @@ static void __init xen_set_identity_and_remap(unsigned long nr_pages,
 			if (start_pfn < end_pfn)
 				last_pfn = xen_set_identity_and_remap_chunk(
 						start_pfn, end_pfn, nr_pages,
-						last_pfn, &num_released,
-						&num_remapped);
+						last_pfn);
 			start = end;
 		}
 	}
 
-	*released = num_released;
-	*remapped = num_remapped;
-
-	pr_info("Released %ld page(s)\n", num_released);
+	pr_info("Released %ld page(s)\n", xen_released_pages);
 }
 
 /*
@@ -560,6 +551,28 @@ static void __init xen_ignore_unusable(void)
 	}
 }
 
+static unsigned long __init xen_count_remap_pages(unsigned long max_pfn)
+{
+	unsigned long extra = 0;
+	const struct e820entry *entry = xen_e820_map;
+	int i;
+
+	for (i = 0; i < xen_e820_map_entries; i++, entry++) {
+		unsigned long start_pfn = PFN_DOWN(entry->addr);
+		unsigned long end_pfn = PFN_UP(entry->addr + entry->size);
+
+		if (start_pfn >= max_pfn)
+			break;
+		if (entry->type == E820_RAM)
+			continue;
+		if (end_pfn >= max_pfn)
+			end_pfn = max_pfn;
+		extra += end_pfn - start_pfn;
+	}
+
+	return extra;
+}
+
 /*
  * Reserve Xen mfn_list.
  * See comment above "struct start_info" in <xen/interface/xen.h>
@@ -601,12 +614,12 @@ static void __init xen_reserve_xen_mfnlist(void)
 char * __init xen_memory_setup(void)
 {
 	unsigned long max_pfn = xen_start_info->nr_pages;
-	phys_addr_t mem_end;
+	phys_addr_t mem_end, addr, size, chunk_size;
+	u32 type;
 	int rc;
 	struct xen_memory_map memmap;
 	unsigned long max_pages;
 	unsigned long extra_pages = 0;
-	unsigned long remapped_pages;
 	int i;
 	int op;
 
@@ -653,15 +666,8 @@ char * __init xen_memory_setup(void)
 	if (max_pages > max_pfn)
 		extra_pages += max_pages - max_pfn;
 
-	/*
-	 * Set identity map on non-RAM pages and prepare remapping the
-	 * underlying RAM.
-	 */
-	xen_set_identity_and_remap(max_pfn, &xen_released_pages,
-				   &remapped_pages);
-
-	extra_pages += xen_released_pages;
-	extra_pages += remapped_pages;
+	/* How many extra pages do we need due to remapping? */
+	extra_pages += xen_count_remap_pages(max_pfn);
 
 	/*
 	 * Clamp the amount of extra memory to a EXTRA_MEM_RATIO
@@ -677,29 +683,35 @@ char * __init xen_memory_setup(void)
 	extra_pages = min(EXTRA_MEM_RATIO * min(max_pfn, PFN_DOWN(MAXMEM)),
 			  extra_pages);
 	i = 0;
+	addr = xen_e820_map[0].addr;
+	size = xen_e820_map[0].size;
 	while (i < xen_e820_map_entries) {
-		phys_addr_t addr = xen_e820_map[i].addr;
-		phys_addr_t size = xen_e820_map[i].size;
-		u32 type = xen_e820_map[i].type;
+		chunk_size = size;
+		type = xen_e820_map[i].type;
 
 		if (type == E820_RAM) {
 			if (addr < mem_end) {
-				size = min(size, mem_end - addr);
+				chunk_size = min(size, mem_end - addr);
 			} else if (extra_pages) {
-				size = min(size, PFN_PHYS(extra_pages));
-				extra_pages -= PFN_DOWN(size);
-				xen_add_extra_mem(addr, size);
-				xen_max_p2m_pfn = PFN_DOWN(addr + size);
+				chunk_size = min(size, PFN_PHYS(extra_pages));
+				extra_pages -= PFN_DOWN(chunk_size);
+				xen_add_extra_mem(addr, chunk_size);
+				xen_max_p2m_pfn = PFN_DOWN(addr + chunk_size);
 			} else
 				type = E820_UNUSABLE;
 		}
 
-		xen_align_and_add_e820_region(addr, size, type);
+		xen_align_and_add_e820_region(addr, chunk_size, type);
 
-		xen_e820_map[i].addr += size;
-		xen_e820_map[i].size -= size;
-		if (xen_e820_map[i].size == 0)
+		addr += chunk_size;
+		size -= chunk_size;
+		if (size == 0) {
 			i++;
+			if (i < xen_e820_map_entries) {
+				addr = xen_e820_map[i].addr;
+				size = xen_e820_map[i].size;
+			}
+		}
 	}
 
 	/*
@@ -709,7 +721,7 @@ char * __init xen_memory_setup(void)
 	 * PFNs above MAX_P2M_PFN are considered identity mapped as
 	 * well.
 	 */
-	set_phys_range_identity(xen_e820_map[i - 1].addr / PAGE_SIZE, ~0ul);
+	set_phys_range_identity(addr / PAGE_SIZE, ~0ul);
 
 	/*
 	 * In domU, the ISA region is normal, usable memory, but we
@@ -723,6 +735,12 @@ char * __init xen_memory_setup(void)
 
 	xen_reserve_xen_mfnlist();
 
+	/*
+	 * Set identity map on non-RAM pages and prepare remapping the
+	 * underlying RAM.
+	 */
+	xen_set_identity_and_remap(max_pfn);
+
 	return "Xen";
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
