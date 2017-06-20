Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE3016B02FD
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s65so121312416pfi.14
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 23:21:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e67si9718408pfg.409.2017.06.19.23.21.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 23:21:15 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5K6J43G101028
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:14 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b69tvqeuh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:14 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 20 Jun 2017 07:21:11 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 5/7] userfaultfd: shmem: wire up shmem_mfill_zeropage_pte
Date: Tue, 20 Jun 2017 09:20:50 +0300
In-Reply-To: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1497939652-16528-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

For shmem VMAs we can use shmem_mfill_zeropage_pte for UFFDIO_ZEROPAGE

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/userfaultfd.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 48c015c..8119270 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -389,11 +389,13 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
 			err = mfill_zeropage_pte(dst_mm, dst_pmd,
 						 dst_vma, dst_addr);
 	} else {
-		err = -EINVAL; /* if zeropage is true return -EINVAL */
-		if (likely(!zeropage))
+		if (!zeropage)
 			err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd,
 						     dst_vma, dst_addr,
 						     src_addr, page);
+		else
+			err = shmem_mfill_zeropage_pte(dst_mm, dst_pmd,
+						       dst_vma, dst_addr);
 	}
 
 	return err;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
