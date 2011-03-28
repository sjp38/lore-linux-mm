Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 50FB58D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:57:07 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id 32so783784pzk.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 06:57:06 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 2/6] nommu: don't scan the vma list when deleting
Date: Mon, 28 Mar 2011 22:56:43 +0900
Message-Id: <1301320607-7259-3-git-send-email-namhyung@gmail.com>
In-Reply-To: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
References: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, David Howells <dhowells@redhat.com>, Greg Ungerer <gerg@snapgear.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since the commit 297c5eee3724 ("mm: make the vma list be doubly linked")
made it a doubly linked list, we don't need to scan the list when
deleting @vma.

And the original code didn't update the prev pointer. Fix it too.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/nommu.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 20d9c330eb0e..a6a073f0745a 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -770,7 +770,6 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
  */
 static void delete_vma_from_mm(struct vm_area_struct *vma)
 {
-	struct vm_area_struct **pp;
 	struct address_space *mapping;
 	struct mm_struct *mm = vma->vm_mm;
 
@@ -793,12 +792,14 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 
 	/* remove from the MM's tree and list */
 	rb_erase(&vma->vm_rb, &mm->mm_rb);
-	for (pp = &mm->mmap; *pp; pp = &(*pp)->vm_next) {
-		if (*pp == vma) {
-			*pp = vma->vm_next;
-			break;
-		}
-	}
+
+	if (vma->vm_prev)
+		vma->vm_prev->vm_next = vma->vm_next;
+	else
+		mm->mmap = vma->vm_next;
+
+	if (vma->vm_next)
+		vma->vm_next->vm_prev = vma->vm_prev;
 
 	vma->vm_mm = NULL;
 }
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
