Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id AEC686B0071
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 08:56:48 -0400 (EDT)
Received: by wixw10 with SMTP id w10so34342102wix.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 05:56:48 -0700 (PDT)
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id k8si11645830wiy.84.2015.03.23.05.56.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 05:56:47 -0700 (PDT)
Received: by wgra20 with SMTP id a20so145196530wgr.3
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 05:56:46 -0700 (PDT)
Message-ID: <55100D8B.90409@plexistor.com>
Date: Mon, 23 Mar 2015 14:56:43 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH v4] xfstest: generic/080 test that mmap-write updates c/mtime
References: <55100B78.501@plexistor.com>
In-Reply-To: <55100B78.501@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

From: Dave Chinner <dchinner@redhat.com>

when using mmap() for file i/o, writing to the file should update
it's c/mtime. Specifically if we first mmap-read from a page, then
memap-write to the same page.

This test was failing for the initial submission of DAX because
pfn based mapping do not have an page_mkwrite called for them.
The new Kernel patches that introduce pfn_mkwrite fixes this test.

Written by Dave Chinner but edited and tested by:
	Omer Zilberberg

Dave hands-up man, it looks like you edited this directly
in the email, but there was not even a single typo.

Tested-by: Omer Zilberberg <omzg@plexistor.com>
Tested-by: Boaz Harrosh <boaz@plexistor.com>
Signed-off-by: Omer Zilberberg <omzg@plexistor.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
Reviewed-by: Eryu Guan <eguan@redhat.com>
---
 tests/generic/080     | 78 +++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/080.out |  2 ++
 tests/generic/group   |  1 +
 3 files changed, 81 insertions(+)
 create mode 100755 tests/generic/080
 create mode 100644 tests/generic/080.out

diff --git a/tests/generic/080 b/tests/generic/080
new file mode 100755
index 0000000..43c93d7
--- /dev/null
+++ b/tests/generic/080
@@ -0,0 +1,78 @@
+#! /bin/bash
+# FS QA Test No. 080
+#
+# Verify that mtime is updated when writing to mmap-ed pages
+#
+#-----------------------------------------------------------------------
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
+status=0
+trap "_cleanup; exit \$status" 0 1 2 3 15
+
+_cleanup()
+{
+	cd /
+	rm -f $tmp.*
+	rm -f $testfile
+}
+
+# get standard environment, filters and checks
+. ./common/rc
+. ./common/filter
+
+# real QA test starts here
+_supported_fs generic
+_supported_os IRIX Linux
+_require_test
+
+echo "Silence is golden."
+rm -f $seqres.full
+
+# pattern the file.
+testfile=$TEST_DIR/mmap_mtime_testfile
+$XFS_IO_PROG -f -c "pwrite 0 4k" -c fsync $testfile >> $seqres.full
+
+# sample timestamps.
+mtime1=`stat -c %Y $testfile`
+ctime1=`stat -c %Z $testfile`
+echo "before mwrite: $mtime1 $ctime1" >> $seqres.full
+
+# map read followed by map write to trigger timestamp change
+sleep 2
+$XFS_IO_PROG -c "mmap 0 4k" -c "mread 0 4k" -c "mwrite 0 4k" $testfile \
+	>> $seqres.full
+
+# sample and verify that timestamps have changed.
+mtime2=`stat -c %Y $testfile`
+ctime2=`stat -c %Z $testfile`
+echo "after mwrite : $mtime2 $ctime2" >> $seqres.full
+
+if [ "$mtime1" == "$mtime2" ]; then
+	echo "mtime not updated"
+	let status=$status+1
+fi
+if [ "$ctime1" == "$ctime2" ]; then
+	echo "ctime not updated"
+	let status=$status+1
+fi
+
+exit
diff --git a/tests/generic/080.out b/tests/generic/080.out
new file mode 100644
index 0000000..cccac52
--- /dev/null
+++ b/tests/generic/080.out
@@ -0,0 +1,2 @@
+QA output created by 080
+Silence is golden.
diff --git a/tests/generic/group b/tests/generic/group
index d56d3ce..8154401 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -79,6 +79,7 @@
 077 acl attr auto enospc
 078 auto quick metadata
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
