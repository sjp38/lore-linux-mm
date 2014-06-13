Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 981E66B0031
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 21:44:17 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id md12so775072pbc.31
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 18:44:17 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qf4si345253pbb.185.2014.06.12.18.44.16
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 18:44:16 -0700 (PDT)
Date: Fri, 13 Jun 2014 09:43:37 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 78/178] mm/madvise.c:161: warning: statement with
 no effect
Message-ID: <539a5749.4XUyZ+7arvrYaHsj%fengguang.wu@intel.com>
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
config: make ARCH=avr32 atngw100_defconfig

All warnings:

   mm/madvise.c: In function 'swapin_walk_pte_entry':
>> mm/madvise.c:161: warning: statement with no effect
>> mm/madvise.c:145: warning: unused variable 'orig_pte'

vim +161 mm/madvise.c

   139	 * Assuming that page table walker holds page table lock.
   140	 */
   141	static int swapin_walk_pte_entry(pte_t *pte, unsigned long start,
   142		unsigned long end, struct mm_walk *walk)
   143	{
   144		pte_t ptent;
 > 145		pte_t *orig_pte = pte - ((start & (PMD_SIZE - 1)) >> PAGE_SHIFT);
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

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
