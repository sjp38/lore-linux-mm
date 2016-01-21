Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6C66F6B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 02:01:02 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id ho8so18292356pac.2
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 23:01:02 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id bx1si2249436pab.57.2016.01.20.23.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 23:01:01 -0800 (PST)
Received: by mail-pa0-x22d.google.com with SMTP id uo6so18763051pac.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 23:01:01 -0800 (PST)
Date: Thu, 21 Jan 2016 18:00:53 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: [RFC][PATCH] KVM-PPC: Migrate Pinned Pages out of CMA
Message-ID: <20160121070053.GA4319@cotter.ozlabs.ibm.com>
Reply-To: bsingharora@gmail.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org
Cc: akpm@linux-foundation.org, aik@ozlabs.ru, paulus@samba.org

From: Balbir Singh <bsingharora@gmail.com>

When PCI/Device pass through is enabled via VFIO, KVM-PPC will
pin pages using get_user_pages_fast(). One of the downsides of
the pinning is that the page could be in CMA region. The CMA
region is used for other allocations like the hash page table.
Ideally we want the pinned pages to be from non CMA region.

This patch (currently only for KVM PPC with VFIO) forcefully
migrates the pages out (huge pages are ommitted for the moment).
There are more efficient ways of doing this, but that might
be elaborate and might impact a larger audience beyond just
the kvm ppc implementation.

The magic is in new_iommu_non_cma_page() which allocates the
new page from a non CMA region.

I've tested the patches lightly at my end, but there might be bugs
For example if after lru_add_drain(), the page is not isolated
is this a BUG?

Second question - is mm_iommu_move_page_from_cma() generic enough
to be used as helper ourside of KVM-PPC?

Previous discussion was at
http://permalink.gmane.org/gmane.linux.kernel.mm/136738

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 arch/powerpc/include/asm/mmu_context.h |  1 +
 arch/powerpc/mm/mmu_context_iommu.c    | 80 ++++++++++++++++++++++++++++++++--
 2 files changed, 77 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 878c277..2ef72aa 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -18,6 +18,7 @@ extern void destroy_context(struct mm_struct *mm);
 #ifdef CONFIG_SPAPR_TCE_IOMMU
 struct mm_iommu_table_group_mem_t;
 
+extern int isolate_lru_page(struct page *page);	/* internal.h */
 extern bool mm_iommu_preregistered(void);
 extern long mm_iommu_get(unsigned long ua, unsigned long entries,
 		struct mm_iommu_table_group_mem_t **pmem);
diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index da6a216..ad843a5 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -15,6 +15,9 @@
 #include <linux/rculist.h>
 #include <linux/vmalloc.h>
 #include <linux/mutex.h>
+#include <linux/migrate.h>
+#include <linux/hugetlb.h>
+#include <linux/swap.h>
 #include <asm/mmu_context.h>
 
 static DEFINE_MUTEX(mem_list_mutex);
@@ -72,6 +75,54 @@ bool mm_iommu_preregistered(void)
 }
 EXPORT_SYMBOL_GPL(mm_iommu_preregistered);
 
+/*
+ * Taken from alloc_migrate_target with changes to remove CMA allocations
+ */
+struct page *new_iommu_non_cma_page(struct page *page, unsigned long private,
+					int **resultp)
+{
+	gfp_t gfp_mask = GFP_USER;
+	struct page *new_page;
+
+	if (PageHuge(page) || PageTransHuge(page))
+		return NULL;
+
+	if (PageHighMem(page))
+		gfp_mask |= __GFP_HIGHMEM;
+
+	/*
+	 * We don't want the allocation to force an OOM if possibe
+	 */
+	new_page = alloc_page(gfp_mask | __GFP_NORETRY | __GFP_NOWARN);
+	return new_page;
+}
+
+static int mm_iommu_move_page_from_cma(struct page *page)
+{
+	int ret;
+	LIST_HEAD(cma_migrate_pages);
+
+	/* Ignore huge/THP pages for now */
+	if (PageHuge(page) || PageTransHuge(page))
+		return -EBUSY;
+
+	lru_add_drain();
+	ret = isolate_lru_page(page);
+	if (ret)
+		get_page(page); /* Potential BUG? */
+
+	list_add(&page->lru, &cma_migrate_pages);
+	put_page(page); /* Drop the gup reference */
+
+	ret = migrate_pages(&cma_migrate_pages, new_iommu_non_cma_page,
+				NULL, 0, MIGRATE_SYNC, MR_CMA);
+	if (ret) {
+		if (!list_empty(&cma_migrate_pages))
+			putback_movable_pages(&cma_migrate_pages);
+	}
+	return 0;
+}
+
 long mm_iommu_get(unsigned long ua, unsigned long entries,
 		struct mm_iommu_table_group_mem_t **pmem)
 {
@@ -124,15 +175,36 @@ long mm_iommu_get(unsigned long ua, unsigned long entries,
 	for (i = 0; i < entries; ++i) {
 		if (1 != get_user_pages_fast(ua + (i << PAGE_SHIFT),
 					1/* pages */, 1/* iswrite */, &page)) {
+			ret = -EFAULT;
 			for (j = 0; j < i; ++j)
-				put_page(pfn_to_page(
-						mem->hpas[j] >> PAGE_SHIFT));
+				put_page(pfn_to_page(mem->hpas[j] >>
+						PAGE_SHIFT));
 			vfree(mem->hpas);
 			kfree(mem);
-			ret = -EFAULT;
 			goto unlock_exit;
 		}
-
+		/*
+		 * If we get a page from the CMA zone, since we are going to
+		 * be pinning these entries, we might as well move them out
+		 * of the CMA zone if possible. NOTE: faulting in + migration
+		 * can be expensive. Batching can be considered later
+		 */
+		if (get_pageblock_migratetype(page) == MIGRATE_CMA) {
+			if (mm_iommu_move_page_from_cma(page))
+				goto populate;
+			if (1 != get_user_pages_fast(ua + (i << PAGE_SHIFT),
+						1/* pages */, 1/* iswrite */,
+						&page)) {
+				ret = -EFAULT;
+				for (j = 0; j < i; ++j)
+					put_page(pfn_to_page(mem->hpas[j] >>
+								PAGE_SHIFT));
+				vfree(mem->hpas);
+				kfree(mem);
+				goto unlock_exit;
+			}
+		}
+populate:
 		mem->hpas[i] = page_to_pfn(page) << PAGE_SHIFT;
 	}
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
