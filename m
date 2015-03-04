Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id DCB206B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 11:37:29 -0500 (EST)
Received: by wevk48 with SMTP id k48so4065183wev.7
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 08:37:29 -0800 (PST)
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id li2si7853017wjc.116.2015.03.04.08.37.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 08:37:28 -0800 (PST)
Received: by wggx13 with SMTP id x13so583073wgg.12
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 08:37:27 -0800 (PST)
Message-ID: <54F734C4.7080409@plexistor.com>
Date: Wed, 04 Mar 2015 18:37:24 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] xfstests: generic/080 test that mmap-write updates c/mtime
References: <54F733BD.7060807@plexistor.com>
In-Reply-To: <54F733BD.7060807@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

From: Yigal Korman <yigal@plexistor.com>

when using mmap() for file i/o, writing to the file should update
it's c/mtime. Specifically if we first mmap-read from a page, then
memap-write to the same page.

This test was failing for the initial submission of DAX because
pfn based mapping do not have an page_mkwrite called for them.
The new Kernel patches that introduce pfn_mkwrite fixes this test.

Signed-off-by: Yigal Korman <yigal@plexistor.com>
Signed-off-by: Omer Zilberberg <omzg@plexistor.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 .gitignore            |   1 +
 src/Makefile          |   2 +-
 src/mmap_mtime.c      | 122 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/080     |  53 ++++++++++++++++++++++
 tests/generic/080.out |   4 ++
 tests/generic/group   |   1 +
 6 files changed, 182 insertions(+), 1 deletion(-)
 create mode 100644 src/mmap_mtime.c
 create mode 100644 tests/generic/080
 create mode 100644 tests/generic/080.out

diff --git a/.gitignore b/.gitignore
index 41e1dc4..fd71526 100644
--- a/.gitignore
+++ b/.gitignore
@@ -119,6 +119,7 @@
 /src/cloner
 /src/renameat2
 /src/t_rename_overwrite
+/src/mmap_mtime
 
 # dmapi/ binaries
 /dmapi/src/common/cmd/read_invis
diff --git a/src/Makefile b/src/Makefile
index fa5f0f4..0e48728 100644
--- a/src/Makefile
+++ b/src/Makefile
@@ -19,7 +19,7 @@ LINUX_TARGETS = xfsctl bstat t_mtab getdevicesize preallo_rw_pattern_reader \
 	bulkstat_unlink_test_modified t_dir_offset t_futimens t_immutable \
 	stale_handle pwrite_mmap_blocked t_dir_offset2 seek_sanity_test \
 	seek_copy_test t_readdir_1 t_readdir_2 fsync-tester nsexec cloner \
-	renameat2 t_getcwd e4compact
+	renameat2 t_getcwd e4compact mmap_mtime
 
 SUBDIRS =
 
