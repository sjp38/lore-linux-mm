Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id AE02A9003CE
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 20:23:12 -0400 (EDT)
Received: by ykeo3 with SMTP id o3so102271068yke.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 17:23:12 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s190si2598575ywd.126.2015.07.08.17.23.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 17:23:11 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 08/10] hugetlbfs: New huge_add_to_page_cache helper routine
Date: Wed,  8 Jul 2015 17:21:39 -0700
Message-Id: <1436401301-18839-9-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1436401301-18839-1-git-send-email-mike.kravetz@oracle.com>
References: <1436401301-18839-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>

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
index e7825c9..657ef26 100644
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
index 66f69d7..5d48436 100644
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
