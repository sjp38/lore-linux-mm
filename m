Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3F56B0038
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 19:55:47 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so35369446pab.0
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 16:55:47 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id oq9si8739003pac.131.2015.10.20.16.55.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 16:55:46 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 3/4] mm/hugetlb: page faults check for fallocate hole punch in progress and wait
Date: Tue, 20 Oct 2015 16:52:21 -0700
Message-Id: <1445385142-29936-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com>
References: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

At page fault time, check i_private which indicates a fallocate hole punch
is in progress.  If the fault falls within the hole, wait for the hole
punch operation to complete before proceeding with the fault.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3c7db92..2a5e9b4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3580,6 +3580,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *pagecache_page = NULL;
 	struct hstate *h = hstate_vma(vma);
 	struct address_space *mapping;
+	struct inode *inode = file_inode(vma->vm_file);
 	int need_wait_lock = 0;
 
 	address &= huge_page_mask(h);
@@ -3603,6 +3604,44 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	idx = vma_hugecache_offset(h, vma, address);
 
 	/*
+	 * page faults could race with fallocate hole punch.  If a page
+	 * is faulted between unmap and deallocation, it will still remain
+	 * in the punched hole.  During hole punch operations, a hugetlb_falloc
+	 * structure will be pointed to by i_private.  If this fault is for
+	 * a page in a hole being punched, wait for the operation to finish
+	 * before proceeding.
+	 *
+	 * Even with this strategy, it is still possible for a page fault to
+	 * race with hole punch.  In this case, remove_inode_hugepages() will
+	 * unmap the page and then remove.  Checking i_private as below should
+	 * catch most of these races as we want to minimize unmapping a page
+	 * multiple times.
+	 */
+	if (unlikely(inode->i_private)) {
+		struct hugetlb_falloc *hugetlb_falloc;
+
+		spin_lock(&inode->i_lock);
+		hugetlb_falloc = inode->i_private;
+		if (hugetlb_falloc && hugetlb_falloc->waitq &&
+		    idx >= hugetlb_falloc->start &&
+		    idx <= hugetlb_falloc->end) {
+			wait_queue_head_t *hugetlb_falloc_waitq;
+			DEFINE_WAIT(hugetlb_fault_wait);
+
+			hugetlb_falloc_waitq = hugetlb_falloc->waitq;
+			prepare_to_wait(hugetlb_falloc_waitq,
+					&hugetlb_fault_wait,
+					TASK_UNINTERRUPTIBLE);
+			spin_unlock(&inode->i_lock);
+			schedule();
+
+			spin_lock(&inode->i_lock);
+			finish_wait(hugetlb_falloc_waitq, &hugetlb_fault_wait);
+		}
+		spin_unlock(&inode->i_lock);
+	}
+
+	/*
 	 * Serialize hugepage allocation and instantiation, so that we don't
 	 * get spurious allocation failures if two CPUs race to instantiate
 	 * the same page in the page cache.
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
