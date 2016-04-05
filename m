Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2CEE56B0283
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 16:52:52 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id fe3so17772476pab.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:52:52 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id a22si15774978pfj.116.2016.04.05.13.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 13:52:51 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id fe3so17772332pab.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:52:51 -0700 (PDT)
Date: Tue, 5 Apr 2016 13:52:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 08/10] huge pagecache: extend mremap pmd rmap lockout to
 files
In-Reply-To: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051351280.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Whatever huge pagecache implementation we go with, file rmap locking
must be added to anon rmap locking, when mremap's move_page_tables()
finds a pmd_trans_huge pmd entry: a simple change, let's do it now.

Factor out take_rmap_locks() and drop_rmap_locks() to handle the
locking for make move_ptes() and move_page_tables(), and delete
the VM_BUG_ON_VMA which rejected vm_file and required anon_vma.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/mremap.c |   42 ++++++++++++++++++++++--------------------
 1 file changed, 22 insertions(+), 20 deletions(-)

--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -70,6 +70,22 @@ static pmd_t *alloc_new_pmd(struct mm_st
 	return pmd;
 }
 
+static void take_rmap_locks(struct vm_area_struct *vma)
+{
+	if (vma->vm_file)
+		i_mmap_lock_write(vma->vm_file->f_mapping);
+	if (vma->anon_vma)
+		anon_vma_lock_write(vma->anon_vma);
+}
+
+static void drop_rmap_locks(struct vm_area_struct *vma)
+{
+	if (vma->anon_vma)
+		anon_vma_unlock_write(vma->anon_vma);
+	if (vma->vm_file)
+		i_mmap_unlock_write(vma->vm_file->f_mapping);
+}
+
 static pte_t move_soft_dirty_pte(pte_t pte)
 {
 	/*
@@ -90,8 +106,6 @@ static void move_ptes(struct vm_area_str
 		struct vm_area_struct *new_vma, pmd_t *new_pmd,
 		unsigned long new_addr, bool need_rmap_locks)
 {
-	struct address_space *mapping = NULL;
-	struct anon_vma *anon_vma = NULL;
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
@@ -114,16 +128,8 @@ static void move_ptes(struct vm_area_str
 	 *   serialize access to individual ptes, but only rmap traversal
 	 *   order guarantees that we won't miss both the old and new ptes).
 	 */
-	if (need_rmap_locks) {
-		if (vma->vm_file) {
-			mapping = vma->vm_file->f_mapping;
-			i_mmap_lock_write(mapping);
-		}
-		if (vma->anon_vma) {
-			anon_vma = vma->anon_vma;
-			anon_vma_lock_write(anon_vma);
-		}
-	}
+	if (need_rmap_locks)
+		take_rmap_locks(vma);
 
 	/*
 	 * We don't have to worry about the ordering of src and dst
@@ -151,10 +157,8 @@ static void move_ptes(struct vm_area_str
 		spin_unlock(new_ptl);
 	pte_unmap(new_pte - 1);
 	pte_unmap_unlock(old_pte - 1, old_ptl);
-	if (anon_vma)
-		anon_vma_unlock_write(anon_vma);
-	if (mapping)
-		i_mmap_unlock_write(mapping);
+	if (need_rmap_locks)
+		drop_rmap_locks(vma);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
@@ -193,15 +197,13 @@ unsigned long move_page_tables(struct vm
 		if (pmd_trans_huge(*old_pmd)) {
 			if (extent == HPAGE_PMD_SIZE) {
 				bool moved;
-				VM_BUG_ON_VMA(vma->vm_file || !vma->anon_vma,
-					      vma);
 				/* See comment in move_ptes() */
 				if (need_rmap_locks)
-					anon_vma_lock_write(vma->anon_vma);
+					take_rmap_locks(vma);
 				moved = move_huge_pmd(vma, old_addr, new_addr,
 						    old_end, old_pmd, new_pmd);
 				if (need_rmap_locks)
-					anon_vma_unlock_write(vma->anon_vma);
+					drop_rmap_locks(vma);
 				if (moved) {
 					need_flush = true;
 					continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
