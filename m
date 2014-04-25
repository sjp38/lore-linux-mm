Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6D85C6B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 11:16:30 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so3272473pde.1
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 08:16:29 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id nf8si3136458pbc.181.2014.04.25.08.16.28
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 08:16:29 -0700 (PDT)
Date: Fri, 25 Apr 2014 23:16:05 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [next:master 102/250] mm/gup.c:43:2: warning: right shift count >=
 width of type
Message-ID: <20140425151605.GC31117@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   d397246adc001ee5235f32de10db112ad23175df
commit: 0d84be787c23f75dba61dca3390c6060ae50d26f [102/250] mm: move get_user_pages()-related code to separate file
config: make ARCH=parisc c8000_defconfig

All warnings:

   In file included from arch/parisc/include/asm/bitops.h:213:0,
                    from include/linux/bitops.h:33,
                    from include/linux/kernel.h:10,
                    from arch/parisc/include/asm/bug.h:4,
                    from include/linux/bug.h:4,
                    from include/linux/thread_info.h:11,
                    from include/asm-generic/preempt.h:4,
                    from arch/parisc/include/generated/asm/preempt.h:1,
                    from include/linux/preempt.h:18,
                    from include/linux/spinlock.h:50,
                    from include/linux/mm_types.h:8,
                    from include/linux/hugetlb.h:4,
                    from mm/gup.c:1:
   include/asm-generic/bitops/__fls.h: In function '__fls':
   include/asm-generic/bitops/__fls.h:17:2: warning: left shift count >= width of type [enabled by default]
   include/asm-generic/bitops/__fls.h:19:3: warning: left shift count >= width of type [enabled by default]
   include/asm-generic/bitops/__fls.h:22:2: warning: left shift count >= width of type [enabled by default]
   include/asm-generic/bitops/__fls.h:26:2: warning: left shift count >= width of type [enabled by default]
   include/asm-generic/bitops/__fls.h:30:2: warning: left shift count >= width of type [enabled by default]
   include/asm-generic/bitops/__fls.h:34:2: warning: left shift count >= width of type [enabled by default]
   include/asm-generic/bitops/__fls.h:38:2: warning: left shift count >= width of type [enabled by default]
   In file included from mm/gup.c:1:0:
   include/linux/hugetlb.h: In function 'hugepages_supported':
   include/linux/hugetlb.h:468:9: error: 'HPAGE_SHIFT' undeclared (first use in this function)
   include/linux/hugetlb.h:468:9: note: each undeclared identifier is reported only once for each function it appears in
   mm/gup.c: In function 'follow_page_mask':
>> mm/gup.c:43:2: warning: right shift count >= width of type [enabled by default]
   mm/gup.c:163:3: error: implicit declaration of function 'trylock_page' [-Werror=implicit-function-declaration]
   mm/gup.c:172:4: error: implicit declaration of function 'unlock_page' [-Werror=implicit-function-declaration]
   mm/gup.c: In function '__get_user_pages':
>> mm/gup.c:307:5: warning: right shift count >= width of type [enabled by default]
>> mm/gup.c:309:5: warning: right shift count >= width of type [enabled by default]
   mm/gup.c:441:5: error: implicit declaration of function 'flush_anon_page' [-Werror=implicit-function-declaration]
   mm/gup.c:442:5: error: implicit declaration of function 'flush_dcache_page' [-Werror=implicit-function-declaration]
   mm/gup.c: In function 'get_dump_page':
   mm/gup.c:611:2: error: implicit declaration of function 'flush_cache_page' [-Werror=implicit-function-declaration]
   cc1: some warnings being treated as errors

vim +43 mm/gup.c

