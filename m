Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 98A1E6B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 10:41:22 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so7802259eek.37
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 07:41:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 49si25795582een.335.2014.04.15.07.41.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 07:41:20 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/3] Use an alternative to _PAGE_PROTNONE for _PAGE_NUMA v4
Date: Tue, 15 Apr 2014 15:41:13 +0100
Message-Id: <1397572876-1610-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Fengguang Wu found that an earlier version crashed on his
tests. This version passed tests running with DEBUG_VM and
DEBUG_PAGEALLOC. Fengguang, another test would be appreciated and
if it helps this series is the mm-numa-use-high-bit-v4r3 branch in
git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git

At the very least the first patch of this series needs to be picked up and
backported to stable as David Vrabel reports that Xen users are now hitting
the bug routinely. It's currently tagged for stable but please make sure
that information does not get stripped when merged and gets picked up by
the stable maintainers in a timely fashion.

Changelog since V2
o Use separate bit and shrink max swap size
o Distinguish between pte_present and pte_numa for swap ptes
o Remove bit shuffling depending on config
o Clear NUMA information protection modification on x86
o Removed RFC

Changelog since V1
o Reuse software-bits
o Use paravirt ops when modifying PTEs in the NUMA helpers

Aliasing _PAGE_NUMA and _PAGE_PROTNONE had some convenient properties but
it ultimately gave Xen a headache and pisses almost everybody off that
looks closely at it. Two discussions on "why this makes sense" is one
discussion too many so rather than having a third so here is this series.
This series uses bits to uniquely identify NUMA hinting ptes instead of
depending on PROTNONE faults to simply "miss" the PTEs.

It really could do with a tested-by from the powerpc people.

 arch/powerpc/include/asm/pgtable.h   |  5 +++
 arch/x86/Kconfig                     |  2 +-
 arch/x86/include/asm/pgtable.h       | 14 +++++---
 arch/x86/include/asm/pgtable_64.h    |  8 +++++
 arch/x86/include/asm/pgtable_types.h | 66 +++++++++++++++++++-----------------
 arch/x86/mm/pageattr-test.c          |  2 +-
 include/asm-generic/pgtable.h        | 35 +++++++++++++------
 include/linux/swapops.h              |  2 +-
 mm/memory.c                          | 12 +++----
 9 files changed, 90 insertions(+), 56 deletions(-)

-- 
1.8.4.5

Mel Gorman (3):
  mm: use paravirt friendly ops for NUMA hinting ptes
  x86: Require x86-64 for automatic NUMA balancing
  x86: Define _PAGE_NUMA by reusing software bits on the PMD and PTE
    levels

 arch/powerpc/include/asm/pgtable.h   |  5 +++
 arch/x86/Kconfig                     |  2 +-
 arch/x86/include/asm/pgtable.h       | 14 +++++---
 arch/x86/include/asm/pgtable_64.h    |  8 +++++
 arch/x86/include/asm/pgtable_types.h | 66 +++++++++++++++++++-----------------
 arch/x86/mm/pageattr-test.c          |  2 +-
 include/asm-generic/pgtable.h        | 35 +++++++++++++------
 include/linux/swapops.h              |  2 +-
 mm/memory.c                          | 17 ++++------
 9 files changed, 93 insertions(+), 58 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
