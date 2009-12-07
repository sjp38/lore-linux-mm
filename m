Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 91CB660021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 03:01:24 -0500 (EST)
Message-ID: <4B1CB5D2.7020403@ah.jp.nec.com>
Date: Mon, 07 Dec 2009 16:59:14 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reply-To: n-horiguchi@ah.jp.nec.com
MIME-Version: 1.0
Subject: [PATCH] mm hugetlb x86: fix hugepage memory leak in mincore()
References: <1260172193-14397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1260172193-14397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: hugh.dickins@tiscali.co.uk, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Most callers of pmd_none_or_clear_bad() check whether the target
page is in a hugepage or not, but mincore() and walk_page_range()
do not check it. So if we use mincore() on a hugepage on x86 machine,
the hugepage memory is leaked as shown below.
This patch fixes it by extending mincore() system call to support hugepages.

Details
=======
My test program (leak_mincore) works as follows:
 - creat() and mmap() a file on hugetlbfs (file size is 200MB == 100 hugepages,)
 - read()/write() something on it,
 - call mincore() for first ten pages and printf() the values of *vec
 - munmap() and unlink() the file on hugetlbfs

Without my patch
----------------
$ cat /proc/meminfo| grep "HugePage"
HugePages_Total:    1000
HugePages_Free:     1000
HugePages_Rsvd:        0
HugePages_Surp:        0
$ ./leak_mincore
vec[0] 0
vec[1] 0
vec[2] 0
vec[3] 0
vec[4] 0
vec[5] 0
vec[6] 0
vec[7] 0
vec[8] 0
vec[9] 0
$ cat /proc/meminfo |grep "HugePage"
HugePages_Total:    1000
HugePages_Free:      999
HugePages_Rsvd:        0
HugePages_Surp:        0
$ ls /hugetlbfs/
$

Return values in *vec from mincore() are set to 0, while the hugepage
should be in memory, and 1 hugepage is still accounted as used while
there is no file on hugetlbfs.

With my patch
-------------
$ cat /proc/meminfo| grep "HugePage"
HugePages_Total:    1000
HugePages_Free:     1000
HugePages_Rsvd:        0
HugePages_Surp:        0
$ ./leak_mincore
vec[0] 1
vec[1] 1
vec[2] 1
vec[3] 1
vec[4] 1
vec[5] 1
vec[6] 1
vec[7] 1
vec[8] 1
vec[9] 1
$ cat /proc/meminfo |grep "HugePage"
HugePages_Total:    1000
HugePages_Free:     1000
HugePages_Rsvd:        0
HugePages_Surp:        0
$ ls /hugetlbfs/
$

Return value in *vec set to 1 and no memory leaks.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---
 mm/mincore.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index 8cb508f..f977e3e 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -14,6 +14,7 @@
 #include <linux/syscalls.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/hugetlb.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -72,6 +73,39 @@ static long do_mincore(unsigned long addr, unsigned char *vec, unsigned long pag
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
 
+	if (is_vm_hugetlb_page(vma)) {
+		struct hstate *h;
+		unsigned long nr_huge;
+		unsigned char present;
+		i = 0;
+		nr = min(pages, (vma->vm_end - addr) >> PAGE_SHIFT);
+		h = hstate_vma(vma);
+		nr_huge = ((addr + pages * PAGE_SIZE - 1) >> huge_page_shift(h))
+			  - (addr >> huge_page_shift(h)) + 1;
+		nr_huge = min(nr_huge,
+			      (vma->vm_end - addr) >> huge_page_shift(h));
+		while (1) {
+			/* hugepage always in RAM for now,
+			 * but generally it needs to be check */
+			ptep = huge_pte_offset(current->mm,
+					       addr & huge_page_mask(h));
+			present = !!(ptep &&
+				     !huge_pte_none(huge_ptep_get(ptep)));
+			while (1) {
+				vec[i++] = present;
+				addr += PAGE_SIZE;
+				/* reach buffer limit */
+				if (i == nr)
+					return nr;
+				/* check hugepage border */
+				if (!((addr & ~huge_page_mask(h))
+				      >> PAGE_SHIFT))
+					break;
+			}
+		}
+		return nr;
+	}
+
 	/*
 	 * Calculate how many pages there are left in the last level of the
 	 * PTE array for our address.
-- 
1.6.0.6


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
