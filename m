Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E96BB6B007E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 13:53:23 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id w64so130497311iow.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 10:53:23 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g206si707715ioa.99.2016.06.06.10.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 10:53:22 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 1/6] mm/memory: add copy_huge_page_from_user for hugetlb userfaultfd support
Date: Mon,  6 Jun 2016 10:45:26 -0700
Message-Id: <1465235131-6112-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
References: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

userfaultfd UFFDIO_COPY allows user level code to copy data to a page
at fault time.  The data is copied from user space to a newly allocated
huge page.  The new routine copy_huge_page_from_user performs this copy.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/mm.h |  3 +++
 mm/memory.c        | 22 ++++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0510282..7ecc7e7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2355,6 +2355,9 @@ extern void clear_huge_page(struct page *page,
 extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned long addr, struct vm_area_struct *vma,
 				unsigned int pages_per_huge_page);
+extern long copy_huge_page_from_user(const void __user *usr_src,
+				struct page *dst_page,
+				unsigned int pages_per_huge_page);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
 extern struct page_ext_operations debug_guardpage_ops;
diff --git a/mm/memory.c b/mm/memory.c
index 19584b9..c44ddad 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3970,6 +3970,28 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 		copy_user_highpage(dst + i, src + i, addr + i*PAGE_SIZE, vma);
 	}
 }
+
+long copy_huge_page_from_user(const void __user *usr_src,
+				struct page *dst_page,
+				unsigned int pages_per_huge_page)
+{
+	void *src = (void *)usr_src;
+	void *page_kaddr;
+	long i, rc = 0;
+
+	for (i = 0; i < pages_per_huge_page; i++) {
+		page_kaddr = kmap_atomic(dst_page + i);
+		rc = copy_from_user(page_kaddr,
+				(const void __user *)(src + i * PAGE_SIZE),
+				PAGE_SIZE);
+		kunmap_atomic(page_kaddr);
+		if (rc)
+			break;
+
+		cond_resched();
+	}
+	return rc;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
 #if USE_SPLIT_PTE_PTLOCKS && ALLOC_SPLIT_PTLOCKS
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
