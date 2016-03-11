Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 46D886B0258
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 18:07:11 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id tt10so110553393pab.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 15:07:11 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ds16si1214123pac.149.2016.03.11.14.59.35
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 14:59:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 25/25] shmem, thp: respect MADV_{NO,}HUGEPAGE for file mappings
Date: Sat, 12 Mar 2016 01:59:17 +0300
Message-Id: <1457737157-38573-26-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's wire up existing madvise() hugepage hints for file mappings.

MADV_HUGEPAGE advise shmem to allocate huge page on page fault in the
VMA. It only has effect if the filesystem is mounted with huge=advise or
huge=within_size.

MADV_NOHUGEPAGE prevents hugepage from being allocated on page fault in
the VMA. It doesn't prevent a huge page from being allocated by other
means, i.e. page fault into different mapping or write(2) into file.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 13 ++-----------
 mm/shmem.c       | 20 +++++++++++++++++---
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a9d642ff7aa2..8d5b552b7963 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1844,11 +1844,6 @@ int hugepage_madvise(struct vm_area_struct *vma,
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
@@ -1856,15 +1851,11 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		 * register it here without waiting a page fault that
 		 * may not happen any time soon.
 		 */
-		if (unlikely(khugepaged_enter_vma_merge(vma, *vm_flags)))
+		if ((*vm_flags & VM_NO_THP) &&
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
diff --git a/mm/shmem.c b/mm/shmem.c
index c31216806721..ee8a15c24123 100644
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
@@ -1371,6 +1373,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct mem_cgroup *memcg;
 	struct page *page;
 	swp_entry_t swap;
+	enum sgp_type sgp_huge = sgp;
 	pgoff_t hindex = index;
 	int error;
 	int once = 0;
@@ -1378,6 +1381,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 
 	if (index > (MAX_LFS_FILESIZE >> PAGE_CACHE_SHIFT))
 		return -EFBIG;
+	if (sgp == SGP_NOHUGE || sgp == SGP_HUGE)
+		sgp = SGP_CACHE;
 repeat:
 	swap.val = 0;
 	page = find_lock_entry(mapping, index);
@@ -1491,7 +1496,7 @@ repeat:
 		/* shmem_symlink() */
 		if (mapping->a_ops != &shmem_aops)
 			goto alloc_nohuge;
-		if (shmem_huge == SHMEM_HUGE_DENY)
+		if (shmem_huge == SHMEM_HUGE_DENY || sgp_huge == SGP_NOHUGE)
 			goto alloc_nohuge;
 		if (shmem_huge == SHMEM_HUGE_FORCE)
 			goto alloc_huge;
@@ -1507,7 +1512,9 @@ repeat:
 				goto alloc_huge;
 			/* fallthrough */
 		case SHMEM_HUGE_ADVISE:
-			/* TODO: wire up fadvise()/madvise() */
+			if (sgp_huge == SGP_HUGE)
+				goto alloc_huge;
+			/* TODO: implement fadvise() hints */
 			goto alloc_nohuge;
 		}
 
@@ -1639,6 +1646,7 @@ unlock:
 static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct inode *inode = file_inode(vma->vm_file);
+	enum sgp_type sgp;
 	int error;
 	int ret = VM_FAULT_LOCKED;
 
@@ -1700,7 +1708,13 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
