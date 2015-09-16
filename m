Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3936B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 06:48:12 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so206664393pac.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 03:48:12 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id pe7si39815914pbb.152.2015.09.16.03.48.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Sep 2015 03:48:11 -0700 (PDT)
From: Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: xfstests: test data-writeback error detection with fsync
Date: Wed, 16 Sep 2015 10:45:26 +0000
Message-ID: <20150916104525.GA13854@xzibit.linux.bs1.fc.nec.co.jp>
References: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915095412.GD13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915143723.GA1747@two.firstfloor.org>
 <20150915150254.6c78985cb271c7104b3ee717@linux-foundation.org>
 <20150916004541.GA6059@xzibit.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150916004541.GA6059@xzibit.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B8AAFDD8FA4B3047A125A4FFFAF5AD21@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, Tejun Heo <tj@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 09/16/15 07:02, Andrew Morton wrote:
> It would be nice to capture the test case(s) somewhere permanent.=20
> Possibly in tools/testing/selftests, but selftests is more for
> peculiar
> linux-specific things.  LTP or xfstests would be a better place.

This is a xfstests version of my test case.
(Device failure portion only. Memory failure will need additional code.)

I used '9999' in this proposal temporarily but if I should other number,
I'll fix that.

---
 common/dm_error       |   96 ++++++++++++++++++++++++++++++++++++++++++
 common/rc             |   16 +++++++
 tests/shared/9999     |  113 +++++++++++++++++++++++++++++++++++++++++++++=
+++++
 tests/shared/9999.out |   18 +++++++
 tests/shared/group    |    1=20
 5 files changed, 244 insertions(+)

diff --git a/common/dm_error b/common/dm_error
new file mode 100644
index 0000000..f6c926f
--- /dev/null
+++ b/common/dm_error
@@ -0,0 +1,96 @@
+##/bin/bash
+#
+# Copyright (c) 2015 NEC Corporation.  All Rights Reserved.
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
+#
+#
+# common functions for setting up and tearing down a dm error device
+
+# device-mapper map name
+DM_ERR_MAPNAME=3Dxfstests-dm-error
+
+# temporary file names for storing device-mapper table data
+DM_ERR_NORMAL_MAP=3D$RESULT_DIR/$DM_ERR_MAPNAME.ok
+DM_ERR_ERROR_MAP=3D$RESULT_DIR/$DM_ERR_MAPNAME.err
+
+_init_dm_error() {
+	# Layer DM device for error injection
+	echo "0 $(blockdev --getsz $SCRATCH_DEV) linear $SCRATCH_DEV 0" | \
+		$DMSETUP_PROG create $DM_ERR_MAPNAME || \
+		_fatal "failed to create dm linear device"
+	$DMSETUP_PROG table $DM_ERR_MAPNAME > $DM_ERR_NORMAL_MAP
+}
+
+_prepare_dm_error_table_for_file() {
+	local file=3D$1
+	local offset=3D$2
+	local len=3D$3
+
+	# Find physical location of the target file
+	find_location() {
+		# pick up physical block number of file offset 0
+		$FILEFRAG_PROG -v $1 | \
+			awk '$1 =3D=3D "0" {print $3} $1 =3D=3D "0:" {print $4}' | \
+			sed 's/\.//g'
+	}
+	local block=3D$(find_location $file)
+	if [ -z "$block" ]; then
+		_fatal "failed to find physical block for $file"
+	fi
+	local blocksize=3D$(stat -c %s -f $file)
+	local secsize=3D512
+	local sector=3D$((block * blocksize / secsize + offset))
+
+	# Create error mapping: inject error at $sector
+	local next=3D$((sector + len))
+	local total=3D$(blockdev --getsz $SCRATCH_DEV)
+	local remainder=3D$((total - next))
+
+	# Generate error mapping
+	echo "0 $sector linear $SCRATCH_DEV 0" > $DM_ERR_ERROR_MAP
+	echo "$sector $len error" >> $DM_ERR_ERROR_MAP
+	echo "$next $remainder linear $SCRATCH_DEV $next" >> $DM_ERR_ERROR_MAP
+}
+
+_load_dm_error_table() {
+	cat $DM_ERR_ERROR_MAP | $DMSETUP_PROG load $DM_ERR_MAPNAME || \
+		_fatal "failed to load dm error table"
+	$DMSETUP_PROG suspend --nolockfs $DM_ERR_MAPNAME || \
+		_fatal "failed to suspend dm device"
+	$DMSETUP_PROG resume $DM_ERR_MAPNAME || \
+		_fatal "failed to suspend dm device"
+}
+_unload_dm_error_table() {
+	cat $DM_ERR_NORMAL_MAP | $DMSETUP_PROG load $DM_ERR_MAPNAME || \
+		_fatal "failed to re-load normal dm table"
+	$DMSETUP_PROG suspend --nolockfs $DM_ERR_MAPNAME || \
+		_fatal "failed to suspend dm device"
+	$DMSETUP_PROG resume $DM_ERR_MAPNAME || \
+		_fatal "failed to suspend dm device"
+}
+
+_mount_dm_error() {
+	mount -t $FSTYP $MOUNT_OPTIONS /dev/mapper/$DM_ERR_MAPNAME $SCRATCH_MNT
+}
+
+_unmount_dm_error() {
+	$UMOUNT_PROG $SCRATCH_MNT
+}
+
+_cleanup_dm_error() {
+	_unmount_dm_error
+	$DMSETUP_PROG remove $DM_ERR_MAPNAME
+	rm -f $DM_ERR_NORMAL_MAP $DM_ERR_ERROR_MAP
+}
diff --git a/common/rc b/common/rc
index 70d2fa8..a4478f6 100644
--- a/common/rc
+++ b/common/rc
@@ -1337,6 +1337,22 @@ _require_sane_bdev_flush()
 	fi
 }
