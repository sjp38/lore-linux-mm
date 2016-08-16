Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C3EAC6B0253
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 13:28:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so184037633pfg.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 10:28:37 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v82si32973404pfa.208.2016.08.16.10.28.36
        for <linux-mm@kvack.org>;
        Tue, 16 Aug 2016 10:28:36 -0700 (PDT)
Date: Wed, 17 Aug 2016 01:27:35 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm: kmemleak: Avoid using __va() on addresses that don't
 have a lowmem mapping
Message-ID: <201608170114.WYq7ZCwJ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="rwEMma7ioTxnRzrJ"
Content-Disposition: inline
In-Reply-To: <1471360856-16916-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vignesh R <vigneshr@ti.com>


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Catalin,

[auto build test ERROR on mmotm/master]
[also build test ERROR on v4.8-rc2 next-20160816]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Catalin-Marinas/mm-kmemleak-Avoid-using-__va-on-addresses-that-don-t-have-a-lowmem-mapping/20160816-232733
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: mn10300-asb2364_defconfig (attached as .config)
compiler: am33_2.0-linux-gcc (GCC) 4.9.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=mn10300 

All error/warnings (new ones prefixed by >>):

   In file included from include/linux/kmemleak.h:24:0,
                    from include/linux/slab.h:117,
                    from arch/mn10300/include/asm/pgtable.h:33,
                    from mm/init-mm.c:9:
   include/linux/mm.h: In function 'is_vmalloc_addr':
>> include/linux/mm.h:486:17: error: 'VMALLOC_START' undeclared (first use in this function)
     return addr >= VMALLOC_START && addr < VMALLOC_END;
                    ^
   include/linux/mm.h:486:17: note: each undeclared identifier is reported only once for each function it appears in
>> include/linux/mm.h:486:41: error: 'VMALLOC_END' undeclared (first use in this function)
     return addr >= VMALLOC_START && addr < VMALLOC_END;
                                            ^
   include/linux/mm.h: In function 'maybe_mkwrite':
>> include/linux/mm.h:624:3: error: implicit declaration of function 'pte_mkwrite' [-Werror=implicit-function-declaration]
      pte = pte_mkwrite(pte);
      ^
>> include/linux/mm.h:624:7: error: incompatible types when assigning to type 'pte_t' from type 'int'
      pte = pte_mkwrite(pte);
          ^
   In file included from include/linux/kmemleak.h:24:0,
                    from include/linux/slab.h:117,
                    from arch/mn10300/include/asm/pgtable.h:33,
                    from mm/init-mm.c:9:
   include/linux/mm.h: In function 'pgtable_init':
>> include/linux/mm.h:1690:2: error: implicit declaration of function 'pgtable_cache_init' [-Werror=implicit-function-declaration]
     pgtable_cache_init();
     ^
   In file included from mm/init-mm.c:9:0:
   arch/mn10300/include/asm/pgtable.h: At top level:
>> arch/mn10300/include/asm/pgtable.h:47:13: warning: conflicting types for 'pgtable_cache_init'
    extern void pgtable_cache_init(void);
                ^
   In file included from include/linux/kmemleak.h:24:0,
                    from include/linux/slab.h:117,
                    from arch/mn10300/include/asm/pgtable.h:33,
                    from mm/init-mm.c:9:
   include/linux/mm.h:1690:2: note: previous implicit declaration of 'pgtable_cache_init' was here
     pgtable_cache_init();
     ^
   In file included from mm/init-mm.c:9:0:
>> arch/mn10300/include/asm/pgtable.h:272:21: error: conflicting types for 'pte_mkwrite'
    static inline pte_t pte_mkwrite(pte_t pte)
                        ^
   In file included from include/linux/kmemleak.h:24:0,
                    from include/linux/slab.h:117,
                    from arch/mn10300/include/asm/pgtable.h:33,
                    from mm/init-mm.c:9:
   include/linux/mm.h:624:9: note: previous implicit declaration of 'pte_mkwrite' was here
      pte = pte_mkwrite(pte);
            ^
   cc1: some warnings being treated as errors

vim +/VMALLOC_START +486 include/linux/mm.h

