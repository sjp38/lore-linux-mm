Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BCF5E6B004A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 04:22:42 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [BUGFIX][PATCH] pagemap: set pagemap walk limit to PMD boundary
Date: Fri, 19 Nov 2010 18:07:45 +0900
Message-Id: <1290157665-17215-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

Currently one pagemap_read() call walks in PAGEMAP_WALK_SIZE bytes
(== 512 pages.)  But there is a corner case where walk_pmd_range()
accidentally runs over a VMA associated with a hugetlbfs file.

For example, when a process has mappings to VMAs as shown below:

  # cat /proc/<pid>/maps
  ...
  3a58f6d000-3a58f72000 rw-p 00000000 00:00 0
  7fbd51853000-7fbd51855000 rw-p 00000000 00:00 0
  7fbd5186c000-7fbd5186e000 rw-p 00000000 00:00 0
  7fbd51a00000-7fbd51c00000 rw-s 00000000 00:12 8614   /hugepages/test

then pagemap_read() goes into walk_pmd_range() path and walks in the range
0x7fbd51853000-0x7fbd51a53000, but the hugetlbfs VMA should be handled
by walk_hugetlb_range(). Otherwise PMD for the hugepage is considered bad
and cleared, which causes undesirable results.

This patch fixes it by separating pagemap walk range into one PMD.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Matt Mackall <mpm@selenic.com>
---
 fs/proc/task_mmu.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index da6b01d..c126c83 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -706,6 +706,7 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
  * skip over unmapped regions.
  */
 #define PAGEMAP_WALK_SIZE	(PMD_SIZE)
+#define PAGEMAP_WALK_MASK	(PMD_MASK)
 static ssize_t pagemap_read(struct file *file, char __user *buf,
 			    size_t count, loff_t *ppos)
 {
@@ -776,7 +777,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 		unsigned long end;
 
 		pm.pos = 0;
-		end = start_vaddr + PAGEMAP_WALK_SIZE;
+		end = (start_vaddr + PAGEMAP_WALK_SIZE) & PAGEMAP_WALK_MASK;
 		/* overflow ? */
 		if (end < start_vaddr || end > end_vaddr)
 			end = end_vaddr;
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
