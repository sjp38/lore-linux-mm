Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA8D96B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 08:39:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u1-v6so30076wrs.18
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 05:39:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 34-v6si9944wri.145.2018.06.28.05.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 05:39:26 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5SCdFni123460
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 08:39:24 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jvwppxs74-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 08:39:23 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 28 Jun 2018 13:39:21 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH/RFC] mm: do not drop unused pages when userfaultd is running
Date: Thu, 28 Jun 2018 14:39:16 +0200
Message-Id: <20180628123916.96106-1-borntraeger@de.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-s390@vger.kernel.org
Cc: kvm@vger.kernel.org, Janosch Frank <frankja@linux.ibm.com>, David Hildenbrand <david@redhat.com>, Cornelia Huck <cohuck@redhat.com>, linux-kernel@vger.kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

KVM guests on s390 can notify the host of unused pages. This can result
in pte_unused callbacks to be true for KVM guest memory.

If a page is unused (checked with pte_unused) we might drop this page
instead of paging it. This can have side-effects on userfaultd, when the
page in question was already migrated:

The next access of that page will trigger a fault and a user fault
instead of faulting in a new and empty zero page. As QEMU does not
expect a userfault on an already migrated page this migration will fail.

The most straightforward solution is to ignore the pte_unused hint if a
userfault context is active for this VMA.

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: stable@vger.kernel.org
Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 mm/rmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 6db729dc4c50..3f3a72aa99f2 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1481,7 +1481,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				set_pte_at(mm, address, pvmw.pte, pteval);
 			}
 
-		} else if (pte_unused(pteval)) {
+		} else if (pte_unused(pteval) && !vma->vm_userfaultfd_ctx.ctx) {
 			/*
 			 * The guest indicated that the page content is of no
 			 * interest anymore. Simply discard the pte, vmscan
-- 
2.17.0
