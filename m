Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31C6D6B026D
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:10:48 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id q12-v6so3824165pgp.6
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:10:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u19-v6si31410049pgk.100.2018.07.16.10.10.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 10:10:47 -0700 (PDT)
Subject: [PATCH v2 05/14] mm, memremap: Up-level foreach_order_pgoff()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Jul 2018 10:00:48 -0700
Message-ID: <153176044796.12695.10692625606054072713.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, Matthew Wilcox <willy@infradead.org>, vishal.l.verma@intel.com, hch@lst.de, linux-mm@kvack.org, jack@suse.cz, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

The foreach_order_pgoff() helper takes advantage of the ability to
insert multi-order entries into a radix. It is currently used by
devm_memremap_pages() to minimize the number of entries in the pgmap
radix. Instead of dividing a range by a constant power-of-2 sized unit
and inserting an entry for each unit, it determines the maximum
power-of-2 sized entry (subject to alignment offset) that can be
inserted at each iteration.

Up-level this helper so it can be used for populating other radix
instances. For example asynchronous-memmap-initialization-thread lookups
arriving in a follow on change.

Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/memremap.h |   25 +++++++++++++++++++++++++
 kernel/memremap.c        |   25 -------------------------
 2 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index bfdc7363b13b..bff314de3f55 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -126,6 +126,31 @@ struct dev_pagemap {
 	enum memory_type type;
 };
 
+static inline unsigned long order_at(struct resource *res, unsigned long pgoff)
+{
+	unsigned long phys_pgoff = PHYS_PFN(res->start) + pgoff;
+	unsigned long nr_pages, mask;
+
+	nr_pages = PHYS_PFN(resource_size(res));
+	if (nr_pages == pgoff)
+		return ULONG_MAX;
+
+	/*
+	 * What is the largest aligned power-of-2 range available from
+	 * this resource pgoff to the end of the resource range,
+	 * considering the alignment of the current pgoff?
+	 */
+	mask = phys_pgoff | rounddown_pow_of_two(nr_pages - pgoff);
+	if (!mask)
+		return ULONG_MAX;
+
+	return find_first_bit(&mask, BITS_PER_LONG);
+}
+
+#define foreach_order_pgoff(res, order, pgoff) \
+	for (pgoff = 0, order = order_at((res), pgoff); order < ULONG_MAX; \
+			pgoff += 1UL << order, order = order_at((res), pgoff))
+
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap,
 		void (*kill)(struct percpu_ref *));
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 85e4a7c576b2..fc2f28033460 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -16,31 +16,6 @@ static RADIX_TREE(pgmap_radix, GFP_KERNEL);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
-static unsigned long order_at(struct resource *res, unsigned long pgoff)
-{
-	unsigned long phys_pgoff = PHYS_PFN(res->start) + pgoff;
-	unsigned long nr_pages, mask;
-
-	nr_pages = PHYS_PFN(resource_size(res));
-	if (nr_pages == pgoff)
-		return ULONG_MAX;
-
-	/*
-	 * What is the largest aligned power-of-2 range available from
-	 * this resource pgoff to the end of the resource range,
-	 * considering the alignment of the current pgoff?
-	 */
-	mask = phys_pgoff | rounddown_pow_of_two(nr_pages - pgoff);
-	if (!mask)
-		return ULONG_MAX;
-
-	return find_first_bit(&mask, BITS_PER_LONG);
-}
-
-#define foreach_order_pgoff(res, order, pgoff) \
-	for (pgoff = 0, order = order_at((res), pgoff); order < ULONG_MAX; \
-			pgoff += 1UL << order, order = order_at((res), pgoff))
-
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
 int device_private_entry_fault(struct vm_area_struct *vma,
 		       unsigned long addr,
