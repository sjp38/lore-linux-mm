Date: Fri, 18 May 2007 06:08:54 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc] increase struct page size?!
Message-ID: <20070518040854.GA15654@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

I'd like to be the first to propose an increase to the size of struct page
just for the sake of increasing it!

If we add 8 bytes to struct page on 64-bit machines, it becomes 64 bytes,
which is quite a nice number for cache purposes.

However we don't have to let those 8 bytes go to waste: we can use them
to store the virtual address of the page, which kind of makes sense for
64-bit, because they can likely to use complicated memory models.

I'd say all up this is going to decrease overall cache footprint in 
fastpaths, both by reducing text and data footprint of page_address and
related operations, and by reducing cacheline footprint of most batched
operations on struct pages.

Flame away :)

--

Many batch operations on struct page are completely random, and as such, I
think it is better if each struct page fits completely into a single
cacheline even if it means being slightly larger.

Don't let this space go to waste though, we can use page->virtual in order
to optimise page_address operations.

Interestingly, the irony of 32-bit architectures setting WANT_PAGE_VIRTUAL
because they have slow multiplications is that without WANT_PAGE_VIRTUAL, the
struct is 32-bytes and so page_address can usually be calculated with a shift.
So WANT_PAGE_VIRTUAL just bloats up the size of struct page for those guys!


Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -9,6 +9,14 @@
 struct address_space;
 
 /*
+ * WANT_PAGE_VIRTUAL on 64-bit machines gives a nice 64 byte alignment,
+ * so a struct page will fit entirely into a cacheline on modern CPUs.
+ */
+#if BITS_PER_LONG == 64
+# define WANT_PAGE_VIRTUAL
+#endif
+
+/*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
  * moment. Note that we have no way to track which tasks are using
Index: linux-2.6/include/linux/bootmem.h
===================================================================
--- linux-2.6.orig/include/linux/bootmem.h
+++ linux-2.6/include/linux/bootmem.h
@@ -91,7 +91,7 @@ extern void free_bootmem_node(pg_data_t 
 
 #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
 #define alloc_bootmem_node(pgdat, x) \
-	__alloc_bootmem_node(pgdat, x, SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node(pgdat, x, L1_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_pages_node(pgdat, x) \
 	__alloc_bootmem_node(pgdat, x, PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_low_pages_node(pgdat, x) \
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -2717,6 +2717,9 @@ static void __meminit alloc_node_mem_map
 	}
 #endif
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
+
+	if ((unsigned long)pgdat->node_mem_map & (L1_CACHE_BYTES - 1))
+		printk(KERN_WARNING "node_mem_map is not cacheline aligned!\n");
 }
 
 void __meminit free_area_init_node(int nid, struct pglist_data *pgdat,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
