Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id EE7F06B0038
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 01:36:42 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so4075342pac.25
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:36:42 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id pt4si9688953pbc.159.2014.06.15.22.36.41
        for <linux-mm@kvack.org>;
        Sun, 15 Jun 2014 22:36:42 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 -next 1/9] DMA, CMA: fix possible memory leak
Date: Mon, 16 Jun 2014 14:40:43 +0900
Message-Id: <1402897251-23639-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We should free memory for bitmap when we find zone mis-match,
otherwise this memory will leak.

Additionally, I copy code comment from PPC KVM's CMA code to inform
why we need to check zone mis-match.

* Note
Minchan suggested to add a tag for the stable, but, I don't do it,
because I found this possibility during code-review and, IMO,
this patch isn't suitable for stable tree.

Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Reviewed-by: Michal Nazarewicz <mina86@mina86.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 83969f8..6467c91 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -176,14 +176,24 @@ static int __init cma_activate_area(struct cma *cma)
 		base_pfn = pfn;
 		for (j = pageblock_nr_pages; j; --j, pfn++) {
 			WARN_ON_ONCE(!pfn_valid(pfn));
+			/*
+			 * alloc_contig_range requires the pfn range
+			 * specified to be in the same zone. Make this
+			 * simple by forcing the entire CMA resv range
+			 * to be in the same zone.
+			 */
 			if (page_zone(pfn_to_page(pfn)) != zone)
-				return -EINVAL;
+				goto err;
 		}
 		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
 	} while (--i);
 
 	mutex_init(&cma->lock);
 	return 0;
+
+err:
+	kfree(cma->bitmap);
+	return -EINVAL;
 }
 
 static struct cma cma_areas[MAX_CMA_AREAS];
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
