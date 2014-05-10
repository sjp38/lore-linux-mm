Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6E13F6B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 22:13:41 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so5089487pab.7
        for <linux-mm@kvack.org>; Fri, 09 May 2014 19:13:41 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yd1si743111pbb.478.2014.05.09.19.13.40
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 19:13:40 -0700 (PDT)
Date: Sat, 10 May 2014 10:09:08 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 230/459] mm/gup.c:208: error: size of array 'type
 name' is negative
Message-ID: <536d8a44.JMhW0mjaIqKB2qV2%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Berg <johannes.berg@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   9567896580328249f6519fda78cf9fe185a8486d
commit: 849ba771e4fd9d334940e79d19c824608d06d393 [230/459] compiler.h: don't use temporary variable in __compiletime_assert()
config: make ARCH=avr32 atngw100_defconfig

All error/warnings:

   mm/gup.c: In function 'follow_page_mask':
>> mm/gup.c:208: error: size of array 'type name' is negative
--
   mm/memory.c: In function 'copy_pmd_range':
>> mm/memory.c:965: error: size of array 'type name' is negative
   mm/memory.c: In function 'zap_pmd_range':
>> mm/memory.c:1232: error: size of array 'type name' is negative
--
   mm/mprotect.c: In function 'change_pmd_range':
>> mm/mprotect.c:164: error: size of array 'type name' is negative
>> mm/mprotect.c:171: error: size of array 'type name' is negative
>> mm/mprotect.c:172: error: size of array 'type name' is negative
--
   mm/mremap.c: In function 'move_page_tables':
>> mm/mremap.c:197: error: size of array 'type name' is negative
--
   mm/pgtable-generic.c: In function 'pmdp_clear_flush_young':
>> mm/pgtable-generic.c:104: error: size of array 'type name' is negative
--
   fs/proc/task_mmu.c: In function 'smaps_pmd':
>> fs/proc/task_mmu.c:502: error: size of array 'type name' is negative
>> fs/proc/task_mmu.c:504: error: size of array 'type name' is negative

vim +208 mm/gup.c

cd31ead0 Kirill A. Shutemov 2014-05-10  192  	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
cd31ead0 Kirill A. Shutemov 2014-05-10  193  		return no_page_table(vma, flags);
cd31ead0 Kirill A. Shutemov 2014-05-10  194  	if (pmd_trans_huge(*pmd)) {
cd31ead0 Kirill A. Shutemov 2014-05-10  195  		if (flags & FOLL_SPLIT) {
cd31ead0 Kirill A. Shutemov 2014-05-10  196  			split_huge_page_pmd(vma, address, pmd);
cd31ead0 Kirill A. Shutemov 2014-05-10  197  			return follow_page_pte(vma, address, pmd, flags);
cd31ead0 Kirill A. Shutemov 2014-05-10  198  		}
cd31ead0 Kirill A. Shutemov 2014-05-10  199  		ptl = pmd_lock(mm, pmd);
cd31ead0 Kirill A. Shutemov 2014-05-10  200  		if (likely(pmd_trans_huge(*pmd))) {
cd31ead0 Kirill A. Shutemov 2014-05-10  201  			if (unlikely(pmd_trans_splitting(*pmd))) {
cd31ead0 Kirill A. Shutemov 2014-05-10  202  				spin_unlock(ptl);
cd31ead0 Kirill A. Shutemov 2014-05-10  203  				wait_split_huge_page(vma->anon_vma, pmd);
cd31ead0 Kirill A. Shutemov 2014-05-10  204  			} else {
cd31ead0 Kirill A. Shutemov 2014-05-10  205  				page = follow_trans_huge_pmd(vma, address,
cd31ead0 Kirill A. Shutemov 2014-05-10  206  							     pmd, flags);
cd31ead0 Kirill A. Shutemov 2014-05-10  207  				spin_unlock(ptl);
cd31ead0 Kirill A. Shutemov 2014-05-10 @208  				*page_mask = HPAGE_PMD_NR - 1;
cd31ead0 Kirill A. Shutemov 2014-05-10  209  				return page;
cd31ead0 Kirill A. Shutemov 2014-05-10  210  			}
cd31ead0 Kirill A. Shutemov 2014-05-10  211  		} else
cd31ead0 Kirill A. Shutemov 2014-05-10  212  			spin_unlock(ptl);
cd31ead0 Kirill A. Shutemov 2014-05-10  213  	}
cd31ead0 Kirill A. Shutemov 2014-05-10  214  	return follow_page_pte(vma, address, pmd, flags);
55b65f76 Kirill A. Shutemov 2014-05-10  215  }
55b65f76 Kirill A. Shutemov 2014-05-10  216  

:::::: The code at line 208 was first introduced by commit
:::::: cd31ead03cee7e815634acb9c0c8fc58eac73409 mm: cleanup follow_page_mask()

:::::: TO: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
:::::: CC: Johannes Weiner <hannes@cmpxchg.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
