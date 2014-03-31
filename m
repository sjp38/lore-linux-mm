Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6B86B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 09:39:48 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id cc10so3325683wib.10
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 06:39:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id be6si7545189wib.13.2014.03.31.06.39.45
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 06:39:46 -0700 (PDT)
Date: Mon, 31 Mar 2014 09:39:37 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <53397022.4658b40a.3c99.2fa8SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <533930a1.W68d+/5S+SyV5Fsf%fengguang.wu@intel.com>
References: <533930a1.W68d+/5S+SyV5Fsf%fengguang.wu@intel.com>
Subject: Re: [next:master 114/486] fs/proc/task_mmu.c:1120:31: error:
 'pagemap_hugetlb' undeclared
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kbuild-all@01.org

On Mon, Mar 31, 2014 at 05:08:49PM +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   8a896813a328f23aeee5f56d3139361534796636
> commit: 64aa967f459ba0bb91ea8b127c9bd586db1beabc [114/486] pagemap: redefine callback functions for page table walker
> config: x86_64-randconfig-br2-03311043 (attached as .config)
> 
> Note: the next/master HEAD 8a896813a328f23aeee5f56d3139361534796636 builds fine.
>       It only hurts bisectibility.
> 
> All error/warnings:
> 
>    fs/proc/task_mmu.c: In function 'pagemap_read':
> >> fs/proc/task_mmu.c:1120:31: error: 'pagemap_hugetlb' undeclared (first use in this function)
>      pagemap_walk.hugetlb_entry = pagemap_hugetlb;
>                                   ^
>    fs/proc/task_mmu.c:1120:31: note: each undeclared identifier is reported only once for each function it appears in
>    fs/proc/task_mmu.c: At top level:
>    fs/proc/task_mmu.c:1025:12: warning: 'pagemap_hugetlb_range' defined but not used [-Wunused-function]
>     static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
>                ^

pagemap_hugetlb_range() should be renamed to pagemap_hugetlb() at 64aa967f459b
("pagemap: redefine callback functions for page table walker"), while it is
currently done by dc86a8715d79 ("pagewalk: remove argument hmask from
hugetlb_entry()") afterward like below:

@@ -1022,8 +1022,7 @@ static void huge_pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *
 }
 
 /* This function walks within one hugetlb entry in the single call */
-static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
-				 unsigned long addr, unsigned long end,
+static int pagemap_hugetlb(pte_t *pte, unsigned long addr, unsigned long end,
 				 struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;

Obviously, dc86a8715d79 should only remove hmask.
Sorry for my poor patch separation.

Thanks,
Naoya Horiguchi

> vim +/pagemap_hugetlb +1120 fs/proc/task_mmu.c
> 
>   1114			goto out_free;
>   1115	
>   1116		pagemap_walk.pte_entry = pagemap_pte;
>   1117		pagemap_walk.pmd_entry = pagemap_pmd;
>   1118		pagemap_walk.pte_hole = pagemap_pte_hole;
>   1119	#ifdef CONFIG_HUGETLB_PAGE
> > 1120		pagemap_walk.hugetlb_entry = pagemap_hugetlb;
>   1121	#endif
>   1122		pagemap_walk.mm = mm;
>   1123		pagemap_walk.private = &pm;
> 
> ---
> 0-DAY kernel build testing backend              Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
