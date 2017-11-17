Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 889546B0038
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 19:13:54 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y41so428645wrc.22
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 16:13:54 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i70si1815322wri.414.2017.11.16.16.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 16:13:53 -0800 (PST)
Date: Thu, 16 Nov 2017 16:13:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] dma-debug: fix incorrect pfn calculation
Message-Id: <20171116161350.3b8bd1fbcaae8e032441d3e7@linux-foundation.org>
In-Reply-To: <1510872972-23919-1-git-send-email-miles.chen@mediatek.com>
References: <1510872972-23919-1-git-send-email-miles.chen@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miles.chen@mediatek.com
Cc: Christoph Hellwig <hch@lst.de>, Robin Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, iommu@lists.linux-foundation.org, Christoph Hellwig <hch@infradead.org>

On Fri, 17 Nov 2017 06:56:12 +0800 <miles.chen@mediatek.com> wrote:

> From: Miles Chen <miles.chen@mediatek.com>
> 
> dma-debug reports the following warning:
> 
> [name:panic&]WARNING: CPU: 3 PID: 298 at kernel-4.4/lib/dma-debug.c:604
> debug _dma_assert_idle+0x1a8/0x230()
> DMA-API: cpu touching an active dma mapped cacheline [cln=0x00000882300]
> CPU: 3 PID: 298 Comm: vold Tainted: G        W  O    4.4.22+ #1
> Hardware name: MT6739 (DT)
> Call trace:
> [<ffffff800808acd0>] dump_backtrace+0x0/0x1d4
> [<ffffff800808affc>] show_stack+0x14/0x1c
> [<ffffff800838019c>] dump_stack+0xa8/0xe0
> [<ffffff80080a0594>] warn_slowpath_common+0xf4/0x11c
> [<ffffff80080a061c>] warn_slowpath_fmt+0x60/0x80
> [<ffffff80083afe24>] debug_dma_assert_idle+0x1a8/0x230
> [<ffffff80081dca9c>] wp_page_copy.isra.96+0x118/0x520
> [<ffffff80081de114>] do_wp_page+0x4fc/0x534
> [<ffffff80081e0a14>] handle_mm_fault+0xd4c/0x1310
> [<ffffff8008098798>] do_page_fault+0x1c8/0x394
> [<ffffff800808231c>] do_mem_abort+0x50/0xec
> 
> I found that debug_dma_alloc_coherent() and debug_dma_free_coherent()
> assume that dma_alloc_coherent() always returns a linear address.  However
> it's possible that dma_alloc_coherent() returns a non-linear address.  In
> this case, page_to_pfn(virt_to_page(virt)) will return an incorrect pfn.
> If the pfn is valid and mapped as a COW page, we will hit the warning when
> doing wp_page_copy().
> 
> Fix this by calculating pfn for linear and non-linear addresses.
> 

It's a shame you didn't Cc Christoph, who was the sole reviewer of the
earlier version.

And it's a shame you didn't capture the result of that review
discussion in the v3 changelog.

And it's a shame that you didn't describe how this patch differs from
earlier versions.


Oh well, here's the incremental patch:

--- a/lib/dma-debug.c~dma-debug-fix-incorrect-pfn-calculation-v4
+++ a/lib/dma-debug.c
@@ -1495,15 +1495,22 @@ void debug_dma_alloc_coherent(struct dev
 	if (!entry)
 		return;
 
+	/* handle vmalloc and linear addresses */
+	if (!is_vmalloc_addr(virt) && !virt_to_page(virt))
+		return;
+
 	entry->type      = dma_debug_coherent;
 	entry->dev       = dev;
-	entry->pfn	 = is_vmalloc_addr(virt) ? vmalloc_to_pfn(virt) :
-						page_to_pfn(virt_to_page(virt));
 	entry->offset	 = offset_in_page(virt);
 	entry->size      = size;
 	entry->dev_addr  = dma_addr;
 	entry->direction = DMA_BIDIRECTIONAL;
 
+	if (is_vmalloc_addr(virt))
+		entry->pfn = vmalloc_to_pfn(virt);
+	else
+		entry->pfn = page_to_pfn(virt_to_page(virt));
+
 	add_dma_entry(entry);
 }
 EXPORT_SYMBOL(debug_dma_alloc_coherent);
@@ -1514,14 +1521,21 @@ void debug_dma_free_coherent(struct devi
 	struct dma_debug_entry ref = {
 		.type           = dma_debug_coherent,
 		.dev            = dev,
-		.pfn		= is_vmalloc_addr(virt) ? vmalloc_to_pfn(virt) :
-						page_to_pfn(virt_to_page(virt)),
 		.offset		= offset_in_page(virt),
 		.dev_addr       = addr,
 		.size           = size,
 		.direction      = DMA_BIDIRECTIONAL,
 	};
 
+	/* handle vmalloc and linear addresses */
+	if (!is_vmalloc_addr(virt) && !virt_to_page(virt))
+		return;
+
+	if (is_vmalloc_addr(virt))
+		ref.pfn = vmalloc_to_pfn(virt);
+	else
+		ref.pfn = page_to_pfn(virt_to_page(virt));
+
 	if (unlikely(dma_debug_disabled()))
 		return;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
