Date: Wed, 28 Mar 2007 15:54:24 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 4/4] holepunch: fix mmap_sem i_mutex deadlock
In-Reply-To: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0703281552520.11726@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <mszeredi@suse.cz>, Badari Pulavarty <pbadari@us.ibm.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

sys_madvise has down_write of mmap_sem, then madvise_remove calls
vmtruncate_range which takes i_mutex and i_alloc_sem: no, we can
easily devise deadlocks from that ordering.

madvise_remove drop mmap_sem while calling vmtruncate_range: luckily,
since madvise_remove doesn't split or merge vmas, it's easy to handle
this case with a NULL prev, without restructuring sys_madvise.  (Though
sad to retake mmap_sem when it's unlikely to be needed, and certainly
down_read is sufficient for MADV_REMOVE, unlike the other madvices.)

Signed-off-by: Hugh Dickins <hugh@veritas.com>
Cc: Miklos Szeredi <mszeredi@suse.cz>
Cc: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>
---

 mm/madvise.c |   19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

--- punch3/mm/madvise.c	2007-03-26 07:30:54.000000000 +0100
+++ punch4/mm/madvise.c	2007-03-28 11:51:01.000000000 +0100
@@ -159,9 +159,10 @@ static long madvise_remove(struct vm_are
 				unsigned long start, unsigned long end)
 {
 	struct address_space *mapping;
-        loff_t offset, endoff;
+	loff_t offset, endoff;
+	int error;
 
-	*prev = vma;
+	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
 
 	if (vma->vm_flags & (VM_LOCKED|VM_NONLINEAR|VM_HUGETLB))
 		return -EINVAL;
@@ -180,7 +181,12 @@ static long madvise_remove(struct vm_are
 			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 	endoff = (loff_t)(end - vma->vm_start - 1)
 			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
-	return  vmtruncate_range(mapping->host, offset, endoff);
+
+	/* vmtruncate_range needs to take i_mutex and i_alloc_sem */
+	up_write(&current->mm->mmap_sem);
+	error = vmtruncate_range(mapping->host, offset, endoff);
+	down_write(&current->mm->mmap_sem);
+	return error;
 }
 
 static long
@@ -315,12 +321,15 @@ asmlinkage long sys_madvise(unsigned lon
 		if (error)
 			goto out;
 		start = tmp;
-		if (start < prev->vm_end)
+		if (prev && start < prev->vm_end)
 			start = prev->vm_end;
 		error = unmapped_error;
 		if (start >= end)
 			goto out;
-		vma = prev->vm_next;
+		if (prev)
+			vma = prev->vm_next;
+		else	/* madvise_remove dropped mmap_sem */
+			vma = find_vma(current->mm, start);
 	}
 out:
 	up_write(&current->mm->mmap_sem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
