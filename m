Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 677E1681021
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:07 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id g80so59488216pfb.3
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 03:26:07 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p1si10023358pld.270.2017.02.17.03.26.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 03:26:06 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1HBNwgZ089150
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:05 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28nefk84gr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:26:05 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 17 Feb 2017 21:26:03 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 957B23578057
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:25:59 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1HBPpPO22806726
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:25:59 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1HBPRZr025236
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 22:25:27 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 0/6] Enable parallel page migration
Date: Fri, 17 Feb 2017 16:54:47 +0530
Message-Id: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

	This patch series is base on the work posted by Zi Yan back in
November 2016 (https://lkml.org/lkml/2016/11/22/457) but includes some
amount clean up and re-organization. This series depends on THP migration
optimization patch series posted by Naoya Horiguchi on 8th November 2016
(https://lwn.net/Articles/705879/). Though Zi Yan has recently reposted
V3 of the THP migration patch series (https://lwn.net/Articles/713667/),
this series is yet to be rebased.

	Primary motivation behind this patch series is to achieve higher
bandwidth of memory migration when ever possible using multi threaded
instead of a single threaded copy. Did all the experiments using a two
socket X86 sytsem (Intel(R) Xeon(R) CPU E5-2650). All the experiments
here have same allocation size 4K * 100000 (which did not split evenly
for the 2MB huge pages). Here are the results.

Vanilla:

Moved 100000 normal pages in 247.000000 msecs 1.544412 GBs
Moved 100000 normal pages in 238.000000 msecs 1.602814 GBs
Moved 195 huge pages in 252.000000 msecs 1.513769 GBs
Moved 195 huge pages in 257.000000 msecs 1.484318 GBs

THP migration improvements:

Moved 100000 normal pages in 302.000000 msecs 1.263145 GBs
Moved 100000 normal pages in 262.000000 msecs 1.455991 GBs
Moved 195 huge pages in 120.000000 msecs 3.178914 GBs
Moved 195 huge pages in 129.000000 msecs 2.957130 GBs

THP migration improvements + Multi threaded page copy:

Moved 100000 normal pages in 1589.000000 msecs 0.240069 GBs **
Moved 100000 normal pages in 1932.000000 msecs 0.197448 GBs **
Moved 195 huge pages in 54.000000 msecs 7.064254 GBs ***
Moved 195 huge pages in 86.000000 msecs 4.435694 GBs ***


**      Using multi threaded copy can be detrimental to performance if
	used for regular pages which are way too small. But then the
	framework provides the means to use it if some kernel/driver
	caller or user application wants to use it.

***     These applications have used the new MPOL_MF_MOVE_MT flag while
	calling the system calls like mbind() and move_pages().

On POWER8 the improvements are similar when tested with a draft patch
which enables migration at PMD level. Not putting out the results here
as the kernel is not stable with the that draft patch and crashes some
times. We are working on enabling PMD level migration on POWER8 and will
test this series out thoroughly when its ready.

Patch Series Description::

Patch 1: Add new parameter to migrate_page_copy and copy_huge_page so
	 that it can differentiate between when to use single threaded
	 version (MIGRATE_ST) or multi threaded version (MIGRATE_MT).

Patch 2: Make migrate_mode types non-exclusive.

Patch 3: Add copy_pages_mthread function which does the actual multi
	 threaded copy. This involves splitting the copy work into
	 chunks, selecting threads and submitting copy jobs in the
	 work queues.

Patch 4: Add new migrate mode MIGRATE_MT to be used by higher level
	 migration functions.

Patch 5: Add new migration flag MPOL_MF_MOVE_MT for migration system
	 calls to be used in the user space.

Patch 6: Define global mt_page_copy tunable which turns on the multi
	 threaded page copy no matter what for all migrations on the
	 system.

Outstanding Issues::

Issue 1: The usefulness of the global multi threaded copy tunable i.e
	 vm.mt_page_copy. It makes sense and helps in validating the
	 framework. Should this be moved to debugfs instead ?

Issue 2: We choose nr_copythreads = 8 as maximum number of threads on
	 a node can be 8 on any architecture (Which is on POWER8 if
	 I am not missing any other arch which might have equal or
	 more number of threads per node). It just denotes max number
	 of threads and we will be adjusted based on cpumask_weight
	 value on destination node. Can we do better, suggestions ?

Issue 3: Multi threaded page migration works best with threads allocated
	 at different physical cores, not all in the same hyper-threaded
	 core. Work queues submitted jobs consume scheduler slots from
	 the given thread to execute the copy. This can interfere with
	 scheduling and affect some already running tasks on the system.
	 Should we be looking into arch topology information, scheduler
	 cpu idle details to decide on which threads to use before going
	 for multi threaded copy ? Abort multi threaded copy and fallback
	 to regular copy at times when the parameters are not good ?

Any comments, suggestions are welcome.

Zi Yan (6):
  mm/migrate: Add new mode parameter to migrate_page_copy() function
  mm/migrate: Make migrate_mode types non-exclussive
  mm/migrate: Add copy_pages_mthread function
  mm/migrate: Add new migrate mode MIGRATE_MT
  mm/migrate: Add new migration flag MPOL_MF_MOVE_MT for syscalls
  sysctl: Add global tunable mt_page_copy

 fs/aio.c                       |  2 +-
 fs/f2fs/data.c                 |  2 +-
 fs/hugetlbfs/inode.c           |  2 +-
 fs/ubifs/file.c                |  2 +-
 include/linux/highmem.h        |  2 +
 include/linux/migrate.h        |  6 ++-
 include/linux/migrate_mode.h   |  8 ++--
 include/uapi/linux/mempolicy.h |  4 +-
 kernel/sysctl.c                | 10 +++++
 mm/Makefile                    |  2 +
 mm/compaction.c                | 20 +++++-----
 mm/copy_pages_mthread.c        | 87 ++++++++++++++++++++++++++++++++++++++++++
 mm/mempolicy.c                 |  7 +++-
 mm/migrate.c                   | 81 +++++++++++++++++++++++++++------------
 14 files changed, 190 insertions(+), 45 deletions(-)
 create mode 100644 mm/copy_pages_mthread.c

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
