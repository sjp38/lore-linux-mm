Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0DF6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 08:28:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x20so1449905wmc.0
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 05:28:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 65si2083073edb.361.2018.04.05.05.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 05:28:03 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w35CKURw113698
	for <linux-mm@kvack.org>; Thu, 5 Apr 2018 08:28:02 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h5hv9d9e2-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Apr 2018 08:28:02 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <imbrenda@linux.vnet.ibm.com>;
	Thu, 5 Apr 2018 13:28:00 +0100
From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: [PATCH v1 1/1] mm/ksm: fix inconsistent accounting of zero pages
Date: Thu,  5 Apr 2018 14:27:54 +0200
Message-Id: <1522931274-15552-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, minchan@kernel.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, hughd@google.com, borntraeger@de.ibm.com, gerald.schaefer@de.ibm.com, stable@vger.kernel.org

When using KSM with use_zero_pages, we replace anonymous pages
containing only zeroes with actual zero pages, which are not anonymous.
We need to do proper accounting of the mm counters, otherwise we will
get wrong values in /proc and a BUG message in dmesg when tearing down
the mm.

Fixes: e86c59b1b1 ("mm/ksm: improve deduplication of zero pages with colouring")

Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
---
 mm/ksm.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/ksm.c b/mm/ksm.c
index 293721f..2d6b352 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1131,6 +1131,13 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	} else {
 		newpte = pte_mkspecial(pfn_pte(page_to_pfn(kpage),
 					       vma->vm_page_prot));
+		/*
+		 * We're replacing an anonymous page with a zero page, which is
+		 * not anonymous. We need to do proper accounting otherwise we
+		 * will get wrong values in /proc, and a BUG message in dmesg
+		 * when tearing down the mm.
+		 */
+		dec_mm_counter(mm, MM_ANONPAGES);
 	}
 
 	flush_cache_page(vma, addr, pte_pfn(*ptep));
-- 
2.7.4
