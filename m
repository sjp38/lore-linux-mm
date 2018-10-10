Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 034FA6B0007
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:10:45 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v138-v6so2522600pgb.7
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:10:44 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id g12-v6si24049600pla.70.2018.10.09.17.10.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:10:43 -0700 (PDT)
Subject: [PATCH v2 00/25] fs: fixes for serious clone/dedupe problems
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Tue, 09 Oct 2018 17:10:38 -0700
Message-ID: <153913023835.32295.13962696655740190941.stgit@magnolia>
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
The patch "generic: test reflink side effects" recently sent to fstests
exercises the fixes in this series.  Tests are in [2].

--D

[1] https://git.kernel.org/pub/scm/linux/kernel/git/djwong/xfs-linux.git/log/?h=djwong-devel
[2] https://git.kernel.org/pub/scm/linux/kernel/git/djwong/xfstests-dev.git/log/?h=djwong-devel
