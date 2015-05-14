Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 45BDF6B0096
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:31:48 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so25682765wic.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:31:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d5si39835787wjb.200.2015.05.14.10.31.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:43 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 22/23] userfaultfd: avoid mmap_sem read recursion in mcopy_atomic
Date: Thu, 14 May 2015 19:31:19 +0200
Message-Id: <1431624680-20153-23-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

If the rwsem starves writers it wasn't strictly a bug but lockdep
doesn't like it and this avoids depending on lowlevel implementation
details of the lock.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/userfaultfd.c | 92 ++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 66 insertions(+), 26 deletions(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index c54c761..f8fe494 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -21,26 +21,39 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
 			    pmd_t *dst_pmd,
 			    struct vm_area_struct *dst_vma,
 			    unsigned long dst_addr,
-			    unsigned long src_addr)
+			    unsigned long src_addr,
+			    struct page **pagep)
 {
 	struct mem_cgroup *memcg;
 	pte_t _dst_pte, *dst_pte;
 	spinlock_t *ptl;
-	struct page *page;
 	void *page_kaddr;
 	int ret;
+	struct page *page;
 
-	ret = -ENOMEM;
-	page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, dst_vma, dst_addr);
-	if (!page)
-		goto out;
-
-	page_kaddr = kmap(page);
-	ret = -EFAULT;
-	if (copy_from_user(page_kaddr, (const void __user *) src_addr,
-			   PAGE_SIZE))
-		goto out_kunmap_release;
-	kunmap(page);
+	if (!*pagep) {
+		ret = -ENOMEM;
+		page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, dst_vma, dst_addr);
+		if (!page)
+			goto out;
+
+		page_kaddr = kmap_atomic(page);
+		ret = copy_from_user(page_kaddr,
+				     (const void __user *) src_addr,
+				     PAGE_SIZE);
+		kunmap_atomic(page_kaddr);
+
+		/* fallback to copy_from_user outside mmap_sem */
+		if (unlikely(ret)) {
+			ret = -EFAULT;
+			*pagep = page;
+			/* don't free the page */
+			goto out;
+		}
+	} else {
+		page = *pagep;
+		*pagep = NULL;
+	}
 
 	/*
 	 * The memory barrier inside __SetPageUptodate makes sure that
@@ -82,9 +95,6 @@ out_release_uncharge_unlock:
 out_release:
 	page_cache_release(page);
 	goto out;
-out_kunmap_release:
-	kunmap(page);
-	goto out_release;
 }
 
 static int mfill_zeropage_pte(struct mm_struct *dst_mm,
@@ -139,7 +149,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	ssize_t err;
 	pmd_t *dst_pmd;
 	unsigned long src_addr, dst_addr;
-	long copied = 0;
+	long copied;
+	struct page *page;
 
 	/*
 	 * Sanitize the command parameters:
@@ -151,6 +162,11 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	BUG_ON(src_start + len <= src_start);
 	BUG_ON(dst_start + len <= dst_start);
 
+	src_addr = src_start;
+	dst_addr = dst_start;
+	copied = 0;
+	page = NULL;
+retry:
 	down_read(&dst_mm->mmap_sem);
 
 	/*
@@ -160,10 +176,10 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	err = -EINVAL;
 	dst_vma = find_vma(dst_mm, dst_start);
 	if (!dst_vma || (dst_vma->vm_flags & VM_SHARED))
-		goto out;
+		goto out_unlock;
 	if (dst_start < dst_vma->vm_start ||
 	    dst_start + len > dst_vma->vm_end)
-		goto out;
+		goto out_unlock;
 
 	/*
 	 * Be strict and only allow __mcopy_atomic on userfaultfd
@@ -175,14 +191,14 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 * belonging to the userfaultfd and not syscalls.
 	 */
 	if (!dst_vma->vm_userfaultfd_ctx.ctx)
-		goto out;
+		goto out_unlock;
 
 	/*
 	 * FIXME: only allow copying on anonymous vmas, tmpfs should
 	 * be added.
 	 */
 	if (dst_vma->vm_ops)
-		goto out;
+		goto out_unlock;
 
 	/*
 	 * Ensure the dst_vma has a anon_vma or this page
@@ -191,12 +207,13 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 */
 	err = -ENOMEM;
 	if (unlikely(anon_vma_prepare(dst_vma)))
-		goto out;
+		goto out_unlock;
 
-	for (src_addr = src_start, dst_addr = dst_start;
-	     src_addr < src_start + len; ) {
+	while (src_addr < src_start + len) {
 		pmd_t dst_pmdval;
+
 		BUG_ON(dst_addr >= dst_start + len);
+
 		dst_pmd = mm_alloc_pmd(dst_mm, dst_addr);
 		if (unlikely(!dst_pmd)) {
 			err = -ENOMEM;
@@ -229,13 +246,33 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 
 		if (!zeropage)
 			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
-					       dst_addr, src_addr);
+					       dst_addr, src_addr, &page);
 		else
 			err = mfill_zeropage_pte(dst_mm, dst_pmd, dst_vma,
 						 dst_addr);
 
 		cond_resched();
 
+		if (unlikely(err == -EFAULT)) {
+			void *page_kaddr;
+
+			BUILD_BUG_ON(zeropage);
+			up_read(&dst_mm->mmap_sem);
+			BUG_ON(!page);
+
+			page_kaddr = kmap(page);
+			err = copy_from_user(page_kaddr,
+					     (const void __user *) src_addr,
+					     PAGE_SIZE);
+			kunmap(page);
+			if (unlikely(err)) {
+				err = -EFAULT;
+				goto out;
+			}
+			goto retry;
+		} else
+			BUG_ON(page);
+
 		if (!err) {
 			dst_addr += PAGE_SIZE;
 			src_addr += PAGE_SIZE;
@@ -248,8 +285,11 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 			break;
 	}
 
-out:
+out_unlock:
 	up_read(&dst_mm->mmap_sem);
+out:
+	if (page)
+		page_cache_release(page);
 	BUG_ON(copied < 0);
 	BUG_ON(err > 0);
 	BUG_ON(!copied && !err);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
