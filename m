Received: from titus.gormenghast (216-99-194-186.dial.spiritone.com [216.99.194.186])
	by franka.aracnet.com (8.12.5/8.12.5) with ESMTP id g726br7m031412
	for <linux-mm@kvack.org>; Thu, 1 Aug 2002 23:37:54 -0700
Received: from [10.10.2.3] (fuchsia.gormenghast [10.10.2.3])
	by titus.gormenghast (8.9.3/8.9.3/Debian 8.9.3-21) with ESMTP id PAA28486
	for <linux-mm@kvack.org>; Thu, 1 Aug 2002 15:54:23 -0700
Date: Thu, 01 Aug 2002 23:38:07 -0700
From: "Martin J. Bligh" <fletch@aracnet.com>
Subject: [RFC] reduce usage of mem_map
Message-ID: <869105998.1028245087@[10.10.2.3]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've tried to cut down the usage of mem_map somewhat.
There's already macros to do the conversion between
pfns to pages, and it doesn't work the way they've
embedded it for discontigmem systems. Comments?
Please don't apply - not tested yet ;-)

M.

diff -urN virgin-2.5.30/arch/i386/mm/init.c linux-2.5.30-pfn_to_page/arch/i386/mm/init.c
--- virgin-2.5.30/arch/i386/mm/init.c	Thu Aug  1 14:16:13 2002
+++ linux-2.5.30-pfn_to_page/arch/i386/mm/init.c	Thu Aug  1 22:39:17 2002
@@ -217,7 +217,7 @@
 {
 	int pfn;
 	for (pfn = highstart_pfn; pfn < highend_pfn; pfn++) {
-		struct page *page = mem_map + pfn;
+		struct page *page = pfn_to_page(pfn);
 
 		if (!page_is_ram(pfn)) {
 			SetPageReserved(page);
@@ -419,7 +419,7 @@
 	bad_ppro = ppro_with_ram_bug();
 
 #ifdef CONFIG_HIGHMEM
-	highmem_start_page = mem_map + highstart_pfn;
+	highmem_start_page = pfn_to_page(highstart_pfn);
 	max_mapnr = num_physpages = highend_pfn;
 #else
 	max_mapnr = num_physpages = max_low_pfn;
@@ -437,7 +437,7 @@
 		/*
 		 * Only count reserved RAM pages
 		 */
-		if (page_is_ram(tmp) && PageReserved(mem_map+tmp))
+		if (page_is_ram(tmp) && PageReserved(pfn_to_page(tmp)))
 			reservedpages++;
 
 	set_highmem_pages_init(bad_ppro);
diff -urN virgin-2.5.30/arch/i386/mm/pgtable.c linux-2.5.30-pfn_to_page/arch/i386/mm/pgtable.c
--- virgin-2.5.30/arch/i386/mm/pgtable.c	Thu Aug  1 14:17:27 2002
+++ linux-2.5.30-pfn_to_page/arch/i386/mm/pgtable.c	Thu Aug  1 17:55:07 2002
@@ -22,24 +22,26 @@
 
 void show_mem(void)
 {
-	int i, total = 0, reserved = 0;
+	int pfn, total = 0, reserved = 0;
 	int shared = 0, cached = 0;
 	int highmem = 0;
+	struct page *page;
 
 	printk("Mem-info:\n");
 	show_free_areas();
 	printk("Free swap:       %6dkB\n",nr_swap_pages<<(PAGE_SHIFT-10));
-	i = max_mapnr;
-	while (i-- > 0) {
+	pfn = max_mapnr;
+	while (pfn-- > 0) {
+		page = pfn_to_page(pfn);
 		total++;
-		if (PageHighMem(mem_map+i))
+		if (PageHighMem(page)
 			highmem++;
-		if (PageReserved(mem_map+i))
+		if (PageReserved(page))
 			reserved++;
-		else if (PageSwapCache(mem_map+i))
+		else if (PageSwapCache(page))
 			cached++;
-		else if (page_count(mem_map+i))
-			shared += page_count(mem_map+i) - 1;
+		else if (page_count(page))
+			shared += page_count(page) - 1;
 	}
 	printk("%d pages of RAM\n", total);
 	printk("%d pages of HIGHMEM\n",highmem);
diff -urN virgin-2.5.30/drivers/net/ns83820.c linux-2.5.30-pfn_to_page/drivers/net/ns83820.c
--- virgin-2.5.30/drivers/net/ns83820.c	Thu Aug  1 14:16:44 2002
+++ linux-2.5.30-pfn_to_page/drivers/net/ns83820.c	Thu Aug  1 22:43:41 2002
@@ -1081,7 +1081,7 @@
 				   frag->page_offset,
 				   frag->size, PCI_DMA_TODEVICE);
 		dprintk("frag: buf=%08Lx  page=%08lx offset=%08lx\n",
-			(long long)buf, (long)(frag->page - mem_map),
+			(long long)buf, (long) page_to_pfn(frag->page),
 			frag->page_offset);
 		len = frag->size;
 		frag++;
diff -urN virgin-2.5.30/include/asm-i386/pci.h linux-2.5.30-pfn_to_page/include/asm-i386/pci.h
--- virgin-2.5.30/include/asm-i386/pci.h	Thu Aug  1 14:16:22 2002
+++ linux-2.5.30-pfn_to_page/include/asm-i386/pci.h	Thu Aug  1 23:00:43 2002
@@ -109,7 +109,7 @@
 	if (direction == PCI_DMA_NONE)
 		BUG();
 
-	return (dma_addr_t)(page - mem_map) * PAGE_SIZE + offset;
+	return (dma_addr_t)(page_to_pfn(page)) * PAGE_SIZE + offset;
 }
 
 static inline void pci_unmap_page(struct pci_dev *hwdev, dma_addr_t dma_address,
@@ -240,7 +240,7 @@
 {
 	unsigned long poff = (dma_addr >> PAGE_SHIFT);
 
-	return mem_map + poff;
+	return pfn_to_page(poff);
 }
 
 static __inline__ unsigned long
diff -urN virgin-2.5.30/include/asm-i386/pgtable.h linux-2.5.30-pfn_to_page/include/asm-i386/pgtable.h
--- virgin-2.5.30/include/asm-i386/pgtable.h	Thu Aug  1 14:16:32 2002
+++ linux-2.5.30-pfn_to_page/include/asm-i386/pgtable.h	Thu Aug  1 23:11:30 2002
@@ -235,7 +235,7 @@
 ((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
 
 #define pmd_page(pmd) \
-	(mem_map + (pmd_val(pmd) >> PAGE_SHIFT))
+	(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
 
 #define pmd_large(pmd) \
 	((pmd_val(pmd) & (_PAGE_PSE|_PAGE_PRESENT)) == (_PAGE_PSE|_PAGE_PRESENT))
diff -urN virgin-2.5.30/kernel/suspend.c linux-2.5.30-pfn_to_page/kernel/suspend.c
--- virgin-2.5.30/kernel/suspend.c	Thu Aug  1 14:16:15 2002
+++ linux-2.5.30-pfn_to_page/kernel/suspend.c	Thu Aug  1 23:17:51 2002
@@ -468,31 +468,33 @@
 {
 	int chunk_size;
 	int nr_copy_pages = 0;
-	int loop;
+	int pfn;
+	struct page *page;
 	
 	if (max_mapnr != num_physpages)
 		panic("mapnr is not expected");
-	for (loop = 0; loop < max_mapnr; loop++) {
-		if (PageHighMem(mem_map+loop))
+	for (pfn = 0; pfn < max_mapnr; pfn++) {
+		page = pfn_to_page(pfn);
+		if (PageHighMem(page))
 			panic("Swsusp not supported on highmem boxes. Send 1GB of RAM to <pavel@ucw.cz> and try again ;-).");
-		if (!PageReserved(mem_map+loop)) {
-			if (PageNosave(mem_map+loop))
+		if (!PageReserved(page)) {
+			if (PageNosave(page))
 				continue;
 
-			if ((chunk_size=is_head_of_free_region(mem_map+loop))!=0) {
-				loop += chunk_size - 1;
+			if ((chunk_size=is_head_of_free_region(page))!=0) {
+				pfn += chunk_size - 1;
 				continue;
 			}
-		} else if (PageReserved(mem_map+loop)) {
-			BUG_ON (PageNosave(mem_map+loop));
+		} else if (PageReserved(page)) {
+			BUG_ON (PageNosave(page));
 
 			/*
 			 * Just copy whole code segment. Hopefully it is not that big.
 			 */
-			if (ADDRESS(loop) >= (unsigned long)
-				&__nosave_begin && ADDRESS(loop) < 
+			if (ADDRESS(pfn) >= (unsigned long)
+				&__nosave_begin && ADDRESS(pfn) < 
 				(unsigned long)&__nosave_end) {
-				PRINTK("[nosave %x]", ADDRESS(loop));
+				PRINTK("[nosave %x]", ADDRESS(pfn));
 				continue;
 			}
 			/* Hmm, perhaps copying all reserved pages is not too healthy as they may contain 
@@ -501,7 +503,7 @@
 
 		nr_copy_pages++;
 		if (pagedir_p) {
-			pagedir_p->orig_address = ADDRESS(loop);
+			pagedir_p->orig_address = ADDRESS(pfn);
 			copy_page(pagedir_p->address, pagedir_p->orig_address);
 			pagedir_p++;
 		}
diff -urN virgin-2.5.30/mm/page_alloc.c linux-2.5.30-pfn_to_page/mm/page_alloc.c
--- virgin-2.5.30/mm/page_alloc.c	Thu Aug  1 14:16:06 2002
+++ linux-2.5.30-pfn_to_page/mm/page_alloc.c	Thu Aug  1 23:25:13 2002
@@ -47,9 +47,9 @@
  */
 static inline int bad_range(zone_t *zone, struct page *page)
 {
-	if (page - mem_map >= zone->zone_start_mapnr + zone->size)
+	if (page_to_pfn(page) >= zone->zone_start_mapnr + zone->size)
 		return 1;
-	if (page - mem_map < zone->zone_start_mapnr)
+	if (page_to_pfn(page) < zone->zone_start_mapnr)
 		return 1;
 	if (zone != page_zone(page))
 		return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
