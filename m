Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6DM3wRu652046
	for <linux-mm@kvack.org>; Wed, 13 Jul 2005 18:03:59 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j6DM3v5b248354
	for <linux-mm@kvack.org>; Wed, 13 Jul 2005 16:03:57 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6DM3vTZ016894
	for <linux-mm@kvack.org>; Wed, 13 Jul 2005 16:03:57 -0600
Date: Wed, 13 Jul 2005 15:03:51 -0700
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low()
Message-ID: <20050713220351.GA19439@w-mikek2.ibm.com>
References: <20050712152715.44CD.Y-GOTO@jp.fujitsu.com> <20050712183021.GC3987@w-mikek2.ibm.com> <20050713152030.1B11.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050713152030.1B11.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 13, 2005 at 03:34:48PM +0900, Yasunori Goto wrote:
> If MAX_DMA_ADDRESS is like -1, then all of memory can be DMA'ble, 
> right?  How is like this? One more comparison is added.
> 
> 	if (MAX_DMA_ADDRESS != ~0UL  &&
> 		goal < __pa(MAX_DMA_ADDRESS) &&
> 		pgdat->bdata->node_boot_start >= 
> 		__pa(MAX_DMA_ADDRESS))
> 

I was thinking more about something like the following to eliminate
all the users of __pa(MAX_DMA_ADDRESS).  This patch is NOT complete
as I didn't change arch dependent code using __pa(MAX_DMA_ADDRESS).

Just curious if people think this is overkill, or is there a better
way to address this?

-- 
Mike

diff -Naupr linux-2.6.13-rc2-mm2/include/linux/bootmem.h linux-2.6.13-rc2-mm2.work/include/linux/bootmem.h
--- linux-2.6.13-rc2-mm2/include/linux/bootmem.h	2005-07-06 03:46:33.000000000 +0000
+++ linux-2.6.13-rc2-mm2.work/include/linux/bootmem.h	2005-07-13 21:14:14.000000000 +0000
@@ -40,6 +40,14 @@ typedef struct bootmem_data {
 					 * up searching */
 } bootmem_data_t;
 
+#ifndef MAX_DMA_PHYSADDR
+#if MAX_DMA_ADDRESS == ~0UL
+#define MAX_DMA_PHYSADDR MAX_DMA_ADDRESS
+#else
+#define MAX_DMA_PHYSADDR (__pa(MAX_DMA_ADDRESS))
+#endif
+#endif
+
 extern unsigned long __init bootmem_bootmap_pages (unsigned long);
 extern unsigned long __init init_bootmem (unsigned long addr, unsigned long memend);
 extern void __init free_bootmem (unsigned long addr, unsigned long size);
@@ -47,11 +55,11 @@ extern void * __init __alloc_bootmem (un
 #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
 extern void __init reserve_bootmem (unsigned long addr, unsigned long size);
 #define alloc_bootmem(x) \
-	__alloc_bootmem((x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem((x), SMP_CACHE_BYTES, MAX_DMA_PHYSADDR)
 #define alloc_bootmem_low(x) \
 	__alloc_bootmem((x), SMP_CACHE_BYTES, 0)
 #define alloc_bootmem_pages(x) \
-	__alloc_bootmem((x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem((x), PAGE_SIZE, MAX_DMA_PHYSADDR)
 #define alloc_bootmem_low_pages(x) \
 	__alloc_bootmem((x), PAGE_SIZE, 0)
 #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
@@ -64,9 +72,9 @@ extern unsigned long __init free_all_boo
 extern void * __init __alloc_bootmem_node (pg_data_t *pgdat, unsigned long size, unsigned long align, unsigned long goal);
 #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
 #define alloc_bootmem_node(pgdat, x) \
-	__alloc_bootmem_node((pgdat), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node((pgdat), (x), SMP_CACHE_BYTES, MAX_DMA_PHYSADDR)
 #define alloc_bootmem_pages_node(pgdat, x) \
-	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, MAX_DMA_PHYSADDR)
 #define alloc_bootmem_low_pages_node(pgdat, x) \
 	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, 0)
 #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
diff -Naupr linux-2.6.13-rc2-mm2/mm/bootmem.c linux-2.6.13-rc2-mm2.work/mm/bootmem.c
--- linux-2.6.13-rc2-mm2/mm/bootmem.c	2005-07-06 03:46:33.000000000 +0000
+++ linux-2.6.13-rc2-mm2.work/mm/bootmem.c	2005-07-13 21:18:40.000000000 +0000
@@ -387,10 +387,16 @@ void * __init __alloc_bootmem (unsigned 
 	pg_data_t *pgdat = pgdat_list;
 	void *ptr;
 
-	for_each_pgdat(pgdat)
+	for_each_pgdat(pgdat){
+
+		if (goal < MAX_DMA_PHYSADDR &&
+		    pgdat->bdata->node_boot_start >= MAX_DMA_PHYSADDR)
+			continue; /* Skip No DMA node */
+
 		if ((ptr = __alloc_bootmem_core(pgdat->bdata, size,
 						align, goal)))
 			return(ptr);
+	}
 
 	/*
 	 * Whoops, we cannot satisfy the allocation request.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
