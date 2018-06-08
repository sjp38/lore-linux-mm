Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E32056B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 13:00:06 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d10-v6so5012637pgv.8
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 10:00:06 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y19-v6si45155210pgv.66.2018.06.08.10.00.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 10:00:04 -0700 (PDT)
Subject: [PATCH] dax: remove VM_MIXEDMAP for fsdax and device dax
From: Dave Jiang <dave.jiang@intel.com>
Date: Fri, 08 Jun 2018 10:00:03 -0700
Message-ID: <152847720311.55924.16999195879201817653.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, linux-nvdimm@lists.01.org

This patch is reworked from an earlier patch that Dan has posted:
https://patchwork.kernel.org/patch/10131727/

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

DAX should also now be supported with madvise_behavior(), vma_merge(),
and copy_page_range().

This patch has been tested against ndctl unit test. It has also been
tested against xfstests commit: 625515d using fake pmem created by memmap
and no additional issues have been observed.

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 drivers/dax/device.c |    2 +-
 fs/ext2/file.c       |    1 -
 fs/ext4/file.c       |    2 +-
 fs/xfs/xfs_file.c    |    2 +-
 mm/hmm.c             |    6 ++++--
 mm/huge_memory.c     |    4 ++--
 mm/ksm.c             |    3 +++
 mm/memory.c          |    6 ++++++
 mm/migrate.c         |    3 ++-
 mm/mlock.c           |    3 ++-
 mm/mmap.c            |    9 +++++----
 11 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index b33e45ee4f70..a9486f1374e4 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -487,7 +487,7 @@ static int dax_mmap(struct file *filp, struct vm_area_struct *vma)
 		return rc;
 
 	vma->vm_ops = &dax_vm_ops;
-	vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
+	vma->vm_flags |= VM_HUGEPAGE;
 	return 0;
 }
 
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 047c327a6b23..28b2609f25c1 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -126,7 +126,6 @@ static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
 
 	file_accessed(file);
 	vma->vm_ops = &ext2_dax_vm_ops;
-	vma->vm_flags |= VM_MIXEDMAP;
 	return 0;
 }
 #else
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index fb6f023622fe..61001b8e25ec 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -373,7 +373,7 @@ static int ext4_file_mmap(struct file *file, struct vm_area_struct *vma)
 	file_accessed(file);
 	if (IS_DAX(file_inode(file))) {
 		vma->vm_ops = &ext4_dax_vm_ops;
-		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
+		vma->vm_flags |= VM_HUGEPAGE;
 	} else {
 		vma->vm_ops = &ext4_file_vm_ops;
 	}
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 19b0c3e0e232..021056ad6de0 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1170,7 +1170,7 @@ xfs_file_mmap(
 	file_accessed(filp);
 	vma->vm_ops = &xfs_file_vm_ops;
 	if (IS_DAX(file_inode(filp)))
-		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
+		vma->vm_flags |= VM_HUGEPAGE;
 	return 0;
 }
 
diff --git a/mm/hmm.c b/mm/hmm.c
index de7b6bf77201..f40e8add84b5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -676,7 +676,8 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 		return -EINVAL;
 
 	/* FIXME support hugetlb fs */
-	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
+	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
+			vma_is_dax(vma)) {
 		hmm_pfns_special(range);
 		return -EINVAL;
 	}
@@ -849,7 +850,8 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 		return -EINVAL;
 
 	/* FIXME support hugetlb fs */
-	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
+	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
+			vma_is_dax(vma)) {
 		hmm_pfns_special(range);
 		return -EINVAL;
 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6af976472a5d..d89ba3564562 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -765,11 +765,11 @@ vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	 * but we need to be consistent with PTEs and architectures that
 	 * can't support a 'special' bit.
 	 */
-	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) &&
+			!pfn_t_devmap(pfn));
 	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
 						(VM_PFNMAP|VM_MIXEDMAP));
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
-	BUG_ON(!pfn_t_devmap(pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return VM_FAULT_SIGBUS;
diff --git a/mm/ksm.c b/mm/ksm.c
index e3cbf9a92f3c..d30393e486d4 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2400,6 +2400,9 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 				 VM_HUGETLB | VM_MIXEDMAP))
 			return 0;		/* just ignore the advice */
 
+		if (vma_is_dax(vma))
+			return 0;
+
 #ifdef VM_SAO
 		if (*vm_flags & VM_SAO)
 			return 0;
diff --git a/mm/memory.c b/mm/memory.c
index 01f5464e0fd2..2b364a5ed4d5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -858,6 +858,10 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 				return NULL;
 			}
 		}
+
+		if (pte_devmap(pte))
+			return NULL;
+
 		print_bad_pte(vma, addr, pte, NULL);
 		return NULL;
 	}
@@ -921,6 +925,8 @@ struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
 		}
 	}
 
+	if (pmd_devmap(pmd))
+		return NULL;
 	if (is_zero_pfn(pfn))
 		return NULL;
 	if (unlikely(pfn > highest_memmap_pfn))
diff --git a/mm/migrate.c b/mm/migrate.c
index 8c0af0f7cab1..4a83268e23c2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2951,7 +2951,8 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 	/* Sanity check the arguments */
 	start &= PAGE_MASK;
 	end &= PAGE_MASK;
-	if (!vma || is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
+	if (!vma || is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
+			vma_is_dax(vma))
 		return -EINVAL;
 	if (start < vma->vm_start || start >= vma->vm_end)
 		return -EINVAL;
diff --git a/mm/mlock.c b/mm/mlock.c
index 74e5a6547c3d..41cc47e28ad6 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -527,7 +527,8 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	vm_flags_t old_flags = vma->vm_flags;
 
 	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
-	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
+	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm) ||
+	    vma_is_dax(vma))
 		/* don't set VM_LOCKED or VM_LOCKONFAULT and don't count */
 		goto out;
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 78e14facdb6e..5db93f58fdb1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1796,11 +1796,12 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 
 	vm_stat_account(mm, vm_flags, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
-		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
-					vma == get_gate_vma(current->mm)))
-			mm->locked_vm += (len >> PAGE_SHIFT);
-		else
+		if ((vm_flags & VM_SPECIAL) || vma_is_dax(vma) ||
+					is_vm_hugetlb_page(vma) ||
+					vma == get_gate_vma(current->mm))
 			vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
+		else
+			mm->locked_vm += (len >> PAGE_SHIFT);
 	}
 
 	if (file)
