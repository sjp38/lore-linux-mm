Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE526B007D
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:19:56 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so8176271wiw.14
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 02:19:55 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5si2847523wjz.59.2014.11.20.02.19.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 02:19:55 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/10] Replace _PAGE_NUMA with PAGE_NONE protections v2
Date: Thu, 20 Nov 2014 10:19:40 +0000
Message-Id: <1416478790-27522-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

V1 failed while running under kvm-tools very quickly and a second report
indicated that it happens on bare metal as well. This version survived
an overnight run of trinity running under kvm-tools here but verification
from Sasha would be appreciated.

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
tests. In most cases I'm leaving out detail as it's not that interesting.

specjbb single JVM: There was negligible performance difference in the
	benchmark itself for short and long runs. However, system activity
	is higher and interrupts are much higher over time -- possibly
	TLB flushes. Migrations are also higher. Overall, this is more
	overhead but considering the problems faced with the old approach
	I think we just have to suck it up and find another way of reducing
	the overhead.

specjbb multi JVM: Negligible performance difference to the actual benchmarm
	but like the single JVM case, the system overhead is noticably
	higher.  Again, interrupts are a major factor.

autonumabench: This was all over the place and about all that can be
	reasonably concluded is that it's different but not necessarily
	better or worse.

autonumabench
                                     3.18.0-rc4            3.18.0-rc4
                                        vanilla         protnone-v2r5
User    NUMA01               32806.01 (  0.00%)    20250.67 ( 38.27%)
User    NUMA01_THEADLOCAL    23910.28 (  0.00%)    22734.37 (  4.92%)
User    NUMA02                3176.85 (  0.00%)     3082.68 (  2.96%)
User    NUMA02_SMT            1600.06 (  0.00%)     1547.08 (  3.31%)
System  NUMA01                 719.07 (  0.00%)     1344.39 (-86.96%)
System  NUMA01_THEADLOCAL      916.26 (  0.00%)      180.90 ( 80.26%)
System  NUMA02                  20.92 (  0.00%)       17.34 ( 17.11%)
System  NUMA02_SMT               8.76 (  0.00%)        7.24 ( 17.35%)
Elapsed NUMA01                 728.27 (  0.00%)      519.28 ( 28.70%)
Elapsed NUMA01_THEADLOCAL      589.15 (  0.00%)      554.73 (  5.84%)
Elapsed NUMA02                  81.20 (  0.00%)       81.72 ( -0.64%)
Elapsed NUMA02_SMT              80.49 (  0.00%)       79.58 (  1.13%)
CPU     NUMA01                4603.00 (  0.00%)     4158.00 (  9.67%)
CPU     NUMA01_THEADLOCAL     4213.00 (  0.00%)     4130.00 (  1.97%)
CPU     NUMA02                3937.00 (  0.00%)     3793.00 (  3.66%)
CPU     NUMA02_SMT            1998.00 (  0.00%)     1952.00 (  2.30%)


System CPU usage of NUMA01 is worse but it's an adverse workload on this
machine so I'm reluctant to conclude that it's a problem that matters. On
the other workloads that are sensible on this machine, system CPU usage
is great.  Overall time to complete the benchmark is comparable

          3.18.0-rc4  3.18.0-rc4
             vanillaprotnone-v2r5
User        61493.38    47615.01
System       1665.17     1550.07
Elapsed      1480.79     1236.74

NUMA alloc hit                 4739774     5328362
NUMA alloc miss                      0           0
NUMA interleave hit                  0           0
NUMA alloc local               4664980     5328351
NUMA base PTE updates        556489407   444119981
NUMA huge PMD updates          1086000      866680
NUMA page range updates     1112521407   887860141
NUMA hint faults               1538964     1242142
NUMA hint local faults          835871      814313
NUMA hint local percent             54          65
NUMA pages migrated            7329212    59883854

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

 arch/powerpc/include/asm/pgtable.h    |  53 ++----------
 arch/powerpc/include/asm/pte-common.h |   5 --
 arch/powerpc/include/asm/pte-hash64.h |   6 --
 arch/powerpc/kvm/book3s_hv_rm_mmu.c   |   2 +-
 arch/powerpc/mm/copro_fault.c         |   8 +-
 arch/powerpc/mm/fault.c               |  25 ++----
 arch/powerpc/mm/gup.c                 |   4 +-
 arch/powerpc/mm/pgtable.c             |   8 +-
 arch/powerpc/mm/pgtable_64.c          |   3 +-
 arch/x86/include/asm/pgtable.h        |  46 +++++-----
 arch/x86/include/asm/pgtable_64.h     |   5 --
 arch/x86/include/asm/pgtable_types.h  |  41 +--------
 arch/x86/mm/gup.c                     |   4 +-
 include/asm-generic/pgtable.h         | 152 ++--------------------------------
 include/linux/migrate.h               |   4 -
 include/linux/swapops.h               |   2 +-
 include/uapi/linux/mempolicy.h        |   2 +-
 mm/gup.c                              |   8 +-
 mm/huge_memory.c                      |  50 ++++++-----
 mm/memory.c                           |  18 ++--
 mm/mempolicy.c                        |   2 +-
 mm/migrate.c                          |   8 +-
 mm/mprotect.c                         |  48 +++++------
 mm/pgtable-generic.c                  |   2 -
 24 files changed, 131 insertions(+), 375 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
