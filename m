Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2C86B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 00:37:46 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q143-v6so28357240pgq.12
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 21:37:46 -0700 (PDT)
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id c68-v6si35227218pfa.45.2018.10.21.21.37.43
        for <linux-mm@kvack.org>;
        Sun, 21 Oct 2018 21:37:44 -0700 (PDT)
Date: Mon, 22 Oct 2018 15:37:41 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 00/28] fs: fixes for serious clone/dedupe problems
Message-ID: <20181022043741.GX6311@dastard>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
 <20181022022112.GW6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022022112.GW6311@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Mon, Oct 22, 2018 at 01:21:12PM +1100, Dave Chinner wrote:
> On Sun, Oct 21, 2018 at 09:15:03AM -0700, Darrick J. Wong wrote:
> > Hi all,
> > 
> > Dave, Eric, and I have been chasing a stale data exposure bug in the XFS
> > reflink implementation, and tracked it down to reflink forgetting to do
> > some of the file-extending activities that must happen for regular
> > writes.
> > 
> > We then started auditing the clone, dedupe, and copyfile code and
> > realized that from a file contents perspective, clonerange isn't any
> > different from a regular file write.  Unfortunately, we also noticed
> > that *unlike* a regular write, clonerange skips a ton of overflow
> > checks, such as validating the ranges against s_maxbytes, MAX_NON_LFS,
> > and RLIMIT_FSIZE.  We also observed that cloning into a file did not
> > strip security privileges (suid, capabilities) like a regular write
> > would.  I also noticed that xfs and ocfs2 need to dump the page cache
> > before remapping blocks, not after.
> > 
> > In fixing the range checking problems I also realized that both dedupe
> > and copyfile tell userspace how much of the requested operation was
> > acted upon.  Since the range validation can shorten a clone request (or
> > we can ENOSPC midway through), we might as well plumb the short
> > operation reporting back through the VFS indirection code to userspace.
> > I added a few more cleanups to the xfs code per reviewer suggestions.
> > 
> > So, here's the whole giant pile of patches[1] that fix all the problems.
> > This branch is against current upstream (4.19-rc8).  The patch
> > "generic: test reflink side effects" recently sent to fstests exercises
> > the fixes in this series.  Tests are in [2].
> 
> Ok, so now that all the patches (other than the ocfs2 bits) have been
> reviewed, how do we want to merge this? I can take it through the
> XFS tree given that there is a bit of XFS changes that needs to be
> co-ordinated with it, or should it go through some other tree?

Ok, this is a bit of a mess. the patches do not merge cleanly to a
4.19-rc1 base kernel because of all the changes to
include/linux/fs.h that have hit the tree after this. There's also
failures against Documentation/filesystems/fs.h

IOWs, it's not going to get merged through the main XFS tree because
I don't have the patience to resolve all the patch application
failures, then when it comes to merge make sure all the merge
failures end up being resolved correctly.

So if I take it through the XFS tree, it will being a standalone
branch based on 4.19-rc8 and won't hit linux-next until after the
first XFS merge when I can rebase the for-next branch...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
