Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2D3FD8D0041
	for <linux-mm@kvack.org>; Sun, 27 Mar 2011 22:03:44 -0400 (EDT)
Subject: [PATCH]mmap: not merge cloned VMA
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Mar 2011 09:58:54 +0800
Message-ID: <1301277534.3981.26.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

Avoid merging a VMA with another VMA which is cloned from parent process. The
cloned VMA shares lock with parent process's VMA. If we do the merge, more vma
area (even the new range is only for current process) uses perent process's
anon_vma lock, so introduces scalability issues.
find_mergeable_anon_vma already considers this.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 mm/mmap.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

Index: linux/mm/mmap.c
===================================================================
--- linux.orig/mm/mmap.c	2011-03-24 09:37:28.000000000 +0800
+++ linux/mm/mmap.c	2011-03-24 09:48:37.000000000 +0800
@@ -699,9 +699,13 @@ static inline int is_mergeable_vma(struc
 }
 
 static inline int is_mergeable_anon_vma(struct anon_vma *anon_vma1,
-					struct anon_vma *anon_vma2)
+					struct anon_vma *anon_vma2,
+					struct vm_area_struct *vma)
 {
-	return !anon_vma1 || !anon_vma2 || (anon_vma1 == anon_vma2);
+	if ((!anon_vma1 || !anon_vma2) && (!vma ||
+		list_is_singular(&vma->anon_vma_chain)))
+		return 1;
+	return anon_vma1 == anon_vma2;
 }
 
 /*
@@ -720,7 +724,7 @@ can_vma_merge_before(struct vm_area_stru
 	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
 {
 	if (is_mergeable_vma(vma, file, vm_flags) &&
-	    is_mergeable_anon_vma(anon_vma, vma->anon_vma)) {
+	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		if (vma->vm_pgoff == vm_pgoff)
 			return 1;
 	}
@@ -739,7 +743,7 @@ can_vma_merge_after(struct vm_area_struc
 	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
 {
 	if (is_mergeable_vma(vma, file, vm_flags) &&
-	    is_mergeable_anon_vma(anon_vma, vma->anon_vma)) {
+	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		pgoff_t vm_pglen;
 		vm_pglen = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
 		if (vma->vm_pgoff + vm_pglen == vm_pgoff)
@@ -817,7 +821,7 @@ struct vm_area_struct *vma_merge(struct
 				can_vma_merge_before(next, vm_flags,
 					anon_vma, file, pgoff+pglen) &&
 				is_mergeable_anon_vma(prev->anon_vma,
-						      next->anon_vma)) {
+						      next->anon_vma, NULL)) {
 							/* cases 1, 6 */
 			err = vma_adjust(prev, prev->vm_start,
 				next->vm_end, prev->vm_pgoff, NULL);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
