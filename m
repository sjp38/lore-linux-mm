Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 608116B004D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 14:01:50 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so16281197wib.11
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 11:01:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r4si3341431wic.58.2014.07.07.11.01.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 11:01:48 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 1/3] mm: introduce fincore()
Date: Mon,  7 Jul 2014 14:00:04 -0400
Message-Id: <1404756006-23794-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1404756006-23794-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1404756006-23794-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch provides a new system call fincore(), which extracts mincore()-
like information from the kernel, i.e. page residency of a given file.
But unlike mincore(), fincore() has a mode flag which allows us to extract
more detailed information like pfn and page flag. This kind of information
is helpful, for example when applications want to know the file cache status
to control the IO on their own way.
There was some complaint around current mincore() API, where we have only
one byte for each page and mincore() is not extensible without breaking
existing applications, so the mode flag is to avoid the same problem.

The details about the data format being passed to userspace are explained
in inline comment, but generally in long entry format, we can choose which
information is extraced flexibly, so you don't have to waste memory by
extracting unnecessary information. And with FINCORE_PGOFF flag, we can skip
hole pages (not on memory,) which makes us avoid a flood of meaningless
zero entries when calling on extremely large (but only few pages of it
are loaded on memory) file.

Basic testset is added in the next patch on tools/testing/selftests/fincore/.

ChangeLog v3:
- remove pagecache tag things
- rename include/uapi/linux/pagecache.h to include/uapi/linux/fincore.h

ChangeLog v2:
- move definition of FINCORE_* to include/uapi/linux/pagecache.h
- add another parameter fincore_extra to sys_fincore()
- rename FINCORE_SKIP_HOLE to FINCORE_PGOFF and change bit order.
- add valid argument check (start should be inside file address range,
  nr_pages should be positive)
- add end-of-file check (scan to the end of file even if the last page
  is a hole)
- add access_ok(VERIFY_WIRTE) (copied from mincore())
- update inline comments

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/x86/syscalls/syscall_64.tbl |   1 +
 include/linux/syscalls.h         |   4 +
 include/uapi/linux/fincore.h     |  84 ++++++++++++
 mm/Makefile                      |   2 +-
 mm/fincore.c                     | 286 +++++++++++++++++++++++++++++++++++++++
 5 files changed, 376 insertions(+), 1 deletion(-)
 create mode 100644 include/uapi/linux/fincore.h
 create mode 100644 mm/fincore.c

diff --git v3.16-rc3.orig/arch/x86/syscalls/syscall_64.tbl v3.16-rc3/arch/x86/syscalls/syscall_64.tbl
index ec255a1646d2..9d291b7081ca 100644
--- v3.16-rc3.orig/arch/x86/syscalls/syscall_64.tbl
+++ v3.16-rc3/arch/x86/syscalls/syscall_64.tbl
@@ -323,6 +323,7 @@
 314	common	sched_setattr		sys_sched_setattr
 315	common	sched_getattr		sys_sched_getattr
 316	common	renameat2		sys_renameat2
+317	common	fincore			sys_fincore
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git v3.16-rc3.orig/include/linux/syscalls.h v3.16-rc3/include/linux/syscalls.h
index b0881a0ed322..60795ee8f9ee 100644
--- v3.16-rc3.orig/include/linux/syscalls.h
+++ v3.16-rc3/include/linux/syscalls.h
@@ -65,6 +65,7 @@ struct old_linux_dirent;
 struct perf_event_attr;
 struct file_handle;
 struct sigaltstack;
+struct fincore_extra;
 
 #include <linux/types.h>
 #include <linux/aio_abi.h>
