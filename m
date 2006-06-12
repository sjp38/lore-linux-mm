Received: from midway.site ([71.245.102.105]) by xenotime.net for <linux-mm@kvack.org>; Mon, 12 Jun 2006 09:41:51 -0700
Date: Mon, 12 Jun 2006 09:44:38 -0700
From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH/RFC] kernel-doc for mm/filemap.c
Message-Id: <20060612094438.b65d4558.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <rdunlap@xenotime.net>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

mm/filemap.c:
- add lots of kernel-doc;
- fix some typos and kernel-doc errors;
- drop some blank lines between function close and EXPORT_SYMBOL();

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 mm/filemap.c |  173 ++++++++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 120 insertions(+), 53 deletions(-)

--- linux-2617-rc6.orig/mm/filemap.c
+++ linux-2617-rc6/mm/filemap.c
@@ -171,15 +171,17 @@ static int sync_page(void *word)
 }
 
 /**
- * filemap_fdatawrite_range - start writeback against all of a mapping's
- * dirty pages that lie within the byte offsets <start, end>
+ * __filemap_fdatawrite_range - start writeback on mapping dirty pages in range
  * @mapping:	address space structure to write
  * @start:	offset in bytes where the range starts
  * @end:	offset in bytes where the range ends (inclusive)
  * @sync_mode:	enable synchronous operation
  *
+ * Start writeback against all of a mapping's dirty pages that lie
+ * within the byte offsets <start, end> inclusive.
+ *
  * If sync_mode is WB_SYNC_ALL then this is a "data integrity" operation, as
- * opposed to a regular memory * cleansing writeback.  The difference between
+ * opposed to a regular memory cleansing writeback.  The difference between
  * these two operations is that if a dirty page/buffer is encountered, it must
  * be waited upon, and not just skipped over.
  */
@@ -219,7 +221,10 @@ static int filemap_fdatawrite_range(stru
 	return __filemap_fdatawrite_range(mapping, start, end, WB_SYNC_ALL);
 }
 
-/*
+/**
+ * filemap_flush - mostly a non-blocking flush
+ * @mapping:	target address_space
+ *
  * This is a mostly non-blocking flush.  Not suitable for data-integrity
  * purposes - I/O may not be started against all dirty pages.
  */
@@ -229,7 +234,12 @@ int filemap_flush(struct address_space *
 }
 EXPORT_SYMBOL(filemap_flush);
 
-/*
+/**
+ * wait_on_page_writeback_range - wait for writeback to complete
+ * @mapping:	target address_space
+ * @start:	beginning page index
+ * @end:	ending page index
+ *
  * Wait for writeback to complete against pages indexed by start->end
  * inclusive
  */
@@ -276,7 +286,13 @@ int wait_on_page_writeback_range(struct 
 	return ret;
 }
 
