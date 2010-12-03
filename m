Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B5C4A6B008C
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 19:17:22 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id oB30HKJ3031280
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 16:17:20 -0800
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by kpbe14.cbf.corp.google.com with ESMTP id oB30HJBx020263
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 16:17:19 -0800
Received: by pxi15 with SMTP id 15so1453113pxi.33
        for <linux-mm@kvack.org>; Thu, 02 Dec 2010 16:17:18 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 3/6] mm: move VM_LOCKED check to __mlock_vma_pages_range()
Date: Thu,  2 Dec 2010 16:16:49 -0800
Message-Id: <1291335412-16231-4-git-send-email-walken@google.com>
In-Reply-To: <1291335412-16231-1-git-send-email-walken@google.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Use a single code path for faulting in pages during mlock.

The reason to have it in this patch series is that I did not want to
update both code paths in a later change that releases mmap_sem when
blocking on disk.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/mlock.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 0531173..241a5d2 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -169,7 +169,7 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	VM_BUG_ON(end   > vma->vm_end);
 	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
-	gup_flags = FOLL_TOUCH | FOLL_MLOCK;
+	gup_flags = FOLL_TOUCH;
 	/*
 	 * We want to touch writable mappings with a write fault in order
 	 * to break COW, except for shared mappings because these don't COW
@@ -178,6 +178,9 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
 		gup_flags |= FOLL_WRITE;
 
+	if (vma->vm_flags & VM_LOCKED)
+		gup_flags |= FOLL_MLOCK;
+
 	/* We don't try to access the guard page of a stack vma */
 	if (stack_guard_page(vma, start)) {
 		addr += PAGE_SIZE;
@@ -456,14 +459,11 @@ static int do_mlock_pages(unsigned long start, size_t len)
 		/*
 		 * Now fault in a range of pages within the first VMA.
 		 */
-		if (vma->vm_flags & VM_LOCKED) {
-			ret = __mlock_vma_pages_range(vma, nstart, nend);
-			if (ret) {
-				ret = __mlock_posix_error_return(ret);
-				break;
-			}
-		} else
-			make_pages_present(nstart, nend);
+		ret = __mlock_vma_pages_range(vma, nstart, nend);
+		if (ret) {
+			ret = __mlock_posix_error_return(ret);
+			break;
+		}
 	}
 	up_read(&mm->mmap_sem);
 	return ret;	/* 0 or negative error code */
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
