Subject: PATHC: SHM mappings beyond the end of a segment.
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 29 Jan 2000 22:28:42 -0600
Message-ID: <m17lgsgp39.fsf@flinx.hidden>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Currently it is possible to extend the vma for a shm segment
with mremap.  The shm code has no checks for access beyond the
end of the shm segment.  Resulting in writes to shp->shm_dir in 2.3
and shp->shm_pages in 2.2 past the allocated end of the array.

By playing with this processes can create weird memory overwrites,
and effectively mlocked private pages.

As using mremap to extend a shm mapping is basically silly,
and linux specific.  I don't think it affects anything in practice.

The attached patch caused SIGBUS to be delivered when
we write past the end of our shm area.

Eric

===File linux-2.3.41.eb1.diff==============
diff -uNrX linux-ignore-files linux-2.3.41/ipc/shm.c linux-2.3.41.eb1/ipc/shm.c
--- linux-2.3.41/ipc/shm.c	Mon Jan 24 13:04:37 2000
+++ linux-2.3.41.eb1/ipc/shm.c	Sat Jan 29 18:57:58 2000
@@ -840,6 +840,15 @@
 	idx = (address - shmd->vm_start) >> PAGE_SHIFT;
 	idx += shmd->vm_pgoff;
 
+	/*
+	 * A shared mapping past the last page of the file is an error
+	 * and results in a SIGBUS, so logically a shared mapping past 
+	 * the end of a shared memory segment should result in SIGBUS
+	 * as well.
+	 */
+	if (idx >= shp->shm_npages) { 
+		return NULL;
+	}
 	down(&shp->sem);
 	if(shp != shm_lock(shp->id))
 		BUG();
============================================================
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
