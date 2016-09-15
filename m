Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75B4F6B0069
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 13:41:48 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id e2so94266417ybi.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 10:41:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h64si1997565ywf.471.2016.09.15.10.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 10:41:47 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/2] mm: vma_merge: fix race vm_page_prot race condition against rmap_walk
Date: Thu, 15 Sep 2016 19:41:44 +0200
Message-Id: <1473961304-19370-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1473961304-19370-1-git-send-email-aarcange@redhat.com>
References: <1473961304-19370-1-git-send-email-aarcange@redhat.com>
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

Reported-by: Aditya Mandaleeka <adityam@microsoft.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mmap.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 1abf106..b381978 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -633,9 +633,10 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	bool start_changed = false, end_changed = false;
 	long adjust_next = 0;
 	int remove_next = 0;
+	struct vm_area_struct *importer = NULL;
 
 	if (next && !insert) {
-		struct vm_area_struct *exporter = NULL, *importer = NULL;
+		struct vm_area_struct *exporter = NULL;
 
 		if (end >= next->vm_end) {
 			/*
@@ -729,6 +730,17 @@ again:
 			vma_interval_tree_remove(next, root);
 	}
 
+	if (importer == vma) {
+		/*
+		 * vm_page_prot and vm_flags can be read by the
+		 * rmap_walk, for example in
+		 * remove_migration_ptes(). Before releasing the rmap
+		 * locks the current vma must match the next that we
+		 * merged with for those fields.
+		 */
+		importer->vm_page_prot = next->vm_page_prot;
+		importer->vm_flags = next->vm_flags;
+	}
 	if (start != vma->vm_start) {
 		vma->vm_start = start;
 		start_changed = true;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
