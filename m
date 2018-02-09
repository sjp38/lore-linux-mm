Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7006B0005
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 23:08:21 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id m10so3030938pgq.1
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 20:08:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s9si1096168pfg.70.2018.02.08.20.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Feb 2018 20:08:17 -0800 (PST)
Date: Thu, 8 Feb 2018 20:08:14 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Regression after commit 19809c2da28a ("mm, vmalloc: use
 __GFP_HIGHMEM implicitly")
Message-ID: <20180209040814.GA23828@bombadil.infradead.org>
References: <627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com>
 <20180208130649.GA15846@bombadil.infradead.org>
 <20180208232004.GA21027@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180208232004.GA21027@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kai Heng Feng <kai.heng.feng@canonical.com>
Cc: Michal Hocko <mhocko@suse.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Feb 08, 2018 at 03:20:04PM -0800, Matthew Wilcox wrote:
> So ... we could enable ZONE_DMA32 on 32-bit architectures.  I don't know
> what side-effects that might have; it's clearly only been tested on 64-bit
> architectures so far.
> 
> It might be best to just revert 19809c2da28a and the follow-on 704b862f9efd.

Alternatively, try this.  It passes in GFP_DMA32 from vmalloc_32,
regardless of whether ZONE_DMA32 exists or not.  If ZONE_DMA32 doesn't
exist, then we clear it in __vmalloc_area_node(), after using it to
determine that we shouldn't set __GFP_HIGHMEM.

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 673942094328..91e8a95123c4 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1669,10 +1669,11 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	struct page **pages;
 	unsigned int nr_pages, array_size, i;
 	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
-	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
-	const gfp_t highmem_mask = (gfp_mask & (GFP_DMA | GFP_DMA32)) ?
-					0 :
-					__GFP_HIGHMEM;
+	gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
+	if (!(alloc_mask & GFP_ZONEMASK))
+		alloc_mask |= __GFP_HIGHMEM;
+	if (!IS_ENABLED(CONFIG_ZONE_DMA32) && (alloc_mask & __GFP_DMA32))
+		alloc_mask &= ~__GFP_DMA32;
 
 	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
 	array_size = (nr_pages * sizeof(struct page *));
@@ -1680,7 +1681,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	area->nr_pages = nr_pages;
 	/* Please note that the recursion is strictly bounded. */
 	if (array_size > PAGE_SIZE) {
-		pages = __vmalloc_node(array_size, 1, nested_gfp|highmem_mask,
+		pages = __vmalloc_node(array_size, 1, nested_gfp|__GFP_HIGHMEM,
 				PAGE_KERNEL, node, area->caller);
 	} else {
 		pages = kmalloc_node(array_size, nested_gfp, node);
@@ -1696,9 +1697,9 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		struct page *page;
 
 		if (node == NUMA_NO_NODE)
-			page = alloc_page(alloc_mask|highmem_mask);
+			page = alloc_page(alloc_mask);
 		else
-			page = alloc_pages_node(node, alloc_mask|highmem_mask, 0);
+			page = alloc_pages_node(node, alloc_mask, 0);
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
@@ -1706,7 +1707,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			goto fail;
 		}
 		area->pages[i] = page;
-		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
+		if (gfpflags_allow_blocking(gfp_mask))
 			cond_resched();
 	}
 
@@ -1942,12 +1943,10 @@ void *vmalloc_exec(unsigned long size)
 			      NUMA_NO_NODE, __builtin_return_address(0));
 }
 
-#if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
-#define GFP_VMALLOC32 GFP_DMA32 | GFP_KERNEL
-#elif defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA)
+#if defined(CONFIG_64BIT) && !defined(CONFIG_ZONE_DMA32)
 #define GFP_VMALLOC32 GFP_DMA | GFP_KERNEL
 #else
-#define GFP_VMALLOC32 GFP_KERNEL
+#define GFP_VMALLOC32 GFP_DMA32 | GFP_KERNEL
 #endif
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
