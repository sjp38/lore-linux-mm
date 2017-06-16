Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 060B744043B
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:36:27 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id z22so42285720qtz.10
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:36:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u55si2761139qth.202.2017.06.16.12.36.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:36:26 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [xfstests PATCH v5 0/5] new tests for writeback error reporting behavior
Date: Fri, 16 Jun 2017 15:36:14 -0400
Message-Id: <20170616193619.14576-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

The main changes in this set from the last are:

- add a btrfs/999.out file
- use _supported_fs to whitelist fs' on which the tests should run
- fix the ext3/4 mount option handling when creating journal device
- ensure that dmerror is installed on make install

These tests are intended to test the new writeback error reporting
introduced by this kernel patchset:

    [PATCH v7 00/22] fs: enhanced writeback error reporting with errseq_t (pile #1)

It adds 3 new xfstests for testing kernel behavior when writeback from
the pagecache fails: one generic filesystem test, one test for raw block
devices and one test for btrfs.

The tests work with dmerror to make data writeback from the pagecache
fail, and then tests how the kernel reports errors afterward.

xfs, ext2/3/4 and btrfs all pass on a kernel with the patchset above. "Bare"
block devices also work correctly.

Jeff Layton (5):
  ext4: allow ext4 to use $SCRATCH_LOGDEV
  ext3: allow it to put journal on a separate device when doing
    scratch_mkfs
  generic: add a writeback error handling test
  generic: test writeback error handling on dmerror devices
  btrfs: make a btrfs version of writeback error reporting test

 .gitignore                 |   1 +
 common/dmerror             |  13 ++-
 common/rc                  |  14 ++-
 doc/auxiliary-programs.txt |  16 ++++
 src/Makefile               |   4 +-
 src/dmerror                |  44 +++++++++
 src/fsync-err.c            | 223 +++++++++++++++++++++++++++++++++++++++++++++
 tests/btrfs/999            |  94 +++++++++++++++++++
 tests/btrfs/999.out        |   3 +
 tests/btrfs/group          |   1 +
 tests/generic/998          |  63 +++++++++++++
 tests/generic/998.out      |   2 +
 tests/generic/999          |  84 +++++++++++++++++
 tests/generic/999.out      |   3 +
 tests/generic/group        |   2 +
 15 files changed, 559 insertions(+), 8 deletions(-)
 create mode 100755 src/dmerror
 create mode 100644 src/fsync-err.c
 create mode 100755 tests/btrfs/999
 create mode 100644 tests/btrfs/999.out
 create mode 100755 tests/generic/998
 create mode 100644 tests/generic/998.out
 create mode 100755 tests/generic/999
 create mode 100644 tests/generic/999.out

-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
