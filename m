Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0B05F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:02:28 -0400 (EDT)
Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id n38K2PuT006315
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 21:02:26 +0100
Received: from wf-out-1314.google.com (wfc28.prod.google.com [10.142.3.28])
	by zps35.corp.google.com with ESMTP id n38K1mlZ020745
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 13:02:24 -0700
Received: by wf-out-1314.google.com with SMTP id 28so241908wfc.26
        for <linux-mm@kvack.org>; Wed, 08 Apr 2009 13:02:24 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 8 Apr 2009 13:02:23 -0700
Message-ID: <604427e00904081302p7aad170bu5ff0702415455f7@mail.gmail.com>
Subject: [PATCH][0/2]page_fault retry with NOPAGE_RETRY
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>, torvalds@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

changelog[v3]:
- applied fixes and cleanups from Wu Fengguang.
filemap VM_FAULT_RETRY fixes
[PATCH 01/14] mm: fix find_lock_page_retry() return value parsing
[PATCH 02/14] mm: fix major/minor fault accounting on retried fault
[PATCH 04/14] mm: reduce duplicate page fault code
[PATCH 05/14] readahead: account mmap_miss for VM_FAULT_RETRY

- split the patch into two parts. first part includes FAULT_FLAG_RETRY
  support with no current user change. second part includes individual
  per-architecture cleanups that enable FAULT_FLAG_RETRY.
  currently there are mainly two users for handle_mm_fault, we enable
  FAULT_FLAG_RETRY for actual fault handler and leave get_user_pages
  unchanged.

Benchmarks:
posted on [V1]:
case 1. one application has a high count of threads each faulting in
different pages of a hugefile. Benchmark indicate that this double data
structure walking in case of major fault results in << 1% performance hit.

case 2. add another thread in the above application which in a tight loop
of
mmap()/munmap(). Here we measure loop count in the new thread while other
threads doing the same amount of work as case one. we got << 3% performance
hit on the Complete Time(benchmark value for case one) and 10% performance
improvement on the mmap()/munmap() counter.

This patch helps a lot in cases we have writer which is waitting behind all
readers, so it could execute much faster.

some new test results from Wufengguang:
Just tested the sparse-random-read-on-sparse-file case, and found the
performance impact to be 0.4% (8.706s vs 8.744s). Kind of acceptable.

without FAULT_FLAG_RETRY:
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.28s user
5.39s system 99% cpu 8.692 total
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.17s user
5.54s system 99% cpu 8.742 total
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.18s user
5.48s system 99% cpu 8.684 total

FAULT_FLAG_RETRY:
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.18s user
5.63s system 99% cpu 8.825 total
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.22s user
5.47s system 99% cpu 8.718 total
iotrace.rb --load stride-100 --mplay /mnt/btrfs-ram/sparse  3.13s user
5.55s system 99% cpu 8.690 total

In the above faked workload, the mmap read page offsets are loaded from
stride-100 and performed on /mnt/btrfs-ram/sparse, which are created by:

	seq 0 100 1000000 > stride-100
	dd if=/dev/zero of=/mnt/btrfs-ram/sparse bs=1M count=1 seek=1024000

Signed-off-by: Ying Han <yinghan@google.com>
	       Mike Waychison <mikew@google.com>

 arch/x86/mm/fault.c |   20 ++++++++++++++
 include/linux/fs.h  |    2 +-
 include/linux/mm.h  |    2 +
 mm/filemap.c        |   72 ++++++++++++++++++++++++++++++++++++++++++++++++--
 mm/memory.c         |   33 +++++++++++++++++------
 5 files changed, 116 insertions(+), 13 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
