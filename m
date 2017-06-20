Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2994B6B02F4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:15 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 77so6245716wrb.11
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 23:21:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b4si8429451wmh.72.2017.06.19.23.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 23:21:14 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5K6Iirm007163
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:12 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b6hbhwws1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:12 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 20 Jun 2017 07:21:09 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 4/7] userfaultfd: mcopy_atomic: introduce mfill_atomic_pte helper
Date: Tue, 20 Jun 2017 09:20:49 +0300
In-Reply-To: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1497939652-16528-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Shuffle the code a bit to improve readability.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/userfaultfd.c | 46 ++++++++++++++++++++++++++++++----------------
 1 file changed, 30 insertions(+), 16 deletions(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 8bcb501..48c015c 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -371,6 +371,34 @@ extern ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 				      bool zeropage);
 #endif /* CONFIG_HUGETLB_PAGE */
 
+static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
+						pmd_t *dst_pmd,
+						struct vm_area_struct *dst_vma,
+						unsigned long dst_addr,
+						unsigned long src_addr,
+						struct page **page,
+						bool zeropage)
+{
+	ssize_t err;
+
+	if (vma_is_anonymous(dst_vma)) {
+		if (!zeropage)
+			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
+					       dst_addr, src_addr, page);
+		else
+			err = mfill_zeropage_pte(dst_mm, dst_pmd,
+						 dst_vma, dst_addr);
+	} else {
+		err = -EINVAL; /* if zeropage is true return -EINVAL */
+		if (likely(!zeropage))
+			err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd,
+						     dst_vma, dst_addr,
+						     src_addr, page);
+	}
+
+	return err;
+}
+
 static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 					      unsigned long dst_start,
 					      unsigned long src_start,
@@ -487,22 +515,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 		BUG_ON(pmd_none(*dst_pmd));
 		BUG_ON(pmd_trans_huge(*dst_pmd));
 
-		if (vma_is_anonymous(dst_vma)) {
-			if (!zeropage)
-				err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
-						       dst_addr, src_addr,
-						       &page);
-			else
-				err = mfill_zeropage_pte(dst_mm, dst_pmd,
-							 dst_vma, dst_addr);
-		} else {
-			err = -EINVAL; /* if zeropage is true return -EINVAL */
-			if (likely(!zeropage))
-				err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd,
-							     dst_vma, dst_addr,
-							     src_addr, &page);
-		}
-
+		err = mfill_atomic_pte(dst_mm, dst_pmd, dst_vma, dst_addr,
+				       src_addr, &page, zeropage);
 		cond_resched();
 
 		if (unlikely(err == -EFAULT)) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
