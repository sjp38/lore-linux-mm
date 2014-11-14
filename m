Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD3E6B00CD
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 06:44:25 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id g201so11789178oib.24
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 03:44:25 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o2si27878951oer.69.2014.11.14.03.44.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 03:44:24 -0800 (PST)
Date: Fri, 14 Nov 2014 14:44:15 +0300
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 120/306] fs/proc/task_mmu.c:474 smaps_account() warn:
 should 'size << 12' be a 64 bit type?
Message-ID: <20141114114415.GD5351@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild@01.org, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dan Carpenter <dan.carpenter@oracle.com>

[ You would have to enable transparent huge page tables on a 32 bit
  system to trigger this bug and I don't think that's possible.

  I don't think Smatch will complain about this if you have the cross
  function database turned on because it knows the value of size in that
  case.  But most people don't build the database so it might be worth
  silencing this bug?  Should I even bother sending these email for
  non-bugs?  Let me know.  -dan ]

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   e668fb4c5c5e6de5b9432bd36d83b3a0b4ce78e8
commit: be7c8db9daa43935912bc8c898ecea99b32d805b [120/306] mm: fix huge zero page accounting in smaps report

fs/proc/task_mmu.c:474 smaps_account() warn: should 'size << 12' be a 64 bit type?

git remote add mmotm git://git.cmpxchg.org/linux-mmotm.git
git remote update mmotm
git checkout be7c8db9daa43935912bc8c898ecea99b32d805b
vim +474 fs/proc/task_mmu.c

be7c8db9 Kirill A. Shutemov 2014-11-13  458  	mss->resident += size;
be7c8db9 Kirill A. Shutemov 2014-11-13  459  	/* Accumulate the size in pages that have been accessed. */
be7c8db9 Kirill A. Shutemov 2014-11-13  460  	if (young || PageReferenced(page))
be7c8db9 Kirill A. Shutemov 2014-11-13  461  		mss->referenced += size;
be7c8db9 Kirill A. Shutemov 2014-11-13  462  	mapcount = page_mapcount(page);
be7c8db9 Kirill A. Shutemov 2014-11-13  463  	if (mapcount >= 2) {
be7c8db9 Kirill A. Shutemov 2014-11-13  464  		if (dirty || PageDirty(page))
be7c8db9 Kirill A. Shutemov 2014-11-13  465  			mss->shared_dirty += size;
be7c8db9 Kirill A. Shutemov 2014-11-13  466  		else
be7c8db9 Kirill A. Shutemov 2014-11-13  467  			mss->shared_clean += size;
be7c8db9 Kirill A. Shutemov 2014-11-13  468  		mss->pss += (size << PSS_SHIFT) / mapcount;
be7c8db9 Kirill A. Shutemov 2014-11-13  469  	} else {
be7c8db9 Kirill A. Shutemov 2014-11-13  470  		if (dirty || PageDirty(page))
be7c8db9 Kirill A. Shutemov 2014-11-13  471  			mss->private_dirty += size;
be7c8db9 Kirill A. Shutemov 2014-11-13  472  		else
be7c8db9 Kirill A. Shutemov 2014-11-13  473  			mss->private_clean += size;
be7c8db9 Kirill A. Shutemov 2014-11-13 @474  		mss->pss += (size << PSS_SHIFT);
be7c8db9 Kirill A. Shutemov 2014-11-13  475  	}
be7c8db9 Kirill A. Shutemov 2014-11-13  476  }
be7c8db9 Kirill A. Shutemov 2014-11-13  477  
be7c8db9 Kirill A. Shutemov 2014-11-13  478  
be7c8db9 Kirill A. Shutemov 2014-11-13  479  static void smaps_pte_entry(pte_t *pte, unsigned long addr,
be7c8db9 Kirill A. Shutemov 2014-11-13  480  		struct mm_walk *walk)
e070ad49 Mauricio Lin       2005-09-03  481  {
2165009b Dave Hansen        2008-06-12  482  	struct mem_size_stats *mss = walk->private;

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
