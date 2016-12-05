Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3144C6B025E
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 04:18:01 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id b202so541684832oii.3
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:18:01 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20067.outbound.protection.outlook.com. [40.107.2.67])
        by mx.google.com with ESMTPS id t207si6651206oie.268.2016.12.05.01.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 05 Dec 2016 01:18:00 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH v3 0/4]  mm: fix the "counter.sh" failure for libhugetlbfs 
Date: Mon, 5 Dec 2016 17:17:07 +0800
Message-ID: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, vbabka@suze.cz, Huang Shijie <shijie.huang@arm.com>

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

   The counter.sh is just a wrapper for counter.c.
   You can find them in:
       https://github.com/libhugetlbfs/libhugetlbfs/blob/master/tests/counters.c
       https://github.com/libhugetlbfs/libhugetlbfs/blob/master/tests/counters.sh

   The error log shows below:

   ----------------------------------------------------------
        ...........................................
	LD_PRELOAD=libhugetlbfs.so shmoverride_unlinked (32M: 64):	PASS
	LD_PRELOAD=libhugetlbfs.so HUGETLB_SHM=yes shmoverride_unlinked (32M: 64):	PASS
	quota.sh (32M: 64):	PASS
	counters.sh (32M: 64):	FAIL mmap failed: Invalid argument
	********** TEST SUMMARY
	*                      32M           
	*                      32-bit 64-bit 
	*     Total testcases:     0     87   
	*             Skipped:     0      0   
	*                PASS:     0     86   
	*                FAIL:     0      1   
	*    Killed by signal:     0      0   
	*   Bad configuration:     0      0   
	*       Expected FAIL:     0      0   
	*     Unexpected PASS:     0      0   
	* Strange test result:     0      0   
	**********
   ----------------------------------------------------------

   The failure is caused by:
    1) kernel fails to allocate a gigantic page for the surplus case.
       And the gather_surplus_pages() will return NULL in the end.

    2) The condition checks for some functions are wrong:
        return_unused_surplus_pages()
        nr_overcommit_hugepages_store()
        hugetlb_overcommit_handler()
   
   This patch set adds support for gigantic surplus hugetlb pages,
   allowing the counter.sh unit test to pass. 
   Test this patch set with Juno-r1 board.

   	
v2 -- > v3:
   1.) In patch 2, change argument "no_init" to "do_prep" 
   2.) In patch 3, also change alloc_fresh_huge_page().
       In the v2, this patch only changes the alloc_fresh_gigantic_page().  
   3.) Merge old patch #4,#5 into the last one.    
   4.) Follow Babka's suggestion, do the NULL check for @mask.
   5.) others.


v1 -- > v2:
   1.) fix the compiler error in X86.
   2.) add new patches for NUMA.
       The patch #2 ~ #5 are new patches.

Huang Shijie (4):
  mm: hugetlb: rename some allocation functions
  mm: hugetlb: add a new parameter for some functions
  mm: hugetlb: change the return type for some functions
  mm: hugetlb: support gigantic surplus pages

 include/linux/mempolicy.h |   8 +++
 mm/hugetlb.c              | 146 +++++++++++++++++++++++++++++++++++-----------
 mm/mempolicy.c            |  44 ++++++++++++++
 3 files changed, 163 insertions(+), 35 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
