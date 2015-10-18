Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3391E6B0253
	for <linux-mm@kvack.org>; Sun, 18 Oct 2015 19:22:43 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so74872403pac.3
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 16:22:42 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qw9si47953688pbc.223.2015.10.18.16.22.42
        for <linux-mm@kvack.org>;
        Sun, 18 Oct 2015 16:22:42 -0700 (PDT)
Date: Mon, 19 Oct 2015 07:22:14 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 8316/8584] mm/madvise.c:280:9: sparse: incorrect
 type in initializer (different base types)
Message-ID: <201510190710.SdxRkgF4%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   cd685d8558e92f3d3ba7e070ac03ae2585f70ba1
commit: dd968da779361ddf808028d34ab1d6d91e94a218 [8316/8584] mm-support-madvisemadv_free-vs-thp-rename-split_huge_page_pmd-to-split_huge_pmd
reproduce:
        # apt-get install sparse
        git checkout dd968da779361ddf808028d34ab1d6d91e94a218
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/madvise.c:280:9: sparse: incorrect type in initializer (different base types)
   mm/madvise.c:280:9:    expected struct pmd_t [usertype] *____pmd
   mm/madvise.c:280:9:    got unsigned long [unsigned] addr
>> mm/madvise.c:280:9: sparse: incorrect type in argument 2 (different base types)
   mm/madvise.c:280:9:    expected struct pmd_t [usertype] *pmd
   mm/madvise.c:280:9:    got unsigned long [unsigned] addr
>> mm/madvise.c:280:9: sparse: incorrect type in argument 3 (different base types)
   mm/madvise.c:280:9:    expected unsigned long [unsigned] address
   mm/madvise.c:280:9:    got struct pmd_t [usertype] *pmd
   In file included from include/linux/mm.h:322:0,
                    from include/linux/mman.h:4,
                    from mm/madvise.c:8:
   mm/madvise.c: In function 'madvise_free_pte_range':
   include/linux/huge_mm.h:108:20: warning: initialization makes pointer from integer without a cast [-Wint-conversion]
      pmd_t *____pmd = (__pmd);    \
                       ^
   mm/madvise.c:280:2: note: in expansion of macro 'split_huge_pmd'
     split_huge_pmd(vma, addr, pmd);
     ^
   mm/madvise.c:280:22: warning: passing argument 2 of '__split_huge_pmd' makes pointer from integer without a cast [-Wint-conversion]
     split_huge_pmd(vma, addr, pmd);
                         ^
   include/linux/huge_mm.h:110:28: note: in definition of macro 'split_huge_pmd'
       __split_huge_pmd(__vma, __pmd, __address); \
                               ^
   include/linux/huge_mm.h:103:6: note: expected 'pmd_t * {aka struct <anonymous> *}' but argument is of type 'long unsigned int'
    void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
         ^
   mm/madvise.c:280:28: warning: passing argument 3 of '__split_huge_pmd' makes integer from pointer without a cast [-Wint-conversion]
     split_huge_pmd(vma, addr, pmd);
                               ^
   include/linux/huge_mm.h:110:35: note: in definition of macro 'split_huge_pmd'
       __split_huge_pmd(__vma, __pmd, __address); \
                                      ^
   include/linux/huge_mm.h:103:6: note: expected 'long unsigned int' but argument is of type 'pmd_t * {aka struct <anonymous> *}'
    void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
         ^

vim +280 mm/madvise.c

   264		force_page_cache_readahead(file->f_mapping, file, start, end - start);
   265		return 0;
   266	}
   267	
   268	static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
   269					unsigned long end, struct mm_walk *walk)
   270	
   271	{
   272		struct madvise_free_private *fp = walk->private;
   273		struct mmu_gather *tlb = fp->tlb;
   274		struct mm_struct *mm = tlb->mm;
   275		struct vm_area_struct *vma = fp->vma;
   276		spinlock_t *ptl;
   277		pte_t *pte, ptent;
   278		struct page *page;
   279	
 > 280		split_huge_pmd(vma, addr, pmd);
   281		if (pmd_trans_unstable(pmd))
   282			return 0;
   283	
   284		pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
   285		arch_enter_lazy_mmu_mode();
   286		for (; addr != end; pte++, addr += PAGE_SIZE) {
   287			ptent = *pte;
   288	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
