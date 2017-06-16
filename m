Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5244404A3
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:37:17 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o21so42464444qtb.13
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:37:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r188si2729103qke.208.2017.06.16.12.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:37:16 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [xfstests PATCH v5 4/5] generic: test writeback error handling on dmerror devices
Date: Fri, 16 Jun 2017 15:36:18 -0400
Message-Id: <20170616193619.14576-5-jlayton@redhat.com>
In-Reply-To: <20170616193619.14576-1-jlayton@redhat.com>
References: <20170616193619.14576-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Ensure that we get an error back on all fds when a block device is
open by multiple writers and writeback fails.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 tests/generic/998     | 63 +++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/998.out |  2 ++
 tests/generic/group   |  1 +
 3 files changed, 66 insertions(+)
 create mode 100755 tests/generic/998
 create mode 100644 tests/generic/998.out

diff --git a/tests/generic/998 b/tests/generic/998
new file mode 100755
index 000000000000..ef528f18986e
--- /dev/null
+++ b/tests/generic/998
@@ -0,0 +1,63 @@
+#! /bin/bash
+# FS QA Test No. 998
+#
+# Test writeback error handling when writing to block devices via pagecache.
+# See src/fsync-err.c for details of what test actually does.
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
+_require_dm_target error
+_require_test_program fsync-err
+_require_test_program dmerror
+
+rm -f $seqres.full
+
+_dmerror_init
+
+$here/src/fsync-err -d $here/src/dmerror $DMERROR_DEV
+
+# success, all done
+_dmerror_load_working_table
+_dmerror_cleanup
+_scratch_mkfs > $seqres.full 2>&1
+status=0
+exit
diff --git a/tests/generic/998.out b/tests/generic/998.out
new file mode 100644
index 000000000000..658c438820e2
--- /dev/null
+++ b/tests/generic/998.out
@@ -0,0 +1,2 @@
+QA output created by 998
+Test passed!
diff --git a/tests/generic/group b/tests/generic/group
index b56bae8f04f0..9c62ab13ad36 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -442,4 +442,5 @@
 437 auto quick
 438 auto
 439 auto quick punch
+998 blockdev
 999 auto quick
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
