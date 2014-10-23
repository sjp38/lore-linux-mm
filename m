Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id D731C6B0095
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:33:59 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id z12so950069lbi.30
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:33:59 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [2001:4b98:dc2:45:216:3eff:febb:480d])
        by mx.google.com with ESMTPS id u14si2910271laz.45.2014.10.23.07.33.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 07:33:56 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Subject: [PATCH 3/4] mm: cma: Ensure that reservations never cross the low/high mem boundary
Date: Thu, 23 Oct 2014 17:33:47 +0300
Message-Id: <1414074828-4488-4-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
In-Reply-To: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Commit 95b0e655f914 ("ARM: mm: don't limit default CMA region only to
low memory") extended CMA memory reservation to allow usage of high
memory. It relied on commit f7426b983a6a ("mm: cma: adjust address limit
to avoid hitting low/high memory boundary") to ensure that the reserved
block never crossed the low/high memory boundary. While the
implementation correctly lowered the limit, it failed to consider the
case where the base..limit range crossed the low/high memory boundary
with enough space on each side to reserve the requested size on either
low or high memory.

Rework the base and limit adjustment to fix the problem. The function
now starts by rejecting the reservation altogether for fixed
reservations that cross the boundary, then adjust the limit if
reservation from high memory is impossible, and finally first try to
reserve from high memory first and then falls back to low memory.

Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
---
 mm/cma.c | 58 ++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 44 insertions(+), 14 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 6b14346..b83597b 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -247,23 +247,38 @@ int __init cma_declare_contiguous(phys_addr_t base,
 		return -EINVAL;
 
 	/*
-	 * adjust limit to avoid crossing low/high memory boundary for
+	 * Adjust limit and base to avoid crossing low/high memory boundary for
 	 * automatically allocated regions
 	 */
-	if (((limit == 0 || limit > memblock_end) &&
-	     (memblock_end - size < highmem_start &&
-	      memblock_end > highmem_start)) ||
-	    (!fixed && limit > highmem_start && limit - size < highmem_start)) {
-		limit = highmem_start;
-	}
 
-	if (fixed && base < highmem_start && base+size > highmem_start) {
+	/*
+	 * If allocating at a fixed base the request region must not cross the
+	 * low/high memory boundary.
+	 */
+	if (fixed && base < highmem_start && base + size > highmem_start) {
 		ret = -EINVAL;
 		pr_err("Region at %08lx defined on low/high memory boundary (%08lx)\n",
 			(unsigned long)base, (unsigned long)highmem_start);
 		goto err;
 	}
 
+	/*
+	 * If the limit is unspecified or above the memblock end, its effective
+	 * value will be the memblock end. Set it explicitly to simplify further
+	 * checks.
+	 */
+	if (limit == 0 || limit > memblock_end)
+		limit = memblock_end;
+
+	/*
+	 * If the limit is above the highmem start by less than the reserved
+	 * size allocation in highmem won't be possible. Lower the limit to the
+	 * lowmem end.
+	 */
+	if (limit > highmem_start && limit - size < highmem_start)
+		limit = highmem_start;
+
+
 	/* Reserve memory */
 	if (fixed) {
 		if (memblock_is_region_reserved(base, size) ||
@@ -272,14 +287,29 @@ int __init cma_declare_contiguous(phys_addr_t base,
 			goto err;
 		}
 	} else {
-		phys_addr_t addr = memblock_alloc_range(size, alignment, base,
-							limit);
+		phys_addr_t addr = 0;
+
+		/*
+		 * If the requested region crosses the low/high memory boundary,
+		 * try allocating from high memory first and fall back to low
+		 * memory in case of failure.
+		 */
+		if (base < highmem_start && limit > highmem_start) {
+			addr = memblock_alloc_range(size, alignment,
+						    highmem_start, limit);
+			limit = highmem_start;
+		}
+
 		if (!addr) {
-			ret = -ENOMEM;
-			goto err;
-		} else {
-			base = addr;
+			addr = memblock_alloc_range(size, alignment, base,
+						    limit);
+			if (!addr) {
+				ret = -ENOMEM;
+				goto err;
+			}
 		}
+
+		base = addr;
 	}
 
 	ret = cma_init_reserved_mem(base, size, order_per_bit, res_cma);
-- 
2.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
