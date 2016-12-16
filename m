Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B73A86B0271
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:28 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g187so21100989itc.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e205si6178890ioa.58.2016.12.16.06.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 19/42] userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing
Date: Fri, 16 Dec 2016 15:47:58 +0100
Message-Id: <20161216144821.5183-20-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Kravetz <mike.kravetz@oracle.com>

The new routine copy_huge_page_from_user() uses kmap_atomic() to map
PAGE_SIZE pages.  However, this prevents page faults in the subsequent
call to copy_from_user().  This is OK in the case where the routine
is copied with mmap_sema held.  However, in another case we want to
allow page faults.  So, add a new argument allow_pagefault to indicate
if the routine should allow page faults.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h |  3 ++-
 mm/hugetlb.c       |  2 +-
 mm/memory.c        | 13 ++++++++++---
 mm/userfaultfd.c   |  2 +-
 4 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 298b265..f9914ba 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2396,7 +2396,8 @@ extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned int pages_per_huge_page);
 extern long copy_huge_page_from_user(struct page *dst_page,
 				const void __user *usr_src,
-				unsigned int pages_per_huge_page);
+				unsigned int pages_per_huge_page,
+				bool allow_pagefault);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
 extern struct page_ext_operations debug_guardpage_ops;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f815f56..9ea7588 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3954,7 +3954,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 
 		ret = copy_huge_page_from_user(page,
 						(const void __user *) src_addr,
-						pages_per_huge_page(h));
+						pages_per_huge_page(h), false);
 
 		/* fallback to copy_from_user outside mmap_sem */
 		if (unlikely(ret)) {
diff --git a/mm/memory.c b/mm/memory.c
index 9e4ecf1..5c9bfd2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4142,7 +4142,8 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 
 long copy_huge_page_from_user(struct page *dst_page,
 				const void __user *usr_src,
-				unsigned int pages_per_huge_page)
+				unsigned int pages_per_huge_page,
+				bool allow_pagefault)
 {
 	void *src = (void *)usr_src;
 	void *page_kaddr;
@@ -4150,11 +4151,17 @@ long copy_huge_page_from_user(struct page *dst_page,
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
index ef0495b..0997674 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -274,7 +274,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 
 			err = copy_huge_page_from_user(page,
 						(const void __user *)src_addr,
-						pages_per_huge_page(h));
+						pages_per_huge_page(h), true);
 			if (unlikely(err)) {
 				err = -EFAULT;
 				goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
