Date: Sun, 19 Jul 1998 23:25:37 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: [PATCH] small fix: drivers/char/mem.c
Message-ID: <Pine.LNX.3.95.980719231632.14079A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: torvalds@transmeta.com
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

In drivers/char/mem.c:read_zero, we have a case of code mucking with page
tables which isn't protected by the mmap semaphore.  The patch below
(ancient & well tested, against 2.1.86, but applies to 2.1.109 w/fuzz)
fixes it.

		-ben


Index: linux-2.1.86-mm/drivers/char/mem.c
diff -u linux-2.1.86-mm/drivers/char/mem.c:1.1.1.2 linux-2.1.86-mm/drivers/char/mem.c:1.2
--- linux-2.1.86-mm/drivers/char/mem.c:1.1.1.2	Mon Mar  2 22:28:42 1998
+++ linux-2.1.86-mm/drivers/char/mem.c	Fri Mar  6 03:51:32 1998
@@ -260,12 +260,15 @@
 	struct vm_area_struct * vma;
 	unsigned long addr=(unsigned long)buf;
 
+	/* Oops, this was forgotten before. -ben */
+	down(&current->mm->mmap_sem);
+
 	/* For private mappings, just map in zero pages. */
 	for (vma = find_vma(current->mm, addr); vma; vma = vma->vm_next) {
 		unsigned long count;
 
 		if (vma->vm_start > addr || (vma->vm_flags & VM_WRITE) == 0)
-			return size;
+			goto out_up;
 		if (vma->vm_flags & VM_SHARED)
 			break;
 		count = vma->vm_end - addr;
@@ -273,16 +276,18 @@
 			count = size;
 
 		flush_cache_range(current->mm, addr, addr + count);
-		zap_page_range(current->mm, addr, count);
-        	zeromap_page_range(addr, count, PAGE_COPY);
+		zap_page_range(vma, addr, count);
+        	zeromap_page_range(vma, addr, count, PAGE_COPY);
         	flush_tlb_range(current->mm, addr, addr + count);
 
 		size -= count;
 		buf += count;
 		addr += count;
 		if (size == 0)
-			return 0;
+			goto out_up;
 	}
+
+	up(&current->mm->mmap_sem);
 	
 	/* The shared case is hard. Lets do the conventional zeroing. */ 
 	do {
@@ -296,6 +301,9 @@
 	} while (size);
 
 	return size;
+out_up:
+	up(&current->mm->mmap_sem);
+	return size;
 }
 
 static ssize_t read_zero(struct file * file, char * buf, 

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
