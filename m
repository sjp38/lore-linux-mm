Date: Fri, 28 Sep 2007 13:02:50 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] splice mmap_sem deadlock
In-Reply-To: <20070928193017.GC11717@kernel.dk>
Message-ID: <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org>
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk>
 <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org>
 <20070928181513.GB11717@kernel.dk> <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org>
 <20070928193017.GC11717@kernel.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 28 Sep 2007, Jens Axboe wrote:
> 
> Hmm, part of me doesn't like this patch, since we now end up beating on
> mmap_sem for each part of the vec. It's fine for a stable patch, but how
> about
> 
> - prefaulting the iovec
> - using __get_user()
> - only dropping/regrabbing the lock if we have to fault

"__get_user()" doesn't help any. But we should do the same thing we do for 
generic_file_write(), or whatever - probe it while in an atomic region.

So something like the appended might work. Untested.

		Linus
---
 fs/splice.c |   32 +++++++++++++++++++++-----------
 1 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index c010a72..07e880e 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1236,31 +1236,41 @@ static int get_iovec_page_array(const struct iovec __user *iov,
 {
 	int buffers = 0, error = 0;
 
-	/*
-	 * It's ok to take the mmap_sem for reading, even
-	 * across a "get_user()".
-	 */
 	down_read(&current->mm->mmap_sem);
 
 	while (nr_vecs) {
 		unsigned long off, npages;
+		struct iovec entry;
 		void __user *base;
 		size_t len;
 		int i;
 
 		/*
-		 * Get user address base and length for this iovec.
+		 * We do not want to recursively take the mmap_sem semaphore
+		 * on a page fault, since that could deadlock with a writer
+		 * that comes in in the middle. So disable pagefaults, and
+		 * do it the slow way if the copy fails..
 		 */
-		error = get_user(base, &iov->iov_base);
-		if (unlikely(error))
-			break;
-		error = get_user(len, &iov->iov_len);
-		if (unlikely(error))
-			break;
+		pagefault_disable();
+		i = __copy_from_user_inatomic(&entry, iov, sizeof(entry));
+		pagefault_enable();
+
+		if (unlikely(i)) {
+			up_read(&current->mm->mmap_sem);
+			i = copy_from_user(&entry, iov, sizeof(entry));
+			down_read(&current->mm->mmap_sem);
+			error = -EFAULT;
+			if (i)
+				break;
+		}
+
+		len = entry.iov_len;
+		base = entry.iov_base;
 
 		/*
 		 * Sanity check this iovec. 0 read succeeds.
 		 */
+		error = 0;
 		if (unlikely(!len))
 			break;
 		error = -EFAULT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
