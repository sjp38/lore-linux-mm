Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6EBE6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 04:59:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z11-v6so1022111pfn.1
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 01:59:00 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id k124-v6si1937769pgc.519.2018.06.13.01.58.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 01:58:59 -0700 (PDT)
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
	by mailout1.w1.samsung.com (KnoxPortal) with ESMTP id 20180613085853euoutp01abbb85cde665a487e04cb30a6f67a263~3rJA7Uz8m1185911859euoutp01D
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 08:58:53 +0000 (GMT)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] mm: cma: honor __GFP_ZERO flag in cma_alloc()
Date: Wed, 13 Jun 2018 10:58:37 +0200
Message-Id: <20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2~3rI_9nj8b0455904559eucas1p2C@eucas1p2.samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2@eucas1p2.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

cma_alloc() function has gfp mask parameter, so users expect that it
honors typical memory allocation related flags. The most imporant from
the security point of view is handling of __GFP_ZERO flag, because memory
allocated by this function usually can be directly remapped to userspace
by device drivers as a part of multimedia processing and ignoring this
flag might lead to leaking some kernel structures to userspace.
Some callers of this function (for example arm64 dma-iommu glue code)
already assumed that the allocated buffers are cleared when this flag
is set. To avoid such issues, add simple code for clearing newly
allocated buffer when __GFP_ZERO flag is set. Callers will be then
updated to skip implicit clearing or adjust passed gfp flags.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 mm/cma.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/cma.c b/mm/cma.c
index 5809bbe360d7..1106d5aef2cc 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -464,6 +464,13 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 		start = bitmap_no + mask + 1;
 	}
 
+	if (ret == 0 && gfp_mask & __GFP_ZERO) {
+		int i;
+
+		for (i = 0; i < count; i++)
+			clear_highpage(page + i);
+	}
+
 	trace_cma_alloc(pfn, page, count, align);
 
 	if (ret && !(gfp_mask & __GFP_NOWARN)) {
-- 
2.17.1
