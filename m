Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6832802FE
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 14:03:51 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 80so142489897uas.8
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:03:51 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w85si7416173vke.247.2017.07.27.11.03.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 11:03:50 -0700 (PDT)
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: [RFC PATCH 0/1] oom support for reclaiming of hugepages
Date: Thu, 27 Jul 2017 14:02:35 -0400
Message-Id: <20170727180236.6175-1-Liam.Howlett@Oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, mike.kravetz@Oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, punit.agrawal@arm.com, arnd@arndb.de, gerald.schaefer@de.ibm.com, aarcange@redhat.com, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mingo@kernel.org, kirill.shutemov@linux.intel.com, vdavydov.dev@gmail.com, willy@infradead.org

I'm looking for comments on how to avoid the failure scenario where a correctly
configured system fails to boot after taking corrective action when a memory
module goes bad.  Right now if there is a memory event that causes a system
reboot and the UEFI to remove the memory from the memory pool, it may result in
Linux not having enough memory to boot due to the huge page reserve.

The patch in its current state will reclaim hugepages if they are free
regardless of on boot or not - which may not be desirable, or maybe it is?
I've looked through how select_bad_process works and do not see a clean way to
hook in to this function when the victim is not a task.

I also could not find a good place to add the CONFIG_HUGETLB_PAGE_OOM.
Obviously that would need to go somewhere sane.

Liam R. Howlett (1):
  mm/hugetlb mm/oom_kill:  Add support for reclaiming hugepages on OOM
    events.

 include/linux/hugetlb.h |  1 +
 mm/hugetlb.c            | 35 +++++++++++++++++++++++++++++++++++
 mm/oom_kill.c           |  8 ++++++++
 3 files changed, 44 insertions(+)

-- 
2.13.0.90.g1eb437020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
