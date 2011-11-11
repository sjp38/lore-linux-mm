Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 552DC6B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 07:53:26 -0500 (EST)
Received: by wyg24 with SMTP id 24so5137604wyg.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 04:53:23 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Nov 2011 20:53:23 +0800
Message-ID: <CAJd=RBAhHS4txg-2tnJyER=GeT4X95z6COMzJvRhcwFgXu6oOA@mail.gmail.com>
Subject: [PATCH] mmap: fix loop when adjusting vma
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

If we have more work to do after one vma is removed, we have to reload @end in
case it is clobbered, then try again.

Thanks

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/mmap.c	Fri Nov 11 20:35:46 2011
+++ b/mm/mmap.c	Fri Nov 11 20:41:32 2011
@@ -490,6 +490,7 @@ __vma_unlink(struct mm_struct *mm, struc
 int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
 {
+	unsigned long saved_end = end;
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *next = vma->vm_next;
 	struct vm_area_struct *importer = NULL;
@@ -634,7 +635,14 @@ again:			remove_next = 1 + (end > next->
 		 */
 		if (remove_next == 2) {
 			next = vma->vm_next;
-			goto again;
+			if (next) {
+				/*
+				 * we have more work, reload @end in case
+				 * it is clobbered.
+				 */
+				end = saved_end;
+				goto again;
+			}
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
