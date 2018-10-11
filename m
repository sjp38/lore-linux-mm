Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70A706B026B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 00:12:23 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d1-v6so6996093qkb.11
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:12:23 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id k7-v6si17173457qvc.79.2018.10.10.21.12.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 21:12:22 -0700 (PDT)
Subject: [PATCH v3 00/25] fs: fixes for serious clone/dedupe problems
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Wed, 10 Oct 2018 21:12:16 -0700
Message-ID: <153923113649.5546.9840926895953408273.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

Hi all,

Dave, Eric, and I have been chasing a stale data exposure bug in the XFS
reflink implementation, and tracked it down to reflink forgetting to do
some of the file-extending activities that must happen for regular
writes.

We then started auditing the clone, dedupe, and copyfile code and
realized that from a file contents perspective, clonerange isn't any
different from a regular file write.  Unfortunately, we also noticed
that *unlike* a regular write, clonerange skips a ton of overflow
checks, such as validating the ranges against s_maxbytes, MAX_NON_LFS,
and RLIMIT_FSIZE.  We also observed that cloning into a file did not
strip security privileges (suid, capabilities) like a regular write
would.  I also noticed that xfs and ocfs2 need to dump the page cache
before remapping blocks, not after.

In fixing the range checking problems I also realized that both dedupe
and copyfile tell userspace how much of the requested operation was
acted upon.  Since the range validation can shorten a clone request (or
we can ENOSPC midway through), we might as well plumb the short
operation reporting back through the VFS indirection code to userspace.

So, here's the whole giant pile of patches[1] that fix all the problems.
This branch is against 4.19-rc7 with Dave Chinner's XFS for-next branch.
The patch "generic: test reflink side effects" recently sent to fstests
exercises the fixes in this series.  Tests are in [2].

--D

[1] https://git.kernel.org/pub/scm/linux/kernel/git/djwong/xfs-linux.git/log/?h=djwong-devel
[2] https://git.kernel.org/pub/scm/linux/kernel/git/djwong/xfstests-dev.git/log/?h=djwong-devel
