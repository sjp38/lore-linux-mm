Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 23AF44403D9
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 23:36:10 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id q63so57681057pfb.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 20:36:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tj2si39894187pab.76.2016.01.11.20.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 20:36:09 -0800 (PST)
Date: Mon, 11 Jan 2016 20:35:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlbfs: Unmap pages if page fault raced with hole
 punch
Message-Id: <20160111203554.cd3990ed.akpm@linux-foundation.org>
In-Reply-To: <5694712B.6040705@oracle.com>
References: <1452119824-32715-1-git-send-email-mike.kravetz@oracle.com>
	<20160111143548.f6dc084529530b05b03b8f0c@linux-foundation.org>
	<56943D00.7090405@oracle.com>
	<20160111162931.0bea916e.akpm@linux-foundation.org>
	<569458AB.5000102@oracle.com>
	<20160111182010.bc4e171b.akpm@linux-foundation.org>
	<5694712B.6040705@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Davidlohr Bueso <dave@stgolabs.net>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, 11 Jan 2016 19:21:15 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> >> Just let me know what is easiest/best for you.
> > 
> > If you're saying that
> > http://ozlabs.org/~akpm/mmots/broken-out/mm-mempolicy-skip-non-migratable-vmas-when-setting-mpol_mf_lazy.patch
> 
> That should be,
> http://ozlabs.org/~akpm/mmots/broken-out/mm-hugetlbfs-fix-bugs-in-hugetlb_vmtruncate_list.patch

yup.

> > and
> > http://ozlabs.org/~akpm/mmots/broken-out/mm-hugetlbfs-unmap-pages-if-page-fault-raced-with-hole-punch.patch
> > are the final everything-works versions then we're all good to go now.
> > 
> 
> The only thing that 'might' be an issue is the new reference to
> hugetlb_vmdelete_list() from remove_inode_hugepages().
> hugetlb_vmdelete_list() was after remove_inode_hugepages() in the source
> file.
> 
> The original patch moved hugetlb_vmdelete_list() to satisfy the new
> reference.  I can not tell if that was taken into account in the way the
> patches were pulled into your tree.  Will certainly know when it comes
> time to build.

um, yes.

--- a/fs/hugetlbfs/inode.c~mm-hugetlbfs-unmap-pages-if-page-fault-raced-with-hole-punch-fix
+++ a/fs/hugetlbfs/inode.c
@@ -324,6 +324,44 @@ static void remove_huge_page(struct page
 	delete_from_page_cache(page);
 }
 
+static void
+hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
+{
+	struct vm_area_struct *vma;
+
+	/*
+	 * end == 0 indicates that the entire range after
+	 * start should be unmapped.
+	 */
+	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
+		unsigned long v_offset;
+		unsigned long v_end;
+
+		/*
+		 * Can the expression below overflow on 32-bit arches?
+		 * No, because the interval tree returns us only those vmas
+		 * which overlap the truncated area starting at pgoff,
+		 * and no vma on a 32-bit arch can span beyond the 4GB.
+		 */
+		if (vma->vm_pgoff < start)
+			v_offset = (start - vma->vm_pgoff) << PAGE_SHIFT;
+		else
+			v_offset = 0;
+
+		if (!end)
+			v_end = vma->vm_end;
+		else {
+			v_end = ((end - vma->vm_pgoff) << PAGE_SHIFT)
+							+ vma->vm_start;
+			if (v_end > vma->vm_end)
+				v_end = vma->vm_end;
+		}
+
+		unmap_hugepage_range(vma, vma->vm_start + v_offset, v_end,
+									NULL);
+	}
+}
+
 /*
  * remove_inode_hugepages handles two distinct cases: truncation and hole
  * punch.  There are subtle differences in operation for each case.
@@ -458,44 +496,6 @@ static void hugetlbfs_evict_inode(struct
 	clear_inode(inode);
 }
 
-static inline void
-hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
-{
-	struct vm_area_struct *vma;
-
-	/*
-	 * end == 0 indicates that the entire range after
-	 * start should be unmapped.
-	 */
-	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
-		unsigned long v_offset;
-		unsigned long v_end;
-
-		/*
-		 * Can the expression below overflow on 32-bit arches?
-		 * No, because the interval tree returns us only those vmas
-		 * which overlap the truncated area starting at pgoff,
-		 * and no vma on a 32-bit arch can span beyond the 4GB.
-		 */
-		if (vma->vm_pgoff < start)
-			v_offset = (start - vma->vm_pgoff) << PAGE_SHIFT;
-		else
-			v_offset = 0;
-
-		if (!end)
-			v_end = vma->vm_end;
-		else {
-			v_end = ((end - vma->vm_pgoff) << PAGE_SHIFT)
-							+ vma->vm_start;
-			if (v_end > vma->vm_end)
-				v_end = vma->vm_end;
-		}
-
-		unmap_hugepage_range(vma, vma->vm_start + v_offset, v_end,
-									NULL);
-	}
-}
-
 static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 {
 	pgoff_t pgoff;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
