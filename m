Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AEC446B02F3
	for <linux-mm@kvack.org>; Wed, 17 May 2017 13:17:48 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id x25so14537639pgc.10
        for <linux-mm@kvack.org>; Wed, 17 May 2017 10:17:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id e8si2611993pgf.197.2017.05.17.10.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 10:17:47 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH] generic: add regression test for DAX PTE/PMD races
Date: Wed, 17 May 2017 11:17:42 -0600
Message-Id: <20170517171742.14848-1-ross.zwisler@linux.intel.com>
In-Reply-To: <20170517171639.14501-2-ross.zwisler@linux.intel.com>
References: <20170517171639.14501-2-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fstests@vger.kernel.org, Xiong Zhou <xzhou@redhat.com>, Eryu Guan <eguan@redhat.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pawel Lebioda <pawel.lebioda@intel.com>, Dave Jiang <dave.jiang@intel.com>

This adds a regression test for the following kernel patches:

  mm: avoid spurious 'bad pmd' warning messages
  dax: Fix race between colliding PMD & PTE entries

The above patches fix two related PMD vs PTE races in the DAX code.  These
can both be easily triggered by having two threads reading and writing
simultaneously to the same private mapping, with the key being that private
mapping reads can be handled with PMDs but private mapping writes are
always handled with PTEs so that we can COW.

Without this 2-patch kernel series, the newly added test will result in the
following errors:

  run fstests generic/435 at 2017-05-16 16:53:43
  mm/pgtable-generic.c:39: bad pmd ffff8808daa49b88(84000001006000a5)
  	... a bunch of the bad pmd messages ...
  BUG: Bad rss-counter state mm:ffff8800a8c1b700 idx:1 val:1
  BUG: non-zero nr_ptes on freeing mm: 38
  XFS (pmem0p1): Unmounting Filesystem

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 .gitignore            |   1 +
 src/Makefile          |   3 +-
 src/t_mmap_cow_race.c | 106 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/435     |  61 +++++++++++++++++++++++++++++
 tests/generic/435.out |   2 +
 tests/generic/group   |   1 +
 6 files changed, 173 insertions(+), 1 deletion(-)
 create mode 100644 src/t_mmap_cow_race.c
 create mode 100755 tests/generic/435
 create mode 100644 tests/generic/435.out

diff --git a/.gitignore b/.gitignore
index 38f3a00..a6ac25e 100644
--- a/.gitignore
+++ b/.gitignore
@@ -149,6 +149,7 @@
 /src/t_rename_overwrite
 /src/t_mmap_dio
 /src/t_mmap_stale_pmd
+/src/t_mmap_cow_race
 
 # dmapi/ binaries
 /dmapi/src/common/cmd/read_invis
diff --git a/src/Makefile b/src/Makefile
index e5042c9..b505b42 100644
--- a/src/Makefile
+++ b/src/Makefile
@@ -12,7 +12,8 @@ TARGETS = dirstress fill fill2 getpagesize holes lstat64 \
 	godown resvtest writemod makeextents itrash rename \
 	multi_open_unlink dmiperf unwritten_sync genhashnames t_holes \
 	t_mmap_writev t_truncate_cmtime dirhash_collide t_rename_overwrite \
-	holetest t_truncate_self t_mmap_dio af_unix t_mmap_stale_pmd
+	holetest t_truncate_self t_mmap_dio af_unix t_mmap_stale_pmd \
+	t_mmap_cow_race
 
 LINUX_TARGETS = xfsctl bstat t_mtab getdevicesize preallo_rw_pattern_reader \
 	preallo_rw_pattern_writer ftrunc trunc fs_perms testx looptest \
