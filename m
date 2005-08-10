Date: Wed, 10 Aug 2005 15:10:20 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
In-Reply-To: <17145.13835.592008.577583@wombat.chubb.wattle.id.au>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com> <17145.13835.592008.577583@wombat.chubb.wattle.id.au>
Message-Id: <20050810145550.740D.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ia64@vger.kernel.org, Mike Kravetz <kravetz@us.ibm.com>, "Luck, Tony" <tony.luck@intel.com>
List-ID: <linux-mm.kvack.org>

> Yasunori> +static inline unsigned long max_dma_physaddr(void) 
> Yasunori> +{
> Yasunori> + 
> Yasunori> +  if (MAX_DMA_ADDRESS == ~0UL) 
> Yasunori> +	return MAX_DMA_ADDRESS; 
> Yasunori> +  else 
> Yasunori> +	return __pa(MAX_DMA_ADDRESS); 
> Yasunori> +} 
> 
> This code illustrates one of my pet coding-style hates:  there's no
> need for the `else' as the return statement means it'll never be
> reached.
> 
> 	if (MAX_DMA_ADDRESS == ~0UL)
> 	    return MAX_DMA_ADDRESS;
> 	return __pa(MAX_DMA_ADDRESS);
> 
> is all that's needed.

Ok. I modified it.
Thanks for your comment.

Bye.

------------------------------------------------------

This is a patch to guarantee that alloc_bootmem_low() allocate DMA area.

Current alloc_bootmem_low() is just specify "goal=0". And it is 
used for __alloc_bootmem_core() to decide which address is better.
However, there is no guarantee that __alloc_bootmem_core()
allocate DMA area when goal=0 is specified.
Even if there is no DMA'ble area in searching node, it allocates
higher address than MAX_DMA_ADDRESS.

__alloc_bootmem_core() is called by order of for_each_pgdat()
in __alloc_bootmem(). So, if first node (node_id = 0) has
DMA'ble area, no trouble will occur. However, our new Itanium2 server
can change which node has lower address. And panic really occurred on it.
The message was "bounce buffer is not DMA'ble" in swiothl_map_single().

To avoid this panic, following patch confirm allocated area, and retry
if it is not in DMA.
I tested this patch on my Tiger 4 and our new server.


Signed-off by Yasunori Goto <y-goto@jp.fujitsu.com>

-------------------------------------------------------------------
Index: bootmem/mm/bootmem.c
===================================================================
--- bootmem.orig/mm/bootmem.c	2005-08-10 14:34:45.580239280 +0900
+++ bootmem/mm/bootmem.c	2005-08-10 14:34:49.021645488 +0900
@@ -374,10 +374,25 @@ void * __init __alloc_bootmem (unsigned 
 	pg_data_t *pgdat = pgdat_list;
 	void *ptr;
 
-	for_each_pgdat(pgdat)
-		if ((ptr = __alloc_bootmem_core(pgdat->bdata, size,
-						align, goal)))
-			return(ptr);
+	for_each_pgdat(pgdat){
+
+		ptr = __alloc_bootmem_core(pgdat->bdata, size,
+					   align, goal);
+
+		if (!ptr)
+			continue;
+
+		if (goal < max_dma_physaddr() &&
+		    (unsigned long)ptr >= MAX_DMA_ADDRESS){
+			/* DMA area is required, but ptr is not DMA area.
+			   Trying other nodes */
+			free_bootmem_core(pgdat->bdata, virt_to_phys(ptr), size);
+			continue;
+		}
+
+		return(ptr);
+
+	}
 
 	/*
 	 * Whoops, we cannot satisfy the allocation request.
Index: bootmem/include/linux/bootmem.h
===================================================================
--- bootmem.orig/include/linux/bootmem.h	2005-08-10 14:34:45.574379905 +0900
+++ bootmem/include/linux/bootmem.h	2005-08-10 14:35:28.569496566 +0900
@@ -36,6 +36,14 @@ typedef struct bootmem_data {
 					 * up searching */
 } bootmem_data_t;
 
+static inline unsigned long max_dma_physaddr(void)
+{
+
+	if (MAX_DMA_ADDRESS == ~0UL)
+		return MAX_DMA_ADDRESS;
+	return __pa(MAX_DMA_ADDRESS);
+}
+
 extern unsigned long __init bootmem_bootmap_pages (unsigned long);
 extern unsigned long __init init_bootmem (unsigned long addr, unsigned long memend);
 extern void __init free_bootmem (unsigned long addr, unsigned long size);
@@ -43,11 +51,11 @@ extern void * __init __alloc_bootmem (un
 #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
 extern void __init reserve_bootmem (unsigned long addr, unsigned long size);
 #define alloc_bootmem(x) \
-	__alloc_bootmem((x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem((x), SMP_CACHE_BYTES, max_dma_physaddr())
 #define alloc_bootmem_low(x) \
 	__alloc_bootmem((x), SMP_CACHE_BYTES, 0)
 #define alloc_bootmem_pages(x) \
-	__alloc_bootmem((x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem((x), PAGE_SIZE, max_dma_physaddr())
 #define alloc_bootmem_low_pages(x) \
 	__alloc_bootmem((x), PAGE_SIZE, 0)
 #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
@@ -60,9 +68,9 @@ extern unsigned long __init free_all_boo
 extern void * __init __alloc_bootmem_node (pg_data_t *pgdat, unsigned long size, unsigned long align, unsigned long goal);
 #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
 #define alloc_bootmem_node(pgdat, x) \
-	__alloc_bootmem_node((pgdat), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node((pgdat), (x), SMP_CACHE_BYTES, max_dma_physaddr())
 #define alloc_bootmem_pages_node(pgdat, x) \
-	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, max_dma_physaddr())
 #define alloc_bootmem_low_pages_node(pgdat, x) \
 	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, 0)
 #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */

-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
