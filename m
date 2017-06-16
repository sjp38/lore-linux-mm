Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 613634404A3
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:37:09 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m57so42174612qta.9
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:37:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j9si2761794qtc.324.2017.06.16.12.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:37:07 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [xfstests PATCH v5 3/5] generic: add a writeback error handling test
Date: Fri, 16 Jun 2017 15:36:17 -0400
Message-Id: <20170616193619.14576-4-jlayton@redhat.com>
In-Reply-To: <20170616193619.14576-1-jlayton@redhat.com>
References: <20170616193619.14576-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

I'm working on a set of kernel patches to change how writeback errors
are handled and reported in the kernel. Instead of reporting a
writeback error to only the first fsync caller on the file, it has
the the kernel report them once on every file description that was
open at the time of the error.

This patch adds a test for this new behavior. Basically, open many fds
to the same file, turn on dm_error, write to each of the fds, and then
fsync them all to ensure that they all get an error back.

To do that, I'm adding a new tools/dmerror script that the C program
can use to load the error table from the script. It's also suitable for
setting up, frobbing and tearing down a dmerror device for by-hand testing.

For now, only ext2/3/4 and xfs are whitelisted on this test, since those
filesystems are included in the initial patchset. We can add to that as
we convert filesystems, and eventually make it a more general test.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 .gitignore                 |   1 +
 common/dmerror             |  13 ++-
 doc/auxiliary-programs.txt |  16 ++++
 src/Makefile               |   4 +-
 src/dmerror                |  44 +++++++++
 src/fsync-err.c            | 223 +++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/999          |  84 +++++++++++++++++
 tests/generic/999.out      |   3 +
 tests/generic/group        |   1 +
 9 files changed, 382 insertions(+), 7 deletions(-)
 create mode 100755 src/dmerror
 create mode 100644 src/fsync-err.c
 create mode 100755 tests/generic/999
 create mode 100644 tests/generic/999.out

diff --git a/.gitignore b/.gitignore
index 39664b0a7f53..56e863b2c8dc 100644
--- a/.gitignore
+++ b/.gitignore
@@ -72,6 +72,7 @@
 /src/fs_perms
 /src/fssum
 /src/fstest
+/src/fsync-err
 /src/fsync-tester
 /src/ftrunc
 /src/genhashnames
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
diff --git a/doc/auxiliary-programs.txt b/doc/auxiliary-programs.txt
index 21ef118596b6..bcab453c4335 100644
--- a/doc/auxiliary-programs.txt
+++ b/doc/auxiliary-programs.txt
@@ -16,6 +16,8 @@ note the dependency with:
 Contents:
 
  - af_unix		-- Create an AF_UNIX socket
+ - dmerror		-- fault injection block device control
+ - fsync-err		-- tests fsync error reporting after failed writeback
  - open_by_handle	-- open_by_handle_at syscall exercise
  - stat_test		-- statx syscall exercise
  - t_dir_type		-- print directory entries and their file type
@@ -30,6 +32,20 @@ af_unix
 
 	The af_unix program creates an AF_UNIX socket at the given location.
 
+dmerror
+
+	dmerror is a program for creating, destroying and controlling a
+	fault injection device. The device can be set up as initially
+	working and then flip to throwing errors for testing purposes.
+
+fsync-err
+
+	Specialized program for testing how the kernel reports errors that
+	occur during writeback. Works in conjunction with the dmerror script
+	in tools/ to write data to a device, and then force it to fail
+	writeback and test that errors are reported during fsync and cleared
+	afterward.
+
 open_by_handle
 
 	The open_by_handle program exercises the open_by_handle_at() system
diff --git a/src/Makefile b/src/Makefile
index 6b0e4b022485..2c1b898cebe1 100644
--- a/src/Makefile
+++ b/src/Makefile
@@ -13,7 +13,7 @@ TARGETS = dirstress fill fill2 getpagesize holes lstat64 \
 	multi_open_unlink dmiperf unwritten_sync genhashnames t_holes \
 	t_mmap_writev t_truncate_cmtime dirhash_collide t_rename_overwrite \
 	holetest t_truncate_self t_mmap_dio af_unix t_mmap_stale_pmd \
