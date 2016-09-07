Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 52D586B0253
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 18:56:26 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hi6so63359924pac.0
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 15:56:26 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v9si29063338pab.64.2016.09.07.15.29.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 15:29:13 -0700 (PDT)
Subject: [PATCH v2 1/2] mm: fix cache mode of dax pmd mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 07 Sep 2016 15:26:14 -0700
Message-ID: <147328717393.35069.6384193370523015106.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <147328716869.35069.16311932814998156819.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147328716869.35069.16311932814998156819.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Toshi Kani <toshi.kani@hpe.com>, Matthew Wilcox <mawilcox@microsoft.com>, Nilesh Choudhury <nilesh.choudhury@oracle.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Ross Zwisler <ross.zwisler@linux.intel.com>, akpm@linux-foundation.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kai Zhang <kai.ka.zhang@oracle.com>

track_pfn_insert() in vmf_insert_pfn_pmd() is marking dax mappings as
uncacheable rendering them impractical for application usage.  DAX-pte
mappings are cached and the goal of establishing DAX-pmd mappings is to
attain more performance, not dramatically less (3 orders of magnitude).

track_pfn_insert() relies on a previous call to reserve_memtype() to
establish the expected page_cache_mode for the range.  While memremap()
arranges for reserve_memtype() to be called, devm_memremap_pages() does
not.  So, teach track_pfn_insert() and untrack_pfn() how to handle
tracking without a vma, and arrange for devm_memremap_pages() to
establish the write-back-cache reservation in the memtype tree.

Cc: <stable@vger.kernel.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Nilesh Choudhury <nilesh.choudhury@oracle.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Toshi Kani <toshi.kani@hpe.com>
Reported-by: Kai Zhang <kai.ka.zhang@oracle.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/pat.c |   17 ++++++++++-------
 kernel/memremap.c |    9 +++++++++
 2 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index ecb1b69c1651..170cc4ff057b 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -927,9 +927,10 @@ int track_pfn_copy(struct vm_area_struct *vma)
 }
 
 /*
- * prot is passed in as a parameter for the new mapping. If the vma has a
- * linear pfn mapping for the entire range reserve the entire vma range with
- * single reserve_pfn_range call.
+ * prot is passed in as a parameter for the new mapping. If the vma has
+ * a linear pfn mapping for the entire range, or no vma is provided,
+ * reserve the entire pfn + size range with single reserve_pfn_range
+ * call.
  */
 int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 		    unsigned long pfn, unsigned long addr, unsigned long size)
@@ -938,11 +939,12 @@ int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 	enum page_cache_mode pcm;
 
 	/* reserve the whole chunk starting from paddr */
-	if (addr == vma->vm_start && size == (vma->vm_end - vma->vm_start)) {
+	if (!vma || (addr == vma->vm_start
+				&& size == (vma->vm_end - vma->vm_start))) {
 		int ret;
 
 		ret = reserve_pfn_range(paddr, size, prot, 0);
-		if (!ret)
+		if (ret == 0 && vma)
 			vma->vm_flags |= VM_PAT;
 		return ret;
 	}
@@ -997,7 +999,7 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 	resource_size_t paddr;
 	unsigned long prot;
 
-	if (!(vma->vm_flags & VM_PAT))
+	if (vma && !(vma->vm_flags & VM_PAT))
 		return;
 
 	/* free the chunk starting from pfn or the whole chunk */
@@ -1011,7 +1013,8 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 		size = vma->vm_end - vma->vm_start;
 	}
 	free_pfn_range(paddr, size);
-	vma->vm_flags &= ~VM_PAT;
+	if (vma)
+		vma->vm_flags &= ~VM_PAT;
 }
 
 /*
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 251d16b4cb41..b501e390bb34 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -247,6 +247,7 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(resource_size(res), SECTION_SIZE);
 	arch_remove_memory(align_start, align_size);
+	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
 	pgmap_radix_release(res);
 	dev_WARN_ONCE(dev, pgmap->altmap && pgmap->altmap->alloc,
 			"%s: failed to free all reserved pages\n", __func__);
@@ -282,6 +283,7 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap)
 {
 	resource_size_t key, align_start, align_size, align_end;
+	pgprot_t pgprot = PAGE_KERNEL;
 	struct dev_pagemap *pgmap;
 	struct page_map *page_map;
 	int error, nid, is_ram;
@@ -351,6 +353,11 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	if (nid < 0)
 		nid = numa_mem_id();
 
+	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(align_start), 0,
+			align_size);
+	if (error)
+		goto err_pfn_remap;
+
 	error = arch_add_memory(nid, align_start, align_size, true);
 	if (error)
 		goto err_add_memory;
@@ -371,6 +378,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
 	return __va(res->start);
 
  err_add_memory:
+	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
+ err_pfn_remap:
  err_radix:
 	pgmap_radix_release(res);
 	devres_free(page_map);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
