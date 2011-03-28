Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 32A2D8D003B
	for <linux-mm@kvack.org>; Sun, 27 Mar 2011 22:03:43 -0400 (EDT)
Subject: [PATCH]mmap: avoid unnecessary anon_vma lock
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Mar 2011 09:58:52 +0800
Message-ID: <1301277532.3981.25.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

If we only change vma->vm_end, we can avoid taking anon_vma lock even 'insert'
isn't NULL, which is the case of split_vma.
>From my understanding, we need the lock before because rmap must get the
'insert' VMA when we adjust old VMA's vm_end (the 'insert' VMA is linked to
anon_vma list in __insert_vm_struct before).
But now this isn't true any more. The 'insert' VMA is already linked to
anon_vma list in __split_vma(with anon_vma_clone()) instead of
__insert_vm_struct. There is no race rmap can't get required VMAs.
So the anon_vma lock is unnecessary, and this can reduce one locking in brk
case and improve scalability.

Signed-off-by: Shaohua Li<shaohua.li@intel.com>

---
 mm/mmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/mm/mmap.c
===================================================================
--- linux.orig/mm/mmap.c	2011-03-24 09:08:27.000000000 +0800
+++ linux/mm/mmap.c	2011-03-24 09:14:03.000000000 +0800
@@ -605,7 +605,7 @@ again:			remove_next = 1 + (end > next->
 	 * lock may be shared between many sibling processes.  Skipping
 	 * the lock for brk adjustments makes a difference sometimes.
 	 */
-	if (vma->anon_vma && (insert || importer || start != vma->vm_start)) {
+	if (vma->anon_vma && (importer || start != vma->vm_start)) {
 		anon_vma = vma->anon_vma;
 		anon_vma_lock(anon_vma);
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
