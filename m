Date: Sun, 19 Aug 2001 04:59:06 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla speedup.
Message-ID: <20010819045906.E1719@athlon.random>
References: <20010819012713.N1719@athlon.random> <Pine.LNX.4.33.0108182005590.3026-100000@touchme.toronto.redhat.com> <20010819023548.P1719@athlon.random> <20010819025314.R1719@athlon.random> <20010819032544.X1719@athlon.random> <20010819034050.Z1719@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010819034050.Z1719@athlon.random>; from andrea@suse.de on Sun, Aug 19, 2001 at 03:40:50AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

Ok, at the light of this thread I did these changes:

diff -urN mmap-rb-ref/include/linux/mm.h mmap-rb-5/include/linux/mm.h
--- mmap-rb-ref/include/linux/mm.h	Sun Aug 19 04:51:13 2001
+++ mmap-rb-5/include/linux/mm.h	Sun Aug 19 04:56:07 2001
@@ -578,6 +578,10 @@
 {
 	unsigned long grow;
 
+	/*
+	 * vma->vm_start/vm_end cannot change under us because the caller is required
+	 * to hold the mmap_sem at least in read mode.
+	 */
 	address &= PAGE_MASK;
 	if (prev_vma && prev_vma->vm_end + (heap_stack_gap << PAGE_SHIFT) > address)
 		return -ENOMEM;
@@ -587,7 +591,21 @@
 		return -ENOMEM;
 	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_start = address;
+
+	/*
+	 * vm_pgoff locking is a bit subtle: everybody but expand_stack is
+	 * playing with the vm_pgoff with the write semaphore acquired. The
+	 * only one playing with vm_pgoff with only the read semaphore
+	 * acquired is expand_stack and it serializes against itself with the
+	 * spinlock.
+	 *
+	 * More in general this means that it is not enough to grab the mmap_sem
+	 * in read mode to avoid vm_pgoff to change under you. You either
+	 * need the write semaphore acquired, or the read semaphore plus
+	 * the spinlock.
+	 */
 	vma->vm_pgoff -= grow;
+
 	vma->vm_mm->total_vm += grow;
 	if (vma->vm_flags & VM_LOCKED)
 		vma->vm_mm->locked_vm += grow;
diff -urN mmap-rb-ref/mm/mmap.c mmap-rb-5/mm/mmap.c
--- mmap-rb-ref/mm/mmap.c	Sun Aug 19 04:49:51 2001
+++ mmap-rb-5/mm/mmap.c	Sun Aug 19 04:52:05 2001
@@ -785,14 +785,19 @@
 
 	/* Work out to one of the ends. */
 	if (end == area->vm_end) {
+		/*
+		 * here area isn't visible to the semaphore-less readers
+		 * so we don't need to update it under the spinlock.
+		 */
+		area->vm_end = addr;
 		lock_vma_mappings(area);
 		spin_lock(&mm->page_table_lock);
-		area->vm_end = addr;
 	} else if (addr == area->vm_start) {
 		area->vm_pgoff += (end - area->vm_start) >> PAGE_SHIFT;
+		/* same locking considerations of the above case */
+		area->vm_start = end;
 		lock_vma_mappings(area);
 		spin_lock(&mm->page_table_lock);
-		area->vm_start = end;
 	} else {
 	/* Unmapping a hole: area->vm_start < addr <= end < area->vm_end */
 		/* Add end mapping -- leave beginning for below */

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
