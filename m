Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 19D146B0314
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g143so37709698wme.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 1si20453451wre.175.2017.05.24.04.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 04:20:23 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OB9jfx007219
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:22 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2an78mx8e1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:22 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 24 May 2017 12:20:20 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v2 05/10] mm: Add a range lock parameter to userfaultfd_remove()
Date: Wed, 24 May 2017 13:19:56 +0200
In-Reply-To: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1495624801-8063-6-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

As __mcopy_atomic_hugetlb() called by userfaultfd_remove() may unlock
the mmap_sem, it has to know about the range of lock when dealing with
range lock.

This patch adds a new range_lock pointer parameter to
userfaultfd_remove() and handles it in the callees.

On the otherside, userfaultfd_remove()'s callers are touched to deal
with the range parameter as well.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 fs/userfaultfd.c              |  8 ++++++--
 include/linux/userfaultfd_k.h | 28 ++++++++++++++++++++++++----
 mm/madvise.c                  | 42 +++++++++++++++++++++++++++++++++---------
 mm/userfaultfd.c              | 18 +++++++++++++++---
 4 files changed, 78 insertions(+), 18 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index b3daffc589a2..7d56c21ef65d 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -703,8 +703,12 @@ void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *vm_ctx,
 	userfaultfd_event_wait_completion(ctx, &ewq);
 }
 
-bool userfaultfd_remove(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end)
+bool _userfaultfd_remove(struct vm_area_struct *vma,
+			 unsigned long start, unsigned long end
+#ifdef CONFIG_MEM_RANGE_LOCK
+			 , struct range_lock *range
+#endif
+	)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct userfaultfd_ctx *ctx;
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 48a3483dccb1..07c3dbddc021 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -61,9 +61,18 @@ extern void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *,
 					unsigned long from, unsigned long to,
 					unsigned long len);
 
