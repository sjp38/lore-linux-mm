Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58DFD280730
	for <linux-mm@kvack.org>; Tue,  9 May 2017 12:12:57 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id s58so1775248qtb.1
        for <linux-mm@kvack.org>; Tue, 09 May 2017 09:12:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d56si367406qta.117.2017.05.09.09.12.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 09:12:56 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [xfstests PATCH v2 1/3] generic: add a writeback error handling test
Date: Tue,  9 May 2017 12:12:43 -0400
Message-Id: <20170509161245.29908-2-jlayton@redhat.com>
In-Reply-To: <20170509161245.29908-1-jlayton@redhat.com>
References: <20170509161245.29908-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, fstests@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

I'm working on a set of kernel patches to change how writeback errors
are handled and reported in the kernel. Instead of reporting a
writeback error to only the first fsync caller on the file, I aim
to make the kernel report them once on every file description.

This patch adds a test for the new behavior. Basically, open many fds
to the same file, turn on dm_error, write to each of the fds, and then
fsync them all to ensure that they all get an error back.

To do that, I'm adding a new tools/dmerror script that the C program
can use to load the error table. For now, that's all it can do, but
we can fill it out with other commands as necessary.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 common/dmerror        |  13 +++--
 src/Makefile          |   2 +-
 src/fsync-err.c       | 138 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/999     |  75 +++++++++++++++++++++++++++
 tests/generic/999.out |   3 ++
 tests/generic/group   |   1 +
 tools/dmerror         |  47 +++++++++++++++++
 7 files changed, 273 insertions(+), 6 deletions(-)
 create mode 100644 src/fsync-err.c
 create mode 100755 tests/generic/999
 create mode 100644 tests/generic/999.out
 create mode 100755 tools/dmerror

diff --git a/common/dmerror b/common/dmerror
index d46c5d0b7266..238baa213b1f 100644
--- a/common/dmerror
+++ b/common/dmerror
@@ -23,22 +23,25 @@ if [ $? -eq 0 ]; then
 	_notrun "Cannot run tests with DAX on dmerror devices"
 fi
 
-_dmerror_init()
+_dmerror_setup()
 {
 	local dm_backing_dev=$SCRATCH_DEV
 
-	$DMSETUP_PROG remove error-test > /dev/null 2>&1
-
 	local blk_dev_size=`blockdev --getsz $dm_backing_dev`
 
 	DMERROR_DEV='/dev/mapper/error-test'
 
 	DMLINEAR_TABLE="0 $blk_dev_size linear $dm_backing_dev 0"
 
+	DMERROR_TABLE="0 $blk_dev_size error $dm_backing_dev 0"
+}
+
+_dmerror_init()
+{
+	_dmerror_setup
+	$DMSETUP_PROG remove error-test > /dev/null 2>&1
 	$DMSETUP_PROG create error-test --table "$DMLINEAR_TABLE" || \
 		_fatal "failed to create dm linear device"
-
-	DMERROR_TABLE="0 $blk_dev_size error $dm_backing_dev 0"
 }
 
 _dmerror_mount()
diff --git a/src/Makefile b/src/Makefile
index e5042c9b7d8e..eb8ff6c4a344 100644
--- a/src/Makefile
+++ b/src/Makefile
@@ -12,7 +12,7 @@ TARGETS = dirstress fill fill2 getpagesize holes lstat64 \
 	godown resvtest writemod makeextents itrash rename \
 	multi_open_unlink dmiperf unwritten_sync genhashnames t_holes \
 	t_mmap_writev t_truncate_cmtime dirhash_collide t_rename_overwrite \
-	holetest t_truncate_self t_mmap_dio af_unix t_mmap_stale_pmd
+	holetest t_truncate_self t_mmap_dio af_unix t_mmap_stale_pmd fsync-err
 
 LINUX_TARGETS = xfsctl bstat t_mtab getdevicesize preallo_rw_pattern_reader \
 	preallo_rw_pattern_writer ftrunc trunc fs_perms testx looptest \
