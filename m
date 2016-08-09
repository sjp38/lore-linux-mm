Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C16066B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:38:12 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id pp5so30850224pac.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:38:12 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id r71si1655316pfb.169.2016.08.09.09.38.11
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 09:38:11 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [RFC 00/11] THP swap: Delay splitting THP during swapping out
Date: Tue,  9 Aug 2016 09:37:42 -0700
Message-Id: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>

From: Huang Ying <ying.huang@intel.com>

This patchset is based on 8/4 head of mmotm/master.

This is the first step for Transparent Huge Page (THP) swap support.
The plan is to delaying splitting THP step by step and avoid splitting
THP finally during THP swapping out and swapping in.

The advantages of THP swap support are:

- Batch swap operations for THP to reduce lock acquiring/releasing,
  including allocating/freeing swap space, adding/deleting to/from swap
  cache, and writing/reading swap space, etc.

- THP swap space read/write will be 2M sequence IO.  It is particularly
  helpful for swap read, which usually are 4k random IO.

- It will help memory fragmentation, especially when THP is heavily used
  by the applications.  2M continuous pages will be free up after THP
  swapping out.

As the first step, in this patchset, the splitting huge page is
delayed from almost the first step of swapping out to after allocating
the swap space for THP and adding the THP into swap cache.  This will
reduce lock acquiring/releasing for locks used for swap space and swap
cache management.

With the patchset, the swap out bandwidth improved 12.1% in
vm-scalability swap-w-seq test case with 16 processes on a Xeon E5 v3
system.  To test sequence swap out, the test case uses 16 processes
sequentially allocate and write to anonymous pages until RAM and part of
the swap device is used up.

The detailed compare result is as follow,

base             base+patchset
---------------- -------------------------- 
         %stddev     %change         %stddev
             \          |                \  
   1118821 A+-  0%     +12.1%    1254241 A+-  1%  vmstat.swap.so
   2460636 A+-  1%     +10.6%    2720983 A+-  1%  vm-scalability.throughput
    308.79 A+-  1%      -7.9%     284.53 A+-  1%  vm-scalability.time.elapsed_time
      1639 A+-  4%    +232.3%       5446 A+-  1%  meminfo.SwapCached
      0.70 A+-  3%      +8.7%       0.77 A+-  5%  perf-stat.ipc
      9.82 A+-  8%     -31.6%       6.72 A+-  2%  perf-profile.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