diff --git a/src/t_mmap_cow_race.c b/src/t_mmap_cow_race.c
new file mode 100644
index 0000000..207ba42
--- /dev/null
+++ b/src/t_mmap_cow_race.c
@@ -0,0 +1,106 @@
+#include <errno.h>
+#include <fcntl.h>
+#include <libgen.h>
+#include <pthread.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/mman.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <unistd.h>
+
+#define MiB(a) ((a)*1024*1024)
+#define NUM_THREADS 2
+
+void err_exit(char *op)
+{
+	fprintf(stderr, "%s: %s\n", op, strerror(errno));
+	exit(1);
+}
+
+void worker_fn(void *ptr)
+{
+	char *data = (char *)ptr;
+	volatile int a;
+	int i, err;
+
+	for (i = 0; i < 10; i++) {
+		a = data[0];
+		data[0] = a;
+
+		err = madvise(data, MiB(2), MADV_DONTNEED);
+		if (err < 0)
+			err_exit("madvise");
+
+		/* Mix up the thread timings to encourage the race. */
+		err = usleep(rand() % 100);
+		if (err < 0)
+			err_exit("usleep");
+	}
+}
+
+int main(int argc, char *argv[])
+{
+	pthread_t thread[NUM_THREADS];
+	int i, j, fd, err;
+	char *data;
+
+	if (argc < 2) {
+		printf("Usage: %s <file>\n", basename(argv[0]));
+		exit(0);
+	}
+
+	fd = open(argv[1], O_RDWR|O_CREAT, S_IRUSR|S_IWUSR);
+	if (fd < 0)
+		err_exit("fd");
+
+	/* This allows us to map a huge page. */
+	ftruncate(fd, 0);
+	ftruncate(fd, MiB(2));
+
+	/*
+	 * First we set up a shared mapping.  Our write will (hopefully) get
+	 * the filesystem to give us a 2MiB huge page DAX mapping.  We will
+	 * then use this 2MiB page for our private mapping race.
+	 */
+	data = mmap(NULL, MiB(2), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
+	if (data == MAP_FAILED)
+		err_exit("shared mmap");
+
+	data[0] = 1;
+
+	err = munmap(data, MiB(2));
+	if (err < 0)
+		err_exit("shared munmap");
+
+	for (i = 0; i < 500; i++) {
+		data = mmap(NULL, MiB(2), PROT_READ|PROT_WRITE, MAP_PRIVATE,
+				fd, 0);
+		if (data == MAP_FAILED)
+			err_exit("private mmap");
+
+		for (j = 0; j < NUM_THREADS; j++) {
+			err = pthread_create(&thread[j], NULL,
+					(void*)&worker_fn, data);
+			if (err)
+				err_exit("pthread_create");
+		}
+
+		for (j = 0; j < NUM_THREADS; j++) {
+			err = pthread_join(thread[j], NULL);
+			if (err)
+				err_exit("pthread_join");
+		}
+
+		err = munmap(data, MiB(2));
+		if (err < 0)
+			err_exit("private munmap");
+	}
+
+	err = close(fd);
+	if (err < 0)
+		err_exit("close");
+
+	return 0;
+}
diff --git a/tests/generic/435 b/tests/generic/435
new file mode 100755
index 0000000..f1413f1
--- /dev/null
+++ b/tests/generic/435
@@ -0,0 +1,61 @@
+#! /bin/bash
+# FS QA Test 435
+#
+# This is a regression test for kernel patches:
+#   mm: avoid spurious 'bad pmd' warning messages
+#   dax: Fix race between colliding PMD & PTE entries
+# created by Ross Zwisler <ross.zwisler@linux.intel.com>
+#
+#-----------------------------------------------------------------------
+# Copyright (c) 2017 Intel Corporation.  All Rights Reserved.
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
+	cd /
+	rm -f $tmp.*
+}
+
+# get standard environment, filters and checks
+. ./common/rc
+. ./common/filter
+
+# remove previous $seqres.full before test
+rm -f $seqres.full
+
+# Modify as appropriate.
+_supported_fs generic
+_supported_os Linux
+_require_test
+_require_test_program "t_mmap_cow_race"
+
+# real QA test starts here
+src/t_mmap_cow_race $TEST_DIR/testfile
+
+# success, all done
+echo "Silence is golden"
+status=0
+exit
diff --git a/tests/generic/435.out b/tests/generic/435.out
new file mode 100644
index 0000000..6a175d3
--- /dev/null
+++ b/tests/generic/435.out
@@ -0,0 +1,2 @@
+QA output created by 435
+Silence is golden
diff --git a/tests/generic/group b/tests/generic/group
index c4911b8..ac43f42 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -437,3 +437,4 @@
 432 auto quick copy
 433 auto quick copy
 434 auto quick copy
+435 auto quick
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
