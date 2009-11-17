Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 448996B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 03:39:32 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAH8dTpr001744
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 17:39:29 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9706245DE7A
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 17:39:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 751EA45DE6E
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 17:39:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 49E7B1DB8040
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 17:39:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFC861DB8041
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 17:39:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH]  [for mmotm-1113] mm: Simplify try_to_unmap_one()
Message-Id: <20091117173759.3DF6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 17:39:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

SWAP_MLOCK mean "We marked the page as PG_MLOCK, please move it to
unevictable-lru". So, following code is easy confusable.

        if (vma->vm_flags & VM_LOCKED) {
                ret = SWAP_MLOCK;
                goto out_unmap;
        }

Plus, if the VMA doesn't have VM_LOCKED, We don't need to check
the needed of calling mlock_vma_page().

Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/rmap.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 82e31fb..70dec01 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -779,10 +779,9 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	 * skipped over this mm) then we should reactivate it.
 	 */
 	if (!(flags & TTU_IGNORE_MLOCK)) {
-		if (vma->vm_flags & VM_LOCKED) {
-			ret = SWAP_MLOCK;
-			goto out_unmap;
-		}
+		if (vma->vm_flags & VM_LOCKED)
+			goto out_mlock;
+
 		if (TTU_ACTION(flags) == TTU_MUNLOCK)
 			goto out_unmap;
 	}
@@ -855,18 +854,19 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+out:
+	return ret;
 
-	if (ret == SWAP_MLOCK) {
-		ret = SWAP_AGAIN;
-		if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
-			if (vma->vm_flags & VM_LOCKED) {
-				mlock_vma_page(page);
-				ret = SWAP_MLOCK;
-			}
-			up_read(&vma->vm_mm->mmap_sem);
+out_mlock:
+	pte_unmap_unlock(pte, ptl);
+
+	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+		if (vma->vm_flags & VM_LOCKED) {
+			mlock_vma_page(page);
+			ret = SWAP_MLOCK;
 		}
+		up_read(&vma->vm_mm->mmap_sem);
 	}
-out:
 	return ret;
 }
 
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