=20
+# this test requires the device mapper error target
+#
+_require_dm_error()
+{
+	_require_block_device $SCRATCH_DEV
+	_require_command "$DMSETUP_PROG" dmsetup
+	# Use filefrag to find location to inject failure
+	_require_command "$FILEFRAG_PROG" filefrag
+
+	modprobe dm-mod >/dev/null 2>&1
+	$DMSETUP_PROG targets | grep error >/dev/null 2>&1
+	if [ $? -ne 0 ]; then
+		_notrun "This test requires dm error support"
+	fi
+}
+
 # this test requires the device mapper flakey target
 #
 _require_dm_flakey()
diff --git a/tests/shared/9999 b/tests/shared/9999
new file mode 100755
index 0000000..9e66f77
--- /dev/null
+++ b/tests/shared/9999
@@ -0,0 +1,113 @@
+#!/bin/bash
+# FS QA Test No. 9999
+#
+# Overwrite blocks on buffer, inject sector error using device-mapper,
+# run sync, and then fsync the file.
+# Verify if fsync could detect the error.
+#
+#-----------------------------------------------------------------------
+# Copyright (C) 2015 NEC Corporation. All Rights Reserved.
+# Author: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
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
+seq=3D`basename $0`
+seqres=3D$RESULT_DIR/$seq
+echo "QA output created by $seq"
+
+here=3D`pwd`
+status=3D1        # failure is the default!
+
+_cleanup() {
+	_cleanup_dm_error
+}
+trap "_cleanup; exit \$status" 0 1 2 3 15
+
+# get standard environment, filters and checks
+. ./common/rc
+. ./common/filter
+. ./common/dm_error
+
+# real QA test starts here
+_supported_fs ext4 ext3 ext2 xfs
+_supported_os Linux
+_need_to_be_root
+_require_scratch
+_require_dm_error
+
+rm -f $seqres.full
+
+_scratch_mkfs >> $seqres.full 2>&1
+
+# test file name, size and filling patterns
+testfile=3D$SCRATCH_MNT/x
+filesize=3D16384
+pat1=3D0x11
+pat2=3D0xaa
+
+_init_dm_error
+_mount_dm_error
+
+echo "Create testfile"
+$XFS_IO_PROG -f \
+	-c "pwrite -S $pat1 0 $filesize" -c "fsync" \
+	$testfile | _filter_xfs_io
+$XFS_IO_PROG -f \
+	-c "pwrite -S $pat2 0 $filesize" -c "fsync" \
+	$testfile.expected | _filter_xfs_io
+_prepare_dm_error_table_for_file $testfile 0 1
+
+echo "Buffered write on the file"
+$XFS_IO_PROG -c "pwrite -S $pat2 0 $filesize" $testfile | _filter_xfs_io
+
+echo "Inject device error"
+_load_dm_error_table
+
+# Running 'sync' while written data is on buffer. This should start
+# writeback and wait for completion.  Beause of the injected failure,
+# the file is marked with AS_EIO.
+echo "Execute sync command"
+sync
+
+# fsync() should get error return.
+echo "Do fsync on the file (should fail)"
+$XFS_IO_PROG -c "fsync" $testfile | _filter_xfs_io
+
+echo "Remove injected device error"
+_unload_dm_error_table
+_unmount_dm_error
+_mount_dm_error
+
+cmp $testfile $testfile.expected >> $seqres.full 2>&1
+if [ $? -ne 0 ]; then
+	echo "Data was not written to disk"
+fi
+echo "Expected contents of the file if error was not injected:" >> $seqres=
.full
+od -t x1 $testfile.expected >> $seqres.full
+echo "Actual contents of the file:" >> $seqres.full
+od -t x1 $testfile >> $seqres.full
+
+echo "Retry write and fsync"
+$XFS_IO_PROG -f \
+	-c "pwrite -S $pat2 0 $filesize" -c "fsync" \
+	$testfile | _filter_xfs_io
+
+cmp $testfile $testfile.expected
+echo "Contents of the file after retry:" >> $seqres.full
+od -t x1 $testfile >> $seqres.full
+
+status=3D0
+exit
diff --git a/tests/shared/9999.out b/tests/shared/9999.out
new file mode 100644
index 0000000..236e913
--- /dev/null
+++ b/tests/shared/9999.out
@@ -0,0 +1,18 @@
+QA output created by 9999
+Create testfile
+wrote 16384/16384 bytes at offset 0
+XXX Bytes, X ops; XX:XX:XX.X (XXX YYY/sec and XXX ops/sec)
+wrote 16384/16384 bytes at offset 0
+XXX Bytes, X ops; XX:XX:XX.X (XXX YYY/sec and XXX ops/sec)
+Buffered write on the file
+wrote 16384/16384 bytes at offset 0
+XXX Bytes, X ops; XX:XX:XX.X (XXX YYY/sec and XXX ops/sec)
+Inject device error
+Execute sync command
+Do fsync on the file (should fail)
+fsync: Input/output error
+Remove injected device error
+Data was not written to disk
+Retry write and fsync
+wrote 16384/16384 bytes at offset 0
+XXX Bytes, X ops; XX:XX:XX.X (XXX YYY/sec and XXX ops/sec)
diff --git a/tests/shared/group b/tests/shared/group
index 00d42c8..f196b71 100644
--- a/tests/shared/group
+++ b/tests/shared/group
@@ -11,3 +11,4 @@
 272 auto enospc rw
 289 auto quick
 298 auto trim
+9999 auto quick data=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
