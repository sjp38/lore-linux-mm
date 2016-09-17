Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A4E4A6B025E
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 12:05:18 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id n185so128653194qke.2
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 09:05:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h63si7344696ybb.147.2016.09.17.09.05.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Sep 2016 09:05:18 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] mm: vma_merge: fix vm_page_prot SMP race condition against rmap_walk
Date: Sat, 17 Sep 2016 18:05:15 +0200
Message-Id: <1474128315-22726-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1474128315-22726-1-git-send-email-aarcange@redhat.com>
References: <20160916205441.GB4743@redhat.com>
 <1474128315-22726-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Vorlicek <janvorli@microsoft.com>, Aditya Mandaleeka <adityam@microsoft.com>

The rmap_walk can access vm_page_prot (and potentially vm_flags in the
pte/pmd manipulations). So it's not safe to wait the caller to update
the vm_page_prot/vm_flags after vma_merge returned potentially
removing the "next" vma and extending the "current" vma over the
next->vm_start,vm_end range, but still with the "current" vma
vm_page_prot, after releasing the rmap locks.

The vm_page_prot/vm_flags must be transferred from the "next" vma to
the current vma while vma_merge still holds the rmap locks.

The side effect of this race condition is pte corruption during
migrate as remove_migration_ptes when run on a address of the "next"
vma that got removed, used the vm_page_prot of the current vma.

migrate	     	      	        mprotect
------------			-------------
migrating in "next" vma
				vma_merge() # removes "next" vma and
			        	    # extends "current" vma
					    # current vma is not with
					    # vm_page_prot updated
remove_migration_ptes
read vm_page_prot of current "vma"
establish pte with wrong permissions
				vm_set_page_prot(vma) # too late!
				change_protection in the old vma range
				only, next range is not updated

This caused segmentation faults and potentially memory corruption in
heavy mprotect loads with some light page migration caused by
compaction in the background.

v2: limit the scope to case 8 after review from Hugh Dickins.

Reported-by: Aditya Mandaleeka <adityam@microsoft.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mmap.c | 40 +++++++++++++++++++++++++++++++++++++---
 1 file changed, 37 insertions(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f86fd39..2043a97 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -727,6 +727,25 @@ again:
 			vma_interval_tree_remove(next, root);
 	}
 
+	if (remove_next == 1) {
+		/*
+		 * vm_page_prot and vm_flags can be read by the
+		 * rmap_walk, for example in remove_migration_ptes(),
+		 * so before releasing the rmap locks the permissions
+		 * of the expanded vmas must be already the correct
+		 * one for the whole merged range.
+		 *
+		 * mprotect case 8 (which sets remove_next == 1) needs
+		 * special handling to provide the above guarantee, as
+		 * it is the only case where the "vma" that is being
+		 * expanded is the one with the wrong permissions for
+		 * the whole merged region. So copy the right
+		 * permissions from the next one that is getting
+		 * removed before releasing the rmap locks.
+		 */
+		vma->vm_page_prot = next->vm_page_prot;
+		vma->vm_flags = next->vm_flags;
+	}
 	if (start != vma->vm_start) {
 		vma->vm_start = start;
 		start_changed = true;
@@ -807,7 +826,16 @@ again:
 		 */
 		next = vma->vm_next;
 		if (remove_next == 2) {
-			remove_next = 1;
+			/*
+			 * No need to transfer vm_page_prot/vm_flags
+			 * in the remove_next == 2 case,
+			 * vma_page_prot/vm_flags of the "vma" was
+			 * already the correct one for the whole range
+			 * in mprotect case 6. So set remove_next to 3
+			 * to skip that. It wouldn't hurt to execute
+			 * it but it's superfluous.
+			 */
+			remove_next = 3;
 			end = next->vm_end;
 			goto again;
 		}
@@ -939,8 +967,14 @@ can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
  *    PPPP    NNNN    PPPPPPPPPPPP    PPPPPPPPNNNN    PPPPNNNNNNNN
  *    might become    case 1 below    case 2 below    case 3 below
  *
- * Odd one out? Case 8, because it extends NNNN but needs flags of XXXX:
- * mprotect_fixup updates vm_flags & vm_page_prot on successful return.
+ * Odd one out? Case 8, because it extends NNNN but needs the
+ * properties of XXXX. In turn the vma_merge caller must update the
+ * properties on successful return of vma_merge. An update in the
+ * caller of those properties is only ok if those properties are never
+ * accessed through rmap_walks (i.e. without the mmap_sem). The
+ * vm_page_prot/vm_flags (which may be accessed by rmap_walks) must be
+ * transferred from XXXX to NNNN in case 8 before releasing the rmap
+ * locks.
  */
 struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			struct vm_area_struct *prev, unsigned long addr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
