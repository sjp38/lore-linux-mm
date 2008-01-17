Message-Id: <20080117223546.592799000@sgi.com>
References: <20080117223546.419383000@sgi.com>
Date: Thu, 17 Jan 2008 14:35:47 -0800
From: travis@sgi.com
Subject: [PATCH 1/3] x86: Change size of node ids from u8 to u16 fixup
Content-Disposition: inline; filename=big_nodeids-fixup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
List-ID: <linux-mm.kvack.org>

Change the size of node ids from 8 bits to 16 bits to
accomodate more than 256 nodes.

Cc: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
Fixup:

Size of memnode.embedded_map needs to be changed to
accomodate 16-bit node ids as suggested by Eric.

V2->V3:
    - changed memnode.embedded_map from [64-16] to [64-8]
      (and size comment to 128 bytes)

V1->V2:
    - changed pxm_to_node_map to u16
    - changed memnode map entries to u16
---
 arch/x86/mm/numa_64.c       |    2 +-
 drivers/acpi/numa.c         |    2 +-
 include/asm-x86/mmzone_64.h |    6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -88,7 +88,7 @@ static int __init allocate_cachealigned_
 	unsigned long pad, pad_addr;
 
 	memnodemap = memnode.embedded_map;
-	if (memnodemapsize <= 48)
+	if (memnodemapsize <= ARRAY_SIZE(memnode.embedded_map))
 		return 0;
 
 	pad = L1_CACHE_BYTES - 1;
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -38,7 +38,7 @@ ACPI_MODULE_NAME("numa");
 static nodemask_t nodes_found_map = NODE_MASK_NONE;
 
 /* maps to convert between proximity domain and logical node ID */
-static int pxm_to_node_map[MAX_PXM_DOMAINS]
+static u16 pxm_to_node_map[MAX_PXM_DOMAINS]
 				= { [0 ... MAX_PXM_DOMAINS - 1] = NID_INVAL };
 static int node_to_pxm_map[MAX_NUMNODES]
 				= { [0 ... MAX_NUMNODES - 1] = PXM_INVAL };
--- a/include/asm-x86/mmzone_64.h
+++ b/include/asm-x86/mmzone_64.h
@@ -15,9 +15,9 @@
 struct memnode {
 	int shift;
 	unsigned int mapsize;
-	u8 *map;
-	u8 embedded_map[64-16];
-} ____cacheline_aligned; /* total size = 64 bytes */
+	u16 *map;
+	u16 embedded_map[64-8];
+} ____cacheline_aligned; /* total size = 128 bytes */
 extern struct memnode memnode;
 #define memnode_shift memnode.shift
 #define memnodemap memnode.map

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
