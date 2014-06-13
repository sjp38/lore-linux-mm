Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 227A56B0038
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 22:59:31 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id b13so2048238wgh.2
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 19:59:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id bf3si4506742wjc.6.2014.06.12.19.59.28
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 19:59:29 -0700 (PDT)
Message-ID: <539a6911.e3acc20a.3e4e.ffffe5a0SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [mmotm:master 83/178] include/linux/compiler.h:346:20: error: call to '__compiletime_assert_505' declared with attribute error: BUILD_BUG failed
Date: Thu, 12 Jun 2014 22:59:08 -0400
In-Reply-To: <539a5523.HESVePEonvHiA9PR%fengguang.wu@intel.com>
References: <539a5523.HESVePEonvHiA9PR%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Fri, Jun 13, 2014 at 09:34:27AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   a621774e0e7bbd9e8a024230af4704cc489bd40e
> commit: d6dc10868bc1439159231b2353dbbfc635a0c104 [83/178] mm/pagewalk: move pmd_trans_huge_lock() from callbacks to common code
> config: x86_64-randconfig-c0-0613 (attached as .config)
> 
> All error/warnings:
> 
>    In file included from include/linux/linkage.h:4:0,
>                     from include/linux/preempt.h:9,
>                     from include/linux/spinlock.h:50,
>                     from include/linux/mmzone.h:7,
>                     from include/linux/gfp.h:5,
>                     from include/linux/mm.h:9,
>                     from fs/proc/task_mmu.c:1:
>    fs/proc/task_mmu.c: In function 'smaps_pmd':
> >> include/linux/compiler.h:346:20: error: call to '__compiletime_assert_505' declared with attribute error: BUILD_BUG failed
>        prefix ## suffix();    \
>                        ^
>    include/linux/compiler.h:351:2: note: in expansion of macro '__compiletime_assert'
>      __compiletime_assert(condition, msg, prefix, suffix)
>      ^
>    include/linux/compiler.h:363:2: note: in expansion of macro '_compiletime_assert'
>      _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>      ^
>    include/linux/bug.h:50:37: note: in expansion of macro 'compiletime_assert'
>     #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>                                         ^
>    include/linux/bug.h:84:21: note: in expansion of macro 'BUILD_BUG_ON_MSG'
>     #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
>                         ^
>    include/linux/huge_mm.h:167:27: note: in expansion of macro 'BUILD_BUG'
>     #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
>                               ^
>    fs/proc/task_mmu.c:505:39: note: in expansion of macro 'HPAGE_PMD_SIZE'
>      smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
>                                           ^

We shouldn't use HPAGE_PMD_SIZE when !CONFIG_TRANSPARENT_HUGEPAGE.
I'll fix it in next post, while maybe I need to add some ugly #ifdefs.

Curiously, current upstream code uses HPAGE_PMD_SIZE without #ifdef
CONFIG_TRANSPARENT_HUGEPAGE too, but it seems to be safe because
if (pmd_trans_huge_lock) block is compiled away in such case.

Other warnings tagged [mmotm:master 83/178] seems to be triggered for
the same reason.

Thanks,
Naoya Horiguchi

