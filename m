Date: Tue, 8 Aug 2006 09:37:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [3/3] Guarantee that the uncached allocator gets pages on the correct
 node.
In-Reply-To: <Pine.LNX.4.64.0608080933510.27620@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0608080934540.27620@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608080933510.27620@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, pj@sgi.com, jes@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

The uncached allocator manages per node pools. Specify __GFP_THISNODE
in order to force allocation on the indicated node or fail. The
uncached allocator has already logic to deal with failing allocations.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc3-mm2/arch/ia64/kernel/uncached.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/arch/ia64/kernel/uncached.c	2006-08-07 15:22:18.460374398 -0700
+++ linux-2.6.18-rc3-mm2/arch/ia64/kernel/uncached.c	2006-08-08 09:36:00.696583433 -0700
@@ -98,7 +98,8 @@ static int uncached_add_chunk(struct unc
 
 	/* attempt to allocate a granule's worth of cached memory pages */
 
-	page = alloc_pages_node(nid, GFP_KERNEL | __GFP_ZERO,
+	page = alloc_pages_node(nid, GFP_KERNEL | __GFP_ZERO |
+				 __GFP_THISNODE | __GFP_NORETRY | __GFP_NOWARN,
 				IA64_GRANULE_SHIFT-PAGE_SHIFT);
 	if (!page) {
 		mutex_unlock(&uc_pool->add_chunk_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
