Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k7A2Finx020475
	for <linux-mm@kvack.org>; Wed, 9 Aug 2006 21:15:44 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k7A2LgDu45425455
	for <linux-mm@kvack.org>; Wed, 9 Aug 2006 19:21:42 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k7A2FinB50868892
	for <linux-mm@kvack.org>; Wed, 9 Aug 2006 19:15:44 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1GB05I-0001QO-00
	for <linux-mm@kvack.org>; Wed, 09 Aug 2006 19:15:44 -0700
Date: Wed, 9 Aug 2006 19:14:40 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Define easier to handle GFP_THISNODE
Message-ID: <Pine.LNX.4.64.0608091858300.5361@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0608091915370.5464@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In many places we will need to use the same combination of flags.
Specify a single GFP_THISNODE definition for ease of use in gfp.h.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc3-mm2/include/linux/gfp.h
===================================================================
--- linux-2.6.18-rc3-mm2.orig/include/linux/gfp.h	2006-08-08 09:20:41.727897528 -0700
+++ linux-2.6.18-rc3-mm2/include/linux/gfp.h	2006-08-09 18:40:35.417771186 -0700
@@ -67,6 +67,8 @@ struct vm_area_struct;
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
 			 __GFP_HIGHMEM)
 
+#define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
+
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */
 
Index: linux-2.6.18-rc3-mm2/mm/migrate.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/mm/migrate.c	2006-08-08 09:25:41.388119893 -0700
+++ linux-2.6.18-rc3-mm2/mm/migrate.c	2006-08-09 18:40:35.418747688 -0700
@@ -745,9 +745,7 @@ static struct page *new_page_node(struct
 
 	*result = &pm->status;
 
-	return alloc_pages_node(pm->node,
-		GFP_HIGHUSER | __GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY,
-		0);
+	return alloc_pages_node(pm->node, GFP_HIGHUSER | GFP_THISNODE, 0);
 }
 
 /*
Index: linux-2.6.18-rc3-mm2/arch/ia64/kernel/uncached.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/arch/ia64/kernel/uncached.c	2006-08-09 18:40:32.653293682 -0700
+++ linux-2.6.18-rc3-mm2/arch/ia64/kernel/uncached.c	2006-08-09 18:41:04.237278284 -0700
@@ -98,8 +98,7 @@ static int uncached_add_chunk(struct unc
 
 	/* attempt to allocate a granule's worth of cached memory pages */
 
-	page = alloc_pages_node(nid, GFP_KERNEL | __GFP_ZERO |
-				 __GFP_THISNODE | __GFP_NORETRY | __GFP_NOWARN,
+	page = alloc_pages_node(nid, GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
 				IA64_GRANULE_SHIFT-PAGE_SHIFT);
 	if (!page) {
 		mutex_unlock(&uc_pool->add_chunk_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
