Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E1CB782F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 16:48:38 -0400 (EDT)
Received: by pasz6 with SMTP id z6so17086553pas.2
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 13:48:38 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id y12si72801968pbt.182.2015.10.28.13.48.36
        for <linux-mm@kvack.org>;
        Wed, 28 Oct 2015 13:48:37 -0700 (PDT)
Date: Thu, 29 Oct 2015 07:48:34 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Triggering non-integrity writeback from userspace
Message-ID: <20151028204834.GP8773@dastard>
References: <20151022131555.GC4378@alap3.anarazel.de>
 <20151024213912.GE8773@dastard>
 <20151028092752.GF29811@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151028092752.GF29811@alap3.anarazel.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Andres,

On Wed, Oct 28, 2015 at 10:27:52AM +0100, Andres Freund wrote:
> On 2015-10-25 08:39:12 +1100, Dave Chinner wrote:
....
> > Data integrity operations require related file metadata (e.g. block
> > allocation trnascations) to be forced to the journal/disk, and a
> > device cache flush issued to ensure the data is on stable storage.
> > SYNC_FILE_RANGE_WRITE does neither of these things, and hence while
> > the IO might be the same pattern as a data integrity operation, it
> > does not provide such guarantees.
> 
> Which is desired here - the actual integrity is still going to be done
> via fsync().

OK, so you require data integrity, but....

> The idea of using SYNC_FILE_RANGE_WRITE beforehand is that
> the fsync() will only have to do very little work. The language in
> sync_file_range(2) doesn't inspire enough confidence for using it as an
> actual integrity operation :/

So really you're trying to minimise the blocking/latency of fsync()?

> > You don't want to do writeback from the syscall, right? i.e. you'd
> > like to expire the inode behind the fd, and schedule background
> > writeback to run on it immediately?
> 
> Yes, that's exactly what we want. Blocking if a process has done too
> much writes is fine tho.

OK, so it's really the latency of the fsync() operation that is what
you are trying to avoid? I've been meaning to get back to a generic
implementation of an aio fsync operation:

http://oss.sgi.com/archives/xfs/2014-06/msg00214.html

Would that be a better approach to solving your need for a
non-blocking data integrity flush of a file?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
