Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9C2746B0062
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 02:31:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA7VNQm023066
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Dec 2009 16:31:23 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BAC945DE62
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:31:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D88745DE5D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:31:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EA6821DB8038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:31:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FC4D1DB803F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:31:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v2  3/8] VM_LOCKED check don't need pte lock
In-Reply-To: <20091210154822.2550.A69D9226@jp.fujitsu.com>
References: <20091210154822.2550.A69D9226@jp.fujitsu.com>
Message-Id: <20091210163033.2559.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Dec 2009 16:31:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

Currently, page_referenced_one() check VM_LOCKED after taking ptelock.
But it's unnecessary. We can check VM_LOCKED before to take lock.

This patch does it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/rmap.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 1b50425..fb0983a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -383,21 +383,21 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int referenced = 0;
 
-	pte = page_check_address(page, mm, address, &ptl, 0);
-	if (!pte)
-		goto out;
-
 	/*
 	 * Don't want to elevate referenced for mlocked page that gets this far,
 	 * in order that it progresses to try_to_unmap and is moved to the
 	 * unevictable list.
 	 */
 	if (vma->vm_flags & VM_LOCKED) {
-		*mapcount = 1;	/* break early from loop */
+		*mapcount = 0;	/* break early from loop */
 		*vm_flags |= VM_LOCKED;
-		goto out_unmap;
+		goto out;
 	}
 
+	pte = page_check_address(page, mm, address, &ptl, 0);
+	if (!pte)
+		goto out;
+
 	if (ptep_clear_flush_young_notify(vma, address, pte)) {
 		/*
 		 * Don't treat a reference through a sequentially read
@@ -416,7 +416,6 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
 
-out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
