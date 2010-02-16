Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 943556B0082
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 13:14:46 -0500 (EST)
Date: Tue, 16 Feb 2010 10:13:12 -0800
From: Chris Frost <chris@frostnet.net>
Subject: Re: [PATCH] fs: add fincore(2) (mincore(2) for file descriptors)
Message-ID: <20100216181312.GA9700@frostnet.net>
References: <20100120215712.GO27212@frostnet.net> <20100126141229.e1a81b29.akpm@linux-foundation.org> <20100120215712.GO27212@frostnet.net> <20100122011709.GA6700@localhost> <20100120215712.GO27212@frostnet.net> <87k4vc2rds.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="1yeeQ81UyVL57Vl7"
Content-Disposition: inline
In-Reply-To: <20100126141229.e1a81b29.akpm@linux-foundation.org> <20100122011709.GA6700@localhost> <87k4vc2rds.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benny Halevy <bhalevy@panasas.com>, Andrew@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steve VanDeBogart <vandebo-lkml@nerdbox.net>, linux-fsdevel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Add the fincore() system call. fincore() is mincore() for file descriptors.

The functionality of fincore() can be emulated with an mmap(), mincore(),
and munmap(), but this emulation requires more system calls and requires
page table modifications. fincore() can provide a significant performance
improvement for non-sequential in-core queries.

CC: Andi Kleen <andi@firstfloor.org>
CC: Wu Fengguang <fengguang.wu@intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Chris Frost <frost@cs.ucla.edu>
Signed-off-by: Steve VanDeBogart <vandebo@cs.ucla.edu>
---

Andi, Wu, and Andrew,

Thanks for the feedback. I have incorporated most of your suggestions
into this patch. A man page for fincore(2) is attached.

A few questions about the suggestions:

* Early return when a signal is queued
Andi pointed out that it would be good to return early if a signal is
queued for the calling process. I see two options to do this:
1. Return -EINTR (the patch in this email takes this approach).
2. Return the results discovered so far.

And the tradeoffs:
1. Returning -EINTR abandons good work.
2. fincore needs to inform the caller of the number of valid vec entries.
   Three approaches:
   - Return the number of file bytes with valid page entries.
     Issue: The return type is a long. For a 32 bit process, sizeof(long)
     is significantly less than sizeof(loff_t).
   - Return the number of pages with valid page entries (use type ssize_t).
     Issue: I don't see any significant issues.
   - Add an 'loff_t *result' parameter to the system call (a la _llseek).
     Issue: does this push the number of arguments too high?

Given the above, I feel that returning the number of valid page entries is
the best approach. Feedback?

* Radix gang lookup
Andi and Andrew suggested using radix gang lookups for larger ranges.
My benchmarks show that my change to do this isn't a strict performance
win. Attached is my patch that changes the below code to do gang lookups.
Here are the microbenchmark results for querying a 1 GiB file (results
are times in seconds):
  density       | none in-core | many in-core |
  pages/syscall | 1    | 8192  | 1    | 8192  |
  --------------+------+-------+------+-------|
  fincore       | .055 | .0045 | .078 | .0250 |
  fincore-batch | .059 | .0010 | .123 | .0170 |
"none in-core" means none of the file pages were in ram and "many in-core"
that the majority were in ram. the next row indicates how many pages
are queried in each fincore(2) call by the process (1 or 8192 pages).
These results show that fincore-batch is ~2-5x faster for large count
calls, but that it is slower for small count calls. Both classes of calls
are made by our macrobenchmarks. The macrobenchmarks (a SQLite query and
a GIMP image blur) show the batch version slows performance by 2-12%.

Perhaps my gang patch can be further optimized, or is incorrect? (Of note,
I did not avoid the gets and puts.) If not, fincore_pages() could be
changed to decide choose which of a single vs. gang lookup to do based on
a heuristic tradeoff value. Or it could stay simple and only make single
lookups.

* Kernel output buffer size
Andi pointed out that the optimization to avoid allocating a buffer page
for small queries could be changed to claim more than 64 bytes of on-stack
buffer space. I haven't seen increasing this space to significantly affect
my particular macrobenchmarks. I'm ok with leaving it at 64 bytes or
changing it; this number was picked fairly arbitrarily.

