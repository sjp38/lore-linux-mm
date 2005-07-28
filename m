Date: Wed, 27 Jul 2005 17:42:41 -0700
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: [patch] mm: Ensure proper alignment for node_remap_start_pfn
Message-ID: <20050728004241.GA16073@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

While reserving KVA for lmem_maps of node, we have to make sure that
node_remap_start_pfn[] is aligned to a proper pmd boundary.
(node_remap_start_pfn[] gets its value from node_end_pfn[])

Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
Signed-off-by: Shai Fultheim <shai@scalex86.org>

Index: linux-2.6.13-rc3/arch/i386/mm/discontig.c
===================================================================
--- linux-2.6.13-rc3.orig/arch/i386/mm/discontig.c	2005-07-26 15:10:25.000000000 -0700
+++ linux-2.6.13-rc3/arch/i386/mm/discontig.c	2005-07-26 16:27:43.000000000 -0700
@@ -243,6 +243,14 @@
 		/* now the roundup is correct, convert to PAGE_SIZE pages */
 		size = size * PTRS_PER_PTE;
 
+		if (node_end_pfn[nid] & (PTRS_PER_PTE-1)) {
+			/* 
+			 * Adjust size if node_end_pfn is not on a proper 
+			 * pmd boundary. remap_numa_kva will barf otherwise.
+			 */
+			size +=  node_end_pfn[nid] & (PTRS_PER_PTE-1);
+		}
+
 		/*
 		 * Validate the region we are allocating only contains valid
 		 * pages.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