-	t_mmap_cow_race t_mmap_fallocate
+	t_mmap_cow_race t_mmap_fallocate fsync-err
 
 LINUX_TARGETS = xfsctl bstat t_mtab getdevicesize preallo_rw_pattern_reader \
 	preallo_rw_pattern_writer ftrunc trunc fs_perms testx looptest \
@@ -86,7 +86,7 @@ LINKTEST = $(LTLINK) $@.c -o $@ $(CFLAGS) $(LDFLAGS)
 install: default $(addsuffix -install,$(SUBDIRS))
 	$(INSTALL) -m 755 -d $(PKG_LIB_DIR)/src
 	$(LTINSTALL) -m 755 $(LDIRT) $(PKG_LIB_DIR)/src
-	$(LTINSTALL) -m 755 fill2attr fill2fs fill2fs_check scaleread.sh $(PKG_LIB_DIR)/src
+	$(LTINSTALL) -m 755 dmerror fill2attr fill2fs fill2fs_check scaleread.sh $(PKG_LIB_DIR)/src
 	$(LTINSTALL) -m 644 dumpfile $(PKG_LIB_DIR)/src
 
 %-install:
diff --git a/src/dmerror b/src/dmerror
new file mode 100755
index 000000000000..4aaf682ee5f9
--- /dev/null
+++ b/src/dmerror
@@ -0,0 +1,44 @@
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
+. ./common/config
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
+*)
+	echo "Usage: $0 {init|cleanup|load_error_table|load_working_table}"
+	exit 1
+	;;
+esac
+
+status=0
+exit
diff --git a/src/fsync-err.c b/src/fsync-err.c
new file mode 100644
index 000000000000..5b3bdd3ada07
--- /dev/null
+++ b/src/fsync-err.c
@@ -0,0 +1,223 @@
+/*
+ * fsync-err.c: test whether writeback errors are reported to all open fds
+ * 		and properly cleared as expected after being seen once on each
+ *
+ * Copyright (c) 2017: Jeff Layton <jlayton@redhat.com>
+ */
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+#include <getopt.h>
+
+/*
+ * btrfs has a fixed stripewidth of 64k, so we need to write enough data to
+ * ensure that we hit both stripes by default.
+ */
+#define DEFAULT_BUFSIZE (65 * 1024)
+
+/* default number of fds to open */
+#define DEFAULT_NUM_FDS	10
+
+static void usage()
+{
+	printf("Usage: fsync-err [ -b bufsize ] [ -n num_fds ] -d dmerror path <filename>\n");
+}
+
+int main(int argc, char **argv)
+{
+	int *fd, ret, i, numfds = DEFAULT_NUM_FDS;
+	char *fname, *buf;
+	char *dmerror_path = NULL;
+	char *cmdbuf;
+	size_t cmdsize, bufsize = DEFAULT_BUFSIZE;
+
+	while ((i = getopt(argc, argv, "b:d:n:")) != -1) {
+		switch (i) {
+		case 'b':
+			bufsize = strtol(optarg, &buf, 0);
+			if (*buf != '\0') {
+				printf("bad string conversion: %s\n", optarg);
+				return 1;
+			}
+			break;
+		case 'd':
+			dmerror_path = optarg;
+			break;
+		case 'n':
+			numfds = strtol(optarg, &buf, 0);
+			if (*buf != '\0') {
+				printf("bad string conversion: %s\n", optarg);
+				return 1;
+			}
+			break;
+		}
+	}
+
+	if (argc < 1) {
+		usage();
+		return 1;
+	}
+
+	if (!dmerror_path) {
+		printf("Must specify dmerror path with -d option!\n");
+		return 1;
+	}
+
+	/* Remaining argument is filename */
+	fname = argv[optind];
+
+	fd = calloc(numfds, sizeof(*fd));
+	if (!fd) {
+		printf("malloc failed: %m\n");
+		return 1;
+	}
+
+	for (i = 0; i < numfds; ++i) {
+		fd[i] = open(fname, O_WRONLY | O_CREAT | O_TRUNC, 0644);
+		if (fd[i] < 0) {
+			printf("open of fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	buf = malloc(bufsize);
+	if (!buf) {
+		printf("malloc failed: %m\n");
+		return 1;
+	}
+
+	/* fill it with some junk */
+	memset(buf, 0x7c, bufsize);
+
+	for (i = 0; i < numfds; ++i) {
+		ret = write(fd[i], buf, bufsize);
+		if (ret < 0) {
+			printf("First write on fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	for (i = 0; i < numfds; ++i) {
+		ret = fsync(fd[i]);
+		if (ret < 0) {
+			printf("First fsync on fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	/* enough for path + dmerror command string  (and then some) */
+	cmdsize = strlen(dmerror_path) + 64;
+
+	cmdbuf = malloc(cmdsize);
+	if (!cmdbuf) {
+		printf("malloc failed: %m\n");
+		return 1;
+	}
+
+	ret = snprintf(cmdbuf, cmdsize, "%s load_error_table", dmerror_path);
+	if (ret < 0 || ret >= cmdsize) {
+		printf("sprintf failure: %d\n", ret);
+		return 1;
+	}
+
+	/* flip the device to non-working mode */
+	ret = system(cmdbuf);
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
+	for (i = 0; i < numfds; ++i) {
+		ret = write(fd[i], buf, bufsize);
+		if (ret < 0) {
+			printf("Second write on fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	for (i = 0; i < numfds; ++i) {
+		ret = fsync(fd[i]);
+		/* Now, we EXPECT the error! */
+		if (ret >= 0) {
+			printf("Success on second fsync on fd[%d]!\n", i);
+			return 1;
+		}
+	}
+
+	for (i = 0; i < numfds; ++i) {
+		ret = fsync(fd[i]);
+		if (ret < 0) {
+			/*
+			 * We did a failed write and fsync on each fd before.
+			 * Now the error should be clear since we've not done
+			 * any writes since then.
+			 */
+			printf("Third fsync on fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	/* flip the device to working mode */
+	ret = snprintf(cmdbuf, cmdsize, "%s load_working_table", dmerror_path);
+	if (ret < 0 || ret >= cmdsize) {
+		printf("sprintf failure: %d\n", ret);
+		return 1;
+	}
+
+	ret = system(cmdbuf);
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
+	for (i = 0; i < numfds; ++i) {
+		ret = fsync(fd[i]);
+		if (ret < 0) {
+			/* The error should still be clear */
+			printf("fsync after healing device on fd[%d] failed: %m\n", i);
+			return 1;
+		}
+	}
+
+	/*
+	 * reopen each file one at a time to ensure the same inode stays
+	 * in core. fsync each one to make sure we see no errors on a fresh
+	 * open of the inode.
+	 */
+	for (i = 0; i < numfds; ++i) {
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
index 000000000000..3a8cca9cd0b1
--- /dev/null
+++ b/tests/generic/999
@@ -0,0 +1,84 @@
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
+	cd /
+	rm -rf $tmp.* $testdir
+	_dmerror_cleanup
+}
+
+# get standard environment, filters and checks
+. ./common/rc
+. ./common/filter
+. ./common/dmerror
+
+# real QA test starts here
+_supported_fs ext2 ext3 ext4 xfs
+_supported_os Linux
+_require_scratch
+
+# Generally, we want to avoid journal errors in this test. Ensure that
+# journalled fs' have a logdev.
+if [ "$FSTYP" != "ext2" ]; then
+	_require_logdev
+fi
+
+_require_dm_target error
+_require_test_program fsync-err
+_require_test_program dmerror
+
+rm -f $seqres.full
+
+echo "Format and mount"
+_scratch_mkfs > $seqres.full 2>&1
+_dmerror_init
+_dmerror_mount
+
+_require_fs_space $SCRATCH_MNT 65536
+
+testfile=$SCRATCH_MNT/fsync-err-test
+
+$here/src/fsync-err -d $here/src/dmerror $testfile
+
+# success, all done
+_dmerror_load_working_table
+_dmerror_unmount
+_dmerror_cleanup
+
+# fs may be corrupt after this -- attempt to repair it
+_repair_scratch_fs >> $seqres.full
+
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
index 5d3e4dcf732e..b56bae8f04f0 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -442,3 +442,4 @@
 437 auto quick
 438 auto
 439 auto quick punch
+999 auto quick
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
