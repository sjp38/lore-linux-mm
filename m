Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3029D6B005C
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 23:59:17 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id ft15so1667051pdb.30
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 20:59:16 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id xm4si703318pbc.45.2014.06.12.20.59.15
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 20:59:16 -0700 (PDT)
Date: Fri, 13 Jun 2014 11:58:49 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 78/178] mm/madvise.c:161:190: warning: value
 computed is not used
Message-ID: <539a76f9.TdKRGJVN9ctnWHnE%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   a621774e0e7bbd9e8a024230af4704cc489bd40e
commit: ef99d21ea4a246e56b9a55de5740655d30735f33 [78/178] madvise: cleanup swapin_walk_pmd_entry()
config: make ARCH=i386 defconfig

All warnings:

   mm/madvise.c: In function 'swapin_walk_pte_entry':
>> mm/madvise.c:161:190: warning: value computed is not used [-Wunused-value]
     pte_offset_map(walk->pmd, start & PMD_MASK);
                                                                                                                                                                                                 ^

vim +161 mm/madvise.c

   145		pte_t *orig_pte = pte - ((start & (PMD_SIZE - 1)) >> PAGE_SHIFT);
   146		swp_entry_t entry;
   147		struct page *page;
   148	
   149		ptent = *pte;
   150		pte_unmap_unlock(orig_pte, walk->ptl);
   151		if (pte_present(ptent) || pte_none(ptent) || pte_file(ptent))
   152			goto lock;
   153		entry = pte_to_swp_entry(ptent);
   154		if (unlikely(non_swap_entry(entry)))
   155			goto lock;
   156		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
   157					     walk->vma, start);
   158		if (page)
   159			page_cache_release(page);
   160	lock:
 > 161		pte_offset_map(walk->pmd, start & PMD_MASK);
   162		spin_lock(walk->ptl);
   163		return 0;
   164	}
   165	
   166	static void force_swapin_readahead(struct vm_area_struct *vma,
   167			unsigned long start, unsigned long end)
   168	{
   169		struct mm_walk walk = {

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
