Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EDFC16B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 08:05:01 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so11903259pde.7
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 05:05:01 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id b4si5716560pbe.358.2014.02.14.05.05.00
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 05:05:00 -0800 (PST)
Date: Fri, 14 Feb 2014 21:04:50 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mmotm:master 97/220] fs/proc/task_mmu.c:1042 pagemap_hugetlb()
 error: we previously assumed 'vma' could be null (see line 1037)
Message-ID: <20140214130450.GA14755@localhost>
References: <52fdd350.dwn4aII31EyWlDq9%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52fdd350.dwn4aII31EyWlDq9%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


Hi Naoya,

FYI, there are new smatch warnings show up in

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   0363f94bc1c9b81f23ee7d2446331eb288568ea7
commit: 81272031cc2831a3d1abb3c681f1188aa36a1454 [97/220] pagewalk: remove argument hmask from hugetlb_entry()

fs/proc/task_mmu.c:1042 pagemap_hugetlb() error: we previously assumed 'vma' could be null (see line 1037)

vim +/vma +1042 fs/proc/task_mmu.c

d9104d1c Cyrill Gorcunov       2013-09-11  1031  	int flags2;
16fbdce6 Konstantin Khlebnikov 2012-05-10  1032  	pagemap_entry_t pme;
81272031 Naoya Horiguchi       2014-02-13  1033  	unsigned long hmask;
5dc37642 Naoya Horiguchi       2009-12-14  1034  
d9104d1c Cyrill Gorcunov       2013-09-11  1035  	WARN_ON_ONCE(!vma);
d9104d1c Cyrill Gorcunov       2013-09-11  1036  
d9104d1c Cyrill Gorcunov       2013-09-11 @1037  	if (vma && (vma->vm_flags & VM_SOFTDIRTY))
d9104d1c Cyrill Gorcunov       2013-09-11  1038  		flags2 = __PM_SOFT_DIRTY;
d9104d1c Cyrill Gorcunov       2013-09-11  1039  	else
d9104d1c Cyrill Gorcunov       2013-09-11  1040  		flags2 = 0;
d9104d1c Cyrill Gorcunov       2013-09-11  1041  
21a2f342 Naoya Horiguchi       2014-02-13 @1042  	hmask = huge_page_mask(hstate_vma(vma));
5dc37642 Naoya Horiguchi       2009-12-14  1043  	for (; addr != end; addr += PAGE_SIZE) {
116354d1 Naoya Horiguchi       2010-04-06  1044  		int offset = (addr & ~hmask) >> PAGE_SHIFT;
d9104d1c Cyrill Gorcunov       2013-09-11  1045  		huge_pte_to_pagemap_entry(&pme, pm, *pte, offset, flags2);



---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
