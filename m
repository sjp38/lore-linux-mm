Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0E16B0275
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:28:11 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y5so545072pgq.15
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:28:11 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e4si2798504pgf.23.2017.10.31.16.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 16:28:10 -0700 (PDT)
Subject: [PATCH 02/15] mm, dax: introduce pfn_t_special()
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 31 Oct 2017 16:21:45 -0700
Message-ID: <150949210553.24061.5992572975056748512.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hch@lst.de

In support of removing the VM_MIXEDMAP indication from DAX VMAs,
introduce pfn_t_special() for drivers to indicate that _PAGE_SPECIAL
should be used for DAX ptes. This also helps identify drivers like
dccssblk that only want to use DAX in a read-only fashion without
get_user_pages() support.

Ideally we could delete axonram and dcssblk DAX support, but if we need
to keep it better make it explicit that axonram and dcssblk only support
a sub-set of DAX due to missing _PAGE_DEVMAP support.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/powerpc/sysdev/axonram.c |    2 +-
 drivers/s390/block/dcssblk.c  |    3 ++-
 include/linux/pfn_t.h         |   13 +++++++++++++
 mm/memory.c                   |   16 +++++++++++++++-
 4 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index c60e84e4558d..aaf540efb92c 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -151,7 +151,7 @@ __axon_ram_direct_access(struct axon_ram_bank *bank, pgoff_t pgoff, long nr_page
 	resource_size_t offset = pgoff * PAGE_SIZE;
 
 	*kaddr = (void *) bank->io_addr + offset;
-	*pfn = phys_to_pfn_t(bank->ph_addr + offset, PFN_DEV);
+	*pfn = phys_to_pfn_t(bank->ph_addr + offset, PFN_DEV|PFN_SPECIAL);
 	return (bank->size - offset) / PAGE_SIZE;
 }
 
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 7abb240847c0..87756e28c29b 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -915,7 +915,8 @@ __dcssblk_direct_access(struct dcssblk_dev_info *dev_info, pgoff_t pgoff,
 
 	dev_sz = dev_info->end - dev_info->start + 1;
 	*kaddr = (void *) dev_info->start + offset;
-	*pfn = __pfn_to_pfn_t(PFN_DOWN(dev_info->start + offset), PFN_DEV);
+	*pfn = __pfn_to_pfn_t(PFN_DOWN(dev_info->start + offset),
+			PFN_DEV|PFN_SPECIAL);
 
 	return (dev_sz - offset) / PAGE_SIZE;
 }
diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index a49b3259cad7..2a16386725b2 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -14,8 +14,10 @@
 #define PFN_SG_LAST (1ULL << (BITS_PER_LONG_LONG - 2))
 #define PFN_DEV (1ULL << (BITS_PER_LONG_LONG - 3))
 #define PFN_MAP (1ULL << (BITS_PER_LONG_LONG - 4))
+#define PFN_SPECIAL (1ULL << (BITS_PER_LONG_LONG - 5))
 
 #define PFN_FLAGS_TRACE \
+	{ PFN_SPECIAL,	"SPECIAL" }, \
 	{ PFN_SG_CHAIN,	"SG_CHAIN" }, \
 	{ PFN_SG_LAST,	"SG_LAST" }, \
 	{ PFN_DEV,	"DEV" }, \
@@ -119,4 +121,15 @@ pud_t pud_mkdevmap(pud_t pud);
 #endif
 #endif /* __HAVE_ARCH_PTE_DEVMAP */
 
+#ifdef __HAVE_ARCH_PTE_SPECIAL
+static inline bool pfn_t_special(pfn_t pfn)
+{
+	return (pfn.val & PFN_SPECIAL) == PFN_SPECIAL;
+}
+#else
+static inline bool pfn_t_special(pfn_t pfn)
+{
+	return false;
+}
+#endif /* __HAVE_ARCH_PTE_SPECIAL */
 #endif /* _LINUX_PFN_T_H_ */
diff --git a/mm/memory.c b/mm/memory.c
index a728bed16c20..e764dc5d8a87 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1896,12 +1896,26 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_pfn_prot);
 
+static bool vm_mixed_ok(struct vm_area_struct *vma, pfn_t pfn)
+{
+	/* these checks mirror the abort conditions in vm_normal_page */
+	if (vma->vm_flags & VM_MIXEDMAP)
+		return true;
+	if (pfn_t_devmap(pfn))
+		return true;
+	if (pfn_t_special(pfn))
+		return true;
+	if (is_zero_pfn(pfn_t_to_pfn(pfn)))
+		return true;
+	return false;
+}
+
 static int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn, bool mkwrite)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
 
-	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
+	BUG_ON(!vm_mixed_ok(vma, pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
