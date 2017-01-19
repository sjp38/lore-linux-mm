Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A42E6B02B4
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 12:08:01 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r126so424249wmr.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 09:08:01 -0800 (PST)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id i190si7205807wmd.75.2017.01.19.09.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 09:07:59 -0800 (PST)
From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH 1/3] mm: alloc_contig_range: allow to specify GFP mask
Date: Thu, 19 Jan 2017 18:07:05 +0100
Message-Id: <20170119170707.31741-1-l.stach@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Alexander Graf <agraf@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-xtensa@linux-xtensa.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

Currently alloc_contig_range assumes that the compaction should
be done with the default GFP_KERNEL flags. This is probably
right for all current uses of this interface, but may change as
CMA is used in more use-cases (including being the default DMA
memory allocator on some platforms).

Change the function prototype, to allow for passing through the
GFP mask set by upper layers. No functional change in this patch,
just making the assumptions a bit more obvious.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 include/linux/gfp.h | 2 +-
 mm/cma.c            | 3 ++-
 mm/hugetlb.c        | 3 ++-
 mm/page_alloc.c     | 5 +++--
 4 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4175dca4ac39..1efa221e0e1d 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -549,7 +549,7 @@ static inline bool pm_suspended_storage(void)
 #if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
-			      unsigned migratetype);
+			      unsigned migratetype, gfp_t gfp_mask);
 extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
 #endif
 
diff --git a/mm/cma.c b/mm/cma.c
index c960459eda7e..fbd67d866f67 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -407,7 +407,8 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
 
 		pfn = cma->base_pfn + (bitmap_no << cma->order_per_bit);
 		mutex_lock(&cma_mutex);
-		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
+		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA,
+					 GFP_KERNEL);
 		mutex_unlock(&cma_mutex);
 		if (ret == 0) {
 			page = pfn_to_page(pfn);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3edb759c5c7d..6ed8b160fc0d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1051,7 +1051,8 @@ static int __alloc_gigantic_page(unsigned long start_pfn,
 				unsigned long nr_pages)
 {
 	unsigned long end_pfn = start_pfn + nr_pages;
-	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE,
+				  GFP_KERNEL);
 }
 
 static bool pfn_range_valid_gigantic(struct zone *z,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eced9fee582b..6d392d8dee36 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7230,6 +7230,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
  *			#MIGRATE_MOVABLE or #MIGRATE_CMA).  All pageblocks
  *			in range must have the same migratetype and it must
  *			be either of the two.
+ * @gfp_mask:	GFP mask to use during compaction
  *
  * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
  * aligned, however it's the caller's responsibility to guarantee that
@@ -7243,7 +7244,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
  * need to be freed with free_contig_range().
  */
 int alloc_contig_range(unsigned long start, unsigned long end,
-		       unsigned migratetype)
+		       unsigned migratetype, gfp_t gfp_mask)
 {
 	unsigned long outer_start, outer_end;
 	unsigned int order;
@@ -7255,7 +7256,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 		.zone = page_zone(pfn_to_page(start)),
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
-		.gfp_mask = GFP_KERNEL,
+		.gfp_mask = gfp_mask,
 	};
 	INIT_LIST_HEAD(&cc.migratepages);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
