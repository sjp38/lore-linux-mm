Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 30E9D82F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 18:10:49 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so1457859pab.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:10:48 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id vz2si32186551pbc.164.2015.10.16.15.10.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 15:10:48 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 3/3] mm/hugetlb: page faults check for fallocate hole punch in progress and wait
Date: Fri, 16 Oct 2015 15:08:30 -0700
Message-Id: <1445033310-13155-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1445033310-13155-1-git-send-email-mike.kravetz@oracle.com>
References: <1445033310-13155-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

At page fault time, check i_private which indicates a fallocate hole punch
is in progress.  If the fault falls within the hole, wait for the hole
punch operation to complete before proceeding with the fault.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3c7db92..540d3a79 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3580,6 +3580,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *pagecache_page = NULL;
 	struct hstate *h = hstate_vma(vma);
 	struct address_space *mapping;
+	struct inode *inode = file_inode(vma->vm_file);
 	int need_wait_lock = 0;
 
 	address &= huge_page_mask(h);
@@ -3603,6 +3604,42 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
+	 * race with hole punch.  However, the race window is considerably
+	 * smaller.
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
