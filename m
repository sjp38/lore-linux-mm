Date: Tue, 12 Jul 2005 15:50:09 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH] gurantee DMA area for alloc_bootmem_low()
Message-Id: <20050712152715.44CD.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

Hello.

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

To avoid this panic, following patch skips no DMA'ble node when 
lower address is required.
I tested this patch on my Tiger 4 and our new server.

Please apply.

Thanks.

Signed-off by Yasunori Goto <y-goto@jp.fujitsu.com>

Index: allocbootmem/mm/bootmem.c
===================================================================
--- allocbootmem.orig/mm/bootmem.c	2005-06-30 11:57:13.000000000 +0900
+++ allocbootmem/mm/bootmem.c	2005-07-08 20:46:56.209040741 +0900
@@ -387,10 +387,16 @@
 	pg_data_t *pgdat = pgdat_list;
 	void *ptr;
 
-	for_each_pgdat(pgdat)
+	for_each_pgdat(pgdat){
+
+		if (goal < __pa(MAX_DMA_ADDRESS) &&
+		    pgdat->bdata->node_boot_start >= __pa(MAX_DMA_ADDRESS))
+			continue; /* Skip No DMA node */
+
 		if ((ptr = __alloc_bootmem_core(pgdat->bdata, size,
 						align, goal)))
 			return(ptr);
+	}
 
 	/*
 	 * Whoops, we cannot satisfy the allocation request.

-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
