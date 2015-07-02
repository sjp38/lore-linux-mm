Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 48D8A280246
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 11:39:54 -0400 (EDT)
Received: by oihr66 with SMTP id r66so2830461oih.2
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 08:39:54 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id fv12si4753153oeb.49.2015.07.02.08.39.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jul 2015 08:39:53 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 08/10] hugetlbfs: New huge_add_to_page_cache helper routine
Date: Thu,  2 Jul 2015 08:38:44 -0700
Message-Id: <1435851526-4200-9-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1435851526-4200-1-git-send-email-mike.kravetz@oracle.com>
References: <1435851526-4200-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

Currently, there is  only a single place where hugetlbfs pages are
added to the page cache.  The new fallocate code be adding a second
one, so break the functionality out into its own helper.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h |  2 ++
 mm/hugetlb.c            | 27 ++++++++++++++++++---------
 2 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 95cd716..12e90f1 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -333,6 +333,8 @@ struct huge_bootmem_page {
 struct page *alloc_huge_page_node(struct hstate *h, int nid);
 struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
 				unsigned long addr, int avoid_reserve);
+int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
+			pgoff_t idx);
 
 /* arch callback */
 int __init alloc_bootmem_huge_page(struct hstate *h);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 90d8250..d6e47ac 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3373,6 +3373,23 @@ static bool hugetlbfs_pagecache_present(struct hstate *h,
 	return page != NULL;
 }
 
+int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
+			   pgoff_t idx)
+{
+	struct inode *inode = mapping->host;
+	struct hstate *h = hstate_inode(inode);
+	int err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
+
+	if (err)
+		return err;
+	ClearPagePrivate(page);
+
+	spin_lock(&inode->i_lock);
+	inode->i_blocks += blocks_per_huge_page(h);
+	spin_unlock(&inode->i_lock);
+	return 0;
+}
+
 static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			   struct address_space *mapping, pgoff_t idx,
 			   unsigned long address, pte_t *ptep, unsigned int flags)
@@ -3420,21 +3437,13 @@ retry:
 		set_page_huge_active(page);
 
 		if (vma->vm_flags & VM_MAYSHARE) {
-			int err;
-			struct inode *inode = mapping->host;
-
-			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
+			int err = huge_add_to_page_cache(page, mapping, idx);
 			if (err) {
 				put_page(page);
 				if (err == -EEXIST)
 					goto retry;
 				goto out;
 			}
-			ClearPagePrivate(page);
-
-			spin_lock(&inode->i_lock);
-			inode->i_blocks += blocks_per_huge_page(h);
-			spin_unlock(&inode->i_lock);
 		} else {
 			lock_page(page);
 			if (unlikely(anon_vma_prepare(vma))) {
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
