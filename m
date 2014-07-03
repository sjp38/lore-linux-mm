Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id DD45D6B0038
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 17:53:38 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u56so851919wes.22
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 14:53:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l8si25615735wik.89.2014.07.03.14.53.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 14:53:37 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 3/4] selftests/fincore: add test code for fincore()
Date: Thu,  3 Jul 2014 17:52:14 -0400
Message-Id: <1404424335-30128-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1404424335-30128-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1404424335-30128-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch adds simple test programs for fincore(), which contains the
following testcase:
  - test_smallfile_bytemap
  - test_smallfile_pfn
  - test_smallfile_multientry
  - test_smallfile_pfn_skiphole
  - test_smallfile_pagecache_tag
  - test_largefile_pfn
  - test_largefile_pfn_offset
  - test_largefile_pfn_overrun
  - test_largefile_pfn_skiphole
  - test_tmpfs_pfn
  - test_hugetlb_pfn
  - test_invalid_start_address
  - test_invalid_len
  - test_invalid_mode
  - test_unaligned_start_address_hugetlb

ChangeLog v2:
- include uapi/linux/pagecache.h
- add testcase test_invalid_start_address and test_invalid_len
- other small changes to adjust for the kernel's changes

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/fincore/Makefile           |  31 ++
 .../selftests/fincore/create_hugetlbfs_file.c      |  49 +++
 tools/testing/selftests/fincore/fincore.c          | 166 +++++++++
 tools/testing/selftests/fincore/run_fincoretests   | 401 +++++++++++++++++++++
 5 files changed, 648 insertions(+)
 create mode 100644 tools/testing/selftests/fincore/Makefile
 create mode 100644 tools/testing/selftests/fincore/create_hugetlbfs_file.c
 create mode 100644 tools/testing/selftests/fincore/fincore.c
 create mode 100644 tools/testing/selftests/fincore/run_fincoretests

diff --git v3.16-rc3.orig/tools/testing/selftests/Makefile v3.16-rc3/tools/testing/selftests/Makefile
index e66e710cc595..91e817b87a9e 100644
--- v3.16-rc3.orig/tools/testing/selftests/Makefile
+++ v3.16-rc3/tools/testing/selftests/Makefile
@@ -11,6 +11,7 @@ TARGETS += vm
 TARGETS += powerpc
 TARGETS += user
 TARGETS += sysctl
+TARGETS += fincore
 
 all:
 	for TARGET in $(TARGETS); do \
