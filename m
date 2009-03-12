Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCC66B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 06:22:34 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2CAMSJq078882
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:22:28 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CAMR1Z4092052
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:22:27 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2CAMRe0027579
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:22:27 +0100
Date: Thu, 12 Mar 2009 11:19:16 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] fix/improve generic page table walker
Message-ID: <20090312111916.5dbdb1e5@skybase>
In-Reply-To: <20090312093335.6dd67251@skybase>
References: <20090311144951.58c6ab60@skybase>
	<1236792263.3205.45.camel@calx>
	<20090312093335.6dd67251@skybase>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 09:33:35 +0100
Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> > I've gone to lengths to keep VMAs out of the equation, so I can't say
> > I'm excited about this solution.  
> 
> The minimum fix is to add the mmap_sem. If a vma is unmapped while you
> walk the page tables, they can get freed. You do have a dependency on
> the vma list. All the other page table walkers in mm/ start with the
> vma, then do the four loops. It would be consistent if the generic page
> table walker would do the same.
> 
> Having thought about the problem again, I think I found a way how to
> deal with the problem in the s390 page table primitives. The fix is not
> exactly nice but it will work. With it s390 will be able to walk
> addresses outside of the vma address range.

Ok, the patch below fixes the problem without vma operations in the
generic page table walker. We still need the mmap_sem part though.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

---
Subject: [PATCH] s390: make page table walking more robust

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

Make page table walking on s390 more robust. Currently the four loops
over the pgd/pud/pmd/pte tables may only be done if the address range
of the walk is below the end address of the last vma of the address
space. The reason is the dynamic page table code on s390. A *pgd can
point to a region-second, a region-third or a segment table and a *pud
can point to a region-third or a segment table. The page table primitives
can determine the level of a pgd/pud table by looking at two bits in
any of the entries of the table. The pgd_present primitive always returns
1 if the *pgd does not point to a region-second table, pud_present always
returs 1 if the *pud does not point to a region-third table. pud_offset
and pmd_offset check the type of the table pointed to by *pgd and *pud
and either just cast the pointer to the type of the next lower level
table, or if the level of the table is correct they read the entry from
the table. This all only works if the address bits for the potentially
missing higher page tables are zero. As long as the address of the walk
stays smaller than the end address of the last vma this works.

The generic page table walker ignores the list of vmas and can be used to
walk page table ranges behind the end address of the last vma. If the
process is using a reduced page table nasty things happen.

In case of a reduced page table pgd_present and/or pud_present should
return true only of the address bits in the pgd/pud pointer of the missing
page table is zero. The effect of this changes is that the loop over the
pgd/pud table is done on the lower level. For each of the entries but
the first pgd_present returns false and the outer loops just continue.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 arch/s390/include/asm/pgtable.h |    4 ++--
 fs/proc/task_mmu.c              |    2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/arch/s390/include/asm/pgtable.h linux-2.6-patched/arch/s390/include/asm/pgtable.h
--- linux-2.6/arch/s390/include/asm/pgtable.h	2009-03-12 10:34:01.000000000 +0100
+++ linux-2.6-patched/arch/s390/include/asm/pgtable.h	2009-03-12 10:34:43.000000000 +0100
@@ -451,7 +451,7 @@ static inline int pud_bad(pud_t pud)	 { 
 static inline int pgd_present(pgd_t pgd)
 {
 	if ((pgd_val(pgd) & _REGION_ENTRY_TYPE_MASK) < _REGION_ENTRY_TYPE_R2)
-		return 1;
+		return (pgd_val(pgd) & PGDIR_MASK) == 0;
 	return (pgd_val(pgd) & _REGION_ENTRY_ORIGIN) != 0UL;
 }
 
@@ -478,7 +478,7 @@ static inline int pgd_bad(pgd_t pgd)
 static inline int pud_present(pud_t pud)
 {
 	if ((pud_val(pud) & _REGION_ENTRY_TYPE_MASK) < _REGION_ENTRY_TYPE_R3)
-		return 1;
+		return (pud_val(pud) & PUD_MASK) == 0;
 	return (pud_val(pud) & _REGION_ENTRY_ORIGIN) != 0UL;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
