Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id DE5E66B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 06:24:36 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id a1so22302185wgh.25
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 03:24:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lj11si25807020wic.21.2014.12.04.03.24.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 03:24:35 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/10] Replace _PAGE_NUMA with PAGE_NONE protections v4
Date: Thu,  4 Dec 2014 11:24:23 +0000
Message-Id: <1417692273-27170-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Mel Gorman <mgorman@suse.de>

There are no functional changes here and I kept the mmotm-20141119 baseline
as that is what got tested but it rebases cleanly to current mmotm. The
series makes architectural changes but splitting this on a per-arch basis
would cause bisect-related brain damage. I'm hoping this can go through
Andrew without conflict. It's been tested by myself (standard tests),
Aneesh (ppc64) and Sasha (trinity) so there is some degree of confidence
that it's ok.

Changelog since V3
o Minor comment update						(benh)
o Add ack'ed bys

Changelog since V2
o Rename *_protnone_numa to _protnone and extend docs		(linus)
o Rebase to mmotm-20141119 for pre-merge testing		(mel)
o Conver WARN_ON to VM_WARN_ON					(aneesh)

Changelog since V1
o ppc64 paranoia checks and clarifications			(aneesh)
o Fix trinity regression (hopefully)
o Reduce unnecessary TLB flushes				(mel)

Automatic NUMA balancing depends on being able to protect PTEs to trap a
fault and gather reference locality information. Very broadly speaking it
would mark PTEs as not present and use another bit to distinguish between
NUMA hinting faults and other types of faults. It was universally loved
by everybody and caused no problems whatsoever. That last sentence might
be a lie.

This series is very heavily based on patches from Linus and Aneesh to
replace the existing PTE/PMD NUMA helper functions with normal change
protections. I did alter and add parts of it but I consider them relatively
minor contributions. At their suggestion, acked-bys are in there but I've
no problem converting them to Signed-off-by if requested.

AFAIK, this has received no testing on ppc64 and I'm depending on Aneesh for
that. I tested trinity under kvm-tool and passed and ran a few other basic
tests. At the time of writing, only the short-lived tests have completed
but testing of V2 indicated that long-term testing had no surprises. In
most cases I'm leaving out detail as it's not that interesting.

specjbb single JVM: There was negligible performance difference in the
	benchmark itself for short runs. However, system activity is
	higher and interrupts are much higher over time -- possibly TLB
	flushes. Migrations are also higher. Overall, this is more overhead
	but considering the problems faced with the old approach I think
	we just have to suck it up and find another way of reducing the
	overhead.

specjbb multi JVM: Negligible performance difference to the actual benchmark
	but like the single JVM case, the system overhead is noticeably
	higher.  Again, interrupts are a major factor.

autonumabench: This was all over the place and about all that can be
	reasonably concluded is that it's different but not necessarily
	better or worse.

autonumabench
                                     3.18.0-rc5            3.18.0-rc5
                                 mmotm-20141119         protnone-v3r3
User    NUMA01               32380.24 (  0.00%)    21642.92 ( 33.16%)
User    NUMA01_THEADLOCAL    22481.02 (  0.00%)    22283.22 (  0.88%)
User    NUMA02                3137.00 (  0.00%)     3116.54 (  0.65%)
User    NUMA02_SMT            1614.03 (  0.00%)     1543.53 (  4.37%)
System  NUMA01                 322.97 (  0.00%)     1465.89 (-353.88%)
System  NUMA01_THEADLOCAL       91.87 (  0.00%)       49.32 ( 46.32%)
System  NUMA02                  37.83 (  0.00%)       14.61 ( 61.38%)
System  NUMA02_SMT               7.36 (  0.00%)        7.45 ( -1.22%)
Elapsed NUMA01                 716.63 (  0.00%)      599.29 ( 16.37%)
Elapsed NUMA01_THEADLOCAL      553.98 (  0.00%)      539.94 (  2.53%)
Elapsed NUMA02                  83.85 (  0.00%)       83.04 (  0.97%)
Elapsed NUMA02_SMT              86.57 (  0.00%)       79.15 (  8.57%)
CPU     NUMA01                4563.00 (  0.00%)     3855.00 ( 15.52%)
CPU     NUMA01_THEADLOCAL     4074.00 (  0.00%)     4136.00 ( -1.52%)
CPU     NUMA02                3785.00 (  0.00%)     3770.00 (  0.40%)
CPU     NUMA02_SMT            1872.00 (  0.00%)     1959.00 ( -4.65%)

System CPU usage of NUMA01 is worse but it's an adverse workload on this
machine so I'm reluctant to conclude that it's a problem that matters. On
the other workloads that are sensible on this machine, system CPU usage
is great.  Overall time to complete the benchmark is comparable

          3.18.0-rc5  3.18.0-rc5
        mmotm-20141119protnone-v3r3
User        59612.50    48586.44
System        460.22     1537.45
Elapsed      1442.20     1304.29

NUMA alloc hit                 5075182     5743353
NUMA alloc miss                      0           0
NUMA interleave hit                  0           0
NUMA alloc local               5075174     5743339
NUMA base PTE updates        637061448   443106883
NUMA huge PMD updates          1243434      864747
NUMA page range updates     1273699656   885857347
NUMA hint faults               1658116     1214277
NUMA hint local faults          959487      754113
NUMA hint local percent             57          62
NUMA pages migrated            5467056    61676398

The NUMA pages migrated look terrible but when I looked at a graph of the
activity over time I see that the massive spike in migration activity was
during NUMA01. This correlates with high system CPU usage and could be simply
down to bad luck but any modifications that affect that workload would be
related to scan rates and migrations, not the protection mechanism. For
all other workloads, migration activity was comparable.

Overall, headline performance figures are comparable but the overhead
is higher, mostly in interrupts. To some extent, higher overhead from
this approach was anticipated but not to this degree. It's going to be
necessary to reduce this again with a separate series in the future. It's
still worth going ahead with this series though as it's likely to avoid
constant headaches with Xen and is probably easier to maintain.

 arch/powerpc/include/asm/pgtable.h    |  54 ++----------
 arch/powerpc/include/asm/pte-common.h |   5 --
 arch/powerpc/include/asm/pte-hash64.h |   6 --
 arch/powerpc/kvm/book3s_hv_rm_mmu.c   |   2 +-
 arch/powerpc/mm/copro_fault.c         |   8 +-
 arch/powerpc/mm/fault.c               |  25 ++----
 arch/powerpc/mm/pgtable.c             |  11 ++-
 arch/powerpc/mm/pgtable_64.c          |   3 +-
 arch/x86/include/asm/pgtable.h        |  46 +++++-----
 arch/x86/include/asm/pgtable_64.h     |   5 --
 arch/x86/include/asm/pgtable_types.h  |  41 +--------
 arch/x86/mm/gup.c                     |   4 +-
 include/asm-generic/pgtable.h         | 153 ++--------------------------------
 include/linux/migrate.h               |   4 -
 include/linux/swapops.h               |   2 +-
 include/uapi/linux/mempolicy.h        |   2 +-
 mm/gup.c                              |  10 +--
 mm/huge_memory.c                      |  50 ++++++-----
 mm/memory.c                           |  18 ++--
 mm/mempolicy.c                        |   2 +-
 mm/migrate.c                          |   8 +-
 mm/mprotect.c                         |  48 +++++------
 mm/pgtable-generic.c                  |   2 -
 23 files changed, 135 insertions(+), 374 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