@@ -866,4 +867,7 @@ asmlinkage long sys_process_vm_writev(pid_t pid,
 asmlinkage long sys_kcmp(pid_t pid1, pid_t pid2, int type,
 			 unsigned long idx1, unsigned long idx2);
 asmlinkage long sys_finit_module(int fd, const char __user *uargs, int flags);
+asmlinkage long sys_fincore(int fd, loff_t start, long nr_pages,
+			int mode, unsigned char __user *vec,
+			struct fincore_extra __user *extra);
 #endif
diff --git v3.16-rc3.orig/include/uapi/linux/fincore.h v3.16-rc3/include/uapi/linux/fincore.h
new file mode 100644
index 000000000000..30797e68a8d4
--- /dev/null
+++ v3.16-rc3/include/uapi/linux/fincore.h
@@ -0,0 +1,84 @@
+#ifndef _UAPI_LINUX_FINCORE_H
+#define _UAPI_LINUX_FINCORE_H
+
+/*
+ * You can control how the buffer in userspace is filled with this mode
+ * parameters:
+ *
+ * - FINCORE_BMAP:
+ *     the page status is returned in a vector of bytes.
+ *     The least significant bit of each byte is 1 if the referenced page
+ *     is in memory, otherwise it is zero.
+ *
+ * - FINCORE_PGOFF:
+ *     if this flag is set, fincore() doesn't store any information about
+ *     holes. Instead each records per page has the entry of page offset,
+ *     using 8 bytes. This mode is useful if we handle a large file and
+ *     only few pages are on memory.
+ *
+ * - FINCORE_PFN:
+ *     stores pfn, using 8 bytes.
+ *
+ * - FINCORE_PAGEFLAGS:
+ *     stores page flags, using 8 bytes. See definition of KPF_* for
+ *     details of each bit.
+ *
+ * FINCORE_BMAP shouldn't be used combined with any other flags, and returnd
+ * data in this mode is like this:
+ *
+ *   page offset  0   1   2   3   4
+ *              +---+---+---+---+---+
+ *              | 1 | 0 | 0 | 1 | 1 | ...
+ *              +---+---+---+---+---+
+ *               <->
+ *              1 byte
+ *
+ * For FINCORE_PFN, page data is formatted like this:
+ *
+ *   page offset    0       1       2       3       4
+ *              +-------+-------+-------+-------+-------+
+ *              |  pfn  |  pfn  |  pfn  |  pfn  |  pfn  | ...
+ *              +-------+-------+-------+-------+-------+
+ *               <----->
+ *               8 byte
+ *
+ * We can use multiple flags among the flags in FINCORE_LONGENTRY_MASK.
+ * For example, when the mode is FINCORE_PFN|FINCORE_PAGEFLAGS, the per-page
+ * information is stored like this:
+ *
+ *    page offset 0    page offset 1   page offset 2   page offset 3
+ *                                        (hole)
+ *   +-------+-------+-------+-------+-------+-------+-------+-------+
+ *   |  pfn  | flags |  pfn  | flags |   0   |   0   |  pfn  | flags | ...
+ *   +-------+-------+-------+-------+-------+-------+-------+-------+
+ *    <-------------> <-------------> <-------------> <------------->
+ *       16 bytes        16 bytes        16 bytes        16 bytes
+ *
+ * When FINCORE_PGOFF is set, we store page offset entry and ignore holes
+ * For example, the data format of mode FINCORE_PGOFF|FINCORE_PFN|
+ * FINCORE_PAGEFLAGS is like follows:
+ *
+ *   +-------+-------+-------+-------+-------+-------+
+ *   | pgoff |  pfn  | flags | pgoff |  pfn  | flags | ...
+ *   +-------+-------+-------+-------+-------+-------+
+ *    <---------------------> <--------------------->
+ *           24 bytes                24 bytes
+ */
+#define FINCORE_BMAP		0x01	/* bytemap mode */
+#define FINCORE_PGOFF		0x02
+#define FINCORE_PFN		0x04
+#define FINCORE_PAGE_FLAGS	0x08
+
+#define FINCORE_MODE_MASK	0x1f
+#define FINCORE_LONGENTRY_MASK	(FINCORE_PGOFF | FINCORE_PFN | \
+				 FINCORE_PAGE_FLAGS)
+
+struct fincore_extra {
+	/*
+	 * (output) the number of entries with valid data, this is useful
+	 * if you set FINCORE_PGOFF and want to know the end of filled data.
+	 */
+	unsigned long nr_entries;
+};
+
+#endif /* _UAPI_LINUX_FINCORE_H */
diff --git v3.16-rc3.orig/mm/Makefile v3.16-rc3/mm/Makefile
index 4064f3ec145e..cc9420221afd 100644
--- v3.16-rc3.orig/mm/Makefile
+++ v3.16-rc3/mm/Makefile
@@ -18,7 +18,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o balloon_compaction.o vmacache.o \
 			   interval_tree.o list_lru.o workingset.o \
