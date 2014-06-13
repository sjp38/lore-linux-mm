Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 247916B003C
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 23:23:14 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id k15so2801903qaq.30
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 20:23:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v4si3189167qat.19.2014.06.12.20.23.13
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 20:23:13 -0700 (PDT)
Message-ID: <539a6ea1.4489e00a.7843.ffffaf41SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [mmotm:master 78/178] arch/x86/include/asm/pgtable_32.h:53:42: warning: value computed is not used
Date: Thu, 12 Jun 2014 23:22:59 -0400
In-Reply-To: <539a4dbd.PkEDiEWLgk+yYc8S%fengguang.wu@intel.com>
References: <539a4dbd.PkEDiEWLgk+yYc8S%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Fri, Jun 13, 2014 at 09:02:53AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   a621774e0e7bbd9e8a024230af4704cc489bd40e
> commit: ef99d21ea4a246e56b9a55de5740655d30735f33 [78/178] madvise: cleanup swapin_walk_pmd_entry()
> config: make ARCH=i386 allyesconfig
> 
> All warnings:
> 
>    In file included from arch/x86/include/asm/pgtable.h:432:0,
>                     from include/linux/mm.h:51,
>                     from include/linux/mman.h:4,
>                     from mm/madvise.c:8:
>    mm/madvise.c: In function 'swapin_walk_pte_entry':
> >> arch/x86/include/asm/pgtable_32.h:53:42: warning: value computed is not used [-Wunused-value]
>      ((pte_t *)kmap_atomic(pmd_page(*(dir))) +  \
>                                              ^
>    mm/madvise.c:161:2: note: in expansion of macro 'pte_offset_map'
>      pte_offset_map(walk->pmd, start & PMD_MASK);

Hmm, in the new pagewalk's scheme every callback function is called with
the relevant page table lock held, and we already have the pointers of pte
and ptl inside callbacks, so I thought that no need to recalculate them.
But from compiler's viewpoint, keeping pte_unmap_unlock()-pte_offset_map_lock()
relationship is important so I'll keep it in next post.

Thanks,
Naoya Horiguchi

> 
> vim +53 arch/x86/include/asm/pgtable_32.h
> 
> e621bd189 include/asm-x86/pgtable_32.h      Dave Young     2008-08-20  37  
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  38  /*
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  39   * Define this if things work differently on an i386 and an i486:
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  40   * it will (on an i486) warn about kernel memory accesses that are
> e49332bd1 include/asm-i386/pgtable.h        Jesper Juhl    2005-05-01  41   * done without a 'access_ok(VERIFY_WRITE,..)'
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  42   */
> e49332bd1 include/asm-i386/pgtable.h        Jesper Juhl    2005-05-01  43  #undef TEST_ACCESS_OK
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  44  
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  45  #ifdef CONFIG_X86_PAE
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  46  # include <asm/pgtable-3level.h>
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  47  #else
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  48  # include <asm/pgtable-2level.h>
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  49  #endif
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  50  
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  51  #if defined(CONFIG_HIGHPTE)
> cf840147d include/asm-x86/pgtable_32.h      Joe Perches    2008-03-23  52  #define pte_offset_map(dir, address)					\
> ece0e2b64 arch/x86/include/asm/pgtable_32.h Peter Zijlstra 2010-10-26 @53  	((pte_t *)kmap_atomic(pmd_page(*(dir))) +		\
> cf840147d include/asm-x86/pgtable_32.h      Joe Perches    2008-03-23  54  	 pte_index((address)))
> ece0e2b64 arch/x86/include/asm/pgtable_32.h Peter Zijlstra 2010-10-26  55  #define pte_unmap(pte) kunmap_atomic((pte))
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  56  #else
> cf840147d include/asm-x86/pgtable_32.h      Joe Perches    2008-03-23  57  #define pte_offset_map(dir, address)					\
> cf840147d include/asm-x86/pgtable_32.h      Joe Perches    2008-03-23  58  	((pte_t *)page_address(pmd_page(*(dir))) + pte_index((address)))
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  59  #define pte_unmap(pte) do { } while (0)
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  60  #endif
> ^1da177e4 include/asm-i386/pgtable.h        Linus Torvalds 2005-04-16  61  
> 
> :::::: The code at line 53 was first introduced by commit
> :::::: ece0e2b6406a995c371e0311190631ea34ad851a mm: remove pte_*map_nested()
> 
> :::::: TO: Peter Zijlstra <a.p.zijlstra@chello.nl>
> :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
> 
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