diff --git v3.16-rc3.orig/tools/testing/selftests/fincore/Makefile v3.16-rc3/tools/testing/selftests/fincore/Makefile
new file mode 100644
index 000000000000..ab4361c70da5
--- /dev/null
+++ v3.16-rc3/tools/testing/selftests/fincore/Makefile
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
diff --git v3.16-rc3.orig/tools/testing/selftests/fincore/create_hugetlbfs_file.c v3.16-rc3/tools/testing/selftests/fincore/create_hugetlbfs_file.c
new file mode 100644
index 000000000000..a46ccf0af5f2
--- /dev/null
+++ v3.16-rc3/tools/testing/selftests/fincore/create_hugetlbfs_file.c
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
diff --git v3.16-rc3.orig/tools/testing/selftests/fincore/fincore.c v3.16-rc3/tools/testing/selftests/fincore/fincore.c
new file mode 100644
index 000000000000..5722622a3b75
--- /dev/null
+++ v3.16-rc3/tools/testing/selftests/fincore/fincore.c
@@ -0,0 +1,166 @@
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
+#include <uapi/linux/pagecache.h>
+
+#define err(x) (perror(x), exit(1))
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
+			printf("buffer: 0x%lx\t%d", start + i, curuc[i + j]);
+		else if (mode & (FINCORE_LONGENTRY_MASK)) {
+			if (mode & FINCORE_PGOFF)
+				printf("buffer: 0x%lx",
+				       curul[i * records_per_page + (j++)]);
+			else
+				printf("buffer: 0x%lx", start + i);
+			if (mode & FINCORE_PFN)
+				printf("\t0x%lx",
+				       curul[i * records_per_page + (j++)]);
+			if (mode & FINCORE_PAGE_FLAGS)
+				printf("\t0x%lx",
+				       curul[i * records_per_page + (j++)]);
+			if (mode & FINCORE_PAGECACHE_TAGS)
+				printf("\t0x%lx",
+				       curul[i * records_per_page + (j++)]);
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
+	int len_not_given = 1;
+	long len = 0;
+	long buffer_size = 0;
+	unsigned char *buf;
+	struct stat stat;
+	int extra = 0;
+	struct fincore_extra fe = {
+		.tags = PAGECACHE_TAG_DIRTY|PAGECACHE_TAG_WRITEBACK|
+			PAGECACHE_TAG_TOWRITE,
+	};
+
+	while ((c = getopt(argc, argv, "s:l:m:p:et:b:h")) != -1) {
+		switch (c) {
+		case 's':
+			start = strtoul(optarg, NULL, 0);
+			break;
+		case 'l':
+			len_not_given = 0;
+			len = strtol(optarg, NULL, 0);
+			break;
+		case 'm':
+			mode = strtoul(optarg, NULL, 0);
+			break;
+		case 'p':
+			pagesize = strtoul(optarg, NULL, 0);
+			break;
+		case 'e':
+			extra = 1;
+			break;
+		case 't':
+			fe.tags = strtoul(optarg, NULL, 0);
+			break;
+		case 'b':
+			buffer_size = strtoul(optarg, NULL, 0);
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
+	if (len_not_given) {
+		ret = fstat(fd, &stat);
+		if (ret == -1)
+			err("fstat failed.");
+		len = stat.st_size - start;
+	}
+
+	if (mode & FINCORE_LONGENTRY_MASK) {
+		records_per_page = ((mode & FINCORE_PGOFF ? 1 : 0) +
+				    (mode & FINCORE_PFN ? 1 : 0) +
+				    (mode & FINCORE_PAGE_FLAGS ? 1 : 0) +
+				    (mode & FINCORE_PAGECACHE_TAGS ? 1 : 0)
+			);
+		width = records_per_page * sizeof(unsigned long);
+	}
+
+	nr_pages = ((len + pagesize - 1) & (~(pagesize - 1))) / pagesize;
+	printf("start:0x%lx, len:%ld, mode:%d, pagesize:0x%lx, "
+	       "tags:0x%lx,\n buffer_size:0x%lx, nr_pages:0x%lx, width:%d\n",
+	       start, len, mode, pagesize, fe.tags,
+	       buffer_size, nr_pages, width);
+	buf = malloc(buffer_size > 0 ? buffer_size : nr_pages * width);
+	if (!buf)
+		err("malloc");
+
+	ret = syscall(__NR_fincore, fd, start, nr_pages, mode, buf,
+		      extra ? &fe : NULL);
+	if (ret < 0)
+		err("fincore");
+	/*
+	 * print buffer to stdout, and parse it later for validation check.
+	 * fincore() returns the number of entries written to the buffer.
+	 */
+	show_fincore_buffer(start / pagesize, nr_pages, records_per_page,
+			    mode, buf);
+
+	if (extra) {
+		printf("fincore_extra->nr_entries: %ld\n", fe.nr_entries);
+		printf("fincore_extra->tags: 0x%lx\n", fe.tags);
+	}
+
+	ret = close(fd);
+	if (ret < 0)
+		err("close");
+	return 0;
+}
diff --git v3.16-rc3.orig/tools/testing/selftests/fincore/run_fincoretests v3.16-rc3/tools/testing/selftests/fincore/run_fincoretests
new file mode 100644
index 000000000000..99c89f915b30
--- /dev/null
+++ v3.16-rc3/tools/testing/selftests/fincore/run_fincoretests
@@ -0,0 +1,401 @@
+#!/bin/bash
+
+WDIR=./fincore_work
+mkdir $WDIR 2> /dev/null
+TMPF=`mktemp --tmpdir=$WDIR -d`
+export LANG=C
+
+sysctl -q vm.nr_hugepages=50
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
+        mount -t hugetlbfs none $WDIR/hugepages 2> /dev/null
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
+get_buffer() {
+    cat "$1" | grep '^buffer:' | cut -f 2- -d ' '
+}
+
+get_fincore_extra_nr_entries() {
+    cat "$1" | grep '^fincore_extra->nr_entries' | cut -f 2 -d ' '
+}
+
+get_fincore_extra_tags() {
+    cat "$1" | grep '^fincore_extra->tags' | cut -f 2 -d ' '
+}
+
+nr_of_exist_should_be() {
+    if [ "$1" -ne "$2" ] ; then
+        echo "[FAIL] $3: Number of on-memory pages should be $1, but got $2"
+        return 1
+    fi
+    return 0
+}
+
+nr_of_nonexist_should_be() {
+    if [ "$1" -ne "$2" ] ; then
+        echo "[FAIL] $3: Number of hole entries should be $1, but got $2"
+        return 1
+    fi
+    return 0
+}
+
+nr_of_valid_entries_should_be() {
+    if [ "$1" -ne "$2" ] ; then
+        echo "[FAIL] $3: Number of valid entries should be $1, but got $2"
+        return 1
+    fi
+    return 0
+}
+
+check_einval() {
+    grep "fincore: Invalid argument" "$1" > /dev/null
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
+    ./fincore -m 0x1 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    exist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 1 | wc -l)
+    nonexist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 0 | wc -l)
+    nr_of_exist_should_be 9 "$exist" "$FUNCNAME" || return 1
+    nr_of_nonexist_should_be 4 "$nonexist" "$FUNCNAME" || return 1
+    echo "[PASS] $FUNCNAME"
+}
+
+test_smallfile_pfn() {
+    local exist
+    local nonexist
+    create_small_file
+
+    ./fincore -m 0x4 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    exist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    nr_of_exist_should_be 9 "$exist" "$FUNCNAME" || return 1
+    nr_of_nonexist_should_be 4 "$nonexist" "$FUNCNAME" || return 1
+    echo "[PASS] $FUNCNAME"
+}
+
+test_smallfile_multientry() {
+    local exist
+    local nonexist
+    create_small_file
+
+    ./fincore -m 0x1c -e $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    exist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2,3,4 | grep -vP "0x0\t0x0\t0x0" | wc -l)
+    nonexist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2,3,4 | grep -P "0x0\t0x0\t0x0" | wc -l)
+    nr_of_exist_should_be 9 "$exist" "$FUNCNAME" || return 1
+    nr_of_nonexist_should_be 4 "$nonexist" "$FUNCNAME" || return 1
+    echo "[PASS] $FUNCNAME"
+}
+
+test_smallfile_pfn_skiphole() {
+    local exist
+    local nonexist
+    local nr_entries
+    create_small_file
+
+    ./fincore -m 0x6 -e $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    exist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    nr_entries=$(get_fincore_extra_nr_entries $TMPF/$FUNCNAME)
+    nr_of_exist_should_be 9 "$exist" "$FUNCNAME" || return 1
+    nr_of_nonexist_should_be 4 "$nonexist" "$FUNCNAME" || return 1
+    nr_of_valid_entries_should_be 9 "$nr_entries" "$FUNCNAME" || return 1
+    echo "[PASS] $FUNCNAME"
+}
+
+test_smallfile_pagecache_tag() {
+    local nr_dirty
+    local fincore_extra_tags
+    create_small_file
+
+    # dirty one page
+    date >> $WDIR/smallfile
+
+    ./fincore -m 0x10 -e -t 0xff $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    nr_dirty=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 0x1 | wc -l)
+    fincore_extra_tags=$(get_fincore_extra_tags $TMPF/$FUNCNAME)
+    if [ "$nr_dirty" -ne 1 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of dirty bit should be 1, but got $nr_dirty"
+        return 1
+    fi
+    if [ "$fincore_extra_tags" != 0x7 ] ; then
+        echo "[FAIL] $FUNCNAME: unsupported PAGECACHE_TAG_* should be ignored."
+        return 1
+    fi
+
+    # ignore only PAGECACHE_TAG_DIRTY
+    ./fincore -m 0x10 -e -t 0x6 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    nr_dirty=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 0x1 | wc -l)
+    fincore_extra_tags=$(get_fincore_extra_tags $TMPF/$FUNCNAME)
+    if [ "$nr_dirty" -ne 0 ] ; then
+        echo "[FAIL] $FUNCNAME: Number of dirty bit should be 0, but got $nr_dirty"
+        return 1
+    fi
+    if [ "$fincore_extra_tags" != 0x6 ] ; then
+        echo "[FAIL] $FUNCNAME: unsupported PAGECACHE_TAG_* should be ignored."
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+}
+
+# in-kernel function sys_fincore() repeat copy_to_user() per 256 entries,
+# so testing for large file is meaningful testcase.
+test_largefile_pfn() {
+    local exist
+    local nonexist
+    create_large_file
+
+    ./fincore -m 0x4 -e $WDIR/largefile > $TMPF/$FUNCNAME 2>&1
+    exist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    nr_of_exist_should_be 768 "$exist" "$FUNCNAME" || return 1
+    nr_of_nonexist_should_be 256 "$nonexist" "$FUNCNAME" || return 1
+    echo "[PASS] $FUNCNAME"
+}
+
+test_largefile_pfn_offset() {
+    local exist
+    local nonexist
+    create_large_file
+
+    ./fincore -m 0x4 -s 0x80000 $WDIR/largefile > $TMPF/$FUNCNAME 2>&1
+    exist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    nr_of_exist_should_be 640 "$exist" "$FUNCNAME" || return 1
+    nr_of_nonexist_should_be 256 "$nonexist" "$FUNCNAME" || return 1
+    echo "[PASS] $FUNCNAME"
+}
+
+test_largefile_pfn_overrun() {
+    local exist
+    local nonexist
+    local nr_entries
+    create_large_file
+
+    ./fincore -m 0x4 -s 0x80000 -l 0x400000 -e $WDIR/largefile > $TMPF/$FUNCNAME 2>&1
+    exist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    nr_entries=$(get_fincore_extra_nr_entries $TMPF/$FUNCNAME)
+    nr_of_exist_should_be 640 "$exist" "$FUNCNAME" || return 1
+    nr_of_nonexist_should_be 384 "$nonexist" "$FUNCNAME" || return 1
+    nr_of_valid_entries_should_be 896 "$nr_entries" "$FUNCNAME" || return 1
+    echo "[PASS] $FUNCNAME"
+}
+
+test_largefile_pfn_skiphole() {
+    local exist
+    local nonexist
+    create_large_file
+
+    ./fincore -m 0x6 -s 0x100000 -l 0x102000 -e $WDIR/largefile > $TMPF/$FUNCNAME 2>&1
+    exist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    nr_entries=$(get_fincore_extra_nr_entries $TMPF/$FUNCNAME)
+    nr_of_exist_should_be 258 "$exist" "$FUNCNAME" || return 1
+    nr_of_nonexist_should_be 0 "$nonexist" "$FUNCNAME" || return 1
+    nr_of_valid_entries_should_be 258 "$nr_entries" "$FUNCNAME" || return 1
+    echo "[PASS] $FUNCNAME"
+}
+
+test_tmpfs_pfn() {
+    local exist
+    local nonexist
+    create_tmpfs_file
+
+    ./fincore -m 0x4 /tmp/tmpfile > $TMPF/$FUNCNAME 2>&1
+    exist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    nr_of_exist_should_be 9 "$exist" "$FUNCNAME" || return 1
+    nr_of_nonexist_should_be 4 "$nonexist" "$FUNCNAME" || return 1
+    echo "[PASS] $FUNCNAME"
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
+    ./fincore -p $hugepagesize -m 0x4 -e $WDIR/hugepages/file > $TMPF/$FUNCNAME 2>&1
+    exist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep -v 0x0 | wc -l)
+    nonexist=$(get_buffer $TMPF/$FUNCNAME | cut -f 2 | grep 0x0 | wc -l)
+    nr_entries=$(get_fincore_extra_nr_entries $TMPF/$FUNCNAME)
+    nr_of_exist_should_be 6 "$exist" "$FUNCNAME" || return 1
+    nr_of_nonexist_should_be 4 "$nonexist" "$FUNCNAME" || return 1
+    nr_of_valid_entries_should_be 10 "$nr_entries" "$FUNCNAME" || return 1
+    rm -rf $WDIR/hugepages/file
+    echo "[PASS] $FUNCNAME"
+}
+
+test_invalid_start_address() {
+    create_small_file
+    ./fincore -m 0x4 -s -0x4000 -l 1 -e $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    if [ $? -eq 0 ] || ! check_einval $TMPF/$FUNCNAME ; then
+        echo "[FAIL] $FUNCNAME: negative start is invalid"
+        return 1
+    fi
+    ./fincore -m 0x4 -s 0x100000 -l 1 -e $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    if [ $? -eq 0 ] || ! check_einval $TMPF/$FUNCNAME ; then
+        echo "[FAIL] $FUNCNAME: too large start is invalid"
+        return 1
+    fi
+    ./fincore -m 0x4 -s 0x30 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    if [ $? -eq 0 ] || ! check_einval $TMPF/$FUNCNAME ; then
+        echo "[FAIL] $FUNCNAME: fincore should fail for unaligned start address"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+}
+
+test_invalid_len() {
+    create_small_file
+    ./fincore -m 0x4 -l 0 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    if [ $? -eq 0 ] || ! check_einval $TMPF/$FUNCNAME ; then
+        echo "[FAIL] $FUNCNAME: zero len is invalid"
+        return 1
+    fi
+    ./fincore -m 0x4 -l -10 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    if [ $? -eq 0 ] || ! check_einval $TMPF/$FUNCNAME ; then
+        echo "[FAIL] $FUNCNAME: negative len is invalid"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+}
+
+test_invalid_mode() {
+    create_small_file
+    ./fincore -m 0x0 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    if [ $? -eq 0 ] || ! check_einval $TMPF/$FUNCNAME ; then
+        echo "[FAIL] $FUNCNAME: mode == NULL is invalid mode"
+        return 1
+    fi
+    ./fincore -m 0x5 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    if [ $? -eq 0 ] || ! check_einval $TMPF/$FUNCNAME ; then
+        echo "[FAIL] $FUNCNAME: mode == (FINCORE_BMAP|FINCORE_PFN) is invalid mode"
+        return 1
+    fi
+    ./fincore -m 0x3 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    if [ $? -eq 0 ] || ! check_einval $TMPF/$FUNCNAME ; then
+        echo "[FAIL] $FUNCNAME: mode == (FINCORE_BMAP|FINCORE_PGOFF) is invalid mode"
+        return 1
+    fi
+    ./fincore -m 0x6 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    if [ $? -ne 0 ] ; then
+        echo "[FAIL] $FUNCNAME: mode == (FINCORE_PGOFF|FINCORE_PFN) is valid mode"
+        return 1
+    fi
+    ./fincore -m 0x2 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    if [ $? -ne 0 ] ; then
+        echo "[FAIL] $FUNCNAME: mode == (FINCORE_PGOFF) is valid mode"
+        return 1
+    fi
+    ./fincore -m 0x1004 $WDIR/smallfile > $TMPF/$FUNCNAME 2>&1
+    if [ $? -eq 0 ] || ! check_einval $TMPF/$FUNCNAME ; then
+        echo "[FAIL] $FUNCNAME: mode == (Unknown|FINCORE_PFN) is invalid mode"
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
+    ./fincore -p $hugepagesize -m 0x4 -s 0x1000 $WDIR/hugepages/file > $TMPF/$FUNCNAME 2>&1
+    if [ $? -eq 0 ] || ! check_einval $TMPF/$FUNCNAME ; then
+        echo "[FAIL] $FUNCNAME: fincore should fail for page-unaligned start address"
+        return 1
+    fi
+    ./fincore -p $hugepagesize -m 0x4 -s $hugepagesize $WDIR/hugepages/file > $TMPF/$FUNCNAME 2>&1
+    if [ $? -ne 0 ] ; then
+        echo "[FAIL] $FUNCNAME: fincore should pass for hugepage-aligned start address"
+        return 1
+    fi
+    echo "[PASS] $FUNCNAME"
+}
+
+test_smallfile_bytemap                 || abort
+test_smallfile_pfn                     || abort
+test_smallfile_multientry              || abort
+test_smallfile_pfn_skiphole            || abort
+test_smallfile_pagecache_tag           || abort
+test_largefile_pfn                     || abort
+test_largefile_pfn_offset              || abort
+test_largefile_pfn_overrun             || abort
+test_largefile_pfn_skiphole            || abort
+test_tmpfs_pfn                         || abort
+test_hugetlb_pfn                       || abort
+test_invalid_start_address             || abort
+test_invalid_len                       || abort
+test_invalid_mode                      || abort
+test_unaligned_start_address_hugetlb   || abort
+
+# cleanup
+rm -rf $WDIR/hugepages/file
+umount $WDIR/hugepages > /dev/null 2>&1
+
+exit 0
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