diff --git a/src/fsync-err.c b/src/fsync-err.c
new file mode 100644
index 000000000000..8ad27b3da3e7
--- /dev/null
+++ b/src/fsync-err.c
@@ -0,0 +1,138 @@
+/*
+ * fsync-err.c: test whether writeback errors are reported to all open fds
+ * Copyright (c) 2017: Jeff Layton <jlayton@redhat.com>
+ *
+ * Open a file several times, write to it and then fsync. Flip dm_error over
+ * to make the backing device stop working. Overwrite the same section and
+ * call fsync on all fds and verify that we get errors on all of them. Then,
+ * fsync one more time on all of them and verify that they return 0.
+ */
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+
+#define NUM_FDS	10
+
+static void usage() {
+	fprintf(stderr, "Usage: fsync-err <filename>\n");
+}
+
+int main(int argc, char **argv)
+{
+	int fd[NUM_FDS], ret, i;
+	char *fname, *buf;
+
+	if (argc < 1) {
+		usage();
+		return 1;
+	}
+
+	/* First argument is filename */
+	fname = argv[1];
+
+	for (i = 0; i < NUM_FDS; ++i) {
+		fd[i] = open(fname, O_WRONLY | O_CREAT | O_TRUNC, 0644);
+		if (fd[i] < 0) {
+			printf("open of fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	buf = "foobar";
+	for (i = 0; i < NUM_FDS; ++i) {
+		ret = write(fd[i], buf, strlen(buf) + 1);
+		if (ret < 0) {
+			printf("First write on fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	for (i = 0; i < NUM_FDS; ++i) {
+		ret = fsync(fd[i]);
+		if (ret < 0) {
+			printf("First fsync on fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	/* flip the device to non-working mode */
+	ret = system("./tools/dmerror load_error_table");
+	if (ret) {
+		if (WIFEXITED(ret))
+			printf("system: program exited: %d\n",
+					WEXITSTATUS(ret));
+		else
+			printf("system: 0x%x\n", (int)ret);
+
+		return 1;
+	}
+
+	for (i = 0; i < NUM_FDS; ++i) {
+		ret = write(fd[i], buf, strlen(buf) + 1);
+		if (ret < 0) {
+			printf("Second write on fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	for (i = 0; i < NUM_FDS; ++i) {
+		ret = fsync(fd[i]);
+		/* Now, we EXPECT the error! */
+		if (ret >= 0) {
+			printf("Success on second fsync on fd[%d]!\n", i);
+			return 1;
+		}
+	}
+
+	/* flip the device to working mode */
+	ret = system("./tools/dmerror load_working_table");
+	if (ret) {
+		if (WIFEXITED(ret))
+			printf("system: program exited: %d\n",
+					WEXITSTATUS(ret));
+		else
+			printf("system: 0x%x\n", (int)ret);
+
+		return 1;
+	}
+
+	for (i = 0; i < NUM_FDS; ++i) {
+		ret = fsync(fd[i]);
+		if (ret < 0) {
+			/* Now the error should be clear */
+			printf("Third fsync on fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	/*
+	 * reopen each file to guarantee the same one stays in core. fsync
+	 * each one to make sure we see no errors.
+	 */
+	for (i = 0; i < NUM_FDS; ++i) {
+		ret = close(fd[i]);
+		if (ret < 0) {
+			printf("Close of fd[%d] returned unexpected error: %m\n", i);
+			return 1;
+		}
+		fd[i] = open(fname, O_WRONLY | O_CREAT | O_TRUNC, 0644);
+		if (fd[i] < 0) {
+			printf("Second open of fd[%d] failed: %m\n", i);
+			return 1;
+		}
+		ret = fsync(fd[i]);
+		if (ret < 0) {
+			/* New opens should not return an error */
+			printf("First fsync after reopen of fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	printf("Test passed!\n");
+	return 0;
+}
diff --git a/tests/generic/999 b/tests/generic/999
new file mode 100755
index 000000000000..57e093b43416
--- /dev/null
+++ b/tests/generic/999
@@ -0,0 +1,75 @@
+#! /bin/bash
+# FS QA Test No. 999
+#
+# Open a file several times, write to it, fsync on all fds and make sure that
+# they all return 0. Change the device to start throwing errors. Write again
+# on all fds and fsync on all fds. Ensure that we get errors on all of them.
+# Then fsync on all one last time and verify that all return 0.
+#
+#-----------------------------------------------------------------------
+# Copyright (c) 2017, Jeff Layton <jlayton@redhat.com>
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
+
+seq=`basename $0`
+seqres=$RESULT_DIR/$seq
+echo "QA output created by $seq"
+
+here=`pwd`
+tmp=/tmp/$$
+status=1    # failure is the default!
+trap "_cleanup; exit \$status" 0 1 2 3 15
+
+_cleanup()
+{
+    cd /
+    rm -rf $tmp.* $testdir
+    _dmerror_cleanup
+}
+
+# get standard environment, filters and checks
+. ./common/rc
+. ./common/filter
+. ./common/dmerror
+
+# real QA test starts here
+_supported_os Linux
+_require_scratch
+_require_logdev
+_require_dm_target error
+
+rm -f $seqres.full
+
+echo "Format and mount"
+$XFS_IO_PROG -d -c "pwrite -S 0x7c -b 1048576 0 $((64 * 1048576))" $SCRATCH_DEV >> $seqres.full
+_scratch_mkfs > $seqres.full 2>&1
+_dmerror_init
+_dmerror_mount >> $seqres.full 2>&1
+_dmerror_unmount
+_dmerror_mount
+
+_require_fs_space $SCRATCH_MNT 8192
+
+testfile=$SCRATCH_MNT/fsync-err-test
+
+$here/src/fsync-err $testfile
+
+# success, all done
+_dmerror_load_working_table
+_dmerror_unmount
+_dmerror_cleanup
+_repair_scratch_fs >> $seqres.full
+status=0
+exit
diff --git a/tests/generic/999.out b/tests/generic/999.out
new file mode 100644
index 000000000000..2e48492ff6d1
--- /dev/null
+++ b/tests/generic/999.out
@@ -0,0 +1,3 @@
+QA output created by 999
+Format and mount
+Test passed!
diff --git a/tests/generic/group b/tests/generic/group
index 9fc7f9d419a8..854c39277dd5 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -432,3 +432,4 @@
 427 auto quick aio rw
 428 auto quick
 429 auto encrypt
+999 auto quick
diff --git a/tools/dmerror b/tools/dmerror
new file mode 100755
index 000000000000..fc0de295e778
--- /dev/null
+++ b/tools/dmerror
@@ -0,0 +1,47 @@
+#!/bin/bash
+#-----------------------------------------------------------------------
+# Copyright (c) 2017, Jeff Layton <jlayton@redhat.com>
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
+
+. ./common/rc
+. ./common/dmerror
+
+_dmerror_setup
+
+case $1 in
+cleanup)
+	_dmerror_cleanup
+	;;
+init)
+	_dmerror_init
+	;;
+load_error_table)
+	_dmerror_load_error_table
+	;;
+load_working_table)
+	_dmerror_load_working_table
+	;;
+mount)
+	_dmerror_mount
+	;;
+*)
+	echo "Usage: $0 {init|cleanup|load_error_table|load_working_table|mount}"
+	exit 1
+	;;
+esac
+
+status=0
+exit
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
