Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id D702E6B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 23:21:32 -0400 (EDT)
Date: Wed, 30 May 2012 11:21:29 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: write-behind on streaming writes
Message-ID: <20120530032129.GA7479@localhost>
References: <20120528114124.GA6813@localhost>
 <CA+55aFxHt8q8+jQDuoaK=hObX+73iSBTa4bBWodCX3s-y4Q1GQ@mail.gmail.com>
 <20120529155759.GA11326@localhost>
 <CA+55aFykFaBhzzEyRYWRS9Qoy_q_R65Cuth7=XvfOZEMqjn6=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFykFaBhzzEyRYWRS9Qoy_q_R65Cuth7=XvfOZEMqjn6=w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Vivek Goyal <vgoyal@redhat.com>

Linus,

On Tue, May 29, 2012 at 10:35:46AM -0700, Linus Torvalds wrote:
> On Tue, May 29, 2012 at 8:57 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> >
> > Actually O_SYNC is pretty close to the below code for the purpose of
> > limiting the dirty and writeback pages, except that it's not on by
> > default, hence means nothing for normal users.
> 
> Absolutely not.
> 
> O_SYNC syncs the *current* write, syncs your metadata, and just
> generally makes your writer synchronous. It's just a f*cking moronic
> idea. Nobody sane ever uses it, since you are much better off just
> using fsync() if you want that kind of behavior. That's one of those
> "stupid legacy flags" things that have no sane use.
> 
> The whole point is that doing that is never the right thing to do. You
> want to sync *past* writes, and you never ever want to wait on them
> unless you just sent more (newer) writes to the disk that you are
> *not* waiting on - so that you always have more IO pending.
> 
> O_SYNC is the absolutely anti-thesis of that kind of "multiple levels
> of overlapping IO". Because it requires that the IO is _done_ by the
> time you start more, which is against the whole point.

Yeah, O_SYNC is not really the sane thing to use.  Thanks for teaching
me this with great details!

> > It seems to me all about optimizing the 1-dd case for desktop users,
> > and the most beautiful thing about per-file write behind is, it keeps
> > both the number of dirty and writeback pages low in the system when
> > there are only one or two sequential dirtier tasks. Which is good for
> > responsiveness.
> 
> Yes, but I don't think it's about a single-dd case - it's about just
> trying to handle one common case (streaming writes) efficiently and
> naturally. Try to get those out of the system so that you can then
> worry about the *other* cases knowing that they don't have that kind
> of big streaming behavior.
> 
> For example, right now our main top-level writeback logic is *not*
> about streaming writes (just dirty counts), but then we try to "find"
> the locality by making the lower-level writeback do the whole "write
> back by chunking inodes" without really having any higher-level
> information.

Agreed. Streaming writes can be reliably detected in the same way as
readahead. And doing explicit write-behind for them may help make the
writeback more oriented and well behaved.

For example, consider file A being sequentially written to by dd, and
another mmapped file B being randomly written to. In the current
global writeback, the two files will likely have 1:1 share of the
dirty pages. With write-behind, we'll effectively limit file A's dirty
footprint to 2 chunk sizes, possibly leaving much more rooms for file
B and increase the chances it accumulate more adjacent dirty pages at
writeback time.

> I just suspect that we'd be better off teaching upper levels about the
> streaming. I know for a fact that if I do it by hand, system
> responsiveness was *much* better, and IO throughput didn't go down at
> all.

Your observation of better responsiveness may well be stemmed from
these two aspects:

1) lower dirty/writeback pages
2) the async write IO queue being drained constantly

(1) is obvious. For a mem=4G desktop, the default dirty limit can be
up to (4096 * 20% = 819MB). While your smart writer effectively limits
dirty/writeback pages to a dramatically lower 16MB.

(2) comes from the use of _WAIT_ flags in

        sync_file_range(..., SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER);

