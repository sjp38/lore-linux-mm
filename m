Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8686F6B000A
	for <linux-mm@kvack.org>; Wed, 23 May 2018 21:00:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e7-v6so13903705pfi.8
        for <linux-mm@kvack.org>; Wed, 23 May 2018 18:00:29 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 203-v6si19885295pfz.160.2018.05.23.18.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 18:00:28 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -V2 -mm 0/4] mm, huge page: Copy target sub-page last when copy huge page
Date: Thu, 24 May 2018 08:58:47 +0800
Message-Id: <20180524005851.4079-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>

From: Huang Ying <ying.huang@intel.com>

Huge page helps to reduce TLB miss rate, but it has higher cache
footprint, sometimes this may cause some issue.  For example, when
copying huge page on x86_64 platform, the cache footprint is 4M.  But
on a Xeon E5 v3 2699 CPU, there are 18 cores, 36 threads, and only 45M
LLC (last level cache).  That is, in average, there are 2.5M LLC for
each core and 1.25M LLC for each thread.

If the cache contention is heavy when copying the huge page, and we
copy the huge page from the begin to the end, it is possible that the
begin of huge page is evicted from the cache after we finishing
copying the end of the huge page.  And it is possible for the
application to access the begin of the huge page after copying the
huge page.

In commit c79b57e462b5d ("mm: hugetlb: clear target sub-page last when
clearing huge page"), to keep the cache lines of the target subpage
hot, the order to clear the subpages in the huge page in
clear_huge_page() is changed to clearing the subpage which is furthest
from the target subpage firstly, and the target subpage last.  The
similar order changing helps huge page copying too.  That is
implemented in this patchset.

The patchset is a generic optimization which should benefit quite some
workloads, not for a specific use case.  To demonstrate the
performance benefit of the patchset, we have tested it with
vm-scalability run on transparent huge page.

With this patchset, the throughput increases ~16.6% in vm-scalability
anon-cow-seq test case with 36 processes on a 2 socket Xeon E5 v3 2699
system (36 cores, 72 threads).  The test case set
/sys/kernel/mm/transparent_hugepage/enabled to be always, mmap() a big
anonymous memory area and populate it, then forked 36 child processes,
each writes to the anonymous memory area from the begin to the end, so
cause copy on write.  For each child process, other child processes
could be seen as other workloads which generate heavy cache pressure.
At the same time, the IPC (instruction per cycle) increased from 0.63
to 0.78, and the time spent in user space is reduced ~7.2%.

Changelog:

V2:

- As suggested by Mike Kravetz, put subpage order algorithm into a
  separate patch to avoid code duplication and reduce maintenance
  overhead.

- Add hugetlbfs support

Best Regards,
Huang, Ying
