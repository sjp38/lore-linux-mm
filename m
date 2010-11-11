Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 639BB6B008C
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 08:32:21 -0500 (EST)
Date: Thu, 11 Nov 2010 14:32:11 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 3/5] writeback: stop background/kupdate works from livelocking other works
Message-ID: <20101111133211.GC12940@lst.de>
References: <20101108230916.826791396@intel.com> <20101108231726.993880740@intel.com> <20101109131310.f442d210.akpm@linux-foundation.org> <20101109222827.GJ4936@quack.suse.cz> <20101109150006.05892241.akpm@linux-foundation.org> <20101109235632.GD11214@quack.suse.cz> <20101110153729.81ae6b19.akpm@linux-foundation.org> <20101111004047.GA7879@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101111004047.GA7879@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2010 at 08:40:47AM +0800, Wu Fengguang wrote:
> Seriously, I also doubt the value of doing sync() in the flusher thread.
> sync() is by definition inefficient. In the block layer, it's served
> with less emphasis on throughput. In the VFS layer, it may sleep in
> inode_wait_for_writeback() and filemap_fdatawait(). In various FS,
> pages won't be skipped at the cost of more lock waiting.
> 
> So when a flusher thread is serving sync(), it has difficulties
> saturating the storage device.
> 
> btw, it seems current sync() does not take advantage of the flusher
> threads to sync multiple disks in parallel.

sys_sync does a wakeup_flusher_threads(0) which kicks all flusher
threads to write back all data.  We then do another serialized task
of kicking per-sb writeback, and then do synchronous per-sb writeback,
interwinded with non-blocking and blocking quota sync, ->sync_fs
and __sync_blockdev calls.

The way sync ended up looking like it did is rather historic:

 First Jan and I fixed sync to actually get data correctly to disk,
 the way is was done traditionally had a lot of issues with ordering
 it's steps.  For that we changed it to just loop around sync_filesystem
 to have one common place to define the proper order for it.
 That caused a large performance regression, which Yanmin Zhang found
 and fixed, which added back the wakeup_pdflush(0) (which later became
 wakeup_flusher_threads).

 The introduction of the per-bdi writeback threads by Jens changed
 writeback_inodes_sb and sync_inodes_sb to offload the I/O submission
 to the I/O thread.

I'm not overly happy with the current situation.  Part of that is
the rather complex callchain in __sync_filesystem.  If we moved the
quota sync and the sync_blockdev into ->sync_fs we'd already be down
to a much more managable level, and we could optimize sync down to:


	wakeup_flusher_threads(0);

	for_each_sb
		sb->sync_fs(sb, 0)

	for_each_sb {
		sync_inodes_sb(sb);
		sb->sync_fs(sb, 1)
	}

We would still try to do most of the I/O from the flusher thread,
but only if we can do it non-blocking.  If we have to block we'll
get less optimal I/O patterns, but at least we don't block other
writeback while waiting for it.

I suspect a big problem for the statving workloads is that we only
do the live-lock avoidance tagging inside sync_inodes_sb, so
any page written by wakeup_flusher_threads, or the writeback_inodes_sb
in the two first passes that gets redirties is synced out again.

But I'd feel very vary doing this without a lot of performance testing.
dpkg package install workloads, the ffsb create_4k test Yanmin used,
or fs_mark in one of the sync using versions would be a good benchmark.

Btw, where in the block I/O code do we penalize sync?


I don't think moving the I/O submission into the caller is going to
help us anything.  What we should look into instead is to make as
much of the I/O submission non-blocking even inside sync.  

> And I guess (concurrent) sync/fsync/msync calls will be rare,
> especially for really performance demanding workloads (which will
> optimize sync away in the first place).

There is no way to optimize a sync away if you want your data on disk.

The most common case is fsync, followed by O_SYNC, but for example due
to the massive fsync suckage on ext3 dpkg for example has switched to
sync instead, which is quite nasty if you have other work going on.

Offloading fsync to the flusher thread is an interesting idea, but I
wonder how well it works.  Both fsync and sync are calls the application
waits on to make progress, so naturally we gave them some preference
to decrease the latency will penalizing background writeback.  By
first trying an asynchronous pass via the flusher thread we could
optimize the I/O pattern, but at a huge cost to the latency for
the caller.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
