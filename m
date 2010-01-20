Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A8F436B0071
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:57:32 -0500 (EST)
Date: Wed, 20 Jan 2010 13:57:12 -0800
From: Chris Frost <frost@cs.ucla.edu>
Subject: [PATCH] fs: add fincore(2) (mincore(2) for file descriptors)
Message-ID: <20100120215712.GO27212@frostnet.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benny Halevy <bhalevy@panasas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steve VanDeBogart <vandebo-lkml@nerdbox.net>
List-ID: <linux-mm.kvack.org>

Add the fincore() system call. fincore() is mincore() for file descriptors.

The functionality of fincore() can be emulated with an mmap(), mincore(),
and munmap(), but this emulation requires more system calls and requires
page table modifications. fincore() can provide a significant performance
improvement for non-sequential in-core queries.

Signed-off-by: Chris Frost <frost@cs.ucla.edu>
Signed-off-by: Steve VanDeBogart <vandebo@cs.ucla.edu>
---

Notes on micro and macro performance and on a potential optimization:

For a microbenchmark that sequentially queries whether the pages of a large
file are in memory fincore is 7-11x faster than mmap+mincore+munmap
when querying one page a time (Pentium 4 running a 32 bit SMP kernel).
When querying 1024 pages at a time the two approaches perform comparably.
However, an application cannot always amortize calls; e.g., non-sequential
reads. These improvements are increased significantly by amortizing the
RCU work done by each find_get_page() call, but this optimization does
not affect our macrobenchmarks (more in third paragraph).

We introduced this system call while modifying SQLite and the GIMP to
request large prefetches for what would otherwise be non-sequential reads.
As a macrobenchmark, we see a 125s SQLite query (72s system time) reduced
to 75s (18s system time) by using fincore() instead of mincore(). This
speedup of course varies by benchmark and benchmarks size; we've seen
both minimal speedups and 1000x speedups. More on these benchmarks in the
publication _Reducing Seek Overhead with Application-Directed Prefetching_
in USENIX ATC 2009 and at http://libprefetch.cs.ucla.edu/.

In this patch find_get_page() is called for each page, which in turn
calls rcu_read_lock(), for each page. We have found that amortizing
these RCU calls, e.g., by introducing a variant of find_get_pages_contig()
that does not skip missing pages, can speedup the above microbenchmark
by 260x when querying many pages per system call. But we have not observed
noticeable improvements to our macrobenchmarks. I'd be happy to also post
this change or look further into it, but this seems like a reasonable
first patch, at least.

 include/linux/syscalls.h           |    2 
 fs/fincore.c                       |  135 +++++++++++++++++++++++++++
 fs/Makefile                        |    2 
 arch/x86/ia32/ia32entry.S          |    1 
 arch/x86/include/asm/unistd_32.h   |    3 
 arch/x86/include/asm/unistd_64.h   |    2 
 arch/x86/kernel/syscall_table_32.S |    1 
 include/asm-generic/unistd.h       |    5 -
 8 files changed, 148 insertions(+), 3 deletions(-)

diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index a990ace..1e8f00f 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -534,6 +534,8 @@ asmlinkage long sys_munlockall(void);
 asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
 asmlinkage long sys_mincore(unsigned long start, size_t len,
 				unsigned char __user * vec);
+asmlinkage long sys_fincore(unsigned int fd, loff_t start, loff_t len,
+				unsigned char __user *vec);
 
 asmlinkage long sys_pivot_root(const char __user *new_root,
 				const char __user *put_old);
