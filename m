Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CAA36B026F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:28 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 3so48736672ioc.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l10si2930434itd.116.2016.12.16.06.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 16/42] userfaultfd: hugetlbfs: add copy_huge_page_from_user for hugetlb userfaultfd support
Date: Fri, 16 Dec 2016 15:47:55 +0100
Message-Id: <20161216144821.5183-17-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

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
index 4424784..298b265 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2394,6 +2394,9 @@ extern void clear_huge_page(struct page *page,
 extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned long addr, struct vm_area_struct *vma,
 				unsigned int pages_per_huge_page);
+extern long copy_huge_page_from_user(struct page *dst_page,
+				const void __user *usr_src,
+				unsigned int pages_per_huge_page);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
 extern struct page_ext_operations debug_guardpage_ops;
diff --git a/mm/memory.c b/mm/memory.c
index 455c3e6..9e4ecf1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4139,6 +4139,31 @@ void copy_user_huge_page(struct page *dst, struct page *src,
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
