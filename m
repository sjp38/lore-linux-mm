Date: Mon, 1 Oct 2007 14:03:31 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [patch] splice mmap_sem deadlock
Message-ID: <20071001120330.GE5303@kernel.dk>
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk> <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org> <20070928181513.GB11717@kernel.dk> <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org> <20070928193017.GC11717@kernel.dk> <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org> <alpine.LFD.0.999.0709281303250.3579@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709281303250.3579@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 28 2007, Linus Torvalds wrote:
> 
> 
> On Fri, 28 Sep 2007, Linus Torvalds wrote:
> > 
> > So something like the appended might work. Untested.
> 
> Btw, it migth be cleaner to separate out this thing as a function of it's 
> own, ie something like
> 
>   /*
>    * Do a copy-from-user while holding the mmap_semaphore for reading
>    */
>   int copy_from_user_mmap_sem(void *dst, const void __user *src, size_t n)
>   {
> 	int partial;
> 
> 	pagefault_disable();
> 	partial = __copy_from_user_inatomic(dst, src, n);
> 	pagefault_enable();
> 
> 	if (!partial)
> 		return 0;
> 	up_read(&current->mm->mmap_sem);
> 	partial = copy_from_user(dst, src, n);
> 	down_read(&current->mm->mmap_sem);
> 
> 	return partial ? -EFAULT : 0;
>   }
> 
> in case anybody else needs it. And even if nobody else does, making it a 
> static inline function in fs/splice.c would at least separate out this 
> thing from the core functionality, and just help keep things clear.
> 
> Wanna test that thing?

OK, this is what I tested. It works for me.

diff --git a/fs/splice.c b/fs/splice.c
index c010a72..49b8107 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1224,6 +1224,33 @@ static long do_splice(struct file *in, loff_t __user *off_in,
 }
 
 /*
+ * Do a copy-from-user while holding the mmap_semaphore for reading. If we
+ * have to fault the user page in, we must drop the mmap_sem to avoid a
+ * deadlock in the page fault handling (it wants to grab mmap_sem too, but for
+ * writing). This assumes that we will very rarely hit the partial != 0 path,
+ * or this will not be a win.
+ */
+static int copy_from_user_mmap_sem(void *dst, const void __user *src, size_t n)
+{
+	int partial;
+
+	pagefault_disable();
+	partial = __copy_from_user_inatomic(dst, src, n);
+	pagefault_enable();
+
+	/*
+	 * Didn't copy everything, drop the mmap_sem and do a faulting copy
+	 */
+	if (unlikely(partial)) {
+		up_read(&current->mm->mmap_sem);
+		partial = copy_from_user(dst, src, n);
+		down_read(&current->mm->mmap_sem);
+	}
+
+	return partial;
+}
+
+/*
  * Map an iov into an array of pages and offset/length tupples. With the
  * partial_page structure, we can map several non-contiguous ranges into
  * our ones pages[] map instead of splitting that operation into pieces.
@@ -1236,31 +1263,26 @@ static int get_iovec_page_array(const struct iovec __user *iov,
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
 
-		/*
-		 * Get user address base and length for this iovec.
-		 */
-		error = get_user(base, &iov->iov_base);
-		if (unlikely(error))
-			break;
-		error = get_user(len, &iov->iov_len);
-		if (unlikely(error))
+		error = -EFAULT;
+		if (copy_from_user_mmap_sem(&entry, iov, sizeof(entry)))
 			break;
 
+		base = entry.iov_base;
+		len = entry.iov_len;
+
 		/*
 		 * Sanity check this iovec. 0 read succeeds.
 		 */
+		error = 0;
 		if (unlikely(!len))
 			break;
 		error = -EFAULT;

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
