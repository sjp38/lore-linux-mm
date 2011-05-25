Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0306B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 03:10:48 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A6C933EE0B6
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:10:45 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BB8545DF53
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:10:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72D2345DF56
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:10:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 66EE51DB8038
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:10:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 214541DB803E
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:10:45 +0900 (JST)
Message-ID: <4DDCAB6B.8060804@jp.fujitsu.com>
Date: Wed, 25 May 2011 16:10:35 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 3/4] pagewalk: add locking-rule commnets
References: <4DDCAAC0.20102@jp.fujitsu.com>
In-Reply-To: <4DDCAAC0.20102@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, kamezawa.hiroyu@jp.fujitsu.com

Originally, walk_hugetlb_range() didn't require a caller take any lock.
But commit d33b9f45bd (mm: hugetlb: fix hugepage memory leak in
walk_page_range) changed its rule. Because it added find_vma() call
in walk_hugetlb_range().

Any locking-rule change commit should write a doc too.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mm.h |    1 +
 mm/pagewalk.c      |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index dd87a78..7337b66 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -921,6 +921,7 @@ unsigned long unmap_vmas(struct mmu_gather **tlb,
  * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
  * @pte_hole: if set, called for each hole at all levels
  * @hugetlb_entry: if set, called for each hugetlb entry
+ *                 *Caution*: The caller must hold mmap_sem() if it's used.
  *
  * (see walk_page_range for more details)
  */
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index ee4ff87..f792940 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -181,6 +181,9 @@ static int walk_hugetlb_range(struct vm_area_struct *vma,
  *
  * If any callback returns a non-zero value, the walk is aborted and
  * the return value is propagated back to the caller. Otherwise 0 is returned.
+ *
+ * walk->mm->mmap_sem must be held for at least read if walk->hugetlb_entry
+ * is !NULL.
  */
 int walk_page_range(unsigned long addr, unsigned long end,
 		    struct mm_walk *walk)
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
