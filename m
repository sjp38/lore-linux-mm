In-reply-to: <alpine.LFD.1.00.0801231329120.2803@woody.linux-foundation.org>
	(message from Linus Torvalds on Wed, 23 Jan 2008 13:36:45 -0800 (PST))
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in
 sys_msync()
References: <12010440803930-git-send-email-salikhmetov@gmail.com>  <1201044083504-git-send-email-salikhmetov@gmail.com>  <alpine.LFD.1.00.0801230836250.1741@woody.linux-foundation.org> <1201110066.6341.65.camel@lappy> <alpine.LFD.1.00.0801231107520.1741@woody.linux-foundation.org>
 <E1JHlh8-0003s8-Bb@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801231248060.2803@woody.linux-foundation.org> <E1JHmxa-0004BK-6X@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801231329120.2803@woody.linux-foundation.org>
Message-Id: <E1JHpaa-0004a9-8B@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 24 Jan 2008 01:05:04 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: miklos@szeredi.hu, a.p.zijlstra@chello.nl, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> > How about doing it in a separate pass, similarly to
> > wait_on_page_writeback()?  Just instead of waiting, clean the page
> > tables for writeback pages.
> 
> That sounds like a good idea, but it doesn't work.
> 
> The thing is, we need to hold the page-table lock over the whole sequence 
> of
> 
> 	if (page_mkclean(page))
> 		set_page_dirty(page);
> 	if (TestClearPageDirty(page))
> 		..
> 
> and there's a big comment about why in clear_page_dirty_for_io().
> 
> So if you split it up, so that the first phase is that
> 
> 	if (page_mkclean(page))
> 		set_page_dirty(page);
> 
> and the second phase is the one that just does a
> 
> 	if (TestClearPageDirty(page))
> 		writeback(..)
> 
> and having dropped the page lock in between, then you lose: because 
> another thread migth have faulted in and re-dirtied the page table entry, 
> and you MUST NOT do that "TestClearPageDirty()" in that case!
> 
> That dirty bit handling is really really important, and it's sadly also 
> really really easy to get wrong (usually in ways that are hard to even 
> notice: things still work 99% of the time, and you might just be leaking 
> memory slowly, and fsync/msync() might not write back memory mapped data 
> to disk at all etc).

OK.

But I still think this approach should work.  Untested, might eat your
children, so please don't apply to any kernel.

Miklos

Index: linux/mm/msync.c
===================================================================
--- linux.orig/mm/msync.c	2008-01-24 00:18:31.000000000 +0100
+++ linux/mm/msync.c	2008-01-24 00:50:37.000000000 +0100
@@ -10,9 +10,91 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
+#include <linux/pagemap.h>
 #include <linux/file.h>
 #include <linux/syscalls.h>
 #include <linux/sched.h>
+#include <linux/pagevec.h>
+#include <linux/rmap.h>
+#include <linux/backing-dev.h>
+
+static void mkclean_writeback_pages(struct address_space *mapping,
+				    pgoff_t start, pgoff_t end)
+{
+	struct pagevec pvec;
+	pgoff_t index;
+
+	if (!mapping_cap_account_dirty(mapping))
+		return;
+
+	if (end < start)
+		return;
+
+	pagevec_init(&pvec, 0);
+	index = start;
+	while (index <= end) {
+		unsigned i;
+		int nr_pages = min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1;
+
+		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
+					      PAGECACHE_TAG_WRITEBACK,
+					      nr_pages);
+		if (!nr_pages)
+			break;
+
+		for (i = 0; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+
+			/* until radix tree lookup accepts end_index */
+			if (page->index > end)
+				continue;
+
+			lock_page(page);
+			if (page_mkclean(page))
+				set_page_dirty(page);
+			unlock_page(page);
+		}
+		pagevec_release(&pvec);
+		cond_resched();
+	}
+}
+
+static int msync_range(struct file *file, loff_t start, unsigned long len, unsigned int sync)
+{
+	int ret;
+	struct address_space *mapping = file->f_mapping;
+	loff_t end = start + len - 1;
+	int sync_flags = SYNC_FILE_RANGE_WRITE;
+
+	if (sync) {
+		sync_flags |= SYNC_FILE_RANGE_WAIT_BEFORE;
+	} else {
+		/*
+		 * For MS_ASYNC, don't wait for writback already in
+		 * progress, but instead just clean the page tables.
+		 */
+		mkclean_writeback_pages(mapping,
+					start >> PAGE_CACHE_SHIFT,
+					end >> PAGE_CACHE_SHIFT);
+	}
+
+	ret = do_sync_mapping_range(mapping, start, end, sync_flags);
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
 
 /*
  * MS_SYNC syncs the entire file - including mappings.
@@ -77,18 +159,36 @@ asmlinkage long sys_msync(unsigned long 
 			goto out_unlock;
 		}
 		file = vma->vm_file;
-		start = vma->vm_end;
-		if ((flags & MS_SYNC) && file &&
-				(vma->vm_flags & VM_SHARED)) {
+
+		if (file && (vma->vm_flags & VM_SHARED) &&
+		    (flags & (MS_SYNC | MS_ASYNC))) {
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
