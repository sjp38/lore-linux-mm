Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD3D06B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 02:08:40 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id l139so203760661ywe.5
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 23:08:40 -0800 (PST)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40049.outbound.protection.outlook.com. [40.107.4.49])
        by mx.google.com with ESMTPS id p51si9338950otb.286.2016.11.13.23.08.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 13 Nov 2016 23:08:39 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH v2 0/6] mm: fix the "counter.sh" failure for libhugetlbfs 
Date: Mon, 14 Nov 2016 15:07:33 +0800
Message-ID: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, Huang Shijie <shijie.huang@arm.com>

(1) Background
   For the arm64, the hugetlb page size can be 32M (PMD + Contiguous bit).
   In the 4K page environment, the max page order is 10 (max_order - 1),
   so 32M page is the gigantic page.    

   The arm64 MMU supports a Contiguous bit which is a hint that the TTE
   is one of a set of contiguous entries which can be cached in a single
   TLB entry.  Please refer to the arm64v8 mannul :
       DDI0487A_f_armv8_arm.pdf (in page D4-1811)

(2) The bug   
   After I tested the libhugetlbfs, I found the test case "counter.sh"
   will fail with the gigantic page (32M page in arm64 board).

   This patch set adds support for gigantic surplus hugetlb pages,
   allowing the counter.sh unit test to pass.   

v1 -- > v2:
   1.) fix the compiler error in X86.
   2.) add new patches for NUMA.
       The patch #2 ~ #5 are new patches.

Huang Shijie (6):
  mm: hugetlb: rename some allocation functions
  mm: hugetlb: add a new parameter for some functions
  mm: hugetlb: change the return type for alloc_fresh_gigantic_page
  mm: mempolicy: intruduce a helper huge_nodemask()
  mm: hugetlb: add a new function to allocate a new gigantic page
  mm: hugetlb: support gigantic surplus pages

 include/linux/mempolicy.h |   8 +++
 mm/hugetlb.c              | 128 ++++++++++++++++++++++++++++++++++++----------
 mm/mempolicy.c            |  20 ++++++++
 3 files changed, 130 insertions(+), 26 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
