Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id B76C96B0038
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 01:25:58 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id k48so4616762wev.17
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 22:25:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id fy1si23435038wjb.64.2014.06.01.22.25.56
        for <linux-mm@kvack.org>;
        Sun, 01 Jun 2014 22:25:57 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/3] selftest: add test code for fincore()
Date: Mon,  2 Jun 2014 01:24:59 -0400
Message-Id: <1401686699-9723-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20140521193336.5df90456.akpm@linux-foundation.org>
 <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch adds simple test programs for fincore(), which contains the
following testcase:
- test_unaligned_start_address
- test_unaligned_start_address_hugetlb
- test_invalid_mode
- test_smallfile_bytemap
- test_smallfile_pfn
- test_smallfile_multientry
- test_largefile_pfn
- test_largefile_pfn_offset
- test_largefile_pfn_overrun
- test_tmpfs_pfn
- test_hugetlb_pfn
- test_largefile_pfn_skiphole
- test_smallfile_pfn_skiphole
-
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/fincore/Makefile           |  31 ++
 .../selftests/fincore/create_hugetlbfs_file.c      |  49 +++
 tools/testing/selftests/fincore/fincore.c          | 153 +++++++++
 tools/testing/selftests/fincore/run_fincoretests   | 355 +++++++++++++++++++++
 5 files changed, 589 insertions(+)
 create mode 100644 tools/testing/selftests/fincore/Makefile
 create mode 100644 tools/testing/selftests/fincore/create_hugetlbfs_file.c
 create mode 100644 tools/testing/selftests/fincore/fincore.c
 create mode 100644 tools/testing/selftests/fincore/run_fincoretests

diff --git v3.15-rc7.orig/tools/testing/selftests/Makefile v3.15-rc7/tools/testing/selftests/Makefile
index 32487ed18354..820813f571fb 100644
--- v3.15-rc7.orig/tools/testing/selftests/Makefile
+++ v3.15-rc7/tools/testing/selftests/Makefile
@@ -10,6 +10,7 @@ TARGETS += timers
 TARGETS += vm
 TARGETS += powerpc
 TARGETS += user
+TARGETS += fincore
 
 all:
 	for TARGET in $(TARGETS); do \
