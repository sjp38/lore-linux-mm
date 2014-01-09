Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id BCD5C6B003D
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 09:35:09 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id b57so1363544eek.31
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 06:35:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si4081632eeo.128.2014.01.09.06.35.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 06:35:08 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/5] x86: mm: Change tlb_flushall_shift for IvyBridge
Date: Thu,  9 Jan 2014 14:34:57 +0000
Message-Id: <1389278098-27154-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1389278098-27154-1-git-send-email-mgorman@suse.de>
References: <1389278098-27154-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

There was a large performance regression that was bisected to commit 611ae8e3
(x86/tlb: enable tlb flush range support for x86). This patch simply changes
the default balance point between a local and global flush for IvyBridge.

In the interest of allowing the tests to be reproduced, this patch was
tested using mmtests 0.15 with the following configurations

	configs/config-global-dhp__tlbflush-performance
	configs/config-global-dhp__scheduler-performance
	configs/config-global-dhp__network-performance

Results are from two machines

Ivybridge   4 threads:  Intel(R) Core(TM) i3-3240 CPU @ 3.40GHz
Ivybridge   8 threads:  Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz

Page fault microbenchmark showed nothing interesting.

Ebizzy was configured to run multiple iterations and threads. Thread counts
ranged from 1 to NR_CPUS*2. For each thread count, it ran 100 iterations and
each iteration lasted 10 seconds.

Ivybridge 4 threads
                    3.13.0-rc7            3.13.0-rc7
                       vanilla           altshift-v3
Mean   1     6395.44 (  0.00%)     6789.09 (  6.16%)
Mean   2     7012.85 (  0.00%)     8052.16 ( 14.82%)
Mean   3     6403.04 (  0.00%)     6973.74 (  8.91%)
Mean   4     6135.32 (  0.00%)     6582.33 (  7.29%)
Mean   5     6095.69 (  0.00%)     6526.68 (  7.07%)
Mean   6     6114.33 (  0.00%)     6416.64 (  4.94%)
Mean   7     6085.10 (  0.00%)     6448.51 (  5.97%)
Mean   8     6120.62 (  0.00%)     6462.97 (  5.59%)

Ivybridge 8 threads
                     3.13.0-rc7            3.13.0-rc7
                        vanilla           altshift-v3
Mean   1      7336.65 (  0.00%)     7787.02 (  6.14%)
Mean   2      8218.41 (  0.00%)     9484.13 ( 15.40%)
Mean   3      7973.62 (  0.00%)     8922.01 ( 11.89%)
Mean   4      7798.33 (  0.00%)     8567.03 (  9.86%)
Mean   5      7158.72 (  0.00%)     8214.23 ( 14.74%)
Mean   6      6852.27 (  0.00%)     7952.45 ( 16.06%)
Mean   7      6774.65 (  0.00%)     7536.35 ( 11.24%)
Mean   8      6510.50 (  0.00%)     6894.05 (  5.89%)
Mean   12     6182.90 (  0.00%)     6661.29 (  7.74%)
Mean   16     6100.09 (  0.00%)     6608.69 (  8.34%)

Ebizzy hits the worst case scenario for TLB range flushing every time and
it shows for these Ivybridge CPUs at least that the default choice is a
poor on. The patch addresses the problem.

Next was a tlbflush microbenchmark written by Alex Shi at
http://marc.info/?l=linux-kernel&m=133727348217113 . It measures access
costs while the TLB is being flushed. The expectation is that if there are
always full TLB flushes that the benchmark would suffer and it benefits
from range flushing

There are 320 iterations of the test per thread count. The number of
entries is randomly selected with a min of 1 and max of 512. To ensure
a reasonably even spread of entries, the full range is broken up into 8
sections and a random number selected within that section.

iteration 1, random number between 0-64
iteration 2, random number between 64-128 etc

This is still a very weak methodology. When you do not know what are
typical ranges, random is a reasonable choice but it can be easily argued
that the opimisation was for smaller ranges and an even spread is not
representative of any workload that matters. To improve this, we'd need to
know the probability distribution of TLB flush range sizes for a set of
workloads that are considered "common", build a synthetic trace and feed
that into this benchmark. Even that is not perfect because it would not
account for the time between flushes but there are limits of what can be
reasonably done and still be doing something useful. If a representative
synthetic trace is provided then this benchmark could be revisited and
the shift values retuned.

Ivybridge 4 threads
                        3.13.0-rc7            3.13.0-rc7
                           vanilla           altshift-v3
Mean       1       10.50 (  0.00%)       10.50 (  0.03%)
Mean       2       17.59 (  0.00%)       17.18 (  2.34%)
Mean       3       22.98 (  0.00%)       21.74 (  5.41%)
Mean       5       47.13 (  0.00%)       46.23 (  1.92%)
Mean       8       43.30 (  0.00%)       42.56 (  1.72%)

Ivybridge 8 threads
                         3.13.0-rc7            3.13.0-rc7
                            vanilla           altshift-v3
Mean       1         9.45 (  0.00%)        9.36 (  0.93%)
Mean       2         9.37 (  0.00%)        9.70 ( -3.54%)
Mean       3         9.36 (  0.00%)        9.29 (  0.70%)
Mean       5        14.49 (  0.00%)       15.04 ( -3.75%)
Mean       8        41.08 (  0.00%)       38.73 (  5.71%)
Mean       13       32.04 (  0.00%)       31.24 (  2.49%)
Mean       16       40.05 (  0.00%)       39.04 (  2.51%)

For both CPUs, average access time is reduced which is good as this is
the benchmark that was used to tune the shift values in the first place
albeit it is now known *how* the benchmark was used.

The scheduler benchmarks were somewhat inconclusive. They showed gains
and losses and makes me reconsider how stable those benchmarks really
are or if something else might be interfering with the test results
recently.

Network benchmarks were inconclusive. Almost all results were flat
except for netperf-udp tests on the 4 thread machine. These results
were unstable and showed large variations between reboots. It is
unknown if this is a recent problems but I've noticed before that
netperf-udp results tend to vary.

Based on these results, changing the default for Ivybridge seems
like a logical choice.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Alex Shi <alex.shi@linaro.org>
---
 arch/x86/kernel/cpu/intel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index ea04b34..bbe1b8b 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -628,7 +628,7 @@ static void intel_tlb_flushall_shift_set(struct cpuinfo_x86 *c)
 		tlb_flushall_shift = 5;
 		break;
 	case 0x63a: /* Ivybridge */
-		tlb_flushall_shift = 1;
+		tlb_flushall_shift = 2;
 		break;
 	default:
 		tlb_flushall_shift = 6;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
