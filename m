Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BCE066B000D
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 19:21:54 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 89-v6so226832plb.18
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 16:21:54 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id l9-v6si16734359pgr.287.2018.06.04.16.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 16:21:53 -0700 (PDT)
Subject: [PATCH v3 03/12] device-dax: Enable page_mapping()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 04 Jun 2018 16:11:55 -0700
Message-ID: <152815391576.39010.14402839848074832654.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jack@suse.cz

In support of enabling memory_failure() handling for device-dax
mappings, set the ->mapping association of pages backing device-dax
mappings. The rmap implementation requires page_mapping() to return the
address_space hosting the vmas that map the page.

The ->mapping pointer is never cleared. There is no possibility for the
page to become associated with another address_space while the device is
enabled. When the device is disabled the 'struct page' array for the
device is destroyed / later reinitialized to zero.

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
