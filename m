Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 859BB60021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 21:46:02 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS2jxUO007789
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 28 Dec 2009 11:46:00 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8704345DE5D
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:45:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F4DC45DE4E
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:45:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 47DF31DB803A
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:45:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 048321DB803C
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:45:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [cleanup][PATCH 1/2] mlock_vma_pages_range() never return negative value
Message-Id: <20091228114519.A678.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 28 Dec 2009 11:45:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Currently, mlock_vma_pages_range() never return negative value. Then, we can
remove some worthless error check.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mmap.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 64e0b04..826b0ec 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1247,12 +1247,7 @@ out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
-		/*
-		 * makes pages present; downgrades, drops, reacquires mmap_sem
-		 */
 		long nr_pages = mlock_vma_pages_range(vma, addr, addr + len);
-		if (nr_pages < 0)
-			return nr_pages;	/* vma gone! */
 		mm->locked_vm += (len >> PAGE_SHIFT) - nr_pages;
 	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
@@ -1730,8 +1725,7 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	if (!prev || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED) {
-		if (mlock_vma_pages_range(prev, addr, prev->vm_end) < 0)
-			return NULL;	/* vma gone! */
+		mlock_vma_pages_range(prev, addr, prev->vm_end);
 	}
 	return prev;
 }
@@ -1759,8 +1753,7 @@ find_extend_vma(struct mm_struct * mm, unsigned long addr)
 	if (expand_stack(vma, addr))
 		return NULL;
 	if (vma->vm_flags & VM_LOCKED) {
-		if (mlock_vma_pages_range(vma, addr, start) < 0)
-			return NULL;	/* vma gone! */
+		mlock_vma_pages_range(vma, addr, start);
 	}
 	return vma;
 }
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
