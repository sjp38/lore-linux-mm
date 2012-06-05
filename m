Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 860D86B0062
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 21:01:56 -0400 (EDT)
Date: Tue, 5 Jun 2012 11:01:48 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: write-behind on streaming writes
Message-ID: <20120605010148.GE4347@dastard>
References: <20120528114124.GA6813@localhost>
 <CA+55aFxHt8q8+jQDuoaK=hObX+73iSBTa4bBWodCX3s-y4Q1GQ@mail.gmail.com>
 <20120529155759.GA11326@localhost>
 <CA+55aFykFaBhzzEyRYWRS9Qoy_q_R65Cuth7=XvfOZEMqjn6=w@mail.gmail.com>
 <20120530032129.GA7479@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120530032129.GA7479@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Vivek Goyal <vgoyal@redhat.com>

On Wed, May 30, 2012 at 11:21:29AM +0800, Fengguang Wu wrote:
> Linus,
> 
> On Tue, May 29, 2012 at 10:35:46AM -0700, Linus Torvalds wrote:
> > On Tue, May 29, 2012 at 8:57 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> > I just suspect that we'd be better off teaching upper levels about the
> > streaming. I know for a fact that if I do it by hand, system
> > responsiveness was *much* better, and IO throughput didn't go down at
> > all.
> 
> Your observation of better responsiveness may well be stemmed from
> these two aspects:
> 
> 1) lower dirty/writeback pages
> 2) the async write IO queue being drained constantly
> 
> (1) is obvious. For a mem=4G desktop, the default dirty limit can be
> up to (4096 * 20% = 819MB). While your smart writer effectively limits
> dirty/writeback pages to a dramatically lower 16MB.
> 
> (2) comes from the use of _WAIT_ flags in
> 
>         sync_file_range(..., SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER);
> 
> Each sync_file_range() syscall will submit 8MB write IO and wait for
> completion. That means the async write IO queue constantly swing
> between 0 and 8MB fillness at the frequency (100MBps / 8MB = 12.5ms).
> So on every 12.5ms, the async IO queue runs empty, which gives any
> pending read IO (from firefox etc.) a chance to be serviced. Nice
> and sweet breaks!
> 
> I suspect (2) contributes *much more* than (1) to desktop responsiveness.

Almost certainly, especially with NCQ devices where even if the IO
scheduler preempts the write queue immediately, the device might
complete the outstanding 31 writes before servicing the read which
is issued as the 32nd command....

So NCQ depth is going to play a part here as well.

> Because in a desktop with heavy sequential writes and sporadic reads,
> the 20% dirty/writeback pages can hardly reach the end of LRU lists to
> trigger waits in direct page reclaim.
> 
> On the other hand, it's a known problem that our IO scheculer is still
> not that well behaved to provide good read latency when the flusher
> rightfully manages to keep 100% fillness of the async IO queue all the
> time.

Deep queues are the antithesis of low latency. If you want good IO
interactivity (i.e. low access latency) you cannot keep deep async
IO queues. If you want good throughput, you need deep queues to
allow the best scheduling window as possible and to keep the IO
device as busy as possible.

> The IO scheduler will be the right place to solve this issue. There's
> nothing wrong for the flusher to blindly fill the async IO queue. It's
> the flusher's duty to avoid underrun of the async IO queue and the IO
> scheduler's duty to select the right queue to service (or to idle).
> The IO scheduler *in theory* has all the information to do the right
> decisions to _not service_ requests from the flusher when there are
> reads observed recently...

That's my take on the issue, too. Even if we decide that streaming
writes should be sync'd immeidately, where should we draw the limit?

I often write temporary files that would qualify as large streaming
writes (e.g. 1GB) and then immediately remove them. I rely on the
fact they don't hit the disk for performance (i.e. <1s to create,
wait 2s, <1s to read, <1s to unlink). If these are forced to disk
rather than sitting in memory for a short while, the create will now
take ~10s per file and I won't be able to create 10 of them
concurrently and have them all take <1s to create....

IOWs, what might seem like an interactivity optimisation for
one workload will quite badly affect the performance of a different
workload. Optimising read latency vs write bandwidth is exactly what
we have IO schedulers for....

> Or when there are 10+ writers running, each submitting 8MB data to the
> async IO queue, they may well overrun the max IO queue size and get
> blocked in the earlier stage of get_request_wait().

Yup, as soon as you have multiple IO submitters, we get back to the
old problem of thrashing the disks. This is *exactly* the throughput
problem we solved by moving to IO-less throttling. That is, having N
IO submitters is far less efficient than having a single, well
controlled IO submitter. That's exactly what we want to avoid...

> > The other important part is that the chunk size is fairly large. We do
> > read-ahead in 64k kind of things, to make sense the write-behind
> > chunking needs to be in "multiple megabytes".  8MB is probably the
> > minimum size it makes sense.
> 
> Yup. And we also need to make sure it's not 10 tasks each scheduling
> 50MB write IOs *concurrently*. sync_file_range() is unfortunately
> doing it this way by sending IO requests to the async IO queue on its
> own, rather than delegating the work to the flusher and let one single
> flusher submit IOs for them one after the other.

Yup, that's the thrashing we need to avoid ;)

> So if parallel file syncs are a common usage, we'll need to make them
> IO-less, too.

Or just tell people "don't do that"

> > The write-behind would be for things like people writing disk images
> > and video files. Not for random IO in smaller chunks.

Or you could just use async direct IO to acheive exactly the same
thing without modifying the kernel at all ;)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