* Upper query size limit
Andi suggested imposing a reasonable upper limit on the number of pages
that can be queried in a single fincore call, because the process would
not be debuggable while the system call is executing. Andi, could you
cite an example system call for me to look at that takes this approach?

* System call argument feasibility across architectures
The fincore(2) parameters are now reordered so that they should fit in six
registers on all platforms. I intend for the libc wrapper to expose the
call as shown in the man page, rather than the system call's ordering.
I think this issue is now resolved, but wanted to mention it just in case
I missed anything; does this look good for all architectures?

 include/linux/syscalls.h           |    2 
 fs/fincore.c                       |  126 +++++++++++++++++++++++++++++++++++++
 fs/Makefile                        |    2 
 include/asm-generic/unistd.h       |    5 +
 arch/x86/ia32/ia32entry.S          |    1 
 arch/x86/include/asm/unistd_32.h   |    3 
 arch/x86/include/asm/unistd_64.h   |    2 
 arch/x86/kernel/syscall_table_32.S |    1 
 8 files changed, 139 insertions(+), 3 deletions(-)

diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index a990ace..814e4f5 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -534,6 +534,8 @@ asmlinkage long sys_munlockall(void);
 asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
 asmlinkage long sys_mincore(unsigned long start, size_t len,
 				unsigned char __user * vec);
+asmlinkage long sys_fincore(unsigned int fd, unsigned char __user *vec,
+				loff_t start, loff_t len);
 
 asmlinkage long sys_pivot_root(const char __user *new_root,
 				const char __user *put_old);
