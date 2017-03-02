Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB1156B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 12:37:42 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id 9so108643205qkk.6
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:37:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t127si7403083qkf.315.2017.03.02.09.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 09:37:41 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/3] userfaultfd: non-cooperative: userfaultfd_remove revalidate vma in MADV_DONTNEED
Date: Thu,  2 Mar 2017 18:37:37 +0100
Message-Id: <20170302173738.18994-3-aarcange@redhat.com>
In-Reply-To: <20170302173738.18994-1-aarcange@redhat.com>
References: <20170302173738.18994-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

userfaultfd_remove() has to be execute before zapping the pagetables or
UFFDIO_COPY could keep filling pages after zap_page_range returned,
which would result in non zero data after a MADV_DONTNEED.

However userfaultfd_remove() may have to release the mmap_sem. This
was handled correctly in MADV_REMOVE, but MADV_DONTNEED accessed a
potentially stale vma (the very vma passed to zap_page_range(vma, ...)).

The fix consists in revalidating the vma in case userfaultfd_remove()
had to release the mmap_sem.

This also optimizes away an unnecessary down_read/up_read in the
MADV_REMOVE case if UFFD_EVENT_FORK had to be delivered.

It all remains zero runtime cost in case CONFIG_USERFAULTFD=n as
userfaultfd_remove() will be defined as "true" at build time.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c              |  9 +++------
 include/linux/userfaultfd_k.h |  7 +++----
 mm/madvise.c                  | 44 ++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 47 insertions(+), 13 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 5087a69..2104811 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -694,8 +694,7 @@ void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *vm_ctx,
 	userfaultfd_event_wait_completion(ctx, &ewq);
 }
 
-void userfaultfd_remove(struct vm_area_struct *vma,
-			struct vm_area_struct **prev,
+bool userfaultfd_remove(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -704,13 +703,11 @@ void userfaultfd_remove(struct vm_area_struct *vma,
 
 	ctx = vma->vm_userfaultfd_ctx.ctx;
 	if (!ctx || !(ctx->features & UFFD_FEATURE_EVENT_REMOVE))
-		return;
+		return true;
 
 	userfaultfd_ctx_get(ctx);
 	up_read(&mm->mmap_sem);
 
-	*prev = NULL; /* We wait for ACK w/o the mmap semaphore */
-
 	msg_init(&ewq.msg);
 
 	ewq.msg.event = UFFD_EVENT_REMOVE;
@@ -719,7 +716,7 @@ void userfaultfd_remove(struct vm_area_struct *vma,
 
 	userfaultfd_event_wait_completion(ctx, &ewq);
 
-	down_read(&mm->mmap_sem);
+	return false;
 }
 
 static bool has_unmap_ctx(struct userfaultfd_ctx *ctx, struct list_head *unmaps,
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index f2b79bf..48a3483 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -61,8 +61,7 @@ extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *,
 					unsigned long from, unsigned long to,
 					unsigned long len);
 
-extern void userfaultfd_remove(struct vm_area_struct *vma,
-			       struct vm_area_struct **prev,
+extern bool userfaultfd_remove(struct vm_area_struct *vma,
 			       unsigned long start,
 			       unsigned long end);
 
@@ -118,11 +117,11 @@ static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *ctx,
 {
 }
 
-static inline void userfaultfd_remove(struct vm_area_struct *vma,
-				      struct vm_area_struct **prev,
+static inline bool userfaultfd_remove(struct vm_area_struct *vma,
 				      unsigned long start,
 				      unsigned long end)
 {
+	return true;
 }
 
 static inline int userfaultfd_unmap_prep(struct vm_area_struct *vma,
diff --git a/mm/madvise.c b/mm/madvise.c
index dc5927c..7a2abf0 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -513,7 +513,43 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 	if (!can_madv_dontneed_vma(vma))
 		return -EINVAL;
 
-	userfaultfd_remove(vma, prev, start, end);
+	if (!userfaultfd_remove(vma, start, end)) {
+		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
+
+		down_read(&current->mm->mmap_sem);
+		vma = find_vma(current->mm, start);
+		if (!vma)
+			return -ENOMEM;
+		if (start < vma->vm_start) {
+			/*
+			 * This "vma" under revalidation is the one
+			 * with the lowest vma->vm_start where start
+			 * is also < vma->vm_end. If start <
+			 * vma->vm_start it means an hole materialized
+			 * in the user address space within the
+			 * virtual range passed to MADV_DONTNEED.
+			 */
+			return -ENOMEM;
+		}
+		if (!can_madv_dontneed_vma(vma))
+			return -EINVAL;
+		if (end > vma->vm_end) {
+			/*
+			 * Don't fail if end > vma->vm_end. If the old
+			 * vma was splitted while the mmap_sem was
+			 * released the effect of the concurrent
+			 * operation may not cause MADV_DONTNEED to
+			 * have an undefined result. There may be an
+			 * adjacent next vma that we'll walk
+			 * next. userfaultfd_remove() will generate an
+			 * UFFD_EVENT_REMOVE repetition on the
+			 * end-vma->vm_end range, but the manager can
+			 * handle a repetition fine.
+			 */
+			end = vma->vm_end;
+		}
+		VM_WARN_ON(start >= end);
+	}
 	zap_page_range(vma, start, end - start);
 	return 0;
 }
@@ -554,8 +590,10 @@ static long madvise_remove(struct vm_area_struct *vma,
 	 * mmap_sem.
 	 */
 	get_file(f);
-	userfaultfd_remove(vma, prev, start, end);
-	up_read(&current->mm->mmap_sem);
+	if (userfaultfd_remove(vma, start, end)) {
+		/* mmap_sem was not released by userfaultfd_remove() */
+		up_read(&current->mm->mmap_sem);
+	}
 	error = vfs_fallocate(f,
 				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
 				offset, end - start);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
