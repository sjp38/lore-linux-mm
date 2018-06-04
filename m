Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07C4B6B000A
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 19:21:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x23-v6so210369pfm.7
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 16:21:48 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g7-v6si45854736plt.149.2018.06.04.16.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 16:21:47 -0700 (PDT)
Subject: [PATCH v3 02/12] device-dax: Cleanup vm_fault de-reference chains
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 04 Jun 2018 16:11:50 -0700
Message-ID: <152815391047.39010.14943806463373398992.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jack@suse.cz

Define a local 'vma' variable rather than repetitively de-referencing
the passed in 'struct vm_fault *' instance.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/device.c |   30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index d44d98c54d0f..686de08e120b 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -247,13 +247,14 @@ __weak phys_addr_t dax_pgoff_to_phys(struct dev_dax *dev_dax, pgoff_t pgoff,
 static vm_fault_t __dev_dax_pte_fault(struct dev_dax *dev_dax,
 				struct vm_fault *vmf)
 {
+	struct vm_area_struct *vma = vmf->vma;
 	struct device *dev = &dev_dax->dev;
 	struct dax_region *dax_region;
 	phys_addr_t phys;
 	pfn_t pfn;
 	unsigned int fault_size = PAGE_SIZE;
 
-	if (check_vma(dev_dax, vmf->vma, __func__))
+	if (check_vma(dev_dax, vma, __func__))
 		return VM_FAULT_SIGBUS;
 
 	dax_region = dev_dax->region;
@@ -274,13 +275,14 @@ static vm_fault_t __dev_dax_pte_fault(struct dev_dax *dev_dax,
 
 	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
 
-	return vmf_insert_mixed(vmf->vma, vmf->address, pfn);
+	return vmf_insert_mixed(vma, vmf->address, pfn);
 }
 
 static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
 				struct vm_fault *vmf)
 {
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
+	struct vm_area_struct *vma = vmf->vma;
 	struct device *dev = &dev_dax->dev;
 	struct dax_region *dax_region;
 	phys_addr_t phys;
@@ -288,7 +290,7 @@ static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
 	pfn_t pfn;
 	unsigned int fault_size = PMD_SIZE;
 
-	if (check_vma(dev_dax, vmf->vma, __func__))
+	if (check_vma(dev_dax, vma, __func__))
 		return VM_FAULT_SIGBUS;
 
 	dax_region = dev_dax->region;
@@ -310,11 +312,10 @@ static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
 		return VM_FAULT_FALLBACK;
 
 	/* if we are outside of the VMA */
-	if (pmd_addr < vmf->vma->vm_start ||
-			(pmd_addr + PMD_SIZE) > vmf->vma->vm_end)
+	if (pmd_addr < vma->vm_start || (pmd_addr + PMD_SIZE) > vma->vm_end)
 		return VM_FAULT_SIGBUS;
 
-	pgoff = linear_page_index(vmf->vma, pmd_addr);
+	pgoff = linear_page_index(vma, pmd_addr);
 	phys = dax_pgoff_to_phys(dev_dax, pgoff, PMD_SIZE);
 	if (phys == -1) {
 		dev_dbg(dev, "pgoff_to_phys(%#lx) failed\n", pgoff);
@@ -323,7 +324,7 @@ static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
 
 	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
 
-	return vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd, pfn,
+	return vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
 			vmf->flags & FAULT_FLAG_WRITE);
 }
 
@@ -332,6 +333,7 @@ static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
 				struct vm_fault *vmf)
 {
 	unsigned long pud_addr = vmf->address & PUD_MASK;
+	struct vm_area_struct *vma = vmf->vma;
 	struct device *dev = &dev_dax->dev;
 	struct dax_region *dax_region;
 	phys_addr_t phys;
@@ -340,7 +342,7 @@ static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
 	unsigned int fault_size = PUD_SIZE;
 
 
-	if (check_vma(dev_dax, vmf->vma, __func__))
+	if (check_vma(dev_dax, vma, __func__))
 		return VM_FAULT_SIGBUS;
 
 	dax_region = dev_dax->region;
@@ -362,11 +364,10 @@ static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
 		return VM_FAULT_FALLBACK;
 
 	/* if we are outside of the VMA */
-	if (pud_addr < vmf->vma->vm_start ||
-			(pud_addr + PUD_SIZE) > vmf->vma->vm_end)
+	if (pud_addr < vma->vm_start || (pud_addr + PUD_SIZE) > vma->vm_end)
 		return VM_FAULT_SIGBUS;
 
-	pgoff = linear_page_index(vmf->vma, pud_addr);
+	pgoff = linear_page_index(vma, pud_addr);
 	phys = dax_pgoff_to_phys(dev_dax, pgoff, PUD_SIZE);
 	if (phys == -1) {
 		dev_dbg(dev, "pgoff_to_phys(%#lx) failed\n", pgoff);
@@ -375,7 +376,7 @@ static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
 
 	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
 
-	return vmf_insert_pfn_pud(vmf->vma, vmf->address, vmf->pud, pfn,
+	return vmf_insert_pfn_pud(vma, vmf->address, vmf->pud, pfn,
 			vmf->flags & FAULT_FLAG_WRITE);
 }
 #else
@@ -390,12 +391,13 @@ static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
 		enum page_entry_size pe_size)
 {
 	int rc, id;
-	struct file *filp = vmf->vma->vm_file;
+	struct vm_area_struct *vma = vmf->vma;
+	struct file *filp = vma->vm_file;
 	struct dev_dax *dev_dax = filp->private_data;
 
 	dev_dbg(&dev_dax->dev, "%s: %s (%#lx - %#lx) size = %d\n", current->comm,
 			(vmf->flags & FAULT_FLAG_WRITE) ? "write" : "read",
-			vmf->vma->vm_start, vmf->vma->vm_end, pe_size);
+			vma->vm_start, vma->vm_end, pe_size);
 
 	id = dax_read_lock();
 	switch (pe_size) {
