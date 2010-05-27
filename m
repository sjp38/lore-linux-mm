Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EF45D600385
	for <linux-mm@kvack.org>; Thu, 27 May 2010 10:20:37 -0400 (EDT)
Date: Thu, 27 May 2010 09:17:17 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [BUG] slub crashes on dma allocations
In-Reply-To: <20100526153757.GB2232@osiris.boeblingen.de.ibm.com>
Message-ID: <alpine.DEB.2.00.1005270916220.5762@router.home>
References: <20100526153757.GB2232@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


So S390 has NUMA and the minalign is allowing very small slabs of 8/16/32 bytes?


Try this patch

From: Christoph Lameter <cl@linux-foundation.org>
Subject: SLUB: Allow full duplication of kmalloc array for 390

Seems that S390 is running out of kmalloc caches.

Increase the number of kmalloc caches to a safe size.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-05-27 09:14:16.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-05-27 09:14:26.000000000 -0500
@@ -140,7 +140,7 @@ struct kmem_cache {
 #ifdef CONFIG_ZONE_DMA
 #define SLUB_DMA __GFP_DMA
 /* Reserve extra caches for potential DMA use */
-#define KMALLOC_CACHES (2 * SLUB_PAGE_SHIFT - 6)
+#define KMALLOC_CACHES (2 * SLUB_PAGE_SHIFT)
 #else
 /* Disable DMA functionality */
 #define SLUB_DMA (__force gfp_t)0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