-extern bool userfaultfd_remove(struct vm_area_struct *vma,
-			       unsigned long start,
-			       unsigned long end);
+#ifdef CONFIG_MEM_RANGE_LOCK
+extern bool _userfaultfd_remove(struct vm_area_struct *vma,
+				unsigned long start,
+				unsigned long end,
+				struct range_lock *range);
+#define userfaultfd_remove _userfaultfd_remove
+#else
+extern bool _userfaultfd_remove(struct vm_area_struct *vma,
+				unsigned long start,
+				unsigned long end);
+#define userfaultfd_remove(v, s, e, r) _userfaultfd_remove(v, s, e)
+#endif /* CONFIG_MEM_RANGE_LOCK */
 
 extern int userfaultfd_unmap_prep(struct vm_area_struct *vma,
 				  unsigned long start, unsigned long end,
@@ -117,12 +126,23 @@ static inline void mremap_userfaultfd_complete(struct vm_userfaultfd_ctx *ctx,
 {
 }
 
+#ifdef CONFIG_MEM_RANGE_LOCK
 static inline bool userfaultfd_remove(struct vm_area_struct *vma,
 				      unsigned long start,
-				      unsigned long end)
+				      unsigned long end,
+				      struct range_lock *range)
 {
 	return true;
 }
+#else
+static inline bool _userfaultfd_remove(struct vm_area_struct *vma,
+				       unsigned long start,
+				       unsigned long end)
+{
+	return true;
+}
+#define userfaultfd_remove(v, s, e, r) _userfaultfd_remove(v, s, e)
+#endif
 
 static inline int userfaultfd_unmap_prep(struct vm_area_struct *vma,
 					 unsigned long start, unsigned long end,
diff --git a/mm/madvise.c b/mm/madvise.c
index 25b78ee4fc2c..437f35778f07 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -506,13 +506,17 @@ static long madvise_free(struct vm_area_struct *vma,
  */
 static long madvise_dontneed(struct vm_area_struct *vma,
 			     struct vm_area_struct **prev,
-			     unsigned long start, unsigned long end)
+			     unsigned long start, unsigned long end
+#ifdef CONFIG_MEM_RANGE_LOCK
+			     , struct range_lock *range
+#endif
+	)
 {
 	*prev = vma;
 	if (!can_madv_dontneed_vma(vma))
 		return -EINVAL;
 
-	if (!userfaultfd_remove(vma, start, end)) {
+	if (!userfaultfd_remove(vma, start, end, range)) {
 		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
 
 		down_read(&current->mm->mmap_sem);
@@ -558,8 +562,12 @@ static long madvise_dontneed(struct vm_area_struct *vma,
  * This is effectively punching a hole into the middle of a file.
  */
 static long madvise_remove(struct vm_area_struct *vma,
-				struct vm_area_struct **prev,
-				unsigned long start, unsigned long end)
+			   struct vm_area_struct **prev,
+			   unsigned long start, unsigned long end
+#ifdef CONFIG_MEM_RANGE_LOCK
+			   , struct range_lock *range
+#endif
+	)
 {
 	loff_t offset;
 	int error;
@@ -589,7 +597,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 	 * mmap_sem.
 	 */
 	get_file(f);
-	if (userfaultfd_remove(vma, start, end)) {
+	if (userfaultfd_remove(vma, start, end, NULL)) {
 		/* mmap_sem was not released by userfaultfd_remove() */
 		up_read(&current->mm->mmap_sem);
 	}
@@ -648,17 +656,29 @@ static int madvise_inject_error(int behavior,
 
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
-		unsigned long start, unsigned long end, int behavior)
+	    unsigned long start, unsigned long end, int behavior
+#ifdef CONFIG_MEM_RANGE_LOCK
+	    , struct range_lock *range
+#endif
+	)
 {
 	switch (behavior) {
 	case MADV_REMOVE:
-		return madvise_remove(vma, prev, start, end);
+		return madvise_remove(vma, prev, start, end
+#ifdef CONFIG_MEM_RANGE_LOCK
+				      , range
+#endif
+			);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_FREE:
 		return madvise_free(vma, prev, start, end);
 	case MADV_DONTNEED:
-		return madvise_dontneed(vma, prev, start, end);
+		return madvise_dontneed(vma, prev, start, end
+#ifdef CONFIG_MEM_RANGE_LOCK
+					, range
+#endif
+			);
 	default:
 		return madvise_behavior(vma, prev, start, end, behavior);
 	}
@@ -826,7 +846,11 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 			tmp = end;
 
 		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
-		error = madvise_vma(vma, &prev, start, tmp, behavior);
+		error = madvise_vma(vma, &prev, start, tmp, behavior
+#ifdef CONFIG_MEM_RANGE_LOCK
+				    , &range
+#endif
+			);
 		if (error)
 			goto out;
 		start = tmp;
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 8bcb501bce60..ae2babc46fa5 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -156,7 +156,11 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 					      unsigned long dst_start,
 					      unsigned long src_start,
 					      unsigned long len,
-					      bool zeropage)
+					      bool zeropage
+#ifdef CONFIG_MEM_RANGE_LOCK
+					      , struct range_lock *range
+#endif
+					      )
 {
 	int vm_alloc_shared = dst_vma->vm_flags & VM_SHARED;
 	int vm_shared = dst_vma->vm_flags & VM_SHARED;
@@ -368,7 +372,11 @@ extern ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 				      unsigned long dst_start,
 				      unsigned long src_start,
 				      unsigned long len,
-				      bool zeropage);
+				      bool zeropage
+#ifdef CONFIG_MEM_RANGE_LOCK
+				      , struct range_lock *range
+#endif
+				      );
 #endif /* CONFIG_HUGETLB_PAGE */
 
 static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
@@ -439,7 +447,11 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 */
 	if (is_vm_hugetlb_page(dst_vma))
 		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
-						src_start, len, zeropage);
+					       src_start, len, zeropage
+#ifdef CONFIG_MEM_RANGE_LOCK
+					       , &range
+#endif
+					       );
 
 	if (!vma_is_anonymous(dst_vma) && !vma_is_shmem(dst_vma))
 		goto out_unlock;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