0738c4bb8 Paul Mundt             2008-03-12  480   */
bb00a789e Yaowei Bai             2016-05-19  481  static inline bool is_vmalloc_addr(const void *x)
9e2779fa2 Christoph Lameter      2008-02-04  482  {
0738c4bb8 Paul Mundt             2008-03-12  483  #ifdef CONFIG_MMU
9e2779fa2 Christoph Lameter      2008-02-04  484  	unsigned long addr = (unsigned long)x;
9e2779fa2 Christoph Lameter      2008-02-04  485  
9e2779fa2 Christoph Lameter      2008-02-04 @486  	return addr >= VMALLOC_START && addr < VMALLOC_END;
0738c4bb8 Paul Mundt             2008-03-12  487  #else
bb00a789e Yaowei Bai             2016-05-19  488  	return false;
8ca3ed87d David Howells          2008-02-23  489  #endif
0738c4bb8 Paul Mundt             2008-03-12  490  }
81ac3ad90 KAMEZAWA Hiroyuki      2009-09-22  491  #ifdef CONFIG_MMU
81ac3ad90 KAMEZAWA Hiroyuki      2009-09-22  492  extern int is_vmalloc_or_module_addr(const void *x);
81ac3ad90 KAMEZAWA Hiroyuki      2009-09-22  493  #else
934831d06 David Howells          2009-09-24  494  static inline int is_vmalloc_or_module_addr(const void *x)
81ac3ad90 KAMEZAWA Hiroyuki      2009-09-22  495  {
81ac3ad90 KAMEZAWA Hiroyuki      2009-09-22  496  	return 0;
81ac3ad90 KAMEZAWA Hiroyuki      2009-09-22  497  }
81ac3ad90 KAMEZAWA Hiroyuki      2009-09-22  498  #endif
9e2779fa2 Christoph Lameter      2008-02-04  499  
39f1f78d5 Al Viro                2014-05-06  500  extern void kvfree(const void *addr);
39f1f78d5 Al Viro                2014-05-06  501  
53f9263ba Kirill A. Shutemov     2016-01-15  502  static inline atomic_t *compound_mapcount_ptr(struct page *page)
53f9263ba Kirill A. Shutemov     2016-01-15  503  {
53f9263ba Kirill A. Shutemov     2016-01-15  504  	return &page[1].compound_mapcount;
53f9263ba Kirill A. Shutemov     2016-01-15  505  }
53f9263ba Kirill A. Shutemov     2016-01-15  506  
53f9263ba Kirill A. Shutemov     2016-01-15  507  static inline int compound_mapcount(struct page *page)
53f9263ba Kirill A. Shutemov     2016-01-15  508  {
5f527c2b3 Andrea Arcangeli       2016-05-20  509  	VM_BUG_ON_PAGE(!PageCompound(page), page);
53f9263ba Kirill A. Shutemov     2016-01-15  510  	page = compound_head(page);
53f9263ba Kirill A. Shutemov     2016-01-15  511  	return atomic_read(compound_mapcount_ptr(page)) + 1;
53f9263ba Kirill A. Shutemov     2016-01-15  512  }
53f9263ba Kirill A. Shutemov     2016-01-15  513  
ccaafd7fd Joonsoo Kim            2015-02-10  514  /*
70b50f94f Andrea Arcangeli       2011-11-02  515   * The atomic page->_mapcount, starts from -1: so that transitions
70b50f94f Andrea Arcangeli       2011-11-02  516   * both from it and to it can be tracked, using atomic_inc_and_test
70b50f94f Andrea Arcangeli       2011-11-02  517   * and atomic_add_negative(-1).
70b50f94f Andrea Arcangeli       2011-11-02  518   */
22b751c3d Mel Gorman             2013-02-22  519  static inline void page_mapcount_reset(struct page *page)
70b50f94f Andrea Arcangeli       2011-11-02  520  {
70b50f94f Andrea Arcangeli       2011-11-02  521  	atomic_set(&(page)->_mapcount, -1);
70b50f94f Andrea Arcangeli       2011-11-02  522  }
70b50f94f Andrea Arcangeli       2011-11-02  523  
b20ce5e03 Kirill A. Shutemov     2016-01-15  524  int __page_mapcount(struct page *page);
b20ce5e03 Kirill A. Shutemov     2016-01-15  525  
70b50f94f Andrea Arcangeli       2011-11-02  526  static inline int page_mapcount(struct page *page)
70b50f94f Andrea Arcangeli       2011-11-02  527  {
1d148e218 Wang, Yalin            2015-02-11  528  	VM_BUG_ON_PAGE(PageSlab(page), page);
53f9263ba Kirill A. Shutemov     2016-01-15  529  
b20ce5e03 Kirill A. Shutemov     2016-01-15  530  	if (unlikely(PageCompound(page)))
b20ce5e03 Kirill A. Shutemov     2016-01-15  531  		return __page_mapcount(page);
b20ce5e03 Kirill A. Shutemov     2016-01-15  532  	return atomic_read(&page->_mapcount) + 1;
53f9263ba Kirill A. Shutemov     2016-01-15  533  }
b20ce5e03 Kirill A. Shutemov     2016-01-15  534  
b20ce5e03 Kirill A. Shutemov     2016-01-15  535  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
b20ce5e03 Kirill A. Shutemov     2016-01-15  536  int total_mapcount(struct page *page);
6d0a07edd Andrea Arcangeli       2016-05-12  537  int page_trans_huge_mapcount(struct page *page, int *total_mapcount);
b20ce5e03 Kirill A. Shutemov     2016-01-15  538  #else
b20ce5e03 Kirill A. Shutemov     2016-01-15  539  static inline int total_mapcount(struct page *page)
b20ce5e03 Kirill A. Shutemov     2016-01-15  540  {
b20ce5e03 Kirill A. Shutemov     2016-01-15  541  	return page_mapcount(page);
70b50f94f Andrea Arcangeli       2011-11-02  542  }
6d0a07edd Andrea Arcangeli       2016-05-12  543  static inline int page_trans_huge_mapcount(struct page *page,
6d0a07edd Andrea Arcangeli       2016-05-12  544  					   int *total_mapcount)
6d0a07edd Andrea Arcangeli       2016-05-12  545  {
6d0a07edd Andrea Arcangeli       2016-05-12  546  	int mapcount = page_mapcount(page);
6d0a07edd Andrea Arcangeli       2016-05-12  547  	if (total_mapcount)
6d0a07edd Andrea Arcangeli       2016-05-12  548  		*total_mapcount = mapcount;
6d0a07edd Andrea Arcangeli       2016-05-12  549  	return mapcount;
6d0a07edd Andrea Arcangeli       2016-05-12  550  }
b20ce5e03 Kirill A. Shutemov     2016-01-15  551  #endif
70b50f94f Andrea Arcangeli       2011-11-02  552  
b49af68ff Christoph Lameter      2007-05-06  553  static inline struct page *virt_to_head_page(const void *x)
b49af68ff Christoph Lameter      2007-05-06  554  {
b49af68ff Christoph Lameter      2007-05-06  555  	struct page *page = virt_to_page(x);
ccaafd7fd Joonsoo Kim            2015-02-10  556  
1d798ca3f Kirill A. Shutemov     2015-11-06  557  	return compound_head(page);
b49af68ff Christoph Lameter      2007-05-06  558  }
b49af68ff Christoph Lameter      2007-05-06  559  
ddc58f27f Kirill A. Shutemov     2016-01-15  560  void __put_page(struct page *page);
ddc58f27f Kirill A. Shutemov     2016-01-15  561  
1d7ea7324 Alexander Zarochentsev 2006-08-13  562  void put_pages_list(struct list_head *pages);
^1da177e4 Linus Torvalds         2005-04-16  563  
8dfcc9ba2 Nick Piggin            2006-03-22  564  void split_page(struct page *page, unsigned int order);
8dfcc9ba2 Nick Piggin            2006-03-22  565  
^1da177e4 Linus Torvalds         2005-04-16  566  /*
33f2ef89f Andy Whitcroft         2006-12-06  567   * Compound pages have a destructor function.  Provide a
33f2ef89f Andy Whitcroft         2006-12-06  568   * prototype for that function and accessor functions.
f1e61557f Kirill A. Shutemov     2015-11-06  569   * These are _only_ valid on the head of a compound page.
33f2ef89f Andy Whitcroft         2006-12-06  570   */
f1e61557f Kirill A. Shutemov     2015-11-06  571  typedef void compound_page_dtor(struct page *);
f1e61557f Kirill A. Shutemov     2015-11-06  572  
f1e61557f Kirill A. Shutemov     2015-11-06  573  /* Keep the enum in sync with compound_page_dtors array in mm/page_alloc.c */
f1e61557f Kirill A. Shutemov     2015-11-06  574  enum compound_dtor_id {
f1e61557f Kirill A. Shutemov     2015-11-06  575  	NULL_COMPOUND_DTOR,
f1e61557f Kirill A. Shutemov     2015-11-06  576  	COMPOUND_PAGE_DTOR,
f1e61557f Kirill A. Shutemov     2015-11-06  577  #ifdef CONFIG_HUGETLB_PAGE
f1e61557f Kirill A. Shutemov     2015-11-06  578  	HUGETLB_PAGE_DTOR,
f1e61557f Kirill A. Shutemov     2015-11-06  579  #endif
9a982250f Kirill A. Shutemov     2016-01-15  580  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
9a982250f Kirill A. Shutemov     2016-01-15  581  	TRANSHUGE_PAGE_DTOR,
9a982250f Kirill A. Shutemov     2016-01-15  582  #endif
f1e61557f Kirill A. Shutemov     2015-11-06  583  	NR_COMPOUND_DTORS,
f1e61557f Kirill A. Shutemov     2015-11-06  584  };
f1e61557f Kirill A. Shutemov     2015-11-06  585  extern compound_page_dtor * const compound_page_dtors[];
33f2ef89f Andy Whitcroft         2006-12-06  586  
33f2ef89f Andy Whitcroft         2006-12-06  587  static inline void set_compound_page_dtor(struct page *page,
f1e61557f Kirill A. Shutemov     2015-11-06  588  		enum compound_dtor_id compound_dtor)
33f2ef89f Andy Whitcroft         2006-12-06  589  {
f1e61557f Kirill A. Shutemov     2015-11-06  590  	VM_BUG_ON_PAGE(compound_dtor >= NR_COMPOUND_DTORS, page);
f1e61557f Kirill A. Shutemov     2015-11-06  591  	page[1].compound_dtor = compound_dtor;
33f2ef89f Andy Whitcroft         2006-12-06  592  }
33f2ef89f Andy Whitcroft         2006-12-06  593  
33f2ef89f Andy Whitcroft         2006-12-06  594  static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
33f2ef89f Andy Whitcroft         2006-12-06  595  {
f1e61557f Kirill A. Shutemov     2015-11-06  596  	VM_BUG_ON_PAGE(page[1].compound_dtor >= NR_COMPOUND_DTORS, page);
f1e61557f Kirill A. Shutemov     2015-11-06  597  	return compound_page_dtors[page[1].compound_dtor];
33f2ef89f Andy Whitcroft         2006-12-06  598  }
33f2ef89f Andy Whitcroft         2006-12-06  599  
d00181b96 Kirill A. Shutemov     2015-11-06  600  static inline unsigned int compound_order(struct page *page)
d85f33855 Christoph Lameter      2007-05-06  601  {
6d7779538 Christoph Lameter      2007-05-06  602  	if (!PageHead(page))
d85f33855 Christoph Lameter      2007-05-06  603  		return 0;
e4b294c2d Kirill A. Shutemov     2015-02-11  604  	return page[1].compound_order;
d85f33855 Christoph Lameter      2007-05-06  605  }
d85f33855 Christoph Lameter      2007-05-06  606  
f1e61557f Kirill A. Shutemov     2015-11-06  607  static inline void set_compound_order(struct page *page, unsigned int order)
d85f33855 Christoph Lameter      2007-05-06  608  {
e4b294c2d Kirill A. Shutemov     2015-02-11  609  	page[1].compound_order = order;
d85f33855 Christoph Lameter      2007-05-06  610  }
d85f33855 Christoph Lameter      2007-05-06  611  
9a982250f Kirill A. Shutemov     2016-01-15  612  void free_compound_page(struct page *page);
9a982250f Kirill A. Shutemov     2016-01-15  613  
3dece370e Michal Simek           2011-01-21  614  #ifdef CONFIG_MMU
33f2ef89f Andy Whitcroft         2006-12-06  615  /*
14fd403f2 Andrea Arcangeli       2011-01-13  616   * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
14fd403f2 Andrea Arcangeli       2011-01-13  617   * servicing faults for write access.  In the normal case, do always want
14fd403f2 Andrea Arcangeli       2011-01-13  618   * pte_mkwrite.  But get_user_pages can cause write faults for mappings
14fd403f2 Andrea Arcangeli       2011-01-13  619   * that do not have writing enabled, when used by access_process_vm.
14fd403f2 Andrea Arcangeli       2011-01-13  620   */
14fd403f2 Andrea Arcangeli       2011-01-13  621  static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
14fd403f2 Andrea Arcangeli       2011-01-13  622  {
14fd403f2 Andrea Arcangeli       2011-01-13  623  	if (likely(vma->vm_flags & VM_WRITE))
14fd403f2 Andrea Arcangeli       2011-01-13 @624  		pte = pte_mkwrite(pte);
14fd403f2 Andrea Arcangeli       2011-01-13  625  	return pte;
14fd403f2 Andrea Arcangeli       2011-01-13  626  }
8c6e50b02 Kirill A. Shutemov     2014-04-07  627  

:::::: The code at line 486 was first introduced by commit
:::::: 9e2779fa281cfda13ac060753d674bbcaa23367e is_vmalloc_addr(): Check if an address is within the vmalloc boundaries

:::::: TO: Christoph Lameter <clameter@sgi.com>
:::::: CC: Linus Torvalds <torvalds@woody.linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--rwEMma7ioTxnRzrJ
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--rwEMma7ioTxnRzrJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