diff --git a/fs/fincore.c b/fs/fincore.c
new file mode 100644
index 0000000..f329fe4
--- /dev/null
+++ b/fs/fincore.c
@@ -0,0 +1,126 @@
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
+ * Note that the parameter order for this system calls differ from the order
+ * for the libc wrapper. This syscall order allows the parameters to fit
+ * in six registers on all architectures.
+ *
+ * return values:
+ *  zero    - success
+ *  -EBADF  - fd is an illegal file descriptor
+ *  -EFAULT - vec points to an illegal address
+ *  -EINVAL - start is not a multiple of PAGE_CACHE_SIZE
+ *  -EAGAIN - A kernel resource was temporarily unavailable
+ *  -EINTR  - The call was interrupted by a signal
+ */
+SYSCALL_DEFINE4(fincore, unsigned int, fd, unsigned char __user *, vec,
+		loff_t, start, loff_t, len)
+{
+	long retval;
+	pgoff_t pgoff = start >> PAGE_SHIFT;
+	pgoff_t npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	pgoff_t pgend = pgoff + npages;
+	struct file *filp;
+	int fput_needed;
+	loff_t file_nbytes;
+	pgoff_t file_npages;
+	unsigned char *kernel_vec = NULL;
+	unsigned char kernel_vec_small[64];
+	unsigned kernel_vec_count;
+	int i;
+
+	/* Check the start address: needs to be page-aligned.. */
+	if (start & ~PAGE_CACHE_MASK)
+		return -EINVAL;
+
+	filp = fget_light(fd, &fput_needed);
+	if (!filp)
+		return -EBADF;
+
+	file_nbytes = i_size_read(filp->f_mapping->host);
+
+	file_npages = (file_nbytes + PAGE_SIZE - 1) >> PAGE_SHIFT;
+
+	/*
+	 * Allocate buffer vector page.
+	 * Optimize allocation for small values of npages because the
+	 * __get_free_page() call doubles fincore(2) runtime when npages == 1.
+	 */
+	if (npages <= sizeof(kernel_vec_small)) {
+		kernel_vec = kernel_vec_small;
+		kernel_vec_count = sizeof(kernel_vec_small);
+	} else {
+		kernel_vec = (void *) __get_free_page(GFP_USER);
+		if (!kernel_vec) {
+			retval = -EAGAIN;
+			goto done;
+		}
+		kernel_vec_count = PAGE_SIZE;
+	}
+
+	while (pgoff < pgend) {
+		/*
+		 * Do at most kernel_vec_count entries per iteration, due to
+		 * the limited buffer size.
+		 */
+		for (i = 0; pgoff < pgend && i < kernel_vec_count; pgoff++, i++)
+			kernel_vec[i] = fincore_page(filp->f_mapping, pgoff);
+
+		if (copy_to_user(vec, kernel_vec, i)) {
+			retval = -EFAULT;
+			break;
+		}
+		vec += i;
+
+		if (signal_pending(current)) {
+			retval = -EINTR;
+			break;
+		}
+		cond_resched();
+	}
+	retval = 0;
+done:
+	if (kernel_vec && kernel_vec != kernel_vec_small)
+		free_page((unsigned long) kernel_vec);
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
Chris Frost
http://www.frostnet.net/chris/

--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="fincore.2"

.\" Hey Emacs! This file is -*- nroff -*- source.
.\"
.\" Copyright (C) 2001 Bert Hubert <ahu@ds9a.nl>
.\" and Copyright (C) 2007 Michael Kerrisk <mtk.manpages@gmail.com>
.\" and Copyright (C) 2010 Chris Frost <frost@cs.ucla.edu>, UC Regents
.\"
.\" Permission is granted to make and distribute verbatim copies of this
.\" manual provided the copyright notice and this permission notice are
.\" preserved on all copies.
.\"
.\" Permission is granted to copy and distribute modified versions of this
.\" manual under the conditions for verbatim copying, provided that the
.\" entire resulting derived work is distributed under the terms of a
.\" permission notice identical to this one.
.\"
.\" Since the Linux kernel and libraries are constantly changing, this
.\" manual page may be incorrect or out-of-date.  The author(s) assume no
.\" responsibility for errors or omissions, or for damages resulting from
.\" the use of the information contained herein.  The author(s) may not
.\" have taken the same level of care in the production of this manual,
.\" which is licensed free of charge, as they might when working
.\" professionally.
.\"
.\" Formatted or processed versions of this manual, if unaccompanied by
.\" the source, must acknowledge the copyright and authors of this work.
.\"
.\" Created Sun Jun 3 17:23:32 2001 by bert hubert <ahu@ds9a.nl>
.\" Slightly adapted, following comments by Hugh Dickins, aeb, 2001-06-04.
.\" Modified, 20 May 2003, Michael Kerrisk <mtk.manpages@gmail.com>
.\" Modified, 30 Apr 2004, Michael Kerrisk <mtk.manpages@gmail.com>
.\" 2005-04-05 mtk, Fixed error descriptions
.\" 	after message from <gordon.jin@intel.com>
.\" 2007-01-08 mtk, rewrote various parts
.\" Adapted for fincore, 2010-02-13, Chris Frost <frost@cs.ucla.edu>
.\"
.TH FINCORE 2 2010-02-13 "Linux" "Linux Programmer's Manual"
.SH NAME
fincore \- determine whether buffer cache pages are resident in memory
.SH SYNOPSIS
.B #define _GNU_SOURCE
.br
.B #include <fnctl.h>
.sp
.BI "int fincore(int " fd ", loff_t " start ", loff_t " length ", unsigned char *" vec );
.SH DESCRIPTION
.BR fincore ()
returns a vector that indicates whether pages for a file descriptor
are resident in core (RAM),
and so will not cause a disk access if read.
The kernel returns residency information about the pages
starting at the offset
.IR start ,
and continuing for
.I length
bytes.

The
.I start
argument must be a multiple of the system page size.
The
.I length
argument need not be a multiple of the page size,
but since residency information is returned for whole pages,
.I length
is effectively rounded up to the next multiple of the page size.
One may obtain the page size
.RB ( PAGE_SIZE )
using
.IR sysconf(_SC_PAGESIZE) .

The
.I vec
argument must point to an array containing at least
.I "(length+PAGE_SIZE\-1) / PAGE_SIZE"
bytes.
On return,
the least significant bit of each byte will be set if
the corresponding page is currently resident in memory,
and be clear otherwise.
(The settings of the other bits in each byte are undefined;
these bits are reserved for possible later use.)
Of course the information returned in
.I vec
is only a snapshot: pages that are not
locked in memory can come and go at any moment, and the contents of
.I vec
may already be stale by the time this call returns.
.SH "RETURN VALUE"
On success,
.BR fincore ()
returns zero.
On error, \-1 is returned, and
.I errno
is set appropriately.
.SH ERRORS
.B EAGAIN
kernel is temporarily out of resources.
.TP
.B EBADF
.I fd
is an illegal file descriptor.
.TP
.B EFAULT
.I vec
points to an invalid address.
.TP
.B EINVAL
.I start
is not a multiple of the page size.
.TP
.B EINTR
The call was interrupted by a signal.
.SH VERSIONS
Available since Linux 2.6.? and glibc 2.?.
.SH "CONFORMING TO"
.BR fincore ()
is not specified in POSIX.1-2001,
and it is not available on all Unix implementations.
.\" Does it exist on other systems?
.SH "SEE ALSO"
.BR mincore (2)
.SH COLOPHON
This page is part of release 3.23 of the Linux
.I man-pages
project.
A description of the project,
and information about reporting bugs,
can be found at
http://www.kernel.org/doc/man-pages/.

