Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4776B02C3
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 04:32:36 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o21so59431910qtb.13
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 01:32:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m31si11116126qtm.188.2017.06.13.01.32.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 01:32:35 -0700 (PDT)
Date: Tue, 13 Jun 2017 16:32:31 +0800
From: Eryu Guan <eguan@redhat.com>
Subject: Re: [xfstests PATCH v4 0/5] new tests for writeback error reporting
 behavior
Message-ID: <20170613083231.GB4788@eguan.usersys.redhat.com>
References: <20170612124213.14855-1-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170612124213.14855-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Mon, Jun 12, 2017 at 08:42:08AM -0400, Jeff Layton wrote:
> v4: respin set based on Eryu's comments
> 
> These tests are companion tests to the patchset I recently posted with
> the cover letter:
> 
>     [PATCH v6 00/20] fs: enhanced writeback error reporting with errseq_t (pile #1)
> 
> This set just adds 3 new xfstests to test writeback behavior. One generic
> filesystem test, one test for raw block devices, and one test for btrfs.
> The tests work with dmerror to ensure that writeback fails, and then
> tests how the kernel reports errors afterward.
> 
> xfs, ext2/3/4 and btrfs all pass on a kernel with the patchset above.

xfs, ext3/4 passed generic/999, btrfs passed btrfs/999 (with some local
modifications, see reply to btrfs/999), but ext2 (using ext4 driver) and
btrfs failed generic/999 on my host. (See test log at the end of mail.)

In the ext2 case, this test requires an external log device to run, but
ext2 has no journal at all, I wonder if we should _notrun on ext2.

btrfs doesn't support external log device either, it should not run this
generic test either.

I think _require_logdev() should be updated too, to do a check on
$FSTYP, only allows filesystems that have external log device support to
continue to run.

> 
> The one comment I couldn't really address from earlier review is that
> we don't have a great way for xfstests to tell what sort of error
> reporting behavior it should expect from the running kernel. That
> makes it difficult to tell whether failure is expected during a given
> run.
> 
> Maybe that's OK though and we should just let unconverted filesystems
> fail this test?

If there's really no good way to tell if current fs supports this new
behavior, I think this is fine, strictly speaking, it's not a new
feature anyway.

Thanks,
Eryu

P.S. ext2 and btrfs failure in generic/999 run (I renumbered it to
generic/441)

[root@ibm-x3550m3-05 xfstests]# ./check generic/441 generic/442
FSTYP         -- ext2
PLATFORM      -- Linux/x86_64 ibm-x3550m3-05 4.12.0-rc4.jlayton+
MKFS_OPTIONS  -- /dev/sdc2
MOUNT_OPTIONS -- -o acl,user_xattr -o context=system_u:object_r:root_t:s0 /dev/sdc2 /mnt/testarea/scratch

generic/441 4s ... - output mismatch (see /root/xfstests/results//generic/441.out.bad)
    --- tests/generic/441.out   2017-06-13 15:52:09.928413126 +0800
    +++ /root/xfstests/results//generic/441.out.bad     2017-06-13 16:21:41.414112226 +0800
    @@ -1,3 +1,3 @@
     QA output created by 441
     Format and mount
    -Test passed!
    +Third fsync on fd[0] failed: Input/output error
    ...
    (Run 'diff -u tests/generic/441.out /root/xfstests/results//generic/441.out.bad'  to see the entire diff)

[root@ibm-x3550m3-05 xfstests]# ./check generic/441 generic/442
FSTYP         -- btrfs
PLATFORM      -- Linux/x86_64 ibm-x3550m3-05 4.12.0-rc4.jlayton+
MKFS_OPTIONS  -- /dev/sdc2
MOUNT_OPTIONS -- -o context=system_u:object_r:root_t:s0 /dev/sdc2 /mnt/testarea/scratch

generic/441 4s ... - output mismatch (see /root/xfstests/results//generic/441.out.bad)
    --- tests/generic/441.out   2017-06-13 15:52:09.928413126 +0800
    +++ /root/xfstests/results//generic/441.out.bad     2017-06-13 16:25:17.483273992 +0800
    @@ -1,3 +1,3 @@
     QA output created by 441
     Format and mount
    -Test passed!
    +Third fsync on fd[0] failed: Read-only file system
    ...
    (Run 'diff -u tests/generic/441.out /root/xfstests/results//generic/441.out.bad'  to see the entire diff)
> 
> Jeff Layton (5):
>   generic: add a writeback error handling test
>   ext4: allow ext4 to use $SCRATCH_LOGDEV
>   generic: test writeback error handling on dmerror devices
>   ext3: allow it to put journal on a separate device when doing
>     scratch_mkfs
>   btrfs: make a btrfs version of writeback error reporting test
> 
>  .gitignore                 |   1 +
>  common/dmerror             |  13 ++-
>  common/rc                  |  14 ++-
>  doc/auxiliary-programs.txt |  16 ++++
>  src/Makefile               |   2 +-
>  src/dmerror                |  44 +++++++++
>  src/fsync-err.c            | 223 +++++++++++++++++++++++++++++++++++++++++++++
>  tests/btrfs/999            |  93 +++++++++++++++++++
>  tests/btrfs/group          |   1 +
>  tests/generic/998          |  64 +++++++++++++
>  tests/generic/998.out      |   2 +
>  tests/generic/999          |  77 ++++++++++++++++
>  tests/generic/999.out      |   3 +
>  tests/generic/group        |   2 +
>  14 files changed, 548 insertions(+), 7 deletions(-)
>  create mode 100755 src/dmerror
>  create mode 100644 src/fsync-err.c
>  create mode 100755 tests/btrfs/999
>  create mode 100755 tests/generic/998
>  create mode 100644 tests/generic/998.out
>  create mode 100755 tests/generic/999
>  create mode 100644 tests/generic/999.out
> 
> -- 
> 2.13.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
