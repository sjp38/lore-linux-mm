Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 2792E6B0072
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 19:50:16 -0500 (EST)
Received: by mail-da0-f44.google.com with SMTP id z20so1786226dae.3
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 16:50:14 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/9] mm: remap_file_pages() fixes
Date: Thu, 20 Dec 2012 16:49:50 -0800
Message-Id: <1356050997-2688-3-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-1-git-send-email-walken@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Assorted small fixes. The first two are quite small:

- Move check for vma->vm_private_data && !(vma->vm_flags & VM_NONLINEAR)
  within existing if (!(vma->vm_flags & VM_NONLINEAR)) block.
  Purely cosmetic.

- In the VM_LOCKED case, when dropping PG_Mlocked for the over-mapped
  range, make sure we own the mmap_sem write lock around the
  munlock_vma_pages_range call as this manipulates the vma's vm_flags.

Last fix requires a longer explanation. remap_file_pages() can do its work
either through VM_NONLINEAR manipulation or by creating extra vmas.
These two cases were inconsistent with each other (and ultimately, both wrong)
as to exactly when did they fault in the newly mapped file pages:

- In the VM_NONLINEAR case, new file pages would be populated if
  the MAP_NONBLOCK flag wasn't passed. If MAP_NONBLOCK was passed,
  new file pages wouldn't be populated even if the vma is already
  marked as VM_LOCKED.

- In the linear (emulated) case, the work is passed to the mmap_region()
  function which would populate the pages if the vma is marked as
  VM_LOCKED, and would not otherwise - regardless of the value of the
  MAP_NONBLOCK flag, because MAP_POPULATE wasn't being passed to
  mmap_region().

The desired behavior is that we want the pages to be populated and locked
if the vma is marked as VM_LOCKED, or to be populated if the MAP_NONBLOCK
flag is not passed to remap_file_pages().

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 mm/fremap.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/mm/fremap.c b/mm/fremap.c
index a0aaf0e56800..2db886e31044 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -160,15 +160,11 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	/*
 	 * Make sure the vma is shared, that it supports prefaulting,
 	 * and that the remapped range is valid and fully within
-	 * the single existing vma.  vm_private_data is used as a
-	 * swapout cursor in a VM_NONLINEAR vma.
+	 * the single existing vma.
 	 */
 	if (!vma || !(vma->vm_flags & VM_SHARED))
 		goto out;
 
-	if (vma->vm_private_data && !(vma->vm_flags & VM_NONLINEAR))
-		goto out;
-
 	if (!vma->vm_ops || !vma->vm_ops->remap_pages)
 		goto out;
 
@@ -177,6 +173,13 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 
 	/* Must set VM_NONLINEAR before any pages are populated. */
 	if (!(vma->vm_flags & VM_NONLINEAR)) {
+		/*
+		 * vm_private_data is used as a swapout cursor
+		 * in a VM_NONLINEAR vma.
+		 */
+		if (vma->vm_private_data)
+			goto out;
+
 		/* Don't need a nonlinear mapping, exit success */
 		if (pgoff == linear_page_index(vma, start)) {
 			err = 0;
@@ -184,6 +187,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 		}
 
 		if (!has_write_lock) {
+get_write_lock:
 			up_read(&mm->mmap_sem);
 			down_write(&mm->mmap_sem);
 			has_write_lock = 1;
@@ -199,7 +203,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 			unsigned long addr;
 			struct file *file = get_file(vma->vm_file);
 
-			flags &= MAP_NONBLOCK;
+			flags = (flags & MAP_NONBLOCK) | MAP_POPULATE;
 			addr = mmap_region(file, start, size,
 					flags, vma->vm_flags, pgoff);
 			fput(file);
@@ -225,6 +229,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 		 * drop PG_Mlocked flag for over-mapped range
 		 */
 		vm_flags_t saved_flags = vma->vm_flags;
+		if (!has_write_lock)
+			goto get_write_lock;
 		munlock_vma_pages_range(vma, start, start + size);
 		vma->vm_flags = saved_flags;
 	}
@@ -232,13 +238,13 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	mmu_notifier_invalidate_range_start(mm, start, start + size);
 	err = vma->vm_ops->remap_pages(vma, start, size, pgoff);
 	mmu_notifier_invalidate_range_end(mm, start, start + size);
-	if (!err && !(flags & MAP_NONBLOCK)) {
+	if (!err) {
 		if (vma->vm_flags & VM_LOCKED) {
 			/*
 			 * might be mapping previously unmapped range of file
 			 */
 			mlock_vma_pages_range(vma, start, start + size);
-		} else {
+		} else if (!(flags & MAP_NONBLOCK)) {
 			if (unlikely(has_write_lock)) {
 				downgrade_write(&mm->mmap_sem);
 				has_write_lock = 0;
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
