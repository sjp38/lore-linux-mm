Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C25186B025E
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 04:14:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so140987351wml.0
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:14:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n123si2778654wmg.68.2016.08.04.01.14.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 01:14:51 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u748EUtT026970
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 04:14:49 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24kkajq6r1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 04:14:49 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 09:14:47 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 8F05B17D8056
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:16:21 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u748EiQk1835278
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 08:14:44 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u748Ei41012191
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 02:14:44 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/7] userfaultfd: introduce vma_can_userfault
Date: Thu,  4 Aug 2016 11:14:12 +0300
In-Reply-To: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1470298458-9925-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1470298458-9925-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Check whether a VMA can be used with userfault in more compact way

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f48f709..2aab2e1 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1066,6 +1066,11 @@ static __always_inline int validate_range(struct mm_struct *mm,
 	return 0;
 }
 
+static inline bool vma_can_userfault(struct vm_area_struct *vma)
+{
+	return vma_is_anonymous(vma) || is_vm_hugetlb_page(vma);
+}
+
 static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 				unsigned long arg)
 {
@@ -1148,7 +1153,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 
 		/* check not compatible vmas */
 		ret = -EINVAL;
-		if (!vma_is_anonymous(cur) && !is_vm_hugetlb_page(cur))
+		if (!vma_can_userfault(cur))
 			goto out_unlock;
 		/* FIXME: add WP support to hugetlbfs */
 		if (is_vm_hugetlb_page(cur) && vm_flags & VM_UFFD_WP)
@@ -1197,7 +1202,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(!vma_is_anonymous(vma) && !is_vm_hugetlb_page(vma));
+		BUG_ON(!vma_can_userfault(vma));
 		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
 		       vma->vm_userfaultfd_ctx.ctx != ctx);
 
@@ -1335,7 +1340,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		 * provides for more strict behavior to notice
 		 * unregistration errors.
 		 */
-		if (!vma_is_anonymous(cur) && !is_vm_hugetlb_page(cur))
+		if (!vma_can_userfault(cur))
 			goto out_unlock;
 
 		found = true;
@@ -1349,7 +1354,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	do {
 		cond_resched();
 
-		BUG_ON(!vma_is_anonymous(vma) && !is_vm_hugetlb_page(vma));
+		BUG_ON(!vma_can_userfault(vma));
 
 		/*
 		 * Nothing to do: this vma is already registered into this
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
