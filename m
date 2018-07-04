Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 868F26B0007
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 17:50:28 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id j22-v6so455328pll.7
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 14:50:28 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id t4-v6si4137094pgc.572.2018.07.04.14.50.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 14:50:27 -0700 (PDT)
Subject: [PATCH v5 01/11] device-dax: Convert to vmf_insert_mixed and
 vm_fault_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jul 2018 14:40:29 -0700
Message-ID: <153074042893.27838.11180008652608787099.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.dehch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jack@suse.czross.zwisler@linux.intel.com

Use new return type vm_fault_t for fault and huge_fault handler. For
now, this is just documenting that the function returns a VM_FAULT value
rather than an errno.  Once all instances are converted, vm_fault_t will
become a distinct type.

Commit 1c8f422059ae ("mm: change return type to vm_fault_t")

Previously vm_insert_mixed() returned an error code which driver mapped into
VM_FAULT_* type. The new function vmf_insert_mixed() will replace this
inefficiency by returning VM_FAULT_* type.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/device.c    |   26 +++++++++++---------------
 include/linux/huge_mm.h |    5 +++--
 mm/huge_memory.c        |    4 ++--
 3 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index de2f8297a210..ad5e7b4a15dc 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -244,11 +244,11 @@ __weak phys_addr_t dax_pgoff_to_phys(struct dev_dax *dev_dax, pgoff_t pgoff,
 	return -1;
 }
 
-static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
+static vm_fault_t __dev_dax_pte_fault(struct dev_dax *dev_dax,
+				struct vm_fault *vmf)
 {
 	struct device *dev = &dev_dax->dev;
 	struct dax_region *dax_region;
-	int rc = VM_FAULT_SIGBUS;
 	phys_addr_t phys;
 	pfn_t pfn;
 	unsigned int fault_size = PAGE_SIZE;
@@ -274,17 +274,11 @@ static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
 
 	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
 
-	rc = vm_insert_mixed(vmf->vma, vmf->address, pfn);
-
-	if (rc == -ENOMEM)
-		return VM_FAULT_OOM;
-	if (rc < 0 && rc != -EBUSY)
-		return VM_FAULT_SIGBUS;
-
-	return VM_FAULT_NOPAGE;
+	return vmf_insert_mixed(vmf->vma, vmf->address, pfn);
 }
 
-static int __dev_dax_pmd_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
+static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
+				struct vm_fault *vmf)
 {
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
 	struct device *dev = &dev_dax->dev;
@@ -334,7 +328,8 @@ static int __dev_dax_pmd_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
 }
 
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
-static int __dev_dax_pud_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
+static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
+				struct vm_fault *vmf)
 {
 	unsigned long pud_addr = vmf->address & PUD_MASK;
 	struct device *dev = &dev_dax->dev;
@@ -384,13 +379,14 @@ static int __dev_dax_pud_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
 			vmf->flags & FAULT_FLAG_WRITE);
 }
 #else
-static int __dev_dax_pud_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
+static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
+				struct vm_fault *vmf)
 {
 	return VM_FAULT_FALLBACK;
 }
 #endif /* !CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
 
-static int dev_dax_huge_fault(struct vm_fault *vmf,
+static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
 		enum page_entry_size pe_size)
 {
 	int rc, id;
@@ -420,7 +416,7 @@ static int dev_dax_huge_fault(struct vm_fault *vmf,
 	return rc;
 }
 
-static int dev_dax_fault(struct vm_fault *vmf)
+static vm_fault_t dev_dax_fault(struct vm_fault *vmf)
 {
 	return dev_dax_huge_fault(vmf, PE_SIZE_PTE);
 }
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a8a126259bc4..d3bbf6bea9e9 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -3,6 +3,7 @@
 #define _LINUX_HUGE_MM_H
 
 #include <linux/sched/coredump.h>
+#include <linux/mm_types.h>
 
 #include <linux/fs.h> /* only for vma_is_dax() */
 
@@ -46,9 +47,9 @@ extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
-int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, pfn_t pfn, bool write);
-int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 			pud_t *pud, pfn_t pfn, bool write);
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1cd7c1a57a14..feba371169ca 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -752,7 +752,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	spin_unlock(ptl);
 }
 
-int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
@@ -812,7 +812,7 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 	spin_unlock(ptl);
 }
 
-int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 			pud_t *pud, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
