Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D60A76B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 15:14:11 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v126so462040pgb.21
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 12:14:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b190si463710pgc.312.2018.02.15.12.14.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Feb 2018 12:14:10 -0800 (PST)
Date: Thu, 15 Feb 2018 12:14:05 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
Message-ID: <20180215201405.GA22948@bombadil.infradead.org>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
 <20180214095911.GB28460@dhcp22.suse.cz>
 <alpine.DEB.2.10.1802140225290.261065@chino.kir.corp.google.com>
 <20180215144525.GG7275@dhcp22.suse.cz>
 <20180215151129.GB12360@bombadil.infradead.org>
 <alpine.DEB.2.20.1802150947240.1902@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1802150947240.1902@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Thu, Feb 15, 2018 at 09:49:00AM -0600, Christopher Lameter wrote:
> On Thu, 15 Feb 2018, Matthew Wilcox wrote:
> 
> > What if ... on startup, slab allocated a MAX_ORDER page for itself.
> > It would then satisfy its own page allocation requests from this giant
> > page.  If we start to run low on memory in the rest of the system, slab
> > can be induced to return some of it via its shrinker.  If slab runs low
> > on memory, it tries to allocate another MAX_ORDER page for itself.
> 
> The inducing of releasing memory back is not there but you can run SLUB
> with MAX_ORDER allocations by passing "slab_min_order=9" or so on bootup.

Maybe we should try this patch in order to automatically scale the slub
page size with the amount of memory in the machine?

diff --git a/mm/internal.h b/mm/internal.h
index e6bd35182dae..7059a8389194 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -167,6 +167,7 @@ extern void prep_compound_page(struct page *page, unsigned int order);
 extern void post_alloc_hook(struct page *page, unsigned int order,
 					gfp_t gfp_flags);
 extern int user_min_free_kbytes;
+extern unsigned long __meminitdata nr_kernel_pages;
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ef9c259db041..3c51bb22403f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -264,7 +264,7 @@ int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
 int watermark_scale_factor = 10;
 
-static unsigned long __meminitdata nr_kernel_pages;
+unsigned long __meminitdata nr_kernel_pages;
 static unsigned long __meminitdata nr_all_pages;
 static unsigned long __meminitdata dma_reserve;
 
diff --git a/mm/slub.c b/mm/slub.c
index e381728a3751..abca4a6e9b6c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4194,6 +4194,23 @@ void __init kmem_cache_init(void)
 
 	if (debug_guardpage_minorder())
 		slub_max_order = 0;
+	if (slub_min_order == 0) {
+		unsigned long numentries = nr_kernel_pages;
+
+		/*
+		 * Above 4GB, we start to care more about fragmenting large
+		 * pages than about using the minimum amount of memory.
+		 * Scale the slub page size at half the rate that we scale
+		 * the memory size; at 4GB we double the page size to 8k,
+		 * 16GB to 16k, 64GB to 32k, 256GB to 64k.
+		 */
+		while (numentries > (4UL << 30)) {
+			if (slub_min_order >= slub_max_order)
+				break;
+			slub_min_order++;
+			numentries /= 4;
+		}
+	}
 
 	kmem_cache_node = &boot_kmem_cache_node;
 	kmem_cache = &boot_kmem_cache;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
