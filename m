Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5E46B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:22 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id cn2so1745216pad.9
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 01:49:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c204si1463554pfb.128.2016.10.26.01.49.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 01:49:21 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9Q8n23l077672
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:20 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26aqktd7s4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:20 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 26 Oct 2016 02:49:19 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 0/5] mmu gather changes
Date: Wed, 26 Oct 2016 14:18:34 +0530
Message-Id: <20161026084839.27299-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Hi,

With commit e77b0852b551 ("mm/mmu_gather: track page size with mmu gather and force flush if page size change")
we added the ability to force a tlb flush when the page size change in
a mmu_gather loop. We did that by checking for a page size change
every time we added a page to mmu_gather for lazy flush/remove. This breaks when
invalidating a range that contain dax mapping. Dax pte entries are
considered special pte entries and the mmu_gather loop doesn't call
tlb_remove_page for them. Hence the page size change check doesn't work when
the invalidate range covers dax mappings.

We can also improve the current code by moving the page size change check
early and not doing it every time we add a page.

This series is not a bug fix series, because only arch that use the page
size change detail is ppc64 and we don't have dax enabled on that arch yet.
The series also include code changes that improve code comments and add new helpers
to makes it easy to follow.


Aneesh Kumar K.V (5):
  mm: Use the correct page size when removing the page
  mm: Update mmu_gather range correctly
  mm/hugetlb: add tlb_remove_hugetlb_entry for handling hugetlb pages
  mm: Add tlb_remove_check_page_size_change to track page size change
  mm: Remove the page size change check in tlb_remove_page

 arch/arm/include/asm/tlb.h     | 21 ++++++-----
 arch/ia64/include/asm/tlb.h    | 25 +++++++------
 arch/powerpc/include/asm/tlb.h | 16 ++++++++
 arch/s390/include/asm/tlb.h    | 14 ++++---
 arch/sh/include/asm/tlb.h      | 15 +++++---
 arch/um/include/asm/tlb.h      | 15 +++++---
 include/asm-generic/tlb.h      | 83 +++++++++++++++++++++++++-----------------
 mm/huge_memory.c               |  8 +++-
 mm/hugetlb.c                   |  7 +++-
 mm/madvise.c                   |  1 +
 mm/memory.c                    | 28 ++++++--------
 11 files changed, 141 insertions(+), 92 deletions(-)

-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
