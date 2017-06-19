Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DEB346B03AD
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 08:45:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 77so2829233wrb.11
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 05:45:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a18si10169578wrd.355.2017.06.19.05.45.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 05:45:32 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5JCd3W6039997
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 08:45:30 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b5uhbsb6v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 08:45:30 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 19 Jun 2017 13:45:29 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] userfaultfd: non-cooperative: add madvise() event for MADV_FREE request
Date: Mon, 19 Jun 2017 15:45:11 +0300
Message-Id: <1497876311-18615-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

MADV_FREE is identical to MADV_DONTNEED from the point of view of uffd
monitor. The monitor has to stop handling #PF events in the range being
freed. We are reusing userfaultfd_remove callback along with the logic
required to re-get and re-validate the VMA which may change or disappear
because userfaultfd_remove releases mmap_sem.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/madvise.c | 42 ++++++++++++++++++++++--------------------
 1 file changed, 22 insertions(+), 20 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 25b78ee..4162bbd 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -451,9 +451,6 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
 	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_gather tlb;
 
-	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
-		return -EINVAL;
-
 	/* MADV_FREE works for only anon vma at the moment */
 	if (!vma_is_anonymous(vma))
 		return -EINVAL;
@@ -477,14 +474,6 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
 	return 0;
 }
 
-static long madvise_free(struct vm_area_struct *vma,
-			     struct vm_area_struct **prev,
-			     unsigned long start, unsigned long end)
-{
-	*prev = vma;
-	return madvise_free_single_vma(vma, start, end);
-}
-
 /*
  * Application no longer needs these pages.  If the pages are dirty,
  * it's OK to just throw them away.  The app will be more careful about
@@ -504,9 +493,17 @@ static long madvise_free(struct vm_area_struct *vma,
  * An interface that causes the system to free clean pages and flush
  * dirty pages is already available as msync(MS_INVALIDATE).
  */
-static long madvise_dontneed(struct vm_area_struct *vma,
-			     struct vm_area_struct **prev,
-			     unsigned long start, unsigned long end)
+static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
+					unsigned long start, unsigned long end)
+{
+	zap_page_range(vma, start, end - start);
+	return 0;
+}
+
+static long madvise_dontneed_free(struct vm_area_struct *vma,
+				  struct vm_area_struct **prev,
+				  unsigned long start, unsigned long end,
+				  int behavior)
 {
 	*prev = vma;
 	if (!can_madv_dontneed_vma(vma))
@@ -526,7 +523,8 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 			 * is also < vma->vm_end. If start <
 			 * vma->vm_start it means an hole materialized
 			 * in the user address space within the
-			 * virtual range passed to MADV_DONTNEED.
+			 * virtual range passed to MADV_DONTNEED
+			 * or MADV_FREE.
 			 */
 			return -ENOMEM;
 		}
@@ -537,7 +535,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 			 * Don't fail if end > vma->vm_end. If the old
 			 * vma was splitted while the mmap_sem was
 			 * released the effect of the concurrent
-			 * operation may not cause MADV_DONTNEED to
+			 * operation may not cause madvise() to
 			 * have an undefined result. There may be an
 			 * adjacent next vma that we'll walk
 			 * next. userfaultfd_remove() will generate an
@@ -549,8 +547,13 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 		}
 		VM_WARN_ON(start >= end);
 	}
-	zap_page_range(vma, start, end - start);
-	return 0;
+
+	if (behavior == MADV_DONTNEED)
+		return madvise_dontneed_single_vma(vma, start, end);
+	else if (behavior == MADV_FREE)
+		return madvise_free_single_vma(vma, start, end);
+	else
+		return -EINVAL;
 }
 
 /*
@@ -656,9 +659,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_FREE:
-		return madvise_free(vma, prev, start, end);
 	case MADV_DONTNEED:
-		return madvise_dontneed(vma, prev, start, end);
+		return madvise_dontneed_free(vma, prev, start, end, behavior);
 	default:
 		return madvise_behavior(vma, prev, start, end, behavior);
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
