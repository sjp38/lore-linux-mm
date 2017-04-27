Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E56D46B039F
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:33 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y22so2188978wry.1
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:53:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j80si3662348wmj.45.2017.04.27.08.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 08:53:32 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3RFooKe120089
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:30 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a3had7ucn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:30 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 16:53:28 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v3 16/17] mm: protect madvise vs speculative pf
Date: Thu, 27 Apr 2017 17:52:55 +0200
In-Reply-To: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1493308376-23851-17-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

This is an attempt to protect madvise's effect against the speculative
page fault handler.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/madvise.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 0e3828eae9f8..f91b64564571 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -132,8 +132,9 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
+	write_seqcount_begin(&vma->vm_sequence);
 	vma->vm_flags = new_flags;
-
+	write_seqcount_end(&vma->vm_sequence);
 out:
 	if (error == -ENOMEM)
 		error = -EAGAIN;
@@ -403,9 +404,11 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
 		.private = tlb,
 	};
 
+	write_seqcount_begin(&vma->vm_sequence);
 	tlb_start_vma(tlb, vma);
 	walk_page_range(addr, end, &free_walk);
 	tlb_end_vma(tlb, vma);
+	write_seqcount_end(&vma->vm_sequence);
 }
 
 static int madvise_free_single_vma(struct vm_area_struct *vma,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
