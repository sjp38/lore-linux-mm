Date: Fri, 28 Sep 2007 18:00:35 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] splice mmap_sem deadlock
Message-ID: <20070928160035.GD12538@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I'm fairly sure this is the right patch... but the explicit comment has me
thinking I missed something? (there is also a down_write->fault deadlock
in the splice code in -mm, however when talking with Jens about that code,
we might have an idea for a different approach using preexisting vmas
rather than setting them up with splice -- so this patch is just for mainline)


mmap_sem cannot be taken recursively for read, due to the FIFO nature of the
rwsem, and the presence of possible write lockers.

process A			process B
down_read(mmap_sem); [1]
get_user();             	down_write(mmap_sem); [2]
-> page fault
   down_read(mmap_sem); [3]

[1] will never be released until [3] can be taken and released, however:
[2] blocks on [1]; [3] blocks on [2].

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -1534,12 +1534,6 @@ static int get_iovec_page_array(const st
 {
 	int buffers = 0, error = 0;
 
-	/*
-	 * It's ok to take the mmap_sem for reading, even
-	 * across a "get_user()".
-	 */
-	down_read(&current->mm->mmap_sem);
-
 	while (nr_vecs) {
 		unsigned long off, npages;
 		void __user *base;
@@ -1583,9 +1577,11 @@ static int get_iovec_page_array(const st
 		if (npages > PIPE_BUFFERS - buffers)
 			npages = PIPE_BUFFERS - buffers;
 
+		down_read(&current->mm->mmap_sem);
 		error = get_user_pages(current, current->mm,
 				       (unsigned long) base, npages, 0, 0,
 				       &pages[buffers], NULL);
+		up_read(&current->mm->mmap_sem);
 
 		if (unlikely(error <= 0))
 			break;
@@ -1624,8 +1620,6 @@ static int get_iovec_page_array(const st
 		iov++;
 	}
 
-	up_read(&current->mm->mmap_sem);
-
 	if (buffers)
 		return buffers;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
