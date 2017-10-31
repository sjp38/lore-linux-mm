Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F030A280244
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:28:29 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t10so540454pgo.20
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:28:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f1si2990823pfk.204.2017.10.31.16.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 16:28:27 -0700 (PDT)
Subject: [PATCH 05/15] dax: stop using VM_MIXEDMAP for dax
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 31 Oct 2017 16:22:02 -0700
Message-ID: <150949212239.24061.11111318131160225304.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, hch@lst.de, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, akpm@linux-foundation.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

VM_MIXEDMAP is used by dax to direct mm paths like vm_normal_page() that
the memory page it is dealing with is not typical memory from the linear
map. The get_user_pages_fast() path, since it does not resolve the vma,
is already using {pte,pmd}_devmap() as a stand-in for VM_MIXEDMAP, so we
use that as a VM_MIXEDMAP replacement in some locations. In the cases
where there is no pte to consult we fallback to using vma_is_dax() to
detect the VM_MIXEDMAP special case.

Now that we have explicit driver pfn_t-flag opt-in/opt-out for
get_user_pages() support for DAX we can stop setting VM_MIXEDMAP.  This
also means we no longer need to worry about safely manipulating vm_flags
in a future where we support dynamically changing the dax mode of a
file.

Cc: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/device.c |    2 +-
 fs/ext2/file.c       |    1 -
 fs/ext4/file.c       |    2 +-
 fs/xfs/xfs_file.c    |    2 +-
 include/linux/mm.h   |    1 +
 include/linux/vma.h  |   33 +++++++++++++++++++++++++++++++++
 mm/huge_memory.c     |    8 ++++----
 mm/ksm.c             |    3 +++
 mm/madvise.c         |    2 +-
 mm/memory.c          |    8 ++++++--
 mm/migrate.c         |    3 ++-
 mm/mlock.c           |    5 +++--
 mm/mmap.c            |    8 ++++----
 13 files changed, 60 insertions(+), 18 deletions(-)
 create mode 100644 include/linux/vma.h

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index e9f3b3e4bbf4..ed79d006026e 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -450,7 +450,7 @@ static int dax_mmap(struct file *filp, struct vm_area_struct *vma)
 		return rc;
 
 	vma->vm_ops = &dax_vm_ops;
-	vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
+	vma->vm_flags |= VM_HUGEPAGE;
 	return 0;
 }
 
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index ff3a3636a5ca..70657e8550ed 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -125,7 +125,6 @@ static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
 
 	file_accessed(file);
 	vma->vm_ops = &ext2_dax_vm_ops;
-	vma->vm_flags |= VM_MIXEDMAP;
 	return 0;
 }
 #else
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index b1da660ac3bc..0cc9d205bd96 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -352,7 +352,7 @@ static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
 	file_accessed(file);
 	if (IS_DAX(file_inode(file))) {
 		vma->vm_ops = &ext4_dax_vm_ops;
-		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
+		vma->vm_flags |= VM_HUGEPAGE;
 	} else {
 		vma->vm_ops = &ext4_file_vm_ops;
 	}
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 309e26c9dddb..c419c6fdb769 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1134,7 +1134,7 @@ xfs_file_mmap(
 	file_accessed(filp);
 	vma->vm_ops = &xfs_file_vm_ops;
 	if (IS_DAX(file_inode(filp)))
-		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
+		vma->vm_flags |= VM_HUGEPAGE;
 	return 0;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 065d99deb847..8c1e3ac77285 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2338,6 +2338,7 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn);
 int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn);
+bool vm_mixed_ok(struct vm_area_struct *vma, pfn_t pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
 
diff --git a/include/linux/vma.h b/include/linux/vma.h
new file mode 100644
index 000000000000..135ad5262cd1
--- /dev/null
+++ b/include/linux/vma.h
@@ -0,0 +1,33 @@
+/*
+ * Copyright(c) 2017 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+#ifndef __VMA_H__
+#define __VMA_H__
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/mm_types.h>
+#include <linux/hugetlb_inline.h>
+
+/*
+ * There are several vma types that have special handling in the
+ * get_user_pages() path and other core mm paths that must not assume
+ * normal pages. vma_is_special() consolidates checks for VM_SPECIAL,
+ * hugetlb and dax vmas, but note that there are 'special' vmas and
+ * special circumstances beyond these types. In other words this helper
+ * is not exhaustive.
+ */
+static inline bool vma_is_special(struct vm_area_struct *vma)
+{
+	return vma && (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)
+			|| vma_is_dax(vma));
+}
+#endif /* __VMA_H__ */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 269b5df58543..3cabd682da1c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -765,11 +765,11 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	 * but we need to be consistent with PTEs and architectures that
 	 * can't support a 'special' bit.
 	 */
