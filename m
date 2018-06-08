Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71A746B000D
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 20:00:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j14-v6so6940838pfn.11
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 17:00:37 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id h21-v6si25884859pgn.279.2018.06.08.17.00.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 17:00:36 -0700 (PDT)
Subject: [PATCH v4 03/12] device-dax: Enable page_mapping()
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 08 Jun 2018 16:50:37 -0700
Message-ID: <152850183732.38390.13744173577899382680.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.orgjack@suse.cz

In support of enabling memory_failure() handling for device-dax
mappings, set the ->mapping association of pages backing device-dax
mappings. The rmap implementation requires page_mapping() to return the
address_space hosting the vmas that map the page.

The ->mapping pointer is never cleared. There is no possibility for the
page to become associated with another address_space while the device is
enabled. When the device is disabled the 'struct page' array for the
device is destroyed / later reinitialized to zero.

Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/device.c |   55 +++++++++++++++++++++++++++++++++++---------------
 1 file changed, 38 insertions(+), 17 deletions(-)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 686de08e120b..7ec246549721 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -245,13 +245,12 @@ __weak phys_addr_t dax_pgoff_to_phys(struct dev_dax *dev_dax, pgoff_t pgoff,
 }
 
 static vm_fault_t __dev_dax_pte_fault(struct dev_dax *dev_dax,
-				struct vm_fault *vmf)
+				struct vm_fault *vmf, pfn_t *pfn)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct device *dev = &dev_dax->dev;
 	struct dax_region *dax_region;
 	phys_addr_t phys;
-	pfn_t pfn;
 	unsigned int fault_size = PAGE_SIZE;
 
 	if (check_vma(dev_dax, vma, __func__))
@@ -273,13 +272,13 @@ static vm_fault_t __dev_dax_pte_fault(struct dev_dax *dev_dax,
 		return VM_FAULT_SIGBUS;
 	}
 
-	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
+	*pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
 
-	return vmf_insert_mixed(vma, vmf->address, pfn);
+	return vmf_insert_mixed(vma, vmf->address, *pfn);
 }
 
 static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
-				struct vm_fault *vmf)
+				struct vm_fault *vmf, pfn_t *pfn)
 {
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
 	struct vm_area_struct *vma = vmf->vma;
@@ -287,7 +286,6 @@ static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
 	struct dax_region *dax_region;
 	phys_addr_t phys;
 	pgoff_t pgoff;
-	pfn_t pfn;
 	unsigned int fault_size = PMD_SIZE;
 
 	if (check_vma(dev_dax, vma, __func__))
@@ -322,15 +320,15 @@ static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
 		return VM_FAULT_SIGBUS;
 	}
 
-	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
+	*pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
 
-	return vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
+	return vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, *pfn,
 			vmf->flags & FAULT_FLAG_WRITE);
 }
 
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
 static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
-				struct vm_fault *vmf)
+				struct vm_fault *vmf, pfn_t *pfn)
 {
 	unsigned long pud_addr = vmf->address & PUD_MASK;
 	struct vm_area_struct *vma = vmf->vma;
@@ -338,7 +336,6 @@ static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
 	struct dax_region *dax_region;
 	phys_addr_t phys;
 	pgoff_t pgoff;
-	pfn_t pfn;
 	unsigned int fault_size = PUD_SIZE;
 
 
@@ -374,14 +371,14 @@ static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
 		return VM_FAULT_SIGBUS;
 	}
 
-	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
+	*pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
 
-	return vmf_insert_pfn_pud(vma, vmf->address, vmf->pud, pfn,
+	return vmf_insert_pfn_pud(vma, vmf->address, vmf->pud, *pfn,
 			vmf->flags & FAULT_FLAG_WRITE);
 }
 #else
 static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
-				struct vm_fault *vmf)
+				struct vm_fault *vmf, pfn_t *pfn)
 {
 	return VM_FAULT_FALLBACK;
 }
@@ -390,9 +387,11 @@ static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
 static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
 		enum page_entry_size pe_size)
 {
-	int rc, id;
 	struct vm_area_struct *vma = vmf->vma;
 	struct file *filp = vma->vm_file;
+	unsigned long fault_size;
+	int rc, id;
+	pfn_t pfn;
 	struct dev_dax *dev_dax = filp->private_data;
 
 	dev_dbg(&dev_dax->dev, "%s: %s (%#lx - %#lx) size = %d\n", current->comm,
@@ -402,17 +401,39 @@ static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
 	id = dax_read_lock();
 	switch (pe_size) {
 	case PE_SIZE_PTE:
-		rc = __dev_dax_pte_fault(dev_dax, vmf);
+		fault_size = PAGE_SIZE;
+		rc = __dev_dax_pte_fault(dev_dax, vmf, &pfn);
 		break;
 	case PE_SIZE_PMD:
-		rc = __dev_dax_pmd_fault(dev_dax, vmf);
+		fault_size = PMD_SIZE;
+		rc = __dev_dax_pmd_fault(dev_dax, vmf, &pfn);
 		break;
 	case PE_SIZE_PUD:
-		rc = __dev_dax_pud_fault(dev_dax, vmf);
+		fault_size = PUD_SIZE;
+		rc = __dev_dax_pud_fault(dev_dax, vmf, &pfn);
 		break;
 	default:
 		rc = VM_FAULT_SIGBUS;
 	}
+
+	if (rc == VM_FAULT_NOPAGE) {
+		unsigned long i;
+
+		/*
+		 * In the device-dax case the only possibility for a
+		 * VM_FAULT_NOPAGE result is when device-dax capacity is
+		 * mapped. No need to consider the zero page, or racing
+		 * conflicting mappings.
+		 */
+		for (i = 0; i < fault_size / PAGE_SIZE; i++) {
+			struct page *page;
+
+			page = pfn_to_page(pfn_t_to_pfn(pfn) + i);
+			if (page->mapping)
+				continue;
+			page->mapping = filp->f_mapping;
+		}
+	}
 	dax_read_unlock(id);
 
 	return rc;
