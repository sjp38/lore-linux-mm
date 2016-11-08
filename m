Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5465B6B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 16:06:23 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id w194so147171119vkw.2
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 13:06:23 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j17si176766vka.45.2016.11.08.13.06.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 13:06:22 -0800 (PST)
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb
 for huge page UFFDIO_COPY
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
 <1478115245-32090-16-git-send-email-aarcange@redhat.com>
 <074501d235bb$3766dbd0$a6349370$@alibaba-inc.com>
 <c9c59023-35ee-1012-1da7-13c3aa89ba61@oracle.com>
 <31d06dc7-ea2d-4ca3-821a-f14ea69de3e9@oracle.com>
 <20161104193626.GU4611@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <1805f956-1777-471c-1401-46c984189c88@oracle.com>
Date: Tue, 8 Nov 2016 13:06:06 -0800
MIME-Version: 1.0
In-Reply-To: <20161104193626.GU4611@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On 11/04/2016 12:36 PM, Andrea Arcangeli wrote:
> This is the current status, I'm sending a full diff against the
> previous submit for review of the latest updates. It's easier to
> review incrementally I think.
> 
> Please test it, I updated the aa.git tree userfault branch in sync
> with this.
> 

Hello Andrea,

I found a couple more issues with hugetlbfs support.  The below patch
describes and addresses the issues.  It is against your aa tree. Do note
that there is a patch going into mm tree that is a pre-req for this
patch.  The patch is "mm/hugetlb: fix huge page reservation leak in
private mapping error paths".
http://marc.info/?l=linux-mm&m=147693310409312&w=2

-- 
Mike Kravetz

From: Mike Kravetz <mike.kravetz@oracle.com>

userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing

The new routine copy_huge_page_from_user() uses kmap_atomic() to map
PAGE_SIZE pages.  However, this prevents page faults in the subsequent
call to copy_from_user().  This is OK in the case where the routine
is copied with mmap_sema held.  However, in another case we want to
allow page faults.  So, add a new argument allow_pagefault to indicate
if the routine should allow page faults.

A patch (mm/hugetlb: fix huge page reservation leak in private mapping
error paths) was recently submitted and is being added to -mm tree.  It
addresses the issue huge page reservations when a huge page is allocated,
and free'ed before being instantiated in an address space.  This would
typically happen in error paths.  The routine __mcopy_atomic_hugetlb has
such an error path, so it will need to call restore_reserve_on_error()
before free'ing the huge page.  restore_reserve_on_error is currently
only visible in mm/hugetlb.c.  So, add it to a header file so that it
can be used in mm/userfaultfd.c.  Another option would be to move
__mcopy_atomic_hugetlb into mm/hugetlb.c

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h |  2 ++
 include/linux/mm.h      |  3 ++-
 mm/hugetlb.c            |  7 +++----
 mm/memory.c             | 13 ++++++++++---
 mm/userfaultfd.c        |  6 ++++--
 5 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index fc27b66..bf02b7e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -101,6 +101,8 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h,
struct mm_struct *mm,
 				struct vm_area_struct *vma,
 				struct address_space *mapping,
 				pgoff_t idx, unsigned long address);
+void restore_reserve_on_error(struct hstate *h, struct vm_area_struct *vma,
+				unsigned long address, struct page *page);

 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t
*pud);

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 39157f5..7c73a05 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2417,7 +2417,8 @@ extern void copy_user_huge_page(struct page *dst,
struct page *src,
 				unsigned int pages_per_huge_page);
 extern long copy_huge_page_from_user(struct page *dst_page,
 				const void __user *usr_src,
-				unsigned int pages_per_huge_page);
+				unsigned int pages_per_huge_page,
+				bool allow_pagefault);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */

 extern struct page_ext_operations debug_guardpage_ops;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7bfeee3..9ce8ecb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1935,9 +1935,8 @@ static long vma_add_reservation(struct hstate *h,
  * reserve map here to be consistent with global reserve count adjustments
  * to be made by free_huge_page.
  */
-static void restore_reserve_on_error(struct hstate *h,
-			struct vm_area_struct *vma, unsigned long address,
-			struct page *page)
+void restore_reserve_on_error(struct hstate *h, struct vm_area_struct *vma,
+				unsigned long address, struct page *page)
 {
 	if (unlikely(PagePrivate(page))) {
 		long rc = vma_needs_reservation(h, vma, address);
@@ -3981,7 +3980,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,

 		ret = copy_huge_page_from_user(page,
 						(const void __user *) src_addr,
-						pages_per_huge_page(h));
+						pages_per_huge_page(h), false);

 		/* fallback to copy_from_user outside mmap_sem */
 		if (unlikely(ret)) {
diff --git a/mm/memory.c b/mm/memory.c
index b911110..0137c4a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4106,7 +4106,8 @@ void copy_user_huge_page(struct page *dst, struct
page *src,

 long copy_huge_page_from_user(struct page *dst_page,
 				const void __user *usr_src,
-				unsigned int pages_per_huge_page)
+				unsigned int pages_per_huge_page,
+				bool allow_pagefault)
 {
 	void *src = (void *)usr_src;
 	void *page_kaddr;
@@ -4114,11 +4115,17 @@ long copy_huge_page_from_user(struct page *dst_page,
 	unsigned long ret_val = pages_per_huge_page * PAGE_SIZE;

 	for (i = 0; i < pages_per_huge_page; i++) {
-		page_kaddr = kmap_atomic(dst_page + i);
+		if (allow_pagefault)
+			page_kaddr = kmap(dst_page + i);
+		else
+			page_kaddr = kmap_atomic(dst_page + i);
 		rc = copy_from_user(page_kaddr,
 				(const void __user *)(src + i * PAGE_SIZE),
 				PAGE_SIZE);
-		kunmap_atomic(page_kaddr);
+		if (allow_pagefault)
+			kunmap(page_kaddr);
+		else
+			kunmap_atomic(page_kaddr);

 		ret_val -= (PAGE_SIZE - rc);
 		if (rc)
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index e8d7a89..c8588aa 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -275,7 +275,7 @@ static __always_inline ssize_t
__mcopy_atomic_hugetlb(struct mm_struct *dst_mm,

 			err = copy_huge_page_from_user(page,
 						(const void __user *)src_addr,
-						pages_per_huge_page(h));
+						pages_per_huge_page(h), true);
 			if (unlikely(err)) {
 				err = -EFAULT;
 				goto out;
@@ -302,8 +302,10 @@ static __always_inline ssize_t
__mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 out_unlock:
 	up_read(&dst_mm->mmap_sem);
 out:
-	if (page)
+	if (page) {
+		restore_reserve_on_error(h, dst_vma, dst_addr, page);
 		put_page(page);
+	}
 	BUG_ON(copied < 0);
 	BUG_ON(err > 0);
 	BUG_ON(!copied && !err);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
