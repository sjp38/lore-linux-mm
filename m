Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4BF36B025E
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 18:47:38 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z67so217401286pgb.0
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:47:38 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z6si17084559pgb.66.2017.01.23.15.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 15:47:38 -0800 (PST)
Subject: [PATCH 3/3] dax: Support for transparent PUD pages for device DAX
From: Dave Jiang <dave.jiang@intel.com>
Date: Mon, 23 Jan 2017 16:47:36 -0700
Message-ID: <148521525631.31533.2193884571494676804.stgit@djiang5-desk3.ch.intel.com>
In-Reply-To: <148521477073.31533.17781371321988910714.stgit@djiang5-desk3.ch.intel.com>
References: <148521477073.31533.17781371321988910714.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dave.hansen@linux.intel.com, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, vbabka@suse.cz, jack@suse.com, dan.j.williams@intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com

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
