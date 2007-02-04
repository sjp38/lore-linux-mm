Date: Sun, 4 Feb 2007 16:10:51 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-ID: <20070204151051.GB12771@wotan.suse.de>
References: <20070204063707.23659.20741.sendpatchset@linux.site> <20070204063833.23659.55105.sendpatchset@linux.site> <20070204014445.88e6c8c7.akpm@linux-foundation.org> <20070204101529.GA22004@wotan.suse.de> <20070204023055.2583fd65.akpm@linux-foundation.org> <20070204104609.GA29943@wotan.suse.de> <20070204025602.a5f8c53a.akpm@linux-foundation.org> <20070204110317.GA9034@wotan.suse.de> <20070204031549.203f7b47.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070204031549.203f7b47.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Feb 04, 2007 at 03:15:49AM -0800, Andrew Morton wrote:
> On Sun, 4 Feb 2007 12:03:17 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > On Sun, Feb 04, 2007 at 02:56:02AM -0800, Andrew Morton wrote:
> > > On Sun, 4 Feb 2007 11:46:09 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > > 
> > > If that recollection is right, I think we could afford to reintroduce that
> > > problem, frankly.  Especially as it only happens in the incredibly rare
> > > case of that get_user()ed page getting unmapped under our feet.
> > 
> > Dang. I was hoping to fix it without introducing data corruption.
> 
> Well.  It's a compromise.  Being practical about it, I reeeealy doubt that
> anyone will hit this combination of circumstances.

They're not likely to hit the deadlocks, either. Probability gets more
likely after my patch to lock the page in the fault path. But practially,
we could live without that too, because the data corruption it fixes is
very rare as well. Which is exactly what we've been doing quite happily
for most of 2.6, including all distro kernels (I think).

But (sadly) for me, there is no compromise. I may be known as the clown
who tries outlandish things to shave a few atomic ops and interrupt flag
changes in the page allocator, or make the pagecache lockless. However
I can't be happy even making something faster if correctness is < 100.0%,
even if less likely than hardware failure.

> > > > > > but you introduce the theoretical memory deadlock
> > > > > > where a task cannot reclaim its own memory.
> > > > > 
> > > > > Nah, that'll never happen - both pages are already allocated.
> > > > 
> > > > Both pages? I don't get it.
> > > > 
> > > > You set the don't-reclaim vma flag, then run get_user, which takes a
> > > > page fault and potentially has to allocate N pages for pagetables,
> > > > pagecache readahead, buffers and fs private data and pagecache radix
> > > > tree nodes for all of the pages read in.
> > > 
> > > Oh, OK.  Need to do the get_user() twice then.  Once before taking that new
> > > rwsem.
> > 
> > Race condition remains.
> 
> No, not in a million years.

There is a huge window. Think about what other activity will be holding
that very rwsem for write, that you'll have to wait for in the race window.
But you could say that's also a question of practicality, because it is
pretty unlikely to do anything bad even if you do hit the race.

Well if fixing this is just going to be flat-out vetoed on performance
reasons then I can't argue, because it does impact performance.

Thinking about the numbers, if your kernel's reliability is already the
same order of magnitude as reliability of commodity hardware, then
trading a bit of performance for a bit of reliability is a BAD tradeoff
if you are at all interested in performance on commodity hardware. That
is especially true if you have a massive redundant cluster of commodity
systems, which I understand is a fairly big market for Linux. The 
X-nines guys who would disagree are probably a tiny niche for Linux.

So I do understand your argument for praticality, even if I don't agree.

For the record, here is the "temporary page" fix that should fix it
properly. And some numbers.

Nick

--

Modify the core write() code so that it won't take a pagefault while holding a
lock on the pagecache page. There are a number of different deadlocks possible
if we try to do such a thing:

1.  generic_buffered_write
2.   lock_page
3.    prepare_write
4.     unlock_page+vmtruncate
5.     copy_from_user
6.      mmap_sem(r)
7.       handle_mm_fault
8.        lock_page (filemap_nopage)
9.    commit_write
10.  unlock_page

a. sys_munmap / sys_mlock / others
b.  mmap_sem(w)
c.   make_pages_present
d.    get_user_pages
e.     handle_mm_fault
f.      lock_page (filemap_nopage)

2,8	- recursive deadlock if page is same
2,8;2,8	- ABBA deadlock is page is different
2,6;b,f	- ABBA deadlock if page is same