diff --git a/src/mmap_mtime.c b/src/mmap_mtime.c
new file mode 100644
index 0000000..9a83227
--- /dev/null
+++ b/src/mmap_mtime.c
@@ -0,0 +1,122 @@
+/*
+ * test to check that mtime is updated when writing to mmap
+ *
+ * Copyright (c) 2014 Plexistor Ltd. All rights reserved.
+*/
+
+#include <stdio.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <time.h>
+#include <sys/mman.h>
+#include <sys/signal.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <stdint.h>
+
+#define EXIT_SUCCESS 0
+#define EXIT_ERROR 1
+#define EXIT_TEST_FAILED 2
+
+#define PAGE_SIZE (getpagesize())
+
+struct timespec get_mtime(int fd)
+{
+	struct stat st;
+	int ret;
+
+	ret = fstat(fd, &st);
+	if (ret) {
+		perror("fstat");
+		exit(EXIT_TEST_FAILED);
+	}
+
+	/*
+	printf("%d mtime: %lld.%.9ld\n", fd,
+		(long long)st.st_mtim.tv_sec, st.st_mtim.tv_nsec);
+	*/
+
+	return st.st_mtim;
+}
+
+void print_usage (const char* progname)
+{
+	fprintf (stderr, "%s <filename>\n", progname);
+	exit(EXIT_ERROR);
+}
+
+int main(int argc, char *argv[])
+{
+	int ret = EXIT_SUCCESS;
+	loff_t size;
+	const char* filename;
+	int fd;
+	void *mapped_mem;
+	int i;
+	struct timespec before, after;
+	long tempc = 0;
+	uint64_t tempbuf[PAGE_SIZE/sizeof(uint64_t)]; // 4K buf
+
+	if (argc < 2)
+		print_usage(argv[0]);
+
+	filename = argv[1];
+	size = PAGE_SIZE;
+
+	fd = open(filename, O_CREAT | O_EXCL | O_RDWR, 0666);
+	if (fd < 0) {
+		fprintf(stderr, "%s: Cannot open `%s': %s\n",
+			argv[0], filename, strerror(errno));
+		exit(EXIT_ERROR);
+	}
+
+	// fill the file with random data in order to make sure we
+	// won't get fake "zero" pages from FS
+	if (write(fd, tempbuf, size) < 0) {
+		perror("write");
+		close(fd);
+		exit(EXIT_ERROR);
+	}
+
+	mapped_mem = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
+	if (mapped_mem == MAP_FAILED) {
+		perror("mmap");
+		close(fd);
+		exit(EXIT_TEST_FAILED);
+	}
+
+	printf("reading page...");
+	for (i = 0; i < size/sizeof(char); i++) {
+		char *p = ((char*)mapped_mem) + i;
+		tempc += *p;
+	}
+	printf("done\n");
+
+	before = get_mtime(fd);
+	sleep(1);
+
+	printf("writing something...");
+	for (i = 0; i < size/sizeof(char); i++) {
+		char *p = ((char*)mapped_mem) + i;
+		*p = tempc + i;
+	}
+	printf("done\n");
+
+	after = get_mtime(fd);
+
+	if ((before.tv_sec == after.tv_sec) &&
+			(before.tv_nsec == after.tv_nsec)) {
+		printf("Failure. mtime was not updated.\n");
+		ret = EXIT_TEST_FAILED;
+	} else {
+		// assuming no time travel/warp
+		printf("Success. mtime was updated as expected\n");
+	}
+
+	munmap(mapped_mem,0);
+	close(fd);
+	exit(ret);
+}
diff --git a/tests/generic/080 b/tests/generic/080
new file mode 100644
index 0000000..42e2a49
--- /dev/null
+++ b/tests/generic/080
@@ -0,0 +1,53 @@
+#! /bin/bash
+# FS QA Test No. 080
+#
+# Verify that mtime is updated when writing to mmap-ed pages
+#
+#-----------------------------------------------------------------------
+# Copyright (c) 2015 Yigal Korman (yigal@plexistor.com).  All Rights Reserved.
+#
+# This program is free software; you can redistribute it and/or
+# modify it under the terms of the GNU General Public License as
+# published by the Free Software Foundation.
+#
+# This program is distributed in the hope that it would be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write the Free Software Foundation,
+# Inc.,  51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+#-----------------------------------------------------------------------
+#
+
+seq=`basename $0`
+seqres=$RESULT_DIR/$seq
+echo "QA output created by $seq"
+
+here=`pwd`
+tmp=/tmp/$$
+status=1	# failure is the default!
+trap "_cleanup; exit \$status" 0 1 2 3 15
+
+_cleanup()
+{
+    cd /
+    rm -f $tmp.*
+    rm -f $TEST_DIR/mmap_mtime_testfile
+}
+
+# get standard environment, filters and checks
+. ./common/rc
+. ./common/filter
+
+# real QA test starts here
+
+# Modify as appropriate.
+_supported_fs generic
+_supported_os IRIX Linux
+_require_test
+
+$here/src/mmap_mtime $TEST_DIR/mmap_mtime_testfile
+status=$?
+exit
diff --git a/tests/generic/080.out b/tests/generic/080.out
new file mode 100644
index 0000000..118fd24
--- /dev/null
+++ b/tests/generic/080.out
@@ -0,0 +1,4 @@
+QA output created by 080
+reading page...done
+writing something...done
+Success. mtime was updated as expected
diff --git a/tests/generic/group b/tests/generic/group
index 11ce3e4..7ee5cdc 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -77,6 +77,7 @@
 076 metadata rw udf auto quick stress
 077 acl attr auto enospc
 079 acl attr ioctl metadata auto quick
+080 auto quick
 083 rw auto enospc stress
 088 perms auto quick
 089 metadata auto
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
