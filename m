Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 719566B000A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 21:06:58 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 84-v6so2625986pgc.13
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 18:06:58 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 38-v6si19152274pgr.237.2018.10.09.18.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 18:06:57 -0700 (PDT)
Date: Tue, 9 Oct 2018 18:06:52 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v2 00/25] fs: fixes for serious clone/dedupe problems
Message-ID: <20181010010652.GK28243@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
 <20181010010208.GI6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010010208.GI6311@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Wed, Oct 10, 2018 at 12:02:08PM +1100, Dave Chinner wrote:
> On Tue, Oct 09, 2018 at 05:10:38PM -0700, Darrick J. Wong wrote:
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
> > 
> > So, here's the whole giant pile of patches[1] that fix all the problems.
> > The patch "generic: test reflink side effects" recently sent to fstests
> > exercises the fixes in this series.  Tests are in [2].
> 
> Can you rebase this on the for-next branch on the xfs tree which
> already contains some of the initial fixes in the series and a
> couple of other reflink/dedupe data corruption fixes? I'm planning
> on pushing them to Greg tomorrow, so you'll have to do this soon
> anyway....

<nod> I was planning to do that tomorrow, but figured I might as well
scrape for review comments in the mean time.

--D

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
