Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 601196B025E
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 12:10:02 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d123so65052468pfd.0
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 09:10:02 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id u88si1901346pfi.55.2017.01.26.09.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 09:10:01 -0800 (PST)
Subject: [PATCH v2 3/3] dax: Support for transparent PUD pages for device DAX
From: Dave Jiang <dave.jiang@intel.com>
Date: Thu, 26 Jan 2017 10:10:00 -0700
Message-ID: <148545060002.17912.6765687780007547551.stgit@djiang5-desk3.ch.intel.com>
In-Reply-To: <148545012634.17912.13951763606410303827.stgit@djiang5-desk3.ch.intel.com>
References: <148545012634.17912.13951763606410303827.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dave.hansen@linux.intel.com, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com

Adding transparent huge PUD pages support for device DAX by adding a
pud_fault handler.

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 drivers/dax/dax.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
index 922ec46..b90bb30 100644
--- a/drivers/dax/dax.c
+++ b/drivers/dax/dax.c
@@ -493,6 +493,51 @@ static int __dax_dev_pmd_fault(struct dax_dev *dax_dev, struct vm_fault *vmf)
 			vmf->flags & FAULT_FLAG_WRITE);
 }
 
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static int __dax_dev_pud_fault(struct dax_dev *dax_dev, struct vm_fault *vmf)
+{
+	unsigned long pud_addr = vmf->address & PUD_MASK;
+	struct device *dev = &dax_dev->dev;
+	struct dax_region *dax_region;
+	phys_addr_t phys;
+	pgoff_t pgoff;
+	pfn_t pfn;
+
+	if (check_vma(dax_dev, vmf->vma, __func__))
+		return VM_FAULT_SIGBUS;
+
+	dax_region = dax_dev->region;
+	if (dax_region->align > PUD_SIZE) {
+		dev_dbg(dev, "%s: alignment > fault size\n", __func__);
+		return VM_FAULT_SIGBUS;
+	}
+
+	/* dax pud mappings require pfn_t_devmap() */
+	if ((dax_region->pfn_flags & (PFN_DEV|PFN_MAP)) != (PFN_DEV|PFN_MAP)) {
+		dev_dbg(dev, "%s: alignment > fault size\n", __func__);
+		return VM_FAULT_SIGBUS;
+	}
+
+	pgoff = linear_page_index(vmf->vma, pud_addr);
+	phys = pgoff_to_phys(dax_dev, pgoff, PUD_SIZE);
+	if (phys == -1) {
+		dev_dbg(dev, "%s: phys_to_pgoff(%#lx) failed\n", __func__,
+				pgoff);
+		return VM_FAULT_SIGBUS;
+	}
+
+	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
+
+	return vmf_insert_pfn_pud(vmf->vma, vmf->address, vmf->pud, pfn,
+			vmf->flags & FAULT_FLAG_WRITE);
+}
+#else
+static int __dax_dev_pud_fault(struct dax_dev *dax_dev, struct vm_fault *vmf)
+{
+	return VM_FAULT_FALLBACK;
+}
+#endif /* !CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
 static int dax_dev_fault(struct vm_fault *vmf)
 {
 	int rc;
@@ -512,6 +557,9 @@ static int dax_dev_fault(struct vm_fault *vmf)
 	case FAULT_FLAG_SIZE_PMD:
 		rc = __dax_dev_pmd_fault(dax_dev, vmf);
 		break;
+	case FAULT_FLAG_SIZE_PUD:
+		rc = __dax_dev_pud_fault(dax_dev, vmf);
+		break;
 	default:
 		return VM_FAULT_FALLBACK;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
