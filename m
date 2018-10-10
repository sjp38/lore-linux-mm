Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE056B027D
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 21:02:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 43-v6so2730189ple.19
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 18:02:59 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id i64-v6si23475531pli.56.2018.10.09.18.02.57
        for <linux-mm@kvack.org>;
        Tue, 09 Oct 2018 18:02:58 -0700 (PDT)
Date: Wed, 10 Oct 2018 12:02:08 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 00/25] fs: fixes for serious clone/dedupe problems
Message-ID: <20181010010208.GI6311@dastard>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153913023835.32295.13962696655740190941.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Tue, Oct 09, 2018 at 05:10:38PM -0700, Darrick J. Wong wrote:
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
> The patch "generic: test reflink side effects" recently sent to fstests
> exercises the fixes in this series.  Tests are in [2].

Can you rebase this on the for-next branch on the xfs tree which
already contains some of the initial fixes in the series and a
couple of other reflink/dedupe data corruption fixes? I'm planning
on pushing them to Greg tomorrow, so you'll have to do this soon
anyway....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