diff --git a/fs/fincore.c b/fs/fincore.c
new file mode 100644
index 0000000..6b74cc4
--- /dev/null
+++ b/fs/fincore.c
@@ -0,0 +1,135 @@
+/*
+ *	fs/fincore.c
+ *
+ * Copyright (C) 2009, 2010 Chris Frost, UC Regents
+ * Copyright (C) 2008 Steve VanDeBogart, UC Regents
+ */
+
+/*
+ * The fincore() system call.
+ */
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/pagemap.h>
+#include <linux/syscalls.h>
+#include <linux/uaccess.h>
+
+static unsigned char fincore_page(struct address_space *mapping, pgoff_t pgoff)
+{
+	unsigned char present = 0;
+	struct page *page = find_get_page(mapping, pgoff);
+	if (page) {
+		present = PageUptodate(page);
+		page_cache_release(page);
+	}
+
+	return present;
+}
+
+/*
+ * The fincore(2) system call.
+ *
+ * fincore() returns the memory residency status of the pages backing
+ * a file range specified by fd and [start, start + len).
+ * The status is returned in a vector of bytes.  The least significant
+ * bit of each byte is 1 if the referenced page is in memory, otherwise
+ * it is zero.
+ *
+ * Because the status of a page can change after fincore() checks it
+ * but before it returns to the application, the returned vector may
+ * contain stale information.  Only locked pages are guaranteed to
+ * remain in memory.
+ *
+ * return values:
+ *  zero    - success
+ *  -EBADF  - fd is an illegal file descriptor
+ *  -EFAULT - vec points to an illegal address
+ *  -EINVAL - start is not a multiple of PAGE_CACHE_SIZE or start + len
+ *		is larger than the size of the file
+ *  -EAGAIN - A kernel resource was temporarily unavailable.
+ */
+SYSCALL_DEFINE4(fincore, unsigned int, fd, loff_t, start, loff_t, len,
+		unsigned char __user *, vec)
+{
+	long retval;
+	loff_t pgoff = start >> PAGE_SHIFT;
+	loff_t pgend;
+	loff_t npages;
+	struct file *filp;
+	int fput_needed;
+	loff_t file_nbytes;
+	loff_t file_npages;
+	unsigned char *tmp = NULL;
+	unsigned char tmp_small[64];
+	unsigned tmp_count;
+	int i;
+
+	/* Check the start address: needs to be page-aligned.. */
+	if (start & ~PAGE_CACHE_MASK)
+		return -EINVAL;
+
+	npages = len >> PAGE_SHIFT;
+	npages += (len & ~PAGE_MASK) != 0;
+
+	pgend = pgoff + npages;
+
+	filp = fget_light(fd, &fput_needed);
+	if (!filp)
+		return -EBADF;
+
+	if (filp->f_dentry->d_inode->i_mode & S_IFBLK)
+		file_nbytes = filp->f_dentry->d_inode->i_bdev->bd_inode->i_size << 9;
+	else
+		file_nbytes = filp->f_dentry->d_inode->i_size;
+
+	file_npages = file_nbytes >> PAGE_SHIFT;
+	file_npages += (file_nbytes & ~PAGE_MASK) != 0;
+
+	if (pgoff >= file_npages || pgend > file_npages) {
+		retval = -EINVAL;
+		goto done;
+	}
+
+	if (!access_ok(VERIFY_WRITE, vec, npages)) {
+		retval = -EFAULT;
+		goto done;
+	}
+
+	/*
+	 * Allocate buffer vector page.
+	 * Optimize allocation for small values of npages because the
+	 * __get_free_page() call doubles fincore(2) runtime when npages == 1.
+	 */
+	if (npages <= sizeof(tmp_small)) {
+		tmp = tmp_small;
+		tmp_count = sizeof(tmp_small);
+	} else {
+		tmp = (void *) __get_free_page(GFP_USER);
+		if (!tmp) {
+			retval = -EAGAIN;
+			goto done;
+		}
+		tmp_count = PAGE_SIZE;
+	}
+
+	while (pgoff < pgend) {
+		/*
+		 * Do at most tmp_count entries per iteration, due to
+		 * the temporary buffer size.
+		 */
+		for (i = 0; pgoff < pgend && i < tmp_count; pgoff++, i++)
+			tmp[i] = fincore_page(filp->f_mapping, pgoff);
+
+		if (copy_to_user(vec, tmp, i)) {
+			retval = -EFAULT;
+			break;
+		}
+		vec += i;
+	}
+	retval = 0;
+done:
+	if (tmp && tmp != tmp_small)
+		free_page((unsigned long) tmp);
+	fput_light(filp, fput_needed);
+	return retval;
+}
diff --git a/fs/Makefile b/fs/Makefile
index af6d047..a3ccd6b 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -11,7 +11,7 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		attr.o bad_inode.o file.o filesystems.o namespace.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o drop_caches.o splice.o sync.o utimes.o \
-		stack.o fs_struct.o
+		stack.o fs_struct.o fincore.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o bio.o block_dev.o direct-io.o mpage.o ioprio.o
diff --git a/include/asm-generic/unistd.h b/include/asm-generic/unistd.h
index d76b66a..ce76dc8 100644
--- a/include/asm-generic/unistd.h
+++ b/include/asm-generic/unistd.h
@@ -623,8 +623,11 @@ __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
 #define __NR_perf_event_open 241
 __SYSCALL(__NR_perf_event_open, sys_perf_event_open)
 
+#define __NR_fincore 242
+__SYSCALL(__NR_fincore, sys_fincore)
+
 #undef __NR_syscalls
-#define __NR_syscalls 242
+#define __NR_syscalls 243
 
 /*
  * All syscalls below here should go away really,
diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index 581b056..cbf96e6 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -841,4 +841,5 @@ ia32_sys_call_table:
 	.quad compat_sys_pwritev
 	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
 	.quad sys_perf_event_open
+	.quad sys_fincore
 ia32_syscall_end:
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index 6fb3c20..088b235 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -342,10 +342,11 @@
 #define __NR_pwritev		334
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_event_open	336
+#define __NR_fincore		337
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 337
+#define NR_syscalls 338
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index 8d3ad0a..ebc04b5 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -661,6 +661,8 @@ __SYSCALL(__NR_pwritev, sys_pwritev)
 __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
 #define __NR_perf_event_open			298
 __SYSCALL(__NR_perf_event_open, sys_perf_event_open)
+#define __NR_fincore				299
+__SYSCALL(__NR_fincore, sys_fincore)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index 0157cd2..1fdc8bc 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -336,3 +336,4 @@ ENTRY(sys_call_table)
 	.long sys_pwritev
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_event_open
+	.long sys_fincore
-- 
1.5.4.3

-- 
Chris Frost
http://www.frostnet.net/chris/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
