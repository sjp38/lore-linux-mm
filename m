Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC3160021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 21:01:58 -0500 (EST)
Message-ID: <4B1F0450.2050008@ah.jp.nec.com>
Date: Wed, 09 Dec 2009 10:58:40 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reply-To: n-horiguchi@ah.jp.nec.com
MIME-Version: 1.0
Subject: Re: + mm-hugetlb-fix-hugepage-memory-leak-in-walk_page_range.patch
 added to -mm tree
References: <200912082239.nB8MdgwG019623@imap1.linux-foundation.org>
In-Reply-To: <200912082239.nB8MdgwG019623@imap1.linux-foundation.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, ak@linux.intel.com, apw@canonical.com, fengguang.wu@intel.com, hugh.dickins@tiscali.co.uk, lee.schermerhorn@hp.com, mel@csn.ul.ie, rientjes@google.com, stable@kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Subject: mm: hugetlb: fix hugepage memory leak in walk_page_range()
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Most callers of pmd_none_or_clear_bad() check whether the target page is
> in a hugepage or not, but mincore() and walk_page_range() do not check it.
> So if we use mincore() on a hugepage on x86 machine, the hugepage memory
> is leaked as shown below.  This patch fixes it by extending mincore()
> system call to support hugepages.
> 
> Details
> =======
> My test program (leak_mincore) works as follows:
>  - creat() and mmap() a file on hugetlbfs (file size is 200MB == 100 hugepages,)
>  - read()/write() something on it,
>  - call mincore() for first ten pages and printf() the values of *vec
>  - munmap() and unlink() the file on hugetlbfs

Sorry, this description is for "fix mincore() patch."

Here is "fix walk_page_range() patch."
(I changed some code since previous post and this patch contains them.)

Thanks,
Naoya Horiguchi
-----------
Most callers of pmd_none_or_clear_bad() check whether the target
page is in a hugepage or not, but walk_page_range() do not check it.
So if we read /proc/pid/pagemap for the hugepage on x86 machine,
the hugepage memory is leaked as shown below. This patch fixes it.

Changelog v2:
- NULL check of vma
- remove redundant ternary operation

Details
=======
My test program (leak_pagemap) works as follows:
 - creat() and mmap() a file on hugetlbfs (file size is 200MB == 100 hugepages,)
 - read()/write() something on it,
 - call page-types with option -p (walk around the page tables),
 - munmap() and unlink() the file on hugetlbfs

Without my patches
------------------
$ cat /proc/meminfo |grep "HugePage"
HugePages_Total:    1000
HugePages_Free:     1000
HugePages_Rsvd:        0
HugePages_Surp:        0
$ ./leak_pagemap
[snip output]
$ cat /proc/meminfo |grep "HugePage"
HugePages_Total:    1000
HugePages_Free:      900
HugePages_Rsvd:        0
HugePages_Surp:        0
$ ls /hugetlbfs/
$

100 hugepages are accounted as used while there is no file on hugetlbfs.


With my patches
---------------
$ cat /proc/meminfo |grep "HugePage"
HugePages_Total:    1000
HugePages_Free:     1000
HugePages_Rsvd:        0
HugePages_Surp:        0
$ ./leak_pagemap
[snip output]
$ cat /proc/meminfo |grep "HugePage"
HugePages_Total:    1000
HugePages_Free:     1000
HugePages_Rsvd:        0
HugePages_Surp:        0
$ ls /hugetlbfs
$

No memory leaks.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andy Whitcroft <apw@canonical.com>
Cc: David Rientjes <rientjes@google.com>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/pagewalk.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index d5878be..a286915 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -1,6 +1,7 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/sched.h>
+#include <linux/hugetlb.h>
 
 static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			  struct mm_walk *walk)
@@ -107,6 +108,7 @@ int walk_page_range(unsigned long addr, unsigned long end,
 	pgd_t *pgd;
 	unsigned long next;
 	int err = 0;
+	struct vm_area_struct *vma;
 
 	if (addr >= end)
 		return err;
@@ -117,11 +119,22 @@ int walk_page_range(unsigned long addr, unsigned long end,
 	pgd = pgd_offset(walk->mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
+
+		/* skip hugetlb vma to avoid hugepage PMD being cleared
+		 * in pmd_none_or_clear_bad(). */
+		vma = find_vma(walk->mm, addr);
+		if (vma && is_vm_hugetlb_page(vma)) {
+			if (vma->vm_end < next)
+				next = vma->vm_end;
+			continue;
+		}
+
 		if (pgd_none_or_clear_bad(pgd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
 			if (err)
 				break;
+			pgd++;
 			continue;
 		}
 		if (walk->pgd_entry)
@@ -131,7 +144,8 @@ int walk_page_range(unsigned long addr, unsigned long end,
 			err = walk_pud_range(pgd, addr, next, walk);
 		if (err)
 			break;
-	} while (pgd++, addr = next, addr != end);
+		pgd++;
+	} while (addr = next, addr != end);
 
 	return err;
 }
-- 1.6.0.6 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
