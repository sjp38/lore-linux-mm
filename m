Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 944196B0005
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 04:34:10 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id z1-v6so3913701ybf.4
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 01:34:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m78-v6sor5392007ybf.142.2018.10.11.01.34.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 01:34:09 -0700 (PDT)
MIME-Version: 1.0
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
In-Reply-To: <153923113649.5546.9840926895953408273.stgit@magnolia>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 11 Oct 2018 11:33:57 +0300
Message-ID: <CAOQ4uxgOvOOnKL5TsC9jpjBsepAgtQ56Hhjh7WDeXM7m0=dz7g@mail.gmail.com>
Subject: Re: [PATCH v3 00/25] fs: fixes for serious clone/dedupe problems
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Thu, Oct 11, 2018 at 7:12 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
>
> Hi all,
>
> Dave, Eric, and I have been chasing a stale data exposure bug in the XFS
> reflink implementation, and tracked it down to reflink forgetting to do
> some of the file-extending activities that must happen for regular
> writes.
>
> We then started auditing the clone, dedupe, and copyfile code and
> realized that from a file contents perspective, clonerange isn't any
> different from a regular file write.  Unfortunately, we also noticed
> that *unlike* a regular write, clonerange skips a ton of overflow
> checks, such as validating the ranges against s_maxbytes, MAX_NON_LFS,
> and RLIMIT_FSIZE.  We also observed that cloning into a file did not
> strip security privileges (suid, capabilities) like a regular write
> would.  I also noticed that xfs and ocfs2 need to dump the page cache
> before remapping blocks, not after.
>
> In fixing the range checking problems I also realized that both dedupe
> and copyfile tell userspace how much of the requested operation was
> acted upon.  Since the range validation can shorten a clone request (or
> we can ENOSPC midway through), we might as well plumb the short
> operation reporting back through the VFS indirection code to userspace.
>
> So, here's the whole giant pile of patches[1] that fix all the problems.
> This branch is against 4.19-rc7 with Dave Chinner's XFS for-next branch.
> The patch "generic: test reflink side effects" recently sent to fstests
> exercises the fixes in this series.  Tests are in [2].
>
> --D
>
> [1] https://git.kernel.org/pub/scm/linux/kernel/git/djwong/xfs-linux.git/log/?h=djwong-devel
> [2] https://git.kernel.org/pub/scm/linux/kernel/git/djwong/xfstests-dev.git/log/?h=djwong-devel

I tested your branch with overlayfs over xfs.
I did not observe any failures with -g clone except for test generic/937
which also failed on xfs in my test.

I though that you forgot to mention I needed to grab xfsprogs from djwong-devel
for commit e84a9e93 ("xfs_io: dedupe command should only complain
if we don't dedupe anything"), but even with this change the test still fails:

generic/937     - output mismatch (see
/old/home/amir/src/fstests/xfstests-dev/results//generic/937.out.bad)
    --- tests/generic/937.out   2018-10-11 08:23:00.630938364 +0300
    +++ /old/home/amir/src/fstests/xfstests-dev/results//generic/937.out.bad
   2018-10-11 10:54:40.448134832 +0300
    @@ -4,8 +4,7 @@
     39578c21e2cb9f6049b1cf7fc7be12a6  TEST_DIR/test-937/file2
     Files 1-2 do not match (intentional)
     (partial) dedupe the middle blocks together
    -deduped XXXX/XXXX bytes at offset XXXX
    -XXX Bytes, X ops; XX:XX:XX.X (XXX YYY/sec and XXX ops/sec)
    +XFS_IOC_FILE_EXTENT_SAME: Extents did not match.
     Compare sections

One thing that *is* different with overlayfs test is that filefrag crashes
on this same test:

    QA output created by 937
    Create the original files
    35ac8d7917305c385c30f3d82c30a8f6  TEST_DIR/test-937/file1
    39578c21e2cb9f6049b1cf7fc7be12a6  TEST_DIR/test-937/file2
    Files 1-2 do not match (intentional)
    (partial) dedupe the middle blocks together
    XFS_IOC_FILE_EXTENT_SAME: Extents did not match.
    ./tests/generic/937: line 59: 19242 Floating point exception(core
dumped) ${FILEFRAG_PROG} -v $testdir/file1 >> $seqres.full
    ./tests/generic/937: line 60: 19244 Floating point exception(core
dumped) ${FILEFRAG_PROG} -v $testdir/file2 >> $seqres.full

It looks like an overlayfs v4.19-rc1 regression - FIGETBSZ returns zero.
I never noticed this regression before, because none of the generic tests
are using filefrag.

Thanks,
Amir.
