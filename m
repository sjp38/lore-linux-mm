Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 93DC26B007D
	for <linux-mm@kvack.org>; Sat, 25 Sep 2010 19:34:33 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <m1sk0x9z62.fsf@fess.ebiederm.org>
Date: Sat, 25 Sep 2010 16:34:25 -0700
In-Reply-To: <m1sk0x9z62.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Sat, 25 Sep 2010 16:33:09 -0700")
Message-ID: <m1iq1t9z3y.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [PATCH 2/3] mm: Consolidate vma destruction into remove_vma.
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


Consolidate vma destruction in remove_vma.   This is slightly
better for code size and for code maintenance.  Avoiding the pain
of 3 copies of everything needed to tear down a vma.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 mm/mmap.c |   21 +++++----------------
 1 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 6128dc8..17dd003 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -643,16 +643,10 @@ again:			remove_next = 1 + (end > next->vm_end);
 		spin_unlock(&mapping->i_mmap_lock);
 
 	if (remove_next) {
-		if (file) {
-			fput(file);
-			if (next->vm_flags & VM_EXECUTABLE)
-				removed_exe_file_vma(mm);
-		}
 		if (next->anon_vma)
 			anon_vma_merge(vma, next);
+		remove_vma(next);
 		mm->map_count--;
-		mpol_put(vma_policy(next));
-		kmem_cache_free(vm_area_cachep, next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -2002,19 +1996,14 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 		return 0;
 
 	/* Clean everything up if vma_adjust failed. */
-	if (new->vm_ops && new->vm_ops->close)
-		new->vm_ops->close(new);
-	if (new->vm_file) {
-		if (vma->vm_flags & VM_EXECUTABLE)
-			removed_exe_file_vma(mm);
-		fput(new->vm_file);
-	}
+	remove_vma(new);
+ out_err:
+	return err;
  out_free_mpol:
 	mpol_put(pol);
  out_free_vma:
 	kmem_cache_free(vm_area_cachep, new);
- out_err:
-	return err;
+	goto out_err;
 }
 
 /*
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