Each sync_file_range() syscall will submit 8MB write IO and wait for
completion. That means the async write IO queue constantly swing
between 0 and 8MB fillness at the frequency (100MBps / 8MB = 12.5ms).
So on every 12.5ms, the async IO queue runs empty, which gives any
pending read IO (from firefox etc.) a chance to be serviced. Nice
and sweet breaks!

I suspect (2) contributes *much more* than (1) to desktop responsiveness.

Because in a desktop with heavy sequential writes and sporadic reads,
the 20% dirty/writeback pages can hardly reach the end of LRU lists to
trigger waits in direct page reclaim.

On the other hand, it's a known problem that our IO scheculer is still
not that well behaved to provide good read latency when the flusher
rightfully manages to keep 100% fillness of the async IO queue all the
time.

The IO scheduler will be the right place to solve this issue. There's
nothing wrong for the flusher to blindly fill the async IO queue. It's
the flusher's duty to avoid underrun of the async IO queue and the IO
scheduler's duty to select the right queue to service (or to idle).
The IO scheduler *in theory* has all the information to do the right
decisions to _not service_ requests from the flusher when there are
reads observed recently...

> > Note that the above user space code won't work well when there are 10+
> > dirtier tasks. It effectively creates 10+ IO submitters on different
> > regions of the disk and thus create lots of seeks.
> 
> Not really much more than our current writeback code does. It
> *schedules* data for writing, but doesn't wait for it until much
> later.
>
> You seem to think it was synchronous. It's not. Look at the second
> sync_file_range() thing, and the important part is the "index-1". The
> fact that you confused this with O_SYNC seems to be the same thing.
> This has absolutely *nothing* to do with O_SYNC.
 
Hmm we should be sharing the same view here: it's not waiting for
"index", but does wait for "index-1" for clear of PG_writeback by
using SYNC_FILE_RANGE_WAIT_AFTER.

Or when there are 10+ writers running, each submitting 8MB data to the
async IO queue, they may well overrun the max IO queue size and get
blocked in the earlier stage of get_request_wait().

> The other important part is that the chunk size is fairly large. We do
> read-ahead in 64k kind of things, to make sense the write-behind
> chunking needs to be in "multiple megabytes".  8MB is probably the
> minimum size it makes sense.

Yup. And we also need to make sure it's not 10 tasks each scheduling
50MB write IOs *concurrently*. sync_file_range() is unfortunately
doing it this way by sending IO requests to the async IO queue on its
own, rather than delegating the work to the flusher and let one single
flusher submit IOs for them one after the other.

Imagine the async IO queue can hold exactly 50MB writeback pages. You
can see the obvious difference in the below graph. The IO queue will
be filled with dirty pages from (a) one single inode (b) 10 different
inodes. In the later case, the IO scheduler will switch between the
inodes much more frequently and create lots more seeks.

A theoretic view of the async IO queue:

    +----------------+               +----------------+
    |                |               |    inode 1     |
    |                |               +----------------+
    |                |               |    inode 2     |
    |                |               +----------------+
    |                |               |    inode 3     |
    |                |               +----------------+
    |                |               |    inode 4     |
    |                |               +----------------+
    |   inode 1      |               |    inode 5     |
    |                |               +----------------+
    |                |               |    inode 6     |
    |                |               +----------------+
    |                |               |    inode 7     |
    |                |               +----------------+
    |                |               |    inode 8     |
    |                |               +----------------+
    |                |               |    inode 9     |
    |                |               +----------------+
    |                |               |    inode 10    |
    +----------------+               +----------------+
    (a) one single flusher           (b) 10 sync_file_range()
        submitting 50MB IO               submitting 50MB IO
        for each inode *in turn*         for each inode *in parallel*

So if parallel file syncs are a common usage, we'll need to make them
IO-less, too.

> The write-behind would be for things like people writing disk images
> and video files. Not for random IO in smaller chunks.

Yup.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
