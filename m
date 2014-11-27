Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9C48C6B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 13:08:47 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so5353091pab.33
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 10:08:47 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id qc5si12524451pac.236.2014.11.27.10.08.44
        for <linux-mm@kvack.org>;
        Thu, 27 Nov 2014 10:08:46 -0800 (PST)
Date: Fri, 28 Nov 2014 02:08:06 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 181/397] arch/x86/include/asm/paravirt.h:534:17:
 sparse: context imbalance in 'madvise_free_huge_pmd' - unexpected unlock
Message-ID: <201411280201.xezjOjT0%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   a2d887dee78e23dc092ff14ae2ad22592437a328
commit: ee010684ca66feef309e267f9a47a8cb9b6eb2e3 [181/397] mm: don't split THP page when syscall is called
reproduce:
  # apt-get install sparse
  git checkout ee010684ca66feef309e267f9a47a8cb9b6eb2e3
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> arch/x86/include/asm/paravirt.h:534:17: sparse: context imbalance in 'madvise_free_huge_pmd' - unexpected unlock
   mm/huge_memory.c:1436:40: sparse: context imbalance in 'zap_huge_pmd' - unexpected unlock
   mm/huge_memory.c:1467:28: sparse: context imbalance in 'mincore_huge_pmd' - unexpected unlock
   mm/huge_memory.c:1521:28: sparse: context imbalance in 'move_huge_pmd' - unexpected unlock
   mm/huge_memory.c:1566:28: sparse: context imbalance in 'change_huge_pmd' - unexpected unlock
   mm/huge_memory.c:1579:5: sparse: context imbalance in '__pmd_trans_huge_lock' - different lock contexts for basic block
   mm/huge_memory.c:1606:7: sparse: context imbalance in 'page_check_address_pmd' - different lock contexts for basic block
   mm/huge_memory.c:1680:17: sparse: context imbalance in '__split_huge_page_splitting' - unexpected unlock
   arch/x86/include/asm/paravirt.h:545:17: sparse: context imbalance in '__split_huge_page_map' - unexpected unlock

vim +/madvise_free_huge_pmd +534 arch/x86/include/asm/paravirt.h

4eed80cd include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  518  			      pte_t *ptep, pte_t pte)
4eed80cd include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  519  {
4eed80cd include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  520  	if (sizeof(pteval_t) > sizeof(long))
4eed80cd include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  521  		/* 5 arg words */
4eed80cd include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  522  		pv_mmu_ops.set_pte_at(mm, addr, ptep, pte);
4eed80cd include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  523  	else
4eed80cd include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  524  		PVOP_VCALL4(pv_mmu_ops.set_pte_at, mm, addr, ptep, pte.pte);
4eed80cd include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  525  }
4eed80cd include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  526  
331127f7 arch/x86/include/asm/paravirt.h Andrea Arcangeli    2011-01-13  527  static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
331127f7 arch/x86/include/asm/paravirt.h Andrea Arcangeli    2011-01-13  528  			      pmd_t *pmdp, pmd_t pmd)
331127f7 arch/x86/include/asm/paravirt.h Andrea Arcangeli    2011-01-13  529  {
331127f7 arch/x86/include/asm/paravirt.h Andrea Arcangeli    2011-01-13  530  	if (sizeof(pmdval_t) > sizeof(long))
331127f7 arch/x86/include/asm/paravirt.h Andrea Arcangeli    2011-01-13  531  		/* 5 arg words */
331127f7 arch/x86/include/asm/paravirt.h Andrea Arcangeli    2011-01-13  532  		pv_mmu_ops.set_pmd_at(mm, addr, pmdp, pmd);
331127f7 arch/x86/include/asm/paravirt.h Andrea Arcangeli    2011-01-13  533  	else
cacf061c arch/x86/include/asm/paravirt.h Andrea Arcangeli    2011-01-25 @534  		PVOP_VCALL4(pv_mmu_ops.set_pmd_at, mm, addr, pmdp,
cacf061c arch/x86/include/asm/paravirt.h Andrea Arcangeli    2011-01-25  535  			    native_pmd_val(pmd));
331127f7 arch/x86/include/asm/paravirt.h Andrea Arcangeli    2011-01-13  536  }
331127f7 arch/x86/include/asm/paravirt.h Andrea Arcangeli    2011-01-13  537  
60b3f626 include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  538  static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
60b3f626 include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  539  {
60b3f626 include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  540  	pmdval_t val = native_pmd_val(pmd);
60b3f626 include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  541  
60b3f626 include/asm-x86/paravirt.h      Jeremy Fitzhardinge 2008-01-30  542  	if (sizeof(pmdval_t) > sizeof(long))

:::::: The code at line 534 was first introduced by commit
:::::: cacf061c5e42a040200463afccd9178ace680322 thp: fix PARAVIRT x86 32bit noPAE

:::::: TO: Andrea Arcangeli <aarcange@redhat.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
