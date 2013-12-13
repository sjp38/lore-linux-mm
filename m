Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id E38526B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 15:01:13 -0500 (EST)
Received: by mail-vc0-f181.google.com with SMTP id ks9so1663776vcb.12
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 12:01:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si3205797eeg.156.2013.12.13.12.01.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 12:01:12 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB range flush v2
Date: Fri, 13 Dec 2013 20:01:06 +0000
Message-Id: <1386964870-6690-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Changelog since v1
o Drop a pagetable walk that seems redundant
o Account for TLB flushes only when debugging
o Drop the patch that took number of CPUs to flush into account

ebizzy regressed between 3.4 and 3.10 while testing on a new
machine. Bisection initially found at least three problems of which the
first was commit 611ae8e3 (x86/tlb: enable tlb flush range support for
x86). Second was related to TLB flush accounting. The third was related
to ACPI cpufreq and so it was disabled for the purposes of this series.

The intent of the TLB range flush series was to preserve existing TLB
entries by flushing a range one page at a time instead of flushing the
address space. This makes a certain amount of sense if the address space
being flushed was known to have existing hot entries.  The decision on
whether to do a full mm flush or a number of single page flushes depends
on the size of the relevant TLB and how many of these hot entries would
be preserved by a targeted flush. This implicitly assumes a lot including
the following examples

o That the full TLB is in use by the task being flushed
o The TLB has hot entries that are going to be used in the near future
o The TLB has entries for the range being cached
o The cost of the per-page flushes is similar to a single mm flush
o Large pages are unimportant and can always be globally flushed
o Small flushes from workloads are very common

The first three are completely unknowable but unfortunately it is
something that is probably true of micro benchmarks designed to exercise
these paths. The fourth one depends completely on the hardware.  I've no
idea what the logic behind the large page decision was but it's certainly
wrong if automatic NUMA balancing is enabled as it frequently flushes a
single THP page. The last one is the strangest because generally only a
process that was mapping/unmapping very small regions would hit this. It's
possible it is the common case for virtualised workloads that is managing
the address space of its guests. Maybe this was the real original motivation
of the TLB range flush support for x86.

Whatever the reason, Ebizzy sees very little benefit as it discards newly
allocated memory very quickly and regressed badly on Ivybridge where
it constantly flushes ranges of 128 pages one page at a time. Earlier
machines may not have seen this problem as the balance point was at a
different location. While I'm wary of optimising for such a benchmark,
it's commonly tested and it's apparent that the worst case defaults for
Ivybridge need to be re-examined.

The following small series restores ebizzy to 3.4-era performance for the
very limited set of machines tested.

ebizzy
                      3.13.0-rc3                3.4.69            3.13.0-rc3            3.13.0-rc3
      thread             vanilla               vanilla       altershift-v2r1           nowalk-v2r7
Mean     1     7377.91 (  0.00%)     6812.38 ( -7.67%)     7784.45 (  5.51%)     7804.08 (  5.78%)
Mean     2     8262.07 (  0.00%)     8276.75 (  0.18%)     9437.49 ( 14.23%)     9450.88 ( 14.39%)
Mean     3     7895.00 (  0.00%)     8002.84 (  1.37%)     8875.38 ( 12.42%)     8914.60 ( 12.91%)
Mean     4     7658.74 (  0.00%)     7824.83 (  2.17%)     8509.10 ( 11.10%)     8399.43 (  9.67%)
Mean     5     7275.37 (  0.00%)     7678.74 (  5.54%)     8208.94 ( 12.83%)     8197.86 ( 12.68%)
Mean     6     6875.50 (  0.00%)     7597.18 ( 10.50%)     7755.66 ( 12.80%)     7807.51 ( 13.56%)
Mean     7     6722.48 (  0.00%)     7584.75 ( 12.83%)     7456.93 ( 10.93%)     7480.74 ( 11.28%)
Mean     8     6559.55 (  0.00%)     7591.51 ( 15.73%)     6879.01 (  4.87%)     6881.86 (  4.91%)
Stddev   1       50.55 (  0.00%)       78.05 (-54.41%)       44.70 ( 11.58%)       39.22 ( 22.41%)
Stddev   2       37.98 (  0.00%)      176.92 (-365.76%)       92.40 (-143.26%)      184.32 (-385.24%)
Stddev   3       55.76 (  0.00%)      126.02 (-126.00%)       99.79 (-78.95%)       32.97 ( 40.87%)
Stddev   4       64.64 (  0.00%)      117.09 (-81.13%)      124.23 (-92.17%)      212.67 (-229.00%)
Stddev   5      131.53 (  0.00%)       92.86 ( 29.39%)      108.07 ( 17.83%)      101.05 ( 23.17%)
Stddev   6      109.92 (  0.00%)       74.87 ( 31.89%)      179.26 (-63.08%)      202.56 (-84.28%)
Stddev   7      124.32 (  0.00%)       72.25 ( 41.88%)      124.46 ( -0.12%)      128.52 ( -3.38%)
Stddev   8       60.98 (  0.00%)       60.98 ( -0.00%)       62.31 ( -2.19%)       63.73 ( -4.51%)

Machine was a single socket machine with number of threads tested ranging
from 1 to NR_CPUS. For each thread, there were 100 iterations and the
reported mean and stddev was based on those iterations. The results are
unfortunately noisy but many of the gains are well outside 1 standard
deviation. The test is dominated by the address space allocation, page
allocation and zeroing of the pages with the flush being a relatively
small component of the workload.

It was suggested to remove the per-family TLB shifts entirely but the
figures must have been based on some testing by someone somewhere using a
representative workload. Details on that would be nice but in the meantime
I only altered IvyBridge as the balance point happens to be where ebizzy
becomes an adverse workload.

 arch/x86/include/asm/tlbflush.h    |  6 ++---
 arch/x86/kernel/cpu/intel.c        |  2 +-
 arch/x86/kernel/cpu/mtrr/generic.c |  4 +--
 arch/x86/mm/tlb.c                  | 52 ++++++++++----------------------------
 include/linux/vm_event_item.h      |  4 +--
 include/linux/vmstat.h             |  8 ++++++
 6 files changed, 29 insertions(+), 47 deletions(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