0d84be78 Kirill A. Shutemov 2014-04-23  @1  #include <linux/hugetlb.h>
0d84be78 Kirill A. Shutemov 2014-04-23   2  #include <linux/mm.h>
0d84be78 Kirill A. Shutemov 2014-04-23   3  #include <linux/rmap.h>
0d84be78 Kirill A. Shutemov 2014-04-23   4  #include <linux/swap.h>
0d84be78 Kirill A. Shutemov 2014-04-23   5  #include <linux/swapops.h>
0d84be78 Kirill A. Shutemov 2014-04-23   6  
0d84be78 Kirill A. Shutemov 2014-04-23   7  #include "internal.h"
0d84be78 Kirill A. Shutemov 2014-04-23   8  
0d84be78 Kirill A. Shutemov 2014-04-23   9  /**
0d84be78 Kirill A. Shutemov 2014-04-23  10   * follow_page_mask - look up a page descriptor from a user-virtual address
0d84be78 Kirill A. Shutemov 2014-04-23  11   * @vma: vm_area_struct mapping @address
0d84be78 Kirill A. Shutemov 2014-04-23  12   * @address: virtual address to look up
0d84be78 Kirill A. Shutemov 2014-04-23  13   * @flags: flags modifying lookup behaviour
0d84be78 Kirill A. Shutemov 2014-04-23  14   * @page_mask: on output, *page_mask is set according to the size of the page
0d84be78 Kirill A. Shutemov 2014-04-23  15   *
0d84be78 Kirill A. Shutemov 2014-04-23  16   * @flags can have FOLL_ flags set, defined in <linux/mm.h>
0d84be78 Kirill A. Shutemov 2014-04-23  17   *
0d84be78 Kirill A. Shutemov 2014-04-23  18   * Returns the mapped (struct page *), %NULL if no mapping exists, or
0d84be78 Kirill A. Shutemov 2014-04-23  19   * an error pointer if there is a mapping to something not represented
0d84be78 Kirill A. Shutemov 2014-04-23  20   * by a page descriptor (see also vm_normal_page()).
0d84be78 Kirill A. Shutemov 2014-04-23  21   */
0d84be78 Kirill A. Shutemov 2014-04-23  22  struct page *follow_page_mask(struct vm_area_struct *vma,
0d84be78 Kirill A. Shutemov 2014-04-23  23  			      unsigned long address, unsigned int flags,
0d84be78 Kirill A. Shutemov 2014-04-23  24  			      unsigned int *page_mask)
0d84be78 Kirill A. Shutemov 2014-04-23  25  {
0d84be78 Kirill A. Shutemov 2014-04-23  26  	pgd_t *pgd;
0d84be78 Kirill A. Shutemov 2014-04-23  27  	pud_t *pud;
0d84be78 Kirill A. Shutemov 2014-04-23  28  	pmd_t *pmd;
0d84be78 Kirill A. Shutemov 2014-04-23  29  	pte_t *ptep, pte;
0d84be78 Kirill A. Shutemov 2014-04-23  30  	spinlock_t *ptl;
0d84be78 Kirill A. Shutemov 2014-04-23  31  	struct page *page;
0d84be78 Kirill A. Shutemov 2014-04-23  32  	struct mm_struct *mm = vma->vm_mm;
0d84be78 Kirill A. Shutemov 2014-04-23  33  
0d84be78 Kirill A. Shutemov 2014-04-23  34  	*page_mask = 0;
0d84be78 Kirill A. Shutemov 2014-04-23  35  
0d84be78 Kirill A. Shutemov 2014-04-23  36  	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
0d84be78 Kirill A. Shutemov 2014-04-23  37  	if (!IS_ERR(page)) {
0d84be78 Kirill A. Shutemov 2014-04-23  38  		BUG_ON(flags & FOLL_GET);
0d84be78 Kirill A. Shutemov 2014-04-23  39  		goto out;
0d84be78 Kirill A. Shutemov 2014-04-23  40  	}
0d84be78 Kirill A. Shutemov 2014-04-23  41  
0d84be78 Kirill A. Shutemov 2014-04-23  42  	page = NULL;
0d84be78 Kirill A. Shutemov 2014-04-23 @43  	pgd = pgd_offset(mm, address);
0d84be78 Kirill A. Shutemov 2014-04-23  44  	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
0d84be78 Kirill A. Shutemov 2014-04-23  45  		goto no_page_table;
0d84be78 Kirill A. Shutemov 2014-04-23  46  

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