-/*
+/**
+ * sync_page_range - write and wait on all pages in the passed range
+ * @inode:	target inode
+ * @mapping:	target address_space
+ * @pos:	beginning offset in pages to write
+ * @count:	number of bytes to write
+ *
  * Write and wait upon all the pages in the passed range.  This is a "data
  * integrity" operation.  It waits upon in-flight writeout before starting and
  * waiting upon new writeout.  If there was an IO error, return it.
@@ -305,7 +321,13 @@ int sync_page_range(struct inode *inode,
 }
 EXPORT_SYMBOL(sync_page_range);
 
-/*
+/**
+ * sync_page_range_nolock
+ * @inode:	target inode
+ * @mapping:	target address_space
+ * @pos:	beginning offset in pages to write
+ * @count:	number of bytes to write
+ *
  * Note: Holding i_mutex across sync_page_range_nolock is not a good idea
  * as it forces O_SYNC writers to different parts of the same file
  * to be serialised right until io completion.
@@ -329,10 +351,11 @@ int sync_page_range_nolock(struct inode 
 EXPORT_SYMBOL(sync_page_range_nolock);
 
 /**
- * filemap_fdatawait - walk the list of under-writeback pages of the given
- *     address space and wait for all of them.
- *
+ * filemap_fdatawait - wait for all under-writeback pages to complete
  * @mapping: address space structure to wait for
+ *
+ * Walk the list of under-writeback pages of the given address space
+ * and wait for all of them.
  */
 int filemap_fdatawait(struct address_space *mapping)
 {
@@ -368,7 +391,12 @@ int filemap_write_and_wait(struct addres
 }
 EXPORT_SYMBOL(filemap_write_and_wait);
 
-/*
+/**
+ * filemap_write_and_wait_range - write out & wait on a file range
+ * @mapping:	the address_space for the pages
+ * @lstart:	offset in bytes where the range starts
+ * @lend:	offset in bytes where the range ends (inclusive)
+ *
  * Write out and wait upon file offsets lstart->lend, inclusive.
  *
  * Note that `lend' is inclusive (describes the last byte to be written) so
@@ -394,8 +422,14 @@ int filemap_write_and_wait_range(struct 
 	return err;
 }
 
-/*
- * This function is used to add newly allocated pagecache pages:
+/**
+ * add_to_page_cache - add newly allocated pagecache pages
+ * @page:	page to add
+ * @mapping:	the page's address_space
+ * @offset:	page index
+ * @gfp_mask:	page allocation mode
+ *
+ * This function is used to add newly allocated pagecache pages;
  * the page is new, so we can just run SetPageLocked() against it.
  * The other page state flags were set by rmqueue().
  *
@@ -422,7 +456,6 @@ int add_to_page_cache(struct page *page,
 	}
 	return error;
 }
-
 EXPORT_SYMBOL(add_to_page_cache);
 
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
@@ -489,8 +522,7 @@ void fastcall wait_on_page_bit(struct pa
 EXPORT_SYMBOL(wait_on_page_bit);
 
 /**
- * unlock_page() - unlock a locked page
- *
+ * unlock_page - unlock a locked page
  * @page: the page
  *
  * Unlocks the page and wakes up sleepers in ___wait_on_page_locked().
@@ -513,8 +545,9 @@ void fastcall unlock_page(struct page *p
 }
 EXPORT_SYMBOL(unlock_page);
 
-/*
- * End writeback against a page.
+/**
+ * end_page_writeback - end writeback against a page
+ * @page: the page
  */
 void end_page_writeback(struct page *page)
 {
@@ -527,10 +560,11 @@ void end_page_writeback(struct page *pag
 }
 EXPORT_SYMBOL(end_page_writeback);
 
-/*
- * Get a lock on the page, assuming we need to sleep to get it.
+/**
+ * __lock_page - get a lock on the page, assuming we need to sleep to get it
+ * @page: the page to lock
  *
- * Ugly: running sync_page() in state TASK_UNINTERRUPTIBLE is scary.  If some
+ * Ugly. Running sync_page() in state TASK_UNINTERRUPTIBLE is scary.  If some
  * random driver's requestfn sets TASK_RUNNING, we could busywait.  However
  * chances are that on the second loop, the block layer's plug list is empty,
  * so sync_page() will then return in state TASK_UNINTERRUPTIBLE.
@@ -544,8 +578,12 @@ void fastcall __lock_page(struct page *p
 }
 EXPORT_SYMBOL(__lock_page);
 
-/*
- * a rather lightweight function, finding and getting a reference to a
+/**
+ * find_get_page - find and get a page reference
+ * @mapping: the address_space to search
+ * @offset: the page index
+ *
+ * A rather lightweight function, finding and getting a reference to a
  * hashed page atomically.
  */
 struct page * find_get_page(struct address_space *mapping, unsigned long offset)
@@ -559,11 +597,14 @@ struct page * find_get_page(struct addre
 	read_unlock_irq(&mapping->tree_lock);
 	return page;
 }
-
 EXPORT_SYMBOL(find_get_page);
 
-/*
- * Same as above, but trylock it instead of incrementing the count.
+/**
+ * find_trylock_page - find and lock a page
+ * @mapping: the address_space to search
+ * @offset: the page index
+ *
+ * Same as find_get_page(), but trylock it instead of incrementing the count.
  */
 struct page *find_trylock_page(struct address_space *mapping, unsigned long offset)
 {
@@ -576,12 +617,10 @@ struct page *find_trylock_page(struct ad
 	read_unlock_irq(&mapping->tree_lock);
 	return page;
 }
-
 EXPORT_SYMBOL(find_trylock_page);
 
 /**
  * find_lock_page - locate, pin and lock a pagecache page
- *
  * @mapping: the address_space to search
  * @offset: the page index
  *
@@ -617,12 +656,10 @@ repeat:
 	read_unlock_irq(&mapping->tree_lock);
 	return page;
 }
-
 EXPORT_SYMBOL(find_lock_page);
 
 /**
  * find_or_create_page - locate or add a pagecache page
- *
  * @mapping: the page's address_space
  * @index: the page's index into the mapping
  * @gfp_mask: page allocation mode
@@ -663,7 +700,6 @@ repeat:
 		page_cache_release(cached_page);
 	return page;
 }
-
 EXPORT_SYMBOL(find_or_create_page);
 
 /**
@@ -729,9 +765,16 @@ unsigned find_get_pages_contig(struct ad
 	return i;
 }
 
-/*
+/**
+ * find_get_pages_tag - find and return pages that match @tag
+ * @mapping:	the address_space to search
+ * @index:	the starting page index
+ * @tag:	the tag index
+ * @nr_pages:	the maximum number of pages
+ * @pages:	where the resulting pages are placed
+ *
  * Like find_get_pages, except we only return pages which are tagged with
- * `tag'.   We update *index to index the next page for the traversal.
+ * @tag.   We update @index to index the next page for the traversal.
  */
 unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 			int tag, unsigned int nr_pages, struct page **pages)
@@ -750,7 +793,11 @@ unsigned find_get_pages_tag(struct addre
 	return ret;
 }
 
-/*
+/**
+ * grab_cache_page_nowait - returns locked page at given index in given cache
+ * @mapping: target address_space
+ * @index: the page index
+ *
  * Same as grab_cache_page, but do not wait if the page is unavailable.
  * This is intended for speculative data generators, where the data can
  * be regenerated if the page couldn't be grabbed.  This routine should
@@ -779,19 +826,25 @@ grab_cache_page_nowait(struct address_sp
 	}
 	return page;
 }
-
 EXPORT_SYMBOL(grab_cache_page_nowait);
 
-/*
+/**
+ * do_generic_mapping_read - generic file read routine
+ * @mapping:	address_space to be read
+ * @_ra:	file's readahead state
+ * @filp:	the file to read
+ * @ppos:	current file position
+ * @desc:	read_descriptor
+ * @actor:	read method
+ *
  * This is a generic file read routine, and uses the
- * mapping->a_ops->readpage() function for the actual low-level
- * stuff.
+ * mapping->a_ops->readpage() function for the actual low-level stuff.
  *
  * This is really ugly. But the goto's actually try to clarify some
  * of the logic when it comes to error handling etc.
  *
- * Note the struct file* is only passed for the use of readpage.  It may be
- * NULL.
+ * Note the struct file* is only passed for the use of readpage.
+ * It may be NULL.
  */
 void do_generic_mapping_read(struct address_space *mapping,
 			     struct file_ra_state *_ra,
@@ -1004,7 +1057,6 @@ out:
 	if (filp)
 		file_accessed(filp);
 }
-
 EXPORT_SYMBOL(do_generic_mapping_read);
 
 int file_read_actor(read_descriptor_t *desc, struct page *page,
@@ -1045,7 +1097,13 @@ success:
 	return size;
 }
 
-/*
+/**
+ * __generic_file_aio_read - generic filesystem read routine
+ * @iocb:	kernel I/O control block
+ * @iov:	io vector request
+ * @nr_segs:	number of segments in the iovec
+ * @ppos:	current file position
+ *
  * This is the "read()" routine for all filesystems
  * that can use the page cache directly.
  */
@@ -1124,7 +1182,6 @@ __generic_file_aio_read(struct kiocb *io
 out:
 	return retval;
 }
-
 EXPORT_SYMBOL(__generic_file_aio_read);
 
 ssize_t
@@ -1135,7 +1192,6 @@ generic_file_aio_read(struct kiocb *iocb
 	BUG_ON(iocb->ki_pos != pos);
 	return __generic_file_aio_read(iocb, &local_iov, 1, &iocb->ki_pos);
 }
-
 EXPORT_SYMBOL(generic_file_aio_read);
 
 ssize_t
@@ -1151,7 +1207,6 @@ generic_file_read(struct file *filp, cha
 		ret = wait_on_sync_kiocb(&kiocb);
 	return ret;
 }
-
 EXPORT_SYMBOL(generic_file_read);
 
 int file_send_actor(read_descriptor_t * desc, struct page *page, unsigned long offset, unsigned long size)
@@ -1192,7 +1247,6 @@ ssize_t generic_file_sendfile(struct fil
 		return desc.written;
 	return desc.error;
 }
-
 EXPORT_SYMBOL(generic_file_sendfile);
 
 static ssize_t
@@ -1228,11 +1282,15 @@ asmlinkage ssize_t sys_readahead(int fd,
 }
 
 #ifdef CONFIG_MMU
-/*
+static int FASTCALL(page_cache_read(struct file * file, unsigned long offset));
+/**
+ * page_cache_read - adds requested page to the page cache if not already there
+ * @file:	file to read
+ * @offset:	page index
+ *
  * This adds the requested page to the page cache if it isn't already there,
  * and schedules an I/O to read in its contents from disk.
  */
-static int FASTCALL(page_cache_read(struct file * file, unsigned long offset));
 static int fastcall page_cache_read(struct file * file, unsigned long offset)
 {
 	struct address_space *mapping = file->f_mapping;
@@ -1259,7 +1317,12 @@ static int fastcall page_cache_read(stru
 
 #define MMAP_LOTSAMISS  (100)
 
-/*
+/**
+ * filemap_nopage - read in file data for page fault handling
+ * @area:	the applicable vm_area
+ * @address:	target address to read in
+ * @type:	returned with VM_FAULT_{MINOR,MAJOR} if not %NULL
+ *
  * filemap_nopage() is invoked via the vma operations vector for a
  * mapped memory region to read in file data during a page fault.
  *
@@ -1462,7 +1525,6 @@ page_not_uptodate:
 	page_cache_release(page);
 	return NULL;
 }
-
 EXPORT_SYMBOL(filemap_nopage);
 
 static struct page * filemap_getpage(struct file *file, unsigned long pgoff,
@@ -1716,7 +1778,13 @@ repeat:
 	return page;
 }
 
-/*
+/**
+ * read_cache_page - read into page cache, fill it if needed
+ * @mapping:	the page's address_space
+ * @index:	the page index
+ * @filler:	function to perform the read
+ * @data:	destination for read data
+ *
  * Read into the page cache. If a page already exists,
  * and PageUptodate() is not set, try to fill the page.
  */
@@ -1754,7 +1822,6 @@ retry:
  out:
 	return page;
 }
-
 EXPORT_SYMBOL(read_cache_page);
 
 /*
@@ -1854,7 +1921,7 @@ __filemap_copy_from_user_iovec(char *vad
 /*
  * Performs necessary checks before doing a write
  *
- * Can adjust writing position aor amount of bytes to write.
+ * Can adjust writing position or amount of bytes to write.
  * Returns appropriate error code that caller should return or
  * zero in case that write should be allowed.
  */


---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