diff --git v3.15-rc7.orig/tools/testing/selftests/fincore/Makefile v3.15-rc7/tools/testing/selftests/fincore/Makefile
new file mode 100644
index 000000000000..ab4361c70da5
--- /dev/null
+++ v3.15-rc7/tools/testing/selftests/fincore/Makefile
@@ -0,0 +1,31 @@
+# Makefile for vm selftests
+
+uname_M := $(shell uname -m 2>/dev/null || echo not)
+ARCH ?= $(shell echo $(uname_M) | sed -e s/i.86/i386/)
+ifeq ($(ARCH),i386)
+        ARCH := X86
+        CFLAGS := -DCONFIG_X86_32 -D__i386__
+endif
+ifeq ($(ARCH),x86_64)
+        ARCH := X86
+        CFLAGS := -DCONFIG_X86_64 -D__x86_64__
+endif
+
+CC = $(CROSS_COMPILE)gcc
+CFLAGS = -Wall
+CFLAGS += -I../../../../arch/x86/include/generated/
+CFLAGS += -I../../../../include/
+CFLAGS += -I../../../../usr/include/
+CFLAGS += -I../../../../arch/x86/include/
+
+BINARIES = fincore create_hugetlbfs_file
+
+all: $(BINARIES)
+%: %.c
+	$(CC) $(CFLAGS) -o $@ $^
+
+run_tests: all
+	@/bin/sh ./run_fincoretests || (echo "fincoretests: [FAIL]"; exit 1)
+
+clean:
+	$(RM) $(BINARIES)
diff --git v3.15-rc7.orig/tools/testing/selftests/fincore/create_hugetlbfs_file.c v3.15-rc7/tools/testing/selftests/fincore/create_hugetlbfs_file.c
new file mode 100644
index 000000000000..a46ccf0af5f2
--- /dev/null
+++ v3.15-rc7/tools/testing/selftests/fincore/create_hugetlbfs_file.c
@@ -0,0 +1,49 @@
+#define _GNU_SOURCE 1
+#include <stdio.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <sys/mman.h>
+#include <string.h>
+#include <unistd.h>
+#include <stdlib.h>
+
+#define err(x) (perror(x), exit(1))
+
+unsigned long default_hugepage_size(void)
+{
+	unsigned long hps = 0;
+	char *line = NULL;
+	size_t linelen = 0;
+	FILE *f = fopen("/proc/meminfo", "r");
+	if (!f)
+		err("open /proc/meminfo");
+	while (getline(&line, &linelen, f) > 0) {
+		if (sscanf(line, "Hugepagesize:	%lu kB", &hps) == 1) {
+			hps <<= 10;
+			break;
+		}
+	}
+	free(line);
+	return hps;
+}
+
+int main(int argc, char **argv)
+{
+	int ret;
+	int fd;
+	char *p;
+	unsigned long hpsize = default_hugepage_size();
+	fd = open(argv[1], O_RDWR|O_CREAT);
+	if (fd == -1)
+		err("open");
+	p = mmap(NULL, 10 * hpsize, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
+	if (p == (void *)-1)
+		err("mmap");
+	memset(p, 'a', 3 * hpsize);
+	memset(p + 7 * hpsize, 'a', 3 * hpsize - 1);
+	ret = close(fd);
+	if (ret == -1)
+		err("close");
+	return 0;
+}
diff --git v3.15-rc7.orig/tools/testing/selftests/fincore/fincore.c v3.15-rc7/tools/testing/selftests/fincore/fincore.c
new file mode 100644
index 000000000000..b089fe5f6bdf
--- /dev/null
+++ v3.15-rc7/tools/testing/selftests/fincore/fincore.c
@@ -0,0 +1,153 @@
+/*
+ * fincore(2) test program
+ */
+
+#define _GNU_SOURCE 1
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <getopt.h>
+#include <assert.h>
+#include <fcntl.h>
+#include <sys/mman.h>
+#include <sys/stat.h>
+#include <sys/syscall.h>
+
+#define err(x) (perror(x), exit(1))
+
+#define FINCORE_BMAP		0x01
+#define FINCORE_PFN		0x02
+#define FINCORE_PAGE_FLAGS	0x04
+#define FINCORE_PAGECACHE_TAGS	0x08
+#define FINCORE_SKIP_HOLE	0x10
+
+#define FINCORE_MODE_MASK	0x1f
+#define FINCORE_LONGENTRY_MASK	(FINCORE_PFN | FINCORE_PAGE_FLAGS | \
+				 FINCORE_PAGECACHE_TAGS | FINCORE_SKIP_HOLE)
+
+static int sys_fincore(int fd, loff_t start, size_t len, int mode,
+		       unsigned char *vec)
+{
+	return syscall(__NR_fincore, fd, start, len, mode, vec);
+}
+
+static int call_fincore(int fd, loff_t start, size_t len, int mode,
+			unsigned char *vec)
+{
+	return sys_fincore(fd, start, len, mode, vec);
+}
+
+void usage(char *str)
+{
+	printf(
+		"Usage: %s [-s start] [-l len] [-m mode] [-p pagesize] file\n"
+		"  -s: start offset (in bytes)\n"
+		"  -l: length to scan (in bytes)\n"
+		"  -m: fincore mode\n"
+		"  -p: set page size (for hugepage)\n"
+		"  -h: show this message\n"
+		, str);
+	exit(EXIT_SUCCESS);
+}
+
+static void show_fincore_buffer(long start, long nr_pages, int records_per_page,
+				int mode, unsigned char *buf)
+{
+	int i, j;
+	unsigned char *curuc = (unsigned char *)buf;
+	unsigned long *curul = (unsigned long *)buf;
+
+	for (i = 0; i < nr_pages; i++) {
+		j = 0;
+		if (mode & FINCORE_BMAP)
+			printf("0x%lx\t%d", start + i, curuc[i + j]);
+		else if (mode & (FINCORE_LONGENTRY_MASK)) {
+			if (mode & FINCORE_SKIP_HOLE)
+				printf("0x%lx", curul[i * records_per_page + (j++)]);
+			else
+				printf("0x%lx", start + i);
+			if (mode & FINCORE_PFN)
+				printf("\t0x%lx", curul[i * records_per_page + (j++)]);
+			if (mode & FINCORE_PAGE_FLAGS)
+				printf("\t0x%lx", curul[i * records_per_page + (j++)]);
+			if (mode & FINCORE_PAGECACHE_TAGS)
+				printf("\t0x%lx", curul[i * records_per_page + (j++)]);
+		}
+		printf("\n");
+	}
+}
+
+int main(int argc, char *argv[])
+{
+	char c;
+	int fd;
+	int ret;
+	int mode = FINCORE_PFN;
+	int width = sizeof(unsigned char);
+	int records_per_page = 1;
+	long pagesize = sysconf(_SC_PAGESIZE);
+	long nr_pages;
+	unsigned long start = 0;
+	unsigned long len = 0;
+	unsigned char *buf;
+	struct stat stat;
+
+	while ((c = getopt(argc, argv, "s:l:m:p:h")) != -1) {
+		switch (c) {
+		case 's':
+			start = strtoul(optarg, NULL, 0);
+			break;
+		case 'l':
+			len = strtoul(optarg, NULL, 0);
+			break;
+		case 'm':
+			mode = strtoul(optarg, NULL, 0);
+			break;
+		case 'p':
+			pagesize = strtoul(optarg, NULL, 0);
+			break;
+		case 'h':
+		default:
+			usage(argv[0]);
+		}
+	}
+
+	fd = open(argv[optind], O_RDWR);
+	if (fd == -1)
+		err("open failed.");
+
+	/* scan to the end of file by default */
+	if (!len) {
+		ret = fstat(fd, &stat);
+		if (ret == -1)
+			err("fstat failed.");
+		len = stat.st_size - start;
+	}
+
+	if (mode & FINCORE_LONGENTRY_MASK) {
+		records_per_page = ((mode & FINCORE_PFN ? 1 : 0) +
+				    (mode & FINCORE_PAGE_FLAGS ? 1 : 0) +
+				    (mode & FINCORE_PAGECACHE_TAGS ? 1 : 0) +
+				    (mode & FINCORE_SKIP_HOLE ? 1 : 0)
+			);
+		width = records_per_page * sizeof(unsigned long);
+	}
+
+	nr_pages = ((len + pagesize - 1) & (~(pagesize - 1))) / pagesize;
+	buf = malloc(nr_pages * width);
+	if (!buf)
+		err("malloc");
+	ret = call_fincore(fd, start, nr_pages, mode, buf);
+	if (ret < 0)
+		err("fincore");
+	/*
+	 * print buffer to stdout, and parse it later for validation check.
+	 * fincore() returns the number of entries written to the buffer.
+	 */
+	show_fincore_buffer(start / pagesize, ret, records_per_page, mode, buf);
+	ret = close(fd);
+	if (ret < 0)
+		err("close");
+	return 0;
+}
diff --git v3.15-rc7.orig/tools/testing/selftests/fincore/run_fincoretests v3.15-rc7/tools/testing/selftests/fincore/run_fincoretests
new file mode 100644
index 000000000000..3775ac339860
--- /dev/null
+++ v3.15-rc7/tools/testing/selftests/fincore/run_fincoretests
@@ -0,0 +1,355 @@
+#!/bin/bash
+
+WDIR=./fincore_work
+mkdir $WDIR 2> /dev/null
+TMPF=`mktemp --tmpdir=$WDIR -d`
+
+#
+# common routines
+#
+abort() {
+    echo "Test abort"
+    exit 1
+}
+
+create_small_file() {
+    dd if=/dev/urandom of=$WDIR/smallfile bs=4096 count=4 > /dev/null 2>&1
+    dd if=/dev/urandom of=$WDIR/smallfile bs=4096 count=4 seek=8> /dev/null 2>&1
+    date >> $WDIR/smallfile
+    sync
+}
+
+create_large_file() {
+    dd if=/dev/urandom of=$WDIR/largefile bs=4096 count=384 > /dev/null 2>&1
+    dd if=/dev/urandom of=$WDIR/largefile bs=4096 count=384 seek=640> /dev/null 2>&1
+    sync
+}
+
+create_tmpfs_file() {
+    dd if=/dev/urandom of=/tmp/tmpfile bs=4096 count=4 > /dev/null 2>&1
+    dd if=/dev/urandom of=/tmp/tmpfile bs=4096 count=4 seek=8> /dev/null 2>&1
+    date >> /tmp/tmpfile
+    sync
+}
+
+create_hugetlb_file() {
+    if mount | grep $WDIR/hugepages > /dev/null ; then
+        echo "$WDIR/hugepages already mounted"
+    else
+        mkdir -p $WDIR/hugepages 2> /dev/null
+        mount -t hugetlbfs none $WDIR/hugepages
+        if [ $? -ne 0 ] ; then
+            echo "Failed to mount hugetlbfs" >&2
+            return 1
+        fi
+    fi
+    local hptotal=$(grep HugePages_Total: /proc/meminfo | tr -s ' ' | cut -f2 -d' ')
+    if [ "$hptotal" -lt 10 ] ; then
+        echo "Hugepage pool size need to be >= 10" >&2
+        return 1
+    fi
+    ./create_hugetlbfs_file $WDIR/hugepages/file
+    if [ $? -ne 0 ] ; then
+        echo "Failed to create hugetlb file" >&2
+        return 1
+    fi
+    return 0;
+}
+
+#
+# Testcases
+#
+test_smallfile_bytemap() {
+    local exist
+    local nonexist
+    create_small_file
+
+    ./fincore -m 0x1 $WDIR/smallfile > $TMPF/$FUNCNAME
+    exist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep 1 | wc -l)
+    nonexist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep 0 | wc -l)
+    if [ "$exist" -ne 9 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of on-memory pages should be 9, but got $exist"
+        return 1
+    fi
+    if [ "$nonexist" -ne 4 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of hole pages should be 4, but got $nonexist"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+    return 0
+}
+
+test_smallfile_pfn() {
+    local exist
+    local nonexist
+    create_small_file
+
+    ./fincore -m 0x2 $WDIR/smallfile > $TMPF/$FUNCNAME
+    exist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    if [ "$exist" -ne 9 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of on-memory pages should be 9, but got $exist"
+        return 1
+    fi
+    if [ "$nonexist" -ne 4 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of hole pages should be 4, but got $nonexist"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+    return 0
+}
+
+test_smallfile_multientry() {
+    local exist
+    local nonexist
+    create_small_file
+
+    ./fincore -m 0xe $WDIR/smallfile > $TMPF/$FUNCNAME
+    exist=$(cat $TMPF/$FUNCNAME | cut -f 2,3,4 | grep -vP "0x0\t0x0\t0x0" | wc -l)
+    nonexist=$(cat $TMPF/$FUNCNAME | cut -f 2,3,4 | grep -P "0x0\t0x0\t0x0" | wc -l)
+    if [ "$exist" -ne 9 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of on-memory pages should be 9, but got $exist"
+        return 1
+    fi
+    if [ "$nonexist" -ne 4 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of hole pages should be 4, but got $nonexist"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+    return 0
+}
+
+test_smallfile_pfn_skiphole() {
+    local exist
+    local nonexist
+    create_small_file
+
+    ./fincore -m 0x12 $WDIR/smallfile > $TMPF/$FUNCNAME
+    exist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    if [ "$exist" -ne 9 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of on-memory pages should be 9, but got $exist"
+        return 1
+    fi
+    if [ "$nonexist" -ne 0 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of hole pages should be 0, but got $nonexist"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+    return 0
+}
+
+# in-kernel function sys_fincore() repeat copy_to_user() per 256 entries,
+# so testing for large file is meaningful testcase.
+test_largefile_pfn() {
+    local exist
+    local nonexist
+    create_large_file
+
+    ./fincore -m 0x2 $WDIR/largefile > $TMPF/$FUNCNAME
+    exist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    if [ "$exist" -ne 768 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of on-memory pages should be 768, but got $exist"
+        return 1
+    fi
+    if [ "$nonexist" -ne 256 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of hole pages should be 256, but got $nonexist"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+    return 0
+}
+
+test_largefile_pfn_offset() {
+    local exist
+    local nonexist
+    create_large_file
+
+    ./fincore -m 0x2 -s 0x80000 $WDIR/largefile > $TMPF/$FUNCNAME
+    exist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    if [ "$exist" -ne 640 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of on-memory pages should be 640, but got $exist"
+        return 1
+    fi
+    if [ "$nonexist" -ne 256 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of hole pages should be 256, but got $nonexist"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+    return 0
+}
+
+test_largefile_pfn_overrun() {
+    local exist
+    local nonexist
+    create_large_file
+
+    ./fincore -m 0x2 -s 0x80000 -l 0x400000 $WDIR/largefile > $TMPF/$FUNCNAME
+    exist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    if [ "$exist" -ne 640 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of on-memory pages should be 640, but got $exist"
+        return 1
+    fi
+    if [ "$nonexist" -ne 256 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of hole pages should be 256, but got $nonexist"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+    return 0
+}
+
+test_largefile_pfn_skiphole() {
+    local exist
+    local nonexist
+    create_large_file
+
+    ./fincore -m 0x12 -s 0x100000 -l 0x102000 $WDIR/largefile > $TMPF/$FUNCNAME
+    exist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    if [ "$exist" -ne 258 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of on-memory pages should be 258, but got $exist"
+        return 1
+    fi
+    if [ "$nonexist" -ne 0 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of hole pages should be 0, but got $nonexist"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+    return 0
+}
+
+test_tmpfs_pfn() {
+    local exist
+    local nonexist
+    create_tmpfs_file
+
+    ./fincore -m 0x2 /tmp/tmpfile > $TMPF/$FUNCNAME
+    exist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    if [ "$exist" -ne 9 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of on-memory pages should be 9, but got $exist"
+        return 1
+    fi
+    if [ "$nonexist" -ne 4 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of hole pages should be 4, but got $nonexist"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+    return 0
+}
+
+test_hugetlb_pfn() {
+    local exist
+    local nonexist
+    local exitcode=0
+    create_hugetlb_file
+    if [ $? -ne 0 ] ; then
+        echo "[FAIL] $FUNCNAME: fail to create a file on hugetlbfs"
+        return 1
+    fi
+    local hugepagesize=$[$(cat /proc/meminfo  | grep Hugepagesize: | tr -s ' ' | cut -f2 -d' ') * 1024]
+    ./fincore -p $hugepagesize -m 0x2 $WDIR/hugepages/file > $TMPF/$FUNCNAME
+    exist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(cat $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    rm -rf $WDIR/hugepages/file
+    umount $WDIR/hugepages
+    if [ "$exist" -ne 6 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of on-memory pages should be 6, but got $exist"
+        return 1
+     fi
+    if [ "$nonexist" -ne 4 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of hole pages should be 4, but got $nonexist"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+}
+
+test_unaligned_start_address() {
+    create_small_file
+    ./fincore -m 0x2 -s 0x30 $WDIR/smallfile > $TMPF/$FUNCNAME
+    if [ $? -eq 0 ] ; then
+        echo "[FAIL] $FUNCNAME: fincore should fail for unaligned start address"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+}
+
+test_unaligned_start_address_hugetlb() {
+    local exist
+    local nonexist
+    local exitcode=0
+    create_hugetlb_file
+    if [ $? -ne 0 ] ; then
+        echo "[FAIL] $FUNCNAME: fail to create a file on hugetlbfs"
+        return 1
+    fi
+    local hugepagesize=$[$(cat /proc/meminfo  | grep Hugepagesize: | tr -s ' ' | cut -f2 -d' ') * 1024]
+    ./fincore -p $hugepagesize -m 0x2 -s 0x1000 $WDIR/hugepages/file > $TMPF/$FUNCNAME
+    if [ $? -eq 0 ] ; then
+        echo "[FAIL] $FUNCNAME: fincore should fail for page-unaligned start address"
+        return 1
+    fi
+    ./fincore -p $hugepagesize -m 0x2 -s $hugepagesize $WDIR/hugepages/file > $TMPF/$FUNCNAME
+    if [ $? -ne 0 ] ; then
+        echo "[FAIL] $FUNCNAME: fincore should pass for hugepage-aligned start address"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+}
+
+test_invalid_mode() {
+    create_small_file
+    ./fincore -m 0x0 $WDIR/smallfile > $TMPF/$FUNCNAME
+    if [ $? -eq 0 ] ; then
+        echo "[FAIL] $FUNCNAME: mode == NULL is invalid mode"
+        return 1
+    fi
+    ./fincore -m 0x3 $WDIR/smallfile > $TMPF/$FUNCNAME
+    if [ $? -eq 0 ] ; then
+        echo "[FAIL] $FUNCNAME: mode == (FINCORE_BMAP|FINCORE_PFN) is invalid mode"
+        return 1
+    fi
+    ./fincore -m 0x11 $WDIR/smallfile > $TMPF/$FUNCNAME
+    if [ $? -eq 0 ] ; then
+        echo "[FAIL] $FUNCNAME: mode == (FINCORE_BMAP|FINCORE_SKIP_HOLE) is invalid mode"
+        return 1
+    fi
+    ./fincore -m 0x12 $WDIR/smallfile > $TMPF/$FUNCNAME
+    if [ $? -ne 0 ] ; then
+        echo "[FAIL] $FUNCNAME: mode == (FINCORE_PFN|FINCORE_SKIP_HOLE) is valid mode"
+        return 1
+    fi
+    ./fincore -m 0x10 $WDIR/smallfile > $TMPF/$FUNCNAME
+    if [ $? -eq 0 ] ; then
+        echo "[FAIL] $FUNCNAME: mode == (FINCORE_SKIP_HOLE) is invalid mode"
+        return 1
+    fi
+    ./fincore -m 0x1002 $WDIR/smallfile > $TMPF/$FUNCNAME
+    if [ $? -eq 0 ] ; then
+        echo "[FAIL] $FUNCNAME: mode == (Unknown|FINCORE_PFN) is invalid mode"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+}
+
+test_unaligned_start_address           || abort
+test_unaligned_start_address_hugetlb   || abort
+test_invalid_mode                      || abort
+test_smallfile_bytemap                 || abort
+test_smallfile_pfn                     || abort
+test_smallfile_multientry              || abort
+test_largefile_pfn                     || abort
+test_largefile_pfn_offset              || abort
+test_largefile_pfn_overrun             || abort
+test_tmpfs_pfn                         || abort
+test_hugetlb_pfn                       || abort
+test_largefile_pfn_skiphole            || abort
+test_smallfile_pfn_skiphole            || abort
+
+# cleanup
+rm -rf $WDIR
+
+exit 0
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