-	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON(!((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))
+				|| vm_mixed_ok(vma, pfn)));
 	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
 						(VM_PFNMAP|VM_MIXEDMAP));
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
-	BUG_ON(!pfn_t_devmap(pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return VM_FAULT_SIGBUS;
@@ -824,11 +824,11 @@ int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 	 * but we need to be consistent with PTEs and architectures that
 	 * can't support a 'special' bit.
 	 */
-	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON(!((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))
+				|| vm_mixed_ok(vma, pfn)));
 	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
 						(VM_PFNMAP|VM_MIXEDMAP));
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
-	BUG_ON(!pfn_t_devmap(pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return VM_FAULT_SIGBUS;
diff --git a/mm/ksm.c b/mm/ksm.c
index 6cb60f46cce5..72f196a36503 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2361,6 +2361,9 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 				 VM_HUGETLB | VM_MIXEDMAP))
 			return 0;		/* just ignore the advice */
 
+		if (vma_is_dax(vma))
+			return 0;
+
 #ifdef VM_SAO
 		if (*vm_flags & VM_SAO)
 			return 0;
diff --git a/mm/madvise.c b/mm/madvise.c
index 25bade36e9ca..50513a7a11f6 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -95,7 +95,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 		new_flags |= VM_DONTDUMP;
 		break;
 	case MADV_DODUMP:
-		if (new_flags & VM_SPECIAL) {
+		if (vma_is_dax(vma) || (new_flags & VM_SPECIAL)) {
 			error = -EINVAL;
 			goto out;
 		}
diff --git a/mm/memory.c b/mm/memory.c
index e764dc5d8a87..150c9194db27 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -830,6 +830,8 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			return vma->vm_ops->find_special_page(vma, addr);
 		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
 			return NULL;
+		if (pte_devmap(pte))
+			return NULL;
 		if (is_zero_pfn(pfn))
 			return NULL;
 
@@ -917,6 +919,8 @@ struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
 		}
 	}
 
+	if (pmd_devmap(pmd))
+		return NULL;
 	if (is_zero_pfn(pfn))
 		return NULL;
 	if (unlikely(pfn > highest_memmap_pfn))
@@ -1227,7 +1231,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * efficient than faulting.
 	 */
 	if (!(vma->vm_flags & (VM_HUGETLB | VM_PFNMAP | VM_MIXEDMAP)) &&
-			!vma->anon_vma)
+			!vma->anon_vma && !vma_is_dax(vma))
 		return 0;
 
 	if (is_vm_hugetlb_page(vma))
@@ -1896,7 +1900,7 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_pfn_prot);
 
-static bool vm_mixed_ok(struct vm_area_struct *vma, pfn_t pfn)
+bool vm_mixed_ok(struct vm_area_struct *vma, pfn_t pfn)
 {
 	/* these checks mirror the abort conditions in vm_normal_page */
 	if (vma->vm_flags & VM_MIXEDMAP)
diff --git a/mm/migrate.c b/mm/migrate.c
index 6954c1435833..13f8748e7cba 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -45,6 +45,7 @@
 #include <linux/page_owner.h>
 #include <linux/sched/mm.h>
 #include <linux/ptrace.h>
+#include <linux/vma.h>
 
 #include <asm/tlbflush.h>
 
@@ -2927,7 +2928,7 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 	/* Sanity check the arguments */
 	start &= PAGE_MASK;
 	end &= PAGE_MASK;
-	if (!vma || is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
+	if (!vma || vma_is_special(vma))
 		return -EINVAL;
 	if (start < vma->vm_start || start >= vma->vm_end)
 		return -EINVAL;
diff --git a/mm/mlock.c b/mm/mlock.c
index dfc6f1912176..4e20915ddfef 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -22,6 +22,7 @@
 #include <linux/hugetlb.h>
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h>
+#include <linux/vma.h>
 
 #include "internal.h"
 
@@ -519,8 +520,8 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	int lock = !!(newflags & VM_LOCKED);
 	vm_flags_t old_flags = vma->vm_flags;
 
-	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
-	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
+	if (newflags == vma->vm_flags || vma_is_special(vma)
+			|| vma == get_gate_vma(current->mm))
 		/* don't set VM_LOCKED or VM_LOCKONFAULT and don't count */
 		goto out;
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 680506faceae..c28996f74320 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -45,6 +45,7 @@
 #include <linux/moduleparam.h>
 #include <linux/pkeys.h>
 #include <linux/oom.h>
+#include <linux/vma.h>
 
 #include <linux/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1722,11 +1723,10 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 
 	vm_stat_account(mm, vm_flags, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
-		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
-					vma == get_gate_vma(current->mm)))
-			mm->locked_vm += (len >> PAGE_SHIFT);
-		else
+		if (vma_is_special(vma) || vma == get_gate_vma(current->mm))
 			vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
+		else
+			mm->locked_vm += (len >> PAGE_SHIFT);
 	}
 
 	if (file)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
