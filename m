Date: Thu, 10 Apr 2003 14:07:54 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] bootmem speedup from the IA64 tree
Message-Id: <20030410140754.763db0b4.akpm@digeo.com>
In-Reply-To: <45550000.1050006895@flay>
References: <20030410122421.A17889@lst.de>
	<20030410095930.D9136@redhat.com>
	<20030410134334.37c86863.akpm@digeo.com>
	<45550000.1050006895@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: bcrl@redhat.com, hch@lst.de, davidm@napali.hpl.hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> > Bootmem igornamus says:
> > 
> > Do we have a problem with using an `unsigned long' byte address in there on
> > ia32 PAE?  Or are we guaranteed that this will only ever be used in the lower
> > 4G of physical memory?
> 
> IIRC, only ZONE_NORMAL goes into bootmem, so we should be OK.
> 

OK, thanks.  You didn't answer my other question ;)

I stuck

        if (addr < bdata->last_success)
                bdata->last_success = addr;

in free_bootmem_core().


diff -puN mm/bootmem.c~bootmem-speedup mm/bootmem.c
--- 25/mm/bootmem.c~bootmem-speedup	Thu Apr 10 13:35:15 2003
+++ 25-akpm/mm/bootmem.c	Thu Apr 10 14:06:54 2003
@@ -115,6 +115,9 @@ static void __init free_bootmem_core(boo
 	if (end > bdata->node_low_pfn)
 		BUG();
 
+	if (addr < bdata->last_success)
+		bdata->last_success = addr;
+
 	/*
 	 * Round up the beginning of the address.
 	 */
@@ -135,26 +138,23 @@ static void __init free_bootmem_core(boo
  * is not a problem.
  *
  * On low memory boxes we get it right in 100% of the cases.
- */
-
-/*
+ *
  * alignment has to be a power of 2 value.
+ *
+ * NOTE:  This function is _not_ reenetrant.
  */
-static void * __init __alloc_bootmem_core (bootmem_data_t *bdata, 
-	unsigned long size, unsigned long align, unsigned long goal)
+static void * __init
+__alloc_bootmem_core(struct bootmem_data *bdata, unsigned long size,
+		unsigned long align, unsigned long goal)
 {
-	unsigned long i, start = 0;
+	unsigned long offset, remaining_size, areasize, preferred;
+	unsigned long i, start = 0, incr, eidx;
 	void *ret;
-	unsigned long offset, remaining_size;
-	unsigned long areasize, preferred, incr;
-	unsigned long eidx = bdata->node_low_pfn - (bdata->node_boot_start >>
-							PAGE_SHIFT);
-
-	if (!size) BUG();
 
-	if (align & (align-1))
-		BUG();
+	BUG_ON(!size);
+	BUG_ON(align & (align-1));
 
+	eidx = bdata->node_low_pfn - (bdata->node_boot_start >> PAGE_SHIFT);
 	offset = 0;
 	if (align &&
 	    (bdata->node_boot_start & (align - 1UL)) != 0)
@@ -166,8 +166,11 @@ static void * __init __alloc_bootmem_cor
 	 * first, then we try to allocate lower pages.
 	 */
 	if (goal && (goal >= bdata->node_boot_start) && 
-			((goal >> PAGE_SHIFT) < bdata->node_low_pfn)) {
+	    ((goal >> PAGE_SHIFT) < bdata->node_low_pfn)) {
 		preferred = goal - bdata->node_boot_start;
+
+		if (bdata->last_success >= preferred)
+			preferred = bdata->last_success;
 	} else
 		preferred = 0;
 
@@ -179,6 +182,8 @@ static void * __init __alloc_bootmem_cor
 restart_scan:
 	for (i = preferred; i < eidx; i += incr) {
 		unsigned long j;
+		i = find_next_zero_bit(bdata->node_bootmem_map, eidx, i);
+		i = (i + incr - 1) & -incr;
 		if (test_bit(i, bdata->node_bootmem_map))
 			continue;
 		for (j = i + 1; j < i + areasize; ++j) {
@@ -189,31 +194,33 @@ restart_scan:
 		}
 		start = i;
 		goto found;
-	fail_block:;
+	fail_block:
+		;
 	}
+
 	if (preferred) {
 		preferred = offset;
 		goto restart_scan;
 	}
 	return NULL;
+
 found:
-	if (start >= eidx)
-		BUG();
+	bdata->last_success = start << PAGE_SHIFT;
+	BUG_ON(start >= eidx);
 
 	/*
 	 * Is the next page of the previous allocation-end the start
 	 * of this allocation's buffer? If yes then we can 'merge'
 	 * the previous partial page with this allocation.
 	 */
-	if (align < PAGE_SIZE
-	    && bdata->last_offset && bdata->last_pos+1 == start) {
+	if (align < PAGE_SIZE &&
+	    bdata->last_offset && bdata->last_pos+1 == start) {
 		offset = (bdata->last_offset+align-1) & ~(align-1);
-		if (offset > PAGE_SIZE)
-			BUG();
+		BUG_ON(offset > PAGE_SIZE);
 		remaining_size = PAGE_SIZE-offset;
 		if (size < remaining_size) {
 			areasize = 0;
-			// last_pos unchanged
+			/* last_pos unchanged */
 			bdata->last_offset = offset+size;
 			ret = phys_to_virt(bdata->last_pos*PAGE_SIZE + offset +
 						bdata->node_boot_start);
@@ -231,11 +238,12 @@ found:
 		bdata->last_offset = size & ~PAGE_MASK;
 		ret = phys_to_virt(start * PAGE_SIZE + bdata->node_boot_start);
 	}
+
 	/*
 	 * Reserve the area now:
 	 */
 	for (i = start; i < start+areasize; i++)
-		if (test_and_set_bit(i, bdata->node_bootmem_map))
+		if (unlikely(test_and_set_bit(i, bdata->node_bootmem_map)))
 			BUG();
 	memset(ret, 0, size);
 	return ret;
@@ -256,21 +264,21 @@ static unsigned long __init free_all_boo
 	map = bdata->node_bootmem_map;
 	for (i = 0; i < idx; ) {
 		unsigned long v = ~map[i / BITS_PER_LONG];
-		if (v) { 
+		if (v) {
 			unsigned long m;
-			for (m = 1; m && i < idx; m<<=1, page++, i++) { 
+			for (m = 1; m && i < idx; m<<=1, page++, i++) {
 				if (v & m) {
-			count++;
-			ClearPageReserved(page);
-			set_page_count(page, 1);
-			__free_page(page);
-		}
-	}
+					count++;
+					ClearPageReserved(page);
+					set_page_count(page, 1);
+					__free_page(page);
+				}
+			}
 		} else {
 			i+=BITS_PER_LONG;
-			page+=BITS_PER_LONG; 
-		} 	
-	}	
+			page += BITS_PER_LONG;
+		}
+	}
 	total += count;
 
 	/*
diff -puN include/linux/bootmem.h~bootmem-speedup include/linux/bootmem.h
--- 25/include/linux/bootmem.h~bootmem-speedup	Thu Apr 10 13:38:43 2003
+++ 25-akpm/include/linux/bootmem.h	Thu Apr 10 13:39:17 2003
@@ -32,6 +32,8 @@ typedef struct bootmem_data {
 	void *node_bootmem_map;
 	unsigned long last_offset;
 	unsigned long last_pos;
+	unsigned long last_success;	/* Previous allocation point.  To speed
+					 * up searching */
 } bootmem_data_t;
 
 extern unsigned long __init bootmem_bootmap_pages (unsigned long);

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
