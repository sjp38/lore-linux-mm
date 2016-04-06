Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EF4AE6B0298
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:58:55 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id 184so42556031pff.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:58:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id o13si7277125pfj.73.2016.04.06.15.51.36
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:36 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 26/30] shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings
Date: Thu,  7 Apr 2016 01:51:16 +0300
Message-Id: <1459983080-106718-27-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's wire up existing madvise() hugepage hints for file mappings.

MADV_HUGEPAGE advise shmem to allocate huge page on page fault in the
VMA. It only has effect if the filesystem is mounted with huge=advise or
huge=within_size.

MADV_NOHUGEPAGE prevents hugepage from being allocated on page fault in
the VMA. It doesn't prevent a huge page from being allocated by other
means, i.e. page fault into different mapping or write(2) into file.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 19 +++++--------------
 mm/shmem.c       | 20 +++++++++++++++++---
 2 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b9788468e50b..17f5c78f55f3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1840,7 +1840,7 @@ spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
 	return NULL;
 }
 
-#define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
+#define VM_NO_KHUGEPAGED (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
 		     unsigned long *vm_flags, int advice)
@@ -1856,11 +1856,6 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		if (mm_has_pgste(vma->vm_mm))
 			return 0;
 #endif
-		/*
-		 * Be somewhat over-protective like KSM for now!
-		 */
-		if (*vm_flags & VM_NO_THP)
-			return -EINVAL;
 		*vm_flags &= ~VM_NOHUGEPAGE;
 		*vm_flags |= VM_HUGEPAGE;
 		/*
@@ -1868,15 +1863,11 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		 * register it here without waiting a page fault that
 		 * may not happen any time soon.
 		 */
-		if (unlikely(khugepaged_enter_vma_merge(vma, *vm_flags)))
+		if (!(*vm_flags & VM_NO_KHUGEPAGED) &&
+				khugepaged_enter_vma_merge(vma, *vm_flags))
 			return -ENOMEM;
 		break;
 	case MADV_NOHUGEPAGE:
-		/*
-		 * Be somewhat over-protective like KSM for now!
-		 */
-		if (*vm_flags & VM_NO_THP)
-			return -EINVAL;
 		*vm_flags &= ~VM_HUGEPAGE;
 		*vm_flags |= VM_NOHUGEPAGE;
 		/*
@@ -1987,7 +1978,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 	if (vma->vm_ops)
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
-	VM_BUG_ON_VMA(vm_flags & VM_NO_THP, vma);
+	VM_BUG_ON_VMA(vm_flags & VM_NO_KHUGEPAGED, vma);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
@@ -2376,7 +2367,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
-	VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma);
+	VM_BUG_ON_VMA(vma->vm_flags & VM_NO_KHUGEPAGED, vma);
 	return true;
 }
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 265bb17af1e5..5aea558c5319 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -101,6 +101,8 @@ struct shmem_falloc {
 enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
+	SGP_NOHUGE,	/* like SGP_CACHE, but no huge pages */
+	SGP_HUGE,	/* like SGP_CACHE, huge pages preferred */
 	SGP_DIRTY,	/* like SGP_CACHE, but set new page dirty */
 	SGP_WRITE,	/* may exceed i_size, may allocate !Uptodate page */
 	SGP_FALLOC,	/* like SGP_WRITE, but make existing page Uptodate */
@@ -1367,6 +1369,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct mem_cgroup *memcg;
 	struct page *page;
 	swp_entry_t swap;
+	enum sgp_type sgp_huge = sgp;
 	pgoff_t hindex = index;
 	int error;
 	int once = 0;
@@ -1374,6 +1377,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 
 	if (index > (MAX_LFS_FILESIZE >> PAGE_SHIFT))
 		return -EFBIG;
+	if (sgp == SGP_NOHUGE || sgp == SGP_HUGE)
+		sgp = SGP_CACHE;
 repeat:
 	swap.val = 0;
 	page = find_lock_entry(mapping, index);
@@ -1487,7 +1492,7 @@ repeat:
 		/* shmem_symlink() */
 		if (mapping->a_ops != &shmem_aops)
 			goto alloc_nohuge;
-		if (shmem_huge == SHMEM_HUGE_DENY)
+		if (shmem_huge == SHMEM_HUGE_DENY || sgp_huge == SGP_NOHUGE)
 			goto alloc_nohuge;
 		if (shmem_huge == SHMEM_HUGE_FORCE)
 			goto alloc_huge;
@@ -1504,7 +1509,9 @@ repeat:
 				goto alloc_huge;
 			/* fallthrough */
 		case SHMEM_HUGE_ADVISE:
-			/* TODO: wire up fadvise()/madvise() */
+			if (sgp_huge == SGP_HUGE)
+				goto alloc_huge;
+			/* TODO: implement fadvise() hints */
 			goto alloc_nohuge;
 		}
 
@@ -1636,6 +1643,7 @@ unlock:
 static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct inode *inode = file_inode(vma->vm_file);
+	enum sgp_type sgp;
 	int error;
 	int ret = VM_FAULT_LOCKED;
 
@@ -1697,7 +1705,13 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		spin_unlock(&inode->i_lock);
 	}
 
-	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, &ret);
+	sgp = SGP_CACHE;
+	if (vma->vm_flags & VM_HUGEPAGE)
+		sgp = SGP_HUGE;
+	else if (vma->vm_flags & VM_NOHUGEPAGE)
+		sgp = SGP_NOHUGE;
+
+	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, sgp, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
