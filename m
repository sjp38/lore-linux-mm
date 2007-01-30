Date: Tue, 30 Jan 2007 12:55:58 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 0/9] buffered write deadlock fix
Message-Id: <20070130125558.ae9119b0.akpm@osdl.org>
In-Reply-To: <20070129081905.23584.97878.sendpatchset@linux.site>
References: <20070129081905.23584.97878.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007 11:31:37 +0100 (CET)
Nick Piggin <npiggin@suse.de> wrote:

> The following set of patches attempt to fix the buffered write
> locking problems 

y'know, four or five years back I fixed this bug by doing

	current->locked_page = page;

in the write() code, and then teaching the pagefault code to avoid locking
the same page.  Patch below.

But then evil mean Hugh pointed out that the patch is still vulnerable to
ab/ba deadlocking so I dropped it.

But Hugh lied!  There is no ab/ba deadlock because both a and b need
i_mutex to get into the write() path.

This approach doesn't fix the writev() performance regresson which
nobody has measured yet but which the NFS guys reported.

But I think with this fix in place we can go back to a modified version of
the 2.6.17 filemap.c code and get that performance back, but I haven't
thought about that.

It's a heck of a lot simpler than your patches though ;)





There is a longstanding problem in which the kernel can deadlock if an
application performs a write(bf, buf, n), and `buf' points at a mmapped
page of `fd', and that page is the pagecache page into which this write
will write, and the page is not yet present.

The kernel will put a new page into pagecache, lock it, run
copy_from_user().  The copy will fault and filemap_nopage() will try to
lock the page in preparation for reading it in.  But it was already
locked up in generic_file_write().

We have had a workaround in there - touch the userspace address by hand
(to fault it in) before locking the pagecache page, and hope that it
doesn't get evicted before we try to lock it.

But there's a place in the kmap_atomic-for-generic_file_write code
where this race is detectable.  I put a printk in there and saw a
stream of them during heavy testing.  So the workaround doesn't work.


What this patch does is

- within generic_file_write(): record the locked page in current->locked_page

- within filemap_nopage, look to see if the page which we're faulting
  in is equal to current->locked_page.

  If it is, taken special action: instead of locking the page,
  reading it and unlocking it, we assume that the page is already
  locked.  Bring it uptodate and relock it before returning.


I tested this by disabling the fault-it-in-by-hand workaround, writing
a special test app and adding several printks.  Not pretty, but it does
the job.




 include/linux/sched.h |    2 ++
 mm/filemap.c          |   26 ++++++++++++++++++++++----
 2 files changed, 24 insertions(+), 4 deletions(-)

--- linux-mnm/mm/filemap.c~write-deadlock	Thu Oct 31 22:42:38 2002
+++ linux-mnm-akpm/mm/filemap.c	Thu Oct 31 22:42:38 2002
@@ -997,6 +997,7 @@ struct page * filemap_nopage(struct vm_a
 	struct page *page;
 	unsigned long size, pgoff, endoff;
 	int did_readahead;
+	struct page *locked_page = current->locked_page;
 
 	pgoff = ((address - area->vm_start) >> PAGE_CACHE_SHIFT) + area->vm_pgoff;
 	endoff = ((area->vm_end - area->vm_start) >> PAGE_CACHE_SHIFT) + area->vm_pgoff;
@@ -1092,10 +1093,12 @@ no_cached_page:
 
 page_not_uptodate:
 	inc_page_state(pgmajfault);
-	lock_page(page);
+	if (page != locked_page)
+		lock_page(page);
 
 	/* Did it get unhashed while we waited for it? */
 	if (!page->mapping) {
+		BUG_ON(page == locked_page);	/* can't happen: i_sem */
 		unlock_page(page);
 		page_cache_release(page);
 		goto retry_all;
@@ -1103,12 +1106,15 @@ page_not_uptodate:
 
 	/* Did somebody else get it up-to-date? */
 	if (PageUptodate(page)) {
-		unlock_page(page);
+		if (page != locked_page)
+			unlock_page(page);
 		goto success;
 	}
 
 	if (!mapping->a_ops->readpage(file, page)) {
 		wait_on_page_locked(page);
+		if (page == locked_page)
+			lock_page(page);
 		if (PageUptodate(page))
 			goto success;
 	}
@@ -1119,10 +1125,12 @@ page_not_uptodate:
 	 * because there really aren't any performance issues here
 	 * and we need to check for errors.
 	 */
-	lock_page(page);
+	if (page != locked_page)
+		lock_page(page);
 
 	/* Somebody truncated the page on us? */
 	if (!page->mapping) {
+		BUG_ON(page == locked_page);	/* can't happen: i_sem */
 		unlock_page(page);
 		page_cache_release(page);
 		goto retry_all;
@@ -1130,12 +1138,15 @@ page_not_uptodate:
 
 	/* Somebody else successfully read it in? */
 	if (PageUptodate(page)) {
-		unlock_page(page);
+		if (page != locked_page)
+			unlock_page(page);
 		goto success;
 	}
 	ClearPageError(page);
 	if (!mapping->a_ops->readpage(file, page)) {
 		wait_on_page_locked(page);
+		if (page == locked_page)
+			lock_page(page);
 		if (PageUptodate(page))
 			goto success;
 	}
@@ -1445,6 +1456,11 @@ void remove_suid(struct dentry *dentry)
 	}
 }
 
+/*
+ * There is rare deadlock scenario in which the source and dest pages are
+ * the same, and the VM evicts the page at the wrong time.   Here we set
+ * current->locked_page to signal that to special-case code in filemap_nopage
+ */
 static inline int
 filemap_copy_from_user(struct page *page, unsigned long offset,
 			const char *buf, unsigned bytes)
@@ -1459,7 +1475,9 @@ filemap_copy_from_user(struct page *page
 	if (left != 0) {
 		/* Do it the slow way */
 		kaddr = kmap(page);
+		current->locked_page = page;
 		left = __copy_from_user(kaddr + offset, buf, bytes);
+		current->locked_page = NULL;
 		kunmap(page);
 	}
 	return left;
--- linux-mnm/include/linux/sched.h~write-deadlock	Thu Oct 31 22:42:38 2002
+++ linux-mnm-akpm/include/linux/sched.h	Thu Oct 31 22:42:38 2002
@@ -266,6 +266,7 @@ extern struct user_struct root_user;
 
 typedef struct prio_array prio_array_t;
 struct backing_dev_info;
+struct page;
 
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
@@ -387,6 +388,7 @@ struct task_struct {
 	void *journal_info;
 	struct dentry *proc_dentry;
 	struct backing_dev_info *backing_dev_info;
+	struct page *locked_page;
 };
 
 extern void __put_task_struct(struct task_struct *tsk);

.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
