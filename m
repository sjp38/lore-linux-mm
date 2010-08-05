Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B390E6B02A9
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 13:33:03 -0400 (EDT)
Date: Thu, 5 Aug 2010 12:33:22 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q3 00/23] SLUB: The Unified slab allocator (V3)
In-Reply-To: <alpine.DEB.2.00.1008050136340.30889@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008051231400.6787@router.home>
References: <20100804024514.139976032@linux.com> <alpine.DEB.2.00.1008032138160.20049@chino.kir.corp.google.com> <alpine.DEB.2.00.1008041115500.11084@router.home> <alpine.DEB.2.00.1008050136340.30889@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Aug 2010, David Rientjes wrote:

> I bisected this to patch 8 but still don't have a bootlog.  I'm assuming
> in the meantime that something is kmallocing DMA memory on this machine
> prior to kmem_cache_init_late() and get_slab() is returning a NULL
> pointer.

There is a kernel option "earlyprintk=..." that allows you to see early
boot messages.

If this indeed is a problem with the DMA caches then try the following
patch:



Subject: slub: Move dma cache initialization up

Do dma kmalloc initialization in kmem_cache_init and not in kmem_cache_init_late()

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-05 12:24:21.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-05 12:28:58.000000000 -0500
@@ -3866,13 +3866,8 @@ void __init kmem_cache_init(void)
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
 #endif
-}

-void __init kmem_cache_init_late(void)
-{
 #ifdef CONFIG_ZONE_DMA
-	int i;
-
 	/* Create the dma kmalloc array and make it operational */
 	for (i = 0; i < SLUB_PAGE_SHIFT; i++) {
 		struct kmem_cache *s = kmalloc_caches[i];
@@ -3891,6 +3886,10 @@ void __init kmem_cache_init_late(void)
 #endif
 }

+void __init kmem_cache_init_late(void)
+{
+}
+
 /*
  * Find a mergeable slab cache
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
