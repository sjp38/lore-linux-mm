Message-ID: <48BB5551.8000106@mxs.nes.nec.co.jp>
Date: Mon, 01 Sep 2008 11:37:05 +0900
From: "Ken'ichi Ohmichi" <oomichi@mxs.nes.nec.co.jp>
MIME-Version: 1.0
Subject: [PATCH][ia64] Fix the difference between node_mem_map and node_start_pfn
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, kexec-ml <kexec@lists.infradead.org>, Bernhard Walle <bwalle@suse.de>, Jay Lan <jlan@sgi.com>
List-ID: <linux-mm.kvack.org>

Hi,

makedumpfile[1] cannot run on ia64 discontigmem kernel, because the member
node_mem_map of struct pgdat_list has invalid value. This patch fixes it.

node_start_pfn shows the start pfn of each node, and node_mem_map should
point 'struct page' of each node's node_start_pfn.
On my machine, node0's node_start_pfn shows 0x400 and its node_mem_map points
0xa0007fffbf000000. This address is the same as vmem_map, so the node_mem_map
points 'struct page' of pfn 0, even if its node_start_pfn shows 0x400.

The cause is due to the round down of min_pfn in count_node_pages() and
node0's node_mem_map points 'struct page' of inactive pfn (0x0).
This patch fixes it.


makedumpfile[1]: dump filtering command
https://sourceforge.net/projects/makedumpfile/

Signed-off-by: Ken'ichi Ohmichi <oomichi@mxs.nes.nec.co.jp>
---
--- a/arch/ia64/mm/discontig.c	2008-08-29 23:05:52.000000000 +0900
+++ b/arch/ia64/mm/discontig.c	2008-08-29 23:06:59.000000000 +0900
@@ -631,7 +631,6 @@ static __init int count_node_pages(unsig
 			(min(end, __pa(MAX_DMA_ADDRESS)) - start) >>PAGE_SHIFT;
 #endif
 	start = GRANULEROUNDDOWN(start);
-	start = ORDERROUNDDOWN(start);
 	end = GRANULEROUNDUP(end);
 	mem_data[node].max_pfn = max(mem_data[node].max_pfn,
 				     end >> PAGE_SHIFT);
--- a/include/asm-ia64/meminit.h	2008-08-29 23:06:36.000000000 +0900
+++ b/include/asm-ia64/meminit.h	2008-08-29 23:06:48.000000000 +0900
@@ -47,7 +47,6 @@ extern int reserve_elfcorehdr(unsigned l
  */
 #define GRANULEROUNDDOWN(n)	((n) & ~(IA64_GRANULE_SIZE-1))
 #define GRANULEROUNDUP(n)	(((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
-#define ORDERROUNDDOWN(n)	((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
 
 #ifdef CONFIG_NUMA
   extern void call_pernode_memory (unsigned long start, unsigned long len, void *func);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