--1yeeQ81UyVL57Vl7
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="batch.patch"

diff --git a/fs/fincore.c b/fs/fincore.c
index f329fe4..d1a5d65 100644
--- a/fs/fincore.c
+++ b/fs/fincore.c
@@ -11,19 +11,34 @@
 #include <linux/fs.h>
 #include <linux/file.h>
 #include <linux/pagemap.h>
+#include <linux/pagevec.h>
 #include <linux/syscalls.h>
 #include <linux/uaccess.h>
 
-static unsigned char fincore_page(struct address_space *mapping, pgoff_t pgoff)
+static void fincore_pages(struct address_space *mapping, pgoff_t pgoff,
+                          unsigned vec_count, unsigned char *vec)
 {
-	unsigned char present = 0;
-	struct page *page = find_get_page(mapping, pgoff);
-	if (page) {
-		present = PageUptodate(page);
-		page_cache_release(page);
-	}
+	struct pagevec pvec;
+	unsigned vec_i = 0;
+
+	pagevec_init(&pvec, 0);
+
+	while (vec_i < vec_count) {
+		unsigned pvec_max = min(vec_count - vec_i, (unsigned) PAGEVEC_SIZE);
+		unsigned pvec_i = 0;
+
+		pagevec_lookup(&pvec, mapping, pgoff, pvec_max);
 
-	return present;
+		for (; vec_i < vec_count && pvec_i < pvec_max; vec_i++, pgoff++) {
+			if (pvec_i >= pagevec_count(&pvec) ||
+				pvec.pages[pvec_i]->index != pgoff)
+				vec[vec_i] = 0;
+			else
+				vec[vec_i] = PageUptodate(pvec.pages[pvec_i++]);
+		}
+
+		pagevec_release(&pvec);
+	}
 }
 
 /*
@@ -64,9 +79,8 @@ SYSCALL_DEFINE4(fincore, unsigned int, fd, unsigned char __user *, vec,
 	loff_t file_nbytes;
 	pgoff_t file_npages;
 	unsigned char *kernel_vec = NULL;
-	unsigned char kernel_vec_small[64];
+	unsigned char kernel_vec_small[64]; /* 64 is fairly arbitrary */
 	unsigned kernel_vec_count;
-	int i;
 
 	/* Check the start address: needs to be page-aligned.. */
 	if (start & ~PAGE_CACHE_MASK)
@@ -100,16 +114,19 @@ SYSCALL_DEFINE4(fincore, unsigned int, fd, unsigned char __user *, vec,
 	while (pgoff < pgend) {
 		/*
 		 * Do at most kernel_vec_count entries per iteration, due to
-		 * the limited buffer size.
+		 * the limited buffer size and the possibility that an loff_t
+		 * can store a larger value than an unsigned.
 		 */
-		for (i = 0; pgoff < pgend && i < kernel_vec_count; pgoff++, i++)
-			kernel_vec[i] = fincore_page(filp->f_mapping, pgoff);
+		unsigned len = min((uint64_t) (pgend - pgoff),
+			(uint64_t) kernel_vec_count);
+		fincore_pages(filp->f_mapping, pgoff, len, kernel_vec);
 
-		if (copy_to_user(vec, kernel_vec, i)) {
+		if (copy_to_user(vec, kernel_vec, len)) {
 			retval = -EFAULT;
 			break;
 		}
-		vec += i;
+		pgoff += len;
+		vec += len;
 
 		if (signal_pending(current)) {
 			retval = -EINTR;

--1yeeQ81UyVL57Vl7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
