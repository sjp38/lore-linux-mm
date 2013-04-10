Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 8E7F16B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 19:45:08 -0400 (EDT)
Subject: [PATCH] mm: madvise: complete input validation before taking lock
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Wed, 10 Apr 2013 23:45:06 +0000
Message-ID: <u0leheij6gt.fsf@orc05.imf.au.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

In madvise(), there doesn't seem to be any reason for taking the
&current->mm->mmap_sem before start and len_in have been
validated. Incidentally, this removes the need for the out: label.


Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---

diff --git a/mm/madvise.c b/mm/madvise.c
index c58c94b..d2ae668 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -473,27 +473,27 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	if (!madvise_behavior_valid(behavior))
 		return error;
 
-	write = madvise_need_mmap_write(behavior);
-	if (write)
-		down_write(&current->mm->mmap_sem);
-	else
-		down_read(&current->mm->mmap_sem);
-
 	if (start & ~PAGE_MASK)
-		goto out;
+		return error;
 	len = (len_in + ~PAGE_MASK) & PAGE_MASK;
 
 	/* Check to see whether len was rounded up from small -ve to zero */
 	if (len_in && !len)
-		goto out;
+		return error;
 
 	end = start + len;
 	if (end < start)
-		goto out;
+		return error;
 
 	error = 0;
 	if (end == start)
-		goto out;
+		return error;
+
+	write = madvise_need_mmap_write(behavior);
+	if (write)
+		down_write(&current->mm->mmap_sem);
+	else
+		down_read(&current->mm->mmap_sem);
 
 	/*
 	 * If the interval [start,end) covers some unmapped address
@@ -541,7 +541,6 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	}
 out_plug:
 	blk_finish_plug(&plug);
-out:
 	if (write)
 		up_write(&current->mm->mmap_sem);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
