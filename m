Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id DF8A76B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 11:42:53 -0400 (EDT)
Received: by igcau1 with SMTP id au1so31148659igc.1
        for <linux-mm@kvack.org>; Fri, 15 May 2015 08:42:53 -0700 (PDT)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id bf2si3121871pad.81.2015.05.15.08.42.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 15 May 2015 08:42:51 -0700 (PDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 May 2015 21:12:47 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 77033E0054
	for <linux-mm@kvack.org>; Fri, 15 May 2015 21:15:44 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4FFggiR66387972
	for <linux-mm@kvack.org>; Fri, 15 May 2015 21:12:42 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4FFgg1r019005
	for <linux-mm@kvack.org>; Fri, 15 May 2015 21:12:42 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V5 0/3] THP related cleanups
Date: Fri, 15 May 2015 21:12:27 +0530
Message-Id: <1431704550-19937-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, schwidefsky@de.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>


Changes from V4:
* Folded patches in -mm
  mm-thp-split-out-pmd-collpase-flush-into-a-separate-functions-fix.patch
  mm-thp-split-out-pmd-collpase-flush-into-a-separate-functions-fix-2.patch
  mm-clarify-that-the-function-operateds-on-hugepage-pte-fix.patch
* Fix VM_BUG_ON on x86.
 the default implementation of pmdp_collapse_flush used the hugepage variant
 and hence can be called on pmd_t pointing to pgtable. This resulting in us
 hitting VM_BUG_ON in pmdp_clear_flush. Update powerpc/mm: Use generic version of pmdp_clear_flush
 to handle this.


NOTE: Can we get this tested on s390 ?

Aneesh Kumar K.V (3):
  mm/thp: Split out pmd collpase flush into a separate functions
  powerpc/mm: Use generic version of pmdp_clear_flush
  mm: Clarify that the function operates on hugepage pte

 arch/mips/include/asm/pgtable.h          |  8 ++--
 arch/powerpc/include/asm/pgtable-ppc64.h | 14 +++---
 arch/powerpc/mm/pgtable_64.c             | 73 +++++++++++++++-----------------
 arch/s390/include/asm/pgtable.h          | 30 ++++++++-----
 arch/sparc/include/asm/pgtable_64.h      |  8 ++--
 arch/tile/include/asm/pgtable.h          |  8 ++--
 arch/x86/include/asm/pgtable.h           |  4 +-
 include/asm-generic/pgtable.h            | 49 +++++++++++++++++----
 include/linux/mmu_notifier.h             | 12 +++---
 mm/huge_memory.c                         | 18 ++++----
 mm/migrate.c                             |  2 +-
 mm/pgtable-generic.c                     |  9 ++--
 mm/rmap.c                                |  2 +-
 13 files changed, 136 insertions(+), 101 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
