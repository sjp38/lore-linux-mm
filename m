Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id CD8656B0038
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 11:12:20 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id bs8so1079695wib.13
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:12:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id df7si2230537wib.45.2014.06.13.08.12.18
        for <linux-mm@kvack.org>;
        Fri, 13 Jun 2014 08:12:19 -0700 (PDT)
Message-ID: <539b14d3.e75eb40a.5896.6d75SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: linux-next: build failure after merge of the akpm-current tree
Date: Fri, 13 Jun 2014 11:12:06 -0400
In-Reply-To: <20140613150550.7b2e2c4c@canb.auug.org.au>
References: <20140613150550.7b2e2c4c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

# cced: linux-mm

Hi Stephen,

On Fri, Jun 13, 2014 at 03:05:50PM +1000, Stephen Rothwell wrote:
> Hi Andrew,
> 
> After merging the akpm-current tree, today's linux-next build (powerpc ppc64_defconfig)
> failed like this:
> 
> fs/proc/task_mmu.c: In function 'smaps_pmd':
> include/linux/compiler.h:363:38: error: call to '__compiletime_assert_505' declared with attribute error: BUILD_BUG failed
>   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>                                       ^
> include/linux/compiler.h:346:4: note: in definition of macro '__compiletime_assert'
>     prefix ## suffix();    \
>     ^
> include/linux/compiler.h:363:2: note: in expansion of macro '_compiletime_assert'
>   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>   ^
> include/linux/bug.h:50:37: note: in expansion of macro 'compiletime_assert'
>  #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>                                      ^
> include/linux/bug.h:84:21: note: in expansion of macro 'BUILD_BUG_ON_MSG'
>  #define BUILD_BUG() BUILD_BUG_ON_MSG(1, "BUILD_BUG failed")
>                      ^
> include/linux/huge_mm.h:167:27: note: in expansion of macro 'BUILD_BUG'
>  #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
>                            ^
> fs/proc/task_mmu.c:505:39: note: in expansion of macro 'HPAGE_PMD_SIZE'
>   smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
>                                        ^
> 
> Caused by commit b0e08c526179 ("mm/pagewalk: move pmd_trans_huge_lock()
> from callbacks to common code").
> 
> The reference to HPAGE_PMD_SIZE (which contains a BUILD_BUG() when
> CONFIG_TRANSPARENT_HUGEPAGE is not defined) used to be protected by a
> call to pmd_trans_huge_lock() (a static inline function that was
> contact 0 when CONFIG_TRANSPARENT_HUGEPAGE is not defined) so gcc did
> not see the reference and the BUG_ON.  That protection has been
> removed ...
> 
> I have reverted that commit and commit 2dc554765dd1
> ("mm-pagewalk-move-pmd_trans_huge_lock-from-callbacks-to-common-code-checkpatch-fixes")
> that depend on it for today.

Sorry about that, this build failure happens because I moved the
pmd_trans_huge_lock() into the common pagewalk code,
clearly this makes mm_walk->pmd_entry handle only transparent hugepage,
so the additional patch below explicitly declare it with #ifdef
CONFIG_TRANSPARENT_HUGEPAGE.

I'll merge this in the next version of my series, but this will help
linux-next for a quick solution.

Thanks,
Naoya Horiguchi
---