-			   iov_iter.o $(mmu-y)
+			   iov_iter.o fincore.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git v3.16-rc3.orig/mm/fincore.c v3.16-rc3/mm/fincore.c
new file mode 100644
index 000000000000..2f20ac3569df
--- /dev/null
+++ v3.16-rc3/mm/fincore.c
@@ -0,0 +1,286 @@
+/*
+ * fincore(2) system call
+ *
+ * Copyright (C) 2014 NEC Corporation, Naoya Horiguchi
+ */
+
+#include <linux/syscalls.h>
+#include <linux/pagemap.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/hugetlb.h>
+#include <uapi/linux/fincore.h>
+
+struct fincore_control {
+	int mode;
+	int width;		/* width of each entry (in bytes) */
+	unsigned char *buffer;
+	long buffer_size;
+	void *cursor;		/* current position on the buffer */
+	pgoff_t pgstart;	/* start point of page cache scan in each run
+				 * of the while loop */
+	long nr_pages;		/* number of pages to be copied to userspace
+				 * (decreasing while scan proceeds) */
+	long scanned_offset;	/* page offset of the lastest scanned page */
+	struct address_space *mapping;
+};
+
+#define store_entry(fc, type, data) ({		\
+	*(type *)fc->cursor = (type)data;	\
+	fc->cursor += sizeof(type);		\
+})
+
+/*
+ * Store page cache data to temporal buffer in the specified format depending
+ * on fincore mode.
+ */
+static void __do_fincore(struct fincore_control *fc, struct page *page,
+			 unsigned long index)
+{
+	VM_BUG_ON(!page);
+	VM_BUG_ON((unsigned long)fc->cursor - (unsigned long)fc->buffer
+		  >= fc->buffer_size);
+	if (fc->mode & FINCORE_BMAP)
+		store_entry(fc, unsigned char, PageUptodate(page));
+	else if (fc->mode & (FINCORE_LONGENTRY_MASK)) {
+		if (fc->mode & FINCORE_PGOFF)
+			store_entry(fc, unsigned long, index);
+		if (fc->mode & FINCORE_PFN)
+			store_entry(fc, unsigned long, page_to_pfn(page));
+		if (fc->mode & FINCORE_PAGE_FLAGS)
+			store_entry(fc, unsigned long, stable_page_flags(page));
+	}
+}
+
+/*
+ * Traverse page cache tree. It's assumed that temporal buffer are zeroed
+ * in advance. Due to this, we don't have to store zero entry explicitly
+ * one-by-one and we just set fc->cursor to the position of the next
+ * on-memory page.
+ *
+ * Return value is the number of pages whose data is stored in fc->buffer.
+ */
+static long do_fincore(struct fincore_control *fc, int nr_pages)
+{
+	pgoff_t pgend = fc->pgstart + nr_pages;
+	struct radix_tree_iter iter;
+	void **slot;
+	long nr = 0;
+
+	fc->cursor = fc->buffer;
+
+	rcu_read_lock();
+restart:
+	radix_tree_for_each_slot(slot, &fc->mapping->page_tree, &iter,
+				 fc->pgstart) {
+		long jump;
+		struct page *page;
+
+		fc->scanned_offset = iter.index;
+		/* Handle holes */
+		jump = iter.index - fc->pgstart - nr;
+		if (jump) {
+			if (!(fc->mode & FINCORE_PGOFF)) {
+				if (iter.index < pgend) {
+					fc->cursor += jump * fc->width;
+					nr = iter.index - fc->pgstart;
+				} else {
+					/*
+					 * Fill remaining buffer as hole. Next
+					 * call should start at offset pgend.
+					 */
+					nr = nr_pages;
+					fc->scanned_offset = pgend - 1;
+					break;
+				}
+			}
+		}
+repeat:
+		page = radix_tree_deref_slot(slot);
+		if (unlikely(!page))
+			/*
+			 * No need to increment nr and fc->cursor, because next
+			 * iteration should detect hole and update them there.
+			 */
+			continue;
+		else if (radix_tree_exception(page)) {
+			if (radix_tree_deref_retry(page)) {
+				/*
+				 * Transient condition which can only trigger
+				 * when entry at index 0 moves out of or back
+				 * to root: none yet gotten, safe to restart.
+				 */
+				WARN_ON(iter.index);
+				goto restart;
+			}
+			__do_fincore(fc, page, iter.index);
+		} else {
+			if (!page_cache_get_speculative(page))
+				goto repeat;
+
+			/* Has the page moved? */
+			if (unlikely(page != *slot)) {
+				page_cache_release(page);
+				goto repeat;
+			}
+
+			__do_fincore(fc, page, iter.index);
+			page_cache_release(page);
+		}
+
+		if (++nr == nr_pages)
+			break;
+	}
+
+	if (!(fc->mode & FINCORE_PGOFF)) {
+		nr = nr_pages;
+		fc->scanned_offset = pgend - 1;
+	}
+
+	rcu_read_unlock();
+
+	return nr;
+}
+
+static inline bool fincore_validate_mode(int mode)
+{
+	if (mode & ~FINCORE_MODE_MASK)
+		return false;
+	if (!(!!(mode & FINCORE_BMAP) ^ !!(mode & FINCORE_LONGENTRY_MASK)))
+		return false;
+	return true;
+}
+
+#define FINCORE_LOOP_STEP	256L
+
+/*
+ * The fincore(2) system call
+ *
+ *  @fd:        file descriptor of the target file
+ *  @start:     starting address offset of the target file (in byte).
+ *              This should be aligned to page cache size.
+ *  @nr_pages:  the number of pages whose data is passed to userspace.
+ *  @mode       fincore mode flags to determine the entry's format
+ *  @vec        pointer of the userspace buffer. The size must be equal to or
+ *              larger than (@nr_pages * width), where width is the size of
+ *              each entry.
+ *  @extra      used to input/output additional information from/to userspace
+ *
+ * fincore() returns the memory residency status and additional info (like
+ * pfn and page flags) of the given file's pages.
+ *
+ * Depending on the fincore mode, caller can receive the different formatted
+ * information. See the comment on definition of FINCORE_*.
+ *
+ * Because the status of a page can change after fincore() checks it once,
+ * the returned vector may contain stale information.
+ *
+ * return values:
+ *  -EBADF:   @fd isn't a valid open file descriptor
+ *  -EFAULT:  @vec points to an illegal address
+ *  -EINVAL:  @start is unaligned to page cache size or is out of file range.
+ *            Or @nr_pages is non-positive. Or @mode is invalid.
+ *  0:        fincore() is successfully done
+ */
+SYSCALL_DEFINE6(fincore, int, fd, loff_t, start, long, nr_pages,
+		int, mode, unsigned char __user *, vec,
+		struct fincore_extra __user *, extra)
+{
+	long ret = 0;
+	long step;
+	long nr = 0;
+	long pages_to_eof;
+	int pc_shift = PAGE_CACHE_SHIFT;
+	struct fd f;
+
+	struct fincore_control fc = {
+		.mode	= mode,
+		.width	= sizeof(unsigned char),
+	};
+
+	if (start < 0 || nr_pages <= 0)
+		return -EINVAL;
+
+	if (!fincore_validate_mode(mode))
+		return -EINVAL;
+
+	f = fdget(fd);
+
+	if (is_file_hugepages(f.file))
+		pc_shift = huge_page_shift(hstate_file(f.file));
+
+	if (!IS_ALIGNED(start, 1 << pc_shift)) {
+		ret = -EINVAL;
+		goto fput;
+	}
+
+	/*
+	 * TODO: support /dev/mem, /proc/pid/mem for system/process wide
+	 * page survey, which would obsolete /proc/kpageflags, and
+	 * /proc/pid/pagemap.
+	 */
+	if (!S_ISREG(file_inode(f.file)->i_mode)) {
+		ret = -EBADF;
+		goto fput;
+	}
+
+	fc.pgstart = start >> pc_shift;
+	pages_to_eof = DIV_ROUND_UP(i_size_read(file_inode(f.file)),
+				    1UL << pc_shift) - fc.pgstart;
+	/* start is too large */
+	if (pages_to_eof <= 0) {
+		ret = -EINVAL;
+		goto fput;
+	}
+	/* Never go beyond the end of file */
+	fc.nr_pages = min(pages_to_eof, nr_pages);
+	fc.mapping = f.file->f_mapping;
+	if (mode & FINCORE_LONGENTRY_MASK)
+		fc.width = ((mode & FINCORE_PGOFF ? 1 : 0) +
+			    (mode & FINCORE_PFN ? 1 : 0) +
+			    (mode & FINCORE_PAGE_FLAGS ? 1 : 0)
+			) * sizeof(unsigned long);
+
+	if (!access_ok(VERIFY_WRITE, vec, nr_pages * fc.width)) {
+		ret = -EFAULT;
+		goto fput;
+	}
+
+	step = min(fc.nr_pages, FINCORE_LOOP_STEP);
+
+	fc.buffer_size = step * fc.width;
+	fc.buffer = kmalloc(fc.buffer_size, GFP_TEMPORARY);
+	if (!fc.buffer) {
+		ret = -ENOMEM;
+		goto fput;
+	}
+
+	while (fc.nr_pages > 0) {
+		memset(fc.buffer, 0, fc.buffer_size);
+		ret = do_fincore(&fc, min(step, fc.nr_pages));
+		/* Reached the end of the file */
+		if (ret == 0)
+			break;
+		if (ret < 0)
+			break;
+		if (copy_to_user(vec + nr * fc.width,
+				 fc.buffer, ret * fc.width)) {
+			ret = -EFAULT;
+			break;
+		}
+		fc.nr_pages -= ret;
+		fc.pgstart = fc.scanned_offset + 1;
+		nr += ret;
+	}
+
+	kfree(fc.buffer);
+
+	if (extra)
+		__put_user(nr, &extra->nr_entries);
+
+fput:
+	fdput(f);
+	return ret;
+}
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