The solution is as follows:
1.  If we find the destination page is uptodate, continue as normal, but use
    atomic usercopies which do not take pagefaults and do not zero the uncopied
    tail of the destination. The destination is already uptodate, so we can
    commit_write the full length even if there was a partial copy: it does not
    matter that the tail was not modified, because if it is dirtied and written
    back to disk it will not cause any problems (uptodate *means* that the
    destination page is as new or newer than the copy on disk).

1a. The above requires that fault_in_pages_readable correctly returns access
    information, because atomic usercopies cannot distinguish between
    non-present pages in a readable mapping, from lack of a readable mapping.

2.  If we find the destination page is non uptodate, unlock it (this could be
    made slightly more optimal), then allocate a temporary page to copy the
    source data into. Relock the destination page and continue with the copy.
    However, instead of a usercopy (which might take a fault), copy the data
    from the pinned temporary page via the kernel address space.

(also, rename maxlen to seglen, because it was confusing)

On a P4 Xeon, SMP kernel, on a tmpfs filesystem, a 1GB dd if=/dev/zero write
had the following performance (higher is worse):

Orig kernel			New kernel
new file (no pagecache)
4K  blocks 1.280s		1.287s (+0.5%)
64K blocks 1.090s		1.105s (+1.4%)
notrunc (uptodate pagecache)
4K  blocks 0.976s		1.001s (+0.5%)
64K blocks 0.780s		0.792s (+1.5%)

[numbers are better than +/- 0.005]

