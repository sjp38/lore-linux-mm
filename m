Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE3D6B0012
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:06 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id w16so10033166plp.20
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3-v6si6253178plq.540.2018.02.04.17.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 20/64] mm/madvise: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:10 +0100
Message-Id: <20180205012754.23615-21-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

mmap_sem users are already aware of mmrange, thus a
straightforward conversion. No changes in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/madvise.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index eaec6bfc2b08..de8fb035955c 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -532,7 +532,7 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
 	if (!userfaultfd_remove(vma, start, end)) {
 		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, mmrange);
 		vma = find_vma(current->mm, start);
 		if (!vma)
 			return -ENOMEM;
@@ -582,7 +582,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
  */
 static long madvise_remove(struct vm_area_struct *vma,
 				struct vm_area_struct **prev,
-				unsigned long start, unsigned long end)
+				unsigned long start, unsigned long end,
+				struct range_lock *mmrange)
 {
 	loff_t offset;
 	int error;
@@ -614,13 +615,13 @@ static long madvise_remove(struct vm_area_struct *vma,
 	get_file(f);
 	if (userfaultfd_remove(vma, start, end)) {
 		/* mmap_sem was not released by userfaultfd_remove() */
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, mmrange);
 	}
 	error = vfs_fallocate(f,
 				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
 				offset, end - start);
 	fput(f);
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, mmrange);
 	return error;
 }
 
@@ -690,7 +691,7 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 {
 	switch (behavior) {
 	case MADV_REMOVE:
-		return madvise_remove(vma, prev, start, end);
+		return madvise_remove(vma, prev, start, end, mmrange);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end, mmrange);
 	case MADV_FREE:
@@ -809,6 +810,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	int write;
 	size_t len;
 	struct blk_plug plug;
+
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 	if (!madvise_behavior_valid(behavior))
 		return error;
@@ -836,10 +838,10 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 
 	write = madvise_need_mmap_write(behavior);
 	if (write) {
-		if (down_write_killable(&current->mm->mmap_sem))
+		if (mm_write_lock_killable(current->mm, &mmrange))
 			return -EINTR;
 	} else {
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 	}
 
 	/*
@@ -889,9 +891,9 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 out:
 	blk_finish_plug(&plug);
 	if (write)
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm, &mmrange);
 	else
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 
 	return error;
 }
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
