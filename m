Date: Wed, 28 Sep 2005 22:50:18 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 3.
Message-Id: <20050928223609.8653.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

Hello.

I changed the patch which guarantees allocation of DMA area
at alloc_bootmem_low(). This patch is for 2.6.14-rc2.

Previous patch had a trouble on Andrew's x86_64 box[1].
Unfortunately, I've not been able to see it on my box.  

However, I guess that its cause is that something required 
big size of DMA at bootmem. Because according to his report,
CONFIG_NUMA is not set, and required size is 67Mbyte.
In addtion, x86_64's DMA size is 16Mbyte. 
Before my patch, bootmem allocater allocated normal area for 
it instead of DMA. But my patch didn't permit normal area.

So, I changed my patch to permit normal area allocation.
And if normal area must return instead of DMA, allocater show
message and stack_dump() to find what is requester.

Please apply this.

[1]http://marc.theaimsgroup.com/?l=linux-mm&m=112439496416060&w=2


Thanks.

----------------------

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

To avoid this panic, following patch confirms allocated area, and retry
if it is not in DMA.
I tested this patch on my Tiger 4 and our new server.


Signed-off-by Yasunori Goto <y-goto@jp.fujitsu.com>

Index: bootmem_new/mm/bootmem.c
===================================================================
--- bootmem_new.orig/mm/bootmem.c	2005-09-23 18:05:14.000000000 +0900
+++ bootmem_new/mm/bootmem.c	2005-09-28 14:57:34.000000000 +0900
@@ -391,19 +391,54 @@ unsigned long __init free_all_bootmem (v
 	return(free_all_bootmem_core(NODE_DATA(0)));
 }
 
+static int __init is_dma_required(unsigned long goal)
+{
+	return goal < max_dma_physaddr() ? 1 : 0;
+}
+
+static int __init unmatch_dma_required(void *ptr, unsigned long goal)
+{
+
+	if(is_dma_required(goal) && (unsigned long)ptr >= MAX_DMA_ADDRESS)
+		return 1;
+
+	return 0;
+}
+
 void * __init __alloc_bootmem (unsigned long size, unsigned long align, unsigned long goal)
 {
 	pg_data_t *pgdat = pgdat_list;
 	void *ptr;
+	int retried = 0;
 
-	for_each_pgdat(pgdat)
-		if ((ptr = __alloc_bootmem_core(pgdat->bdata, size,
-						align, goal)))
-			return(ptr);
+retry:
+	for_each_pgdat(pgdat){
+
+		ptr = __alloc_bootmem_core(pgdat->bdata, size,
+					   align, goal);
+		if (!ptr)
+			continue;
+
+		if (unmatch_dma_required(ptr, goal) && !retried){
+			/* DMA is required, but normal area is allocated.
+			   Other node might have DMA, should try it. */
+			free_bootmem_core(pgdat->bdata, virt_to_phys(ptr), size);
+			continue;
+		}
+
+		return ptr;
+	}
 
 	/*
 	 * Whoops, we cannot satisfy the allocation request.
 	 */
+	if (is_dma_required(goal) && !retried){
+		printk(KERN_WARNING "bootmem alloc DMA of %lu bytes failed, retry normal area!\n", size);
+		dump_stack();
+		retried++;
+		goto retry;
+	}
+
 	printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", size);
 	panic("Out of memory");
 	return NULL;
Index: bootmem_new/include/linux/bootmem.h
===================================================================
--- bootmem_new.orig/include/linux/bootmem.h	2005-09-23 18:05:14.000000000 +0900
+++ bootmem_new/include/linux/bootmem.h	2005-09-23 18:18:41.000000000 +0900
@@ -40,6 +40,14 @@ typedef struct bootmem_data {
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
@@ -47,11 +55,11 @@ extern void * __init __alloc_bootmem (un
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
@@ -64,9 +72,9 @@ extern unsigned long __init free_all_boo
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
