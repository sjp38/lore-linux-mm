Date: Fri, 16 Aug 2002 13:45:34 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: clean up mem_map usage ... part 1
Message-ID: <2441610000.1029530734@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This simply converts direct usage of mem_map to the correct macros
(mem_map doesn't work like this for discontigmem). It also fixes a bug
in bad_range, that happens to work for contig mem systems, but is
incorrect. Tested both with and without discontigmem support.

please forward to Linus if you're happy with it .... applies on top of
the i386 discontigmem patches.

M.

diff -urN 2.5.31-13-numa/arch/i386/mm/init.c 2.5.31-21-bad_range/arch/i386/mm/init.c
--- 2.5.31-13-numa/arch/i386/mm/init.c	Fri Aug 16 11:26:20 2002
+++ 2.5.31-21-bad_range/arch/i386/mm/init.c	Fri Aug 16 11:34:33 2002
@@ -235,7 +235,7 @@
 {
 	int pfn;
 	for (pfn = highstart_pfn; pfn < highend_pfn; pfn++)
-		one_highpage_init((struct page *)(mem_map + pfn), pfn, bad_ppro);
+		one_highpage_init((struct page *)pfn_to_page(pfn), pfn, bad_ppro);
 	totalram_pages += totalhigh_pages;
 }
 #else
@@ -419,7 +419,7 @@
 static void __init set_max_mapnr_init(void)
 {
 #ifdef CONFIG_HIGHMEM
-	highmem_start_page = mem_map + highstart_pfn;
+	highmem_start_page = pfn_to_page(highstart_pfn);
 	max_mapnr = num_physpages = highend_pfn;
 #else
 	max_mapnr = num_physpages = max_low_pfn;
@@ -458,7 +458,7 @@
 		/*
 		 * Only count reserved RAM pages
 		 */
-		if (page_is_ram(tmp) && PageReserved(mem_map+tmp))
+		if (page_is_ram(tmp) && PageReserved(pfn_to_page(tmp)))
 			reservedpages++;
 
 	set_highmem_pages_init(bad_ppro);
diff -urN 2.5.31-13-numa/arch/i386/mm/pgtable.c 2.5.31-21-bad_range/arch/i386/mm/pgtable.c
--- 2.5.31-13-numa/arch/i386/mm/pgtable.c	Sat Aug 10 18:42:09 2002
+++ 2.5.31-21-bad_range/arch/i386/mm/pgtable.c	Fri Aug 16 11:34:33 2002
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
+		if (PageHighMem(page))
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
diff -urN 2.5.31-13-numa/drivers/net/ns83820.c 2.5.31-21-bad_range/drivers/net/ns83820.c
--- 2.5.31-13-numa/drivers/net/ns83820.c	Sat Aug 10 18:41:55 2002
+++ 2.5.31-21-bad_range/drivers/net/ns83820.c	Fri Aug 16 11:34:33 2002
@@ -1081,7 +1081,7 @@
 				   frag->page_offset,
 				   frag->size, PCI_DMA_TODEVICE);
 		dprintk("frag: buf=%08Lx  page=%08lx offset=%08lx\n",
-			(long long)buf, (long)(frag->page - mem_map),
+			(long long)buf, (long) page_to_pfn(frag->page),
 			frag->page_offset);
 		len = frag->size;
 		frag++;
diff -urN 2.5.31-13-numa/include/asm-i386/pci.h 2.5.31-21-bad_range/include/asm-i386/pci.h
--- 2.5.31-13-numa/include/asm-i386/pci.h	Sat Aug 10 18:41:27 2002
+++ 2.5.31-21-bad_range/include/asm-i386/pci.h	Fri Aug 16 11:34:33 2002
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
diff -urN 2.5.31-13-numa/include/asm-i386/pgtable.h 2.5.31-21-bad_range/include/asm-i386/pgtable.h
--- 2.5.31-13-numa/include/asm-i386/pgtable.h	Fri Aug 16 11:26:20 2002
+++ 2.5.31-21-bad_range/include/asm-i386/pgtable.h	Fri Aug 16 11:34:33 2002
@@ -236,7 +236,7 @@
 
 #ifndef CONFIG_DISCONTIGMEM
 #define pmd_page(pmd) \
-	(mem_map + (pmd_val(pmd) >> PAGE_SHIFT))
+	(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
 #endif /* !CONFIG_DISCONTIGMEM */
 
 #define pmd_large(pmd) \
diff -urN 2.5.31-13-numa/kernel/suspend.c 2.5.31-21-bad_range/kernel/suspend.c
--- 2.5.31-13-numa/kernel/suspend.c	Sat Aug 10 18:41:24 2002
+++ 2.5.31-21-bad_range/kernel/suspend.c	Fri Aug 16 11:34:33 2002
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
diff -urN 2.5.31-13-numa/mm/page_alloc.c 2.5.31-21-bad_range/mm/page_alloc.c
--- 2.5.31-13-numa/mm/page_alloc.c	Fri Aug 16 11:26:56 2002
+++ 2.5.31-21-bad_range/mm/page_alloc.c	Fri Aug 16 13:43:20 2002
@@ -47,9 +47,9 @@
  */
 static inline int bad_range(zone_t *zone, struct page *page)
 {
-	if (page - mem_map >= zone->zone_start_mapnr + zone->size)
+	if (page_to_pfn(page) >= zone->zone_start_pfn + zone->size)
 		return 1;
-	if (page - mem_map < zone->zone_start_mapnr)
+	if (page_to_pfn(page) < zone->zone_start_pfn)
 		return 1;
 	if (zone != page_zone(page))
 		return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
