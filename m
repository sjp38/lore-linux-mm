Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id CF10E6B0253
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 12:26:12 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ho8so83628769pac.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:26:12 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id n9si34860949pap.49.2016.01.25.09.26.11
        for <linux-mm@kvack.org>;
        Mon, 25 Jan 2016 09:26:11 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 2/3] mm: Convert vm_insert_pfn_prot to vmf_insert_pfn_prot
Date: Mon, 25 Jan 2016 12:25:16 -0500
Message-Id: <1453742717-10326-3-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Matthew Wilcox <willy@linux.intel.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

Other than the name, the vmf_ version takes a pfn_t parameter, and
returns a VM_FAULT_ code suitable for returning from a fault handler.

This patch also prevents vm_insert_pfn() from returning -EBUSY.
This is a good thing as several callers handled it incorrectly (and
none intentionally treat -EBUSY as a different case from 0).

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 arch/x86/entry/vdso/vma.c |  6 +++---
 include/linux/mm.h        |  4 ++--
 mm/memory.c               | 31 ++++++++++++++++++-------------
 3 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 7c912fe..660bb69 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -9,6 +9,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/init.h>
+#include <linux/pfn_t.h>
 #include <linux/random.h>
 #include <linux/elf.h>
 #include <linux/cpu.h>
@@ -131,10 +132,9 @@ static int vvar_fault(const struct vm_special_mapping *sm,
 	} else if (sym_offset == image->sym_hpet_page) {
 #ifdef CONFIG_HPET_TIMER
 		if (hpet_address && vclock_was_used(VCLOCK_HPET)) {
-			ret = vm_insert_pfn_prot(
-				vma,
+			return vmf_insert_pfn_prot(vma,
 				(unsigned long)vmf->virtual_address,
-				hpet_address >> PAGE_SHIFT,
+				phys_to_pfn_t(hpet_address, PFN_DEV),
 				pgprot_noncached(PAGE_READONLY));
 		}
 #endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index fa6da9a..19f8741 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2138,8 +2138,8 @@ int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
-int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn, pgprot_t pgprot);
+int vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
+			pfn_t pfn, pgprot_t pgprot);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
diff --git a/mm/memory.c b/mm/memory.c
index a2eaeef..9b57318 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1554,7 +1554,11 @@ out:
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn)
 {
-	return vm_insert_pfn_prot(vma, addr, pfn, vma->vm_page_prot);
+	int result = vmf_insert_pfn_prot(vma, addr,
+			__pfn_to_pfn_t(pfn, PFN_DEV), vma->vm_page_prot);
+	if (result & VM_FAULT_ERROR)
+		return -EFAULT;
+	return 0;
 }
 EXPORT_SYMBOL(vm_insert_pfn);
 
@@ -1570,13 +1574,13 @@ EXPORT_SYMBOL(vm_insert_pfn);
  *
  * This only makes sense for IO mappings, and it makes no sense for
  * cow mappings.  In general, using multiple vmas is preferable;
- * vm_insert_pfn_prot should only be used if using multiple VMAs is
+ * vmf_insert_pfn_prot should only be used if using multiple VMAs is
  * impractical.
  */
-int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn, pgprot_t pgprot)
+int vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
+			pfn_t pfn, pgprot_t pgprot)
 {
-	int ret;
+	int error;
 	/*
 	 * Technically, architectures with pte_special can avoid all these
 	 * restrictions (same for remap_pfn_range).  However we would like
@@ -1587,18 +1591,19 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
 						(VM_PFNMAP|VM_MIXEDMAP));
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
-	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_t_valid(pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
-		return -EFAULT;
-	if (track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV)))
-		return -EINVAL;
-
-	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot);
+		return VM_FAULT_SIGBUS;
+	if (track_pfn_insert(vma, &pgprot, pfn))
+		return VM_FAULT_SIGBUS;
 
-	return ret;
+	error = insert_pfn(vma, addr, pfn, pgprot);
+	if (error == -EBUSY || !error)
+		return VM_FAULT_NOPAGE;
+	return VM_FAULT_SIGBUS;
 }
-EXPORT_SYMBOL(vm_insert_pfn_prot);
+EXPORT_SYMBOL(vmf_insert_pfn_prot);
 
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn)
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