> >> include/linux/compiler.h:346:20: error: call to '__compiletime_assert_506' declared with attribute error: BUILD_BUG failed
>        prefix ## suffix();    \
>                        ^
>    include/linux/compiler.h:351:2: note: in expansion of macro '__compiletime_assert'
>      __compiletime_assert(condition, msg, prefix, suffix)
>      ^
>    include/linux/compiler.h:363:2: note: in expansion of macro '_compiletime_assert'
>      _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>      ^
>    include/linux/bug.h:50:37: note: in expansion of macro 'compiletime_assert'
>     #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>                                         ^
>    include/linux/bug.h:84:21: note: in expansion of macro 'BUILD_BUG_ON_MSG'
>     #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
>                         ^
>    include/linux/huge_mm.h:167:27: note: in expansion of macro 'BUILD_BUG'
>     #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
>                               ^
>    fs/proc/task_mmu.c:506:24: note: in expansion of macro 'HPAGE_PMD_SIZE'
>      mss->anonymous_thp += HPAGE_PMD_SIZE;
>                            ^
>    fs/proc/task_mmu.c: In function 'gather_pmd_stats':
> >> include/linux/compiler.h:346:20: error: call to '__compiletime_assert_1330' declared with attribute error: BUILD_BUG failed
>        prefix ## suffix();    \
>                        ^
>    include/linux/compiler.h:351:2: note: in expansion of macro '__compiletime_assert'
>      __compiletime_assert(condition, msg, prefix, suffix)
>      ^
>    include/linux/compiler.h:363:2: note: in expansion of macro '_compiletime_assert'
>      _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>      ^
>    include/linux/bug.h:50:37: note: in expansion of macro 'compiletime_assert'
>     #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>                                         ^
>    include/linux/bug.h:84:21: note: in expansion of macro 'BUILD_BUG_ON_MSG'
>     #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
>                         ^
>    include/linux/huge_mm.h:167:27: note: in expansion of macro 'BUILD_BUG'
>     #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
>                               ^
>    fs/proc/task_mmu.c:1330:9: note: in expansion of macro 'HPAGE_PMD_SIZE'
>             HPAGE_PMD_SIZE/PAGE_SIZE);
>             ^
> 
> vim +/__compiletime_assert_505 +346 include/linux/compiler.h
> 
> 57e66715 mmotm auto import 2014-06-13  330   * versions of GCC (e.g. 4.2.4), so hide the array from sparse altogether.
> 57e66715 mmotm auto import 2014-06-13  331   */
> 57e66715 mmotm auto import 2014-06-13  332  # ifndef __CHECKER__
> 57e66715 mmotm auto import 2014-06-13  333  #  define __compiletime_error_fallback(condition) \
> 9a8ab1c3 Daniel Santos     2013-02-21  334  	do { ((void)sizeof(char[1 - 2 * condition])); } while (0)
> 57e66715 mmotm auto import 2014-06-13  335  # endif
> 57e66715 mmotm auto import 2014-06-13  336  #endif
> 57e66715 mmotm auto import 2014-06-13  337  #ifndef __compiletime_error_fallback
> c361d3e5 Daniel Santos     2013-02-21  338  # define __compiletime_error_fallback(condition) do { } while (0)
> 63312b6a Arjan van de Ven  2009-10-02  339  #endif
> c361d3e5 Daniel Santos     2013-02-21  340  
> 9a8ab1c3 Daniel Santos     2013-02-21  341  #define __compiletime_assert(condition, msg, prefix, suffix)		\
> 9a8ab1c3 Daniel Santos     2013-02-21  342  	do {								\
> 9a8ab1c3 Daniel Santos     2013-02-21  343  		bool __cond = !(condition);				\
> 9a8ab1c3 Daniel Santos     2013-02-21  344  		extern void prefix ## suffix(void) __compiletime_error(msg); \
> 9a8ab1c3 Daniel Santos     2013-02-21  345  		if (__cond)						\
> 9a8ab1c3 Daniel Santos     2013-02-21 @346  			prefix ## suffix();				\
> 9a8ab1c3 Daniel Santos     2013-02-21  347  		__compiletime_error_fallback(__cond);			\
> 9a8ab1c3 Daniel Santos     2013-02-21  348  	} while (0)
> 9a8ab1c3 Daniel Santos     2013-02-21  349  
> 9a8ab1c3 Daniel Santos     2013-02-21  350  #define _compiletime_assert(condition, msg, prefix, suffix) \
> 9a8ab1c3 Daniel Santos     2013-02-21  351  	__compiletime_assert(condition, msg, prefix, suffix)
> 9a8ab1c3 Daniel Santos     2013-02-21  352  
> 9a8ab1c3 Daniel Santos     2013-02-21  353  /**
> 9a8ab1c3 Daniel Santos     2013-02-21  354   * compiletime_assert - break build and emit msg if condition is false
> 
> :::::: The code at line 346 was first introduced by commit
> :::::: 9a8ab1c39970a4938a72d94e6fd13be88a797590 bug.h, compiler.h: introduce compiletime_assert & BUILD_BUG_ON_MSG
> 
> :::::: TO: Daniel Santos <daniel.santos@pobox.com>
> :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
> 
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
