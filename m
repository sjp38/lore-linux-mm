Date: Wed, 23 Jan 2008 11:35:21 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in
 sys_msync()
In-Reply-To: <1201110066.6341.65.camel@lappy>
Message-ID: <alpine.LFD.1.00.0801231107520.1741@woody.linux-foundation.org>
References: <12010440803930-git-send-email-salikhmetov@gmail.com>  <1201044083504-git-send-email-salikhmetov@gmail.com>  <alpine.LFD.1.00.0801230836250.1741@woody.linux-foundation.org> <1201110066.6341.65.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Anton Salikhmetov <salikhmetov@gmail.com>, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>


On Wed, 23 Jan 2008, Peter Zijlstra wrote:
> 
> It would need some addition piece to not call msync_interval() for
> MS_SYNC, and remove the balance_dirty_pages_ratelimited_nr() stuff.
> 
> But yeah, this pte walker is much better. 

Actually, I think this patch is much better. 

Anyway, it's better because:
 - it actually honors the range
 - it uses the same code for MS_ASYNC and MS_SYNC
 - it just avoids doing the "wait for" for MS_ASYNC.

However, it's totally untested, of course. What did you expect? Clean code 
_and_ testing? 

[ Side note: it is quite possible that we should not do the 
  SYNC_FILE_RANGE_WAIT_BEFORE on MS_ASYNC, and just skip over pages that 
  are busily under writeback already.

  Whatever.

  There are probably other problems here too, so consider this a "Hey, 
  wouldn't something like this work really well?" patch rather than 
  something final. ]

Just to get peoples creative juices going, here's my suggested patch.

		Linus

---
 mm/msync.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 48 insertions(+), 4 deletions(-)

diff --git a/mm/msync.c b/mm/msync.c
index 144a757..a7a2ea4 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -10,10 +10,37 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
+#include <linux/pagemap.h>
 #include <linux/file.h>
 #include <linux/syscalls.h>
 #include <linux/sched.h>
 
+static int msync_range(struct file *file, loff_t start, unsigned long len, unsigned int sync)
+{
+	int ret;
+	struct address_space *mapping = file->f_mapping;
+	loff_t end = start + len - 1;
+
+	ret = do_sync_mapping_range(mapping, start, end,
+		SYNC_FILE_RANGE_WRITE | SYNC_FILE_RANGE_WAIT_BEFORE);
+
+	if (ret || !sync)
+		return ret;
+
+	if (file->f_op && file->f_op->fsync) {
+		mutex_lock(&mapping->host->i_mutex);
+		ret = file->f_op->fsync(file, file->f_path.dentry, 0);
+		mutex_unlock(&mapping->host->i_mutex);
+
+		if (ret < 0)
+			return ret;
+	}
+
+	return wait_on_page_writeback_range(mapping,
+			start >> PAGE_CACHE_SHIFT,
+			end >> PAGE_CACHE_SHIFT);
+}
+
 /*
  * MS_SYNC syncs the entire file - including mappings.
  *
@@ -77,18 +104,35 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
 			goto out_unlock;
 		}
 		file = vma->vm_file;
-		start = vma->vm_end;
-		if ((flags & MS_SYNC) && file &&
-				(vma->vm_flags & VM_SHARED)) {
+
+		if (file && (vma->vm_flags & VM_SHARED)) {
+			loff_t offset;
+			unsigned long len;
+
+			/*
+			 * We need to do all of this before we release the mmap_sem,
+			 * since "vma" isn't available after that.
+			 */
+			offset = start - vma->vm_start;
+			offset += vma->vm_pgoff << PAGE_SHIFT;
+			len = end;
+			if (len > vma->vm_end)
+				len = vma->vm_end;
+			len -= start;
+
+			/* Update start here, since vm_end will be gone too.. */
+			start = vma->vm_end;
 			get_file(file);
 			up_read(&mm->mmap_sem);
-			error = do_fsync(file, 0);
+
+			error = msync_range(file, offset, len, flags & MS_SYNC);
 			fput(file);
 			if (error || start >= end)
 				goto out;
 			down_read(&mm->mmap_sem);
 			vma = find_vma(mm, start);
 		} else {
+			start = vma->vm_end;
 			if (start >= end) {
 				error = 0;
 				goto out_unlock;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
