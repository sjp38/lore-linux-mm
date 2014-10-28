Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8F4900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 10:40:53 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so815948pde.32
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 07:40:53 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yh6si1468638pab.171.2014.10.28.07.40.52
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 07:40:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mremap: take anon_vma lock in shared mode
Date: Tue, 28 Oct 2014 16:40:37 +0200
Message-Id: <1414507237-114852-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, walken@google.com, aarcange@redhat.com, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There's no modification to anon_vma interval tree. We only need to
serialize against exclusive rmap walker who want s to catch all ptes the
page is mapped with. Shared lock is enough for that.

Suggested-by: Davidlohr Bueso <dbueso@suse.de>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mremap.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index c855922497a3..1e35ba664406 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -123,7 +123,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		}
 		if (vma->anon_vma) {
 			anon_vma = vma->anon_vma;
-			anon_vma_lock_write(anon_vma);
+			anon_vma_lock_read(anon_vma);
 		}
 	}
 
@@ -154,7 +154,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	pte_unmap(new_pte - 1);
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (anon_vma)
-		anon_vma_unlock_write(anon_vma);
+		anon_vma_unlock_read(anon_vma);
 	if (mapping)
 		mutex_unlock(&mapping->i_mmap_mutex);
 }
@@ -199,12 +199,12 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 					      vma);
 				/* See comment in move_ptes() */
 				if (need_rmap_locks)
-					anon_vma_lock_write(vma->anon_vma);
+					anon_vma_lock_read(vma->anon_vma);
 				err = move_huge_pmd(vma, new_vma, old_addr,
 						    new_addr, old_end,
 						    old_pmd, new_pmd);
 				if (need_rmap_locks)
-					anon_vma_unlock_write(vma->anon_vma);
+					anon_vma_unlock_read(vma->anon_vma);
 			}
 			if (err > 0) {
 				need_flush = true;
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
