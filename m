Date: Fri, 3 Oct 2003 22:40:56 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] fix split_vma vs. invalidate_mmap_range_list race
Message-Id: <20031003224056.09421fb1.akpm@osdl.org>
In-Reply-To: <20031003222921.33d5c88d.davem@redhat.com>
References: <Pine.LNX.4.44.0310032353070.26794-100000@cello.eecs.umich.edu>
	<20031003222921.33d5c88d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: vrajesh@eecs.umich.edu, hch@lst.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"David S. Miller" <davem@redhat.com> wrote:
>
> I think you are right about these races, they exist and they are
>  real.  Someone should just make sure you haven't added any deadlock
>  or semaphore taking with spinlocks held in higher level callers.
>  I don't think your patch does, but it's something to audit.

It looks OK.  I updated the VM lock ranking docco to cover this.


 mm/filemap.c |    3 +++
 mm/mmap.c    |   16 +++++++++-------
 2 files changed, 12 insertions(+), 7 deletions(-)

diff -puN mm/mmap.c~vma-split-truncate-race-fix-tweaks mm/mmap.c
--- 25/mm/mmap.c~vma-split-truncate-race-fix-tweaks	2003-10-03 21:50:39.000000000 -0700
+++ 25-akpm/mm/mmap.c	2003-10-03 21:53:09.000000000 -0700
@@ -369,7 +369,8 @@ static int vma_merge(struct mm_struct *m
 			unsigned long end, unsigned long vm_flags,
 			struct file *file, unsigned long pgoff)
 {
-	spinlock_t * lock = &mm->page_table_lock;
+	spinlock_t *lock = &mm->page_table_lock;
+	struct semaphore *i_shared_sem;
 
 	/*
 	 * We later require that vma->vm_flags == vm_flags, so this tests
@@ -378,6 +379,8 @@ static int vma_merge(struct mm_struct *m
 	if (vm_flags & VM_SPECIAL)
 		return 0;
 
+	i_shared_sem = file ? &file->f_mapping->i_shared_sem : NULL;
+
 	if (!prev) {
 		prev = rb_entry(rb_parent, struct vm_area_struct, vm_rb);
 		goto merge_next;
@@ -395,7 +398,7 @@ static int vma_merge(struct mm_struct *m
 
 		if (unlikely(file && prev->vm_next &&
 				prev->vm_next->vm_file == file)) {
-			down(&file->f_mapping->i_shared_sem);
+			down(i_shared_sem);
 			need_up = 1;
 		}
 		spin_lock(lock);
@@ -413,7 +416,7 @@ static int vma_merge(struct mm_struct *m
 			__remove_shared_vm_struct(next, inode);
 			spin_unlock(lock);
 			if (need_up)
-				up(&file->f_mapping->i_shared_sem);
+				up(i_shared_sem);
 			if (file)
 				fput(file);
 
@@ -423,7 +426,7 @@ static int vma_merge(struct mm_struct *m
 		}
 		spin_unlock(lock);
 		if (need_up)
-			up(&file->f_mapping->i_shared_sem);
+			up(i_shared_sem);
 		return 1;
 	}
 
@@ -438,17 +441,16 @@ static int vma_merge(struct mm_struct *m
 			return 0;
 		if (end == prev->vm_start) {
 			if (file)
-				down(&file->f_mapping->i_shared_sem);
+				down(i_shared_sem); /* invalidate_mmap_range */
 			spin_lock(lock);
 			prev->vm_start = addr;
 			prev->vm_pgoff -= (end - addr) >> PAGE_SHIFT;
 			spin_unlock(lock);
 			if (file)
-				up(&file->f_mapping->i_shared_sem);
+				up(i_shared_sem);
 			return 1;
 		}
 	}
-
 	return 0;
 }
 
diff -puN mm/filemap.c~vma-split-truncate-race-fix-tweaks mm/filemap.c
--- 25/mm/filemap.c~vma-split-truncate-race-fix-tweaks	2003-10-03 21:59:15.000000000 -0700
+++ 25-akpm/mm/filemap.c	2003-10-03 22:02:01.000000000 -0700
@@ -61,6 +61,9 @@
  *        ->swap_device_lock	(exclusive_swap_page, others)
  *          ->mapping->page_lock
  *
+ *  ->i_sem
+ *    ->i_shared_sem		(truncate->invalidate_mmap_range)
+ *
  *  ->mmap_sem
  *    ->i_shared_sem		(various places)
  *

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
