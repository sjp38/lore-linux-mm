Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j2ELFS5j031442
	for <linux-mm@kvack.org>; Mon, 14 Mar 2005 16:15:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2ELFQSe081292
	for <linux-mm@kvack.org>; Mon, 14 Mar 2005 14:15:26 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j2ELFPsl008190
	for <linux-mm@kvack.org>; Mon, 14 Mar 2005 14:15:25 -0700
Subject: [PATCH 1/4] sparsemem base: teach discontig about sparse ranges
From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 14 Mar 2005 13:15:20 -0800
Message-Id: <E1DAwuK-0007Eg-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

discontig.c has some assumptions that mem_map[]s inside of a node are
contiguous.  Teach it to make sure that each region that it's brining
online is actually made up of valid ranges of ram.

Written-by: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/i386/mm/discontig.c |   14 ++++++++++++++
 memhotplug-dave/arch/i386/mm/init.c      |    2 +-
 memhotplug-dave/include/asm-i386/page.h  |    2 ++
 3 files changed, 17 insertions(+), 1 deletion(-)

diff -puN arch/i386/mm/discontig.c~B-sparse-075-validate-remap-pages arch/i386/mm/discontig.c
--- memhotplug/arch/i386/mm/discontig.c~B-sparse-075-validate-remap-pages	2005-03-14 10:57:45.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/discontig.c	2005-03-14 10:57:46.000000000 -0800
@@ -185,6 +185,7 @@ static unsigned long calculate_numa_rema
 {
 	int nid;
 	unsigned long size, reserve_pages = 0;
+	unsigned long pfn;
 
 	for_each_online_node(nid) {
 		if (nid == 0)
@@ -208,6 +209,19 @@ static unsigned long calculate_numa_rema
 		size = (size + LARGE_PAGE_BYTES - 1) / LARGE_PAGE_BYTES;
 		/* now the roundup is correct, convert to PAGE_SIZE pages */
 		size = size * PTRS_PER_PTE;
+
+		/*
+		 * Validate the region we are allocating only contains valid
+		 * pages.
+		 */
+		for (pfn = node_end_pfn[nid] - size;
+		     pfn < node_end_pfn[nid]; pfn++)
+			if (!page_is_ram(pfn))
+				break;
+
+		if (pfn != node_end_pfn[nid])
+			size = 0;
+
 		printk("Reserving %ld pages of KVA for lmem_map of node %d\n",
 				size, nid);
 		node_remap_size[nid] = size;
diff -puN arch/i386/mm/init.c~B-sparse-075-validate-remap-pages arch/i386/mm/init.c
--- memhotplug/arch/i386/mm/init.c~B-sparse-075-validate-remap-pages	2005-03-14 10:57:46.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/init.c	2005-03-14 10:57:46.000000000 -0800
@@ -191,7 +191,7 @@ static inline int page_kills_ppro(unsign
 
 extern int is_available_memory(efi_memory_desc_t *);
 
-static inline int page_is_ram(unsigned long pagenr)
+int page_is_ram(unsigned long pagenr)
 {
 	int i;
 	unsigned long addr, end;
diff -puN include/asm-i386/page.h~B-sparse-075-validate-remap-pages include/asm-i386/page.h
--- memhotplug/include/asm-i386/page.h~B-sparse-075-validate-remap-pages	2005-03-14 10:57:46.000000000 -0800
+++ memhotplug-dave/include/asm-i386/page.h	2005-03-14 10:57:46.000000000 -0800
@@ -119,6 +119,8 @@ static __inline__ int get_order(unsigned
 
 extern int sysctl_legacy_va_layout;
 
+extern int page_is_ram(unsigned long pagenr);
+
 #endif /* __ASSEMBLY__ */
 
 #ifdef __ASSEMBLY__
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
