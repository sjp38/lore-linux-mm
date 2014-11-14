Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 40EAC6B00CC
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 08:33:10 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id r20so5118305wiv.5
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 05:33:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p1si3708226wiy.53.2014.11.14.05.33.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 05:33:09 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/7] Replace _PAGE_NUMA with PAGE_NONE protections
Date: Fri, 14 Nov 2014 13:32:59 +0000
Message-Id: <1415971986-16143-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

This is follow up from the "pipe/page fault oddness" thread.

Automatic NUMA balancing depends on being able to protect PTEs to trap a
fault and gather reference locality information. Very broadly speaking it
would mark PTEs as not present and use another bit to distinguish between
NUMA hinting faults and other types of faults. It was universally loved
by everybody and caused no problems whatsoever. That last sentence might
be a lie.

This series is very heavily based on patches from Linus and Aneesh to
replace the existing PTE/PMD NUMA helper functions with normal change
protections. I did alter and add parts of it but I consider them relatively
minor contributions. Note that the signed-offs here need addressing. I
couldn't use "From" or Signed-off-by from the original authors as the
patches had to be broken up and they were never signed off. I expect the
two people involved will just stick their signed-off-by on it.

This has received *no* testing at all on ppc64. I'm depending on Aneesh
for that. I did test on a 4-node x86-64 machine with just the basics --
specjbb2005 on single and multi JVM workloads both configured for short
runs and autonumabench. In most cases I'm leaving out detail as it's not
that interesting.

specjbb single JVM: There was negligible performance difference that was
	well within the noise. Overall performance and system activity was
	roughly comparable. Memory node balance was roughly similar. System
	CPU usage is very slightly elevated

specjbb multi JVM: Negligible performance difference, system CPU usage is
	slightly elevated but roughly similar system activity

autonumabench: This was all over the place and about all that can be
	reasonably concluded is that it's different but not necessarily
	better or worse. I'll go into more detail on this one

autonumabench
                                          3.18.0-rc4            3.18.0-rc4
                                             vanilla         protnone-v1r7
Time User-NUMA01                  32806.01 (  0.00%)    33049.91 ( -0.74%)
Time User-NUMA01_THEADLOCAL       23910.28 (  0.00%)    22874.91 (  4.33%)
Time User-NUMA02                   3176.85 (  0.00%)     3116.52 (  1.90%)
Time User-NUMA02_SMT               1600.06 (  0.00%)     1645.56 ( -2.84%)
Time System-NUMA01                  719.07 (  0.00%)     1065.31 (-48.15%)
Time System-NUMA01_THEADLOCAL       916.26 (  0.00%)      365.23 ( 60.14%)
Time System-NUMA02                   20.92 (  0.00%)       17.42 ( 16.73%)
Time System-NUMA02_SMT                8.76 (  0.00%)        5.20 ( 40.64%)
Time Elapsed-NUMA01                 728.27 (  0.00%)      759.89 ( -4.34%)
Time Elapsed-NUMA01_THEADLOCAL      589.15 (  0.00%)      560.95 (  4.79%)
Time Elapsed-NUMA02                  81.20 (  0.00%)       84.78 ( -4.41%)
Time Elapsed-NUMA02_SMT              80.49 (  0.00%)       85.29 ( -5.96%)
Time CPU-NUMA01                    4603.00 (  0.00%)     4489.00 (  2.48%)
Time CPU-NUMA01_THEADLOCAL         4213.00 (  0.00%)     4142.00 (  1.69%)
Time CPU-NUMA02                    3937.00 (  0.00%)     3696.00 (  6.12%)
Time CPU-NUMA02_SMT                1998.00 (  0.00%)     1935.00 (  3.15%)

System CPU usage of NUMA01 is worse but it's an adverse workload on this
machine so I'm reluctant to conclude that it's a problem that matters. On
the other workloads that are sensible on this machine, system CPU usage
is great.  Overall time to complete the benchmark is comparable

          3.18.0-rc4  3.18.0-rc4
             vanillaprotnone-v1r7
User        61493.38    60687.08
System       1665.17     1453.32
Elapsed      1480.79     1492.53

The NUMA stats are as follows

NUMA alloc hit                 4739774     4618019
NUMA alloc miss                      0           0
NUMA interleave hit                  0           0
NUMA alloc local               4664980     4589938
NUMA base PTE updates        556489407   589530598
NUMA huge PMD updates          1086000     1150114
NUMA page range updates     1112521407  1178388966
NUMA hint faults               1538964     1427999
NUMA hint local faults          835871      831469
NUMA hint local percent             54          58
NUMA pages migrated            7329212    18992993
AutoNUMA cost                   11729%      11627%

The NUMA pages migrated look terrible but when I looked at a graph of the
activity over time I see that the massive spike in migration activity was
during NUMA01. This correlates with high system CPU usage and could be simply
down to bad luck but any modifications that affect that workload would be
related to scan rates and migrations, not the protection mechanism. For
all other workloads, migration activity was comparable.

Based on these results I concluded that performance-wise this series
is similar but from a maintenance perspective it's probably better. I
suspect that system CPU usage may be slightly higher overall but nowhere
near enough to justify a lot of complexity.

 arch/powerpc/include/asm/pgtable.h    |  53 ++----------
 arch/powerpc/include/asm/pte-common.h |   5 --
 arch/powerpc/include/asm/pte-hash64.h |   6 --
 arch/powerpc/kvm/book3s_hv_rm_mmu.c   |   2 +-
 arch/powerpc/mm/fault.c               |   5 --
 arch/powerpc/mm/gup.c                 |   4 +-
 arch/x86/include/asm/pgtable.h        |  46 +++++-----
 arch/x86/include/asm/pgtable_64.h     |   5 --
 arch/x86/include/asm/pgtable_types.h  |  41 +--------
 arch/x86/mm/gup.c                     |   4 +-
 include/asm-generic/pgtable.h         | 152 ++--------------------------------
 include/linux/swapops.h               |   2 +-
 include/uapi/linux/mempolicy.h        |   2 +-
 mm/gup.c                              |   8 +-
 mm/huge_memory.c                      |  53 ++++++------
 mm/memory.c                           |  25 ++++--
 mm/mempolicy.c                        |   2 +-
 mm/migrate.c                          |   2 +-
 mm/mprotect.c                         |  44 +++++-----
 mm/pgtable-generic.c                  |   2 -
 20 files changed, 108 insertions(+), 355 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
