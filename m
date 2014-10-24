Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9CC6B0072
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:18:52 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id s18so2409447lam.9
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 03:18:52 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [185.26.127.97])
        by mx.google.com with ESMTPS id ci5si6265323lad.58.2014.10.24.03.18.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 03:18:48 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Subject: [PATCH v2 4/4] mm: cma: Use %pa to print physical addresses
Date: Fri, 24 Oct 2014 13:18:42 +0300
Message-Id: <1414145922-26042-5-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
In-Reply-To: <1414145922-26042-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1414145922-26042-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Weijie Yang <weijie.yang.kh@gmail.com>

Casting physical addresses to unsigned long and using %lu truncates the
values on systems where physical addresses are larger than 32 bits. Use
%pa and get rid of the cast instead.

Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 mm/cma.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index c30a6edee65c..fde706e1284f 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -218,9 +218,8 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	phys_addr_t highmem_start = __pa(high_memory);
 	int ret = 0;
 
-	pr_debug("%s(size %lx, base %08lx, limit %08lx alignment %08lx)\n",
-		__func__, (unsigned long)size, (unsigned long)base,
-		(unsigned long)limit, (unsigned long)alignment);
+	pr_debug("%s(size %pa, base %pa, limit %pa alignment %pa)\n",
+		__func__, &size, &base, &limit, &alignment);
 
 	if (cma_area_count == ARRAY_SIZE(cma_areas)) {
 		pr_err("Not enough slots for CMA reserved regions!\n");
@@ -258,8 +257,8 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	 */
 	if (fixed && base < highmem_start && base + size > highmem_start) {
 		ret = -EINVAL;
-		pr_err("Region at %08lx defined on low/high memory boundary (%08lx)\n",
-			(unsigned long)base, (unsigned long)highmem_start);
+		pr_err("Region at %pa defined on low/high memory boundary (%pa)\n",
+			&base, &highmem_start);
 		goto err;
 	}
 
@@ -309,8 +308,8 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	if (ret)
 		goto err;
 
-	pr_info("Reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
-		(unsigned long)base);
+	pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
+		&base);
 	return 0;
 
 err:
-- 
2.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