So we lose somewhere between half and one and a half of one percent
performance in a pagecache write intensive workload.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -2052,11 +2052,12 @@ generic_file_buffered_write(struct kiocb
 	filemap_set_next_iovec(&cur_iov, nr_segs, &iov_offset, written);
 
 	do {
+		struct page *src_page;
 		struct page *page;
 		pgoff_t index;		/* Pagecache index for current page */
 		unsigned long offset;	/* Offset into pagecache page */
-		unsigned long maxlen;	/* Bytes remaining in current iovec */
-		size_t bytes;		/* Bytes to write to page */
+		unsigned long seglen;	/* Bytes remaining in current iovec */
+		unsigned long bytes;	/* Bytes to write to page */
 		size_t copied;		/* Bytes copied from user */
 
 		buf = cur_iov->iov_base + iov_offset;
@@ -2066,20 +2067,30 @@ generic_file_buffered_write(struct kiocb
 		if (bytes > count)
 			bytes = count;
 
-		maxlen = cur_iov->iov_len - iov_offset;
-		if (maxlen > bytes)
-			maxlen = bytes;
+		/*
+		 * a non-NULL src_page indicates that we're doing the
+		 * copy via get_user_pages and kmap.
+		 */
+		src_page = NULL;
+
+		seglen = cur_iov->iov_len - iov_offset;
+		if (seglen > bytes)
+			seglen = bytes;
 
-#ifndef CONFIG_DEBUG_VM
 		/*
 		 * Bring in the user page that we will copy from _first_.
 		 * Otherwise there's a nasty deadlock on copying from the
 		 * same page as we're writing to, without it being marked
 		 * up-to-date.
+		 *
+		 * Not only is this an optimisation, but it is also required
+		 * to check that the address is actually valid, when atomic
+		 * usercopies are used, below.
 		 */
-		fault_in_pages_readable(buf, maxlen);
-#endif
-
+		if (unlikely(fault_in_pages_readable(buf, seglen))) {
+			status = -EFAULT;
+			break;
+		}
 
 		page = __grab_cache_page(mapping, index);
 		if (!page) {
@@ -2087,32 +2098,96 @@ generic_file_buffered_write(struct kiocb
 			break;
 		}
 
+		/*
+		 * non-uptodate pages cannot cope with short copies, and we
+		 * cannot take a pagefault with the destination page locked.
+		 * So pin the source page to copy it.
+		 */
+		if (!PageUptodate(page)) {
+			unlock_page(page);
+
+			src_page = alloc_page(GFP_KERNEL);
+			if (!src_page) {
+				page_cache_release(page);
+				status = -ENOMEM;
+				break;
+			}
+
+			/*
+			 * Cannot get_user_pages with a page locked for the
+			 * same reason as we can't take a page fault with a
+			 * page locked (as explained below).
+			 */
+			copied = filemap_copy_from_user(src_page, offset,
+					cur_iov, nr_segs, iov_offset, bytes);
+			if (unlikely(copied == 0)) {
+				status = -EFAULT;
+				page_cache_release(page);
+				page_cache_release(src_page);
+				break;
+			}
+			bytes = copied;
+
+			lock_page(page);
+			if (unlikely(!page->mapping)) {
+				unlock_page(page);
+				page_cache_release(page);
+				page_cache_release(src_page);
+				continue;
+			}
+
+		}
+
 		status = a_ops->prepare_write(file, page, offset, offset+bytes);
 		if (unlikely(status))
 			goto fs_write_aop_error;
 
-		copied = filemap_copy_from_user(page, offset,
+		if (!src_page) {
+			/*
+			 * Must not enter the pagefault handler here, because
+			 * we hold the page lock, so we might recursively
+			 * deadlock on the same lock, or get an ABBA deadlock
+			 * against a different lock, or against the mmap_sem
+			 * (which nests outside the page lock).  So increment
+			 * preempt count, and use _atomic usercopies.
+			 *
+			 * The page is uptodate so we are OK to encounter a
+			 * short copy: if unmodified parts of the page are
+			 * marked dirty and written out to disk, it doesn't
+			 * really matter.
+			 */
+			pagefault_disable();
+			copied = filemap_copy_from_user_atomic(page, offset,
 					cur_iov, nr_segs, iov_offset, bytes);
+			pagefault_enable();
+		} else {
+			void *src, *dst;
+			src = kmap_atomic(src_page, KM_USER0);
+			dst = kmap_atomic(page, KM_USER1);
+			memcpy(dst + offset, src + offset, bytes);
+			kunmap_atomic(dst, KM_USER1);
+			kunmap_atomic(src, KM_USER0);
+			copied = bytes;
+		}
 		flush_dcache_page(page);
 
 		status = a_ops->commit_write(file, page, offset, offset+bytes);
 		if (unlikely(status < 0))
 			goto fs_write_aop_error;
-		if (unlikely(copied != bytes)) {
-			status = -EFAULT;
-			goto fs_write_aop_error;
-		}
 		if (unlikely(status > 0)) /* filesystem did partial write */
-			copied = status;
+			copied = min_t(size_t, copied, status);
+
+		unlock_page(page);
+		mark_page_accessed(page);
+		page_cache_release(page);
+		if (src_page)
+			page_cache_release(src_page);
 
 		written += copied;
 		count -= copied;
 		pos += copied;
 		filemap_set_next_iovec(&cur_iov, nr_segs, &iov_offset, copied);
 
-		unlock_page(page);
-		mark_page_accessed(page);
-		page_cache_release(page);
 		balance_dirty_pages_ratelimited(mapping);
 		cond_resched();
 		continue;
@@ -2121,6 +2196,8 @@ fs_write_aop_error:
 		if (status != AOP_TRUNCATED_PAGE)
 			unlock_page(page);
 		page_cache_release(page);
+		if (src_page)
+			page_cache_release(src_page);
 
 		/*
 		 * prepare_write() may have instantiated a few blocks
@@ -2133,7 +2210,6 @@ fs_write_aop_error:
 			continue;
 		else
 			break;
-
 	} while (count);
 	*ppos = pos;
 
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -198,6 +198,9 @@ static inline int fault_in_pages_writeab
 {
 	int ret;
 
+	if (unlikely(size == 0))
+		return 0;
+
 	/*
 	 * Writing zeroes into userspace here is OK, because we know that if
 	 * the zero gets there, we'll be overwriting it.
@@ -217,19 +220,23 @@ static inline int fault_in_pages_writeab
 	return ret;
 }
 
-static inline void fault_in_pages_readable(const char __user *uaddr, int size)
+static inline int fault_in_pages_readable(const char __user *uaddr, int size)
 {
 	volatile char c;
 	int ret;
 
+	if (unlikely(size == 0))
+		return 0;
+
 	ret = __get_user(c, uaddr);
 	if (ret == 0) {
 		const char __user *end = uaddr + size - 1;
 
 		if (((unsigned long)uaddr & PAGE_MASK) !=
 				((unsigned long)end & PAGE_MASK))
-		 	__get_user(c, end);
+		 	ret = __get_user(c, end);
 	}
+	return ret;
 }
 
 #endif /* _LINUX_PAGEMAP_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
