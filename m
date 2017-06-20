Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E31226B02FD
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:18 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so19867412wrb.6
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 23:21:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k19si13072902wrd.349.2017.06.19.23.21.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 23:21:17 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5K6Ig9Z001309
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:16 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b6v2wvr1g-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:16 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 20 Jun 2017 07:21:14 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 6/7] userfaultfd: report UFFDIO_ZEROPAGE as available for shmem VMAs
Date: Tue, 20 Jun 2017 09:20:51 +0300
In-Reply-To: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1497939652-16528-7-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Now when shmem VMAs can be filled with zero page via userfaultfd we can
report that UFFDIO_ZEROPAGE is available for those VMAs

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f7555fc..57794c2 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1183,7 +1183,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	struct uffdio_register __user *user_uffdio_register;
 	unsigned long vm_flags, new_flags;
 	bool found;
-	bool non_anon_pages;
+	bool basic_ioctls;
 	unsigned long start, end, vma_end;
 
 	user_uffdio_register = (struct uffdio_register __user *) arg;
@@ -1249,7 +1249,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	 * Search for not compatible vmas.
 	 */
 	found = false;
-	non_anon_pages = false;
+	basic_ioctls = false;
 	for (cur = vma; cur && cur->vm_start < end; cur = cur->vm_next) {
 		cond_resched();
 
@@ -1288,8 +1288,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		/*
 		 * Note vmas containing huge pages
 		 */
-		if (is_vm_hugetlb_page(cur) || vma_is_shmem(cur))
-			non_anon_pages = true;
+		if (is_vm_hugetlb_page(cur))
+			basic_ioctls = true;
 
 		found = true;
 	}
@@ -1360,7 +1360,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		 * userland which ioctls methods are guaranteed to
 		 * succeed on this range.
 		 */
-		if (put_user(non_anon_pages ? UFFD_API_RANGE_IOCTLS_BASIC :
+		if (put_user(basic_ioctls ? UFFD_API_RANGE_IOCTLS_BASIC :
 			     UFFD_API_RANGE_IOCTLS,
 			     &user_uffdio_register->ioctls))
 			ret = -EFAULT;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
