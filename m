Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5826E6B02AE
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:11 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o68so24649776qkf.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w26si1930921qtc.62.2016.11.02.12.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:10 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 13/33] userfaultfd: hugetlbfs: add copy_huge_page_from_user for hugetlb userfaultfd support
Date: Wed,  2 Nov 2016 20:33:45 +0100
Message-Id: <1478115245-32090-14-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

From: Mike Kravetz <mike.kravetz@oracle.com>

userfaultfd UFFDIO_COPY allows user level code to copy data to a page
at fault time.  The data is copied from user space to a newly allocated
huge page.  The new routine copy_huge_page_from_user performs this copy.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h |  3 +++
 mm/memory.c        | 25 +++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a92c8d7..ec18964 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2404,6 +2404,9 @@ extern void clear_huge_page(struct page *page,
 extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned long addr, struct vm_area_struct *vma,
 				unsigned int pages_per_huge_page);
+extern long copy_huge_page_from_user(struct page *dst_page,
+				const void __user *usr_src,
+				unsigned int pages_per_huge_page);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
 extern struct page_ext_operations debug_guardpage_ops;
diff --git a/mm/memory.c b/mm/memory.c
index e18c57b..00dc2fe 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4093,6 +4093,31 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 		copy_user_highpage(dst + i, src + i, addr + i*PAGE_SIZE, vma);
 	}
 }
+
+long copy_huge_page_from_user(struct page *dst_page,
+				const void __user *usr_src,
+				unsigned int pages_per_huge_page)
+{
+	void *src = (void *)usr_src;
+	void *page_kaddr;
+	unsigned long i, rc = 0;
+	unsigned long ret_val = pages_per_huge_page * PAGE_SIZE;
+
+	for (i = 0; i < pages_per_huge_page; i++) {
+		page_kaddr = kmap_atomic(dst_page + i);
+		rc = copy_from_user(page_kaddr,
+				(const void __user *)(src + i * PAGE_SIZE),
+				PAGE_SIZE);
+		kunmap_atomic(page_kaddr);
+
+		ret_val -= (PAGE_SIZE - rc);
+		if (rc)
+			break;
+
+		cond_resched();
+	}
+	return ret_val;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
 #if USE_SPLIT_PTE_PTLOCKS && ALLOC_SPLIT_PTLOCKS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
