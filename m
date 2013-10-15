Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id EF76E6B0037
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 20:12:48 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so8009703pdi.5
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:12:48 -0700 (PDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so7927044pbc.30
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:12:46 -0700 (PDT)
Date: Mon, 14 Oct 2013 17:12:42 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCH 05/12] mm, thp, tmpfs: request huge page in shm_fault when
 needed
Message-ID: <20131015001242.GF3432@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

Add the function to request huge page in shm_fault when needed.
And it will fall back to regular page if huge page can't be
satisfied or allocated.

If small page requested but huge page is found, the huge page will
be splitted.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 32 +++++++++++++++++++++++++++++---
 1 file changed, 29 insertions(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 68a0e1d..2fc450d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1472,19 +1472,45 @@ unlock:
 static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct inode *inode = file_inode(vma->vm_file);
+	struct page *page = NULL;
 	int error;
 	int ret = VM_FAULT_LOCKED;
 	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
-
-	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, gfp,
-				0, &ret);
+	bool must_use_thp = vmf->flags & FAULT_FLAG_TRANSHUGE;
+	int flags = 0;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+	flags |= AOP_FLAG_TRANSHUGE;
+#endif
+retry_find:
+	error = shmem_getpage(inode, vmf->pgoff, &page, SGP_CACHE, gfp,
+				flags, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
 
+	/* Split huge page if we don't want huge page to be here */
+	if (!must_use_thp && PageTransCompound(page)) {
+		unlock_page(page);
+		page_cache_release(page);
+		split_huge_page(compound_trans_head(page));
+		page = NULL;
+		goto retry_find;
+	}
+
+	if (must_use_thp && !PageTransHuge(page)) {
+		/*
+		 * Caller asked for huge page, but we have small page
+		 * by this offset. Fallback to small pages.
+		 */
+		unlock_page(page);
+		page_cache_release(page);
+		return VM_FAULT_FALLBACK;
+	}
+
 	if (ret & VM_FAULT_MAJOR) {
 		count_vm_event(PGMAJFAULT);
 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 	}
+	vmf->page = page;
 	return ret;
 }
 
-- 
1.8.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
