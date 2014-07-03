Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id E4EB86B003B
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 17:53:47 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id x48so850954wes.23
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 14:53:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bv5si6049120wib.12.2014.07.03.14.53.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 14:53:46 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 4/4] man2/fincore.2: document general description about fincore(2)
Date: Thu,  3 Jul 2014 17:52:15 -0400
Message-Id: <1404424335-30128-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1404424335-30128-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1404424335-30128-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch adds the man page for the new system call fincore(2).

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 man2/fincore.2 | 383 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 383 insertions(+)
 create mode 100644 man2/fincore.2

diff --git v3.16-rc3.orig/man2/fincore.2 v3.16-rc3/man2/fincore.2
new file mode 100644
index 000000000000..dcc596db4fa0
--- /dev/null
+++ v3.16-rc3/man2/fincore.2
@@ -0,0 +1,383 @@
+.\" Copyright (C) 2014 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
+.\"
+.\" %%%LICENSE_START(VERBATIM)
+.\" Permission is granted to make and distribute verbatim copies of this
+.\" manual provided the copyright notice and this permission notice are
+.\" preserved on all copies.
+.\"
+.\" Permission is granted to copy and distribute modified versions of this
+.\" manual under the conditions for verbatim copying, provided that the
+.\" entire resulting derived work is distributed under the terms of a
+.\" permission notice identical to this one.
+.\"
+.\" Since the Linux kernel and libraries are constantly changing, this
+.\" manual page may be incorrect or out-of-date.  The author(s) assume no
+.\" responsibility for errors or omissions, or for damages resulting from
+.\" the use of the information contained herein.  The author(s) may not
+.\" have taken the same level of care in the production of this manual,
+.\" which is licensed free of charge, as they might when working
+.\" professionally.
+.\"
+.\" Formatted or processed versions of this manual, if unaccompanied by
+.\" the source, must acknowledge the copyright and authors of this work.
+.\" %%%LICENSE_END
+.\"
+.TH FINCORE 2 2014-07-03 "Linux" "Linux Programmer's Manual"
+.SH NAME
+fincore \- get page cache information
+.SH SYNOPSIS
+.nf
+.B #include <linux/pagecache.h>
+.B #include <linux/kernel-page-flags.h>
+.sp
+.BI "int fincore(int " fd ", loff_t " start ", long " nr_pages ", int " mode ,
+.BI "            unsigned char *" vec ", struct fincore_extra *" extra );
+.fi
+.SH DESCRIPTION
+.BR fincore ()
+extracts information of in-core data of (i.e., page caches for)
+the file referred to by the file descriptor
+.IR fd .
+The kernel scans over the page cache tree,
+starting at the in-file offset
+.I start
+(in bytes) until
+.I nr_pages
+entries in the userspace buffer pointed to by
+.IR vec
+are filled with the page cache's data,
+or until the scan reached the end of the file.
+The format of each entry stored in
+.I vec
+depends on the
+.IR mode .
+The extra argument
+.I extra
+is used to pass the additional data between the kernel and the userspace.
+This is optional, so you may set
+.I extra
+to NULL if unnecessary.
+The structure
+.I fincore_extra
+is defined like:
+.in +4n
+.nf
+
+struct fincore_extra {
+        unsigned long nr_entries;
+        unsigned long tags;
+};
+
+.fi
+.in
+The field
+.I nr_entries
+is an output parameter, set to the number of valid entries stored in
+.IR vec
+by the kernel on return.
+The field
+.I tags
+is used as an input and output parameter, indicating the set of
+page cache tags of the caller's interest.
+For more detail,
+see the description about the FINCORE_PAGECACHE_TAG mode below.
+
+The
+.I start
+argument must be aligned to the page cache size boundary.
+In most cases, it's the page size boundary,
+but if called for a hugetlbfs file,
+the page cache size is the size of the hugepage associated with the file,
+so
+.I start
+must be aligned to the hugepage size boundary.
+
+The
+.I mode
+argument determines the data format of each entry in the user buffer
+.IR vec :
+.TP
+.B FINCORE_BMAP (0)
+In this mode,
+1 byte vector is stored in
+.I vec
+on return.
+The least significant bit of each byte is set if the corresponding page
+is currently resident in memory, and is cleared otherwise.
+(The other bits in each byte are undefined and reserved for future use.)
+.LP
+Any of the following flags are to be set to add an 8 byte field in each entry.
+You can set any of these flags at the same time, although you can't set
+FINCORE_BMAP combined with these 8 byte field flags.
+.TP
+.B FINCORE_PGOFF (1)
+This flag indicates that each entry contains a page offset field.
+With this information, you don't have to get data for hole range,
+so they are not stored in
+.I vec
+any longer.
+Note that if you call with this flag, you can't predict how many valid
+entries are stored in the buffer on return. So the
+.I nr_entries
+field in
+.I struct fincore_extra
+is useful if you want it.
+.TP
+.B FINCORE_PFN (2)
+This flag indicates that each entry contains a page frame number
+(i.e., physical address in page size unit) field.
+.TP
+.B FINCORE_PAGE_FLAGS (3)
+This flag indicates that each entry contains a page flags field.
+See KERNEL PAGE FLAGS section for more detail about each bit.
+.TP
+.B FINCORE_PAGECACHE_TAGS (4)
+This flag indicates that each entry contains a page cache tag field.
+See PAGE CACHE TAGS section for more detail about each bit.
+Note that if you set this flag, you must set the argument
+.I extra
+and set
+.I tags
+to the set of page cache tags you are interested in.
+And on return,
+.I tags
+are set by the kernel to the set of tags which is actually scanned.
+.LP
+The size of the buffer
+.I vec
+must be at least
+.I nr_pages
+bytes if FINCORE_BMAP is set,
+and
+.I (8*n*nr_pages)
+bytes if some of the 8 byte field flags are set,
+where
+.I n
+means the number of 8 byte field flags being set.
+When multiple 8 byte field flags are set, the order of data in each
+entry is the same as one in the bit definition order (shown above
+as the numbers in parentheses.)
+For example, when you set FINCORE_PGOFF (bit 1) and FINCORE_PAGE_FLAGS (bit 3,)
+the first 8 bytes in an entry is the page offset,
+and the second 8 bytes is the page flags.
+
+Note that the information returned by the kernel is just a snapshot:
+pages which are not locked in memory can be freed at any moment, and
+the contents of
+.I vec
+may already be stale by the time the caller refers to the data.
+.SH KERNEL PAGE FLAGS
+.TP
+.B KPF_LOCKED (0)
+The lock on the page is held, suggesting that the kernel may be
+doing some page-related sensitive operation.
+.TP
+.B KPF_ERROR (1)
+The page was affected by IO error or memory error, so the data on the page
+might be lost.
+.TP
+.B KPF_REFERENCED (2)
+This page flag is used to control the page reclaim, combined with KPF_ACTIVE.
+.TP
+.B KPF_UPTODATE (3)
+The page has valid contents.
+.TP
+.B KPF_DIRTY (4)
+The data of the page is not synchronized with one on the backing storage.
+.TP
+.B KPF_LRU (5)
+The page is linked to one of the LRU (Least Recently Update) lists.
+.TP
+.B KPF_ACTIVE (6)
+The page is linked to one of the active LRU lists.
+.TP
+.B KPF_SLAB (7)
+The page is used to construct slabs, which is managed by the kernel
+to allocate various types of kernel objects.
+.TP
+.B KPF_WRITEBACK (8)
+The page is under the writeback operation.
+.TP
+.B KPF_RECLAIM (9)
+The page is under the page reclaim operation.
+.TP
+.B KPF_BUDDY (10)
+The page is under the buddy allocator as a free page. Note that this flag
+is only set to the first page of the "buddy" (i.e., the chunk of free pages.)
+.TP
+.B KPF_MMAP (11)
+The page is mapped to the virtual address space of some processes.
+.TP
+.B KPF_ANON (12)
+The page is anonymous page.
+.TP
+.B KPF_SWAPCACHE (13)
+The page has its own copy of the data on the swap device.
+.TP
+.B KPF_SWAPBACKED (14)
+The page can be swapped out. This flag is set on anonymous pages,
+tmpfs pages, or shmem page.
+.TP
+.B KPF_COMPOUND_HEAD (15)
+The page belongs to a high-order page, and is its first page.
+.TP
+.B KPF_COMPOUND_TAIL (16)
+The page belongs to a high-order page, and is not its first page.
+.TP
+.B KPF_HUGE (17)
+The page is used to construct a hugepage.
+.TP
+.B KPF_UNEVICTABLE (18)
+The page is prevented from being freed.
+This is caused by
+.BR mlock (2)
+or shared memory with
+.BR SHM_LOCK .
+.TP
+.B KPF_HWPOISON (19)
+The page is affected by a hardware error on the memory.
+.TP
+.B KPF_NOPAGE (20)
+This is a pseudo page flag which indicates that the given address
+has no struct page backed.
+.TP
+.B KPF_KSM (21)
+The page is a shared page governed by KSM (Kernel Shared Merging.)
+.TP
+.B KPF_THP (22)
+The page is used to construct a transparent hugepage.
+.LP
+.SH PAGE CACHE TAGS
+.TP
+.B PAGECACHE_TAG_DIRTY
+The page is dirty.
+.TP
+.B PAGECACHE_TAG_WRITEBACK
+The page is under the writeback operation.
+.TP
+.B PAGECACHE_TAG_TOWRITE
+The writeback operation on the page will start soon.
+.LP
+.SH RETURN VALUE
+On success,
+.BR fincore ()
+returns 0.
+On error, \-1 is returned, and
+.I errno
+is set appropriately.
+.SH ERRORS
+.TP
+.B EBADF
+.I fd
+is not a valid file descriptor.
+.TP
+.B EFAULT
+.I vec
+points to an invalid address.
+.TP
+.B EINVAL
+.I start
+is unaligned to page cache size or is out-of-range
+(negative or larger than the file size.)
+Or
+.I nr_pages
+is not a positive value.
+Or
+.I mode
+contained a undefined flag, or contained no flag,
+or contained both of FINCORE_BMAP and one of the "8 byte field" flags.
+Or
+.I fincore_extra
+is not given if
+.I FINCORE_PAGECACHE_TAG
+flag is set.
+.SH VERSIONS
+TBD
+.SH CONFORMING TO
+TBD
+
+.SH EXAMPLE
+.PP
+The following program is an example that shows the page cache information
+of the file specified in its first command-line argument to the standard
+output.
+
+.nf
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <sys/stat.h>
+#include <uapi/linux/pagecache.h>
+
+#define err(msg) do { perror(msg); exit(1); } while (0)
+
+int main(int argc, char *argv[])
+{
+    int i, j;
+    int fd;
+    int ret;
+    long ps = sysconf(_SC_PAGESIZE);
+    long nr_pages;
+    unsigned char *buf;
+    struct stat stat;
+    struct fincore_extra fe = {};
+
+    fd = open(argv[1], O_RDWR);
+    if (fd == \-1)
+        err("open");
+
+    ret = fstat(fd, &stat);
+    if (ret == \-1)
+        err("fstat");
+    nr_pages = ((stat.st_size + ps \- 1) & (~(ps \- 1))) / ps;
+
+    buf = malloc(nr_pages * 24);
+    if (!buf)
+        err("malloc");
+
+    /* byte map */
+    ret = fincore(fd, 0, nr_pages, FINCORE_BMAP, buf, NULL);
+    if (ret < 0)
+        err("fincore");
+    printf("Page residency:");
+    for (i = 0; i < nr_pages; i++)
+        printf("%d", buf[i]);
+    printf("\\n\\n");
+
+    /* 8 byte entry */
+    ret = fincore(fd, 0, nr_pages,
+                  FINCORE_PFN|FINCORE_PAGE_FLAGS, buf, &fe);
+    if (ret < 0)
+        err("fincore");
+    printf("pfn\\tflags %lx\\n", fe.nr_entries);
+    for (i = 0; i < fe.nr_entries; i++) {
+        for (j = 0; j < 2; j++)
+            printf("0x%lx\\t", *(unsigned long *)(buf + (i*2+j)*8));
+        printf("\\n");
+    }
+    printf("\\n");
+
+    /* 8 byte entry with page offset (no hole scanned) */
+    ret = fincore(fd, 0, nr_pages,
+              FINCORE_PGOFF|FINCORE_PFN|FINCORE_PAGE_FLAGS, buf, &fe);
+    if (ret < 0)
+        err("fincore");
+    printf("pgoff\\tpfn\\tflags %lx\\n", fe.nr_entries);
+    for (i = 0; i < fe.nr_entries; i++) {
+        for (j = 0; j < 3; j++)
+            printf("0x%lx\\t", *(unsigned long *)(buf + (i*3+j)*8));
+        printf("\\n");
+    }
+
+    free(buf);
+
+    ret = close(fd);
+    if (ret < 0)
+        err("close");
+    return 0;
+}
+.fi
+.SH SEE ALSO
+.BR mincore (2),
+.BR fsync (2)
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
