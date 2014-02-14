Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 649366B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:10:27 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id e4so562671wiv.11
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 07:10:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k10si4114348wjb.29.2014.02.14.07.10.24
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 07:10:25 -0800 (PST)
Date: Fri, 14 Feb 2014 10:09:58 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <52fe31e1.ca0ac20a.5647.5e12SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140214130450.GA14755@localhost>
References: <52fdd350.dwn4aII31EyWlDq9%fengguang.wu@intel.com>
 <20140214130450.GA14755@localhost>
Subject: [PATCH] fs/proc/task_mmu.c: assume non-NULL vma in pagemap_hugetlb()
 (Re: [mmotm:master 97/220] fs/proc/task_mmu.c:1042 pagemap_hugetlb() error: we
 previously assumed 'vma' could be null (see line 1037))
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Fengguang,

On Fri, Feb 14, 2014 at 09:04:50PM +0800, Fengguang Wu wrote:
...
> FYI, there are new smatch warnings show up in
> 
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   0363f94bc1c9b81f23ee7d2446331eb288568ea7
> commit: 81272031cc2831a3d1abb3c681f1188aa36a1454 [97/220] pagewalk: remove argument hmask from hugetlb_entry()
> 
> fs/proc/task_mmu.c:1042 pagemap_hugetlb() error: we previously assumed 'vma' could be null (see line 1037)
> 
> vim +/vma +1042 fs/proc/task_mmu.c
> 
> d9104d1c Cyrill Gorcunov       2013-09-11  1031  	int flags2;
> 16fbdce6 Konstantin Khlebnikov 2012-05-10  1032  	pagemap_entry_t pme;
> 81272031 Naoya Horiguchi       2014-02-13  1033  	unsigned long hmask;
> 5dc37642 Naoya Horiguchi       2009-12-14  1034  
> d9104d1c Cyrill Gorcunov       2013-09-11  1035  	WARN_ON_ONCE(!vma);
> d9104d1c Cyrill Gorcunov       2013-09-11  1036  
> d9104d1c Cyrill Gorcunov       2013-09-11 @1037  	if (vma && (vma->vm_flags & VM_SOFTDIRTY))
> d9104d1c Cyrill Gorcunov       2013-09-11  1038  		flags2 = __PM_SOFT_DIRTY;
> d9104d1c Cyrill Gorcunov       2013-09-11  1039  	else
> d9104d1c Cyrill Gorcunov       2013-09-11  1040  		flags2 = 0;
> d9104d1c Cyrill Gorcunov       2013-09-11  1041  
> 21a2f342 Naoya Horiguchi       2014-02-13 @1042  	hmask = huge_page_mask(hstate_vma(vma));
> 5dc37642 Naoya Horiguchi       2009-12-14  1043  	for (; addr != end; addr += PAGE_SIZE) {
> 116354d1 Naoya Horiguchi       2010-04-06  1044  		int offset = (addr & ~hmask) >> PAGE_SHIFT;
> d9104d1c Cyrill Gorcunov       2013-09-11  1045  		huge_pte_to_pagemap_entry(&pme, pm, *pte, offset, flags2);

Thanks for reporting, here is a patch.
We never have NULL vma in pagemap_hugetlb(), I added the BUG_ON check.

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Fri, 14 Feb 2014 09:35:06 -0500
Subject: [PATCH] fs/proc/task_mmu.c: assume non-NULL vma in pagemap_hugetlb()

Fengguang reported smatch error about potential NULL pointer access.

In updated page table walker, we never run ->hugetlb_entry() callback
on the address without vma. This is because __walk_page_range() checks
it in advance. So we can assume non-NULL vma in pagemap_hugetlb().

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f819d0d4a0e8..69aed7192254 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1032,9 +1032,9 @@ static int pagemap_hugetlb(pte_t *pte, unsigned long addr, unsigned long end,
 	pagemap_entry_t pme;
 	unsigned long hmask;
 
-	WARN_ON_ONCE(!vma);
+	BUG_ON(!vma);
 
-	if (vma && (vma->vm_flags & VM_SOFTDIRTY))
+	if (vma->vm_flags & VM_SOFTDIRTY)
 		flags2 = __PM_SOFT_DIRTY;
 	else
 		flags2 = 0;
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
