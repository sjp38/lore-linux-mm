Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E9B9F6B0071
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 20:54:41 -0400 (EDT)
Received: by pddn5 with SMTP id n5so133556618pdd.2
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 17:54:41 -0700 (PDT)
Date: Thu, 9 Apr 2015 10:54:23 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2][v2] blk-plug: don't flush nested plug lists
Message-ID: <20150409005423.GD13731@dastard>
References: <1428347694-17704-1-git-send-email-jmoyer@redhat.com>
 <1428347694-17704-2-git-send-email-jmoyer@redhat.com>
 <x49wq1nrcoe.fsf_-_@segfault.boston.devel.redhat.com>
 <20150408230203.GG15810@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150408230203.GG15810@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: linux-kernel@vger.kernel.org, dm-devel@redhat.com, xen-devel@lists.xenproject.org, linux-raid@vger.kernel.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

[ Sending again with a trimmed CC list to just the lists. Jeff - cc
lists that large get blocked by mailing lists... ]

On Tue, Apr 07, 2015 at 02:55:13PM -0400, Jeff Moyer wrote:
> The way the on-stack plugging currently works, each nesting level
> flushes its own list of I/Os.  This can be less than optimal (read
> awful) for certain workloads.  For example, consider an application
> that issues asynchronous O_DIRECT I/Os.  It can send down a bunch of
> I/Os together in a single io_submit call, only to have each of them
> dispatched individually down in the bowels of the dirct I/O code.
> The reason is that there are blk_plug-s instantiated both at the upper
> call site in do_io_submit and down in do_direct_IO.  The latter will
> submit as little as 1 I/O at a time (if you have a small enough I/O
> size) instead of performing the batching that the plugging
> infrastructure is supposed to provide.

I'm wondering what impact this will have on filesystem metadata IO
that needs to be issued immediately. e.g. we are doing writeback, so
there is a high level plug in place and we need to page in btree
blocks to do extent allocation. We do readahead at this point,
but it looks like this change will prevent the readahead from being
issued by the unplug in xfs_buf_iosubmit().

So while I can see how this can make your single microbenchmark
better (because it's only doing concurrent direct IO to the block
device and hence there are no dependencies between individual IOs),
I have significant reservations that it's actually a win for
filesystem-based workloads where we need direct control of flushing
to minimise IO latency due to IO dependencies...

Patches like this one:

https://lkml.org/lkml/2015/3/20/442

show similar real-world workload improvements to your patchset by
being smarter about using high level plugging to enable cross-file
merging of IO, but it still relies on the lower layers of plugging
to resolve latency bubbles caused by IO dependencies in the
filesystems.

> NOTE TO SUBSYSTEM MAINTAINERS: Before this patch, blk_finish_plug
> would always flush the plug list.  After this patch, this is only the
> case for the outer-most plug.  If you require the plug list to be
> flushed, you should be calling blk_flush_plug(current).  Btrfs and dm
> maintainers should take a close look at this patch and ensure they get
> the right behavior in the end.

IOWs, you are saying we need to change all our current unplugs to
blk_flush_plug(current) to *try* to maintain the same behaviour as
we currently have? I say *try*, because no instead of just flushing
the readahead IO on the plug, we'll also flush all the queued data
writeback IO onthe high level plug. We don't actually want to do
that; we only want to submit the readahead and not the bulk IO that
will delay the latency sensitive dependent IOs....

If that is the case, shouldn't you actually be trying to fix the
specific plugging problem you've identified (i.e. do_direct_IO() is
flushing far too frequently) rather than making a sweeping
generalisation that the IO stack plugging infrastructure
needs fundamental change?

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
